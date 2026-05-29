import 'package:fishpi_app/res/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PiBottomBar extends StatelessWidget {
  final Function(int) callback;
  final int index;
  final int chatUnreadCount;

  const PiBottomBar({
    required this.callback,
    required this.index,
    this.chatUnreadCount = 0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70.h,
      padding: EdgeInsets.only(
        top: 5.h,
        // bottom: MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        border: BorderDirectional(
          top: BorderSide(
            color: Styles.primaryTextColor,
            width: 2,
          ),
        ),
        // color: Styles.primaryColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildItem(
            icon: Image.asset(
              'assets/images/chat.png',
              width: 24.w,
              height: 24.w,
            ),
            title: '聊天',
            idx: 0,
            cb: callback,
            badgeCount: chatUnreadCount,
          ),
          _buildItem(
            icon: Image.asset(
              'assets/images/article.png',
              width: 24.w,
              height: 24.w,
            ),
            title: '帖子',
            idx: 1,
            cb: callback,
          ),
          _buildItem(
            icon: Image.asset(
              'assets/images/breezemoon.png',
              width: 24.w,
              height: 24.w,
            ),
            title: '清风明月',
            idx: 2,
            cb: callback,
          ),
          _buildItem(
            icon: Image.asset(
              'assets/images/profile_circle.png',
              width: 24.w,
              height: 24.w,
            ),
            title: '我的',
            idx: 3,
            cb: callback,
          )
        ],
      ),
    );
  }

  Widget _buildItem({
    required Widget icon,
    required String title,
    required int idx,
    required Function(int) cb,
    int badgeCount = 0,
  }) {
    return GestureDetector(
      onTap: () => cb(idx),
      behavior: HitTestBehavior.translucent,
      child: SizedBox(
        width: 60.w,
        child: Opacity(
          opacity: index == idx ? 1 : 0.7,
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  icon,
                  if (badgeCount > 0)
                    Positioned(
                      key: const ValueKey('bottom_chat_unread_badge'),
                      right: -8.w,
                      top: -6.h,
                      child: Container(
                        constraints: BoxConstraints(minWidth: 16.w),
                        height: 16.w,
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          border: Border.all(
                            color: Styles.primaryTextColor,
                            width: 1.5.w,
                          ),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          badgeCount > 99 ? '99+' : badgeCount.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.bold,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              5.verticalSpace,
              Text(
                title,
                style: Styles.bottomTextStyle,
              ),
              Icon(
                Icons.arrow_drop_up_outlined,
                color:
                    index == idx ? Styles.primaryTextColor : Colors.transparent,
                size: 15.h,
              )
            ],
          ),
        ),
      ),
    );
  }
}
