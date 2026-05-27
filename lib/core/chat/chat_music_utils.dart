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
    final source = ChatMusicUtils.normalizePlayableSource(music.source);
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

  static final RegExp _numberSourcePattern = RegExp(r'^\d+$');

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
    final source = normalizePlayableSource(
      _attr(element, 'source') ??
          _attr(element, 'src') ??
          _attr(element, 'url') ??
          _attr(element, 'id') ??
          _attr(element, 'songId') ??
          _attr(element, 'musicId') ??
          element.text.trim(),
    );
    final type = _attr(element, 'type') ?? 'music';
    final title = _attr(element, 'title') ??
        _attr(element, 'name') ??
        _attr(element, 'songName') ??
        (type == 'voice' ? '语音消息' : '');
    final track = ChatMusicTrack(
      id: ChatMusicTrack._trackId(source, title, type),
      type: type,
      source: source,
      coverURL: _attr(element, 'coverURL') ??
          _attr(element, 'coverUrl') ??
          _attr(element, 'cover') ??
          _attr(element, 'picUrl') ??
          _attr(element, 'pic') ??
          _attr(element, 'image') ??
          '',
      title: title,
      from: _attr(element, 'from') ??
          _attr(element, 'artist') ??
          _attr(element, 'artistName') ??
          _attr(element, 'singer') ??
          _attr(element, 'sourceName') ??
          '',
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

  /// 参考鱼派网页端播放器增强脚本：裸数字 source 是网易云歌曲 id，
  /// 播放前需要转换成 media/outer/url 形式，音频组件才能直接播放。
  static String normalizePlayableSource(String? rawSource) {
    final source = (rawSource ?? '').trim();
    if (source.isEmpty) return '';
    if (_numberSourcePattern.hasMatch(source)) {
      return _neteaseOuterUrl(source);
    }

    final protocolRelative = source.startsWith('//') ? 'https:$source' : source;
    final uri = Uri.tryParse(protocolRelative);
    if (uri == null) return source;
    final songId = _neteaseSongId(uri);
    if (songId != null && songId.isNotEmpty) {
      return _neteaseOuterUrl(songId);
    }
    return protocolRelative;
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
      final source = normalizePlayableSource(text);
      return ChatMusicTrack(
        id: ChatMusicTrack._trackId(source, '', 'music'),
        type: 'music',
        source: source,
        title: '音乐',
        from: Uri.tryParse(source)?.host ?? uri.host,
      );
    }

    if (_numberSourcePattern.hasMatch(text)) {
      final source = normalizePlayableSource(text);
      return ChatMusicTrack(
        id: ChatMusicTrack._trackId(source, '', 'music'),
        type: 'music',
        source: source,
        title: '音乐',
        from: '网易云音乐',
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
        data.containsKey('url') ||
        data.containsKey('src') ||
        _hasSongIdWithMeta(data);
    if (!looksLikeMusic) return null;

    final source = normalizePlayableSource(
      _firstText(data, const [
        'source',
        'url',
        'src',
        'musicUrl',
        'musicURL',
        'audio',
        'audioUrl',
        'audioURL',
        'id',
        'songId',
        'songID',
        'musicId',
        'musicID',
      ]),
    );
    final type = (data['type'] ?? 'music').toString();
    final title = _firstText(data, const ['title', 'name', 'songName']) ?? '';
    final track = ChatMusicTrack(
      id: ChatMusicTrack._trackId(source, title, type),
      type: type,
      source: source,
      coverURL: _firstText(data, const [
            'coverURL',
            'coverUrl',
            'cover',
            'picUrl',
            'picURL',
            'pic',
            'image',
            'img',
          ]) ??
          '',
      title: title,
      from: _firstText(data, const [
            'from',
            'artist',
            'artistName',
            'author',
            'singer',
            'sourceName',
          ]) ??
          '',
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

  static String _neteaseOuterUrl(String songId) {
    return 'https://music.163.com/song/media/outer/url?id=$songId';
  }

  static String? _neteaseSongId(Uri uri) {
    if (!uri.host.toLowerCase().contains('music.163.com')) return null;
    final mediaMatch = RegExp(r'/song/media/outer/url/?$').hasMatch(uri.path);
    final songPageMatch = RegExp(r'/song/?$').hasMatch(uri.path);
    final id = uri.queryParameters['id'];
    if ((mediaMatch || songPageMatch) && id != null) return id;

    // 分享链接通常把歌曲路径放在 fragment 中，例如 /#/song?id=123。
    final fragmentUri = Uri.tryParse(uri.fragment);
    if (fragmentUri != null && RegExp(r'/song/?$').hasMatch(fragmentUri.path)) {
      return fragmentUri.queryParameters['id'];
    }
    return null;
  }

  static String? _firstText(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return null;
  }

  static bool _hasAny(Map<String, dynamic> data, List<String> keys) {
    return keys.any(data.containsKey);
  }

  static bool _hasSongIdWithMeta(Map<String, dynamic> data) {
    return _hasAny(data, const [
          'id',
          'songId',
          'songID',
          'musicId',
          'musicID',
        ]) &&
        _hasAny(data, const [
          'title',
          'name',
          'songName',
          'artist',
          'artistName',
          'singer',
          'coverURL',
          'coverUrl',
          'cover',
          'picUrl',
          'pic',
          'image',
        ]);
  }

  static String? _attr(dom.Element element, String name) {
    final kebabName = name.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => '-${match.group(1)!.toLowerCase()}',
    );
    return element.attributes[name] ??
        element.attributes[name.toLowerCase()] ??
        element.attributes[name.toUpperCase()] ??
        element.attributes['data-$name'] ??
        element.attributes['data-${name.toLowerCase()}'] ??
        element.attributes['data-$kebabName'];
  }
}
