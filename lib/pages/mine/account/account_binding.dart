import 'package:get/get.dart';
import 'account_logic.dart';

class AccountBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AccountLogic());
  }
}
