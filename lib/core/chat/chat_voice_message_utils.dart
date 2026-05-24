import 'dart:convert';

import 'package:fishpi/types/chatroom.dart';

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
    try {
      final data = jsonDecode(content);
      if (data is! Map) return null;
      if (data['msgType'] != ChatRoomMessageType.music) return null;
      return MusicMsg.from(data);
    } catch (_) {
      return null;
    }
  }

  static bool isVoiceMusic(MusicMsg music) {
    return music.type == 'voice' || music.title.startsWith('语音消息');
  }

  static String previewFor(MusicMsg music) {
    if (isVoiceMusic(music)) return '[语音]';
    final title = music.title.trim();
    return title.isEmpty ? '[音乐]' : '[音乐] $title';
  }

  static String formatDuration(int seconds) {
    final safeSeconds = seconds.clamp(0, maxRecordSeconds);
    return '${safeSeconds}s';
  }
}
