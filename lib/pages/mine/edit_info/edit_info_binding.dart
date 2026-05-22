import 'package:get/get.dart';
import 'edit_info_logic.dart';

class EditInfoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => EditInfoLogic());
  }
}
