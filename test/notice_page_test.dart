import 'package:fishpi/fishpi.dart';
import 'package:fishpi_app/pages/notice/notice_logic.dart';
import 'package:fishpi_app/pages/notice/notice_view.dart';
import 'package:fishpi_app/widgets/pi_title_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  setUp(() {
    Get.testMode = true;
  });

  tearDown(() async {
    if (Get.isRegistered<NoticeLogic>()) {
      await Get.delete<NoticeLogic>(force: true);
    }
    Get.reset();
  });

  testWidgets('通知页能渲染分类、未读状态和空态', (tester) async {
    final logic = Get.put(NoticeLogic(autoLoad: false));
    logic.noticeCount.value = NoticeCount(
      notifyStatus: true,
      count: 2,
      reply: 0,
      point: 1,
      at: 1,
      broadcast: 0,
      sysAnnounce: 0,
      newFollower: 0,
      following: 0,
      commented: 0,
    );

    await tester.pumpWidget(_wrap(const NoticePage()));
    await tester.pump();

    expect(find.byType(PiTitleBar), findsOneWidget);
    expect(find.text('通知消息'), findsOneWidget);
    expect(find.byKey(const ValueKey('notice_summary_card')), findsOneWidget);
    expect(find.text('还有 2 条未读消息'), findsOneWidget);
    expect(find.byKey(const ValueKey('notice_category_tabs')), findsOneWidget);
    expect(find.text('积分'), findsOneWidget);
    expect(find.text('@'), findsOneWidget);
    expect(find.byKey(const ValueKey('notice_empty_state')), findsOneWidget);
    expect(find.byKey(const ValueKey('notice_mark_all_read_button')),
        findsOneWidget);
  });
}

Widget _wrap(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(360, 812),
    builder: (context, _) => GetMaterialApp(home: child),
  );
}
