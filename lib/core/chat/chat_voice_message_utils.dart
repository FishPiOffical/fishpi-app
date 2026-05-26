import 'dart:convert';

import 'package:fishpi/types/chatroom.dart';
import 'package:fishpi_app/core/chat/chat_music_utils.dart';

class ChatVoiceMessageUtils {
  static const int maxRecordSeconds = 60;
  static const int minRecordSeconds = 1;

  ChatVoiceMessageUtils._();

  static String buildMusicMessage({
    required String url,
    required int durationSeconds,
  }) {
    return jsonEncode({
      'msgType': ChatRoomMessageType.music,
      'type': 'voice',
      'source': url,
      'coverURL': '',
      'title': '语音消息 ${formatDuration(durationSeconds)}',
      'from': '摸鱼派 App',
    });
  }

  static MusicMsg? parseMusicMessage(String content) {
    return ChatMusicUtils.parseMusicMessage(content);
  }

  static bool isVoiceMusic(MusicMsg music) {
    return ChatMusicUtils.isVoiceMusic(music);
  }

  static String previewFor(MusicMsg music) {
    return ChatMusicUtils.previewFor(music);
  }

  static String formatDuration(int seconds) {
    final safeSeconds = seconds.clamp(0, maxRecordSeconds);
    return '${safeSeconds}s';
  }
}
