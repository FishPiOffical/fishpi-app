import 'package:cached_network_image/cached_network_image.dart';
import 'package:fishpi_app/core/manager/toast.dart';
import 'package:fishpi_app/core/vip/vip_style_service.dart';
import 'package:fishpi_app/routers/navigator.dart';
import 'package:fishpi_app/utils/pi_utils.dart';
import 'package:flutter/painting.dart';
import 'package:get/get.dart';

class SetUpLogic extends GetxController {
  void toBlackPage() {
    AppNavigator.toBlackList();
  }

  void toFeedBackPage() {
    AppNavigator.toFeedback();
  }

  void toComplaint() {
    AppNavigator.toComplaint();
  }

  void toAboutPage() {
    AppNavigator.toAboutUs();
  }

  Future<void> clearImageCache() async {
    ToastManager.show(content: '正在清理缓存...');
    try {
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
      await CachedNetworkImageProvider.defaultCacheManager.emptyCache();
      ToastManager.dismiss();
      ToastManager.showToast('图片缓存已清理');
    } catch (e) {
      ToastManager.dismiss();
      ToastManager.showToast('清理缓存失败：$e');
    }
  }

  void logout() {
    VipStyleService.clearSharedCache();
    PiUtils.clear();
    AppNavigator.startLogin();
  }
}
