import 'package:fishpi_app/res/styles.dart';
import 'package:fleather/fleather.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../widgets/pi_title_bar.dart';
import 'post_logic.dart';

class PostPage extends StatelessWidget {
  final PostLogic logic = Get.put(PostLogic());

  PostPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PiTitleBar.back(
        title: '发帖',
      ),
      body: SafeArea(
        child: Container(
          width: 1.sw,
          height: 1.sh,
          padding: EdgeInsets.symmetric(
            horizontal: 16.w,
          ),
          child: Column(
            children: [
              TextField(
                controller: logic.titleController,
                decoration: InputDecoration(
                  hintText: '请输入标题',
                  border: InputBorder.none,
                ),
              ),
              Divider(),
              TextField(
                controller: logic.tagController,
                decoration: InputDecoration(
                  hintText: '请输入标签,多个标签用空格隔开',
                  border: InputBorder.none,
                ),
              ),
              Divider(),
              FleatherToolbar.basic(
                controller: logic.controller,
                hideBackgroundColor: true,
                hideForegroundColor: true,
                hideUndoRedo: true,
                hideAlignment: true,
                hideDirection: true,
                hideStrikeThrough: true,
                hideIndentation: true,
              ),
              Expanded(
                child: FleatherEditor(
                  controller: logic.controller,
                ),
              ),
              Divider(),
              GestureDetector(
                onTap: () {
                  logic.submit();
                },
                child: Container(
                  width: 1.sw - 32.w,
                  height: 42.h,
                  decoration: BoxDecoration(
                    color: Styles.primaryColor,
                    border: Styles.commonBorder,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Center(
                    child: Text("发布",style: TextStyle(fontSize: 18.sp),),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
