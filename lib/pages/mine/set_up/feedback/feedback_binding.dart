import 'package:get/get.dart';
import 'feedback_logic.dart';

class FeedbackBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FeedbackLogic());
  }
}
