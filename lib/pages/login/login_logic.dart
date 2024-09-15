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

  @override
  void onInit() {
    super.onInit();
  }

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

  Future<String> login({void Function()? mfaCb}) async {
    LoginData loginData = LoginData(
      username: userName.value,
      passwd: pwd.value,
      mfaCode: mfaCode.value,
    );
    print(loginData);
    return imController.login(
      loginData,
      mfaCb: mfaCb,
      mfaCode: mfaCode.value,
    );
  }
}
