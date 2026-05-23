import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../res/styles.dart';
import '../../../widgets/pi_input.dart';
import '../../../widgets/pi_title_bar.dart';
import 'edit_info_logic.dart';

class EditInfoPage extends StatelessWidget {
  EditInfoPage({super.key});

  final EditInfoLogic logic = Get.find<EditInfoLogic>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PiTitleBar.back(title: '修改用户信息'),
      body: Obx(
        () => Container(
          width: 1.sw,
          constraints: BoxConstraints(minHeight: 1.sh),
          color: Styles.titleBarColor,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
            child: Column(
              children: [
                _buildFormCard(),
                20.verticalSpace,
                _buildSaveButton(),
              ],
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
          _buildInput(
            key: const ValueKey('edit_info_nickname_input'),
            label: '昵称',
            hintText: '昵称',
            controller: logic.nicknameController,
            icon: Icons.person_outline,
          ),
          14.verticalSpace,
          _buildInput(
            key: const ValueKey('edit_info_url_input'),
            label: '个人主页',
            hintText: 'https://fishpi.cn',
            controller: logic.urlController,
            icon: Icons.link_outlined,
            keyboardType: TextInputType.url,
          ),
          14.verticalSpace,
          _buildTextArea(
            key: const ValueKey('edit_info_intro_input'),
            label: '简介',
            hintText: '介绍一下自己',
            controller: logic.introController,
          ),
          14.verticalSpace,
          _buildInput(
            key: const ValueKey('edit_info_tags_input'),
            label: '标签',
            hintText: 'Flutter, 摸鱼派',
            controller: logic.tagsController,
            icon: Icons.sell_outlined,
          ),
          14.verticalSpace,
          _buildInput(
            key: const ValueKey('edit_info_mbti_input'),
            label: 'MBTI',
            hintText: 'INTJ',
            controller: logic.mbtiController,
            icon: Icons.psychology_alt_outlined,
            textInputAction: TextInputAction.done,
          ),
        ],
      ),
    );
  }

  Widget _buildInput({
    required Key key,
    required String label,
    required String hintText,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        8.verticalSpace,
        SizedBox(
          height: 52.h,
          child: PiInput(
            key: key,
            controller: controller,
            hintText: hintText,
            prefixIcon: Icon(icon),
            keyboardType: keyboardType,
            textInputAction: textInputAction ?? TextInputAction.next,
            textAlign: TextAlign.start,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            onInputChanged: (_) {},
          ),
        ),
      ],
    );
  }

  Widget _buildTextArea({
    required Key key,
    required String label,
    required String hintText,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        8.verticalSpace,
        TextField(
          key: key,
          controller: controller,
          minLines: 4,
          maxLines: 4,
          maxLength: 255,
          cursorColor: Colors.black,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.black),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: Styles.inputBorder,
            focusedBorder: Styles.inputBorder,
            border: Styles.inputBorder,
            contentPadding: EdgeInsets.all(12.w),
          ),
        ),
      ],
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

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: logic.isSaving.value ? null : logic.submit,
      child: Opacity(
        opacity: logic.isSaving.value ? 0.62 : 1,
        child: Container(
          width: 1.sw - 32.w,
          height: 56.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: logic.isSaving.value
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
                    const Icon(
                      Icons.save_outlined,
                      color: Colors.white,
                    ),
                    8.horizontalSpace,
                    Text(
                      '保存',
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
