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
        padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 0),
        decoration: const BoxDecoration(
          color: Styles.titleBarColor,
          border: Border(
            top: BorderSide(
              color: Styles.primaryTextColor,
              width: 2,
            ),
          ),
        ),
        child: Container(
          height: 32.h,
          padding: EdgeInsets.only(left: 10.w, right: 6.w),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Styles.commonBorder,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Row(
            children: [
              Icon(
                Icons.tag_outlined,
                color: Styles.primaryTextColor,
                size: 16.w,
              ),
              6.horizontalSpace,
              Expanded(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Styles.primaryTextColor,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (onQuoteTap != null)
                GestureDetector(
                  key: const ValueKey('chat_topic_quote_button'),
                  onTap: onQuoteTap,
                  child: Container(
                    height: 24.h,
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Styles.primaryColor,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      '引用',
                      style: TextStyle(
                        color: Styles.primaryTextColor,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              6.horizontalSpace,
              Icon(
                Icons.edit_outlined,
                color: Styles.primaryTextColor,
                size: 16.w,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
