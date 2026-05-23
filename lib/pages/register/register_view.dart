import 'package:fishpi_app/res/styles.dart';
import 'package:fishpi_app/widgets/pi_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';

import 'register_logic.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key});

  static const _loginRoute = '/login';

  final RegisterLogic logic = Get.find<RegisterLogic>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: 1.sw,
        height: 1.sh,
        color: Styles.primaryColor,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: SizedBox(
                      width: 327.w,
                      child: Obx(
                        () => Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _buildHeader(),
                            SizedBox(height: 24.h),
                            _buildStepIndicator(logic.step.value),
                            SizedBox(height: 28.h),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: _buildStepBody(logic.step.value),
                            ),
                            SizedBox(height: 24.h),
                            _buildLoginLink(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/logo.png',
          width: 48.w,
          height: 48.w,
        ),
        SizedBox(width: 10.w),
        Text(
          '注册',
          style: TextStyle(
            fontSize: 28.sp,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStepIndicator(RegisterStep step) {
    final currentIndex = RegisterStep.values.indexOf(step);
    const labels = ['账号', '验证', '密码'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var index = 0; index < labels.length; index++) ...[
          _buildStepChip(labels[index], index <= currentIndex),
          if (index != labels.length - 1)
            Container(
              width: 24.w,
              height: 2,
              color: index < currentIndex ? Colors.black : Colors.white,
            ),
        ],
      ],
    );
  }

  Widget _buildStepChip(String text, bool active) {
    return Container(
      width: 58.w,
      height: 28.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? Colors.black : Colors.white,
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: active ? Colors.white : Colors.black,
          fontSize: 13.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStepBody(RegisterStep step) {
    switch (step) {
      case RegisterStep.info:
        return _buildInfoStep();
      case RegisterStep.verify:
        return _buildVerifyStep();
      case RegisterStep.password:
        return _buildPasswordStep();
    }
  }

  Widget _buildInfoStep() {
    return Column(
      key: const ValueKey('register_info_step'),
      children: [
        _buildInput(
          key: const ValueKey('register_username_input'),
          hintText: '用户名',
          prefixIcon: const Icon(Icons.person_outline),
          controller: logic.userNameController,
          textInputAction: TextInputAction.next,
        ),
        SizedBox(height: 16.h),
        _buildInput(
          key: const ValueKey('register_phone_input'),
          hintText: '手机号',
          prefixIcon: const Icon(Icons.phone_iphone),
          controller: logic.phoneController,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
        ),
        SizedBox(height: 16.h),
        _buildInput(
          key: const ValueKey('register_invite_input'),
          hintText: '邀请码（选填）',
          prefixIcon: const Icon(Icons.confirmation_number_outlined),
          controller: logic.inviteCodeController,
          textInputAction: TextInputAction.next,
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _buildInput(
                key: const ValueKey('register_captcha_input'),
                hintText: '图形验证码',
                prefixIcon: const Icon(Icons.verified_outlined),
                controller: logic.captchaController,
                textInputAction: TextInputAction.done,
              ),
            ),
            SizedBox(width: 12.w),
            _buildCaptchaImage(),
          ],
        ),
        SizedBox(height: 32.h),
        _buildPrimaryButton('下一步', logic.submitPreRegister),
      ],
    );
  }

  Widget _buildVerifyStep() {
    return Column(
      key: const ValueKey('register_verify_step'),
      children: [
        Text(
          '验证码已发送至 ${_maskPhone(logic.phoneController.text)}',
          style: TextStyle(
            color: Colors.black,
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 24.h),
        Material(
          color: Styles.primaryColor,
          child: SizedBox(
            height: 54.h,
            child: PinInputTextField(
              key: const ValueKey('register_sms_code_input'),
              pinLength: 6,
              controller: logic.smsCodeController,
              autoFocus: true,
              keyboardType: TextInputType.number,
              decoration: BoxLooseDecoration(
                strokeWidth: 2,
                radius: const Radius.circular(10),
                textStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
                strokeColorBuilder:
                    PinListenColorBuilder(Colors.black, Colors.grey),
                bgColorBuilder: PinListenColorBuilder(
                  Colors.white,
                  const Color.fromRGBO(255, 244, 204, 1),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 32.h),
        _buildPrimaryButton('验证手机', logic.submitVerifyCode),
        SizedBox(height: 16.h),
        _buildTextButton('修改注册信息', logic.backToInfo),
      ],
    );
  }

  Widget _buildPasswordStep() {
    return Column(
      key: const ValueKey('register_password_step'),
      children: [
        Obx(
          () => _buildInput(
            key: const ValueKey('register_password_input'),
            hintText: '密码',
            prefixIcon: const Icon(Icons.lock_outline),
            controller: logic.passwordController,
            obscureText: !logic.showPassword.value,
            textInputAction: TextInputAction.next,
            suffixIcon: IconButton(
              onPressed: logic.togglePasswordVisible,
              icon: Icon(
                logic.showPassword.value
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Obx(
          () => _buildInput(
            key: const ValueKey('register_confirm_password_input'),
            hintText: '确认密码',
            prefixIcon: const Icon(Icons.lock_outline),
            controller: logic.confirmPasswordController,
            obscureText: !logic.showConfirmPassword.value,
            textInputAction: TextInputAction.done,
            suffixIcon: IconButton(
              onPressed: logic.toggleConfirmPasswordVisible,
              icon: Icon(
                logic.showConfirmPassword.value
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
            ),
          ),
        ),
        SizedBox(height: 32.h),
        _buildPrimaryButton('完成注册', logic.submitRegister),
        SizedBox(height: 16.h),
        _buildTextButton('返回手机验证', logic.backToVerify),
      ],
    );
  }

  Widget _buildInput({
    required Key key,
    required String hintText,
    required Icon prefixIcon,
    required TextEditingController controller,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return SizedBox(
      width: 327.w,
      height: 56.h,
      child: PiInput(
        key: key,
        hintText: hintText,
        prefixIcon: prefixIcon,
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        obscureText: obscureText,
        suffixIcon: suffixIcon,
        onInputChanged: (_) {},
      ),
    );
  }

  Widget _buildCaptchaImage() {
    return Obx(
      () => GestureDetector(
        key: const ValueKey('register_captcha_image'),
        onTap: logic.refreshCaptcha,
        child: Container(
          width: 118.w,
          height: 56.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 2),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                logic.captchaUrl,
                key: ValueKey(logic.captchaUrl),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.refresh, color: Colors.black);
                },
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  width: 24.w,
                  height: 24.w,
                  color: Colors.black.withValues(alpha: 0.72),
                  child: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                    size: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(String text, Future<void> Function() onTap) {
    return Obx(
      () => GestureDetector(
        onTap: logic.isSubmitting.value ? null : onTap,
        child: Opacity(
          opacity: logic.isSubmitting.value ? 0.62 : 1,
          child: Container(
            width: 327.w,
            height: 56.h,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: Colors.black,
            ),
            child: logic.isSubmitting.value
                ? SizedBox(
                    width: 22.w,
                    height: 22.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        text,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      const Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 44.h,
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.black,
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '已有账号？',
          style: TextStyle(
            color: Colors.black,
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        GestureDetector(
          onTap: () {
            Get.offAllNamed(_loginRoute);
          },
          child: SizedBox(
            height: 44.h,
            child: Center(
              child: Text(
                '去登录',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _maskPhone(String phone) {
    final trimmedPhone = phone.trim();
    if (trimmedPhone.length != 11) return trimmedPhone;
    return '${trimmedPhone.substring(0, 3)}****${trimmedPhone.substring(7)}';
  }
}
