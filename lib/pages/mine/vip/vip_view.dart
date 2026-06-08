import 'package:fishpi/fishpi.dart';
import 'package:fishpi_app/core/vip/vip_style_service.dart';
import 'package:fishpi_app/res/styles.dart';
import 'package:fishpi_app/widgets/pi_input.dart';
import 'package:fishpi_app/widgets/pi_title_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'vip_logic.dart';

class VipPage extends StatelessWidget {
  VipPage({super.key});

  final VipLogic logic = Get.find<VipLogic>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PiTitleBar.back(title: 'VIP会员'),
      body: Obx(
        () => Container(
          width: 1.sw,
          constraints: BoxConstraints(minHeight: 1.sh),
          color: Styles.titleBarColor,
          child: RefreshIndicator(
            color: Colors.black,
            onRefresh: () => logic.loadVipInfo(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
              children: [
                if (logic.isLoading.value && !logic.hasProfile)
                  _buildLoadingCard()
                else if (logic.errorText.value.isNotEmpty && !logic.hasProfile)
                  _buildErrorCard()
                else ...[
                  _buildStatusCard(),
                  14.verticalSpace,
                  _buildMembershipLevelsCard(),
                  14.verticalSpace,
                  _buildNameStyleCard(context),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return _buildCard(
      key: const ValueKey('vip_loading_card'),
      child: SizedBox(
        height: 150.h,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return _buildCard(
      key: const ValueKey('vip_error_card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardTitle(
            icon: Icons.cloud_off_outlined,
            title: 'VIP信息加载失败',
          ),
          10.verticalSpace,
          Text(
            logic.errorText.value,
            style: TextStyle(
              color: Styles.secondaryTextColor,
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              height: 1.35,
            ),
          ),
          14.verticalSpace,
          _buildPrimaryButton(
            key: const ValueKey('vip_retry_button'),
            text: '重新加载',
            icon: Icons.refresh,
            onTap: () => logic.loadVipInfo(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final active = logic.isVipActive;
    return _buildCard(
      key: const ValueKey('vip_status_card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50.w,
                height: 50.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: active ? Styles.primaryColor : Colors.white,
                  border: Styles.commonBorder,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(
                  Icons.workspace_premium_outlined,
                  color: Styles.primaryTextColor,
                  size: 28.w,
                ),
              ),
              12.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            logic.levelText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Styles.primaryTextColor,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        _buildStatusChip(logic.statusText),
                      ],
                    ),
                    6.verticalSpace,
                    Text(
                      logic.expiresText,
                      style: TextStyle(
                        color: Styles.secondaryTextColor,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          14.verticalSpace,
          _buildInfoRow('联合会员', logic.jointVip ? '是' : '否'),
          _buildDivider(),
          _buildInfoRow('会员勋章', logic.medalEnabled ? '已开启' : '未开启'),
          _buildDivider(),
          _buildInfoRow('自动签到', logic.autoCheckinText),
        ],
      ),
    );
  }

  Widget _buildNameStyleCard(BuildContext context) {
    final profile = logic.profile.value;
    final style = VipNameStyle.fromVipInfo(
      profile?.info ?? _emptyVipInfo(),
      now: logic.nowProvider(),
    );
    final color = style.color;
    final gradientColors = style.gradientColors;

    return _buildCard(
      key: const ValueKey('vip_name_style_card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardTitle(
            icon: Icons.format_paint_outlined,
            title: '昵称样式',
          ),
          12.verticalSpace,
          Container(
            key: const ValueKey('vip_name_preview'),
            width: 1.sw - 60.w,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Styles.titleBarColor,
              border: Styles.commonBorder,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: _buildVipNamePreview(
              text: logic.previewName,
              style: style,
            ),
          ),
          14.verticalSpace,
          _buildInfoRow(
            '昵称颜色',
            logic.colorText,
            trailing: _buildColorSwatch(
              color: color,
              gradientColors: gradientColors,
            ),
          ),
          _buildDivider(),
          _buildInfoRow('粗体', logic.boldText),
          _buildDivider(),
          _buildInfoRow('下划线', logic.underlineText),
          _buildDivider(),
          _buildInfoRow('会员勋章', logic.medalEnabled ? '已开启' : '未开启'),
          12.verticalSpace,
          _buildPrimaryButton(
            key: const ValueKey('vip_edit_style_button'),
            text: logic.editButtonText,
            icon: logic.canEditStyle ? Icons.edit_outlined : Icons.lock_outline,
            onTap: logic.canEditStyle ? () => _openStyleEditor(context) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildMembershipLevelsCard() {
    final levels = logic.membershipLevels;
    return _buildCard(
      key: const ValueKey('vip_membership_levels_card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardTitle(
            icon: Icons.local_activity_outlined,
            title: '开通与续费',
          ),
          12.verticalSpace,
          if (logic.isLoadingLevels.value && levels.isEmpty)
            SizedBox(
              height: 72.h,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.black),
              ),
            )
          else if (levels.isEmpty)
            _buildEmptyLevels()
          else
            ...levels.map(_buildMembershipLevelItem),
        ],
      ),
    );
  }

  Widget _buildEmptyLevels() {
    final error = logic.levelsErrorText.value.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          error.isEmpty ? '暂无可购买套餐' : error,
          style: TextStyle(
            color: Styles.secondaryTextColor,
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
            height: 1.35,
          ),
        ),
        12.verticalSpace,
        _buildPrimaryButton(
          key: const ValueKey('vip_levels_reload_button'),
          text: '刷新套餐',
          icon: Icons.refresh,
          onTap: () => logic.loadMembershipLevels(),
        ),
      ],
    );
  }

  Widget _buildMembershipLevelItem(MembershipLevel level) {
    final isOpening = logic.isOpeningMembership.value;
    return Container(
      key: ValueKey('vip_membership_level_${level.oId}'),
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Styles.titleBarColor,
        border: Styles.commonBorder,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      logic.membershipLevelTitle(level),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Styles.primaryTextColor,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    4.verticalSpace,
                    Text(
                      logic.membershipLevelMeta(level),
                      style: TextStyle(
                        color: Styles.secondaryTextColor,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              10.horizontalSpace,
              _buildSmallActionButton(
                key: ValueKey('vip_membership_open_${level.oId}'),
                text: logic.isVipActive ? '续费' : '开通',
                onTap: isOpening ? null : () => logic.openMembership(level),
              ),
            ],
          ),
          8.verticalSpace,
          Text(
            logic.membershipBenefitsText(level),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Styles.secondaryTextColor,
              fontSize: 12.sp,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required Key key,
    required Widget child,
  }) {
    return Container(
      key: key,
      width: 1.sw - 32.w,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Styles.commonBorder,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: child,
    );
  }

  Widget _buildCardTitle({
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Icon(icon, color: Styles.primaryTextColor, size: 20.w),
        8.horizontalSpace,
        Text(
          title,
          style: TextStyle(
            color: Styles.primaryTextColor,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String text) {
    return Container(
      key: const ValueKey('vip_status_chip'),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Styles.commonBorder,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Styles.primaryTextColor,
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    Widget? trailing,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 9.h),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Styles.secondaryTextColor,
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          12.horizontalSpace,
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Styles.primaryTextColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (trailing != null) ...[
            8.horizontalSpace,
            trailing,
          ],
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: const Color(0xFFE8E8E8),
    );
  }

  Widget _buildVipNamePreview({
    required String text,
    required VipNameStyle style,
  }) {
    final textStyle = style.mergeInto(
      TextStyle(
        color: Styles.primaryTextColor,
        fontSize: 20.sp,
        fontWeight: FontWeight.bold,
      ),
    );
    if (!style.hasGradient) {
      return Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: textStyle,
      );
    }

    return ShaderMask(
      key: const ValueKey('vip_name_preview_gradient_mask'),
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => LinearGradient(
        colors: style.gradientColors,
      ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: textStyle.copyWith(
          color: Colors.white,
          decorationColor: textStyle.decoration == TextDecoration.underline
              ? Colors.white
              : textStyle.decorationColor,
        ),
      ),
    );
  }

  Widget _buildColorSwatch({
    required Color? color,
    required List<Color> gradientColors,
  }) {
    return Container(
      key: const ValueKey('vip_color_swatch'),
      width: 22.w,
      height: 22.w,
      decoration: BoxDecoration(
        color:
            gradientColors.length >= 2 ? null : color ?? Styles.titleBarColor,
        gradient: gradientColors.length >= 2
            ? LinearGradient(colors: gradientColors)
            : null,
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(7.r),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required Key key,
    required String text,
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    final enabled = onTap != null;
    return GestureDetector(
      key: key,
      onTap: onTap,
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: Container(
          width: double.infinity,
          height: 44.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 18.w),
              6.horizontalSpace,
              Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallActionButton({
    required Key key,
    required String text,
    required VoidCallback? onTap,
  }) {
    final enabled = onTap != null;
    return GestureDetector(
      key: key,
      onTap: onTap,
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: Container(
          constraints: BoxConstraints(minWidth: 58.w),
          height: 34.h,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _openStyleEditor(BuildContext context) {
    logic.prepareEditConfig();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Obx(
          () => Padding(
            padding: EdgeInsets.only(
              left: 12.w,
              right: 12.w,
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 12.h,
            ),
            child: Container(
              key: const ValueKey('vip_style_editor_sheet'),
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: Styles.titleBarColor,
                border: Styles.commonBorder,
                borderRadius: BorderRadius.circular(18.r),
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '编辑昵称样式',
                              style: TextStyle(
                                color: Styles.primaryTextColor,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(sheetContext),
                            child: Icon(
                              Icons.close,
                              size: 22.w,
                              color: Styles.primaryTextColor,
                            ),
                          ),
                        ],
                      ),
                      12.verticalSpace,
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12.w),
                        decoration: Styles.cardDecoration(),
                        child: _buildVipNamePreview(
                          text: logic.previewName,
                          style: logic.editingPreviewStyle,
                        ),
                      ),
                      12.verticalSpace,
                      SizedBox(
                        height: Styles.compactButtonHeight,
                        child: PiInput(
                          key: const ValueKey('vip_style_color_input'),
                          controller: logic.editColorController,
                          hintText: '昵称颜色，如 #FFAA00',
                          textAlign: TextAlign.left,
                          onInputChanged: logic.updateEditColor,
                        ),
                      ),
                      6.verticalSpace,
                      Text(
                        '支持 #RRGGBB、RRGGBB 或 linear-gradient(...)；留空为默认样式。',
                        style: TextStyle(
                          color: Styles.secondaryTextColor,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          height: 1.35,
                        ),
                      ),
                      12.verticalSpace,
                      _buildSwitchRow(
                        key: const ValueKey('vip_style_bold_switch'),
                        title: '昵称加粗',
                        value: logic.editBold.value,
                        onChanged: (value) => logic.editBold.value = value,
                      ),
                      8.verticalSpace,
                      _buildSwitchRow(
                        key: const ValueKey('vip_style_underline_switch'),
                        title: '昵称下划线',
                        value: logic.editUnderline.value,
                        onChanged: (value) => logic.editUnderline.value = value,
                      ),
                      8.verticalSpace,
                      _buildSwitchRow(
                        key: const ValueKey('vip_style_metal_switch'),
                        title: '显示会员勋章',
                        value: logic.editMetal.value,
                        onChanged: (value) => logic.editMetal.value = value,
                      ),
                      8.verticalSpace,
                      _buildSwitchRow(
                        key: const ValueKey('vip_style_auto_checkin_switch'),
                        title: '自动签到',
                        value: logic.editAutoCheckin.value,
                        onChanged: (value) =>
                            logic.editAutoCheckin.value = value,
                      ),
                      14.verticalSpace,
                      _buildPrimaryButton(
                        key: const ValueKey('vip_style_save_button'),
                        text: logic.isSavingConfig.value ? '保存中' : '保存样式',
                        icon: Icons.check,
                        onTap: logic.isSavingConfig.value
                            ? null
                            : () async {
                                final ok = await logic.saveMembershipConfig();
                                if (ok && sheetContext.mounted) {
                                  Navigator.pop(sheetContext);
                                }
                              },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSwitchRow({
    required Key key,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      key: key,
      behavior: HitTestBehavior.translucent,
      onTap: () => onChanged(!value),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: Styles.cardDecoration(),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: Styles.primaryTextColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Switch(
              value: value,
              activeThumbColor: Styles.primaryColor,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  UserVipInfo _emptyVipInfo() => UserVipInfo();
}
