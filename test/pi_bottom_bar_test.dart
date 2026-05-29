import 'package:fishpi_app/widgets/pi_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.window.physicalSizeTestValue = const Size(360, 812);
    binding.window.devicePixelRatioTestValue = 1;
  });

  tearDown(() {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.window.clearPhysicalSizeTestValue();
    binding.window.clearDevicePixelRatioTestValue();
  });

  testWidgets('聊天 Tab 显示私信未读角标', (tester) async {
    var selected = -1;

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 812),
        builder: (context, _) => MaterialApp(
          home: Scaffold(
            bottomNavigationBar: PiBottomBar(
              callback: (idx) => selected = idx,
              index: 0,
              chatUnreadCount: 3,
            ),
          ),
        ),
      ),
    );

    expect(
        find.byKey(const ValueKey('bottom_chat_unread_badge')), findsOneWidget);
    expect(find.text('3'), findsOneWidget);

    await tester.tap(find.text('聊天'));
    expect(selected, 0);
  });

  testWidgets('没有私信未读时不显示聊天角标', (tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 812),
        builder: (context, _) => MaterialApp(
          home: Scaffold(
            bottomNavigationBar: PiBottomBar(
              callback: (_) {},
              index: 0,
              chatUnreadCount: 0,
            ),
          ),
        ),
      ),
    );

    expect(
        find.byKey(const ValueKey('bottom_chat_unread_badge')), findsNothing);
  });
}
