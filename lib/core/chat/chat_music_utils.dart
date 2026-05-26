import 'dart:convert';

import 'package:fishpi/types/chatroom.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

class ChatMusicTrack {
  final String id;
  final String type;
  final String source;
  final String coverURL;
  final String title;
  final String from;

  const ChatMusicTrack({
    required this.id,
    required this.type,
    required this.source,
    this.coverURL = '',
    this.title = '',
    this.from = '',
  });

  bool get isVoice => type == 'voice' || title.startsWith('语音消息');

  bool get isValid {
    final uri = Uri.tryParse(source.trim());
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  String get displayTitle {
    final cleanTitle = title.trim();
    if (cleanTitle.isNotEmpty) return cleanTitle;
    return isVoice ? '语音消息' : '音乐地址无效';
  }

  String get displaySource {
    final cleanFrom = from.trim();
    if (cleanFrom.isNotEmpty) return cleanFrom;
    return isVoice ? '点击播放' : '音乐';
  }

  static ChatMusicTrack fromMusicMsg(MusicMsg music) {
    final source = music.source.trim();
    return ChatMusicTrack(
      id: _trackId(source, music.title, music.type),
      type: music.type.trim().isEmpty ? 'music' : music.type.trim(),
      source: source,
      coverURL: music.coverURL.trim(),
      title: music.title.trim(),
      from: music.from.trim(),
    );
  }

  static ChatMusicTrack invalid({String title = '音乐地址无效'}) {
    return ChatMusicTrack(
      id: 'invalid_${title.hashCode}',
      type: 'music',
      source: '',
      title: title,
      from: '无法播放',
    );
  }

  static String _trackId(String source, String title, String type) {
    final key = source.trim().isNotEmpty ? source.trim() : '$title|$type';
    return 'music_${key.hashCode}';
  }
}

class ChatMusicUtils {
  ChatMusicUtils._();

  static MusicMsg? parseMusicMessage(String content) {
    final track = trackFromContent(content);
    if (track == null) return null;
    return MusicMsg(
      type: track.type,
      source: track.source,
      coverURL: track.coverURL,
      title: track.title,
      from: track.from,
    );
  }

  static ChatMusicTrack? trackFromMessage(ChatRoomMessage message) {
    if (message.music != null) {
      return ChatMusicTrack.fromMusicMsg(message.music!);
    }
    return trackFromContent(message.content);
  }

  static ChatMusicTrack? trackFromContent(String content) {
    final text = content.trim();
    if (text.isEmpty) return null;

    final bracket = _extractWrapped(text, 'music');
    if (bracket != null) {
      return _trackFromPayload(bracket, fallbackInvalid: true);
    }

    final direct = _trackFromPayload(text);
    if (direct != null) return direct;

    try {
      final document = html_parser.parse(text);
      final music = document.querySelector('music');
      if (music != null) return trackFromElement(music);
    } catch (_) {}

    return null;
  }

  static ChatMusicTrack? trackFromElement(dom.Element element) {
    final source = _attr(element, 'source') ??
        _attr(element, 'src') ??
        element.text.trim();
    final type = _attr(element, 'type') ?? 'music';
    final title = _attr(element, 'title') ?? (type == 'voice' ? '语音消息' : '');
    final track = ChatMusicTrack(
      id: ChatMusicTrack._trackId(source, title, type),
      type: type,
      source: source.trim(),
      coverURL: _attr(element, 'coverURL') ?? '',
      title: title,
      from: _attr(element, 'from') ?? '',
    );
    return track.isValid
        ? track
        : ChatMusicTrack.invalid(title: track.displayTitle);
  }

  static bool isVoiceMusic(MusicMsg music) {
    return ChatMusicTrack.fromMusicMsg(music).isVoice;
  }

  static String previewFor(MusicMsg music) {
    return previewForTrack(ChatMusicTrack.fromMusicMsg(music));
  }

  static String previewForTrack(ChatMusicTrack track) {
    if (track.isVoice) return '[语音]';
    final title = track.title.trim();
    return title.isEmpty ? '[音乐]' : '[音乐] $title';
  }

  static ChatMusicTrack? _trackFromPayload(
    String payload, {
    bool fallbackInvalid = false,
  }) {
    final text = payload.trim();
    if (text.isEmpty) {
      return fallbackInvalid ? ChatMusicTrack.invalid() : null;
    }

    final uri = Uri.tryParse(text);
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      return ChatMusicTrack(
        id: ChatMusicTrack._trackId(text, '', 'music'),
        type: 'music',
        source: text,
        title: '音乐',
        from: uri.host,
      );
    }

    try {
      final data = jsonDecode(text);
      if (data is Map) return _trackFromMap(data.cast<String, dynamic>());
    } catch (_) {}

    return fallbackInvalid ? ChatMusicTrack.invalid() : null;
  }

  static ChatMusicTrack? _trackFromMap(Map<String, dynamic> data) {
    final looksLikeMusic = data['msgType'] == ChatRoomMessageType.music ||
        data.containsKey('source') ||
        data.containsKey('url');
    if (!looksLikeMusic) return null;

    final source = (data['source'] ?? data['url'] ?? '').toString().trim();
    final type = (data['type'] ?? 'music').toString();
    final title = (data['title'] ?? '').toString();
    final track = ChatMusicTrack(
      id: ChatMusicTrack._trackId(source, title, type),
      type: type,
      source: source,
      coverURL: (data['coverURL'] ?? data['coverUrl'] ?? data['cover'] ?? '')
          .toString(),
      title: title,
      from: (data['from'] ?? data['artist'] ?? data['sourceName'] ?? '')
          .toString(),
    );
    return track.isValid
        ? track
        : ChatMusicTrack.invalid(title: track.displayTitle);
  }

  static String? _extractWrapped(String content, String tag) {
    final match = RegExp(
      '\\[$tag\\]([\\s\\S]*?)\\[/$tag\\]',
      caseSensitive: false,
    ).firstMatch(content);
    return match?.group(1)?.trim();
  }

  static String? _attr(dom.Element element, String name) {
    return element.attributes[name] ??
        element.attributes[name.toLowerCase()] ??
        element.attributes[name.toUpperCase()];
  }
}
