import 'dart:async';

import 'package:fishpi/types/chat.dart';
import 'package:fishpi/types/chatroom.dart';
import 'package:fishpi/types/user.dart';
import 'package:get/get.dart';

import '../../core/chat/chat_message_utils.dart';
import '../../core/controller/im.dart';
import '../../core/im_event.dart';
import '../../core/sql/black_list.dart';
import '../../core/sql/chat_room_block_list.dart';
import '../../core/sql/user_remark.dart';

class ConversationLogic extends GetxController {
  final imController = Get.find<IMController>();
  final chatList = <ChatData>[].obs;
  final chatRoomLastMsg = ChatRoomMessage().obs;
  final currentUser = UserInfo().obs;
  final remarkVersion = 0.obs;
  final isLoading = false.obs;
  final showItem = "";
  final chatRoomMsg = <ChatRoomMessage>[].obs;
  final List<BlackUser> _blackUsers = [];
  final List<ChatRoomBlockedUser> _chatRoomBlockedUsers = [];
  StreamSubscription<ChatRoomData>? _chatRoomSubscription;
  StreamSubscription<PrivateChatEvent>? _privateChatSubscription;
  StreamSubscription<void>? _blackListSubscription;
  StreamSubscription<void>? _chatRoomBlockListSubscription;
  StreamSubscription<void>? _remarkSubscription;

  @override
  void onInit() {
    super.onInit();
    loadHistoryMessage();
  }

  Future<void> loadHistoryMessage() async {
    if (isLoading.value) return;
    isLoading.value = true;
    await _loadBlackUsers();
    await _loadChatRoomBlockedUsers();
    await _loadCurrentUser();
    try {
      final list = await imController.fishpi.chat.list();
      chatList.assignAll(list);
    } catch (_) {}

    try {
      final history = await imController.fishpi.chatroom.more(1);
      final visibleHistory = _visibleChatRoomMessages(history.reversed);
      chatRoomMsg.assignAll(visibleHistory);
      chatRoomLastMsg.value =
          visibleHistory.isEmpty ? ChatRoomMessage() : visibleHistory.last;
    } catch (_) {
      chatRoomMsg.clear();
      chatRoomLastMsg.value = ChatRoomMessage();
    } finally {
      isLoading.value = false;
    }
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
      chatList.refresh();
      return;
    }

    if (event.isNotice) {
      _refreshChatList();
    }
  }

  Future<void> _refreshChatList() async {
    try {
      chatList.assignAll(await imController.fishpi.chat.list());
    } catch (_) {}
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
