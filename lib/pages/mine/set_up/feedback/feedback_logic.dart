import 'package:fishpi/fishpi.dart';
import 'package:fishpi_app/core/controller/im.dart';
import 'package:fishpi_app/core/manager/toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum FeedbackCategory {
  feature,
  bug,
  experience,
  other,
}

class FeedbackCategoryOption {
  final FeedbackCategory value;
  final String label;

  const FeedbackCategoryOption(this.value, this.label);
}

class FeedbackLogic extends GetxController {
  final imController = Get.find<IMController>();

  final contentController = TextEditingController();
  final contactController = TextEditingController();
  final isSubmitting = false.obs;
  final category = FeedbackCategory.feature.obs;

  static const categoryOptions = [
    FeedbackCategoryOption(FeedbackCategory.feature, '功能建议'),
    FeedbackCategoryOption(FeedbackCategory.bug, '问题反馈'),
    FeedbackCategoryOption(FeedbackCategory.experience, '体验优化'),
    FeedbackCategoryOption(FeedbackCategory.other, '其它'),
  ];

  void changeCategory(FeedbackCategory? value) {
    if (value != null) category.value = value;
  }

  static String? validateFeedback({
    required String content,
    required String contact,
  }) {
    if (content.trim().isEmpty) return '请输入反馈内容';
    if (content.trim().length < 5) return '反馈内容至少 5 个字符';
    if (content.trim().length > 1000) return '反馈内容不能超过 1000 个字符';
    if (contact.trim().length > 100) return '联系方式不能超过 100 个字符';
    return null;
  }

  static String categoryLabel(FeedbackCategory category) {
    return categoryOptions
        .firstWhere((option) => option.value == category)
        .label;
  }

  static String buildFeedbackMemo({
    required FeedbackCategory category,
    required String content,
    required String contact,
  }) {
    final contactText = contact.trim().isEmpty ? '未填写' : contact.trim();
    return [
      '【App意见反馈】',
      '反馈类型：${categoryLabel(category)}',
      '联系方式：$contactText',
      '反馈内容：${content.trim()}',
    ].join('\n');
  }

  Future<void> submit() async {
    if (isSubmitting.value) return;

    final error = validateFeedback(
      content: contentController.text,
      contact: contactController.text,
    );
    if (error != null) {
      ToastManager.showToast(error);
      return;
    }

    isSubmitting.value = true;
    ToastManager.show(content: '提交中...');
    try {
      final userId = await _currentUserId();
      if (userId.isEmpty) {
        throw '无法获取当前用户信息';
      }

      final result = await imController.fishpi.report(
        Report(
          reportDataId: userId,
          reportDataType: ReportDataType.user,
          reportType: ReportType.other,
          reportMemo: buildFeedbackMemo(
            category: category.value,
            content: contentController.text,
            contact: contactController.text,
          ),
        ),
      );
      if (!result.success) {
        throw result.msg.isEmpty ? '提交失败' : result.msg;
      }

      ToastManager.dismiss();
      ToastManager.showToast('意见反馈已提交');
      Get.back();
    } catch (e) {
      ToastManager.dismiss();
      ToastManager.showToast(e.toString());
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<String> _currentUserId() async {
    final cached = imController.fishpi.user.current;
    if (cached.oId.isNotEmpty) return cached.oId;
    final info = await imController.fishpi.user.info();
    return info.oId;
  }

  @override
  void onClose() {
    contentController.dispose();
    contactController.dispose();
    super.onClose();
  }
}
