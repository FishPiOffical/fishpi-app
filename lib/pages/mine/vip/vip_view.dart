import 'package:fishpi/fishpi.dart';
import 'package:fishpi_app/core/vip/vip_style_service.dart';
import 'package:fishpi_app/res/styles.dart';
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
                  _buildNameStyleCard(),
                  14.verticalSpace,
                  _buildEditNoticeCard(),
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

  Widget _buildNameStyleCard() {
    final profile = logic.profile.value;
    final style = VipNameStyle.fromVipInfo(
      profile?.info ?? _emptyVipInfo(),
      now: logic.nowProvider(),
    );
    final color = style.color;

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
            child: Text(
              logic.previewName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: style.mergeInto(
                TextStyle(
                  color: Styles.primaryTextColor,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          14.verticalSpace,
          _buildInfoRow(
            '昵称颜色',
            logic.colorText,
            trailing: _buildColorSwatch(color),
          ),
          _buildDivider(),
          _buildInfoRow('粗体', logic.boldText),
          _buildDivider(),
          _buildInfoRow('下划线', logic.underlineText),
        ],
      ),
    );
  }

  Widget _buildEditNoticeCard() {
    return _buildCard(
      key: const ValueKey('vip_edit_notice_card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardTitle(
            icon: Icons.tune_outlined,
            title: '昵称样式修改',
          ),
          10.verticalSpace,
          Text(
            '当前已支持展示鱼派服务端返回的昵称颜色、粗体和下划线。修改入口会在服务端写入接口明确后接入。',
            style: TextStyle(
              color: Styles.secondaryTextColor,
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
          ),
          14.verticalSpace,
          Opacity(
            opacity: 0.55,
            child: _buildPrimaryButton(
              key: const ValueKey('vip_edit_disabled_button'),
              text: '暂不可编辑',
              icon: Icons.lock_outline,
              onTap: null,
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

  Widget _buildColorSwatch(Color? color) {
    return Container(
      key: const ValueKey('vip_color_swatch'),
      width: 22.w,
      height: 22.w,
      decoration: BoxDecoration(
        color: color ?? Styles.titleBarColor,
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
    return GestureDetector(
      key: key,
      onTap: onTap,
      child: Container(
        width: 1.sw - 60.w,
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
    );
  }

  UserVipInfo _emptyVipInfo() => UserVipInfo();
}
