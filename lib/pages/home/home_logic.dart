import 'package:fishpi_app/core/controller/im.dart';
import 'package:fishpi_app/utils/pi_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class HomeLogic extends GetxController {
  final imController = Get.find<IMController>();
  final token = ''.obs;
  PageController pageController = PageController();
  final index = 0.obs;

  @override
  void onInit() {
    token.value = PiUtils.getString('token');
    initChat();
    super.onInit();
  }

  Future<void> initChat() async {
    if (token.value.isEmpty) return;
    await imController.init(token.value);
    try {
      await imController.chatInit();
    } catch (_) {}
  }

  void onPageChanged(int idx) {
    index.value = idx;
  }

  void changeIndex(int idx) {
    index.value = idx;
    pageController.jumpToPage(idx);
  }
}
