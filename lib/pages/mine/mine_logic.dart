import 'package:fishpi/types/user.dart';
import 'package:fishpi_app/core/controller/im.dart';
import 'package:fishpi_app/core/manager/toast.dart';
import 'package:fishpi_app/core/network/app_error_message.dart';
import 'package:fishpi_app/routers/navigator.dart';
import 'package:get/get.dart';

class MineLogic extends GetxController {
  MineLogic({this.autoLoad = true});

  final bool autoLoad;
  final imController = Get.find<IMController>();
  final userInfo = UserInfo().obs;
  final isLoading = false.obs;
  final errorText = ''.obs;

  @override
  void onInit() {
    if (autoLoad) {
      initUserInfo();
    }
    super.onInit();
  }

  Future<void> initUserInfo() async {
    await refreshUserInfo(silent: true);
  }

  Future<void> refreshUserInfo({bool silent = false}) async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      userInfo.value = await imController.fishpi.user.info(false);
      errorText.value = '';
      if (!silent) ToastManager.showToast('用户信息已刷新');
    } catch (e) {
      final message = AppErrorMessage.friendly(
        e,
        fallback: '用户信息刷新失败',
      );
      errorText.value = message;
      if (!silent) ToastManager.showToast(message);
    } finally {
      isLoading.value = false;
    }
  }

  void toAccountPage() {
    AppNavigator.toAccount();
  }

  void toCollectionPage() {
    final metals = userInfo.value.allMetals.isNotEmpty
        ? userInfo.value.allMetals
        : userInfo.value.sysMetal;
    AppNavigator.toCollection(metals);
  }

  void toVipPage() {
    AppNavigator.toVip();
  }

  void toSetUpPage() {
    AppNavigator.toSetting();
  }
}
