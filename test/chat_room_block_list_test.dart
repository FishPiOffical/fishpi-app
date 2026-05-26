import 'dart:io';

import 'package:fishpi_app/core/sql/black_list.dart';
import 'package:fishpi_app/core/sql/chat_room_block_list.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('chat_room_block_test_');
    Hive.init(tempDir.path);
  });

  setUp(() async {
    await ChatRoomBlockList.init();
    await ChatRoomBlockList.clear();
    await BlackList.init();
    await BlackList.clear();
  });

  tearDownAll(() async {
    await ChatRoomBlockList.dispose();
    await BlackList.dispose();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('聊天室屏蔽按 oId 命中用户', () async {
    await ChatRoomBlockList.addUser(
      ChatRoomBlockedUser(oId: '100', userName: 'other-name'),
    );

    final blockedUsers = await ChatRoomBlockList.getAllUser();

    expect(
      ChatRoomBlockList.isBlockedUser(
        blockedUsers,
        oId: '100',
        userName: 'visible-name',
      ),
      isTrue,
    );
  });

  test('聊天室屏蔽在没有 oId 时按用户名兜底', () async {
    await ChatRoomBlockList.addUser(
      ChatRoomBlockedUser(userName: 'blocked-user'),
    );

    final blockedUsers = await ChatRoomBlockList.getAllUser();

    expect(
      ChatRoomBlockList.isBlockedUser(
        blockedUsers,
        userName: 'blocked-user',
      ),
      isTrue,
    );
  });

  test('聊天室屏蔽与全局黑名单互不写入', () async {
    await ChatRoomBlockList.addUser(
      ChatRoomBlockedUser(oId: 'room-user', userName: 'room'),
    );
    await BlackList.addUser(
      BlackUser(oId: 'black-user', userName: 'black'),
    );

    final roomBlockedUsers = await ChatRoomBlockList.getAllUser();
    final blackUsers = await BlackList.getAllUser();

    expect(roomBlockedUsers.map((item) => item.oId), ['room-user']);
    expect(blackUsers.map((item) => item.oId), ['black-user']);
  });
}
