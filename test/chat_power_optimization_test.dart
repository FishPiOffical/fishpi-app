import 'dart:io';

import 'package:fishpi/types/chatroom.dart';
import 'package:fishpi/types/redpacket.dart';
import 'package:fishpi_app/core/controller/im.dart';
import 'package:fishpi_app/core/sql/chat_emoji_cache.dart';
import 'package:fishpi_app/core/sql/user_remark.dart';
import 'package:fishpi_app/pages/chat/chat_logic.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('chat_power_test_');
    Hive.init(tempDir.path);
  });

  setUp(() async {
    Get.testMode = true;
    Get.put(IMController());
    await ChatEmojiCache.init();
    await ChatEmojiCache.clear();
    await UserRemark.init();
    await UserRemark.clear();
  });

  tearDown(() async {
    await ChatEmojiCache.dispose();
    await UserRemark.dispose();
    if (Get.isRegistered<IMController>()) {
      await Get.delete<IMController>(force: true);
    }
    Get.reset();
  });

  tearDownAll(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('展示分组会在消息替换和红包状态更新后同步', () {
    final logic = ChatLogic();
    logic.isGroup.value = true;

    logic.debugReplaceMessagesForTest([
      ChatRoomMessage(oId: '1', userName: 'alice', content: '<p>同意</p>'),
      ChatRoomMessage(oId: '2', userName: 'bob', content: '<p>同意</p>'),
      ChatRoomMessage(
        oId: 'rp',
        userName: 'carol',
        redpacket: RedPacketMessage(
          type: RedPacketType.Random,
          count: 2,
          got: 0,
          msg: '好运来',
        ),
      ),
    ]);

    expect(logic.messageList, hasLength(3));
    expect(logic.displayGroups, hasLength(2));
    expect(logic.displayGroups.first.repeaters, hasLength(1));

    logic.debugUpdateRedPacketStatusForTest(
      RedPacketStatusMsg(oId: 'rp', count: 2, got: 1),
    );

    expect(logic.displayGroups, hasLength(2));
    expect(logic.displayGroups.last.message.redpacket?.got, 1);
  });

  test('连续滚动到底部只保留最后一个待执行任务', () {
    final logic = ChatLogic();
    logic.isClose.value = false;

    logic.scrollToBottom(delay: 1000);
    final firstTimer = logic.debugScrollToBottomTimer;
    logic.scrollToBottom(delay: 1000);
    final secondTimer = logic.debugScrollToBottomTimer;

    expect(firstTimer, isNotNull);
    expect(secondTimer, isNotNull);
    expect(identical(firstTimer, secondTimer), isFalse);
    expect(firstTimer?.isActive, isFalse);
    expect(secondTimer?.isActive, isTrue);

    secondTimer?.cancel();
  });

  test('进入聊天室只读 DIY 表情缓存，打开面板后才远端刷新且只刷新一次', () async {
    var remoteRequestCount = 0;
    await ChatEmojiCache.saveDiyEmojis(['https://example.com/cached.png']);

    final logic = ChatLogic(
      diyEmojiRemoteLoader: () async {
        remoteRequestCount++;
        return ['https://example.com/remote.png'];
      },
    );

    await logic.loadEmojis();

    expect(logic.diyEmojiList, ['https://example.com/cached.png']);
    expect(remoteRequestCount, 0);

    await logic.ensureDiyEmojiRemoteLoaded();
    await logic.ensureDiyEmojiRemoteLoaded();

    expect(remoteRequestCount, 1);
    expect(logic.diyEmojiList, ['https://example.com/remote.png']);
  });

  test('聊天用户显示名优先备注、昵称，最后回退用户名', () async {
    final logic = ChatLogic();
    final message = ChatRoomMessage(
      userName: 'fishpi',
      nickname: '鱼排',
    );

    expect(logic.chatUserFallbackNameFor(message), '鱼排');
    expect(logic.chatUserDisplayNameFor(message), '鱼排');

    await UserRemark.setRemark(userName: 'fishpi', remark: '摸鱼搭子');
    expect(logic.chatUserDisplayNameFor(message), '摸鱼搭子');

    expect(
      logic.chatUserDisplayNameFor(ChatRoomMessage(userName: 'no_nickname')),
      'no_nickname',
    );
  });
}
