import 'package:fishpi/types/user.dart';
import 'package:fishpi_app/core/account/account_service.dart';
import 'package:fishpi_app/core/controller/im.dart';
import 'package:fishpi_app/core/manager/toast.dart';
import 'package:fishpi_app/core/network/app_error_message.dart';
import 'package:fishpi_app/pages/mine/mine_logic.dart';
import 'package:fishpi_app/routers/navigator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class AccountLogic extends GetxController {
  AccountLogic({
    AccountService? accountService,
    ImagePicker? imagePicker,
    UserInfo? initialUser,
    this.autoLoad = true,
  })  : accountService = accountService ?? AccountService(),
        imagePicker = imagePicker ?? ImagePicker(),
        userInfo = (initialUser ?? UserInfo()).obs;

  final AccountService accountService;
  final ImagePicker imagePicker;
  final bool autoLoad;

  final imController = Get.find<IMController>();
  final Rx<UserInfo> userInfo;
  final selectedAvatarPath = ''.obs;
  final isLoading = false.obs;
  final isUploading = false.obs;

  String get avatarName {
    final current = userInfo.value;
    if (current.userName.isNotEmpty) return current.userName;
    if (current.nickname.isNotEmpty) return current.nickname;
    return '鱼';
  }

  @override
  void onInit() {
    super.onInit();
    if (autoLoad) {
      loadUserInfo();
    }
  }

  Future<void> loadUserInfo() async {
    final cached = imController.fishpi.user.current;
    if (cached.userName.isNotEmpty) {
      userInfo.value = cached;
    }
    if (imController.fishpi.token.isEmpty) return;

    isLoading.value = true;
    try {
      final info = await imController.fishpi.user.info(false);
      _syncUserInfo(info);
    } catch (e) {
      ToastManager.showToast(
        AppErrorMessage.friendly(e, fallback: '加载用户信息失败'),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickAvatar() async {
    if (isUploading.value) return;
    final file = await imagePicker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    selectedAvatarPath.value = file.path;
  }

  Future<void> uploadSelectedAvatar() async {
    if (isUploading.value) return;
    final path = selectedAvatarPath.value;
    if (path.isEmpty) {
      ToastManager.showToast('请先选择头像');
      return;
    }

    isUploading.value = true;
    ToastManager.show(content: '上传中...');
    try {
      final avatarURL = await accountService.uploadAvatar(
        fishpi: imController.fishpi,
        filePath: path,
      );
      await accountService.updateAvatar(
        fishpi: imController.fishpi,
        avatarURL: avatarURL,
      );
      final info = await imController.fishpi.user.info();
      _syncUserInfo(info);
      selectedAvatarPath.value = '';
      ToastManager.dismiss();
      ToastManager.showToast('头像已更新');
      if (Get.isBottomSheetOpen ?? false) {
        Get.back();
      }
    } catch (e) {
      ToastManager.dismiss();
      ToastManager.showToast(
        AppErrorMessage.friendly(e, fallback: '头像更新失败'),
      );
    } finally {
      isUploading.value = false;
    }
  }

  void toEditInfo() {
    AppNavigator.toEditInfo();
  }

  void toChangePassword() {
    AppNavigator.toChangePassword();
  }

  void _syncUserInfo(UserInfo info) {
    userInfo.value = info;
    if (Get.isRegistered<MineLogic>()) {
      Get.find<MineLogic>().userInfo.value = info;
    }
  }
}
