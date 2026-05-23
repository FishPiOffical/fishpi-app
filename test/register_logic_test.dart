import 'package:fishpi_app/core/controller/im.dart';
import 'package:fishpi_app/pages/register/register_logic.dart';
import 'package:fishpi_app/pages/register/register_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  group('注册表单校验', () {
    test('用户名为空时提示输入用户名', () {
      final result = RegisterLogic.validatePreRegister(
        userName: '',
        phone: '13800138000',
        captcha: 'abcd',
      );

      expect(result, '请输入用户名');
    });

    test('手机号格式错误时提示输入正确手机号', () {
      final result = RegisterLogic.validatePreRegister(
        userName: 'fishpi',
        phone: '123',
        captcha: 'abcd',
      );

      expect(result, '请输入正确的手机号');
    });

    test('图形验证码为空时提示输入图形验证码', () {
      final result = RegisterLogic.validatePreRegister(
        userName: 'fishpi',
        phone: '13800138000',
        captcha: '',
      );

      expect(result, '请输入图形验证码');
    });

    test('手机验证码为空或格式错误时提示对应错误', () {
      expect(RegisterLogic.validateSmsCode(''), '请输入手机验证码');
      expect(RegisterLogic.validateSmsCode('123'), '请输入 6 位手机验证码');
    });

    test('密码为空或两次密码不一致时提示对应错误', () {
      expect(
        RegisterLogic.validatePassword(password: '', confirmPassword: ''),
        '请输入密码',
      );
      expect(
        RegisterLogic.validatePassword(
          password: '123456',
          confirmPassword: '654321',
        ),
        '两次输入的密码不一致',
      );
    });

    test('合法注册输入通过校验', () {
      expect(
        RegisterLogic.validatePreRegister(
          userName: 'fishpi',
          phone: '13800138000',
          captcha: 'abcd',
        ),
        isNull,
      );
      expect(RegisterLogic.validateSmsCode('123456'), isNull);
      expect(
        RegisterLogic.validatePassword(
          password: '123456',
          confirmPassword: '123456',
        ),
        isNull,
      );
    });
  });

  testWidgets('注册页初始状态渲染账号表单和验证码区域', (tester) async {
    Get.testMode = true;
    Get.put(IMController());
    Get.put(RegisterLogic());

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 812),
        builder: (context, _) => GetMaterialApp(home: RegisterPage()),
      ),
    );
    await tester.pump();

    expect(find.text('注册'), findsOneWidget);
    expect(
        find.byKey(const ValueKey('register_username_input')), findsOneWidget);
    expect(find.byKey(const ValueKey('register_phone_input')), findsOneWidget);
    expect(
        find.byKey(const ValueKey('register_captcha_image')), findsOneWidget);
    expect(find.text('下一步'), findsOneWidget);

    Get.reset();
  });
}
