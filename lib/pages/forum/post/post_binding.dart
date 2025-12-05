
import 'package:get/get.dart';
import 'post_logic.dart';
class PostBinding  extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PostLogic());
  }
}
