import 'package:dio/dio.dart';
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
    isLogin.value = PiUtils.getBool('isLogin');
    super.onInit();
  }

  void toStartApp() async {
    try {
      await dio.getUri(Uri.parse('https://fishpi.cn/privacy'));
    } catch (_) {}
    isLogin.value ? AppNavigator.closeAllToHome() : AppNavigator.startLogin();
  }

  @override
  void onClose() {
    dio.close();
    super.onClose();
  }
}
