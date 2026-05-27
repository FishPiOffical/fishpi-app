import 'package:fishpi_app/core/chat/chat_room_extension_runtime.dart';
import 'package:fishpi_app/res/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatRoomExtensionTriggerSheet extends StatefulWidget {
  final ChatRoomExtensionRenderResult result;
  final void Function(String text) onInsert;
  final Future<bool> Function(String text) onSend;

  const ChatRoomExtensionTriggerSheet({
    required this.result,
    required this.onInsert,
    required this.onSend,
    super.key,
  });

  @override
  State<ChatRoomExtensionTriggerSheet> createState() =>
      _ChatRoomExtensionTriggerSheetState();
}

class _ChatRoomExtensionTriggerSheetState
    extends State<ChatRoomExtensionTriggerSheet> {
  bool _sending = false;

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    return SafeArea(
      child: Container(
        key: const ValueKey('chat_room_extension_trigger_sheet'),
        width: 1.sw,
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
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
                Expanded(
                  child: Text(
                    result.extension.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Styles.primaryTextColor,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.close,
                    size: 22.w,
                    color: Styles.primaryTextColor,
                  ),
                ),
              ],
            ),
            6.verticalSpace,
            Text(
              '触发来源：${result.triggerLabel}',
              style: TextStyle(
                color: const Color(0xFF777777),
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            14.verticalSpace,
            Container(
              key: const ValueKey('chat_room_extension_trigger_preview'),
              width: 1.sw - 32.w,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Styles.commonBorder,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Text(
                result.text,
                style: TextStyle(
                  color: Styles.primaryTextColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            16.verticalSpace,
            Row(
              children: [
                Expanded(
                  child: _buildButton(
                    key: const ValueKey('chat_room_extension_trigger_insert'),
                    text: '填入输入框',
                    primary: false,
                    onTap: () {
                      widget.onInsert(result.text);
                      Navigator.pop(context);
                    },
                  ),
                ),
                10.horizontalSpace,
                Expanded(
                  child: _buildButton(
                    key: const ValueKey('chat_room_extension_trigger_send'),
                    text: _sending ? '发送中...' : '发送',
                    primary: true,
                    onTap: _sending ? null : _send,
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
    required Key key,
    required String text,
    required bool primary,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      key: key,
      onTap: onTap,
      child: Container(
        height: 42.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: primary ? Styles.primaryTextColor : Colors.white,
          border: Styles.commonBorder,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: primary ? Colors.white : Styles.primaryTextColor,
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<void> _send() async {
    setState(() => _sending = true);
    final success = await widget.onSend(widget.result.text);
    if (!mounted) return;
    setState(() => _sending = false);
    if (success) Navigator.pop(context);
  }
}
