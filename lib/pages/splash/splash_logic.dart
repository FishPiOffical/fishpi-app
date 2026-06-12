import 'package:dio/dio.dart';
import 'package:fishpi_app/core/network/api_config.dart';
import 'package:fishpi_app/routers/navigator.dart';
import 'package:fishpi_app/utils/pi_utils.dart';
import 'package:get/get.dart';

class SplashLogic extends GetxController {
  final isLogin = false.obs;
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 8),
    ),
  );

  @override
  void onInit() {
    _loadLoginState();
    super.onInit();
  }

  void toStartApp() async {
    try {
      await dio.getUri(Uri.parse(ApiConfig.privacyUrl));
    } catch (_) {}
    final hasLoginToken = await PiUtils.hasToken();
    if (isClosed) return;
    isLogin.value = hasLoginToken;
    isLogin.value ? AppNavigator.closeAllToHome() : AppNavigator.startLogin();
  }

  Future<void> _loadLoginState() async {
    final hasLoginToken = await PiUtils.hasToken();
    if (isClosed) return;
    isLogin.value = hasLoginToken;
  }

  @override
  void onClose() {
    dio.close();
    super.onClose();
  }
}
