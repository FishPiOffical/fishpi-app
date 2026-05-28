import 'package:fishpi_app/res/styles.dart';
import 'package:fishpi_app/res/view.dart';
import 'package:fishpi_app/utils/pi_utils.dart';
import 'package:fishpi_app/widgets/pi_title_bar.dart';
import 'package:fishpi_app/widgets/vip_name_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'notice_logic.dart';
import '../../widgets/pi_list_state.dart';

class NoticePage extends GetView<NoticeLogic> {
  const NoticePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: PiTitleBar.back(
          title: '通知消息',
          rightWidget: Icon(
            Icons.done_all,
            key: const ValueKey('notice_mark_all_read_button'),
            color: Styles.primaryTextColor,
            size: 22.w,
          ),
          onRightTap: controller.markAllRead,
        ),
        body: Container(
          width: 1.sw,
          height: 1.sh,
          color: Styles.titleBarColor,
          child: Column(
            children: [
              _buildSummary(),
              _buildCategoryTabs(),
              Expanded(
                child: SmartRefresher(
                  controller: controller.refreshController,
                  header: Views.buildHeader(),
                  enablePullDown: true,
                  onRefresh: controller.reload,
                  child: ListView.builder(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                    itemCount: controller.notices.isEmpty
                        ? 1
                        : controller.notices.length,
                    itemBuilder: _buildNoticeItem,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummary() {
    final count = controller.noticeCount.value.count;
    return Container(
      key: const ValueKey('notice_summary_card'),
      width: 1.sw - 32.w,
      margin: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 12.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Styles.commonBorder,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Container(
            width: 42.w,
            height: 42.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Styles.primaryColor,
              border: Styles.commonBorder,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              Icons.notifications_none,
              color: Styles.primaryTextColor,
              size: 24.w,
            ),
          ),
          12.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '通知中心',
                  style: TextStyle(
                    color: Styles.primaryTextColor,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                4.verticalSpace,
                Text(
                  count > 0 ? '还有 $count 条未读消息' : '暂无未读消息',
                  style: TextStyle(
                    color: Styles.secondaryTextColor,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _buildSmallButton(
            key: const ValueKey('notice_mark_current_read_button'),
            text: '当前已读',
            onTap: controller.markCurrentRead,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return SizedBox(
      key: const ValueKey('notice_category_tabs'),
      height: 46.h,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final category = controller.categories[index];
          final selected = controller.selectedIndex.value == index;
          final unread = controller.unreadFor(category);
          return GestureDetector(
            onTap: () => controller.selectCategory(index),
            child: Container(
              constraints: BoxConstraints(minWidth: 62.w),
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
                  Text(
                    category.title,
                    style: TextStyle(
                      color: selected ? Colors.white : Styles.primaryTextColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (unread > 0) ...[
                    6.horizontalSpace,
                    Container(
                      constraints: BoxConstraints(minWidth: 18.w),
                      height: 18.w,
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(horizontal: 5.w),
                      decoration: BoxDecoration(
                        color:
                            selected ? Styles.primaryColor : Colors.redAccent,
                        borderRadius: BorderRadius.circular(9.r),
                      ),
                      child: Text(
                        unread > 99 ? '99+' : unread.toString(),
                        style: TextStyle(
                          color:
                              selected ? Styles.primaryTextColor : Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => 8.horizontalSpace,
        itemCount: controller.categories.length,
      ),
    );
  }

  Widget _buildNoticeItem(BuildContext context, int index) {
    if (controller.notices.isEmpty) {
      return _buildEmpty();
    }

    final item = controller.notices[index];
    return GestureDetector(
      key: ValueKey('notice_item_${item.oId.isEmpty ? index : item.oId}'),
      onTap: () => controller.openNotice(item),
      behavior: HitTestBehavior.translucent,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Styles.commonBorder,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNoticeIcon(item),
            10.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildNoticeTitle(item),
                      ),
                      if (!item.hasRead)
                        Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      6.horizontalSpace,
                      Icon(
                        Icons.chevron_right,
                        size: 18.w,
                        color: const Color(0xFF999999),
                      ),
                    ],
                  ),
                  6.verticalSpace,
                  Text(
                    item.content,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Styles.secondaryTextColor,
                      fontSize: 13.sp,
                      height: 1.35,
                    ),
                  ),
                  if (item.time.isNotEmpty) ...[
                    8.verticalSpace,
                    Text(
                      PiUtils.getChatTime(item.time),
                      style: TextStyle(
                        color: const Color(0xFF999999),
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoticeTitle(NoticeDisplayItem item) {
    final style = TextStyle(
      color: Styles.primaryTextColor,
      fontSize: 16.sp,
      fontWeight: FontWeight.bold,
    );
    final vipUserName = item.vipUserName.trim();
    if (vipUserName.isEmpty) {
      return Text(
        item.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: style,
      );
    }

    return Row(
      children: [
        Flexible(
          child: VipNameText(
            userId: item.vipUserId,
            userName: vipUserName,
            style: style,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (item.titleAction.trim().isNotEmpty)
          Text(
            ' ${item.titleAction}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
      ],
    );
  }

  Widget _buildNoticeIcon(NoticeDisplayItem item) {
    if (item.avatarURL.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(18.r),
        child: Image.network(
          item.avatarURL,
          width: 36.w,
          height: 36.w,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildDefaultIcon(),
        ),
      );
    }
    return _buildDefaultIcon();
  }

  Widget _buildDefaultIcon() {
    return Container(
      width: 36.w,
      height: 36.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Styles.primaryColor,
        border: Styles.commonBorder,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Icon(
        Icons.notifications_active_outlined,
        size: 20.w,
        color: Styles.primaryTextColor,
      ),
    );
  }

  Widget _buildEmpty() {
    final error = controller.errorText.value.trim();
    final hasError = error.isNotEmpty;
    return PiListState(
      key: const ValueKey('notice_empty_state'),
      retryKey: const ValueKey('notice_retry_button'),
      icon: hasError
          ? Icons.notifications_off_outlined
          : Icons.notifications_none_outlined,
      title: hasError ? '通知加载失败' : '当前分类暂无通知',
      message: hasError ? error : '换个分类看看，或者稍后再来。',
      onRetry: controller.reload,
    );
  }

  Widget _buildSmallButton({
    Key? key,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      key: key,
      onTap: onTap,
      child: Container(
        height: 32.w,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        decoration: BoxDecoration(
          color: Styles.primaryTextColor,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
