import 'package:fishpi/fishpi.dart';
import 'package:fishpi_app/core/controller/im.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class LoginLogic extends GetxController {
  final imController = Get.find<IMController>();
  TextEditingController userNameController = TextEditingController();
  TextEditingController pwdController = TextEditingController();
  final TextEditingController pinEditingController = TextEditingController();
  final userName = "".obs;
  final pwd = "".obs;
  final mfaCode = "".obs;
  final isLoggingIn = false.obs;
  final isSubmittingMfa = false.obs;
  final showPassword = false.obs;

  /// 用户名输入框输入
  void onUserNameChanged(value) {
    userName.value = value;
  }

  /// 密码输入框输入
  void onPwdChanged(value) {
    pwd.value = value;
  }

  /// 二步验证输入
  void onPinChange(value) {
    mfaCode.value = value;
  }

  void togglePasswordVisible() {
    showPassword.value = !showPassword.value;
  }

  Future<String> login({
    void Function()? mfaCb,
    bool submittingMfa = false,
  }) async {
    if (isLoggingIn.value || isSubmittingMfa.value) {
      return Future.error('正在登录，请稍候');
    }

    LoginData loginData = LoginData(
      username: userName.value,
      passwd: pwd.value,
      mfaCode: mfaCode.value,
    );
    if (submittingMfa) {
      isSubmittingMfa.value = true;
    } else {
      isLoggingIn.value = true;
    }
    try {
      return await imController.login(
        loginData,
        mfaCb: mfaCb,
        mfaCode: mfaCode.value,
      );
    } finally {
      if (submittingMfa) {
        isSubmittingMfa.value = false;
      } else {
        isLoggingIn.value = false;
      }
    }
  }

  @override
  void onClose() {
    userNameController.dispose();
    pwdController.dispose();
    pinEditingController.dispose();
    super.onClose();
  }
}
