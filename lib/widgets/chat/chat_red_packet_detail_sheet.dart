import 'package:fishpi/types/redpacket.dart';
import 'package:fishpi_app/core/chat/chat_red_packet_utils.dart';
import 'package:fishpi_app/res/styles.dart';
import 'package:fishpi_app/widgets/pi_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ChatRedPacketDetailSheet extends StatelessWidget {
  final RedPacketInfo info;

  const ChatRedPacketDetailSheet({
    super.key,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    final base = info.info;
    return SafeArea(
      child: Container(
        width: 1.sw,
        constraints: BoxConstraints(maxHeight: .75.sh),
        padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 16.h),
        decoration: BoxDecoration(
          color: Styles.titleBarColor,
          border: Styles.commonBorder,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/images/redpack_icon.png',
                  width: 42.w,
                  height: 42.w,
                ),
                10.horizontalSpace,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        base.msg.trim().isEmpty
                            ? ChatRedPacketUtils.defaultMessage
                            : base.msg,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Styles.primaryTextColor,
                          fontSize: 19.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '已领 ${base.got}/${base.count}',
                        style: TextStyle(
                          color: const Color(0xFF777777),
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Icon(
                    Icons.close,
                    size: 22.w,
                    color: Styles.primaryTextColor,
                  ),
                ),
              ],
            ),
            14.verticalSpace,
            Flexible(
              child: info.who.isEmpty
                  ? Container(
                      height: 90.h,
                      alignment: Alignment.center,
                      child: Text(
                        '暂无领取记录',
                        style: TextStyle(
                          color: const Color(0xFF777777),
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: info.who.length,
                      itemBuilder: (context, index) {
                        final item = info.who[index];
                        return _buildGotItem(item);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGotItem(RedPacketGot item) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFE8E8E8),
            width: 1.w,
          ),
        ),
      ),
      child: Row(
        children: [
          PiAvatar(
            userName: item.userName,
            avatarURL: item.avatar,
            width: 34.w,
            height: 34.w,
          ),
          10.horizontalSpace,
          Expanded(
            child: Text(
              item.userName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Styles.primaryTextColor,
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            '${item.money} 积分',
            style: TextStyle(
              color: Styles.primaryTextColor,
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
