import 'package:fishpi_app/core/sql/chat_room_block_list.dart';
import 'package:fishpi_app/res/styles.dart';
import 'package:fishpi_app/widgets/pi_avatar.dart';
import 'package:fishpi_app/widgets/pi_title_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'chat_room_settings_logic.dart';

class ChatRoomSettingsPage extends GetView<ChatRoomSettingsLogic> {
  const ChatRoomSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: PiTitleBar.back(title: '聊天室屏蔽'),
        body: Container(
          width: 1.sw,
          constraints: BoxConstraints(minHeight: 1.sh),
          color: Styles.titleBarColor,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
            child: Column(
              children: [
                _buildBlockedSection(),
                14.verticalSpace,
                _buildRecentSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBlockedSection() {
    return Container(
      width: 1.sw - 32.w,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Styles.commonBorder,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          _buildSectionHeader(
            title: '已屏蔽用户',
            actionText: '添加用户',
            actionIcon: Icons.person_add_alt_1_outlined,
            onActionTap: controller.openManualAddEditor,
          ),
          if (controller.blockedUsers.isEmpty)
            Container(
              key: const ValueKey('chat_room_block_list_empty'),
              height: 86.h,
              alignment: Alignment.center,
              child: Text(
                '暂无屏蔽用户',
                style: TextStyle(
                  color: const Color(0xFF777777),
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else ...[
            8.verticalSpace,
            for (final user in controller.blockedUsers)
              _buildUserRow(
                user: user,
                buttonText: '移出',
                onTap: () => controller.removeUser(user),
              ),
            10.verticalSpace,
            _buildOutlineButton(
              key: const ValueKey('chat_room_block_clear_button'),
              text: '清空屏蔽',
              icon: Icons.delete_outline,
              onTap: controller.clearBlockedUsers,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecentSection() {
    return Container(
      key: const ValueKey('chat_room_recent_users_section'),
      width: 1.sw - 32.w,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Styles.commonBorder,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          _buildSectionHeader(title: '最近发言用户'),
          if (controller.recentUsers.isEmpty)
            Container(
              height: 76.h,
              alignment: Alignment.center,
              child: Text(
                '暂无可添加用户',
                style: TextStyle(
                  color: const Color(0xFF777777),
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else ...[
            8.verticalSpace,
            for (final user in controller.recentUsers)
              _buildUserRow(
                user: user,
                buttonText: '屏蔽',
                onTap: () => controller.blockUser(user),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    String? actionText,
    IconData? actionIcon,
    VoidCallback? onActionTap,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: Styles.primaryTextColor,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (actionText != null)
          _buildOutlineButton(
            key: const ValueKey('chat_room_manual_add_button'),
            text: actionText,
            icon: actionIcon,
            onTap: onActionTap,
          ),
      ],
    );
  }

  Widget _buildUserRow({
    required ChatRoomBlockedUser user,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    final rawDisplayName = controller.displayNameFor(user);
    final displayName = rawDisplayName.trim().isEmpty ? '未知用户' : rawDisplayName;
    final userName = user.userName?.trim() ?? '';

    return Container(
      key: ValueKey('chat_room_block_user_${user.matchKey}'),
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
            userName: user.userName,
            avatarURL: user.avatarURL,
            width: 36.w,
            height: 36.w,
          ),
          10.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Styles.primaryTextColor,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (userName.isNotEmpty && userName != displayName)
                  Text(
                    userName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: const Color(0xFF777777),
                      fontSize: 12.sp,
                    ),
                  ),
              ],
            ),
          ),
          10.horizontalSpace,
          _buildPrimaryButton(
            text: buttonText,
            onTap: onTap,
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 68.w,
        height: 34.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Styles.primaryColor,
          border: Styles.commonBorder,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Styles.primaryTextColor,
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildOutlineButton({
    Key? key,
    required String text,
    IconData? icon,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      key: key,
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(minHeight: 34.w),
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Styles.commonBorder,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 17.w, color: Styles.primaryTextColor),
              4.horizontalSpace,
            ],
            Text(
              text,
              style: TextStyle(
                color: Styles.primaryTextColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
