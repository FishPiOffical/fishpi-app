import 'dart:async';

import 'package:fishpi/types/breezemoon.dart';
import 'package:fishpi_app/core/controller/im.dart';
import 'package:fishpi_app/core/debug/memory_snapshot.dart';
import 'package:fishpi_app/core/manager/toast.dart';
import 'package:fishpi_app/core/memory/memory_limits.dart';
import 'package:fishpi_app/core/memory/memory_list_utils.dart';
import 'package:fishpi_app/core/network/app_error_message.dart';
import 'package:fishpi_app/core/sql/black_list.dart';
import 'package:fishpi_app/core/sql/user_remark.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class BreezemoonsLogic extends GetxController {
  BreezemoonsLogic({this.autoLoad = true});

  static const int maxContentLength = 280;

  final bool autoLoad;
  final refresherController = RefreshController();
  final imController = Get.find<IMController>();

  final list = <BreezemoonContent>[].obs;
  final page = 1.obs;
  final isFinished = false.obs;
  final isLoading = false.obs;
  final errorText = ''.obs;

  final breezemoons = ''.obs;
  final isSending = false.obs;
  final sendErrorText = ''.obs;
  final List<BlackUser> _blackUsers = [];
  StreamSubscription<void>? _blackListSubscription;
  StreamSubscription<void>? _remarkSubscription;
  bool _hasRequestedInitialLoad = false;

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
    if (autoLoad) {
      loadInitialPageIfNeeded();
    }
    super.onInit();
  }

  bool get hasRequestedInitialLoad => _hasRequestedInitialLoad;

  Future<void> loadInitialPageIfNeeded() async {
    if (_hasRequestedInitialLoad || isLoading.value || list.isNotEmpty) {
      return;
    }
    isFinished.value = false;
    page.value = 1;
    await initBreezemoon();
  }

  Future<void> initBreezemoon() async {
    if (isLoading.value) return;
    isLoading.value = true;
    final requestPage = page.value;
    if (requestPage == 1) {
      _hasRequestedInitialLoad = true;
    }
    try {
      await _loadBlackUsers();
      List<BreezemoonContent> res = await imController.fishpi.breezemoon.list(
        page: requestPage,
        size: 15,
      );
      errorText.value = '';
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
    } catch (e) {
      errorText.value = AppErrorMessage.friendly(
        e,
        fallback: '清风明月加载失败',
      );
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

  int get contentLength => breezemoons.value.trim().length;

  bool get isContentOverflow => contentLength > maxContentLength;

  bool get canSend =>
      contentLength > 0 && !isContentOverflow && !isSending.value;

  String? validateContent(String raw) {
    final content = raw.trim();
    if (content.isEmpty) {
      return '先写点内容再发布';
    }
    if (content.length > maxContentLength) {
      return '内容超过 $maxContentLength 字，请精简后再发布';
    }
    return null;
  }

  void onInputChanged(String text) {
    breezemoons.value = text;
    if (sendErrorText.value.isNotEmpty) {
      sendErrorText.value = '';
    }
  }

  void sendBreezemoon() async {
    if (isSending.value) return;
    final content = breezemoons.value.trim();
    final validationError = validateContent(content);
    if (validationError != null) {
      sendErrorText.value = validationError;
      ToastManager.showToast(validationError);
      return;
    }

    isSending.value = true;
    sendErrorText.value = '';
    ToastManager.show(content: '发布中...');
    try {
      final result = await imController.fishpi.breezemoon.send(content);
      if (!result.success) {
        throw result.msg.isEmpty ? '服务端未接受发布' : result.msg;
      }
      textEditingController.text = '';
      breezemoons.value = '';
      ToastManager.dismiss();
      ToastManager.showToast('已发布');
      onRefresh();
    } catch (e) {
      ToastManager.dismiss();
      final message = AppErrorMessage.friendly(e, fallback: '发布失败');
      sendErrorText.value = message;
      ToastManager.showToast(message);
      return;
    } finally {
      isSending.value = false;
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
