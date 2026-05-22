import 'package:get/get.dart';
import 'complaint_logic.dart';

class ComplaintBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ComplaintLogic());
  }
}
