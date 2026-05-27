import 'package:fishpi_app/widgets/pi_title_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('返回标题栏支持可选右侧更多按钮', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 812),
        builder: (context, _) => MaterialApp(
          home: Scaffold(
            appBar: PiTitleBar.back(
              title: '聊天室',
              rightWidget: const Icon(
                Icons.more_horiz,
                key: ValueKey('chat_room_more_button'),
              ),
              onRightTap: () => tapped = true,
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('chat_room_more_button')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('chat_room_more_button')));
    expect(tapped, isTrue);
  });

  testWidgets('返回标题栏未传右侧按钮时保持空占位', (tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 812),
        builder: (context, _) => MaterialApp(
          home: Scaffold(
            appBar: PiTitleBar.back(title: '私聊'),
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('chat_room_more_button')), findsNothing);
    expect(find.text('私聊'), findsOneWidget);
  });

  testWidgets('返回标题栏支持自定义标题组件', (tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 812),
        builder: (context, _) => MaterialApp(
          home: Scaffold(
            appBar: PiTitleBar.back(
              title: '备用标题',
              titleWidget: const Text(
                'VIP标题',
                key: ValueKey('custom_title_widget'),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('custom_title_widget')), findsOneWidget);
    expect(find.text('备用标题'), findsNothing);
  });

  testWidgets('首页标题栏帖子显示发帖入口，其他主页面显示通知入口', (tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 812),
        builder: (context, _) => MaterialApp(
          home: Scaffold(
            appBar: PiTitleBar.home(title: '帖子'),
          ),
        ),
      ),
    );

    expect(
        find.byKey(const ValueKey('home_forum_create_button')), findsOneWidget);
    expect(find.byKey(const ValueKey('home_notice_button')), findsNothing);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 812),
        builder: (context, _) => MaterialApp(
          home: Scaffold(
            appBar: PiTitleBar.home(title: '聊天'),
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('home_notice_button')), findsOneWidget);
    expect(
        find.byKey(const ValueKey('home_forum_create_button')), findsNothing);
  });
}
