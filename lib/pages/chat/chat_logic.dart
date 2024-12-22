import 'dart:async';
import 'package:fishpi/fishpi.dart';
import 'package:fishpi_app/pages/conversation/conversation_logic.dart';
import 'package:fishpi_app/routers/navigator.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../core/controller/im.dart';

class ChatLogic extends GetxController {
  final imController = Get.find<IMController>();
  final conversationController = Get.find<ConversationLogic>();
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

  @override
  void onInit() {
    super.onInit();
    var args = Get.arguments;
    isGroup.value = args['isGroup'] ?? false;
    userName.value = args['userName'] ?? '聊天室';
    userID.value = args['userID'] ?? '';
    print(
        "pageArgs:isGroup:${args['isGroup']},userName:${args['userName']},userID:${args['userID']}");
    if (isGroup.value) {
      messageList.addAll(conversationController.chatRoomMsg);
      messageList.refresh();
      scrollToBottom(delay: 300);
    }
    imController.fishpi.user.info().then((value) => userInfo.value = value);
    isClose.value = false;
    if (chatRoomController.hasClients) {
      chatRoomController.addListener(() {
        if (chatRoomController.position.maxScrollExtent -
                chatRoomController.position.pixels >=
            100) {
          isSeeHistory.value = true;
        } else {
          isSeeHistory.value = false;
        }
      });
    }
    initChatRoom();
    loadEmojis();
  }

  void initChatRoom() async {
    if (isGroup.value) {
      imController.onRecvNewMessage = (ChatRoomMessage msg) {
        messageList.add(msg);
        if (messageList.length > 50) {
          messageList.removeAt(0);
        }
        messageList.refresh();
      };
      imController.onRecvRedPacketMessage = (ChatRoomMessage msg) {
        messageList.add(msg);
        messageList.refresh();
      };
      scrollToBottom(delay: 300);
    } else {
      List<ChatData> list = await imController.fishpi.chat.get(
        user: userName.value,
        page: 1,
      );
      list = list.reversed.toList();
      for (var ele in list) {
        messageList.add(ChatRoomMessage(
          oId: ele.oId,
          content: ele.content,
          userName: ele.senderUserName,
          userOId: int.parse(ele.fromId),
          time: ele.time,
          avatarURL: ele.senderAvatar,
          md: ele.markdown,
        ));
      }
      messageList.refresh();
      scrollToBottom(delay: 300);
      imController.fishpi.chat.addListener(chatMsgListen, user: userName.value);
    }
  }

  void chatMsgListen(
    /// 消息类型
    ChatMsgType type, {
    /// 新聊天通知
    ChatNotice? notice,

    /// 聊天内容
    ChatData? data,

    /// 撤回聊天
    ChatRevoke? revoke,
  }) {
    if (type != ChatMsgType.data) return;
    messageList.add(ChatRoomMessage(
      oId: data!.oId,
      content: data.content,
      userName: data.senderUserName,
      userOId: int.parse(data.fromId),
      time: data.time,
      avatarURL: data.senderAvatar,
      md: data.markdown,
    ));
    messageList.refresh();
    scrollToBottom(delay: 300);
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

  void clickSend() async {
    if (isGroup.value) {
      await imController.fishpi.chatroom.send(content.value);
    } else {
      await imController.fishpi.chat.send(userName.value, content.value);
    }
    content.value = '';
    chatRoomControllerText.text = '';
    scrollToBottom(delay: 300);
  }

  void loadEmojis() async {
    diyEmojiList.value = await imController.fishpi.emoji.get();
    diyEmojiList.refresh();
  }

  @override
  void onClose() {
    isClose.value = true;
    chatRoomController.dispose();
    if (!isGroup.value){
      imController.fishpi.chat.removeListener();
    }
    print('聊天页面关闭');
    super.onClose();
  }
}
