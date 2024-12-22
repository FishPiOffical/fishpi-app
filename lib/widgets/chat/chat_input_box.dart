import 'package:animate_do/animate_do.dart';
import 'package:fishpi_app/widgets/chat/chat_emoji_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/controller/im.dart';
import '../../res/styles.dart';
import '../pi_input.dart';

class ChatInputBox extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Map<String, String> emojiList;
  final List<String> diyEmojiList;
  final Function(String t) onInput;
  final Function() clickSend;
  final Function() scrollToBottom;
  final String? content;

  const ChatInputBox({
    required this.controller,
    required this.focusNode,
    required this.emojiList,
    required this.diyEmojiList,
    required this.onInput,
    required this.clickSend,
    required this.scrollToBottom,
    this.content,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => ChatInputBoxState();
}

class ChatInputBoxState extends State<ChatInputBox> {
  bool isShowEmoji = false;
  bool isShowTools = false;
  bool isShowVoice = false;
  String content = "";

  @override
  void initState() {
    widget.focusNode.addListener(() {
      if (widget.focusNode.hasFocus) {
        setState(() {
          isShowVoice = false;
          isShowTools = false;
          isShowEmoji = false;
        });
        widget.scrollToBottom();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            width: 2.w,
            color: Styles.primaryTextColor,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 10.h,
              ),
              // height: 35.h,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      toggleVoice();
                    },
                    child: Container(
                      width: 24.w,
                      height: 24.w,
                      child: isShowVoice
                          ? Image.asset('assets/images/keyboard.png')
                          : const Icon(
                              Icons.keyboard_voice_outlined,
                            ),
                    ),
                  ),
                  SizedBox(
                      width: 220.w,
                      child: isShowVoice
                          ? GestureDetector(
                              onTap: () {},
                              behavior: HitTestBehavior.translucent,
                              child: Container(
                                width: 220.w,
                                height: 34.h,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 2.w,
                                    color: Styles.primaryTextColor,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '长按讲话',
                                  style: TextStyle(
                                    color: Styles.primaryTextColor,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                          : SizedBox(
                              width: 220.w,
                              height: 34.h,
                              child: PiInput(
                                controller: widget.controller,
                                textAlign: isShowVoice
                                    ? TextAlign.center
                                    : TextAlign.left,
                                hintText: '说点什么...',
                                focusNode: widget.focusNode,
                                onInputChanged: (t) {
                                  setState(() {
                                    content = t;
                                    widget.onInput(t);
                                  });
                                },
                                onEditingComplete: widget.clickSend,
                              ),
                            )),
                  GestureDetector(
                    onTap: () {
                      toggleEmoji();
                    },
                    child: SizedBox(
                      width: 24.w,
                      height: 24.w,
                      child: Image.asset(
                        'assets/images/face.png',
                        width: 24.w,
                        height: 24.w,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (content == '') {
                        toggleTools();
                      } else {
                        widget.clickSend();
                      }
                    },
                    child: Container(
                      width: 28.w,
                      height: 28.w,
                      alignment: Alignment.center,
                      child: Image.asset(
                        content == ''
                            ? 'assets/images/more_feature.png'
                            : 'assets/images/send.png',
                        width: 28.w,
                        height: 28.w,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: isShowEmoji,
              child: FadeIn(
                duration: const Duration(milliseconds: 200),
                child: EmojiBox(
                    emojiList: widget.emojiList,
                    diyEmojiList: widget.diyEmojiList,
                    onTap: (String t) {
                      setState(() {
                        widget.controller.text = widget.controller.text + t;
                        content = widget.controller.text;
                        widget.onInput(widget.controller.text);
                      });
                    }),
              ),
            ),
            Visibility(
              visible: isShowTools,
              child: FadeIn(
                duration: const Duration(milliseconds: 200),
                child: _buildToolsBox(),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildToolsBox() {
    List<Widget> list = [
      GestureDetector(
        onTap: () {},
        child: Container(
          width: 80.w,
          height: 80.w,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50.w,
                height: 50.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.w),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.photo,
                  size: 30.w,
                ),
              ),
              5.verticalSpace,
              Text(
                '图片',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: Styles.primaryTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
      GestureDetector(
        onTap: () {},
        child: Container(
          width: 80.w,
          height: 80.w,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50.w,
                height: 50.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.w),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.camera_alt,
                  size: 30.w,
                ),
              ),
              5.verticalSpace,
              Text(
                '拍摄',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: Styles.primaryTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
      GestureDetector(
        onTap: () {},
        child: Container(
          width: 80.w,
          height: 80.w,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50.w,
                height: 50.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.w),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.shopping_bag,
                  size: 30.w,
                ),
              ),
              5.verticalSpace,
              Text(
                '红包',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: Styles.primaryTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    ];
    return Container(
      width: 1.sw,
      height: 224.h,
      padding: EdgeInsets.all(10.w),
      color: const Color(0xFFF5F7F9),
      child: GridView.count(
        crossAxisCount: 4,
        scrollDirection: Axis.vertical,
        //设置横向间距
        crossAxisSpacing: 4.w,
        //设置主轴间距
        mainAxisSpacing: 4.w,
        children: list,
      ),
    );
  }

  focus() => FocusScope.of(Get.context!).requestFocus(widget.focusNode);

  unFocus() => FocusScope.of(Get.context!).requestFocus(FocusNode());

  void toggleTools() {
    setState(() {
      isShowTools = !isShowTools;
      isShowEmoji = false;
      isShowVoice = false;
      isShowTools ? unFocus() : focus();
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      widget.scrollToBottom();
    });
  }

  void toggleEmoji() {
    setState(() {
      isShowEmoji = !isShowEmoji;
      isShowTools = false;
      isShowVoice = false;
      isShowEmoji ? unFocus() : focus();
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      widget.scrollToBottom();
    });
  }

  void toggleVoice() {
    setState(() {
      isShowVoice = !isShowVoice;
      isShowTools = false;
      isShowEmoji = false;
      isShowVoice ? unFocus() : focus();
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      widget.scrollToBottom();
    });
  }

  void closeAllTools() {
    isShowEmoji = false;
    isShowTools = false;
    isShowVoice = false;
    unFocus();
  }
}
