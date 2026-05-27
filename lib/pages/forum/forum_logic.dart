import 'dart:async';

import 'package:fishpi/fishpi.dart';
import 'package:fishpi_app/core/controller/im.dart';
import 'package:fishpi_app/core/debug/memory_snapshot.dart';
import 'package:fishpi_app/core/forum/article_utils.dart';
import 'package:fishpi_app/core/memory/memory_limits.dart';
import 'package:fishpi_app/core/memory/memory_list_utils.dart';
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
  final isLoading = false.obs;
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
    if (isLoading.value) return;
    isLoading.value = true;
    final requestPage = page.value;
    try {
      await _loadBlackUsers();
      ArticleList res = await imController.fishpi.article.list(
        type: ArticleListType.Reply,
        page: requestPage,
      );
      final visibleList = _visibleArticles(res.list);
      if (requestPage == 1) {
        list.value = MemoryListUtils.keepFirst(
          ArticleUtils.sortStickyFirst(visibleList),
          MemoryLimits.contentListItems,
        );
        list.refresh();
        refresherController.refreshCompleted();
        refresherController.loadComplete();
      } else {
        list.value = MemoryListUtils.keepFirst(
          [
            ...list,
            ...visibleList,
          ],
          MemoryLimits.contentListItems,
        );
        list.refresh();
        if (res.list.isNotEmpty) {
          refresherController.loadComplete();
        } else {
          refresherController.loadNoData();
          isFinished.value = true;
        }
      }
    } catch (_) {
      if (requestPage > 1 && page.value == requestPage) {
        page.value = requestPage - 1;
      }
      requestPage == 1
          ? refresherController.refreshFailed()
          : refresherController.loadFailed();
    } finally {
      isLoading.value = false;
    }
  }

  void onRefresh() {
    isFinished.value = false;
    page.value = 1;
    initArticle();
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
    list.assignAll(
      MemoryListUtils.keepFirst(
        _visibleArticles(list),
        MemoryLimits.contentListItems,
      ),
    );
    list.refresh();
  }

  @override
  void onClose() {
    _blackListSubscription?.cancel();
    _remarkSubscription?.cancel();
    MemorySnapshot.log(source: '帖子页关闭前', articles: list.length);
    refresherController.dispose();
    super.onClose();
  }
}
