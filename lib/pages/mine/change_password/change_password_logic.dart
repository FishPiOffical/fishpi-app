import 'package:fishpi_app/core/account/account_service.dart';
import 'package:fishpi_app/core/controller/im.dart';
import 'package:fishpi_app/core/manager/toast.dart';
import 'package:fishpi_app/core/network/app_error_message.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChangePasswordLogic extends GetxController {
  ChangePasswordLogic({AccountService? accountService})
      : accountService = accountService ?? AccountService();

  final AccountService accountService;
  final imController = Get.find<IMController>();

  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isSaving = false.obs;
  final showOldPassword = false.obs;
  final showNewPassword = false.obs;
  final showConfirmPassword = false.obs;

  void toggleOldPasswordVisible() {
    showOldPassword.value = !showOldPassword.value;
  }

  void toggleNewPasswordVisible() {
    showNewPassword.value = !showNewPassword.value;
  }

  void toggleConfirmPasswordVisible() {
    showConfirmPassword.value = !showConfirmPassword.value;
  }

  static String? validatePasswordForm({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) {
    if (oldPassword.isEmpty) return '请输入旧密码';
    if (newPassword.isEmpty) return '请输入新密码';
    if (newPassword.length < 6 || newPassword.length > 16) {
      return '新密码需为 6-16 位且包含字母和数字';
    }
    if (!RegExp('[A-Za-z]').hasMatch(newPassword) ||
        !RegExp(r'\d').hasMatch(newPassword)) {
      return '新密码需为 6-16 位且包含字母和数字';
    }
    if (confirmPassword.isEmpty) return '请再次输入新密码';
    if (newPassword != confirmPassword) return '两次输入的新密码不一致';
    return null;
  }

  Future<void> submit() async {
    if (isSaving.value) return;

    final error = validatePasswordForm(
      oldPassword: oldPasswordController.text,
      newPassword: newPasswordController.text,
      confirmPassword: confirmPasswordController.text,
    );
    if (error != null) {
      ToastManager.showToast(error);
      return;
    }

    isSaving.value = true;
    ToastManager.show(content: '保存中...');
    try {
      await accountService.updatePassword(
        fishpi: imController.fishpi,
        oldPassword: oldPasswordController.text,
        newPassword: newPasswordController.text,
      );
      ToastManager.dismiss();
      ToastManager.showToast('密码已更新');
      Get.back();
    } catch (e) {
      ToastManager.dismiss();
      ToastManager.showToast(
        AppErrorMessage.friendly(e, fallback: '密码更新失败'),
      );
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
