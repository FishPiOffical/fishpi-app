import 'package:fishpi/types/chat.dart';
import 'package:fishpi/types/chatroom.dart';
import 'package:get/get.dart';

import '../../core/controller/im.dart';

class ConversationLogic extends GetxController {
  final imController = Get.find<IMController>();
  final chatList = <ChatData>[].obs;
  final chatRoomLastMsg = ChatRoomMessage().obs;
  final showItem = "";
  final chatRoomMsg = <ChatRoomMessage>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadHistoryMessage();
  }

  void loadHistoryMessage() async {
    List<ChatData> list = await imController.fishpi.chat.list();
    chatList.value = list;
    chatList.refresh();
    imController.fishpi.chatroom.more(1).then((value) {
      print("loadHistory:${value.length}条");
      value = value.reversed.toList();
      chatRoomMsg.addAll(value);
      chatRoomMsg.refresh();
      chatRoomLastMsg.value = value.last;
      chatRoomLastMsg.refresh();
      initChat();
    });
  }

  void initChat() {
    imController.fishpi.chatroom.addListener((ChatRoomData data) {
      switch (data.type) {
        case ChatRoomMessageType.msg:
          chatRoomLastMsg.value = data.msg!;
          chatRoomMsg.add(data.msg!);
          break;
        case ChatRoomMessageType.redPacket:
          chatRoomLastMsg.value = data.msg!;
          chatRoomMsg.add(data.msg!);
          break;
      }
      chatRoomLastMsg.refresh();
      chatRoomMsg.refresh();
    });

    imController.fishpi.chat.addListener(
      chatMsgListen,
    );
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
    print("chatMsgListen:$type");
    if (type != ChatMsgType.data) return;
    print("chatMsgListen:${data!.fromId}");
    for (var i = 0; i < chatList.length; i++) {
      if (chatList[i].fromId == data.fromId) {
        chatList.removeAt(i);
      }
    }
    chatList.insert(0, data);
    chatList.refresh();
  }
}
