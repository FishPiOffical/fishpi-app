import 'dart:collection';

import 'package:fishpi/types/chat.dart';
import 'package:fishpi/types/chatroom.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';

import 'chat_voice_message_utils.dart';
import '../sql/black_list.dart';
import '../sql/chat_room_block_list.dart';

class ParsedChatContent {
  final List<dom.Element> elements;
  final String preview;
  final String plainText;
  final String? singleImageUrl;

  const ParsedChatContent({
    required this.elements,
    required this.preview,
    required this.plainText,
    this.singleImageUrl,
  });
}

class ChatMessageGroup {
  final ChatRoomMessage message;
  final List<ChatRoomMessage> repeaters;

  const ChatMessageGroup({
    required this.message,
    this.repeaters = const [],
  });

  bool get hasRepeaters => repeaters.isNotEmpty;
}

class ChatMessageUtils {
  static const int previewCacheLimit = 200;
  static final LinkedHashMap<String, ParsedChatContent> _contentCache =
      LinkedHashMap<String, ParsedChatContent>();

  static ChatRoomMessage chatDataToRoomMessage(ChatData data) {
    return ChatRoomMessage(
      oId: data.oId,
      content: data.content,
      userName: data.senderUserName,
      userOId: int.tryParse(data.fromId) ?? 0,
      time: data.time,
      avatarURL: data.senderAvatar,
      md: data.markdown,
    );
  }

  static List<ChatRoomMessage> appendUniqueChatRoomMessage(
    List<ChatRoomMessage> source,
    ChatRoomMessage message, {
    int? maxLength,
  }) {
    final key = messageKey(message);
    if (key.isNotEmpty && source.any((item) => messageKey(item) == key)) {
      return List<ChatRoomMessage>.from(source);
    }

    final next = List<ChatRoomMessage>.from(source)..add(message);
    if (maxLength != null && next.length > maxLength) {
      return next.sublist(next.length - maxLength);
    }
    return next;
  }

  static List<ChatRoomMessage> prependUniqueChatRoomMessages(
    List<ChatRoomMessage> source,
    Iterable<ChatRoomMessage> history,
  ) {
    final existingKeys = source.map(messageKey).where((key) => key.isNotEmpty);
    final seenKeys = existingKeys.toSet();
    final olderMessages = <ChatRoomMessage>[];

    for (final message in history) {
      final key = messageKey(message);
      if (key.isNotEmpty && seenKeys.contains(key)) continue;
      if (key.isNotEmpty) seenKeys.add(key);
      olderMessages.add(message);
    }

    return [
      ...olderMessages,
      ...source,
    ];
  }

  static List<ChatRoomMessage> visibleMessages(
    Iterable<ChatRoomMessage> messages,
    Iterable<BlackUser> blackUsers, {
    Iterable<ChatRoomBlockedUser> chatRoomBlockedUsers = const [],
  }) {
    final visibleByBlackList = BlackList.visibleItems(
      messages,
      blackUsers,
      oId: (message) => message.userOId.toString(),
      userName: (message) => message.userName,
    );
    return ChatRoomBlockList.visibleItems(
      visibleByBlackList,
      chatRoomBlockedUsers,
      oId: (message) => message.userOId > 0 ? message.userOId.toString() : null,
      userName: (message) => message.userName,
    );
  }

  static List<ChatMessageGroup> groupConsecutiveDuplicateMessages(
    Iterable<ChatRoomMessage> messages,
  ) {
    final groups = <ChatMessageGroup>[];
    ChatRoomMessage? currentMessage;
    final currentRepeaters = <ChatRoomMessage>[];
    final repeaterKeys = <String>{};

    void flushCurrent() {
      final message = currentMessage;
      if (message == null) return;
      groups.add(
        ChatMessageGroup(
          message: message,
          repeaters: List<ChatRoomMessage>.from(currentRepeaters),
        ),
      );
      currentRepeaters.clear();
      repeaterKeys.clear();
    }

    for (final message in messages) {
      final base = currentMessage;
      if (base != null && _isConsecutiveDuplicate(base, message)) {
        final key = _senderKey(message);
        if (key.isNotEmpty && repeaterKeys.add(key)) {
          currentRepeaters.add(message);
        }
        continue;
      }

      flushCurrent();
      currentMessage = message;
    }

    flushCurrent();
    return groups;
  }

  static bool hasMoreHistoryPage(int rawCount) {
    return rawCount > 0;
  }

  static List<ChatRoomMessage> removeChatRoomMessage(
    List<ChatRoomMessage> source,
    String messageId,
  ) {
    if (messageId.isEmpty) return List<ChatRoomMessage>.from(source);
    return source.where((message) => message.oId != messageId).toList();
  }

  static String messageKey(ChatRoomMessage message) {
    if (message.oId.isNotEmpty) return message.oId;
    if (message.content.isEmpty && message.time.isEmpty) return '';
    return '${message.userName}|${message.time}|${message.content.hashCode}';
  }

  static bool _isConsecutiveDuplicate(
    ChatRoomMessage base,
    ChatRoomMessage next,
  ) {
    if (!_canMergeDuplicate(base) || !_canMergeDuplicate(next)) return false;
    final baseContent = base.content.trim();
    return baseContent.isNotEmpty && baseContent == next.content.trim();
  }

  static bool _canMergeDuplicate(ChatRoomMessage message) {
    return message.type == ChatRoomMessageType.msg &&
        !message.isRedpacket &&
        !message.isWeather &&
        !message.isMusic;
  }

  static String _senderKey(ChatRoomMessage message) {
    if (message.userOId > 0) return 'id:${message.userOId}';
    if (message.userName.trim().isNotEmpty) {
      return 'name:${message.userName.trim()}';
    }
    if (message.avatarURL.trim().isNotEmpty) {
      return 'avatar:${message.avatarURL.trim()}';
    }
    return '';
  }

  static List<ChatData> upsertPrivateConversation(
    List<ChatData> source,
    ChatData incoming,
  ) {
    final next = source
        .where((item) => !isSamePrivateConversation(item, incoming))
        .toList();
    next.insert(0, incoming);
    return next;
  }

  static List<ChatData> removePrivateConversationMessage(
    List<ChatData> source,
    String messageId,
  ) {
    if (messageId.isEmpty) return List<ChatData>.from(source);
    return source.where((item) => item.oId != messageId).toList();
  }

  static bool isSamePrivateConversation(ChatData a, ChatData b) {
    if (a.userSession.isNotEmpty &&
        b.userSession.isNotEmpty &&
        a.userSession == b.userSession) {
      return true;
    }
    if (a.fromId.isNotEmpty && a.fromId == b.fromId) return true;
    return false;
  }

  static bool isBlockedMessage(
    ChatRoomMessage message,
    Iterable<BlackUser> blackUsers, {
    Iterable<ChatRoomBlockedUser> chatRoomBlockedUsers = const [],
  }) {
    return BlackList.isBlockedUser(
          blackUsers,
          oId: message.userOId.toString(),
          userName: message.userName,
        ) ||
        ChatRoomBlockList.isBlockedUser(
          chatRoomBlockedUsers,
          oId: message.userOId > 0 ? message.userOId.toString() : null,
          userName: message.userName,
        );
  }

  static ParsedChatContent parseChatContent(String content) {
    final cached = _contentCache[content];
    if (cached != null) return cached;

    final document = parse(content);
    final body = document.body;
    final parsed = ParsedChatContent(
      elements: List<dom.Element>.from(body?.children ?? const []),
      preview: _buildPreview(body),
      plainText: body?.text.trim() ?? content.trim(),
      singleImageUrl: _findSingleImageUrl(body),
    );

    _contentCache[content] = parsed;
    if (_contentCache.length > previewCacheLimit) {
      _contentCache.remove(_contentCache.keys.first);
    }
    return parsed;
  }

  static String conversationPreview(String content) {
    if (content.trim().isEmpty) return '';
    return parseChatContent(content).preview;
  }

  static String? singleImageUrl(String content) {
    if (content.trim().isEmpty) return null;
    return parseChatContent(content).singleImageUrl;
  }

  static String _buildPreview(dom.Element? body) {
    if (body == null) return '';
    final music = ChatVoiceMessageUtils.parseMusicMessage(body.text.trim());
    if (music != null) {
      return ChatVoiceMessageUtils.previewFor(music);
    }

    final parts = <String>[];

    void visit(dom.Node node) {
      if (node is dom.Text) {
        final text = node.text.trim();
        if (text.isNotEmpty) parts.add(text);
        return;
      }
      if (node is! dom.Element) return;

      switch (node.localName) {
        case 'img':
          parts.add('[图片]');
          return;
        case 'video':
          parts.add('[视频]');
          return;
        case 'music':
          final music = MusicMsg(
            type: node.attributes['type'] ?? 'voice',
            source: node.attributes['source'] ?? node.attributes['src'] ?? '',
            coverURL: node.attributes['coverURL'] ?? '',
            title: node.attributes['title'] ?? '',
            from: node.attributes['from'] ?? '',
          );
          parts.add(ChatVoiceMessageUtils.previewFor(music));
          return;
        case 'iframe':
          parts.add(_iframePreview(node.attributes['src'] ?? ''));
          return;
        case 'br':
          return;
      }

      for (final child in node.nodes) {
        visit(child);
      }
    }

    for (final child in body.nodes) {
      visit(child);
    }

    final preview = parts
        .map((item) => item.replaceAll(RegExp(r'\s+'), ' '))
        .where((item) => item.isNotEmpty)
        .join(' ')
        .trim();
    return preview.isEmpty ? body.text.trim() : preview;
  }

  static String _iframePreview(String src) {
    if (src.startsWith('https://fishpi.yuis.cc')) return '[天气卡片]';
    if (src.startsWith('https://music.163.com')) return '[音乐]';
    return '[不支持的消息,请在web端查看]';
  }

  static String? _findSingleImageUrl(dom.Element? body) {
    if (body == null) return null;

    // 只有单张图片且没有其它可见内容时才使用极简图片样式，避免图文混排被误判。
    final images = <String>[];
    var hasOtherContent = false;

    void visit(dom.Node node) {
      if (hasOtherContent) return;

      if (node is dom.Text) {
        if (node.text.trim().isNotEmpty) {
          hasOtherContent = true;
        }
        return;
      }

      if (node is! dom.Element) return;
      switch (node.localName) {
        case 'img':
          final src = node.attributes['src']?.trim() ?? '';
          if (src.isEmpty) {
            hasOtherContent = true;
            return;
          }
          images.add(src);
          if (images.length > 1) hasOtherContent = true;
          return;
        case 'p':
        case 'div':
        case 'span':
        case 'a':
        case 'br':
          break;
        default:
          hasOtherContent = true;
          return;
      }

      for (final child in node.nodes) {
        visit(child);
      }
    }

    for (final node in body.nodes) {
      visit(node);
    }

    if (hasOtherContent || images.length != 1) return null;
    return images.single;
  }

  static void clearPreviewCache() {
    _contentCache.clear();
  }
}
