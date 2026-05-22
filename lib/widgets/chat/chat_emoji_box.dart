import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../pi_image.dart';

class EmojiBox extends StatefulWidget {
  final Map<String, String> emojiList;
  final List<String> diyEmojiList;
  final Function(String t) onTap;

  const EmojiBox({
    required this.emojiList,
    required this.diyEmojiList,
    required this.onTap,
    super.key,
  });

  @override
  State<EmojiBox> createState() => _EmojiBoxState();
}

class _EmojiBoxState extends State<EmojiBox> {
  int emojiIndex = 0;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 1.sw,
      height: 224.h,
      child: Column(
        children: [
          Container(
            height: 30.h,
            margin: EdgeInsets.symmetric(vertical: 5.h),
            alignment: Alignment.center,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      emojiIndex = 0;
                    });
                  },
                  child: AnimatedOpacity(
                    opacity: emojiIndex == 0 ? 1 : 0.3,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      width: 24.w,
                      height: 24.w,
                      margin: EdgeInsets.symmetric(horizontal: 5.w),
                      child: Image.asset(
                        'assets/images/face.png',
                        width: 24.w,
                        height: 24.w,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      emojiIndex = 1;
                    });
                  },
                  child: AnimatedOpacity(
                    opacity: emojiIndex == 1 ? 1 : 0.3,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      width: 30.w,
                      height: 30.w,
                      margin: EdgeInsets.symmetric(horizontal: 5.w),
                      child: Icon(
                        Icons.photo,
                        size: 30.w,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SizedBox(
              width: 1.sw,
              child: [
                _buildDefaultEmojiBox(widget.emojiList),
                _buildDiyEmojiBox(widget.diyEmojiList)
              ][emojiIndex],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDefaultEmojiBox(emojiList) {
    List<Widget> list = [];
    emojiList.forEach((emojiName, value) {
      list.add(
        GestureDetector(
          key: ValueKey('emoji_default_$emojiName'),
          onTap: () {
            // logic.chatRoomControllerText.text = ':$key:';
            // logic.onInput(':$key:');
            // logic.clickSend();
            widget.onTap(':$emojiName:');
          },
          child: Container(
            width: 24.w,
            height: 24.w,
            alignment: Alignment.center,
            child: PiImage(
              imgUrl: value,
              width: 24.w,
              height: 24.w,
            ),
          ),
        ),
      );
    });
    // 返回一个GridView
    return GridView.count(
      crossAxisCount: 8,
      scrollDirection: Axis.vertical,
      //设置横向间距
      crossAxisSpacing: 4.w,
      //设置主轴间距
      mainAxisSpacing: 4.w,
      children: list,
    );
  }

  Widget _buildDiyEmojiBox(diyEmojiList) {
    List<Widget> list = [];
    for (var item in diyEmojiList) {
      list.add(
        GestureDetector(
          key: ValueKey('emoji_diy_$item'),
          onTap: () {
            // logic.chatRoomControllerText.text = '![图片表情]($item)';
            // logic.onInput('![图片表情]($item)');
            // logic.clickSend();
            widget.onTap('![图片表情]($item)');
          },
          child: Container(
            width: 24.w,
            height: 24.w,
            alignment: Alignment.center,
            child: PiImage(
              imgUrl: item,
              width: 80.w,
              height: 80.w,
            ),
          ),
        ),
      );
    }
    return GridView.count(
      crossAxisCount: 4,
      scrollDirection: Axis.vertical,
      //设置横向间距
      crossAxisSpacing: 4.w,
      //设置主轴间距
      mainAxisSpacing: 4.w,
      children: list,
    );
  }
}
