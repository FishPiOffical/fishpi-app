import 'dart:collection';

import 'package:fishpi/types/chat.dart';
import 'package:fishpi/types/chatroom.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';

import '../sql/black_list.dart';

class ParsedChatContent {
  final List<dom.Element> elements;
  final String preview;
  final String plainText;

  const ParsedChatContent({
    required this.elements,
    required this.preview,
    required this.plainText,
  });
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
    Iterable<BlackUser> blackUsers,
  ) {
    final userId = message.userOId.toString();
    return blackUsers.any((user) {
      final blackId = user.oId ?? '';
      final blackName = user.userName ?? '';
      return (blackId.isNotEmpty && blackId == userId) ||
          (blackName.isNotEmpty && blackName == message.userName);
    });
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

  static String _buildPreview(dom.Element? body) {
    if (body == null) return '';
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

  static void clearPreviewCache() {
    _contentCache.clear();
  }
}
