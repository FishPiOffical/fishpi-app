import 'package:fishpi/types/chatroom.dart';
import 'package:fishpi_app/core/chat/chat_barrager_utils.dart';
import 'package:fishpi_app/core/sql/black_list.dart';
import 'package:fishpi_app/core/sql/chat_room_block_list.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('聊天室弹幕工具', () {
    test('弹幕内容会校验空内容和长度', () {
      expect(ChatBarragerUtils.validateContent('   '), '请输入弹幕内容');
      expect(
        ChatBarragerUtils.validateContent(
          'x' * (ChatBarragerUtils.maxContentLength + 1),
        ),
        '弹幕不能超过 ${ChatBarragerUtils.maxContentLength} 个字符',
      );
      expect(ChatBarragerUtils.validateContent('摸鱼快乐'), isNull);
    });

    test('弹幕颜色会按白色兜底', () {
      expect(ChatBarragerUtils.normalizeColor('#ff9f1c'), '#FF9F1C');
      expect(ChatBarragerUtils.normalizeColor('#000000'), '#FFFFFF');
    });

    test('弹幕按全局黑名单和聊天室屏蔽名单过滤', () {
      final msg = BarragerMsg(
        userName: 'alice',
        barragerContent: 'hello',
      );

      expect(
        ChatBarragerUtils.isBlockedBarrager(
          msg,
          [BlackUser(userName: 'alice')],
        ),
        isTrue,
      );
      expect(
        ChatBarragerUtils.isBlockedBarrager(
          msg,
          const [],
          chatRoomBlockedUsers: [ChatRoomBlockedUser(userName: 'alice')],
        ),
        isTrue,
      );
      expect(
        ChatBarragerUtils.isBlockedBarrager(msg, const []),
        isFalse,
      );
    });
  });
}
