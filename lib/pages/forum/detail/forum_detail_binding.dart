import 'package:get/get.dart';
import 'forum_detail_logic.dart';

class ForumDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.create(() => ForumDetailLogic());
    Get.lazyPut(() => ForumDetailLogic());
  }
}
