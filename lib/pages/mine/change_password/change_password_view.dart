import 'package:fishpi_app/res/styles.dart';
import 'package:fishpi_app/widgets/pi_input.dart';
import 'package:fishpi_app/widgets/pi_title_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'change_password_logic.dart';

class ChangePasswordPage extends StatelessWidget {
  ChangePasswordPage({super.key});

  final ChangePasswordLogic logic = Get.find<ChangePasswordLogic>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PiTitleBar.back(title: '修改密码'),
      body: Obx(
        () => Container(
          width: 1.sw,
          constraints: BoxConstraints(minHeight: 1.sh),
          color: Styles.titleBarColor,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
            child: Column(
              children: [
                _buildFormCard(),
                20.verticalSpace,
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      width: 1.sw - 32.w,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Styles.commonBorder,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(
            () => _buildPasswordInput(
              key: const ValueKey('change_password_old_input'),
              label: '旧密码',
              controller: logic.oldPasswordController,
              obscureText: !logic.showOldPassword.value,
              onToggle: logic.toggleOldPasswordVisible,
              visible: logic.showOldPassword.value,
            ),
          ),
          14.verticalSpace,
          Obx(
            () => _buildPasswordInput(
              key: const ValueKey('change_password_new_input'),
              label: '新密码',
              controller: logic.newPasswordController,
              obscureText: !logic.showNewPassword.value,
              onToggle: logic.toggleNewPasswordVisible,
              visible: logic.showNewPassword.value,
            ),
          ),
          14.verticalSpace,
          Obx(
            () => _buildPasswordInput(
              key: const ValueKey('change_password_confirm_input'),
              label: '确认新密码',
              controller: logic.confirmPasswordController,
              obscureText: !logic.showConfirmPassword.value,
              onToggle: logic.toggleConfirmPasswordVisible,
              visible: logic.showConfirmPassword.value,
              textInputAction: TextInputAction.done,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordInput({
    required Key key,
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggle,
    required bool visible,
    TextInputAction textInputAction = TextInputAction.next,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Styles.primaryTextColor,
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        8.verticalSpace,
        SizedBox(
          height: 52.h,
          child: PiInput(
            key: key,
            controller: controller,
            hintText: label,
            prefixIcon: const Icon(Icons.lock_outline),
            obscureText: obscureText,
            textInputAction: textInputAction,
            textAlign: TextAlign.start,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            suffixIcon: IconButton(
              onPressed: onToggle,
              icon: Icon(
                visible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
            ),
            onInputChanged: (_) {},
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: logic.isSaving.value ? null : logic.submit,
      child: Opacity(
        opacity: logic.isSaving.value ? 0.62 : 1,
        child: Container(
          width: 1.sw - 32.w,
          height: 56.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: logic.isSaving.value
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
                    const Icon(
                      Icons.save_outlined,
                      color: Colors.white,
                    ),
                    8.horizontalSpace,
                    Text(
                      '保存',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
