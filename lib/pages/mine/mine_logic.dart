import 'package:fishpi/types/user.dart';
import 'package:fishpi_app/core/controller/im.dart';
import 'package:get/get.dart';

class MineLogic extends GetxController {
  final imController = Get.find<IMController>();
  final userInfo = UserInfo().obs;

  @override
  void onInit() {
    initUserInfo();
    super.onInit();
  }

  void initUserInfo() async {
    userInfo.value = await imController.fishpi.user.info();
    print(userInfo.value.toJson());
  }
}
