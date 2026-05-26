import 'package:fishpi/types/chatroom.dart';
import 'package:fishpi_app/widgets/chat/chat_repeat_avatar_strip.dart';
import 'package:fishpi_app/widgets/pi_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('重复消息头像条最多显示 5 个头像和数量标记', (tester) async {
    await tester.pumpWidget(
      _wrap(
        ChatRepeatAvatarStrip(
          repeaters: List.generate(
            7,
            (index) => ChatRoomMessage(
              userOId: index + 1,
              userName: 'user$index',
            ),
          ),
          isSelf: false,
        ),
      ),
    );

    expect(find.byKey(const ValueKey('chat_repeat_avatar_strip')), findsOne);
    expect(find.byType(PiAvatar), findsNWidgets(5));
    expect(find.text('+2'), findsOneWidget);
  });

  testWidgets('点击重复消息头像会回调用户名', (tester) async {
    String? tappedUserName;

    await tester.pumpWidget(
      _wrap(
        ChatRepeatAvatarStrip(
          repeaters: [
            ChatRoomMessage(userOId: 1, userName: 'follow-user'),
          ],
          isSelf: false,
          onTapUser: (userName) => tappedUserName = userName,
        ),
      ),
    );

    await tester.tap(find.byType(PiAvatar));
    expect(tappedUserName, 'follow-user');
  });

  testWidgets('长按重复消息头像会回调对应消息', (tester) async {
    ChatRoomMessage? pressedMessage;

    await tester.pumpWidget(
      _wrap(
        ChatRepeatAvatarStrip(
          repeaters: [
            ChatRoomMessage(userOId: 1, userName: 'follow-user'),
          ],
          isSelf: false,
          onLongPressUser: (message) => pressedMessage = message,
        ),
      ),
    );

    await tester.longPress(find.byType(PiAvatar));
    expect(pressedMessage?.userName, 'follow-user');
  });
}

Widget _wrap(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(360, 812),
    builder: (context, _) => MaterialApp(home: Scaffold(body: child)),
  );
}
