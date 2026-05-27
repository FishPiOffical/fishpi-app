import 'package:fishpi_app/core/controller/im.dart';
import 'package:fishpi_app/core/vip/vip_style_service.dart';
import 'package:fishpi_app/res/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class VipBadge extends StatefulWidget {
  final String? userId;
  final String? userName;
  final bool showExpires;
  final VipStyleService? vipService;

  const VipBadge({
    this.userId,
    this.userName,
    this.showExpires = false,
    this.vipService,
    super.key,
  });

  @override
  State<VipBadge> createState() => _VipBadgeState();
}

class _VipBadgeState extends State<VipBadge> {
  VipProfile? _profile;
  int _loadVersion = 0;

  @override
  void initState() {
    super.initState();
    _loadVipProfile();
  }

  @override
  void didUpdateWidget(covariant VipBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId ||
        oldWidget.userName != widget.userName ||
        oldWidget.vipService != widget.vipService) {
      _loadVipProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile;
    if (profile == null) return const SizedBox.shrink();

    final expiresText = widget.showExpires && profile.expiresText.isNotEmpty
        ? ' · ${profile.expiresText}到期'
        : '';
    final text = '${profile.levelName}$expiresText';

    return Container(
      key: const ValueKey('vip_badge'),
      constraints: BoxConstraints(maxWidth: 170.w),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE7A3),
        border: Styles.commonBorder,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Styles.primaryTextColor,
          fontSize: 11.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _loadVipProfile() async {
    final service = _resolveService();
    final version = ++_loadVersion;
    if (service == null) {
      _setProfile(null);
      return;
    }

    _setProfile(null);
    final profile = await service.loadProfile(
      userId: widget.userId,
      userName: widget.userName,
    );
    if (!mounted || version != _loadVersion) return;
    _setProfile(profile);
  }

  void _setProfile(VipProfile? profile) {
    if (!mounted || identical(_profile, profile)) return;
    setState(() => _profile = profile);
  }

  VipStyleService? _resolveService() {
    final injected = widget.vipService;
    if (injected != null) return injected;
    if (!Get.isRegistered<IMController>()) return null;
    return VipStyleService.shared(Get.find<IMController>().fishpi);
  }
}
