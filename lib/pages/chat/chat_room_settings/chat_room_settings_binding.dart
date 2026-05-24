import 'package:get/get.dart';

import 'chat_room_settings_logic.dart';

class ChatRoomSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ChatRoomSettingsLogic());
  }
}
