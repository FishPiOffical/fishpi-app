import 'package:fishpi_app/core/manager/toast.dart';
import 'package:fishpi_app/core/sql/black_list.dart';
import 'package:get/get.dart';

class BlackListLogic extends GetxController {
  final blackList = [].obs;

  @override
  void onInit() {
    super.onInit();
    getList();
  }

  getList() async {
    await BlackList.init();
    blackList.value = await BlackList.getAllUser();
    blackList.refresh();
    print(blackList.length);
  }

  removeUser(String oId) async {
    BlackList.removeUser(oId);
    blackList.removeWhere((element) => element.oId == oId);
    ToastManager.showToast("操作成功");
  }

  @override
  void dispose() {
    BlackList.dispose();
    super.dispose();
  }
}
