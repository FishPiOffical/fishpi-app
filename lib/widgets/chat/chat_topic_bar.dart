import 'package:fishpi_app/res/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatTopicBar extends StatelessWidget {
  final String topic;
  final VoidCallback? onTap;
  final VoidCallback? onQuoteTap;

  const ChatTopicBar({
    super.key,
    required this.topic,
    this.onTap,
    this.onQuoteTap,
  });

  @override
  Widget build(BuildContext context) {
    final text = topic.trim().isEmpty ? '暂无话题' : '# $topic';
    return GestureDetector(
      key: const ValueKey('chat_topic_bar'),
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: Container(
        width: 1.sw,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: const BoxDecoration(
          color: Styles.titleBarColor,
          border: Border(
            bottom: BorderSide(
              color: Styles.primaryTextColor,
              width: 2,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24.w,
              height: 24.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Styles.primaryColor,
                border: Styles.commonBorder,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                '#',
                style: TextStyle(
                  color: Styles.primaryTextColor,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            8.horizontalSpace,
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Styles.primaryTextColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (onQuoteTap != null) ...[
              8.horizontalSpace,
              GestureDetector(
                key: const ValueKey('chat_topic_quote_button'),
                onTap: onQuoteTap,
                child: Container(
                  height: 32.h,
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Styles.commonBorder,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    '引用',
                    style: TextStyle(
                      color: Styles.primaryTextColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
            8.horizontalSpace,
            Icon(
              Icons.edit_outlined,
              color: Styles.primaryTextColor,
              size: 18.w,
            ),
          ],
        ),
      ),
    );
  }
}
