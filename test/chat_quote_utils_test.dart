import 'package:fishpi/types/chatroom.dart';
import 'package:fishpi/types/redpacket.dart';
import 'package:fishpi_app/core/chat/chat_quote_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('聊天引用工具', () {
    test('话题引用生成普通话题标签', () {
      final quote = ChatQuoteUtils.fromTopic(' 今天吃什么 ');

      expect(quote, isNotNull);
      expect(quote?.title, '引用话题');
      expect(quote?.preview, '#今天吃什么#');
      expect(quote?.markdown, '#今天吃什么#');
      expect(ChatQuoteUtils.fromTopic('   '), isNull);
    });

    test('消息引用生成昵称和摘要', () {
      final quote = ChatQuoteUtils.fromMessage(
        message: ChatRoomMessage(
          userName: 'alice',
          content: '<p>hello <strong>world</strong></p>',
        ),
        displayName: '小鱼',
      );

      expect(quote.title, '引用消息');
      expect(quote.preview, '小鱼：hello world');
      expect(quote.markdown, '> 小鱼：hello world');
    });

    test('红包消息引用使用可读摘要', () {
      final quote = ChatQuoteUtils.fromMessage(
        message: ChatRoomMessage(
          userName: 'alice',
          redpacket: RedPacketMessage(
            type: RedPacketType.Random,
            msg: '好运来',
          ),
        ),
        displayName: '小鱼',
      );

      expect(quote.preview, '小鱼：拼手气红包 好运来');
    });

    test('组合话题消息会把话题追加到正文下方', () {
      final quote = ChatQuoteUtils.fromTopic('摸鱼');

      expect(
        ChatQuoteUtils.composeMessage(quote: quote, text: '正文'),
        '正文\n\n#摸鱼#',
      );
      expect(
        ChatQuoteUtils.composeMessage(quote: null, text: '  正文  '),
        '正文',
      );
    });

    test('组合消息引用仍放到正文前并保留空行', () {
      final quote = ChatQuoteUtils.fromMessage(
        message: ChatRoomMessage(
          userName: 'alice',
          content: '<p>hello world</p>',
        ),
        displayName: '小鱼',
      );

      expect(
        ChatQuoteUtils.composeMessage(quote: quote, text: '正文'),
        '> 小鱼：hello world\n\n正文',
      );
    });
  });
}
