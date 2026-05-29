import 'dart:async';

import 'package:fishpi/types/chat.dart';
import 'package:fishpi/types/chatroom.dart';
import 'package:fishpi/types/user.dart';
import 'package:get/get.dart';

import '../../core/chat/chat_message_utils.dart';
import '../../core/controller/im.dart';
import '../../core/im_event.dart';
import '../../core/network/app_error_message.dart';
import '../../core/sql/black_list.dart';
import '../../core/sql/chat_room_block_list.dart';
import '../../core/sql/user_remark.dart';

class ConversationLogic extends GetxController {
  ConversationLogic({this.autoLoad = true});

  final bool autoLoad;
  final imController = Get.find<IMController>();
  final chatList = <ChatData>[].obs;
  final chatRoomLastMsg = ChatRoomMessage().obs;
  final currentUser = UserInfo().obs;
  final remarkVersion = 0.obs;
  final privatePeerNicknames = <String, String>{}.obs;
  final isLoading = false.obs;
  final errorText = ''.obs;
  final showItem = "";
  final chatRoomMsg = <ChatRoomMessage>[].obs;
  final List<BlackUser> _blackUsers = [];
  final List<ChatRoomBlockedUser> _chatRoomBlockedUsers = [];
  final Set<String> _loadingPrivatePeerNicknames = {};
  final Map<String, DateTime> _privatePeerNicknameFailures = {};
  StreamSubscription<ChatRoomData>? _chatRoomSubscription;
  StreamSubscription<PrivateChatEvent>? _privateChatSubscription;
  StreamSubscription<void>? _blackListSubscription;
  StreamSubscription<void>? _chatRoomBlockListSubscription;
  StreamSubscription<void>? _remarkSubscription;

  @override
  void onInit() {
    super.onInit();
    if (autoLoad) {
      loadHistoryMessage();
    }
  }

  Future<void> loadHistoryMessage() async {
    if (isLoading.value) return;
    isLoading.value = true;
    final errors = <String>[];
    await _loadBlackUsers();
    await _loadChatRoomBlockedUsers();
    await _loadCurrentUser();
    try {
      final list = await imController.fishpi.chat.list();
      chatList.assignAll(list);
      _warmPrivatePeerNicknames(list);
    } catch (e) {
      errors.add(
        AppErrorMessage.friendly(e, fallback: '私聊会话加载失败'),
      );
    }

    try {
      final history = await imController.fishpi.chatroom.more(1);
      final visibleHistory = _visibleChatRoomMessages(history.reversed);
      chatRoomMsg.assignAll(visibleHistory);
      chatRoomLastMsg.value =
          visibleHistory.isEmpty ? ChatRoomMessage() : visibleHistory.last;
    } catch (e) {
      errors.add(
        AppErrorMessage.friendly(e, fallback: '聊天室消息加载失败'),
      );
      if (chatRoomMsg.isEmpty) {
        chatRoomLastMsg.value = ChatRoomMessage();
      }
    } finally {
      isLoading.value = false;
    }
    errorText.value = errors.join('\n');
    chatList.refresh();
    chatRoomMsg.refresh();
    chatRoomLastMsg.refresh();
    initChat();
  }

  Future<void> refreshConversations() async {
    await loadHistoryMessage();
  }

  void initChat() {
    _chatRoomSubscription ??= imController.chatRoomStream.listen(_onChatRoom);
    _privateChatSubscription ??=
        imController.privateChatStream.listen(_onPrivateChat);
    _blackListSubscription ??= BlackList.changes.listen((_) {
      _reloadBlackUsersAndFilterChatRoom();
    });
    _chatRoomBlockListSubscription ??= ChatRoomBlockList.changes.listen((_) {
      _reloadChatRoomBlockedUsersAndFilterChatRoom();
    });
    UserRemark.init();
    _remarkSubscription ??= UserRemark.changes.listen((_) {
      remarkVersion.value++;
    });
  }

  String displayNameFor(String userName, {String? fallback}) {
    // 让会话列表在备注变更时刷新显示名。
    remarkVersion.value;
    return UserRemark.displayName(userName, fallback: fallback);
  }

  String privatePeerDisplayName(ChatData chat) {
    return displayNameFor(
      privatePeerName(chat),
      fallback: privatePeerFallbackName(chat),
    );
  }

  String privatePeerFallbackName(
    ChatData chat, {
    bool loadIfMissing = true,
  }) {
    final nickname = _privatePeerNicknameFromChat(chat).trim();
    if (nickname.isNotEmpty) return nickname;

    final peerName = privatePeerName(chat).trim();
    final cachedNickname = privatePeerNicknames[peerName]?.trim() ?? '';
    if (cachedNickname.isNotEmpty) return cachedNickname;

    if (loadIfMissing) {
      _ensurePrivatePeerNickname(peerName);
    }
    return peerName;
  }

  String chatRoomSenderDisplayName(ChatRoomMessage message) {
    final fallback = message.nickname.trim().isNotEmpty
        ? message.nickname.trim()
        : message.userName.trim();
    return displayNameFor(message.userName, fallback: fallback);
  }

  String privatePeerName(ChatData chat) {
    final currentName = currentUser.value.userName.trim();
    if (currentName.isNotEmpty) {
      if (chat.senderUserName == currentName) return chat.receiverUserName;
      if (chat.receiverUserName == currentName) return chat.senderUserName;
    }

    final currentId = currentUser.value.oId.trim();
    if (currentId.isNotEmpty) {
      if (chat.fromId == currentId) return chat.receiverUserName;
      if (chat.toId == currentId) return chat.senderUserName;
    }

    return chat.receiverUserName.isNotEmpty
        ? chat.receiverUserName
        : chat.senderUserName;
  }

  String privatePeerId(ChatData chat) {
    final currentId = currentUser.value.oId.trim();
    if (currentId.isNotEmpty) {
      if (chat.fromId == currentId) return chat.toId;
      if (chat.toId == currentId) return chat.fromId;
    }

    final currentName = currentUser.value.userName.trim();
    if (currentName.isNotEmpty) {
      if (chat.senderUserName == currentName) return chat.toId;
      if (chat.receiverUserName == currentName) return chat.fromId;
    }

    return chat.fromId;
  }

  String privatePeerAvatar(ChatData chat) {
    final currentName = currentUser.value.userName.trim();
    if (currentName.isNotEmpty) {
      if (chat.senderUserName == currentName) return chat.receiverAvatar;
      if (chat.receiverUserName == currentName) return chat.senderAvatar;
    }

    final currentId = currentUser.value.oId.trim();
    if (currentId.isNotEmpty) {
      if (chat.fromId == currentId) return chat.receiverAvatar;
      if (chat.toId == currentId) return chat.senderAvatar;
    }

    return chat.receiverAvatar.isNotEmpty
        ? chat.receiverAvatar
        : chat.senderAvatar;
  }

  String _privatePeerNicknameFromChat(ChatData chat) {
    final currentName = currentUser.value.userName.trim();
    if (currentName.isNotEmpty) {
      if (chat.senderUserName == currentName) return chat.receiverNickname;
      if (chat.receiverUserName == currentName) return chat.senderNickname;
    }

    final currentId = currentUser.value.oId.trim();
    if (currentId.isNotEmpty) {
      if (chat.fromId == currentId) return chat.receiverNickname;
      if (chat.toId == currentId) return chat.senderNickname;
    }

    return chat.receiverNickname.trim().isNotEmpty
        ? chat.receiverNickname
        : chat.senderNickname;
  }

  void _warmPrivatePeerNicknames(Iterable<ChatData> chats) {
    for (final chat in chats.take(20)) {
      final peerName = privatePeerName(chat).trim();
      final nickname = _privatePeerNicknameFromChat(chat).trim();
      if (peerName.isEmpty) continue;
      if (nickname.isNotEmpty) {
        privatePeerNicknames[peerName] = nickname;
      } else {
        _ensurePrivatePeerNickname(peerName);
      }
    }
  }

  void _ensurePrivatePeerNickname(String userName) {
    final normalizedUserName = userName.trim();
    if (normalizedUserName.isEmpty) return;
    if ((privatePeerNicknames[normalizedUserName]?.trim() ?? '').isNotEmpty) {
      return;
    }
    if (_loadingPrivatePeerNicknames.contains(normalizedUserName)) return;

    final failedAt = _privatePeerNicknameFailures[normalizedUserName];
    if (failedAt != null &&
        DateTime.now().difference(failedAt) < const Duration(minutes: 5)) {
      return;
    }

    _loadingPrivatePeerNicknames.add(normalizedUserName);
    unawaited(
      imController.fishpi.getUser(normalizedUserName).then((user) {
        final nickname = user.nickname.trim();
        if (nickname.isNotEmpty) {
          privatePeerNicknames[normalizedUserName] = nickname;
          _privatePeerNicknameFailures.remove(normalizedUserName);
        }
      }).catchError((_) {
        _privatePeerNicknameFailures[normalizedUserName] = DateTime.now();
      }).whenComplete(() {
        _loadingPrivatePeerNicknames.remove(normalizedUserName);
      }),
    );
  }

  void _onChatRoom(ChatRoomData data) {
    if (data.type == ChatRoomMessageType.revoke) {
      chatRoomMsg.assignAll(
        ChatMessageUtils.removeChatRoomMessage(
          chatRoomMsg,
          data.revoke ?? '',
        ),
      );
      chatRoomMsg.refresh();
      return;
    }

    final message = data.msg;
    if (message == null || _isChatRoomMessageBlocked(message)) {
      return;
    }

    chatRoomLastMsg.value = message;
    chatRoomMsg.assignAll(
      ChatMessageUtils.appendUniqueChatRoomMessage(
        chatRoomMsg,
        message,
        maxLength: 100,
      ),
    );
    chatRoomLastMsg.refresh();
    chatRoomMsg.refresh();
  }

  void _onPrivateChat(PrivateChatEvent event) {
    if (event.isRevoke) {
      chatList.assignAll(
        ChatMessageUtils.removePrivateConversationMessage(
          chatList,
          event.revoke ?? '',
        ),
      );
      chatList.refresh();
      return;
    }

    final data = event.data;
    if (data != null) {
      chatList.assignAll(
        ChatMessageUtils.upsertPrivateConversation(chatList, data),
      );
      _warmPrivatePeerNicknames([data]);
      chatList.refresh();
      return;
    }

    if (event.isNotice) {
      _refreshChatList();
    }
  }

  Future<void> _refreshChatList() async {
    try {
      final list = await imController.fishpi.chat.list();
      chatList.assignAll(list);
      _warmPrivatePeerNicknames(list);
      errorText.value = '';
    } catch (e) {
      errorText.value = AppErrorMessage.friendly(
        e,
        fallback: '私聊会话加载失败',
      );
    }
    chatList.refresh();
  }

  Future<void> _loadBlackUsers() async {
    try {
      await BlackList.init();
      _blackUsers
        ..clear()
        ..addAll(await BlackList.getAllUser());
    } catch (_) {
      _blackUsers.clear();
    }
  }

  Future<void> _loadChatRoomBlockedUsers() async {
    try {
      await ChatRoomBlockList.init();
      _chatRoomBlockedUsers
        ..clear()
        ..addAll(await ChatRoomBlockList.getAllUser());
    } catch (_) {
      _chatRoomBlockedUsers.clear();
    }
  }

  Future<void> _loadCurrentUser() async {
    try {
      currentUser.value = await imController.fishpi.user.info();
    } catch (_) {}
  }

  bool _isChatRoomMessageBlocked(ChatRoomMessage message) {
    return ChatMessageUtils.isBlockedMessage(
      message,
      _blackUsers,
      chatRoomBlockedUsers: _chatRoomBlockedUsers,
    );
  }

  List<ChatRoomMessage> _visibleChatRoomMessages(
    Iterable<ChatRoomMessage> messages,
  ) {
    return ChatMessageUtils.visibleMessages(
      messages,
      _blackUsers,
      chatRoomBlockedUsers: _chatRoomBlockedUsers,
    );
  }

  Future<void> _reloadBlackUsersAndFilterChatRoom() async {
    await _loadBlackUsers();
    chatRoomMsg.assignAll(_visibleChatRoomMessages(chatRoomMsg));
    chatRoomLastMsg.value =
        chatRoomMsg.isEmpty ? ChatRoomMessage() : chatRoomMsg.last;
    chatRoomMsg.refresh();
    chatRoomLastMsg.refresh();
  }

  Future<void> _reloadChatRoomBlockedUsersAndFilterChatRoom() async {
    await _loadChatRoomBlockedUsers();
    chatRoomMsg.assignAll(_visibleChatRoomMessages(chatRoomMsg));
    chatRoomLastMsg.value =
        chatRoomMsg.isEmpty ? ChatRoomMessage() : chatRoomMsg.last;
    chatRoomMsg.refresh();
    chatRoomLastMsg.refresh();
  }

  @override
  void onClose() {
    _chatRoomSubscription?.cancel();
    _privateChatSubscription?.cancel();
    _blackListSubscription?.cancel();
    _chatRoomBlockListSubscription?.cancel();
    _remarkSubscription?.cancel();
    super.onClose();
  }
}
