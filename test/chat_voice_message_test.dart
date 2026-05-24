import 'package:fishpi/types/chatroom.dart';
import 'package:fishpi_app/widgets/chat/chat_voice_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('语音消息卡片展示标题和播放入口', (tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 812),
        builder: (context, _) => MaterialApp(
          home: Scaffold(
            body: ChatVoiceMessage(
              music: MusicMsg(
                type: 'voice',
                source: 'https://example.com/a.m4a',
                title: '语音消息 5s',
                from: '摸鱼派 App',
              ),
              isSelf: false,
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('chat_voice_message')), findsOneWidget);
    expect(find.text('语音消息 5s'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
  });
}
