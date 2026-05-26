import 'dart:io';

import 'package:fishpi/types/redpacket.dart';
import 'package:fishpi_app/core/sql/chat_room_auto_grab_settings.dart';
import 'package:fishpi_app/core/sql/chat_room_block_list.dart';
import 'package:fishpi_app/core/sql/user_remark.dart';
import 'package:fishpi_app/pages/chat/chat_room_settings/chat_room_settings_logic.dart';
import 'package:fishpi_app/pages/chat/chat_room_settings/chat_room_settings_view.dart';
import 'package:fishpi_app/widgets/pi_title_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('chat_room_settings_test_');
    Hive.init(tempDir.path);
  });

  setUp(() async {
    Get.testMode = true;
    await ChatRoomAutoGrabSettings.init();
    await ChatRoomAutoGrabSettings.saveConfig(
      ChatRoomAutoGrabConfig.defaults(),
    );
    await ChatRoomBlockList.init();
    await ChatRoomBlockList.clear();
    await UserRemark.init();
    await UserRemark.clear();
  });

  tearDown(() async {
    if (Get.isRegistered<ChatRoomSettingsLogic>()) {
      await Get.delete<ChatRoomSettingsLogic>(force: true);
    }
    Get.reset();
  });

  tearDownAll(() async {
    await ChatRoomAutoGrabSettings.dispose();
    await ChatRoomBlockList.dispose();
    await UserRemark.dispose();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  testWidgets('聊天室设置页可正常渲染标题、自动抢红包和屏蔽空状态', (tester) async {
    Get.put(ChatRoomSettingsLogic(autoLoad: false));

    await tester.pumpWidget(_wrap(const ChatRoomSettingsPage()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(PiTitleBar), findsOneWidget);
    expect(find.text('聊天室设置'), findsOneWidget);
    expect(find.byKey(const ValueKey('chat_room_auto_grab_section')),
        findsOneWidget);
    expect(find.byKey(const ValueKey('auto_grab_switch')), findsOneWidget);
    expect(find.text('3 秒'), findsOneWidget);
    expect(find.text('暂无屏蔽用户'), findsOneWidget);
    expect(find.byKey(const ValueKey('chat_room_manual_add_button')),
        findsOneWidget);
  });

  testWidgets('聊天室屏蔽页能展示已屏蔽用户和移出按钮', (tester) async {
    final logic = Get.put(ChatRoomSettingsLogic(autoLoad: false));

    await tester.pumpWidget(_wrap(const ChatRoomSettingsPage()));
    await tester.pump();
    logic.blockedUsers.assignAll([
      ChatRoomBlockedUser(
        oId: '100',
        userName: 'blocked-user',
        avatarURL: '',
      ),
    ]);
    await tester.pump();

    expect(find.text('blocked-user'), findsOneWidget);
    expect(find.text('移出'), findsOneWidget);
  });

  testWidgets('选择猜拳红包后显示手势选择', (tester) async {
    final logic = Get.put(ChatRoomSettingsLogic(autoLoad: false));
    logic.autoGrabConfig.value = ChatRoomAutoGrabConfig.defaults().copyWith(
      enabledTypes: [
        ...ChatRoomAutoGrabConfig.defaults().enabledTypes,
        RedPacketType.RockPaperScissors,
      ],
    );

    await tester.pumpWidget(_wrap(const ChatRoomSettingsPage()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('猜拳手势'), findsOneWidget);
    expect(find.text('石头'), findsOneWidget);
    expect(find.text('剪刀'), findsOneWidget);
    expect(find.text('布'), findsOneWidget);
  });
}

Widget _wrap(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(360, 812),
    builder: (context, _) => GetMaterialApp(home: child),
  );
}
