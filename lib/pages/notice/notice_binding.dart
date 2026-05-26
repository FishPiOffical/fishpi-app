import 'package:get/get.dart';

import 'notice_logic.dart';

class NoticeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => NoticeLogic());
  }
}
