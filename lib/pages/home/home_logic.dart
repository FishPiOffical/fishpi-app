import 'dart:async';

import 'package:fishpi_app/core/controller/im.dart';
import 'package:fishpi_app/pages/breezemoons/breezemoons_logic.dart';
import 'package:fishpi_app/pages/forum/forum_logic.dart';
import 'package:fishpi_app/utils/pi_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class HomeLogic extends GetxController {
  HomeLogic({
    IMController? imController,
    Future<void> Function(String token)? chatInitializer,
    Duration forumPreloadDelay = const Duration(milliseconds: 600),
    Duration breezemoonsPreloadDelay = const Duration(milliseconds: 1200),
    VoidCallback? forumPreloader,
    VoidCallback? breezemoonsPreloader,
  })  : _imController = imController,
        _chatInitializer = chatInitializer,
        _forumPreloadDelay = forumPreloadDelay,
        _breezemoonsPreloadDelay = breezemoonsPreloadDelay,
        _forumPreloader = forumPreloader,
        _breezemoonsPreloader = breezemoonsPreloader;

  final IMController? _imController;
  final Future<void> Function(String token)? _chatInitializer;
  final Duration _forumPreloadDelay;
  final Duration _breezemoonsPreloadDelay;
  final VoidCallback? _forumPreloader;
  final VoidCallback? _breezemoonsPreloader;

  final token = ''.obs;
  PageController pageController = PageController();
  final index = 0.obs;
  Timer? _forumPreloadTimer;
  Timer? _breezemoonsPreloadTimer;
  bool _hasScheduledDeferredPreload = false;
  bool _hasRequestedForumPreload = false;
  bool _hasRequestedBreezemoonsPreload = false;

  IMController get imController => _imController ?? Get.find<IMController>();

  @override
  void onInit() {
    _loadCachedTokenAndInitChat();
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    scheduleDeferredTabPreload();
  }

  Future<void> initChat() async {
    if (token.value.isEmpty) return;
    final chatInitializer = _chatInitializer;
    if (chatInitializer != null) {
      await chatInitializer(token.value);
      return;
    }
    await imController.init(token.value);
    try {
      await imController.chatInit();
    } catch (_) {}
  }

  void _loadCachedTokenAndInitChat() {
    final cachedToken = PiUtils.getCachedToken();
    if (cachedToken.isNotEmpty) {
      token.value = cachedToken;
      unawaited(initChat());
      return;
    }
    unawaited(_loadTokenAndInitChat());
  }

  Future<void> _loadTokenAndInitChat() async {
    final savedToken = await PiUtils.getToken();
    if (isClosed || savedToken.isEmpty || savedToken == token.value) return;
    token.value = savedToken;
    await initChat();
  }

  void scheduleDeferredTabPreload() {
    if (_hasScheduledDeferredPreload) return;
    _hasScheduledDeferredPreload = true;

    // 首页首屏先让聊天和我的页完成关键请求，再分批预热内容流，降低弱网登录后的并发峰值。
    _forumPreloadTimer = Timer(_forumPreloadDelay, _preloadForumIfNeeded);
    _breezemoonsPreloadTimer = Timer(
      _breezemoonsPreloadDelay,
      _preloadBreezemoonsIfNeeded,
    );
  }

  void onPageChanged(int idx) {
    index.value = idx;
    _preloadSelectedTab(idx);
  }

  void changeIndex(int idx) {
    index.value = idx;
    _preloadSelectedTab(idx);
    pageController.jumpToPage(idx);
  }

  void _preloadSelectedTab(int idx) {
    if (idx == 1) {
      _preloadForumIfNeeded();
    } else if (idx == 2) {
      _preloadBreezemoonsIfNeeded();
    }
  }

  void _preloadForumIfNeeded() {
    if (_hasRequestedForumPreload) return;
    _hasRequestedForumPreload = true;
    _forumPreloadTimer?.cancel();
    _forumPreloadTimer = null;
    final forumPreloader = _forumPreloader;
    if (forumPreloader != null) {
      forumPreloader();
      return;
    }
    if (Get.isRegistered<ForumLogic>()) {
      Get.find<ForumLogic>().loadInitialPageIfNeeded();
    }
  }

  void _preloadBreezemoonsIfNeeded() {
    if (_hasRequestedBreezemoonsPreload) return;
    _hasRequestedBreezemoonsPreload = true;
    _breezemoonsPreloadTimer?.cancel();
    _breezemoonsPreloadTimer = null;
    final breezemoonsPreloader = _breezemoonsPreloader;
    if (breezemoonsPreloader != null) {
      breezemoonsPreloader();
      return;
    }
    if (Get.isRegistered<BreezemoonsLogic>()) {
      Get.find<BreezemoonsLogic>().loadInitialPageIfNeeded();
    }
  }

  @override
  void onClose() {
    _forumPreloadTimer?.cancel();
    _breezemoonsPreloadTimer?.cancel();
    pageController.dispose();
    super.onClose();
  }
}
