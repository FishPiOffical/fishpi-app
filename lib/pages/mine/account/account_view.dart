import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../res/styles.dart';
import '../../../widgets/pi_avatar.dart';
import '../../../widgets/pi_menu_item.dart';
import '../../../widgets/pi_title_bar.dart';
import 'account_logic.dart';

class AccountPage extends StatelessWidget {
  AccountPage({super.key});

  final AccountLogic logic = Get.find<AccountLogic>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PiTitleBar.back(
        title: '账号与安全',
      ),
      body: Container(
        width: 1.sw,
        constraints: BoxConstraints(minHeight: 1.sh),
        color: Styles.titleBarColor,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          child: Column(
            children: [
              _buildMenuCard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context) {
    return Container(
      width: 1.sw - 32.w,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Styles.commonBorder,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          PiMenuItem(
            title: '修改头像',
            rightText: '相册上传',
            icon: Icons.photo_camera_back_outlined,
            iconColor: const Color(0xFF00C6AE),
            onTap: () => _showAvatarSheet(context),
          ),
          _buildDivider(),
          PiMenuItem(
            title: '修改用户信息',
            rightText: '昵称 简介',
            icon: Icons.badge_outlined,
            iconColor: Colors.blueAccent,
            onTap: logic.toEditInfo,
          ),
          _buildDivider(),
          PiMenuItem(
            title: '修改密码',
            rightText: '账号安全',
            icon: Icons.lock_reset_outlined,
            iconColor: Colors.redAccent,
            onTap: logic.toChangePassword,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 2,
      margin: EdgeInsets.symmetric(horizontal: 10.w),
      color: const Color(0xFFE8E8E8),
    );
  }

  void _showAvatarSheet(BuildContext context) {
    logic.selectedAvatarPath.value = '';
    Get.bottomSheet(
      SafeArea(
        child: Container(
          width: 1.sw,
          padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 16.h),
          decoration: BoxDecoration(
            color: Styles.titleBarColor,
            border: Styles.commonBorder,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
          ),
          child: Obx(
            () => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '修改头像',
                  style: TextStyle(
                    color: Styles.primaryTextColor,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                16.verticalSpace,
                _buildAvatarPreview(),
                18.verticalSpace,
                _buildSheetButton(
                  text: '从相册选择图片',
                  icon: Icons.photo_library_outlined,
                  isPrimary: false,
                  onTap: logic.isUploading.value ? null : logic.pickAvatar,
                ),
                12.verticalSpace,
                _buildSheetButton(
                  text: logic.isUploading.value ? '上传中...' : '确认上传',
                  icon: Icons.cloud_upload_outlined,
                  isPrimary: true,
                  onTap: logic.isUploading.value
                      ? null
                      : logic.uploadSelectedAvatar,
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  Widget _buildAvatarPreview() {
    final path = logic.selectedAvatarPath.value;
    return Container(
      width: 112.w,
      height: 112.w,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(56.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: path.isEmpty
          ? PiAvatar(
              userName: logic.avatarName,
              avatarURL: logic.userInfo.value.avatarURL,
              width: 112.w,
              height: 112.w,
            )
          : Image.file(
              File(path),
              fit: BoxFit.cover,
            ),
    );
  }

  Widget _buildSheetButton({
    required String text,
    required IconData icon,
    required bool isPrimary,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.62 : 1,
        child: Container(
          width: 1.sw - 32.w,
          height: 52.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isPrimary ? Colors.black : Colors.white,
            border: Border.all(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isPrimary ? Colors.white : Colors.black,
              ),
              8.horizontalSpace,
              Text(
                text,
                style: TextStyle(
                  color: isPrimary ? Colors.white : Colors.black,
                  fontSize: 16.sp,
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
