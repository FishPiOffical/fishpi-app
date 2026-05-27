import 'dart:async';

import 'package:fishpi_app/core/controller/im.dart';
import 'package:fishpi_app/core/sql/user_remark.dart';
import 'package:fishpi_app/core/vip/vip_style_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VipNameText extends StatefulWidget {
  final String? userId;
  final String? userName;
  final String? fallback;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  final VipStyleService? vipService;

  const VipNameText({
    this.userId,
    this.userName,
    this.fallback,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.vipService,
    super.key,
  });

  @override
  State<VipNameText> createState() => _VipNameTextState();
}

class _VipNameTextState extends State<VipNameText> {
  VipNameStyle? _vipStyle;
  StreamSubscription<void>? _remarkSubscription;
  int _loadVersion = 0;

  @override
  void initState() {
    super.initState();
    _remarkSubscription = UserRemark.changes.listen((_) {
      if (mounted) setState(() {});
    });
    _loadVipStyle();
  }

  @override
  void didUpdateWidget(covariant VipNameText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId ||
        oldWidget.userName != widget.userName ||
        oldWidget.vipService != widget.vipService) {
      _loadVipStyle();
    }
  }

  @override
  void dispose() {
    _remarkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayName = UserRemark.displayName(
      widget.userName,
      fallback: widget.fallback,
    );
    final baseStyle = widget.style ?? DefaultTextStyle.of(context).style;
    final style = _vipStyle?.mergeInto(baseStyle) ?? baseStyle;

    return Text(
      displayName,
      key: const ValueKey('vip_name_text'),
      style: style,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
      textAlign: widget.textAlign,
    );
  }

  Future<void> _loadVipStyle() async {
    final service = _resolveService();
    final version = ++_loadVersion;
    if (service == null) {
      _clearVipStyle();
      return;
    }

    _clearVipStyle();
    final style = await service.load(
      userId: widget.userId,
      userName: widget.userName,
    );
    if (!mounted || version != _loadVersion) return;
    setState(() => _vipStyle = style);
  }

  void _clearVipStyle() {
    if (_vipStyle == null || !mounted) return;
    setState(() => _vipStyle = null);
  }

  VipStyleService? _resolveService() {
    final injected = widget.vipService;
    if (injected != null) return injected;
    if (!Get.isRegistered<IMController>()) return null;
    return VipStyleService.shared(Get.find<IMController>().fishpi);
  }
}
