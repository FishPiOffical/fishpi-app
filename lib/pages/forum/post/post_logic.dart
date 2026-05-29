import 'package:fishpi/types/article.dart';
import 'package:fishpi_app/core/manager/toast.dart';
import 'package:fishpi_app/core/network/app_error_message.dart';
import 'package:fleather/fleather.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:parchment/codecs.dart';

import '../../../core/controller/im.dart';

class PostLogic extends GetxController {
  final imController = Get.find<IMController>();
  FleatherController controller = FleatherController();
  TextEditingController titleController = TextEditingController();
  TextEditingController tagController = TextEditingController();
  final isSubmitting = false.obs;
  final errorText = ''.obs;
  final draftVersion = 0.obs;
  bool _hasSubmitted = false;

  static const int maxTitleLength = 80;
  static const int maxTagsLength = 120;

  @override
  void onInit() {
    super.onInit();
    titleController.addListener(_onDraftChanged);
    tagController.addListener(_onDraftChanged);
    controller.addListener(_onDraftChanged);
  }

  void _onDraftChanged() {
    draftVersion.value++;
    if (errorText.value.isNotEmpty) {
      errorText.value = '';
    }
  }

  String get markdownContent {
    const mdCode = ParchmentMarkdownCodec();
    return mdCode.encode(controller.document).trim();
  }

  bool get hasDraft {
    draftVersion.value;
    return titleController.text.trim().isNotEmpty ||
        tagController.text.trim().isNotEmpty ||
        markdownContent.isNotEmpty;
  }

  String? validateDraft() {
    final title = titleController.text.trim();
    final tags = tagController.text.trim();
    final content = markdownContent;
    if (title.isEmpty) return '请输入帖子标题';
    if (title.length > maxTitleLength) {
      return '标题不能超过 $maxTitleLength 字';
    }
    if (tags.length > maxTagsLength) {
      return '标签不能超过 $maxTagsLength 字';
    }
    if (content.isEmpty) return '请输入帖子内容';
    return null;
  }

  Future<void> submit() async {
    if (isSubmitting.value) return;
    final error = validateDraft();
    if (error != null) {
      errorText.value = error;
      ToastManager.showToast(error);
      return;
    }
    isSubmitting.value = true;
    errorText.value = '';
    final md = markdownContent;
    String title = titleController.text.trim();
    String tag = tagController.text
        .trim()
        .split(RegExp(r'\s+'))
        .where((item) => item.trim().isNotEmpty)
        .join(",");
    ArticlePost articlePost = ArticlePost(
      title: title,
      content: md,
      tags: tag,
      showInList: 1,
      commentable: true,
      notifyFollowers: false,
      anonymous: false,
    );
    try {
      var res = await imController.fishpi.article.post(articlePost);
      if (res != "") {
        _hasSubmitted = true;
        titleController.clear();
        tagController.clear();
        draftVersion.value = 0;
        errorText.value = '';
        ToastManager.showToast("发布成功");
        Get.back();
      }
    } catch (e) {
      final message = AppErrorMessage.friendly(e, fallback: '发布失败');
      errorText.value = message;
      ToastManager.showToast(message);
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> confirmLeaveIfNeeded() async {
    if (_hasSubmitted || !hasDraft || isSubmitting.value) return true;
    final result = await Get.dialog<bool>(
      CupertinoAlertDialog(
        title: const Text('放弃编辑？'),
        content: const Text('当前帖子还没有发布，离开后草稿不会保留。'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Get.back(result: false),
            child: const Text('继续编辑'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Get.back(result: true),
            child: const Text('放弃'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> closePage() async {
    if (await confirmLeaveIfNeeded()) {
      Get.back();
    }
  }

  void resetDraftForTest() {
    titleController.clear();
    tagController.clear();
    draftVersion.value = 0;
    errorText.value = '';
    _hasSubmitted = false;
  }

  @override
  void onClose() {
    titleController.removeListener(_onDraftChanged);
    tagController.removeListener(_onDraftChanged);
    controller.removeListener(_onDraftChanged);
    controller.dispose();
    titleController.dispose();
    tagController.dispose();
    super.onClose();
  }
}
