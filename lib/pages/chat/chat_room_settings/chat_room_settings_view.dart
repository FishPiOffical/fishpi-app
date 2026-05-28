import 'package:fishpi/types/redpacket.dart';
import 'package:fishpi_app/core/sql/chat_room_block_list.dart';
import 'package:fishpi_app/core/sql/chat_room_extension_store.dart';
import 'package:fishpi_app/res/styles.dart';
import 'package:fishpi_app/routers/navigator.dart';
import 'package:fishpi_app/widgets/pi_avatar.dart';
import 'package:fishpi_app/widgets/pi_title_bar.dart';
import 'package:fishpi_app/widgets/vip_badge.dart';
import 'package:fishpi_app/widgets/vip_name_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'chat_room_settings_logic.dart';

enum ChatRoomSettingsPageMode {
  menu,
  autoGrab,
  extensions,
  blockList,
}

class ChatRoomSettingsPage extends GetView<ChatRoomSettingsLogic> {
  const ChatRoomSettingsPage({
    this.mode = ChatRoomSettingsPageMode.menu,
    super.key,
  });

  final ChatRoomSettingsPageMode mode;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: PiTitleBar.back(title: _pageTitle),
        body: Container(
          width: 1.sw,
          constraints: BoxConstraints(minHeight: 1.sh),
          color: Styles.titleBarColor,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
            child: Column(
              children: _buildPageChildren(),
            ),
          ),
        ),
      ),
    );
  }

  String get _pageTitle {
    switch (mode) {
      case ChatRoomSettingsPageMode.autoGrab:
        return '自动抢红包';
      case ChatRoomSettingsPageMode.extensions:
        return '扩展插件';
      case ChatRoomSettingsPageMode.blockList:
        return '聊天室屏蔽';
      case ChatRoomSettingsPageMode.menu:
        return '聊天室设置';
    }
  }

  List<Widget> _buildPageChildren() {
    switch (mode) {
      case ChatRoomSettingsPageMode.autoGrab:
        return [_buildAutoGrabSection()];
      case ChatRoomSettingsPageMode.extensions:
        return [_buildExtensionSection()];
      case ChatRoomSettingsPageMode.blockList:
        return [
          _buildBlockedSection(),
          14.verticalSpace,
          _buildRecentSection(),
        ];
      case ChatRoomSettingsPageMode.menu:
        return [_buildMenuSection()];
    }
  }

  Widget _buildMenuSection() {
    final config = controller.autoGrabConfig.value;
    return Container(
      key: const ValueKey('chat_room_settings_menu'),
      width: 1.sw - 32.w,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Styles.commonBorder,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          _buildSettingsEntry(
            key: const ValueKey('chat_room_auto_grab_entry'),
            icon: Icons.redeem_outlined,
            title: '自动抢红包',
            subtitle: config.enabled
                ? '已开启 · 延迟 ${config.delaySeconds} 秒 · 已领 ${config.totalPoint} 积分'
                : '未开启 · 可设置延迟、类型和猜拳手势',
            onTap: AppNavigator.toChatRoomAutoGrabSettings,
          ),
          _buildMenuDivider(),
          _buildSettingsEntry(
            key: const ValueKey('chat_room_extension_entry'),
            icon: Icons.extension_outlined,
            title: '扩展插件',
            subtitle:
                '已启用 ${controller.enabledExtensionCount} / 共 ${controller.extensions.length} 个',
            onTap: AppNavigator.toChatRoomExtensions,
          ),
          _buildMenuDivider(),
          _buildSettingsEntry(
            key: const ValueKey('chat_room_block_entry'),
            icon: Icons.person_off_outlined,
            title: '聊天室屏蔽',
            subtitle:
                '已屏蔽 ${controller.blockedUsers.length} 人 · 最近候选 ${controller.recentUsers.length} 人',
            onTap: AppNavigator.toChatRoomBlockList,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsEntry({
    required Key key,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      key: key,
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        child: Row(
          children: [
            Container(
              width: 42.w,
              height: 42.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Styles.primaryColor,
                border: Styles.commonBorder,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                icon,
                color: Styles.primaryTextColor,
                size: 22.w,
              ),
            ),
            12.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Styles.primaryTextColor,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  4.verticalSpace,
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: const Color(0xFF777777),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Styles.primaryTextColor,
              size: 22.w,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuDivider() {
    return Padding(
      padding: EdgeInsets.only(left: 68.w),
      child: Divider(
        height: 1,
        color: const Color(0xFFE8E8E8),
        thickness: 1.w,
      ),
    );
  }

  Widget _buildAutoGrabSection() {
    final config = controller.autoGrabConfig.value;
    final hasRockPaperScissors =
        config.enabledTypes.contains(RedPacketType.RockPaperScissors);
    return Container(
      key: const ValueKey('chat_room_auto_grab_section'),
      width: 1.sw - 32.w,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Styles.commonBorder,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '自动抢红包',
                  style: TextStyle(
                    color: Styles.primaryTextColor,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Switch(
                key: const ValueKey('auto_grab_switch'),
                value: config.enabled,
                activeThumbColor: Styles.primaryColor,
                activeTrackColor: Styles.primaryTextColor,
                onChanged: controller.toggleAutoGrab,
              ),
            ],
          ),
          4.verticalSpace,
          Text(
            '新红包出现后按设置延迟自动领取，不弹出领取详情。',
            style: TextStyle(
              color: Styles.secondaryTextColor,
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          14.verticalSpace,
          _buildAutoGrabDelay(config.delaySeconds),
          14.verticalSpace,
          Text(
            '红包类型',
            style: TextStyle(
              color: Styles.primaryTextColor,
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          8.verticalSpace,
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              for (final type in controller.redPacketTypes)
                _buildTypeChip(type: type),
            ],
          ),
          if (hasRockPaperScissors) ...[
            14.verticalSpace,
            Text(
              '猜拳手势',
              style: TextStyle(
                color: Styles.primaryTextColor,
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            8.verticalSpace,
            Row(
              children: [
                for (final gesture in GestureType.values) ...[
                  _buildGestureChip(gesture),
                  8.horizontalSpace,
                ],
              ],
            ),
          ],
          14.verticalSpace,
          Container(
            key: const ValueKey('auto_grab_stats'),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Styles.titleBarColor,
              border: Styles.commonBorder,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '已领 ${config.totalPoint} 积分 / ${config.successCount} 次',
                    style: TextStyle(
                      color: Styles.primaryTextColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildOutlineButton(
                  key: const ValueKey('auto_grab_reset_stats_button'),
                  text: '重置',
                  icon: Icons.refresh,
                  onTap: controller.resetAutoGrabStats,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAutoGrabDelay(int delaySeconds) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '延迟领取',
            style: TextStyle(
              color: Styles.primaryTextColor,
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _buildCounterButton(
          key: const ValueKey('auto_grab_delay_decrease'),
          icon: Icons.remove,
          onTap: controller.decreaseDelay,
        ),
        Container(
          key: const ValueKey('auto_grab_delay_value'),
          width: 72.w,
          height: 34.w,
          alignment: Alignment.center,
          margin: EdgeInsets.symmetric(horizontal: 8.w),
          decoration: BoxDecoration(
            color: Styles.titleBarColor,
            border: Styles.commonBorder,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Text(
            '$delaySeconds 秒',
            style: TextStyle(
              color: Styles.primaryTextColor,
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _buildCounterButton(
          key: const ValueKey('auto_grab_delay_increase'),
          icon: Icons.add,
          onTap: controller.increaseDelay,
        ),
      ],
    );
  }

  Widget _buildTypeChip({required String type}) {
    final selected = controller.isAutoGrabTypeSelected(type);
    return GestureDetector(
      key: ValueKey('auto_grab_type_$type'),
      onTap: () => controller.toggleAutoGrabType(type),
      child: Container(
        height: 34.w,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? Styles.primaryTextColor : Colors.white,
          border: Styles.commonBorder,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Text(
          controller.redPacketTypeName(type),
          style: TextStyle(
            color: selected ? Colors.white : Styles.primaryTextColor,
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildGestureChip(GestureType gesture) {
    final selected = controller.autoGrabConfig.value.gesture == gesture;
    return Expanded(
      child: GestureDetector(
        key: ValueKey('auto_grab_gesture_${gesture.name}'),
        onTap: () => controller.selectAutoGrabGesture(gesture),
        child: Container(
          height: 34.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Styles.primaryTextColor : Colors.white,
            border: Styles.commonBorder,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Text(
            controller.gestureName(gesture),
            style: TextStyle(
              color: selected ? Colors.white : Styles.primaryTextColor,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
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

  Widget _buildExtensionSection() {
    return Container(
      key: const ValueKey('chat_room_extension_section'),
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
            title: '扩展插件',
            actionText: '新增',
            actionIcon: Icons.add,
            actionKey: const ValueKey('chat_room_extension_add_button'),
            onActionTap: controller.openNewExtensionEditor,
          ),
          6.verticalSpace,
          Row(
            children: [
              Expanded(
                child: Text(
                  '已启用 ${controller.enabledExtensionCount} / 共 ${controller.extensions.length} 个',
                  style: TextStyle(
                    color: const Color(0xFF777777),
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildOutlineButton(
                key: const ValueKey('chat_room_extension_import_button'),
                text: '导入',
                icon: Icons.content_paste,
                onTap: controller.importExtensionsFromClipboard,
              ),
              8.horizontalSpace,
              _buildOutlineButton(
                key: const ValueKey('chat_room_extension_export_button'),
                text: '导出',
                icon: Icons.copy,
                onTap: controller.exportExtensions,
              ),
            ],
          ),
          14.verticalSpace,
          _buildBuiltInTemplateList(),
          if (controller.extensions.isEmpty)
            Container(
              key: const ValueKey('chat_room_extension_empty'),
              height: 86.h,
              alignment: Alignment.center,
              child: Text(
                '暂无扩展插件',
                style: TextStyle(
                  color: const Color(0xFF777777),
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else ...[
            8.verticalSpace,
            for (final extension in controller.extensions)
              _buildExtensionRow(extension),
          ],
        ],
      ),
    );
  }

  Widget _buildBuiltInTemplateList() {
    return Container(
      key: const ValueKey('chat_room_extension_template_section'),
      decoration: BoxDecoration(
        color: Styles.titleBarColor,
        border: Styles.commonBorder,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 6.h),
            child: Row(
              children: [
                Icon(
                  Icons.auto_awesome_outlined,
                  color: Styles.primaryTextColor,
                  size: 18.w,
                ),
                6.horizontalSpace,
                Expanded(
                  child: Text(
                    '模板库',
                    style: TextStyle(
                      color: Styles.primaryTextColor,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '一键添加后可编辑',
                  style: TextStyle(
                    color: Styles.secondaryTextColor,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          for (var i = 0; i < controller.builtInTemplates.length; i++) ...[
            _buildTemplateRow(controller.builtInTemplates[i]),
            if (i != controller.builtInTemplates.length - 1)
              Padding(
                padding: EdgeInsets.only(left: 58.w),
                child: Divider(
                  height: 1,
                  color: const Color(0xFFDCDCDC),
                  thickness: 1.w,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildTemplateRow(ChatRoomExtensionTemplate template) {
    final installed = controller.isBuiltInTemplateInstalled(template);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 9.h),
      child: Row(
        children: [
          Container(
            width: 38.w,
            height: 38.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Styles.commonBorder,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              template.extension.icon,
              style: TextStyle(
                color: Styles.primaryTextColor,
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          10.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  template.name,
                  style: TextStyle(
                    color: Styles.primaryTextColor,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                3.verticalSpace,
                Text(
                  template.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF777777),
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          8.horizontalSpace,
          _buildOutlineButton(
            key: ValueKey('chat_room_extension_template_${template.id}'),
            text: installed ? '已添加' : '添加',
            icon: installed ? Icons.check : Icons.add,
            onTap: () => controller.addBuiltInTemplate(template),
          ),
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
    Key? actionKey,
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
            key: actionKey ?? const ValueKey('chat_room_manual_add_button'),
            text: actionText,
            icon: actionIcon,
            onTap: onActionTap,
          ),
      ],
    );
  }

  Widget _buildExtensionRow(ChatRoomExtension extension) {
    return Container(
      key: ValueKey('chat_room_extension_${extension.id}'),
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
          Container(
            width: 38.w,
            height: 38.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Styles.primaryColor,
              border: Styles.commonBorder,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              extension.icon.trim().isEmpty ? '扩' : extension.icon.trim(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Styles.primaryTextColor,
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          10.horizontalSpace,
          Expanded(
            child: GestureDetector(
              onTap: () => controller.openExtensionEditor(extension),
              behavior: HitTestBehavior.translucent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    extension.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Styles.primaryTextColor,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  2.verticalSpace,
                  Text(
                    extension.fields.isEmpty
                        ? '无需参数'
                        : '${extension.fields.length} 个参数',
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
          ),
          Switch(
            key: ValueKey('chat_room_extension_switch_${extension.id}'),
            value: extension.enabled,
            activeThumbColor: Styles.primaryColor,
            onChanged: (value) => controller.toggleExtension(extension, value),
          ),
          _buildIconAction(
            key: ValueKey('chat_room_extension_copy_${extension.id}'),
            icon: Icons.copy,
            onTap: () => controller.duplicateExtension(extension),
          ),
          _buildIconAction(
            key: ValueKey('chat_room_extension_delete_${extension.id}'),
            icon: Icons.delete_outline,
            onTap: () => controller.deleteExtension(extension),
          ),
        ],
      ),
    );
  }

  Widget _buildIconAction({
    required Key key,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      key: key,
      onTap: onTap,
      child: SizedBox(
        width: 30.w,
        height: 34.w,
        child: Icon(icon, size: 18.w, color: Styles.primaryTextColor),
      ),
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
                VipNameText(
                  userId: user.oId,
                  userName: user.userName,
                  fallback: displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Styles.primaryTextColor,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                4.verticalSpace,
                VipBadge(
                  userId: user.oId,
                  userName: user.userName,
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

  Widget _buildCounterButton({
    Key? key,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      key: key,
      onTap: onTap,
      child: Container(
        width: 34.w,
        height: 34.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Styles.commonBorder,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(
          icon,
          size: 18.w,
          color: Styles.primaryTextColor,
        ),
      ),
    );
  }
}
