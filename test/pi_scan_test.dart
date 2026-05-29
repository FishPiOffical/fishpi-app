import 'package:fishpi_app/core/controller/im.dart';
import 'package:fishpi_app/widgets/pi_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  setUp(() {
    Get.testMode = true;
  });

  tearDown(() async {
    if (Get.isRegistered<IMController>()) {
      await Get.delete<IMController>(force: true);
    }
    Get.reset();
  });

  testWidgets('扫码页显示返回按钮，点击后关闭页面', (tester) async {
    await tester.pumpWidget(_wrap(const SizedBox()));
    Get.to(
      () => PiScan(
        scanViewBuilder: (_, __) => const SizedBox(
          key: ValueKey('fake_scan_view'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('fake_scan_view')), findsOneWidget);
    expect(find.byKey(const ValueKey('scan_back_button')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('scan_back_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('scan_back_button')), findsNothing);
  });

  testWidgets('扫码结果回调只处理一次', (tester) async {
    Get.put(IMController());

    await tester.pumpWidget(
      _wrap(
        PiScan(
          scanViewBuilder: (_, onCapture) => Center(
            child: GestureDetector(
              key: const ValueKey('fake_capture_button'),
              onTap: () {
                onCapture('first-result');
                onCapture('second-result');
              },
              child: const Text('模拟扫码'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('fake_capture_button')));
    await tester.pumpAndSettle();

    expect(find.text('first-result'), findsOneWidget);
    expect(find.text('second-result'), findsNothing);
  });
}

Widget _wrap(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(360, 812),
    builder: (context, _) => GetMaterialApp(home: child),
  );
}
