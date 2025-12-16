import 'package:fishpi/types/user.dart';
import 'package:get/get.dart';

import '../../../utils/pi_utils.dart';

class CollectionListLogic extends GetxController {
  RxList metals = <Metal>[].obs;
  final apikey = "".obs;

  @override
  void onInit() {
    super.onInit();
    var args = Get.arguments;
    if (args != null) {
      metals.value = args['metals'] ?? [];
    }
    apikey.value = PiUtils.getString('token');
  }
}
