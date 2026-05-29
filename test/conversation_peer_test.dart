import 'dart:io';

import 'package:fishpi/types/chat.dart';
import 'package:fishpi/types/user.dart';
import 'package:fishpi_app/core/controller/im.dart';
import 'package:fishpi_app/core/sql/user_remark.dart';
import 'package:fishpi_app/pages/conversation/conversation_logic.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('conversation_peer_test_');
    Hive.init(tempDir.path);
  });

  setUp(() async {
    Get.testMode = true;
    Get.put(IMController());
    await UserRemark.init();
    await UserRemark.clear();
  });

  tearDown(() async {
    await UserRemark.dispose();
    Get.reset();
  });

  tearDownAll(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('私聊数据会解析发送者和接收者昵称字段', () {
    final chat = ChatData.from({
      'fromId': '2',
      'toId': '1',
      'senderUserName': 'other',
      'senderUserNickname': '小鱼',
      'receiverUserName': 'me',
      'receiverUserNickname': '我',
    });

    expect(chat.senderNickname, '小鱼');
    expect(chat.receiverNickname, '我');
  });

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

  test('私聊会话显示名优先备注、昵称，最后回退用户名', () async {
    final logic = ConversationLogic();
    logic.currentUser.value = UserInfo(oId: '1', userName: 'me');
    final chat = _chatData(
      fromId: '2',
      toId: '1',
      senderUserName: 'other',
      senderNickname: '小鱼',
      receiverUserName: 'me',
      senderAvatar: 'other.png',
      receiverAvatar: 'me.png',
    );

    expect(logic.privatePeerFallbackName(chat), '小鱼');
    expect(logic.privatePeerDisplayName(chat), '小鱼');

    await UserRemark.setRemark(userName: 'other', remark: '摸鱼搭子');
    expect(logic.privatePeerDisplayName(chat), '摸鱼搭子');

    final noNicknameChat = _chatData(
      fromId: '2',
      toId: '1',
      senderUserName: 'other',
      receiverUserName: 'me',
      senderAvatar: 'other.png',
      receiverAvatar: 'me.png',
    );
    expect(
      logic.privatePeerFallbackName(noNicknameChat, loadIfMissing: false),
      'other',
    );
  });

  test('私信未读只按私聊用户统计，进入会话后清除', () {
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

    logic.markPrivateUnreadForUser('other');
    logic.markPrivateUnreadForUser('other');
    logic.markPrivateUnreadForUser('friend');

    expect(logic.privateUnreadCount, 2);

    logic.markPrivateConversationSeen(chat);

    expect(logic.privateUnreadCount, 1);
    expect(logic.privateUnreadUsers.contains('friend'), isTrue);
  });
}

ChatData _chatData({
  required String fromId,
  required String toId,
  required String senderUserName,
  String senderNickname = '',
  required String receiverUserName,
  String receiverNickname = '',
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
    senderNickname: senderNickname,
    content: '<p>你好</p>',
    receiverUserName: receiverUserName,
    receiverNickname: receiverNickname,
  );
}
