import 'package:fishpi_app/res/styles.dart';
import 'package:fishpi_app/utils/pi_utils.dart';
import 'package:fishpi_app/widgets/pi_avatar.dart';
import 'package:fishpi_app/widgets/vip_badge.dart';
import 'package:fishpi_app/widgets/vip_name_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../widgets/pi_menu_item.dart';
import 'mine_logic.dart';

class MinePage extends StatelessWidget {
  final MineLogic logic = Get.find<MineLogic>();

  MinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: logic.refreshUserInfo,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: Styles.pagePadding,
                  child: Column(
                    children: [
                      _buildUserCard(),
                      _buildErrorBanner(),
                      20.verticalSpace,
                      _buildMenuCard(),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildUserCard() {
    return Obx(
      () => Container(
        width: 1.sw - 32.w,
        constraints: BoxConstraints(minHeight: 185.h),
        padding: Styles.compactCardPadding,
        decoration: BoxDecoration(
          borderRadius: Styles.cardRadius,
          border: Styles.commonBorder,
          color: const Color(0xFF00C6AE),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      VipNameText(
                        userId: logic.userInfo.value.oId,
                        userName: logic.userInfo.value.userName,
                        fallback: logic.userInfo.value.name,
                        style: TextStyle(
                          color: Styles.primaryTextColor,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        logic.userInfo.value.intro,
                        style: TextStyle(
                          color: const Color(0xFFEFEFEF),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Text(
                            '# ${logic.userInfo.value.userNo}',
                            style: TextStyle(
                              color: const Color(0xFFEFEFEF),
                              fontSize: 17.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          10.horizontalSpace,
                          PiUtils.roleWidget(logic.userInfo.value.role),
                          10.horizontalSpace,
                          Flexible(
                            child: VipBadge(
                              userId: logic.userInfo.value.oId,
                              userName: logic.userInfo.value.userName,
                              showExpires: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PiAvatar(
                  userName: logic.userInfo.value.userName,
                  avatarURL: logic.userInfo.value.avatarURL,
                  width: 70.w,
                  height: 70.w,
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/coin.png',
                      width: 24.w,
                      height: 24.w,
                    ),
                    2.horizontalSpace,
                    Text(
                      logic.userInfo.value.point.toString(),
                      style: TextStyle(
                        color: Styles.primaryTextColor,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/location_red.png',
                      width: 24.w,
                      height: 24.w,
                    ),
                    2.horizontalSpace,
                    Text(
                      logic.userInfo.value.city,
                      style: TextStyle(
                        color: Styles.primaryTextColor,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Obx(() {
      final error = logic.errorText.value.trim();
      if (error.isEmpty) return const SizedBox.shrink();
      return Container(
        key: const ValueKey('mine_error_banner'),
        width: 1.sw - 32.w,
        margin: EdgeInsets.only(top: 10.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: Styles.actionRadius,
          border: Styles.commonBorder,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 18.w,
              color: Colors.redAccent,
            ),
            8.horizontalSpace,
            Expanded(
              child: Text(
                error,
                style: TextStyle(
                  color: Styles.secondaryTextColor,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ),
            8.horizontalSpace,
            GestureDetector(
              key: const ValueKey('mine_retry_button'),
              onTap: logic.refreshUserInfo,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Styles.primaryTextColor,
                  borderRadius: Styles.smallRadius,
                ),
                child: Text(
                  '重试',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMenuCard() {
    return Container(
      width: 1.sw - 32.w,
      padding: Styles.compactCardPadding,
      decoration: BoxDecoration(
        borderRadius: Styles.cardRadius,
        border: Styles.commonBorder,
        color: Colors.white,
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          PiMenuItem(
            title: '账号与安全',
            iconColor: Colors.redAccent,
            icon: Icons.security_outlined,
            onTap: logic.toAccountPage,
          ),
          PiMenuItem(
            title: 'VIP会员',
            iconColor: const Color(0xFFFFB300),
            icon: Icons.workspace_premium_outlined,
            rightText: '状态与样式',
            onTap: logic.toVipPage,
          ),
          PiMenuItem(
            title: '典藏馆',
            iconColor: Colors.lightBlueAccent,
            icon: Icons.dataset,
            onTap: logic.toCollectionPage,
          ),
          PiMenuItem(
            title: '设置',
            iconColor: Styles.primaryColor,
            icon: Icons.settings,
            onTap: logic.toSetUpPage,
          ),
        ],
      ),
    );
  }
}
