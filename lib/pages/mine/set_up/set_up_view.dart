import 'package:fishpi_app/res/styles.dart';
import 'package:fishpi_app/widgets/pi_title_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../widgets/pi_menu_item.dart';
import 'set_up_logic.dart';

class SetUpPage extends StatelessWidget {
  final SetUpLogic logic = Get.put(SetUpLogic());

  SetUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PiTitleBar.back(
          title: '设置',
        ),
        body: SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Styles.commonBorder,
                    borderRadius: BorderRadius.circular(16.w),
                    color: Colors.white,
                  ),
                  padding: EdgeInsets.all(10.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PiMenuItem(
                        title: '黑名单',
                        iconColor: Colors.black,
                        icon: Icons.people_alt_outlined,
                        onTap: logic.toBlackPage,
                      ),
                      PiMenuItem(
                        title: '意见反馈',
                        iconColor: Colors.greenAccent,
                        icon: Icons.messenger_outline,
                        onTap: logic.toFeedBackPage,
                      ),
                      PiMenuItem(
                        title: '投诉举报',
                        iconColor: Colors.redAccent,
                        icon: Icons.sentiment_dissatisfied_outlined,
                        onTap: logic.toComplaint,
                      ),
                    ],
                  ),
                ),
                20.verticalSpace,
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    border: Styles.commonBorder,
                    borderRadius: BorderRadius.circular(16.w),
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PiMenuItem(
                        title: '关于摸鱼派',
                        iconColor: Styles.primaryColor,
                        icon: Icons.workspaces_outlined,
                        onTap: logic.toAboutPage,
                      ),
                    ],
                  ),
                ),
                Expanded(child: 1.verticalSpace),
                GestureDetector(
                  onTap: () {
                    logic.logout();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.w),
                      border: Styles.commonBorder,
                      color: Styles.primaryColor,
                    ),
                    width: 1.sw - 32.w,
                    height: 50.h,
                    alignment: Alignment.center,
                    child: Text(
                      '退出登录',
                      style: TextStyle(
                        fontSize: 20.sp,
                        color: Styles.primaryTextColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
