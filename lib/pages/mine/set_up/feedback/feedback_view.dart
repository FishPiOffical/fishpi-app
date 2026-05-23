import 'package:fishpi_app/res/styles.dart';
import 'package:fishpi_app/widgets/pi_input.dart';
import 'package:fishpi_app/widgets/pi_title_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'feedback_logic.dart';

class FeedbackPage extends StatelessWidget {
  FeedbackPage({super.key});

  final FeedbackLogic logic = Get.find<FeedbackLogic>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PiTitleBar.back(
        title: '意见反馈',
      ),
      body: Obx(
        () => Container(
          width: 1.sw,
          constraints: BoxConstraints(minHeight: 1.sh),
          color: Styles.titleBarColor,
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
              child: Column(
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
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Styles.commonBorder,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('反馈类型'),
          8.verticalSpace,
          _buildCategoryDropdown(),
          14.verticalSpace,
          _buildLabel('反馈内容'),
          8.verticalSpace,
          _buildContentInput(),
          14.verticalSpace,
          _buildLabel('联系方式'),
          8.verticalSpace,
          SizedBox(
            height: 52.h,
            child: PiInput(
              key: const ValueKey('feedback_contact_input'),
              controller: logic.contactController,
              hintText: '微信/邮箱/摸鱼派用户名（选填）',
              prefixIcon: const Icon(Icons.contact_mail_outlined),
              textAlign: TextAlign.start,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              textInputAction: TextInputAction.done,
              onInputChanged: (_) {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      height: 52.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border.fromBorderSide(
          BorderSide(color: Colors.black, width: 2),
        ),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<FeedbackCategory>(
          key: const ValueKey('feedback_category_dropdown'),
          value: logic.category.value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_outlined),
          dropdownColor: Colors.white,
          style: TextStyle(
            color: Styles.primaryTextColor,
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
          items: FeedbackLogic.categoryOptions
              .map(
                (item) => DropdownMenuItem<FeedbackCategory>(
                  value: item.value,
                  child: Text(item.label),
                ),
              )
              .toList(),
          onChanged: logic.isSubmitting.value ? null : logic.changeCategory,
        ),
      ),
    );
  }

  Widget _buildContentInput() {
    return TextField(
      key: const ValueKey('feedback_content_input'),
      controller: logic.contentController,
      minLines: 7,
      maxLines: 10,
      maxLength: 1000,
      cursorColor: Colors.black,
      textInputAction: TextInputAction.newline,
      style: TextStyle(
        fontSize: 14.sp,
        color: Colors.black,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: '请写下你遇到的问题、想要的功能或体验建议',
        hintStyle: const TextStyle(color: Colors.black),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: Styles.inputBorder,
        focusedBorder: Styles.inputBorder,
        border: Styles.inputBorder,
        contentPadding: EdgeInsets.all(12.w),
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
          height: 56.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(10.r),
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
                      '提交反馈',
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
