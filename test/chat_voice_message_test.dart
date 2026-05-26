import 'package:fishpi/types/chatroom.dart';
import 'package:fishpi_app/core/chat/chat_music_utils.dart';
import 'package:fishpi_app/core/controller/chat_music_player.dart';
import 'package:fishpi_app/widgets/chat/chat_music_card.dart';
import 'package:fishpi_app/widgets/chat/chat_music_mini_player.dart';
import 'package:fishpi_app/widgets/chat/chat_weather_card.dart';
import 'package:fishpi_app/widgets/chat/chat_voice_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  tearDown(() {
    Get.reset();
  });

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

  testWidgets('音乐卡片展示标题、来源和播放入口', (tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 812),
        builder: (context, _) => const MaterialApp(
          home: Scaffold(
            body: ChatMusicCard(
              track: ChatMusicTrack(
                id: 'song-1',
                type: 'music',
                source: 'https://example.com/song.mp3',
                title: '歌名',
                from: '歌手',
              ),
              isSelf: false,
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('chat_music_card')), findsOneWidget);
    expect(find.text('歌名'), findsOneWidget);
    expect(find.text('歌手'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
  });

  testWidgets('音乐迷你播放器在队列非空时展示', (tester) async {
    final player = ChatMusicPlayerController.ensure();
    const track = ChatMusicTrack(
      id: 'song-1',
      type: 'music',
      source: 'https://example.com/song.mp3',
      title: '歌名',
      from: '歌手',
    );
    player.queue.assignAll([track]);
    player.currentTrack.value = track;
    player.currentIndex.value = 0;

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 812),
        builder: (context, _) => const MaterialApp(
          home: Scaffold(body: ChatMusicMiniPlayer()),
        ),
      ),
    );

    expect(
        find.byKey(const ValueKey('chat_music_mini_player')), findsOneWidget);
    expect(find.text('歌名'), findsOneWidget);
    expect(find.byKey(const ValueKey('chat_music_mini_queue_button')),
        findsOneWidget);
  });

  testWidgets('天气卡片展示城市、描述和今日温度', (tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 812),
        builder: (context, _) => MaterialApp(
          home: Scaffold(
            body: ChatWeatherCard(
              weather: WeatherMsg(
                city: '杭州',
                description: '晴',
                data: [
                  WeatherMsgData(date: '今天', code: 'sunny', min: 10, max: 20),
                ],
              ),
              isSelf: false,
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('chat_weather_card')), findsOneWidget);
    expect(find.text('杭州'), findsOneWidget);
    expect(find.text('晴'), findsOneWidget);
    expect(find.text('今日 10°/20°'), findsOneWidget);
  });
}
