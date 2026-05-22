import 'package:get/get.dart';
import 'user_panel_logic.dart';

class UserPanelBinding extends Bindings {
  @override
  void dependencies() {
    Get.create(() => UserPanelLogic());
    Get.lazyPut(() => UserPanelLogic());
  }
}
