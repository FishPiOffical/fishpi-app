import 'package:get/get.dart';
import 'forum_logic.dart';

class ForumBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ForumLogic());
  }
}
