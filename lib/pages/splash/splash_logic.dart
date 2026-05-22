import 'package:dio/dio.dart';
import 'package:fishpi_app/routers/navigator.dart';
import 'package:fishpi_app/utils/pi_utils.dart';
import 'package:get/get.dart';

class SplashLogic extends GetxController {
  final isLogin = false.obs;
  final dio = Dio();

  @override
  void onInit() {
    isLogin.value = PiUtils.getBool('isLogin');
    super.onInit();
  }

  void toStartApp() async {
    await dio.getUri(Uri.parse('https://fishpi.cn/privacy'));
    isLogin.value ? AppNavigator.closeAllToHome() : AppNavigator.startLogin();
  }
}
