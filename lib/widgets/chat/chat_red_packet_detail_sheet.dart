import 'package:fishpi/types/redpacket.dart';
import 'package:fishpi_app/core/chat/chat_red_packet_utils.dart';
import 'package:fishpi_app/res/styles.dart';
import 'package:fishpi_app/widgets/pi_avatar.dart';
import 'package:fishpi_app/widgets/vip_name_text.dart';
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
    const packetRed = Color(0xFFC83B28);
    const packetDarkRed = Color(0xFFA92B22);
    const packetGold = Color(0xFFFFD36A);
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
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                border: Styles.commonBorder,
                borderRadius: BorderRadius.circular(12.r),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [packetRed, packetDarkRed],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42.w,
                    height: 42.w,
                    decoration: BoxDecoration(
                      color: packetGold,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.card_giftcard,
                      color: packetDarkRed,
                      size: 25.w,
                    ),
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
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '已领 ${base.got}/${base.count}',
                          style: TextStyle(
                            color: packetGold,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 32.w,
                      height: 32.w,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.close,
                        size: 22.w,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
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
            child: VipNameText(
              userId: item.userId,
              userName: item.userName,
              fallback: item.userName,
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
