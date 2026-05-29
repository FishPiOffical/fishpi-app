import 'dart:io';

import 'package:fishpi_app/core/controller/im.dart';
import 'package:fishpi_app/core/sql/user_remark.dart';
import 'package:fishpi_app/pages/breezemoons/breezemoons_logic.dart';
import 'package:fishpi_app/pages/breezemoons/breezemoons_view.dart';
import 'package:fishpi_app/pages/forum/forum_logic.dart';
import 'package:fishpi_app/pages/forum/forum_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('content_list_state_test_');
    Hive.init(tempDir.path);
    await UserRemark.init();
  });

  setUp(() {
    Get.testMode = true;
    Get.put(IMController());
  });

  tearDown(() async {
    if (Get.isRegistered<ForumLogic>()) {
      await Get.delete<ForumLogic>(force: true);
    }
    if (Get.isRegistered<BreezemoonsLogic>()) {
      await Get.delete<BreezemoonsLogic>(force: true);
    }
    if (Get.isRegistered<IMController>()) {
      await Get.delete<IMController>(force: true);
    }
    Get.reset();
  });

  tearDownAll(() async {
    await UserRemark.dispose();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  testWidgets('帖子页空列表显示统一空态和重试按钮', (tester) async {
    Get.put(ForumLogic(autoLoad: false));

    await tester.pumpWidget(_wrap(ForumPage()));
    await tester.pump();

    expect(find.byKey(const ValueKey('forum_query_header')), findsOneWidget);
    expect(find.text('最新回复'), findsOneWidget);
    expect(find.text('最新发布'), findsOneWidget);
    expect(find.text('热门'), findsOneWidget);
    expect(find.text('精华'), findsOneWidget);
    expect(find.byKey(const ValueKey('forum_list_state')), findsOneWidget);
    expect(find.text('暂无帖子'), findsOneWidget);
    expect(
        find.byKey(const ValueKey('forum_list_retry_button')), findsOneWidget);
  });

  testWidgets('帖子页搜索入口可以展开并显示搜索框', (tester) async {
    Get.put(ForumLogic(autoLoad: false));

    await tester.pumpWidget(_wrap(ForumPage()));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('forum_search_toggle')));
    await tester.pump();

    expect(find.byKey(const ValueKey('forum_search_input')), findsOneWidget);
    expect(find.text('搜索标签/关键词'), findsOneWidget);
    expect(find.byKey(const ValueKey('forum_search_submit')), findsOneWidget);
  });

  testWidgets('帖子页首次加载失败显示错误空态', (tester) async {
    final logic = Get.put(ForumLogic(autoLoad: false));
    logic.errorText.value = '网络连接失败，请检查网络后重试';

    await tester.pumpWidget(_wrap(ForumPage()));
    await tester.pump();

    expect(find.text('帖子加载失败'), findsOneWidget);
    expect(find.text('网络连接失败，请检查网络后重试'), findsOneWidget);
  });

  testWidgets('清风明月页空列表保留发布框并显示统一空态', (tester) async {
    Get.put(BreezemoonsLogic(autoLoad: false));

    await tester.pumpWidget(_wrap(BreezemoonsPage()));
    await tester.pump();

    expect(find.text('随便说说...'), findsOneWidget);
    expect(
        find.byKey(const ValueKey('breezemoon_send_button')), findsOneWidget);
    expect(find.text('0/280'), findsOneWidget);
    expect(find.byKey(const ValueKey('breezemoon_list_state')), findsOneWidget);
    expect(find.text('暂无清风明月'), findsOneWidget);
  });

  testWidgets('清风明月页刷新组件直接持有可滚动列表', (tester) async {
    Get.put(BreezemoonsLogic(autoLoad: false));

    await tester.pumpWidget(_wrap(BreezemoonsPage()));
    await tester.pump();

    final refresher = tester.widget<SmartRefresher>(
      find.byType(SmartRefresher),
    );
    expect(refresher.child, isA<ListView>());

    final listView = refresher.child as ListView;
    expect(listView.key, const ValueKey('breezemoon_scroll_list'));
    expect(listView.shrinkWrap, isFalse);
    expect(listView.physics, isA<AlwaysScrollableScrollPhysics>());
  });

  testWidgets('清风明月发布框输入后更新字数提示', (tester) async {
    Get.put(BreezemoonsLogic(autoLoad: false));

    await tester.pumpWidget(_wrap(BreezemoonsPage()));
    await tester.pump();

    await tester.enterText(
      find.byKey(const ValueKey('breezemoon_publish_input')),
      'abc',
    );
    await tester.pump();

    expect(find.text('3/280'), findsOneWidget);
  });

  testWidgets('清风明月发布框超长时显示错误提示', (tester) async {
    Get.put(BreezemoonsLogic(autoLoad: false));

    await tester.pumpWidget(_wrap(BreezemoonsPage()));
    await tester.pump();

    await tester.enterText(
      find.byKey(const ValueKey('breezemoon_publish_input')),
      'a' * (BreezemoonsLogic.maxContentLength + 1),
    );
    await tester.pump();

    expect(find.text('281/280'), findsOneWidget);
    expect(find.text('内容超过 280 字，请精简后再发布'), findsOneWidget);
  });

  testWidgets('清风明月发布中时展示发送中状态', (tester) async {
    final logic = Get.put(BreezemoonsLogic(autoLoad: false));
    logic.onInputChanged('今天也要好好摸鱼');
    logic.textEditingController.text = logic.breezemoons.value;
    logic.isSending.value = true;

    await tester.pumpWidget(_wrap(BreezemoonsPage()));
    await tester.pump();

    expect(find.text('发送中'), findsOneWidget);
  });

  test('清风明月发布内容校验覆盖空内容和超长内容', () {
    final logic = Get.put(BreezemoonsLogic(autoLoad: false));

    expect(logic.validateContent('   '), '先写点内容再发布');
    expect(
      logic.validateContent('a' * (BreezemoonsLogic.maxContentLength + 1)),
      '内容超过 280 字，请精简后再发布',
    );
    expect(logic.validateContent('今天摸鱼成功'), isNull);
  });
}

Widget _wrap(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(360, 812),
    builder: (context, _) => GetMaterialApp(home: child),
  );
}
