import 'package:fishpi_app/res/styles.dart';
import 'package:fishpi_app/widgets/vip_name_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ChatMessageActionSheet extends StatelessWidget {
  final String displayName;
  final String? userId;
  final String? userName;
  final bool canUseUserActions;
  final bool canBlockChatRoomUser;
  final VoidCallback onQuote;
  final VoidCallback onViewProfile;
  final VoidCallback onRemark;
  final VoidCallback onTransfer;
  final VoidCallback onBlock;

  const ChatMessageActionSheet({
    super.key,
    required this.displayName,
    this.userId,
    this.userName,
    required this.canUseUserActions,
    required this.canBlockChatRoomUser,
    required this.onQuote,
    required this.onViewProfile,
    required this.onRemark,
    required this.onTransfer,
    required this.onBlock,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: 1.sw,
        padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 16.h),
        decoration: BoxDecoration(
          color: Styles.titleBarColor,
          border: Styles.commonBorder,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            VipNameText(
              userId: userId,
              userName: userName,
              fallback: displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Styles.primaryTextColor,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            14.verticalSpace,
            _buildActionButton(
              key: const ValueKey('chat_quote_message_action'),
              icon: Icons.format_quote,
              text: '引用',
              onTap: onQuote,
            ),
            if (canUseUserActions) ...[
              10.verticalSpace,
              _buildActionButton(
                key: const ValueKey('chat_room_view_profile_action'),
                icon: Icons.person_outline,
                text: '查看主页',
                onTap: onViewProfile,
              ),
              10.verticalSpace,
              _buildActionButton(
                key: const ValueKey('chat_remark_user_action'),
                icon: Icons.edit_note_outlined,
                text: '备注',
                onTap: onRemark,
              ),
              10.verticalSpace,
              _buildActionButton(
                key: const ValueKey('chat_transfer_user_action'),
                icon: Icons.monetization_on_outlined,
                text: '转账',
                onTap: onTransfer,
              ),
              if (canBlockChatRoomUser) ...[
                10.verticalSpace,
                _buildActionButton(
                  key: const ValueKey('chat_room_block_user_action'),
                  icon: Icons.visibility_off_outlined,
                  text: '仅在聊天室屏蔽',
                  onTap: onBlock,
                ),
              ],
            ],
            10.verticalSpace,
            _buildActionButton(
              key: const ValueKey('chat_room_cancel_action'),
              icon: Icons.close,
              text: '取消',
              onTap: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required Key key,
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      key: key,
      onTap: onTap,
      child: Container(
        width: 1.sw - 32.w,
        height: 44.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Styles.commonBorder,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20.w, color: Styles.primaryTextColor),
            10.horizontalSpace,
            Text(
              text,
              style: TextStyle(
                color: Styles.primaryTextColor,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
