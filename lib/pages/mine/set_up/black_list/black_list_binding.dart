import 'package:get/get.dart';
import 'black_list_logic.dart';

class BlackListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BlackListLogic());
  }
}
