import 'package:get/get.dart';

import 'change_password_logic.dart';

class ChangePasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ChangePasswordLogic());
  }
}
