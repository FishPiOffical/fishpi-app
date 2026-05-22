import 'package:get/get.dart';
import 'collection_list_logic.dart';

class CollectionListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CollectionListLogic());
  }
}
