import 'package:fishpi/fishpi.dart';
import 'package:fishpi_app/res/styles.dart';
import 'package:fishpi_app/widgets/pi_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../widgets/pi_title_bar.dart';
import 'complaint_logic.dart';

class ComplaintPage extends StatelessWidget {
  ComplaintPage({super.key});

  final ComplaintLogic logic = Get.find<ComplaintLogic>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PiTitleBar.back(
        title: '投诉举报',
      ),
      body: Obx(
        () => Container(
          width: 1.sw,
          constraints: BoxConstraints(minHeight: 1.sh),
          color: Styles.titleBarColor,
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: Styles.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormCard(),
                  20.verticalSpace,
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      width: 1.sw - 32.w,
      padding: Styles.cardPadding,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Styles.commonBorder,
        borderRadius: Styles.cardRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('举报对象 ID'),
          8.verticalSpace,
          SizedBox(
            height: Styles.formFieldHeight,
            child: PiInput(
              key: const ValueKey('complaint_target_id_input'),
              controller: logic.targetIdController,
              hintText: '文章/评论/用户/消息 oId',
              prefixIcon: const Icon(Icons.tag_outlined),
              textAlign: TextAlign.start,
              contentPadding: Styles.formFieldPadding,
              textInputAction: TextInputAction.next,
              onInputChanged: (_) {},
            ),
          ),
          14.verticalSpace,
          _buildLabel('举报对象类型'),
          8.verticalSpace,
          _buildDataTypeDropdown(),
          14.verticalSpace,
          _buildLabel('举报原因'),
          8.verticalSpace,
          _buildReportTypeDropdown(),
          14.verticalSpace,
          _buildLabel('举报说明'),
          8.verticalSpace,
          _buildMemoInput(),
        ],
      ),
    );
  }

  Widget _buildDataTypeDropdown() {
    return _buildDropdown<ReportDataType>(
      key: const ValueKey('complaint_data_type_dropdown'),
      value: logic.reportDataType.value,
      items: ComplaintLogic.dataTypeOptions,
      onChanged: logic.changeDataType,
    );
  }

  Widget _buildReportTypeDropdown() {
    return _buildDropdown<ReportType>(
      key: const ValueKey('complaint_report_type_dropdown'),
      value: logic.reportType.value,
      items: ComplaintLogic.reportTypeOptions,
      onChanged: logic.changeReportType,
    );
  }

  Widget _buildDropdown<T>({
    required Key key,
    required T value,
    required List<ComplaintOption<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      height: Styles.formFieldHeight,
      padding: EdgeInsets.symmetric(
        horizontal: PiStyleTokens.inputHorizontalPadding.w,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border.fromBorderSide(
          BorderSide(color: Colors.black, width: PiStyleTokens.borderWidth),
        ),
        borderRadius: Styles.controlRadius,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          key: key,
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_outlined),
          dropdownColor: Colors.white,
          style: TextStyle(
            color: Styles.primaryTextColor,
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
          items: items
              .map(
                (item) => DropdownMenuItem<T>(
                  value: item.value,
                  child: Text(item.label),
                ),
              )
              .toList(),
          onChanged: logic.isSubmitting.value ? null : onChanged,
        ),
      ),
    );
  }

  Widget _buildMemoInput() {
    return TextField(
      key: const ValueKey('complaint_memo_input'),
      controller: logic.memoController,
      minLines: 6,
      maxLines: 8,
      maxLength: 1000,
      cursorColor: Colors.black,
      textInputAction: TextInputAction.newline,
      style: TextStyle(
        fontSize: 14.sp,
        color: Colors.black,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: '请描述违规内容、发生位置和补充证据',
        hintStyle: const TextStyle(color: Colors.black),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: Styles.inputBorder,
        focusedBorder: Styles.inputBorder,
        border: Styles.inputBorder,
        contentPadding: Styles.formFieldPadding,
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Styles.primaryTextColor,
        fontSize: 14.sp,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: logic.isSubmitting.value ? null : logic.submit,
      child: Opacity(
        opacity: logic.isSubmitting.value ? 0.62 : 1,
        child: Container(
          width: 1.sw - 32.w,
          height: Styles.primaryButtonHeight,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: Styles.controlRadius,
          ),
          child: logic.isSubmitting.value
              ? SizedBox(
                  width: 22.w,
                  height: 22.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.outbox_outlined, color: Colors.white),
                    8.horizontalSpace,
                    Text(
                      '提交举报',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
