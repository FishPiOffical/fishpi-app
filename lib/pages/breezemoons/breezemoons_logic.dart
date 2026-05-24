import 'dart:async';

import 'package:fishpi/types/breezemoon.dart';
import 'package:fishpi_app/core/controller/im.dart';
import 'package:fishpi_app/core/manager/toast.dart';
import 'package:fishpi_app/core/sql/black_list.dart';
import 'package:fishpi_app/core/sql/user_remark.dart';
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
  final List<BlackUser> _blackUsers = [];
  StreamSubscription<void>? _blackListSubscription;
  StreamSubscription<void>? _remarkSubscription;

  TextEditingController textEditingController = TextEditingController();

  @override
  void onInit() {
    _blackListSubscription ??= BlackList.changes.listen((_) {
      _reloadBlackUsersAndFilterList();
    });
    UserRemark.init();
    _remarkSubscription ??= UserRemark.changes.listen((_) {
      list.refresh();
    });
    initBreezemoon();
    super.onInit();
  }

  void initBreezemoon() async {
    await _loadBlackUsers();
    List<BreezemoonContent> res = await imController.fishpi.breezemoon.list(
      page: page.value,
      size: 15,
    );
    final visibleList = _visibleBreezemoons(res);
    if (page.value == 1) {
      list.value = visibleList;
      list.refresh();
      refresherController.loadComplete();
    } else {
      list.addAll(visibleList);
      list.refresh();
      if (res.isNotEmpty) {
        refresherController.loadComplete();
      } else {
        refresherController.loadNoData();
        isFinished.value = true;
      }
    }
  }

  List<BreezemoonContent> _visibleBreezemoons(
    Iterable<BreezemoonContent> source,
  ) {
    return BlackList.visibleItems(
      source,
      _blackUsers,
      userName: (item) => item.authorName,
    );
  }

  Future<void> _loadBlackUsers() async {
    try {
      await BlackList.init();
      _blackUsers
        ..clear()
        ..addAll(await BlackList.getAllUser());
    } catch (_) {
      _blackUsers.clear();
    }
  }

  Future<void> _reloadBlackUsersAndFilterList() async {
    await _loadBlackUsers();
    list.assignAll(_visibleBreezemoons(list));
    list.refresh();
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

  @override
  void onClose() {
    _blackListSubscription?.cancel();
    _remarkSubscription?.cancel();
    super.onClose();
  }
}
