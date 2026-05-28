import 'package:fishpi_app/res/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PiListState extends StatelessWidget {
  const PiListState({
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.buttonText = '重试',
    this.onRetry,
    this.retryKey,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback? onRetry;
  final Key? retryKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 20.h),
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 22.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Styles.commonBorder,
        borderRadius: Styles.cardRadius,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Styles.primaryColor,
              border: Styles.commonBorder,
              borderRadius: Styles.actionRadius,
            ),
            child: Icon(
              icon,
              size: 26.w,
              color: Styles.primaryTextColor,
            ),
          ),
          12.verticalSpace,
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Styles.primaryTextColor,
              fontSize: 17.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          6.verticalSpace,
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Styles.secondaryTextColor,
              fontSize: 13.sp,
              height: 1.35,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (onRetry != null) ...[
            16.verticalSpace,
            GestureDetector(
              key: retryKey,
              onTap: onRetry,
              child: Container(
                constraints: BoxConstraints(minWidth: 96.w, minHeight: 44.w),
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: Styles.primaryTextColor,
                  borderRadius: Styles.actionRadius,
                ),
                child: Text(
                  buttonText,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
