import 'package:animate_do/animate_do.dart';
import 'package:fishpi_app/core/chat/chat_quote_utils.dart';
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
  final bool isSendingText;
  final int voiceRecordSeconds;
  final Future<void> Function()? onVoiceRecordStart;
  final Future<void> Function()? onVoiceRecordFinish;
  final Future<void> Function()? onVoiceRecordCancel;
  final VoidCallback? onImageTap;
  final VoidCallback? onCameraTap;
  final VoidCallback? onRedPacketTap;
  final VoidCallback? onBarragerTap;
  final VoidCallback? onExtensionTap;
  final Future<void> Function()? onEmojiPanelOpen;
  final String? topic;
  final VoidCallback? onTopicTap;
  final VoidCallback? onTopicQuoteTap;
  final ChatQuoteDraft? quoteDraft;
  final VoidCallback? onClearQuote;

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
    this.isSendingText = false,
    this.voiceRecordSeconds = 0,
    this.onVoiceRecordStart,
    this.onVoiceRecordFinish,
    this.onVoiceRecordCancel,
    this.onImageTap,
    this.onCameraTap,
    this.onRedPacketTap,
    this.onBarragerTap,
    this.onExtensionTap,
    this.onEmojiPanelOpen,
    this.topic,
    this.onTopicTap,
    this.onTopicQuoteTap,
    this.quoteDraft,
    this.onClearQuote,
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
    content = widget.controller.text;
    widget.controller.addListener(_syncContentFromController);
    widget.focusNode.addListener(_onFocusChange);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ChatInputBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_syncContentFromController);
      content = widget.controller.text;
      widget.controller.addListener(_syncContentFromController);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_syncContentFromController);
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _syncContentFromController() {
    if (!mounted || content == widget.controller.text) return;
    setState(() {
      content = widget.controller.text;
    });
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
            if (widget.onTopicTap != null) _buildTopicAssistBar(),
            if (widget.quoteDraft != null) _buildQuotePreview(),
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
                  6.horizontalSpace,
                  Expanded(
                    child: isShowVoice
                        ? _buildVoiceButton()
                        : SizedBox(
                            height: 38.h,
                            child: PiInput(
                              controller: widget.controller,
                              textAlign: isShowVoice
                                  ? TextAlign.center
                                  : TextAlign.left,
                              hintText: '说点什么...',
                              focusNode: widget.focusNode,
                              onInputChanged: widget.onInput,
                              onEditingComplete: () async {
                                if (!widget.isSendingText) {
                                  await widget.clickSend();
                                }
                              },
                            ),
                          ),
                  ),
                  6.horizontalSpace,
                  _buildIconButton(
                    key: const ValueKey('chat_emoji_button'),
                    label: '表情',
                    onTap: toggleEmoji,
                    child: Image.asset(
                      'assets/images/face.png',
                      width: 24.w,
                      height: 24.w,
                    ),
                  ),
                  _buildSendOrMoreButton(),
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
    if (!widget.enableVoice) return SizedBox(width: 44.w, height: 44.w);
    return _buildIconButton(
      key: const ValueKey('chat_voice_toggle_button'),
      label: isShowVoice ? '切换键盘输入' : '切换语音输入',
      onTap: toggleVoice,
      child: isShowVoice
          ? Image.asset(
              'assets/images/keyboard.png',
              width: 24.w,
              height: 24.w,
            )
          : Icon(
              Icons.keyboard_voice_outlined,
              size: 24.w,
              color: Styles.primaryTextColor,
            ),
    );
  }

  Widget _buildIconButton({
    required Key key,
    required String label,
    required Widget child,
    required VoidCallback? onTap,
  }) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        key: key,
        onTap: onTap,
        behavior: HitTestBehavior.translucent,
        child: SizedBox(
          width: 44.w,
          height: 44.w,
          child: Center(child: child),
        ),
      ),
    );
  }

  Widget _buildSendOrMoreButton() {
    final hasContent = content.trim().isNotEmpty;
    return _buildIconButton(
      key: const ValueKey('chat_send_or_more_button'),
      label: hasContent ? '发送消息' : '更多功能',
      onTap: widget.isSendingText
          ? null
          : () async {
              if (!hasContent) {
                toggleTools();
                return;
              }
              await widget.clickSend();
            },
      child: widget.isSendingText
          ? SizedBox(
              key: const ValueKey('chat_text_sending_indicator'),
              width: 20.w,
              height: 20.w,
              child: const CircularProgressIndicator(strokeWidth: 2),
            )
          : Image.asset(
              hasContent
                  ? 'assets/images/send.png'
                  : 'assets/images/more_feature.png',
              width: 28.w,
              height: 28.w,
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
        width: double.infinity,
        height: 38.h,
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

  Widget _buildQuotePreview() {
    final quote = widget.quoteDraft!;
    return Container(
      key: const ValueKey('chat_quote_preview'),
      width: 1.sw,
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Styles.commonBorder,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          children: [
            Container(
              width: 4.w,
              height: 34.h,
              decoration: BoxDecoration(
                color: Styles.primaryColor,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            8.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quote.title,
                    style: TextStyle(
                      color: const Color(0xFF777777),
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  2.verticalSpace,
                  Text(
                    quote.preview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Styles.primaryTextColor,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              key: const ValueKey('chat_quote_clear_button'),
              onTap: widget.onClearQuote,
              child: SizedBox(
                width: 32.w,
                height: 32.w,
                child: Icon(
                  Icons.close,
                  size: 18.w,
                  color: Styles.primaryTextColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicAssistBar() {
    final topic = widget.topic?.trim() ?? '';
    final hasTopic = topic.isNotEmpty;
    final isTopicQuoted = widget.quoteDraft?.type == ChatQuoteType.topic;
    final canQuote =
        hasTopic && !isTopicQuoted && widget.onTopicQuoteTap != null;
    final text = hasTopic
        ? isTopicQuoted
            ? '# 当前话题已引用'
            : '# $topic'
        : '# 设置话题';

    return Container(
      key: const ValueKey('chat_topic_assist_bar'),
      width: 1.sw,
      padding: EdgeInsets.fromLTRB(16.w, 7.h, 16.w, 0),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: widget.onTopicTap,
              behavior: HitTestBehavior.translucent,
              child: Container(
                height: 28.h,
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Row(
                  children: [
                    Icon(
                      Icons.tag_outlined,
                      color: const Color(0xFF555555),
                      size: 15.w,
                    ),
                    5.horizontalSpace,
                    Expanded(
                      child: Text(
                        text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: hasTopic
                              ? Styles.primaryTextColor
                              : const Color(0xFF777777),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    4.horizontalSpace,
                    Icon(
                      Icons.edit_outlined,
                      color: const Color(0xFF777777),
                      size: 14.w,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (canQuote) ...[
            8.horizontalSpace,
            GestureDetector(
              key: const ValueKey('chat_topic_quote_button'),
              onTap: widget.onTopicQuoteTap,
              child: Container(
                height: 26.h,
                padding: EdgeInsets.symmetric(horizontal: 9.w),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Styles.primaryColor,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '引用',
                  style: TextStyle(
                    color: Styles.primaryTextColor,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildToolsBox() {
    List<Widget> list = [
      _buildToolItem(
        key: const ValueKey('chat_tool_image'),
        title: '图片',
        icon: Icon(Icons.photo, size: 30.w),
        onTap: () {
          closeAllTools();
          widget.onImageTap?.call();
        },
      ),
      _buildToolItem(
        key: const ValueKey('chat_tool_camera'),
        title: '拍摄',
        icon: Icon(Icons.camera_alt, size: 30.w),
        onTap: () {
          closeAllTools();
          widget.onCameraTap?.call();
        },
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
      if (widget.onBarragerTap != null)
        _buildToolItem(
          key: const ValueKey('chat_tool_barrager'),
          title: '弹幕',
          icon: Icon(
            Icons.subtitles_outlined,
            size: 30.w,
            color: Styles.primaryTextColor,
          ),
          onTap: () {
            closeAllTools();
            widget.onBarragerTap?.call();
          },
        ),
      if (widget.onExtensionTap != null)
        _buildToolItem(
          key: const ValueKey('chat_tool_extension'),
          title: '扩展',
          icon: Icon(
            Icons.extension_outlined,
            size: 30.w,
            color: Styles.primaryTextColor,
          ),
          onTap: () {
            closeAllTools();
            widget.onExtensionTap?.call();
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
    final willShowEmoji = !isShowEmoji;
    setState(() {
      isShowEmoji = willShowEmoji;
      isShowTools = false;
      isShowVoice = false;
      isShowEmoji ? unFocus() : focus();
    });
    if (willShowEmoji) {
      widget.onEmojiPanelOpen?.call();
    }
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
