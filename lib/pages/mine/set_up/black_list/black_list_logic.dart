import 'dart:async';

import 'package:fishpi_app/core/manager/toast.dart';
import 'package:fishpi_app/core/sql/black_list.dart';
import 'package:fishpi_app/core/sql/user_remark.dart';
import 'package:get/get.dart';

class BlackListLogic extends GetxController {
  final blackList = [].obs;
  StreamSubscription<void>? _remarkSubscription;

  @override
  void onInit() {
    super.onInit();
    UserRemark.init();
    _remarkSubscription ??= UserRemark.changes.listen((_) {
      blackList.refresh();
    });
    getList();
  }

  getList() async {
    await BlackList.init();
    blackList.value = await BlackList.getAllUser();
    blackList.refresh();
  }

  removeUser(String oId) async {
    await BlackList.removeUser(oId);
    blackList.removeWhere((element) => element.oId == oId);
    ToastManager.showToast("操作成功");
  }

  @override
  void onClose() {
    _remarkSubscription?.cancel();
    super.onClose();
  }
}
