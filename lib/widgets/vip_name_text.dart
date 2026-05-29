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
  final bool enableGradientAnimation;

  const VipNameText({
    this.userId,
    this.userName,
    this.fallback,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.vipService,
    this.enableGradientAnimation = true,
    super.key,
  });

  @override
  State<VipNameText> createState() => _VipNameTextState();
}

class _VipNameTextState extends State<VipNameText>
    with SingleTickerProviderStateMixin {
  VipNameStyle? _vipStyle;
  StreamSubscription<void>? _remarkSubscription;
  AnimationController? _gradientController;
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncGradientAnimation(disableAnimations: _disableAnimationsInContext);
  }

  @override
  void didUpdateWidget(covariant VipNameText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId ||
        oldWidget.userName != widget.userName ||
        oldWidget.vipService != widget.vipService) {
      _loadVipStyle();
    }
    if (oldWidget.enableGradientAnimation != widget.enableGradientAnimation) {
      _syncGradientAnimation(disableAnimations: _disableAnimationsInContext);
    }
  }

  @override
  void dispose() {
    _remarkSubscription?.cancel();
    _gradientController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayName = UserRemark.displayName(
      widget.userName,
      fallback: widget.fallback,
    );
    final baseStyle = widget.style ?? DefaultTextStyle.of(context).style;
    final vipStyle = _vipStyle;
    final style = vipStyle?.mergeInto(baseStyle) ?? baseStyle;
    final text = Text(
      displayName,
      key: const ValueKey('vip_name_text'),
      style: style,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
      textAlign: widget.textAlign,
    );

    final activeVipStyle = vipStyle;
    if (activeVipStyle == null || !activeVipStyle.hasGradient) return text;

    final controller = _gradientController;
    final disableAnimations = _disableAnimationsInContext;
    if (_shouldAnimateGradient && !disableAnimations && controller != null) {
      return RepaintBoundary(
        key: const ValueKey('vip_name_gradient_repaint_boundary'),
        child: AnimatedBuilder(
          key: const ValueKey('vip_name_gradient_animation'),
          animation: controller,
          builder: (context, _) => _buildGradientText(
            displayName: displayName,
            style: style,
            vipStyle: activeVipStyle,
            progress: controller.value,
          ),
        ),
      );
    }

    return _buildGradientText(
      displayName: displayName,
      style: style,
      vipStyle: activeVipStyle,
    );
  }

  Widget _buildGradientText({
    required String displayName,
    required TextStyle style,
    required VipNameStyle vipStyle,
    double? progress,
  }) {
    return ShaderMask(
      key: const ValueKey('vip_name_gradient_mask'),
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) {
        final width = bounds.width <= 0 ? 1.0 : bounds.width;
        final shaderRect = progress == null
            ? Rect.fromLTWH(0, 0, width, bounds.height)
            : Rect.fromLTWH(
                -width + progress * width * 2,
                0,
                width * 3,
                bounds.height,
              );
        return LinearGradient(
          colors: progress == null
              ? vipStyle.gradientColors
              : [
                  ...vipStyle.gradientColors,
                  ...vipStyle.gradientColors,
                ],
        ).createShader(shaderRect);
      },
      child: Text(
        displayName,
        key: const ValueKey('vip_name_text'),
        style: style.copyWith(
          color: Colors.white,
          decorationColor: style.decoration == TextDecoration.underline
              ? Colors.white
              : style.decorationColor,
        ),
        maxLines: widget.maxLines,
        overflow: widget.overflow,
        textAlign: widget.textAlign,
      ),
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
    _syncGradientAnimation(disableAnimations: _disableAnimationsInContext);
  }

  void _clearVipStyle() {
    if (!mounted) return;
    if (_vipStyle != null) {
      setState(() => _vipStyle = null);
    }
    _syncGradientAnimation();
  }

  bool get _shouldAnimateGradient {
    final vipStyle = _vipStyle;
    return widget.enableGradientAnimation &&
        vipStyle != null &&
        vipStyle.animatedGradient &&
        vipStyle.hasGradient;
  }

  bool get _disableAnimationsInContext =>
      MediaQuery.maybeOf(context)?.disableAnimations ?? false;

  void _syncGradientAnimation({bool disableAnimations = false}) {
    if (disableAnimations || !_shouldAnimateGradient) {
      _gradientController?.stop();
      return;
    }

    final controller = _gradientController ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );
    if (!controller.isAnimating) {
      controller.repeat();
    }
  }

  VipStyleService? _resolveService() {
    final injected = widget.vipService;
    if (injected != null) return injected;
    if (!Get.isRegistered<IMController>()) return null;
    return VipStyleService.shared(Get.find<IMController>().fishpi);
  }
}
