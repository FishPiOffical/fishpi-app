import 'package:fishpi_app/core/controller/im.dart';
import 'package:fishpi_app/pages/mine/set_up/complaint/complaint_logic.dart';
import 'package:fishpi_app/pages/mine/set_up/complaint/complaint_view.dart';
import 'package:fishpi_app/pages/mine/set_up/feedback/feedback_logic.dart';
import 'package:fishpi_app/pages/mine/set_up/feedback/feedback_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  tearDown(Get.reset);

  group('投诉举报表单校验', () {
    test('举报对象和说明为空时返回对应错误', () {
      expect(
        ComplaintLogic.validateComplaint(
          reportDataId: '',
          reportMemo: '这是一条说明',
        ),
        '请输入举报对象 ID',
      );
      expect(
        ComplaintLogic.validateComplaint(
          reportDataId: '100',
          reportMemo: '',
        ),
        '请输入举报说明',
      );
    });

    test('合法举报输入通过校验', () {
      expect(
        ComplaintLogic.validateComplaint(
          reportDataId: '100',
          reportMemo: '这是一条有效举报说明',
        ),
        isNull,
      );
    });
  });

  group('意见反馈表单校验', () {
    test('反馈内容为空、过短、联系方式超长时返回错误', () {
      expect(
        FeedbackLogic.validateFeedback(content: '', contact: ''),
        '请输入反馈内容',
      );
      expect(
        FeedbackLogic.validateFeedback(content: '太短', contact: ''),
        '反馈内容至少 5 个字符',
      );
      expect(
        FeedbackLogic.validateFeedback(content: '这是有效反馈内容', contact: 'a' * 101),
        '联系方式不能超过 100 个字符',
      );
    });

    test('反馈备注会包含分类、联系方式和内容', () {
      final memo = FeedbackLogic.buildFeedbackMemo(
        category: FeedbackCategory.bug,
        content: '页面无法提交',
        contact: 'fishpi',
      );

      expect(memo, contains('【App意见反馈】'));
      expect(memo, contains('反馈类型：问题反馈'));
      expect(memo, contains('联系方式：fishpi'));
      expect(memo, contains('反馈内容：页面无法提交'));
    });
  });

  testWidgets('投诉举报页能渲染对象、类型、原因和提交按钮', (tester) async {
    Get.testMode = true;
    Get.put(IMController());
    Get.put(ComplaintLogic());

    await tester.pumpWidget(_wrap(ComplaintPage()));
    await tester.pump();

    expect(find.text('投诉举报'), findsOneWidget);
    expect(find.byKey(const ValueKey('complaint_target_id_input')),
        findsOneWidget);
    expect(find.byKey(const ValueKey('complaint_data_type_dropdown')),
        findsOneWidget);
    expect(find.byKey(const ValueKey('complaint_report_type_dropdown')),
        findsOneWidget);
    expect(find.byKey(const ValueKey('complaint_memo_input')), findsOneWidget);
    expect(find.text('提交举报'), findsOneWidget);
  });

  testWidgets('意见反馈页能渲染分类、内容、联系方式和提交按钮', (tester) async {
    Get.testMode = true;
    Get.put(IMController());
    Get.put(FeedbackLogic());

    await tester.pumpWidget(_wrap(FeedbackPage()));
    await tester.pump();

    expect(find.text('意见反馈'), findsOneWidget);
    expect(find.byKey(const ValueKey('feedback_category_dropdown')),
        findsOneWidget);
    expect(
        find.byKey(const ValueKey('feedback_content_input')), findsOneWidget);
    expect(
        find.byKey(const ValueKey('feedback_contact_input')), findsOneWidget);
    expect(find.text('提交反馈'), findsOneWidget);
  });
}

Widget _wrap(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(360, 812),
    builder: (context, _) => GetMaterialApp(home: child),
  );
}
