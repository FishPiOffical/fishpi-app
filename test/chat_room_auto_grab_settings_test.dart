import 'dart:io';

import 'package:fishpi/types/redpacket.dart';
import 'package:fishpi_app/core/sql/chat_room_auto_grab_settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('auto_grab_settings_test_');
    Hive.init(tempDir.path);
  });

  setUp(() async {
    await ChatRoomAutoGrabSettings.init();
    await ChatRoomAutoGrabSettings.saveConfig(
      ChatRoomAutoGrabConfig.defaults(),
    );
  });

  tearDownAll(() async {
    await ChatRoomAutoGrabSettings.dispose();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('自动抢红包配置会校验延迟、类型和猜拳手势', () {
    expect(
      ChatRoomAutoGrabSettings.validate(
        ChatRoomAutoGrabConfig.defaults().copyWith(
          enabled: true,
          delaySeconds: 2,
        ),
      ),
      '自动抢红包延迟不能少于 3 秒',
    );

    expect(
      ChatRoomAutoGrabSettings.validate(
        ChatRoomAutoGrabConfig.defaults().copyWith(
          enabled: true,
          enabledTypes: const [],
        ),
      ),
      '请至少选择一种红包类型',
    );

    expect(
      ChatRoomAutoGrabSettings.validate(
        const ChatRoomAutoGrabConfig(
          enabled: true,
          delaySeconds: 3,
          enabledTypes: [RedPacketType.RockPaperScissors],
          totalPoint: 0,
          successCount: 0,
        ),
      ),
      '抢猜拳红包需要先选择出拳',
    );

    expect(
      ChatRoomAutoGrabSettings.validate(
        ChatRoomAutoGrabConfig.defaults().copyWith(enabled: true),
      ),
      isNull,
    );
  });

  test('自动抢红包配置会持久化并累计统计', () async {
    final config = ChatRoomAutoGrabConfig.defaults().copyWith(
      enabled: true,
      delaySeconds: 5,
      enabledTypes: const [RedPacketType.Random],
    );

    expect(await ChatRoomAutoGrabSettings.saveConfig(config), isNull);
    var saved = await ChatRoomAutoGrabSettings.getConfig();
    expect(saved.enabled, isTrue);
    expect(saved.delaySeconds, 5);
    expect(saved.enabledTypes, [RedPacketType.Random]);

    await ChatRoomAutoGrabSettings.recordSuccess(8);
    saved = await ChatRoomAutoGrabSettings.getConfig();
    expect(saved.totalPoint, 8);
    expect(saved.successCount, 1);

    await ChatRoomAutoGrabSettings.resetStats();
    saved = await ChatRoomAutoGrabSettings.getConfig();
    expect(saved.totalPoint, 0);
    expect(saved.successCount, 0);
  });
}
