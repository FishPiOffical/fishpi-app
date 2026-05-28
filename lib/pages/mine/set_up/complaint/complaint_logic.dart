import 'package:fishpi/fishpi.dart';
import 'package:fishpi_app/core/controller/im.dart';
import 'package:fishpi_app/core/manager/toast.dart';
import 'package:fishpi_app/core/network/app_error_message.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ComplaintOption<T> {
  final T value;
  final String label;

  const ComplaintOption(this.value, this.label);
}

class ComplaintLogic extends GetxController {
  final imController = Get.find<IMController>();

  final targetIdController = TextEditingController();
  final memoController = TextEditingController();
  final isSubmitting = false.obs;
  final reportDataType = ReportDataType.chatroom.obs;
  final reportType = ReportType.advertise.obs;

  static const dataTypeOptions = [
    ComplaintOption(ReportDataType.article, '文章'),
    ComplaintOption(ReportDataType.comment, '评论'),
    ComplaintOption(ReportDataType.user, '用户'),
    ComplaintOption(ReportDataType.chatroom, '聊天室消息'),
  ];

  static const reportTypeOptions = [
    ComplaintOption(ReportType.advertise, '垃圾广告'),
    ComplaintOption(ReportType.porn, '色情'),
    ComplaintOption(ReportType.violate, '违规'),
    ComplaintOption(ReportType.infringement, '侵权'),
    ComplaintOption(ReportType.attacks, '人身攻击'),
    ComplaintOption(ReportType.impersonate, '冒充他人账号'),
    ComplaintOption(ReportType.advertisingAccount, '垃圾广告账号'),
    ComplaintOption(ReportType.leakPrivacy, '违规泄露个人信息'),
    ComplaintOption(ReportType.other, '其它'),
  ];

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      targetIdController.text = args['reportDataId']?.toString() ?? '';
      reportDataType.value =
          args['reportDataType'] as ReportDataType? ?? reportDataType.value;
      reportType.value = args['reportType'] as ReportType? ?? reportType.value;
    }
  }

  void changeDataType(ReportDataType? value) {
    if (value != null) reportDataType.value = value;
  }

  void changeReportType(ReportType? value) {
    if (value != null) reportType.value = value;
  }

  static String? validateComplaint({
    required String reportDataId,
    required String reportMemo,
  }) {
    if (reportDataId.trim().isEmpty) return '请输入举报对象 ID';
    if (reportMemo.trim().isEmpty) return '请输入举报说明';
    if (reportMemo.trim().length < 5) return '举报说明至少 5 个字符';
    if (reportMemo.trim().length > 1000) return '举报说明不能超过 1000 个字符';
    return null;
  }

  Future<void> submit() async {
    if (isSubmitting.value) return;

    final error = validateComplaint(
      reportDataId: targetIdController.text,
      reportMemo: memoController.text,
    );
    if (error != null) {
      ToastManager.showToast(error);
      return;
    }

    isSubmitting.value = true;
    ToastManager.show(content: '提交中...');
    try {
      final result = await imController.fishpi.report(
        Report(
          reportDataId: targetIdController.text.trim(),
          reportDataType: reportDataType.value,
          reportType: reportType.value,
          reportMemo: memoController.text.trim(),
        ),
      );
      if (!result.success) {
        throw result.msg.isEmpty ? '提交失败' : result.msg;
      }
      ToastManager.dismiss();
      ToastManager.showToast('投诉举报已提交');
      Get.back();
    } catch (e) {
      ToastManager.dismiss();
      ToastManager.showToast(
        AppErrorMessage.friendly(e, fallback: '投诉举报提交失败'),
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    targetIdController.dispose();
    memoController.dispose();
    super.onClose();
  }
}
