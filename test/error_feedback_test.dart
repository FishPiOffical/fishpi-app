import 'dart:io';

import 'package:fishpi_app/core/controller/im.dart';
import 'package:fishpi_app/core/network/app_error_message.dart';
import 'package:fishpi_app/pages/conversation/conversation_logic.dart';
import 'package:fishpi_app/pages/conversation/conversation_view.dart';
import 'package:fishpi_app/pages/mine/mine_logic.dart';
import 'package:fishpi_app/pages/mine/mine_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  setUp(() {
    Get.testMode = true;
    Get.put(IMController());
  });

  tearDown(() async {
    if (Get.isRegistered<ConversationLogic>()) {
      await Get.delete<ConversationLogic>(force: true);
    }
    if (Get.isRegistered<MineLogic>()) {
      await Get.delete<MineLogic>(force: true);
    }
    if (Get.isRegistered<IMController>()) {
      await Get.delete<IMController>(force: true);
    }
    Get.reset();
  });

  test('SocketException 会转为统一网络失败文案', () {
    expect(
      AppErrorMessage.friendly(
        const SocketException('Failed host lookup'),
        fallback: '加载失败',
      ),
      '网络连接失败，请检查网络后重试',
    );
  });

  testWidgets('会话页加载失败时显示可重试提示并保留聊天室入口', (tester) async {
    final logic = Get.put(ConversationLogic(autoLoad: false));
    logic.errorText.value = '网络连接失败，请检查网络后重试';

    await tester.pumpWidget(_wrap(ConversationPage()));
    await tester.pump();

    expect(find.text('聊天室'), findsOneWidget);
    expect(find.byKey(const ValueKey('conversation_error_banner')),
        findsOneWidget);
    expect(find.text('网络连接失败，请检查网络后重试'), findsOneWidget);
    expect(find.byKey(const ValueKey('conversation_retry_button')),
        findsOneWidget);
  });

  testWidgets('我的页加载失败时显示可重试提示', (tester) async {
    final logic = Get.put(MineLogic(autoLoad: false));
    logic.errorText.value = '网络连接超时，请检查网络后重试';

    await tester.pumpWidget(_wrap(MinePage()));
    await tester.pump();

    expect(find.byKey(const ValueKey('mine_error_banner')), findsOneWidget);
    expect(find.text('网络连接超时，请检查网络后重试'), findsOneWidget);
    expect(find.byKey(const ValueKey('mine_retry_button')), findsOneWidget);
  });
}

Widget _wrap(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(360, 812),
    builder: (context, _) => GetMaterialApp(home: child),
  );
}
