import 'package:fishpi_app/res/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'about_logic.dart';

class AboutPage extends StatelessWidget {
  final AboutLogic logic = Get.find<AboutLogic>();

  AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: Styles.primaryColor,
        body: SizedBox(
          width: 1.sw,
          height: 1.sh,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Get.back();
                },
                behavior: HitTestBehavior.translucent,
                child: Container(
                  width: 1.sw - 32.w,
                  height: 40.w,
                  alignment: Alignment.centerLeft,
                  child: const Icon(Icons.arrow_back_ios_outlined),
                ),
              ),
              100.verticalSpace,
              Image.asset(
                'assets/images/logo.png',
                width: 70.w,
                height: 70.w,
              ),
              20.verticalSpace,
              Text(
                '摸鱼派',
                style: TextStyle(
                  fontSize: 20.sp,
                  color: Styles.primaryTextColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Version ${logic.version.value}',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Styles.primaryTextColor,
                ),
              ),
              Expanded(
                child: 1.verticalSpace,
              ),
              GestureDetector(
                onTap: () {
                  launchUrl(Uri.parse('https://fishpi.cn/privacy'));
                },
                child: Text(
                  '《用户隐私协议》',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              10.verticalSpace,
              Text(
                '北京白与画科技有限公司 版权所有',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Styles.primaryTextColor,
                ),
              ),
              2.verticalSpace,
              Text(
                'Copyright © 2021 - 2024 W&P Tech. All Rights Reserved.',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Styles.primaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
              50.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }
}
