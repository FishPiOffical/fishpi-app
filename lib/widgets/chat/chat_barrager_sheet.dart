import 'package:fishpi/types/chatroom.dart';
import 'package:fishpi_app/core/chat/chat_barrager_utils.dart';
import 'package:fishpi_app/res/styles.dart';
import 'package:fishpi_app/widgets/pi_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ChatBarragerSheet extends StatefulWidget {
  final BarrageCost? cost;
  final Future<bool> Function(String content, String color) onSubmit;

  const ChatBarragerSheet({
    super.key,
    this.cost,
    required this.onSubmit,
  });

  @override
  State<ChatBarragerSheet> createState() => _ChatBarragerSheetState();
}

class _ChatBarragerSheetState extends State<ChatBarragerSheet> {
  final _contentController = TextEditingController();
  String _color = ChatBarragerUtils.colors.first;
  String _error = '';
  bool _submitting = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cost = widget.cost;
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
            Row(
              children: [
                Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: Styles.primaryTextColor,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.subtitles_outlined,
                    color: Styles.primaryColor,
                    size: 22.w,
                  ),
                ),
                10.horizontalSpace,
                Expanded(
                  child: Text(
                    '发送弹幕',
                    style: TextStyle(
                      color: Styles.primaryTextColor,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _submitting ? null : () => Get.back(),
                  child: Icon(
                    Icons.close,
                    size: 22.w,
                    color: Styles.primaryTextColor,
                  ),
                ),
              ],
            ),
            14.verticalSpace,
            Text(
              cost == null ? '弹幕会从屏幕右侧滑入' : '每条弹幕消耗 ${cost.cost} ${cost.unit}',
              style: TextStyle(
                color: const Color(0xFF777777),
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            12.verticalSpace,
            SizedBox(
              height: 46.h,
              child: PiInput(
                key: const ValueKey('chat_barrager_content_input'),
                controller: _contentController,
                hintText: '输入弹幕内容',
                textAlign: TextAlign.left,
                textInputAction: TextInputAction.done,
                onInputChanged: (_) {
                  if (_error.isNotEmpty) setState(() => _error = '');
                },
              ),
            ),
            12.verticalSpace,
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                for (final color in ChatBarragerUtils.colors)
                  _buildColorItem(color),
              ],
            ),
            if (_error.isNotEmpty) ...[
              12.verticalSpace,
              Text(
                _error,
                key: const ValueKey('chat_barrager_form_error'),
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            18.verticalSpace,
            GestureDetector(
              key: const ValueKey('chat_barrager_submit_button'),
              onTap: _submitting ? null : _submit,
              child: Opacity(
                opacity: _submitting ? .55 : 1,
                child: Container(
                  height: 48.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Styles.primaryTextColor,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    _submitting ? '发送中...' : '发射弹幕',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorItem(String color) {
    final selected = _color == color;
    final parsed =
        Color(int.parse('FF${color.replaceFirst('#', '')}', radix: 16));
    return GestureDetector(
      key: ValueKey('chat_barrager_color_$color'),
      onTap: () => setState(() => _color = color),
      child: Container(
        width: 34.w,
        height: 34.w,
        decoration: BoxDecoration(
          color: parsed,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? Styles.primaryTextColor : Colors.white,
            width: selected ? 3.w : 2.w,
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final content = ChatBarragerUtils.normalizeContent(_contentController.text);
    final error = ChatBarragerUtils.validateContent(content);
    if (error != null) {
      setState(() => _error = error);
      return;
    }

    setState(() => _submitting = true);
    final success = await widget.onSubmit(content, _color);
    if (!mounted) return;
    setState(() => _submitting = false);
    if (success) Get.back();
  }
}
