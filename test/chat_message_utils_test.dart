import 'package:fishpi/types/chat.dart';
import 'package:fishpi/types/chatroom.dart';
import 'package:fishpi/types/article.dart';
import 'package:fishpi/types/breezemoon.dart';
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

    test('历史消息插入列表头部时保持顺序并按 oId 去重', () {
      final current = [
        ChatRoomMessage(oId: '3', content: '<p>3</p>'),
        ChatRoomMessage(oId: '4', content: '<p>4</p>'),
      ];
      final history = [
        ChatRoomMessage(oId: '1', content: '<p>1</p>'),
        ChatRoomMessage(oId: '2', content: '<p>2</p>'),
        ChatRoomMessage(oId: '3', content: '<p>重复</p>'),
      ];

      final result = ChatMessageUtils.prependUniqueChatRoomMessages(
        current,
        history,
      );

      expect(result.map((item) => item.oId), ['1', '2', '3', '4']);
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

    test('黑名单按 oId 命中文章作者', () {
      final articles = [
        ArticleDetail(authorId: '100', authorName: 'blocked', oId: 'a1'),
        ArticleDetail(authorId: '200', authorName: 'visible', oId: 'a2'),
      ];
      final blackUsers = [
        BlackUser(oId: '100', userName: 'other-name'),
      ];

      final result = BlackList.visibleItems(
        articles,
        blackUsers,
        oId: (item) => item.authorId,
        userName: (item) => item.authorName,
      );

      expect(result.map((item) => item.oId), ['a2']);
    });

    test('黑名单按用户名命中清风明月作者', () {
      final breezemoons = [
        BreezemoonContent(authorName: 'blocked', oId: 'b1'),
        BreezemoonContent(authorName: 'visible', oId: 'b2'),
      ];
      final blackUsers = [
        BlackUser(userName: 'blocked'),
      ];

      final result = BlackList.visibleItems(
        breezemoons,
        blackUsers,
        userName: (item) => item.authorName,
      );

      expect(result.map((item) => item.oId), ['b2']);
    });

    test('过滤文章和清风明月时保持原始顺序', () {
      final articles = [
        ArticleDetail(authorId: '1', authorName: 'first', oId: 'a1'),
        ArticleDetail(authorId: '2', authorName: 'blocked', oId: 'a2'),
        ArticleDetail(authorId: '3', authorName: 'third', oId: 'a3'),
      ];
      final breezemoons = [
        BreezemoonContent(authorName: 'first', oId: 'b1'),
        BreezemoonContent(authorName: 'blocked', oId: 'b2'),
        BreezemoonContent(authorName: 'third', oId: 'b3'),
      ];
      final blackUsers = [
        BlackUser(oId: '2', userName: 'blocked'),
      ];

      final visibleArticles = BlackList.visibleItems(
        articles,
        blackUsers,
        oId: (item) => item.authorId,
        userName: (item) => item.authorName,
      );
      final visibleBreezemoons = BlackList.visibleItems(
        breezemoons,
        blackUsers,
        userName: (item) => item.authorName,
      );

      expect(visibleArticles.map((item) => item.oId), ['a1', 'a3']);
      expect(visibleBreezemoons.map((item) => item.oId), ['b1', 'b3']);
    });

    test('历史消息会过滤黑名单用户', () {
      final messages = [
        ChatRoomMessage(oId: '1', userOId: 100, userName: 'blocked'),
        ChatRoomMessage(oId: '2', userOId: 200, userName: 'visible'),
      ];
      final blackUsers = [
        BlackUser(oId: '100', userName: 'blocked'),
      ];

      final result = ChatMessageUtils.visibleMessages(messages, blackUsers);

      expect(result.map((item) => item.oId), ['2']);
    });

    test('空历史页会标记为无更多', () {
      expect(ChatMessageUtils.hasMoreHistoryPage(0), isFalse);
      expect(ChatMessageUtils.hasMoreHistoryPage(1), isTrue);
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
