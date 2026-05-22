import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutLogic extends GetxController {
  final version = '3.0.0'.obs;
  @override
  void onInit() {
    initInfo();
    super.onInit();
  }

  void initInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version.value = packageInfo.version;
  }
}
