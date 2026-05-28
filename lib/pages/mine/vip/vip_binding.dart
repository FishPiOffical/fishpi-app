import 'package:get/get.dart';

import 'vip_logic.dart';

class VipBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => VipLogic());
  }
}
