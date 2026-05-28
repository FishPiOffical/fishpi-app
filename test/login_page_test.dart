import 'package:fishpi_app/core/controller/im.dart';
import 'package:fishpi_app/pages/login/login_logic.dart';
import 'package:fishpi_app/pages/login/login_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  setUp(() {
    Get.testMode = true;
    Get.put(IMController());
    Get.put(LoginLogic());
  });

  tearDown(() async {
    if (Get.isRegistered<LoginLogic>()) {
      await Get.delete<LoginLogic>(force: true);
    }
    if (Get.isRegistered<IMController>()) {
      await Get.delete<IMController>(force: true);
    }
    Get.reset();
  });

  testWidgets('登录页提供密码显隐、忘记密码和提交状态入口', (tester) async {
    await tester.pumpWidget(_wrap(LoginPage()));
    await tester.pump();

    expect(find.byKey(const ValueKey('login_submit_button')), findsOneWidget);
    expect(find.byKey(const ValueKey('login_forgot_password_button')),
        findsOneWidget);
    expect(find.byKey(const ValueKey('login_password_visibility_button')),
        findsOneWidget);
    expect(_passwordField(tester).obscureText, isTrue);

    await tester.tap(
      find.byKey(const ValueKey('login_password_visibility_button')),
    );
    await tester.pump();

    expect(_passwordField(tester).obscureText, isFalse);
  });
}

Widget _wrap(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(360, 812),
    builder: (context, _) => GetMaterialApp(home: child),
  );
}

TextField _passwordField(WidgetTester tester) {
  return tester.widgetList<TextField>(find.byType(TextField)).last;
}
