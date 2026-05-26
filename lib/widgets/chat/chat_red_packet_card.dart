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
    return Container(
      width: 0.8.sw - 58.w,
      alignment: isSelf ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        key: const ValueKey('chat_red_packet_card'),
        onTap: onTap,
        child: Container(
          width: 226.w,
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: const Color(0xFFFF5A2C),
            borderRadius: BorderRadius.circular(10.r),
            border: Styles.redpacketBorder,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/images/redpack_icon.png',
                    width: 36.w,
                    height: 36.w,
                  ),
                  8.horizontalSpace,
                  Expanded(
                    child: Text(
                      redpacket.msg.trim().isEmpty
                          ? ChatRedPacketUtils.defaultMessage
                          : redpacket.msg,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              8.verticalSpace,
              Container(
                height: 2.h,
                color: Styles.redpacketBorderColor,
              ),
              8.verticalSpace,
              Row(
                children: [
                  Expanded(
                    child: Text(
                      ChatRedPacketUtils.typeName(redpacket.type),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFFFFE88A),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Image.asset(
                    'assets/images/coin_line_white.png',
                    width: 14.w,
                    height: 10.w,
                  ),
                  4.horizontalSpace,
                  Text(
                    '${redpacket.money}',
                    style: TextStyle(
                      color: const Color(0xFFFFE88A),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              6.verticalSpace,
              Text(
                progress,
                key: const ValueKey('chat_red_packet_progress'),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
