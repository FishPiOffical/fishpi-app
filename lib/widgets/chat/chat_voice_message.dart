import 'package:fishpi/types/chatroom.dart';
import 'package:fishpi_app/core/chat/chat_music_utils.dart';
import 'package:fishpi_app/widgets/chat/chat_music_card.dart';
import 'package:flutter/material.dart';

/// 语音消息仍保留原组件名，内部接入统一音乐播放器。
///
/// 这样历史测试和旧调用不需要改，同时语音不会再和音乐卡片各自创建播放器。
class ChatVoiceMessage extends StatelessWidget {
  final MusicMsg music;
  final bool isSelf;

  const ChatVoiceMessage({
    super.key,
    required this.music,
    required this.isSelf,
  });

  @override
  Widget build(BuildContext context) {
    return ChatMusicCard(
      track: ChatMusicTrack.fromMusicMsg(music),
      isSelf: isSelf,
    );
  }
}
