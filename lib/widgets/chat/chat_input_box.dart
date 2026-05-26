import 'package:animate_do/animate_do.dart';
import 'package:fishpi_app/widgets/chat/chat_emoji_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../res/styles.dart';
import '../pi_input.dart';

class ChatInputBox extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Map<String, String> emojiList;
  final List<String> diyEmojiList;
  final Function(String t) onInput;
  final Future<void> Function() clickSend;
  final Function() scrollToBottom;
  final String? content;
  final bool enableVoice;
  final bool isRecordingVoice;
  final bool isSendingVoice;
  final int voiceRecordSeconds;
  final Future<void> Function()? onVoiceRecordStart;
  final Future<void> Function()? onVoiceRecordFinish;
  final Future<void> Function()? onVoiceRecordCancel;
  final VoidCallback? onRedPacketTap;
  final VoidCallback? onTopicTap;

  const ChatInputBox({
    required this.controller,
    required this.focusNode,
    required this.emojiList,
    required this.diyEmojiList,
    required this.onInput,
    required this.clickSend,
    required this.scrollToBottom,
    this.content,
    this.enableVoice = true,
    this.isRecordingVoice = false,
    this.isSendingVoice = false,
    this.voiceRecordSeconds = 0,
    this.onVoiceRecordStart,
    this.onVoiceRecordFinish,
    this.onVoiceRecordCancel,
    this.onRedPacketTap,
    this.onTopicTap,
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
  bool _isVoicePressing = false;
  bool _isVoiceReleaseHandled = false;
  Future<void>? _voiceStartFuture;

  @override
  void initState() {
    widget.focusNode.addListener(_onFocusChange);
    super.initState();
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
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
                  _buildVoiceToggle(),
                  SizedBox(
                      width: 220.w,
                      child: isShowVoice
                          ? _buildVoiceButton()
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
                                onEditingComplete: () async {
                                  await widget.clickSend();
                                  if (!mounted) return;
                                  setState(() {
                                    content = widget.controller.text;
                                  });
                                },
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
                    onTap: () async {
                      if (content == '') {
                        toggleTools();
                      } else {
                        await widget.clickSend();
                        if (!mounted) return;
                        setState(() {
                          content = widget.controller.text;
                        });
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

  Widget _buildVoiceToggle() {
    if (!widget.enableVoice) return SizedBox(width: 24.w, height: 24.w);
    return GestureDetector(
      onTap: () {
        toggleVoice();
      },
      child: SizedBox(
        width: 24.w,
        height: 24.w,
        child: isShowVoice
            ? Image.asset('assets/images/keyboard.png')
            : const Icon(
                Icons.keyboard_voice_outlined,
              ),
      ),
    );
  }

  Widget _buildVoiceButton() {
    final recording = widget.isRecordingVoice;
    final sending = widget.isSendingVoice;
    final text = sending
        ? '语音发送中...'
        : recording
            ? '松开发送 ${widget.voiceRecordSeconds}s/60s'
            : '长按讲话';

    return GestureDetector(
      onLongPressStart: sending
          ? null
          : (_) async {
              await _startVoiceRecord();
            },
      onLongPressEnd: sending
          ? null
          : (_) async {
              await _finishVoiceRecord();
            },
      onLongPressCancel: sending
          ? null
          : () async {
              await _cancelVoiceRecord();
            },
      behavior: HitTestBehavior.translucent,
      child: Container(
        key: const ValueKey('chat_voice_record_button'),
        width: 220.w,
        height: 34.h,
        decoration: BoxDecoration(
          border: Border.all(
            width: 2.w,
            color: Styles.primaryTextColor,
          ),
          borderRadius: BorderRadius.circular(10),
          color: recording ? Styles.primaryColor : Colors.white,
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: Styles.primaryTextColor,
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildToolsBox() {
    List<Widget> list = [
      _buildToolItem(
        key: const ValueKey('chat_tool_image'),
        title: '图片',
        icon: Icon(Icons.photo, size: 30.w),
        onTap: () {},
      ),
      _buildToolItem(
        key: const ValueKey('chat_tool_camera'),
        title: '拍摄',
        icon: Icon(Icons.camera_alt, size: 30.w),
        onTap: () {},
      ),
      if (widget.onRedPacketTap != null)
        _buildToolItem(
          key: const ValueKey('chat_tool_red_packet'),
          title: '红包',
          icon: Image.asset(
            'assets/images/red-packet.png',
            width: 30.w,
            height: 30.w,
          ),
          onTap: () {
            closeAllTools();
            widget.onRedPacketTap?.call();
          },
        ),
      if (widget.onTopicTap != null)
        _buildToolItem(
          key: const ValueKey('chat_tool_topic'),
          title: '话题',
          icon: Icon(Icons.tag_outlined, size: 30.w),
          onTap: () {
            closeAllTools();
            widget.onTopicTap?.call();
          },
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

  Widget _buildToolItem({
    required Key key,
    required String title,
    required Widget icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      key: key,
      onTap: onTap,
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
              child: icon,
            ),
            5.verticalSpace,
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: Styles.primaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  focus() => FocusScope.of(context).requestFocus(widget.focusNode);

  unFocus() => FocusScope.of(context).requestFocus(FocusNode());

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
    if (!widget.enableVoice) return;
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

  Future<void> _startVoiceRecord() async {
    _isVoicePressing = true;
    _isVoiceReleaseHandled = false;
    final future = widget.onVoiceRecordStart?.call() ?? Future.value();
    _voiceStartFuture = future;
    await future;
    if (!mounted || _isVoicePressing || _isVoiceReleaseHandled) return;
    _isVoiceReleaseHandled = true;
    await widget.onVoiceRecordFinish?.call();
  }

  Future<void> _finishVoiceRecord() async {
    _isVoicePressing = false;
    await _voiceStartFuture;
    if (!mounted || _isVoiceReleaseHandled) return;
    _isVoiceReleaseHandled = true;
    await widget.onVoiceRecordFinish?.call();
  }

  Future<void> _cancelVoiceRecord() async {
    _isVoicePressing = false;
    await _voiceStartFuture;
    if (!mounted || _isVoiceReleaseHandled) return;
    _isVoiceReleaseHandled = true;
    await widget.onVoiceRecordCancel?.call();
  }

  void closeAllTools() {
    setState(() {
      isShowEmoji = false;
      isShowTools = false;
      isShowVoice = false;
    });
    unFocus();
  }

  void _onFocusChange() {
    if (!widget.focusNode.hasFocus) return;
    setState(() {
      isShowVoice = false;
      isShowTools = false;
      isShowEmoji = false;
    });
    widget.scrollToBottom();
  }
}
