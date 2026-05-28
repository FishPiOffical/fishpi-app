import 'package:fishpi/types/article.dart';
import 'package:fishpi_app/core/forum/forum_query_option.dart';
import 'package:fishpi_app/res/view.dart';
import 'package:fishpi_app/res/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../widgets/pi_article_item.dart';
import '../../widgets/pi_input.dart';
import '../../widgets/pi_list_state.dart';
import 'forum_logic.dart';

class ForumPage extends StatelessWidget {
  final ForumLogic logic = Get.find<ForumLogic>();

  ForumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => Container(
          width: 1.sw,
          height: 1.sh,
          padding: EdgeInsets.symmetric(
            horizontal: 16.w,
          ),
          child: SmartRefresher(
            controller: logic.refresherController,
            header: Views.buildHeader(),
            footer: Views.buildFooter(),
            enablePullUp: true,
            enablePullDown: true,
            onRefresh: logic.onRefresh,
            onLoading: logic.onLoading,
            child: logic.list.isEmpty
                ? ListView(
                    padding: EdgeInsets.only(top: 20.h),
                    children: [
                      _buildQueryHeader(),
                      _buildListState(),
                    ],
                  )
                : ListView.builder(
                    padding: EdgeInsets.only(top: 20.h),
                    itemBuilder: _buildArticleList,
                    itemCount: logic.list.length + 1,
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildQueryHeader() {
    return Container(
      key: const ValueKey('forum_query_header'),
      margin: EdgeInsets.only(bottom: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 38.w,
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final option in logic.queryOptions) ...[
                          _buildTypeChip(option),
                          8.horizontalSpace,
                        ],
                      ],
                    ),
                  ),
                ),
                _buildSearchToggle(),
              ],
            ),
          ),
          if (logic.isSearchVisible.value || logic.searchKeyword.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 10.h),
              child: _buildSearchInput(),
            ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(ForumQueryOption option) {
    final selected = logic.selectedType.value == option.type;
    return GestureDetector(
      key: ValueKey('forum_type_${option.type}'),
      onTap: () => logic.selectType(option.type),
      child: Container(
        height: 38.w,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? Styles.primaryTextColor : Colors.white,
          border: Styles.commonBorder,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _optionIcon(option.type),
              size: 16.w,
              color: selected ? Colors.white : Styles.primaryTextColor,
            ),
            4.horizontalSpace,
            Text(
              option.title,
              style: TextStyle(
                color: selected ? Colors.white : Styles.primaryTextColor,
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchToggle() {
    final active = logic.searchKeyword.value.trim().isNotEmpty;
    return GestureDetector(
      key: const ValueKey('forum_search_toggle'),
      onTap: logic.toggleSearch,
      child: Container(
        height: 38.w,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? Styles.primaryColor : Colors.white,
          border: Styles.commonBorder,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search,
              size: 16.w,
              color: Styles.primaryTextColor,
            ),
            4.horizontalSpace,
            Text(
              active ? '# ${logic.searchKeyword.value}' : '搜索',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Styles.primaryTextColor,
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchInput() {
    return SizedBox(
      key: const ValueKey('forum_search_input'),
      height: 42.h,
      child: PiInput(
        controller: logic.searchController,
        hintText: '搜索标签/关键词',
        textAlign: TextAlign.left,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.search,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (logic.searchKeyword.value.trim().isNotEmpty)
              GestureDetector(
                key: const ValueKey('forum_search_clear'),
                onTap: logic.clearSearch,
                child: SizedBox(
                  width: 34.w,
                  height: 34.w,
                  child: Icon(
                    Icons.close,
                    size: 18.w,
                    color: Styles.primaryTextColor,
                  ),
                ),
              ),
            GestureDetector(
              key: const ValueKey('forum_search_submit'),
              onTap: () => logic.submitSearch(logic.searchController.text),
              child: SizedBox(
                width: 38.w,
                height: 34.w,
                child: Icon(
                  Icons.search,
                  size: 19.w,
                  color: Styles.primaryTextColor,
                ),
              ),
            ),
          ],
        ),
        onInputChanged: (_) {},
        onEditingComplete: () =>
            logic.submitSearch(logic.searchController.text),
      ),
    );
  }

  IconData _optionIcon(String type) {
    switch (type) {
      case ArticleListType.Recent:
        return Icons.article_outlined;
      case ArticleListType.Hot:
        return Icons.local_fire_department_outlined;
      case ArticleListType.Perfect:
        return Icons.workspace_premium_outlined;
      case ArticleListType.Reply:
      default:
        return Icons.forum_outlined;
    }
  }

  Widget _buildListState() {
    final error = logic.errorText.value.trim();
    final hasError = error.isNotEmpty;
    return PiListState(
      key: const ValueKey('forum_list_state'),
      retryKey: const ValueKey('forum_list_retry_button'),
      icon: hasError ? Icons.cloud_off_outlined : Icons.article_outlined,
      title: hasError ? '帖子加载失败' : '暂无帖子',
      message: hasError ? error : '下拉刷新，看看有没有新的摸鱼内容。',
      onRetry: logic.onRefresh,
    );
  }

  Widget _buildArticleList(BuildContext context, int idx) {
    if (idx == 0) return _buildQueryHeader();
    ArticleDetail article = logic.list[idx - 1];
    return PiArticleItem(article: article);
  }
}
