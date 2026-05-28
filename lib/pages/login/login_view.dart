import 'package:fishpi_app/res/styles.dart';
import 'package:fishpi_app/routers/navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/manager/toast.dart';
import '../../utils/pi_utils.dart';
import '../../widgets/pi_input.dart';
import 'login_logic.dart';

class LoginPage extends StatelessWidget {
  final LoginLogic logic = Get.find<LoginLogic>();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 1.sw,
        height: 1.sh,
        color: Styles.primaryColor,
        padding: const EdgeInsets.all(10),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: SizedBox(
                width: 327.w,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      '登录',
                      style: TextStyle(
                        fontSize: 26,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 24.h,
                    ),
                    buildUserNameInputWidget(),
                    SizedBox(
                      height: 24.h,
                    ),
                    buildPwdInputWidget(),
                    SizedBox(
                      height: 48.h,
                    ),
                    _buildLoginButton(),
                    SizedBox(
                      height: 16.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              '还没有账号?'.tr,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.bold),
                            ),
                            GestureDetector(
                              onTap: AppNavigator.toRegister,
                              child: Text(
                                '现在注册'.tr,
                                style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          key: const ValueKey('login_forgot_password_button'),
                          onTap: _openForgotPassword,
                          child: Text(
                            '忘记密码'.tr,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            AppNavigator.toScan();
                          },
                          child: const Icon(
                            Icons.qr_code_scanner,
                            color: Colors.black,
                            size: 20,
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 用户名输入框
  Widget buildUserNameInputWidget() {
    return SizedBox(
      width: 327.w,
      height: 56.h,
      child: PiInput(
        hintText: '用户名/邮箱',
        prefixIcon: const Icon(Icons.person),
        controller: logic.userNameController,
        onInputChanged: (text) {
          logic.onUserNameChanged(text);
        },
      ),
    );
  }

  /// 密码输入框
  Widget buildPwdInputWidget() {
    return Obx(
      () => SizedBox(
        width: 327.w,
        height: 56.h,
        child: PiInput(
          hintText: '密码',
          prefixIcon: const Icon(Icons.lock),
          controller: logic.pwdController,
          obscureText: !logic.showPassword.value,
          suffixIcon: GestureDetector(
            key: const ValueKey('login_password_visibility_button'),
            onTap: logic.togglePasswordVisible,
            child: Icon(
              logic.showPassword.value
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
          ),
          onInputChanged: (text) {
            logic.onPwdChanged(text);
          },
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Obx(
      () {
        final loading = logic.isLoggingIn.value;
        return GestureDetector(
          key: const ValueKey('login_submit_button'),
          onTap: loading ? null : _submitLogin,
          child: Container(
            width: 327.w,
            height: 56.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              color:
                  loading ? Colors.black.withValues(alpha: 0.72) : Colors.black,
            ),
            child: loading
                ? SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    '登 录'.tr,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Future<void> _submitLogin() async {
    if (logic.userName.value.trim().isEmpty) {
      ToastManager.showToast('请输入用户名/邮箱');
      return;
    }
    if (logic.pwd.value.trim().isEmpty) {
      ToastManager.showToast('请输入密码');
      return;
    }

    logic.pinEditingController.clear();
    logic.onPinChange('');
    try {
      final token = await logic.login(mfaCb: _showMfaCodeDialog);
      _finishLogin(token);
    } catch (e) {
      final message = e.toString();
      if (message == '请输入正确的二次验证码') return;
      ToastManager.showToast(message);
    }
  }

  Future<void> _submitMfa(BuildContext dialogContext) async {
    if (logic.mfaCode.value.trim().length != 6) {
      ToastManager.showToast('请输入 6 位二次验证码');
      return;
    }

    final navigator = Navigator.of(dialogContext);
    try {
      final token = await logic.login(
        submittingMfa: true,
      );
      if (navigator.mounted && navigator.canPop()) {
        navigator.pop();
      }
      _finishLogin(token);
    } catch (e) {
      logic.pinEditingController.clear();
      logic.onPinChange('');
      ToastManager.showToast('二次验证码验证失败：$e');
    }
  }

  void _finishLogin(String token) {
    ToastManager.showToast('登录成功');
    PiUtils.setString('token', token);
    PiUtils.setBool('isLogin', true);
    AppNavigator.closeAllToHome();
  }

  Future<void> _openForgotPassword() async {
    final uri = Uri.parse('https://fishpi.cn/login');
    final success = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!success) {
      ToastManager.showToast('请前往 fishpi.cn 网页端找回密码');
    }
  }

  /// 二步验证弹窗
  void _showMfaCodeDialog() {
    showGeneralDialog(
      context: Get.context!,
      barrierColor: Colors.black.withValues(alpha: .1),
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation, Widget child) {
        return ScaleTransition(scale: animation, child: child);
      },
      pageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return Center(
          child: Container(
            width: 392.w,
            height: 220.h,
            decoration: BoxDecoration(
              color: const Color.fromRGBO(255, 244, 204, 1),
              border: Border.all(width: 2, color: Colors.black),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  height: 5.h,
                ),
                // 二步验证组件 有bug 下次改
                Material(
                    color: const Color.fromRGBO(255, 244, 204, 1),
                    child: Container(
                      height: 48.h,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: PinInputTextField(
                        pinLength: 6,
                        controller: logic.pinEditingController,
                        autoFocus: true,
                        onChanged: logic.onPinChange,
                        keyboardType: TextInputType.number,
                        decoration: BoxLooseDecoration(
                          strokeWidth: 2,
                          radius: const Radius.circular(10),
                          textStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 25.sp,
                          ),
                          strokeColorBuilder:
                              PinListenColorBuilder(Colors.black, Colors.grey),
                          bgColorBuilder: PinListenColorBuilder(
                            const Color.fromRGBO(255, 255, 255, 1),
                            const Color.fromRGBO(255, 244, 204, 1),
                          ),
                        ),
                      ),
                    )),
                Obx(
                  () {
                    final loading = logic.isSubmittingMfa.value;
                    return GestureDetector(
                      key: const ValueKey('login_mfa_submit_button'),
                      onTap: loading ? null : () => _submitMfa(context),
                      child: Container(
                        width: 290.w,
                        height: 60.h,
                        decoration: BoxDecoration(
                          color: loading
                              ? Colors.black.withValues(alpha: 0.72)
                              : Colors.black,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                        ),
                        alignment: Alignment.center,
                        child: loading
                            ? SizedBox(
                                width: 20.w,
                                height: 20.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                "提交二次验证码",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                  color: Colors.white,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                      ),
                    );
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
