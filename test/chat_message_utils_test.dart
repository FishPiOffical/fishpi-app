import 'package:fishpi/types/chat.dart';
import 'package:fishpi/types/chatroom.dart';
import 'package:fishpi_app/core/chat/chat_message_utils.dart';
import 'package:fishpi_app/core/sql/black_list.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(ChatMessageUtils.clearPreviewCache);

  group('聊天消息工具', () {
    test('私聊消息转换为聊天室消息时兼容异常用户 id', () {
      final data = _chatData(fromId: 'bad-id');

      final message = ChatMessageUtils.chatDataToRoomMessage(data);

      expect(message.oId, 'msg-1');
      expect(message.userOId, 0);
      expect(message.userName, 'sender');
      expect(message.content, '<p>你好</p>');
    });

    test('聊天室消息按 oId 去重并限制长度', () {
      final first = ChatRoomMessage(oId: '1', content: '<p>1</p>');
      final duplicate = ChatRoomMessage(oId: '1', content: '<p>重复</p>');
      final second = ChatRoomMessage(oId: '2', content: '<p>2</p>');

      final result = ChatMessageUtils.appendUniqueChatRoomMessage(
        [first],
        duplicate,
        maxLength: 2,
      );
      final limited = ChatMessageUtils.appendUniqueChatRoomMessage(
        result,
        second,
        maxLength: 1,
      );

      expect(result, hasLength(1));
      expect(limited.map((item) => item.oId), ['2']);
    });

    test('私聊会话更新时同一会话置顶', () {
      final oldMessage = _chatData(oId: 'old', fromId: 'u1');
      final otherMessage = _chatData(oId: 'other', fromId: 'u2');
      final newMessage = _chatData(oId: 'new', fromId: 'u1');

      final result = ChatMessageUtils.upsertPrivateConversation(
        [oldMessage, otherMessage],
        newMessage,
      );

      expect(result.map((item) => item.oId), ['new', 'other']);
    });

    test('黑名单用户消息会被识别', () {
      final message = ChatRoomMessage(userOId: 100, userName: 'blocked');
      final blackUsers = [
        BlackUser(oId: '100', userName: 'blocked'),
      ];

      expect(ChatMessageUtils.isBlockedMessage(message, blackUsers), isTrue);
    });

    test('会话预览兼容文本、图片、视频和空内容', () {
      expect(ChatMessageUtils.conversationPreview('<p>你好</p>'), '你好');
      expect(
        ChatMessageUtils.conversationPreview('<p>图</p><img src="a.png">'),
        '图 [图片]',
      );
      expect(
        ChatMessageUtils.conversationPreview('<video src="a.mp4"></video>'),
        '[视频]',
      );
      expect(ChatMessageUtils.conversationPreview(''), '');
    });
  });
}

ChatData _chatData({
  String oId = 'msg-1',
  String fromId = '1',
}) {
  return ChatData(
    toId: '2',
    preview: '你好',
    userSession: '',
    senderAvatar: 'sender.png',
    markdown: '你好',
    receiverAvatar: 'receiver.png',
    oId: oId,
    time: '2026-05-22T00:00:00.000Z',
    fromId: fromId,
    senderUserName: 'sender',
    content: '<p>你好</p>',
    receiverUserName: 'receiver',
  );
}
