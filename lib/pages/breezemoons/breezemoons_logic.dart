import 'package:fishpi/types/breezemoon.dart';
import 'package:fishpi_app/core/controller/im.dart';
import 'package:fishpi_app/core/manager/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class BreezemoonsLogic extends GetxController {
  final refresherController = RefreshController();
  final imController = Get.find<IMController>();

  final list = <BreezemoonContent>[].obs;
  final page = 1.obs;
  final isFinished = false.obs;

  final breezemoons = ''.obs;

  TextEditingController textEditingController = TextEditingController();

  @override
  void onInit() {
    initBreezemoon();
    super.onInit();
  }

  void initBreezemoon() async {
    List<BreezemoonContent> res = await imController.fishpi.breezemoon.list(
      page: page.value,
      size: 15,
    );
    if (page.value == 1) {
      list.value = res;
      list.refresh();
      refresherController.loadComplete();
    } else {
      list.addAll(res);
      list.refresh();
      if (res.isNotEmpty) {
        refresherController.loadComplete();
      } else {
        refresherController.loadNoData();
        isFinished.value = true;
      }
    }
  }

  void onRefresh() {
    isFinished.value = false;
    page.value = 1;
    initBreezemoon();
    refresherController.refreshCompleted();
  }

  void onLoading() {
    if (isFinished.value) return;
    page.value++;
    initBreezemoon();
  }

  void onInputChanged(text) {
    breezemoons.value = text;
  }

  void sendBreezemoon() async {
    if (breezemoons.value == '') return;
    ToastManager.show();
    await imController.fishpi.breezemoon.send(breezemoons.value);
    ToastManager.dismiss();
    textEditingController.text = '';
    breezemoons.value = '';
    onRefresh();
  }
}
