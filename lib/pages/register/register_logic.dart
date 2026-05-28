import 'package:fishpi/fishpi.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/controller/im.dart';
import '../../core/manager/toast.dart';
import '../../core/network/app_error_message.dart';

enum RegisterStep {
  info,
  verify,
  password,
}

class RegisterLogic extends GetxController {
  static const _loginRoute = '/login';

  final imController = Get.find<IMController>();

  final userNameController = TextEditingController();
  final phoneController = TextEditingController();
  final inviteCodeController = TextEditingController();
  final captchaController = TextEditingController();
  final smsCodeController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final step = RegisterStep.info.obs;
  final isSubmitting = false.obs;
  final captchaSeed = DateTime.now().millisecondsSinceEpoch.obs;
  final showPassword = false.obs;
  final showConfirmPassword = false.obs;

  String _userId = '';

  String get captchaUrl => '${Fishpi.captcha}?t=${captchaSeed.value}';

  void refreshCaptcha() {
    captchaSeed.value = DateTime.now().millisecondsSinceEpoch;
  }

  void togglePasswordVisible() {
    showPassword.value = !showPassword.value;
  }

  void toggleConfirmPasswordVisible() {
    showConfirmPassword.value = !showConfirmPassword.value;
  }

  void backToInfo() {
    if (isSubmitting.value) return;
    step.value = RegisterStep.info;
  }

  void backToVerify() {
    if (isSubmitting.value) return;
    step.value = RegisterStep.verify;
  }

  static String? validatePreRegister({
    required String userName,
    required String phone,
    required String captcha,
  }) {
    final trimmedName = userName.trim();
    final trimmedPhone = phone.trim();
    final trimmedCaptcha = captcha.trim();

    if (trimmedName.isEmpty) return '请输入用户名';
    if (trimmedPhone.isEmpty) return '请输入手机号';
    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(trimmedPhone)) {
      return '请输入正确的手机号';
    }
    if (trimmedCaptcha.isEmpty) return '请输入图形验证码';
    return null;
  }

  static String? validateSmsCode(String code) {
    final trimmedCode = code.trim();
    if (trimmedCode.isEmpty) return '请输入手机验证码';
    if (!RegExp(r'^\d{6}$').hasMatch(trimmedCode)) {
      return '请输入 6 位手机验证码';
    }
    return null;
  }

  static String? validatePassword({
    required String password,
    required String confirmPassword,
  }) {
    if (password.isEmpty) return '请输入密码';
    if (password.length < 6) return '密码至少 6 位';
    if (confirmPassword.isEmpty) return '请再次输入密码';
    if (password != confirmPassword) return '两次输入的密码不一致';
    return null;
  }

  Future<void> submitPreRegister() async {
    if (isSubmitting.value) return;

    final error = validatePreRegister(
      userName: userNameController.text,
      phone: phoneController.text,
      captcha: captchaController.text,
    );
    if (error != null) {
      ToastManager.showToast(error);
      return;
    }

    isSubmitting.value = true;
    ToastManager.show(content: '提交中...');
    try {
      final result = await imController.fishpi.preRegister(
        PreRegisterInfo(
          username: userNameController.text.trim(),
          phone: phoneController.text.trim(),
          invitecode: inviteCodeController.text.trim(),
          captcha: captchaController.text.trim(),
        ),
      );
      if (!result.success) {
        throw result.msg.isEmpty ? '注册信息提交失败' : result.msg;
      }

      step.value = RegisterStep.verify;
      ToastManager.dismiss();
      ToastManager.showToast('验证码已发送');
    } catch (e) {
      ToastManager.dismiss();
      ToastManager.showToast(
        AppErrorMessage.friendly(e, fallback: '注册信息提交失败'),
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> submitVerifyCode() async {
    if (isSubmitting.value) return;

    final error = validateSmsCode(smsCodeController.text);
    if (error != null) {
      ToastManager.showToast(error);
      return;
    }

    isSubmitting.value = true;
    ToastManager.show(content: '验证中...');
    try {
      _userId = await imController.fishpi.verify(smsCodeController.text.trim());
      step.value = RegisterStep.password;
      ToastManager.dismiss();
      ToastManager.showToast('验证成功');
    } catch (e) {
      ToastManager.dismiss();
      ToastManager.showToast(
        AppErrorMessage.friendly(e, fallback: '验证码验证失败'),
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> submitRegister() async {
    if (isSubmitting.value) return;

    final error = validatePassword(
      password: passwordController.text,
      confirmPassword: confirmPasswordController.text,
    );
    if (error != null) {
      ToastManager.showToast(error);
      return;
    }
    if (_userId.isEmpty) {
      ToastManager.showToast('请先完成手机验证');
      step.value = RegisterStep.verify;
      return;
    }

    isSubmitting.value = true;
    ToastManager.show(content: '注册中...');
    try {
      final result = await imController.fishpi.register(
        RegisterInfo(
          passwd: passwordController.text,
          userId: _userId,
          r: inviteCodeController.text.trim(),
        ),
      );
      if (!result.success) {
        throw result.msg.isEmpty ? '注册失败' : result.msg;
      }

      ToastManager.dismiss();
      ToastManager.showToast('注册成功，请登录');
      Get.offNamed(_loginRoute);
    } catch (e) {
      ToastManager.dismiss();
      ToastManager.showToast(
        AppErrorMessage.friendly(e, fallback: '注册失败'),
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    userNameController.dispose();
    phoneController.dispose();
    inviteCodeController.dispose();
    captchaController.dispose();
    smsCodeController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
