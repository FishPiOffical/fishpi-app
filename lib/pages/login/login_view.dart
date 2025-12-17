import 'package:fishpi_app/res/styles.dart';
import 'package:fishpi_app/routers/navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';

import '../../core/manager/toast.dart';
import '../../utils/pi_utils.dart';
import '../../widgets/pi_input.dart';
import 'login_logic.dart';

class LoginPage extends StatelessWidget {
  final LoginLogic logic = Get.put(LoginLogic());

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 1.sw,
        height: 1.sh,
        color: Styles.primaryColor,
        padding: const EdgeInsets.all(10),
        child: Center(
          child: SizedBox(
            width: 327.w,
            height: 370.h,
            child: Column(
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
                GestureDetector(
                  onTap: () async {
                    print('点击了登录');
                    if (logic.userName.isEmpty) {
                      ToastManager.showToast('请输入用户名/邮箱');
                      return;
                    }
                    if (logic.pwd.isEmpty) {
                      ToastManager.showToast('请输入密码');
                      return;
                    }
                    logic.pinEditingController.clear();
                    ToastManager.show(content: '登录中...');
                    logic.login(mfaCb: () {
                      _showMfaCodeDialog();
                    }).then((token) {
                      ToastManager.dismiss();
                      ToastManager.showToast('登录成功');
                      print(token);
                      PiUtils.setString('token', token);
                      PiUtils.setBool('isLogin', true);
                      AppNavigator.closeAllToHome();
                    }).catchError((e) {
                      ToastManager.dismiss();
                      ToastManager.showToast(e.toString());
                    });
                  },
                  child: Container(
                    width: 327.w,
                    height: 56.h,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Colors.black,
                    ),
                    child: Text(
                      '登 录'.tr,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 24.h,
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
                          onTap: () {
                            print('点击了注册');
                          },
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
                      onTap: () {
                        // print('点击了扫码登录');
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
    return SizedBox(
      width: 327.w,
      height: 56.h,
      child: PiInput(
        hintText: '密码',
        prefixIcon: const Icon(Icons.lock),
        controller: logic.pwdController,
        obscureText: true,
        onInputChanged: (text) {
          logic.onPwdChanged(text);
        },
      ),
    );
  }

  /// 二步验证弹窗
  void _showMfaCodeDialog() {
    showGeneralDialog(
      context: Get.context!,
      barrierColor: Colors.black.withOpacity(.1),
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
                GestureDetector(
                  onTap: () {
                    print('点击提交二次验证码');
                    Navigator.pop(context);
                    logic.pinEditingController.clear();
                    logic.login(mfaCb: () {
                      _showMfaCodeDialog();
                    }).then((token) {
                      ToastManager.dismiss();
                      ToastManager.showToast('登录成功');
                      print(token);
                      PiUtils.setString('token', token);
                      PiUtils.setBool('isLogin', true);
                      AppNavigator.closeAllToHome();
                    }).catchError((e) {
                      ToastManager.dismiss();
                    });
                  },
                  child: Container(
                    width: 290.w,
                    height: 60.h,
                    decoration: const BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    alignment: Alignment.center,
                    child: const Text(
                      "提交二次验证码",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        color: Colors.white,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
