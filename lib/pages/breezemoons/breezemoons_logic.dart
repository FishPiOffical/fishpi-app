import 'dart:async';

import 'package:fishpi/types/breezemoon.dart';
import 'package:fishpi_app/core/controller/im.dart';
import 'package:fishpi_app/core/debug/memory_snapshot.dart';
import 'package:fishpi_app/core/manager/toast.dart';
import 'package:fishpi_app/core/memory/memory_limits.dart';
import 'package:fishpi_app/core/memory/memory_list_utils.dart';
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
  final isLoading = false.obs;

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
    if (isLoading.value) return;
    isLoading.value = true;
    final requestPage = page.value;
    try {
      await _loadBlackUsers();
      List<BreezemoonContent> res = await imController.fishpi.breezemoon.list(
        page: requestPage,
        size: 15,
      );
      final visibleList = _visibleBreezemoons(res);
      if (requestPage == 1) {
        list.value = MemoryListUtils.keepFirst(
          visibleList,
          MemoryLimits.contentListItems,
        );
        list.refresh();
        refresherController.refreshCompleted();
        refresherController.loadComplete();
      } else {
        list.value = MemoryListUtils.keepFirst(
          [
            ...list,
            ...visibleList,
          ],
          MemoryLimits.contentListItems,
        );
        list.refresh();
        if (res.isNotEmpty) {
          refresherController.loadComplete();
        } else {
          refresherController.loadNoData();
          isFinished.value = true;
        }
      }
    } catch (_) {
      if (requestPage > 1 && page.value == requestPage) {
        page.value = requestPage - 1;
      }
      requestPage == 1
          ? refresherController.refreshFailed()
          : refresherController.loadFailed();
    } finally {
      isLoading.value = false;
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
    list.assignAll(
      MemoryListUtils.keepFirst(
        _visibleBreezemoons(list),
        MemoryLimits.contentListItems,
      ),
    );
    list.refresh();
  }

  void onRefresh() {
    isFinished.value = false;
    page.value = 1;
    initBreezemoon();
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
    try {
      await imController.fishpi.breezemoon.send(breezemoons.value);
      textEditingController.text = '';
      breezemoons.value = '';
      onRefresh();
    } catch (e) {
      ToastManager.dismiss();
      ToastManager.showToast('发布失败：$e');
      return;
    } finally {
      ToastManager.dismiss();
    }
  }

  @override
  void onClose() {
    _blackListSubscription?.cancel();
    _remarkSubscription?.cancel();
    MemorySnapshot.log(source: '清风明月页关闭前', breezemoons: list.length);
    textEditingController.dispose();
    refresherController.dispose();
    super.onClose();
  }
}
