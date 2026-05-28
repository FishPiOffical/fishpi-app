import 'package:fishpi_app/pages/breezemoons/breezemoons_logic.dart';
import 'package:fishpi_app/pages/conversation/conversation_logic.dart';
import 'package:fishpi_app/pages/forum/forum_logic.dart';
import 'package:fishpi_app/pages/mine/mine_logic.dart';
import 'package:get/get.dart';

import 'home_logic.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    _putOnce(() => HomeLogic());
    _putOnce(() => ConversationLogic());
    _putOnce(() => ForumLogic(autoLoad: false));
    _putOnce(() => BreezemoonsLogic(autoLoad: false));
    _putOnce(() => MineLogic());
  }

  T _putOnce<T extends Object>(T Function() builder) {
    if (Get.isRegistered<T>()) {
      return Get.find<T>();
    }
    return Get.put<T>(builder());
  }
}
