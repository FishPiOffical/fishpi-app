import 'package:fishpi_app/res/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PiEditWidget extends StatelessWidget {
  final ValueChanged onEditingCompleteText;
  final TextEditingController controller = TextEditingController();
  final String? title;

  PiEditWidget({
    super.key,
    required this.onEditingCompleteText,
    this.title = '发表评论',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              child: Container(
                color: Colors.black.withOpacity(.5),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),
          Container(
            color: const Color(0xFFF3F3F3),
            padding: EdgeInsets.only(
              left: 16.w,
              top: 8.w,
              bottom: 18.h,
              right: 16.w,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    '取消',
                    style: TextStyle(
                      color: const Color(0xFF191722),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  title ?? '发表评论',
                  style: TextStyle(
                    color: const Color(0xFF191722),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    onEditingCompleteText(controller.text);
                    Navigator.pop(context);
                  },
                  child: Text(
                    '确定',
                    style: TextStyle(
                      color: Color(0xFF191722),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
              color: const Color(0xFFF3F3F3),
              padding: EdgeInsets.only(
                  left: 16.w, top: 8.w, bottom: 8.w, right: 16.w),
              child: Container(
                decoration: const BoxDecoration(color: Color(0xFFF3F3F3)),
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Styles.primaryTextColor,
                  ),
                  //设置键盘按钮为发送
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.multiline,
                  onEditingComplete: () {
                    //点击发送调用
                    onEditingCompleteText(controller.text);
                    Navigator.pop(context);
                  },
                  maxLength: 999,
                  decoration: InputDecoration(
                    hintText: '善语皆善缘,恶言伤人心',
                    hintStyle: const TextStyle(color: Color(0x4D000000)),
                    isDense: true,
                    contentPadding: EdgeInsets.only(
                        left: 10.w, top: 5.w, bottom: 5.w, right: 10.w),
                    border: const OutlineInputBorder(
                      gapPadding: 0,
                      borderSide: BorderSide(
                        width: 0,
                        style: BorderStyle.none,
                      ),
                    ),
                  ),
                ),
              ))
        ],
      ),
    );
  }
}
