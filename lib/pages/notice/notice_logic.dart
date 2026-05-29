import 'package:fishpi/fishpi.dart';
import 'package:fishpi_app/core/controller/im.dart';
import 'package:fishpi_app/core/manager/toast.dart';
import 'package:fishpi_app/core/network/app_error_message.dart';
import 'package:fishpi_app/res/styles.dart';
import 'package:fishpi_app/routers/navigator.dart';
import 'package:fishpi_app/utils/pi_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class NoticeLogic extends GetxController {
  final bool autoLoad;

  NoticeLogic({this.autoLoad = true});

  final categories = NoticeCategory.defaults;
  final selectedIndex = 0.obs;
  final noticeCount = _emptyCount().obs;
  final notices = <NoticeDisplayItem>[].obs;
  final isLoading = false.obs;
  final errorText = ''.obs;
  final refreshController = RefreshController();

  IMController get imController => Get.find<IMController>();

  NoticeCategory get currentCategory => categories[selectedIndex.value];

  @override
  void onInit() {
    super.onInit();
    if (autoLoad) {
      reload();
    }
  }

  Future<void> reload() async {
    final results = await Future.wait<String?>([
      _loadCount(),
      _loadCurrentList(),
    ]);
    if (errorText.value.isEmpty && notices.isEmpty) {
      for (final result in results) {
        if (result != null && result.isNotEmpty) {
          errorText.value = result;
          break;
        }
      }
    }
    refreshController.refreshCompleted();
  }

  Future<void> selectCategory(int index) async {
    if (index < 0 || index >= categories.length) return;
    selectedIndex.value = index;
    await _loadCurrentList();
  }

  Future<void> markCurrentRead() async {
    final type = currentCategory.type;
    try {
      await imController.fishpi.notice.makeRead(type);
      ToastManager.showToast('已标记当前分类为已读');
      await reload();
    } catch (e) {
      ToastManager.showToast(_friendlyError(e, fallback: '标记已读失败'));
    }
  }

  Future<void> markAllRead() async {
    try {
      await imController.fishpi.notice.readAll();
      ToastManager.showToast('已全部标记为已读');
      await reload();
    } catch (e) {
      ToastManager.showToast(_friendlyError(e, fallback: '全部已读失败'));
    }
  }

  int unreadFor(NoticeCategory category) =>
      category.unreadCount(noticeCount.value);

  void openNotice(NoticeDisplayItem item) {
    final articleId = item.targetArticleId.trim();
    if (articleId.isNotEmpty) {
      AppNavigator.toForumDetail(
        oId: articleId,
        commentId: item.targetCommentId,
        focusComments:
            item.targetCommentId.isNotEmpty || item.titleAction.isNotEmpty,
      );
      return;
    }

    final userName = item.targetUserName.trim();
    if (userName.isNotEmpty) {
      AppNavigator.toUserPanel(userName: userName);
      return;
    }

    showNoticeDetail(item);
  }

  void showNoticeDetail(NoticeDisplayItem item) {
    Get.bottomSheet(
      Container(
        key: const ValueKey('notice_detail_sheet'),
        width: 1.sw,
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 20.h),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Styles.commonBorder,
          borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.title,
                      style: TextStyle(
                        color: Styles.primaryTextColor,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  GestureDetector(
                    key: const ValueKey('notice_detail_close_button'),
                    onTap: Get.back,
                    child: SizedBox(
                      width: 40.w,
                      height: 40.w,
                      child: Icon(
                        Icons.close,
                        color: Styles.primaryTextColor,
                        size: 22.w,
                      ),
                    ),
                  ),
                ],
              ),
              if (item.time.isNotEmpty) ...[
                4.verticalSpace,
                Text(
                  PiUtils.getChatTime(item.time),
                  style: TextStyle(
                    color: const Color(0xFF888888),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              12.verticalSpace,
              Text(
                item.content.isEmpty ? '这条通知暂无更多内容' : item.content,
                style: TextStyle(
                  color: Styles.secondaryTextColor,
                  fontSize: 14.sp,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                ),
              ),
              16.verticalSpace,
              GestureDetector(
                key: const ValueKey('notice_detail_copy_button'),
                onTap: () async {
                  await Clipboard.setData(
                    ClipboardData(text: '${item.title}\n${item.content}'),
                  );
                  ToastManager.showToast('已复制通知内容');
                },
                child: Container(
                  width: 1.sw - 32.w,
                  height: 44.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Styles.primaryTextColor,
                    borderRadius: Styles.actionRadius,
                  ),
                  child: Text(
                    '复制内容',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  Future<String?> _loadCount() async {
    try {
      noticeCount.value = await imController.fishpi.notice.count();
      return null;
    } catch (e) {
      return _friendlyError(e, fallback: '通知数量加载失败');
    }
  }

  Future<String?> _loadCurrentList() async {
    isLoading.value = true;
    errorText.value = '';
    try {
      final type = currentCategory.type;
      final rawList = await imController.fishpi.notice.list(type);
      notices.assignAll(
        rawList
            .where((item) => item != null)
            .map((item) => NoticeDisplayItem.from(type, item))
            .where((item) => item.title.isNotEmpty || item.content.isNotEmpty)
            .toList(),
      );
      return null;
    } catch (e) {
      // 切分类或刷新失败时保留已有通知，避免短暂解析/网络异常把页面打空。
      // 首次加载失败仍显示空态，已有内容时只在刷新状态里记录错误。
      errorText.value = _friendlyError(e);
      return errorText.value;
    } finally {
      notices.refresh();
      isLoading.value = false;
    }
  }

  String _friendlyError(Object error, {String fallback = '通知加载失败'}) {
    return AppErrorMessage.friendly(error, fallback: fallback);
  }

  @override
  void onClose() {
    refreshController.dispose();
    super.onClose();
  }

  static NoticeCount _emptyCount() {
    return NoticeCount(
      notifyStatus: true,
      count: 0,
      reply: 0,
      point: 0,
      at: 0,
      broadcast: 0,
      sysAnnounce: 0,
      newFollower: 0,
      following: 0,
      commented: 0,
    );
  }
}

class NoticeCategory {
  final String type;
  final String title;

  const NoticeCategory({
    required this.type,
    required this.title,
  });

  int unreadCount(NoticeCount count) {
    switch (type) {
      case NoticeType.point:
        return count.point;
      case NoticeType.commented:
        return count.commented;
      case NoticeType.reply:
        return count.reply;
      case NoticeType.at:
        return count.at;
      case NoticeType.following:
        return count.following + count.newFollower;
      case NoticeType.broadcast:
        return count.broadcast;
      case NoticeType.system:
        return count.sysAnnounce;
      default:
        return 0;
    }
  }

  static const defaults = [
    NoticeCategory(type: NoticeType.point, title: '积分'),
    NoticeCategory(type: NoticeType.commented, title: '评论'),
    NoticeCategory(type: NoticeType.reply, title: '回复'),
    NoticeCategory(type: NoticeType.at, title: '@'),
    NoticeCategory(type: NoticeType.following, title: '关注'),
    NoticeCategory(type: NoticeType.broadcast, title: '同城'),
    NoticeCategory(type: NoticeType.system, title: '系统'),
  ];
}

class NoticeDisplayItem {
  final String oId;
  final String title;
  final String content;
  final String time;
  final String avatarURL;
  final bool hasRead;
  final String vipUserId;
  final String vipUserName;
  final String titleAction;
  final String targetArticleId;
  final String targetUserName;
  final String targetCommentId;
  final String targetUrl;

  const NoticeDisplayItem({
    this.oId = '',
    required this.title,
    required this.content,
    this.time = '',
    this.avatarURL = '',
    this.hasRead = false,
    this.vipUserId = '',
    this.vipUserName = '',
    this.titleAction = '',
    this.targetArticleId = '',
    this.targetUserName = '',
    this.targetCommentId = '',
    this.targetUrl = '',
  });

  factory NoticeDisplayItem.from(String type, dynamic item) {
    if (item is NoticePoint) {
      return NoticeDisplayItem(
        oId: item.oId,
        title: '积分通知',
        content: item.description,
        time: item.createTime,
        hasRead: item.hasRead,
      );
    }
    if (item is NoticeComment) {
      final action = type == NoticeType.reply ? '回复了你' : '评论了你';
      return NoticeDisplayItem(
        oId: item.oId,
        title: item.author.isEmpty ? item.title : '${item.author} $action',
        content: _composeContent(item.title, item.content),
        time: item.createTime,
        avatarURL: item.thumbnailURL,
        hasRead: item.hasRead,
        vipUserName: item.author,
        titleAction: action,
        targetArticleId: _extractArticleId(item.sharpURL),
        targetUserName: item.author,
        targetCommentId: _extractCommentId(item.sharpURL),
        targetUrl: item.sharpURL,
      );
    }
    if (item is NoticeAt) {
      return NoticeDisplayItem(
        oId: item.oId,
        title: item.userName.isEmpty ? '@ 我的消息' : '${item.userName} 提到了你',
        content: PiUtils.getConversationPreview(item.content),
        time: item.createTime,
        avatarURL: item.avatarURL,
        hasRead: item.hasRead,
        vipUserName: item.userName,
        titleAction: '提到了你',
        targetArticleId: _extractArticleId(item.content),
        targetUserName: item.userName,
        targetCommentId: _extractCommentId(item.content),
        targetUrl: _extractUrl(item.content),
      );
    }
    if (item is NoticeFollow) {
      final defaultTitle = type == NoticeType.broadcast ? '同城通知' : '关注通知';
      return NoticeDisplayItem(
        oId: item.oId,
        title: item.author.isEmpty ? defaultTitle : item.author,
        content: _composeContent(item.title, item.content),
        time: item.createTime,
        avatarURL: item.thumbnailURL,
        hasRead: item.hasRead,
        vipUserName: item.author,
        targetArticleId: _extractArticleId(item.url),
        targetUserName: item.author,
        targetCommentId: _extractCommentId(item.url),
        targetUrl: item.url,
      );
    }
    if (item is NoticeSystem) {
      return NoticeDisplayItem(
        oId: item.oId,
        title: '系统通知',
        content: item.description,
        time: item.createTime,
        hasRead: item.hasRead,
        targetArticleId: _normalizeArticleId(item.dataId),
        targetUrl: item.dataId,
      );
    }
    if (item is NoticeUnknown) {
      return NoticeDisplayItem(
        oId: item.oId,
        title: PiUtils.getConversationPreview(item.title),
        content: PiUtils.getConversationPreview(item.content),
        time: item.createTime,
        avatarURL: item.avatarURL,
        hasRead: item.hasRead,
        targetArticleId: _extractArticleId('${item.title} ${item.content}'),
        targetCommentId: _extractCommentId('${item.title} ${item.content}'),
        targetUrl: _extractUrl('${item.title} ${item.content}'),
      );
    }
    return NoticeDisplayItem(
      title: type,
      content: item.toString(),
    );
  }

  static String _composeContent(String title, String content) {
    final cleanTitle = PiUtils.getConversationPreview(title);
    final cleanContent = PiUtils.getConversationPreview(content);
    if (cleanTitle.isEmpty) return cleanContent;
    if (cleanContent.isEmpty) return cleanTitle;
    return '$cleanTitle：$cleanContent';
  }

  static String _extractArticleId(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return '';

    final articleMatch =
        RegExp(r'(?:^|/)article/([0-9A-Za-z_-]+)').firstMatch(value);
    if (articleMatch != null) {
      return articleMatch.group(1) ?? '';
    }

    final queryMatch = RegExp(r'(?:articleId|articleOId|oId)=([0-9A-Za-z_-]+)')
        .firstMatch(value);
    if (queryMatch != null) {
      return queryMatch.group(1) ?? '';
    }

    return _normalizeArticleId(value);
  }

  static String _extractCommentId(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return '';

    final hashMatch =
        RegExp(r'#comments?-?([0-9A-Za-z_-]{3,})').firstMatch(value);
    if (hashMatch != null) return hashMatch.group(1) ?? '';

    final queryMatch = RegExp(r'(?:commentId|commentOId)=([0-9A-Za-z_-]{3,})')
        .firstMatch(value);
    if (queryMatch != null) return queryMatch.group(1) ?? '';

    final pathMatch = RegExp(r'/comment/([0-9A-Za-z_-]{3,})').firstMatch(value);
    if (pathMatch != null) return pathMatch.group(1) ?? '';

    return '';
  }

  static String _extractUrl(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return '';
    final hrefMatch = RegExp(r'''href=["']([^"']+)["']''').firstMatch(value);
    if (hrefMatch != null) return hrefMatch.group(1) ?? '';
    final urlMatch = RegExp(r'''https?://[^\s<>"']+''').firstMatch(value);
    return urlMatch?.group(0) ?? '';
  }

  static String _normalizeArticleId(String raw) {
    final value = raw.trim();
    if (RegExp(r'^[0-9A-Za-z_-]{8,}$').hasMatch(value)) return value;
    return '';
  }
}
