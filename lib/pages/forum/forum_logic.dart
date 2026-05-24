import 'dart:async';

import 'package:fishpi/fishpi.dart';
import 'package:fishpi_app/core/controller/im.dart';
import 'package:fishpi_app/core/sql/black_list.dart';
import 'package:fishpi_app/core/sql/user_remark.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ForumLogic extends GetxController {
  final refresherController = RefreshController();
  final imController = Get.find<IMController>();

  final list = <ArticleDetail>[].obs;
  final page = 1.obs;
  final isFinished = false.obs;
  final List<BlackUser> _blackUsers = [];
  StreamSubscription<void>? _blackListSubscription;
  StreamSubscription<void>? _remarkSubscription;

  @override
  void onInit() {
    _blackListSubscription ??= BlackList.changes.listen((_) {
      _reloadBlackUsersAndFilterList();
    });
    UserRemark.init();
    _remarkSubscription ??= UserRemark.changes.listen((_) {
      list.refresh();
    });
    initArticle();
    super.onInit();
  }

  void initArticle() async {
    await _loadBlackUsers();
    ArticleList res = await imController.fishpi.article.list(
      type: ArticleListType.Reply,
      page: page.value,
    );
    final visibleList = _visibleArticles(res.list);
    if (page.value == 1) {
      list.value = visibleList;
      list.refresh();
      refresherController.loadComplete();
    } else {
      list.addAll(visibleList);
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

  List<ArticleDetail> _visibleArticles(Iterable<ArticleDetail> source) {
    return BlackList.visibleItems(
      source,
      _blackUsers,
      oId: (item) => item.authorId,
      userName: (item) => item.authorName,
    );
  }

  Future<void> _loadBlackUsers() async {
    try {
      await BlackList.init();
      _blackUsers
        ..clear()
        ..addAll(await BlackList.getAllUser());
    } catch (_) {
      _blackUsers.clear();
    }
  }

  Future<void> _reloadBlackUsersAndFilterList() async {
    await _loadBlackUsers();
    list.assignAll(_visibleArticles(list));
    list.refresh();
  }

  @override
  void onClose() {
    _blackListSubscription?.cancel();
    _remarkSubscription?.cancel();
    super.onClose();
  }
}
