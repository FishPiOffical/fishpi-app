import 'package:fishpi_app/res/styles.dart';
import 'package:fishpi_app/widgets/pi_input.dart';
import 'package:fleather/fleather.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../widgets/pi_title_bar.dart';
import 'post_logic.dart';

class PostPage extends StatefulWidget {
  const PostPage({super.key});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final PostLogic logic = Get.find<PostLogic>();
  bool _allowPop = false;

  Future<void> _closePage() async {
    if (await logic.confirmLeaveIfNeeded()) {
      if (!mounted) return;
      setState(() => _allowPop = true);
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _closePage();
        }
      },
      child: Scaffold(
        appBar: PiTitleBar.back(
          title: '发布帖子',
          onBackTap: _closePage,
        ),
        body: SafeArea(
          child: Container(
            width: 1.sw,
            height: 1.sh,
            color: Styles.titleBarColor,
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
            child: Column(
              children: [
                _buildMetaCard(),
                12.verticalSpace,
                Expanded(child: _buildEditorCard()),
                12.verticalSpace,
                _buildErrorText(),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetaCard() {
    return Container(
      width: 1.sw - 32.w,
      padding: Styles.compactCardPadding,
      decoration: Styles.cardDecoration(),
      child: Column(
        children: [
          SizedBox(
            height: Styles.compactButtonHeight,
            child: PiInput(
              key: const ValueKey('post_title_input'),
              controller: logic.titleController,
              hintText: '请输入标题',
              textAlign: TextAlign.left,
              textInputAction: TextInputAction.next,
              onInputChanged: (_) {},
            ),
          ),
          10.verticalSpace,
          SizedBox(
            height: Styles.compactButtonHeight,
            child: PiInput(
              key: const ValueKey('post_tag_input'),
              controller: logic.tagController,
              hintText: '请输入标签，多个标签用空格隔开',
              textAlign: TextAlign.left,
              textInputAction: TextInputAction.next,
              onInputChanged: (_) {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditorCard() {
    return Container(
      width: 1.sw - 32.w,
      decoration: Styles.cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            width: 1.sw - 32.w,
            color: Colors.white,
            child: FleatherToolbar.basic(
              controller: logic.controller,
              hideBackgroundColor: true,
              hideForegroundColor: true,
              hideUndoRedo: true,
              hideAlignment: true,
              hideDirection: true,
              hideStrikeThrough: true,
              hideIndentation: true,
            ),
          ),
          Divider(height: 1.h, thickness: 1.h, color: const Color(0xFFE8E8E8)),
          Expanded(
            child: Container(
              width: 1.sw - 32.w,
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              child: FleatherEditor(
                key: const ValueKey('post_content_editor'),
                controller: logic.controller,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorText() {
    return Obx(() {
      final error = logic.errorText.value.trim();
      if (error.isEmpty) return const SizedBox.shrink();
      return Container(
        key: const ValueKey('post_error_text'),
        width: 1.sw - 32.w,
        padding: EdgeInsets.only(bottom: 8.h),
        alignment: Alignment.centerLeft,
        child: Text(
          error,
          style: TextStyle(
            color: Colors.redAccent,
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    });
  }

  Widget _buildSubmitButton() {
    return Obx(() {
      final submitting = logic.isSubmitting.value;
      return GestureDetector(
        key: const ValueKey('post_submit_button'),
        onTap: submitting ? null : logic.submit,
        child: AnimatedOpacity(
          opacity: submitting ? 0.72 : 1,
          duration: const Duration(milliseconds: 160),
          child: Container(
            width: 1.sw - 32.w,
            height: Styles.compactButtonHeight,
            decoration: BoxDecoration(
              color: Styles.primaryTextColor,
              borderRadius: Styles.actionRadius,
            ),
            alignment: Alignment.center,
            child: submitting
                ? Row(
                    key: const ValueKey('post_submitting_label'),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16.w,
                        height: 16.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      8.horizontalSpace,
                      Text(
                        '发布中',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                : Text(
                    '发布',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      );
    });
  }
}
