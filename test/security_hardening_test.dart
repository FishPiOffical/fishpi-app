import 'package:fishpi/fishpi.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('登录和注册信息字符串不会暴露敏感字段', () {
    final loginText = LoginData(
      username: 'fishpi',
      passwd: 'Secret123',
      mfaCode: '123456',
    ).toString();
    final preRegisterText = PreRegisterInfo(
      username: 'fishpi',
      phone: '13800138000',
      captcha: 'ABCD',
    ).toString();
    final registerText = RegisterInfo(
      passwd: 'Secret123',
      userId: 'u1',
    ).toString();

    expect(loginText, isNot(contains('Secret123')));
    expect(loginText, isNot(contains('123456')));
    expect(preRegisterText, isNot(contains('13800138000')));
    expect(preRegisterText, isNot(contains('ABCD')));
    expect(preRegisterText, contains('138****8000'));
    expect(registerText, isNot(contains('Secret123')));
  });
}
