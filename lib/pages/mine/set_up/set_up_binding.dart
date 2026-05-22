import 'package:get/get.dart';
import 'set_up_logic.dart';

class SetUpBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SetUpLogic());
  }
}
