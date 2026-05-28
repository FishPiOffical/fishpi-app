import 'dart:async';

import 'package:fishpi/fishpi.dart';
import 'package:fishpi_app/core/controller/im.dart';
import 'package:fishpi_app/core/debug/memory_snapshot.dart';
import 'package:fishpi_app/core/forum/article_utils.dart';
import 'package:fishpi_app/core/forum/forum_query_option.dart';
import 'package:fishpi_app/core/memory/memory_limits.dart';
import 'package:fishpi_app/core/memory/memory_list_utils.dart';
import 'package:fishpi_app/core/network/app_error_message.dart';
import 'package:fishpi_app/core/sql/black_list.dart';
import 'package:fishpi_app/core/sql/user_remark.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ForumLogic extends GetxController {
  ForumLogic({this.autoLoad = true});

  final bool autoLoad;
  final refresherController = RefreshController();
  final imController = Get.find<IMController>();

  final list = <ArticleDetail>[].obs;
  final page = 1.obs;
  final isFinished = false.obs;
  final isLoading = false.obs;
  final errorText = ''.obs;
  final selectedType = ArticleListType.Reply.obs;
  final searchKeyword = ''.obs;
  final isSearchVisible = false.obs;
  final TextEditingController searchController = TextEditingController();
  final List<BlackUser> _blackUsers = [];
  StreamSubscription<void>? _blackListSubscription;
  StreamSubscription<void>? _remarkSubscription;
  bool _hasRequestedInitialLoad = false;

  @override
  void onInit() {
    _blackListSubscription ??= BlackList.changes.listen((_) {
      _reloadBlackUsersAndFilterList();
    });
    UserRemark.init();
    _remarkSubscription ??= UserRemark.changes.listen((_) {
      list.refresh();
    });
    if (autoLoad) {
      loadInitialPageIfNeeded();
    }
    super.onInit();
  }

  List<ForumQueryOption> get queryOptions => ForumQueryOption.defaults;

  String get selectedTitle => ForumQueryOption.byType(selectedType.value).title;

  bool get hasRequestedInitialLoad => _hasRequestedInitialLoad;

  Future<void> loadInitialPageIfNeeded() async {
    if (_hasRequestedInitialLoad || isLoading.value || list.isNotEmpty) {
      return;
    }
    isFinished.value = false;
    page.value = 1;
    await initArticle();
  }

  Future<void> initArticle() async {
    if (isLoading.value) return;
    isLoading.value = true;
    final requestPage = page.value;
    if (requestPage == 1) {
      _hasRequestedInitialLoad = true;
    }
    try {
      await _loadBlackUsers();
      ArticleList res = await imController.fishpi.article.list(
        type: selectedType.value,
        page: requestPage,
        tag: searchKeyword.value.trim().isEmpty
            ? null
            : Uri.encodeComponent(searchKeyword.value.trim()),
      );
      errorText.value = '';
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
    } catch (e) {
      errorText.value = AppErrorMessage.friendly(
        e,
        fallback: '帖子加载失败',
      );
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

  void selectType(String type) {
    if (selectedType.value == type && page.value == 1) return;
    selectedType.value = type;
    onRefresh();
  }

  void toggleSearch() {
    isSearchVisible.value = !isSearchVisible.value;
  }

  void submitSearch(String value) {
    final normalized = value.trim();
    if (normalized == searchKeyword.value) return;
    searchKeyword.value = normalized;
    searchController.text = normalized;
    searchController.selection = TextSelection.collapsed(
      offset: searchController.text.length,
    );
    onRefresh();
  }

  void clearSearch() {
    if (searchKeyword.value.isEmpty && searchController.text.isEmpty) return;
    searchKeyword.value = '';
    searchController.clear();
    onRefresh();
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
    searchController.dispose();
    refresherController.dispose();
    super.onClose();
  }
}
