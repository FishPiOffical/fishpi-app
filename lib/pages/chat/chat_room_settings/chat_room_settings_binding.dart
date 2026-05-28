import 'package:get/get.dart';

import 'chat_room_settings_logic.dart';

class ChatRoomSettingsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ChatRoomSettingsLogic>()) {
      Get.lazyPut(() => ChatRoomSettingsLogic());
    }
  }
}
