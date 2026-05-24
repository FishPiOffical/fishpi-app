import 'dart:async';
import 'package:fishpi/fishpi.dart';
import 'package:fishpi_app/core/chat/chat_message_utils.dart';
import 'package:fishpi_app/core/im_event.dart';
import 'package:fishpi_app/core/manager/toast.dart';
import 'package:fishpi_app/core/sql/black_list.dart';
import 'package:fishpi_app/core/sql/user_remark.dart';
import 'package:fishpi_app/pages/conversation/conversation_logic.dart';
import 'package:fishpi_app/routers/navigator.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../core/controller/im.dart';

class ChatLogic extends GetxController {
  final imController = Get.find<IMController>();
  final messageList = <ChatRoomMessage>[].obs;
  final chatMsgList = <ChatData>[].obs;
  final userInfo = UserInfo().obs;

  final isGroup = false.obs;
  final userName = ''.obs;
  final userID = ''.obs;
  final isClose = true.obs;
  final isSeeHistory = false.obs;
  final isLoadingHistory = false.obs;
  final hasMoreHistory = true.obs;
  final historyPage = 0.obs;
  final remarkVersion = 0.obs;
  final int historyPageSize = 20;

  ScrollController chatRoomController = ScrollController();
  TextEditingController chatRoomControllerText = TextEditingController();
  FocusNode chatRoomFocusNode = FocusNode();

  final content = ''.obs;

  get emojiList => imController.fishpi.emoji.defaultEmojis;
  final diyEmojiList = <String>[].obs;
  final emojiIndex = 0.obs;
  final List<BlackUser> _blackUsers = [];
  StreamSubscription<ChatRoomData>? _chatRoomSubscription;
  StreamSubscription<PrivateChatEvent>? _privateChatSubscription;
  StreamSubscription<void>? _blackListSubscription;
  StreamSubscription<void>? _remarkSubscription;
  bool _scrollListenerAttached = false;

  ConversationLogic? get _conversationController =>
      Get.isRegistered<ConversationLogic>()
          ? Get.find<ConversationLogic>()
          : null;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments ?? {};
    isGroup.value = args['isGroup'] ?? false;
    userName.value = args['userName'] ?? '聊天室';
    userID.value = args['userID'] ?? '';
    if (isGroup.value) {
      messageList.addAll(_conversationController?.chatRoomMsg ?? []);
      messageList.refresh();
      scrollToBottom(delay: 300);
    }
    imController.fishpi.user.info().then((value) => userInfo.value = value);
    isClose.value = false;
    _blackListSubscription ??= BlackList.changes.listen((_) {
      _reloadBlackUsersAndFilterMessages();
    });
    UserRemark.init();
    _remarkSubscription ??= UserRemark.changes.listen((_) {
      remarkVersion.value++;
    });
    initChatRoom();
    loadEmojis();
  }

  @override
  void onReady() {
    super.onReady();
    if (!_scrollListenerAttached) {
      chatRoomController.addListener(_handleScroll);
      _scrollListenerAttached = true;
    }
  }

  void initChatRoom() async {
    await _loadBlackUsers();
    if (isGroup.value) {
      if (messageList.isEmpty) {
        await _loadInitialHistory();
      } else {
        historyPage.value = 1;
      }
      _chatRoomSubscription ??=
          imController.chatRoomStream.listen(_onChatRoomData);
      scrollToBottom(delay: 300);
    } else {
      await _loadInitialHistory(markPrivateRead: true);
      scrollToBottom(delay: 300);
      _privateChatSubscription ??= imController
          .watchPrivateChat(userName.value)
          .listen(_onPrivateChatEvent);
    }
  }

  void _onChatRoomData(ChatRoomData data) {
    if (data.type == ChatRoomMessageType.revoke) {
      _removeMessage(data.revoke ?? '');
      return;
    }
    final message = data.msg;
    if (message == null) return;
    _appendMessage(message);
  }

  void _onPrivateChatEvent(PrivateChatEvent event) {
    if (event.isRevoke) {
      _removeMessage(event.revoke ?? '');
      return;
    }
    final data = event.data;
    if (data == null) return;
    _appendMessage(ChatMessageUtils.chatDataToRoomMessage(data));
  }

  void _appendMessage(
    ChatRoomMessage message, {
    bool shouldScroll = true,
  }) {
    if (ChatMessageUtils.isBlockedMessage(message, _blackUsers)) return;
    messageList.assignAll(
      ChatMessageUtils.appendUniqueChatRoomMessage(
        messageList,
        message,
      ),
    );
    messageList.refresh();
    if (shouldScroll) {
      scrollToBottom(delay: 300);
    }
  }

  void _removeMessage(String messageId) {
    messageList.assignAll(
      ChatMessageUtils.removeChatRoomMessage(messageList, messageId),
    );
    messageList.refresh();
  }

  void _handleScroll() {
    if (!chatRoomController.hasClients) return;
    final position = chatRoomController.position;
    final distance = position.maxScrollExtent - position.pixels;
    isSeeHistory.value = distance >= 100;
    if (position.pixels <= 80) {
      loadMoreHistory();
    }
  }

  Future<void> _loadInitialHistory({bool markPrivateRead = false}) async {
    isLoadingHistory.value = true;
    try {
      final result = await _fetchHistoryPage(
        1,
        markPrivateRead: markPrivateRead,
      );
      hasMoreHistory.value =
          ChatMessageUtils.hasMoreHistoryPage(result.rawCount);
      if (!hasMoreHistory.value) return;

      historyPage.value = 1;
      messageList.assignAll(result.messages);
      messageList.refresh();
    } catch (e) {
      ToastManager.showToast('加载历史消息失败：$e');
    } finally {
      isLoadingHistory.value = false;
    }
  }

  Future<void> loadMoreHistory() async {
    if (isLoadingHistory.value || !hasMoreHistory.value) return;

    final oldMaxScrollExtent = chatRoomController.hasClients
        ? chatRoomController.position.maxScrollExtent
        : 0.0;
    final oldPixels = chatRoomController.hasClients
        ? chatRoomController.position.pixels
        : 0.0;

    isLoadingHistory.value = true;
    try {
      final nextPage = historyPage.value + 1;
      final result = await _fetchHistoryPage(
        nextPage,
        markPrivateRead: false,
      );
      hasMoreHistory.value =
          ChatMessageUtils.hasMoreHistoryPage(result.rawCount);
      if (!hasMoreHistory.value) return;

      historyPage.value = nextPage;
      final beforeLength = messageList.length;
      messageList.assignAll(
        ChatMessageUtils.prependUniqueChatRoomMessages(
          messageList,
          result.messages,
        ),
      );
      messageList.refresh();

      if (messageList.length > beforeLength) {
        _restoreScrollOffsetAfterPrepend(oldMaxScrollExtent, oldPixels);
      }
    } catch (e) {
      ToastManager.showToast('加载历史消息失败：$e');
    } finally {
      isLoadingHistory.value = false;
    }
  }

  Future<_HistoryPageResult> _fetchHistoryPage(
    int page, {
    required bool markPrivateRead,
  }) async {
    if (isGroup.value) {
      final history = await imController.fishpi.chatroom.more(page);
      final messages = ChatMessageUtils.visibleMessages(
        history.reversed,
        _blackUsers,
      );
      return _HistoryPageResult(
        rawCount: history.length,
        messages: messages,
      );
    }

    final history = await imController.fishpi.chat.get(
      user: userName.value,
      page: page,
      size: historyPageSize,
      autoRead: markPrivateRead,
    );
    final messages =
        history.reversed.map(ChatMessageUtils.chatDataToRoomMessage).toList();
    return _HistoryPageResult(
      rawCount: history.length,
      messages: ChatMessageUtils.visibleMessages(messages, _blackUsers),
    );
  }

  void _restoreScrollOffsetAfterPrepend(
    double oldMaxScrollExtent,
    double oldPixels,
  ) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isClose.value || !chatRoomController.hasClients) return;

      final position = chatRoomController.position;
      final addedExtent = position.maxScrollExtent - oldMaxScrollExtent;
      final target = (oldPixels + addedExtent)
          .clamp(0.0, position.maxScrollExtent)
          .toDouble();
      chatRoomController.jumpTo(target);
    });
  }

  void scrollToBottom({int? delay}) {
    if (isClose.value || isSeeHistory.value) return;
    Future.delayed(Duration(milliseconds: delay ?? 200), () {
      if (chatRoomController.hasClients) {
        chatRoomController.animateTo(
          chatRoomController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void onInput(String text) {
    content.value = text;
  }

  void clickUserAvatar(String userName) {
    AppNavigator.toUserPanel(userName: userName);
  }

  void toChatRoomSettings() {
    if (!isGroup.value) return;
    AppNavigator.toChatRoomSettings();
  }

  String displayNameFor(String userName, {String? fallback}) {
    // 让 Obx 感知备注变更，触发当前聊天页的昵称刷新。
    remarkVersion.value;
    return UserRemark.displayName(userName, fallback: fallback);
  }

  Future<void> clickSend() async {
    final text = content.value;
    if (text.trim().isEmpty) return;

    try {
      if (isGroup.value) {
        await imController.fishpi.chatroom.send(text);
      } else {
        await imController.fishpi.chat.send(userName.value, text);
      }
      content.value = '';
      chatRoomControllerText.clear();
      scrollToBottom(delay: 300);
    } catch (e) {
      ToastManager.showToast('发送失败：$e');
    }
  }

  void loadEmojis() async {
    try {
      diyEmojiList.value = await imController.fishpi.emoji.get();
      diyEmojiList.refresh();
    } catch (_) {}
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

  Future<void> _reloadBlackUsersAndFilterMessages() async {
    await _loadBlackUsers();
    messageList.assignAll(
      ChatMessageUtils.visibleMessages(messageList, _blackUsers),
    );
    messageList.refresh();
  }

  @override
  void onClose() {
    isClose.value = true;
    _chatRoomSubscription?.cancel();
    _privateChatSubscription?.cancel();
    _blackListSubscription?.cancel();
    _remarkSubscription?.cancel();
    if (!isGroup.value) {
      imController.unwatchPrivateChat(userName.value);
    }
    if (_scrollListenerAttached) {
      chatRoomController.removeListener(_handleScroll);
    }
    chatRoomController.dispose();
    chatRoomControllerText.dispose();
    chatRoomFocusNode.dispose();
    super.onClose();
  }
}

class _HistoryPageResult {
  final int rawCount;
  final List<ChatRoomMessage> messages;

  const _HistoryPageResult({
    required this.rawCount,
    required this.messages,
  });
}
