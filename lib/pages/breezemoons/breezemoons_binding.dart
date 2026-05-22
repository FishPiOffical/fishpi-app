import 'package:get/get.dart';
import 'breezemoons_logic.dart';

class BreezemoonsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BreezemoonsLogic());
  }
}
