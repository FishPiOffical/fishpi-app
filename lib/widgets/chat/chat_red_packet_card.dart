import 'package:fishpi/types/redpacket.dart';
import 'package:fishpi_app/core/chat/chat_red_packet_utils.dart';
import 'package:fishpi_app/res/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatRedPacketCard extends StatelessWidget {
  final RedPacketMessage redpacket;
  final bool isSelf;
  final VoidCallback? onTap;

  const ChatRedPacketCard({
    super.key,
    required this.redpacket,
    required this.isSelf,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress =
        redpacket.count <= 0 ? '待领取' : '已领 ${redpacket.got}/${redpacket.count}';
    const packetRed = Color(0xFFC83B28);
    const packetDarkRed = Color(0xFFA92B22);
    const packetGold = Color(0xFFFFD36A);
    const packetLightGold = Color(0xFFFFF1BF);
    return Container(
      width: 0.8.sw - 58.w,
      alignment: isSelf ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        key: const ValueKey('chat_red_packet_card'),
        onTap: onTap,
        child: Container(
          key: const ValueKey('chat_red_packet_wechat_style'),
          width: 226.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            border: Styles.commonBorder,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [packetRed, packetDarkRed],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(10.w),
                child: Row(
                  children: [
                    Container(
                      width: 38.w,
                      height: 38.w,
                      decoration: BoxDecoration(
                        color: packetGold,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.card_giftcard,
                        color: packetDarkRed,
                        size: 23.w,
                      ),
                    ),
                    9.horizontalSpace,
                    Expanded(
                      child: Text(
                        redpacket.msg.trim().isEmpty
                            ? ChatRedPacketUtils.defaultMessage
                            : redpacket.msg,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 1.h,
                color: Colors.white.withValues(alpha: .18),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(10.w, 8.h, 10.w, 9.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            ChatRedPacketUtils.typeName(redpacket.type),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: packetLightGold,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.monetization_on_outlined,
                          color: packetGold,
                          size: 15.w,
                        ),
                        3.horizontalSpace,
                        Text(
                          '${redpacket.money}',
                          style: TextStyle(
                            color: packetGold,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    5.verticalSpace,
                    Text(
                      progress,
                      key: const ValueKey('chat_red_packet_progress'),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: .9),
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
