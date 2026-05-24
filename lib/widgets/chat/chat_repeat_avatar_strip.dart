import 'package:fishpi/types/chatroom.dart';
import 'package:fishpi_app/res/styles.dart';
import 'package:fishpi_app/widgets/pi_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatRepeatAvatarStrip extends StatelessWidget {
  static const int maxSlots = 6;
  static const int maxVisibleAvatars = maxSlots - 1;

  final List<ChatRoomMessage> repeaters;
  final bool isSelf;
  final void Function(String userName)? onTapUser;

  const ChatRepeatAvatarStrip({
    super.key,
    required this.repeaters,
    required this.isSelf,
    this.onTapUser,
  });

  @override
  Widget build(BuildContext context) {
    if (repeaters.isEmpty) return const SizedBox.shrink();

    final visibleRepeaters = repeaters.take(maxVisibleAvatars).toList();
    final overflowCount = repeaters.length - visibleRepeaters.length;
    final children = <Widget>[
      for (final repeater in visibleRepeaters) _buildAvatar(repeater),
      if (overflowCount > 0) _buildOverflow(overflowCount),
    ];

    return Align(
      alignment: isSelf ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        key: const ValueKey('chat_repeat_avatar_strip'),
        margin: EdgeInsets.only(top: 6.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          textDirection: isSelf ? TextDirection.rtl : TextDirection.ltr,
          children: children,
        ),
      ),
    );
  }

  Widget _buildAvatar(ChatRoomMessage repeater) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      child: GestureDetector(
        onTap: repeater.userName.isEmpty || onTapUser == null
            ? null
            : () => onTapUser!(repeater.userName),
        child: PiAvatar(
          key: ValueKey('chat_repeat_avatar_${repeater.userName}'),
          avatarURL: repeater.avatarURL,
          userName: repeater.userName,
          width: 22.w,
          height: 22.w,
        ),
      ),
    );
  }

  Widget _buildOverflow(int count) {
    return Container(
      key: const ValueKey('chat_repeat_avatar_overflow'),
      width: 22.w,
      height: 22.w,
      margin: EdgeInsets.symmetric(horizontal: 2.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Styles.commonBorder,
        borderRadius: BorderRadius.circular(11.r),
      ),
      child: Text(
        '+$count',
        style: TextStyle(
          color: Styles.primaryTextColor,
          fontSize: 9.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
