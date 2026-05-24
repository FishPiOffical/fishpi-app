import 'package:fishpi_app/res/styles.dart';
import 'package:fishpi_app/widgets/pi_title_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatRoomSettingsPage extends StatelessWidget {
  const ChatRoomSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PiTitleBar.back(title: '聊天室设置'),
      body: Container(
        width: 1.sw,
        constraints: BoxConstraints(minHeight: 1.sh),
        color: Styles.titleBarColor,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          child: Container(
            width: 1.sw - 32.w,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Styles.commonBorder,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Text(
              '暂无设置项',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Styles.primaryTextColor,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
