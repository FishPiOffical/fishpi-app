import 'package:fishpi/fishpi.dart';
import 'package:fishpi_app/core/controller/im.dart';
import 'package:fishpi_app/core/manager/toast.dart';
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
      notices.clear();
      errorText.value = e.toString();
    } finally {
      notices.refresh();
      isLoading.value = false;
    }
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

  const NoticeDisplayItem({
    this.oId = '',
    required this.title,
    required this.content,
    this.time = '',
    this.avatarURL = '',
    this.hasRead = false,
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
      return NoticeDisplayItem(
        oId: item.oId,
        title: item.author.isEmpty ? item.title : '${item.author} 评论了你',
        content: _composeContent(item.title, item.content),
        time: item.createTime,
        avatarURL: item.thumbnailURL,
        hasRead: item.hasRead,
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
      );
    }
    if (item is NoticeFollow) {
      return NoticeDisplayItem(
        oId: item.oId,
        title: item.author.isEmpty ? '关注通知' : item.author,
        content: _composeContent(item.title, item.content),
        time: item.createTime,
        avatarURL: item.thumbnailURL,
        hasRead: item.hasRead,
      );
    }
    if (item is NoticeSystem) {
      return NoticeDisplayItem(
        oId: item.oId,
        title: '系统通知',
        content: item.description,
        time: item.createTime,
        hasRead: item.hasRead,
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
}
