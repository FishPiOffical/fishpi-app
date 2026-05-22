import 'package:fishpi/fishpi.dart';
import 'package:fishpi_app/core/controller/im.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ForumLogic extends GetxController {
  final refresherController = RefreshController();
  final imController = Get.find<IMController>();

  final list = <ArticleDetail>[].obs;
  final page = 1.obs;
  final isFinished = false.obs;

  @override
  void onInit() {
    initArticle();
    super.onInit();
  }

  void initArticle() async {
    ArticleList res = await imController.fishpi.article.list(
      type: ArticleListType.Reply,
      page: page.value,
    );
    if (page.value == 1) {
      list.value = res.list;
      list.refresh();
      refresherController.loadComplete();
    } else {
      list.addAll(res.list);
      list.refresh();
      if (res.list.isNotEmpty) {
        refresherController.loadComplete();
      } else {
        refresherController.loadNoData();
        isFinished.value = true;
      }
    }
  }

  void onRefresh() {
    isFinished.value = false;
    page.value = 1;
    initArticle();
    refresherController.refreshCompleted();
  }

  void onLoading() {
    if (isFinished.value) return;
    page.value++;
    initArticle();
  }
}
