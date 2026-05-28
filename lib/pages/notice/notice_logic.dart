import 'package:fishpi/fishpi.dart';
import 'package:fishpi_app/core/controller/im.dart';
import 'package:fishpi_app/core/manager/toast.dart';
import 'package:fishpi_app/routers/navigator.dart';
import 'package:fishpi_app/utils/pi_utils.dart';
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
    await Future.wait([
      _loadCount(),
      _loadCurrentList(),
    ]);
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
      ToastManager.showToast('标记已读失败：$e');
    }
  }

  Future<void> markAllRead() async {
    try {
      await imController.fishpi.notice.readAll();
      ToastManager.showToast('已全部标记为已读');
      await reload();
    } catch (e) {
      ToastManager.showToast('全部已读失败：$e');
    }
  }

  int unreadFor(NoticeCategory category) =>
      category.unreadCount(noticeCount.value);

  void openNotice(NoticeDisplayItem item) {
    final articleId = item.targetArticleId.trim();
    if (articleId.isNotEmpty) {
      AppNavigator.toForumDetail(oId: articleId);
      return;
    }

    final userName = item.targetUserName.trim();
    if (userName.isNotEmpty) {
      AppNavigator.toUserPanel(userName: userName);
      return;
    }

    ToastManager.showToast('暂不支持跳转该通知');
  }

  Future<void> _loadCount() async {
    try {
      noticeCount.value = await imController.fishpi.notice.count();
    } catch (_) {
      noticeCount.value = _emptyCount();
    }
  }

  Future<void> _loadCurrentList() async {
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
    } catch (e) {
      // 切分类或刷新失败时保留已有通知，避免短暂解析/网络异常把页面打空。
      // 首次加载失败仍显示空态，已有内容时只在刷新状态里记录错误。
      errorText.value = _friendlyError(e);
    } finally {
      notices.refresh();
      isLoading.value = false;
    }
  }

  String _friendlyError(Object error) {
    final raw = error
        .toString()
        .replaceFirst('Exception:', '')
        .replaceFirst('Invalid argument(s):', '')
        .trim();
    if (raw.isEmpty) return '通知加载失败';
    if (raw.contains('type') || raw.contains('List') || raw.contains('Map')) {
      return '通知数据解析失败，请下拉重试';
    }
    return raw;
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

  static String _normalizeArticleId(String raw) {
    final value = raw.trim();
    if (RegExp(r'^[0-9A-Za-z_-]{8,}$').hasMatch(value)) return value;
    return '';
  }
}
