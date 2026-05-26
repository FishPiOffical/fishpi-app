import 'package:fishpi/types/chatroom.dart';
import 'package:fishpi_app/core/chat/chat_message_utils.dart';
import 'package:fishpi_app/core/chat/chat_red_packet_utils.dart';

enum ChatQuoteType {
  topic,
  message,
}

class ChatQuoteDraft {
  final ChatQuoteType type;
  final String title;
  final String preview;
  final String markdown;

  const ChatQuoteDraft({
    required this.type,
    required this.title,
    required this.preview,
    required this.markdown,
  });
}

class ChatQuoteUtils {
  static const int maxPreviewLength = 60;

  static ChatQuoteDraft? fromTopic(String topic) {
    final text = topic.trim();
    if (text.isEmpty) return null;
    final preview = '# $text';
    return ChatQuoteDraft(
      type: ChatQuoteType.topic,
      title: '引用话题',
      preview: preview,
      markdown: _blockquote(preview),
    );
  }

  static ChatQuoteDraft fromMessage({
    required ChatRoomMessage message,
    required String displayName,
  }) {
    final name = displayName.trim().isEmpty ? message.userName : displayName;
    final preview = _messagePreview(message);
    final content = '${name.trim()}：$preview';
    return ChatQuoteDraft(
      type: ChatQuoteType.message,
      title: '引用消息',
      preview: content,
      markdown: _blockquote(content),
    );
  }

  static String composeMessage({
    required ChatQuoteDraft? quote,
    required String text,
  }) {
    final body = text.trim();
    if (quote == null) return body;
    return '${quote.markdown}\n\n$body';
  }

  static String _messagePreview(ChatRoomMessage message) {
    if (message.isRedpacket && message.redpacket != null) {
      final redpacket = message.redpacket!;
      final msg = redpacket.msg.trim();
      final title = ChatRedPacketUtils.typeName(redpacket.type);
      return _truncate(msg.isEmpty ? title : '$title $msg');
    }

    final preview = ChatMessageUtils.conversationPreview(message.content);
    if (preview.trim().isNotEmpty) return _truncate(preview);
    final plainText = ChatMessageUtils.parseChatContent(message.content)
        .plainText
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return _truncate(plainText.isEmpty ? '[消息]' : plainText);
  }

  static String _blockquote(String text) {
    final normalized = _truncate(text.replaceAll(RegExp(r'\s+'), ' ').trim());
    return '> ${normalized.replaceAll('\n', '\n> ')}';
  }

  static String _truncate(String value) {
    final text = value.trim();
    if (text.length <= maxPreviewLength) return text;
    return '${text.substring(0, maxPreviewLength)}...';
  }
}
