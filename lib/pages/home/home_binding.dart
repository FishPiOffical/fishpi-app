import 'package:fishpi_app/pages/breezemoons/breezemoons_logic.dart';
import 'package:fishpi_app/pages/conversation/conversation_logic.dart';
import 'package:fishpi_app/pages/forum/forum_logic.dart';
import 'package:fishpi_app/pages/mine/mine_logic.dart';
import 'package:get/get.dart';

import 'home_logic.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeLogic());
    Get.lazyPut(() => ConversationLogic());
    Get.lazyPut(() => ForumLogic());
    Get.lazyPut(() => BreezemoonsLogic());
    Get.lazyPut(() => MineLogic());
  }
}
