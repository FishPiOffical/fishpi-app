import 'package:fishpi_app/core/chat/chat_topic_utils.dart';
import 'package:fishpi_app/res/styles.dart';
import 'package:fishpi_app/widgets/pi_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ChatTopicSheet extends StatefulWidget {
  final String initialTopic;
  final Future<bool> Function(String topic) onSubmit;

  const ChatTopicSheet({
    super.key,
    required this.initialTopic,
    required this.onSubmit,
  });

  @override
  State<ChatTopicSheet> createState() => _ChatTopicSheetState();
}

class _ChatTopicSheetState extends State<ChatTopicSheet> {
  late final TextEditingController _controller;
  String _error = '';
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialTopic);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: 1.sw,
        padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 16.h),
        decoration: BoxDecoration(
          color: Styles.titleBarColor,
          border: Styles.commonBorder,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '聊天室话题',
              style: TextStyle(
                color: Styles.primaryTextColor,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            14.verticalSpace,
            SizedBox(
              height: 48.h,
              child: PiInput(
                key: const ValueKey('chat_topic_input'),
                controller: _controller,
                hintText: '输入话题，留空清除',
                prefixIcon: const Icon(Icons.tag_outlined),
                textAlign: TextAlign.left,
                textInputAction: TextInputAction.done,
                onInputChanged: (_) {
                  setState(() => _error = '');
                },
              ),
            ),
            8.verticalSpace,
            Text(
              '${_controller.text.trim().length}/${ChatTopicUtils.maxTopicLength}',
              style: TextStyle(
                color: const Color(0xFF777777),
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_error.isNotEmpty) ...[
              8.verticalSpace,
              Text(
                _error,
                key: const ValueKey('chat_topic_error'),
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            18.verticalSpace,
            Row(
              children: [
                Expanded(
                  child: _buildButton(
                    text: '取消',
                    isPrimary: false,
                    onTap: _submitting ? null : () => Get.back(),
                  ),
                ),
                12.horizontalSpace,
                Expanded(
                  child: _buildButton(
                    key: const ValueKey('chat_topic_submit_button'),
                    text: _submitting ? '保存中...' : '保存',
                    isPrimary: true,
                    onTap: _submitting ? null : _submit,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    Key? key,
    required String text,
    required bool isPrimary,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      key: key,
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? .55 : 1,
        child: Container(
          height: 46.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isPrimary ? Styles.primaryTextColor : Colors.white,
            border: Styles.commonBorder,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: isPrimary ? Colors.white : Styles.primaryTextColor,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final topic = ChatTopicUtils.normalizeTopic(_controller.text);
    final error = ChatTopicUtils.validateTopic(topic);
    if (error != null) {
      setState(() => _error = error);
      return;
    }

    setState(() => _submitting = true);
    final success = await widget.onSubmit(topic);
    if (!mounted) return;
    setState(() => _submitting = false);
    if (success) Get.back();
  }
}
