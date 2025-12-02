import 'package:fishpi_app/res/styles.dart';
import 'package:fishpi_app/widgets/pi_title_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PiScanResult extends StatelessWidget {
  final String result;

  const PiScanResult(this.result, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PiTitleBar.back(
        title: "扫码结果",
      ),
      backgroundColor: Styles.primaryColor,
      body: SafeArea(
          child: Column(
        children: [
          SizedBox(height: 50.h),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10.w),
            ),
            child: Text(
              result,
              style: TextStyle(fontSize: 20.sp),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 50.h),
          Text('❗️ 安全提醒 ❗️', style: TextStyle(fontSize: 16.sp)),
          Text('此二维码来源未经摸鱼排官方认证', style: TextStyle(fontSize: 16.sp)),
          Text('可能存在安全隐患，请谨慎使用', style: TextStyle(fontSize: 16.sp)),
          const Expanded(
              child: SizedBox(
            height: 1,
          )),
          InkWell(
            onTap: () {
              Navigator.of(context).pop();
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
                '我知道了',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                ),
              ),
            ),
          ),
          SizedBox(height: 50.h),
        ],
      )),
    );
  }
}
