import 'dart:async';
import 'package:fishpi/fishpi.dart';
import 'package:fishpi_app/core/chat/chat_message_utils.dart';
import 'package:fishpi_app/core/im_event.dart';
import 'package:fishpi_app/core/manager/toast.dart';
import 'package:fishpi_app/core/sql/black_list.dart';
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
        final history = await imController.fishpi.chatroom.more(1);
        for (final message in history.reversed) {
          _appendMessage(message, shouldScroll: false);
        }
      }
      _chatRoomSubscription ??=
          imController.chatRoomStream.listen(_onChatRoomData);
      scrollToBottom(delay: 300);
    } else {
      List<ChatData> list = await imController.fishpi.chat.get(
        user: userName.value,
        page: 1,
      );
      list = list.reversed.toList();
      for (var ele in list) {
        _appendMessage(
          ChatMessageUtils.chatDataToRoomMessage(ele),
          shouldScroll: false,
        );
      }
      messageList.refresh();
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
        maxLength: isGroup.value ? 50 : null,
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
    final distance = chatRoomController.position.maxScrollExtent -
        chatRoomController.position.pixels;
    isSeeHistory.value = distance >= 100;
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

  @override
  void onClose() {
    isClose.value = true;
    _chatRoomSubscription?.cancel();
    _privateChatSubscription?.cancel();
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
