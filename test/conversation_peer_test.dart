import 'package:fishpi/types/chat.dart';
import 'package:fishpi/types/user.dart';
import 'package:fishpi_app/core/controller/im.dart';
import 'package:fishpi_app/pages/conversation/conversation_logic.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  setUp(() {
    Get.testMode = true;
    Get.put(IMController());
  });

  tearDown(Get.reset);

  test('私聊会话中当前用户是接收者时跳转发送者', () {
    final logic = ConversationLogic();
    logic.currentUser.value = UserInfo(oId: '1', userName: 'me');
    final chat = _chatData(
      fromId: '2',
      toId: '1',
      senderUserName: 'other',
      receiverUserName: 'me',
      senderAvatar: 'other.png',
      receiverAvatar: 'me.png',
    );

    expect(logic.privatePeerName(chat), 'other');
    expect(logic.privatePeerId(chat), '2');
    expect(logic.privatePeerAvatar(chat), 'other.png');
  });

  test('私聊会话中当前用户是发送者时跳转接收者', () {
    final logic = ConversationLogic();
    logic.currentUser.value = UserInfo(oId: '1', userName: 'me');
    final chat = _chatData(
      fromId: '1',
      toId: '2',
      senderUserName: 'me',
      receiverUserName: 'other',
      senderAvatar: 'me.png',
      receiverAvatar: 'other.png',
    );

    expect(logic.privatePeerName(chat), 'other');
    expect(logic.privatePeerId(chat), '2');
    expect(logic.privatePeerAvatar(chat), 'other.png');
  });
}

ChatData _chatData({
  required String fromId,
  required String toId,
  required String senderUserName,
  required String receiverUserName,
  required String senderAvatar,
  required String receiverAvatar,
}) {
  return ChatData(
    toId: toId,
    preview: '你好',
    userSession: '',
    senderAvatar: senderAvatar,
    markdown: '你好',
    receiverAvatar: receiverAvatar,
    oId: 'msg-1',
    time: '2026-05-26T00:00:00.000Z',
    fromId: fromId,
    senderUserName: senderUserName,
    content: '<p>你好</p>',
    receiverUserName: receiverUserName,
  );
}
