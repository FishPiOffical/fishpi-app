import 'package:fishpi/types/chat.dart';
import 'package:fishpi/types/chatroom.dart';
import 'package:fishpi/types/article.dart';
import 'package:fishpi/types/breezemoon.dart';
import 'package:fishpi/types/redpacket.dart';
import 'package:fishpi_app/core/chat/chat_message_utils.dart';
import 'package:fishpi_app/core/chat/chat_music_utils.dart';
import 'package:fishpi_app/core/chat/chat_weather_utils.dart';
import 'package:fishpi_app/core/chat/chat_voice_message_utils.dart';
import 'package:fishpi_app/core/sql/black_list.dart';
import 'package:fishpi_app/core/sql/chat_room_block_list.dart';
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

    test('聊天消息裁剪默认保留最新消息', () {
      final messages = List.generate(
        5,
        (index) => ChatRoomMessage(oId: '$index', content: '<p>$index</p>'),
      );

      final result = ChatMessageUtils.trimChatRoomMessages(messages, 3);

      expect(result.map((item) => item.oId), ['2', '3', '4']);
    });

    test('分页历史超出上限时保留顶部历史窗口', () {
      final current = [
        ChatRoomMessage(oId: '3', content: '<p>3</p>'),
        ChatRoomMessage(oId: '4', content: '<p>4</p>'),
      ];
      final history = [
        ChatRoomMessage(oId: '0', content: '<p>0</p>'),
        ChatRoomMessage(oId: '1', content: '<p>1</p>'),
        ChatRoomMessage(oId: '2', content: '<p>2</p>'),
      ];

      final result = ChatMessageUtils.prependUniqueChatRoomMessages(
        current,
        history,
        maxLength: 4,
      );

      expect(result.map((item) => item.oId), ['0', '1', '2', '3']);
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

    test('聊天室消息会按黑名单和聊天室屏蔽并集过滤', () {
      final messages = [
        ChatRoomMessage(oId: '1', userOId: 100, userName: 'black'),
        ChatRoomMessage(oId: '2', userOId: 200, userName: 'room-blocked'),
        ChatRoomMessage(oId: '3', userOId: 300, userName: 'visible'),
      ];
      final blackUsers = [
        BlackUser(oId: '100', userName: 'black'),
      ];
      final chatRoomBlockedUsers = [
        ChatRoomBlockedUser(oId: '200', userName: 'room-blocked'),
      ];

      final result = ChatMessageUtils.visibleMessages(
        messages,
        blackUsers,
        chatRoomBlockedUsers: chatRoomBlockedUsers,
      );

      expect(result.map((item) => item.oId), ['3']);
    });

    test('私聊不传聊天室屏蔽名单时不会被聊天室屏蔽影响', () {
      final message = ChatRoomMessage(
        oId: '1',
        userOId: 200,
        userName: 'room-blocked',
      );
      final chatRoomBlockedUsers = [
        ChatRoomBlockedUser(oId: '200', userName: 'room-blocked'),
      ];

      expect(
        ChatMessageUtils.isBlockedMessage(message, const []),
        isFalse,
      );
      expect(
        ChatMessageUtils.isBlockedMessage(
          message,
          const [],
          chatRoomBlockedUsers: chatRoomBlockedUsers,
        ),
        isTrue,
      );
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

    test('HTML 解析缓存会按条数淘汰旧内容', () {
      for (var index = 0;
          index <= ChatMessageUtils.previewCacheLimit;
          index++) {
        ChatMessageUtils.conversationPreview('<p>$index</p>');
      }

      expect(
        ChatMessageUtils.debugPreviewCacheSize(),
        ChatMessageUtils.previewCacheLimit,
      );
      expect(ChatMessageUtils.debugIsPreviewCached('<p>0</p>'), isFalse);
      expect(
        ChatMessageUtils.debugIsPreviewCached(
          '<p>${ChatMessageUtils.previewCacheLimit}</p>',
        ),
        isTrue,
      );
    });

    test('超长 HTML 不进入解析缓存', () {
      final longText =
          List.filled(ChatMessageUtils.previewCacheMaxContentLength + 1, 'x')
              .join();
      final content = '<p>$longText</p>';

      ChatMessageUtils.conversationPreview(content);

      expect(ChatMessageUtils.debugIsPreviewCached(content), isFalse);
      expect(ChatMessageUtils.debugPreviewCacheSize(), 0);
    });

    test('语音 music 消息可生成并解析为会话预览', () {
      final content = ChatVoiceMessageUtils.buildMusicMessage(
        url: 'https://example.com/a.m4a',
        durationSeconds: 3,
      );
      final roomMessage = ChatRoomMessage.from({
        'oId': 'voice-1',
        'userOId': 1,
        'userName': 'sender',
        'userAvatarURL': '',
        'sysMetal': '{"list":[]}',
        'client': '',
        'content': content,
        'time': '',
      });

      expect(roomMessage.isMusic, isTrue);
      expect(roomMessage.music?.type, 'voice');
      expect(roomMessage.music?.source, 'https://example.com/a.m4a');
      expect(ChatMessageUtils.conversationPreview(content), '[语音]');
    });

    test('红包消息兼容 BBCode 和裸 JSON 格式', () {
      final bbcodeContent =
          '[redpacket]{"type":"random","count":2,"got":0,"money":20,"msg":"好运"}[/redpacket]';
      final jsonContent =
          '{"type":"average","count":2,"got":0,"money":10,"msg":"平分"}';
      final bbcodeMessage = ChatRoomMessage.from({
        'oId': 'packet-1',
        'userOId': 1,
        'userName': 'sender',
        'content': bbcodeContent,
        'time': '',
      });
      final jsonMessage = ChatRoomMessage.from({
        'oId': 'packet-2',
        'userOId': 1,
        'userName': 'sender',
        'content': jsonContent,
        'time': '',
      });

      expect(bbcodeMessage.isRedpacket, isTrue);
      expect(bbcodeMessage.redpacket?.type, RedPacketType.Random);
      expect(jsonMessage.isRedpacket, isTrue);
      expect(jsonMessage.redpacket?.type, RedPacketType.Average);
      expect(
        ChatMessageUtils.conversationPreview(bbcodeContent),
        '[红包] 拼手气红包 好运',
      );
    });

    test('HTML music 标签会降级为语音预览', () {
      expect(
        ChatMessageUtils.conversationPreview(
          '<music type="voice" source="https://example.com/a.m4a"></music>',
        ),
        '[语音]',
      );
    });

    test('音乐解析兼容 JSON、HTML、BBCode 和非法地址', () {
      final jsonTrack = ChatMusicUtils.trackFromContent(
        '{"msgType":"music","type":"music","source":"https://example.com/song.mp3","title":"歌名","from":"歌手"}',
      );
      final htmlTrack = ChatMusicUtils.trackFromContent(
        '<music type="music" source="https://example.com/html.mp3" title="HTML歌"></music>',
      );
      final bracketTrack = ChatMusicUtils.trackFromContent(
        '[music]https://example.com/raw.mp3[/music]',
      );
      final invalidTrack =
          ChatMusicUtils.trackFromContent('[music]bad[/music]');

      expect(jsonTrack?.title, '歌名');
      expect(htmlTrack?.title, 'HTML歌');
      expect(bracketTrack?.source, 'https://example.com/raw.mp3');
      expect(invalidTrack?.isValid, isFalse);
      expect(
          ChatMessageUtils.conversationPreview(
            '[music]{"source":"https://example.com/song.mp3","title":"歌名"}[/music]',
          ),
          '[音乐] 歌名');
    });

    test('天气解析兼容 JSON、BBCode 和缺失字段', () {
      final jsonWeather = ChatWeatherUtils.weatherFromContent(
        '{"msgType":"weather","t":"杭州","st":"晴","date":"今天,明天","weatherCode":"100,101","min":"10,11","max":"20,21"}',
      );
      final bracketWeather = ChatWeatherUtils.weatherFromContent(
        '[weather]{"city":"上海","description":"多云","data":[{"date":"今天","code":"cloud","min":12,"max":18}]}[/weather]',
      );
      final missingWeather = WeatherMsg.from({'t': '北京'});

      expect(jsonWeather?.city, '杭州');
      expect(jsonWeather?.data, hasLength(2));
      expect(bracketWeather?.city, '上海');
      expect(bracketWeather?.data.single.max, 18);
      expect(missingWeather.city, '北京');
      expect(missingWeather.data, isEmpty);
      expect(
          ChatMessageUtils.conversationPreview(
            '[weather]{"city":"上海","description":"多云"}[/weather]',
          ),
          '[天气] 上海 多云');
    });

    test('纯单图消息识别图片地址', () {
      expect(
        ChatMessageUtils.singleImageUrl('<p><img src="a.png"></p>'),
        'a.png',
      );
      expect(
        ChatMessageUtils.singleImageUrl('<div>  <img src="b.png">  </div>'),
        'b.png',
      );
    });

    test('图文混排和多图消息不按纯单图处理', () {
      expect(
        ChatMessageUtils.singleImageUrl('<p>看图</p><img src="a.png">'),
        isNull,
      );
      expect(
        ChatMessageUtils.singleImageUrl(
          '<p><img src="a.png"><img src="b.png"></p>',
        ),
        isNull,
      );
      expect(ChatMessageUtils.singleImageUrl('<video src="a.mp4"></video>'),
          isNull);
    });

    test('连续相同内容会合并为一个展示组', () {
      final messages = [
        _roomMessage(
            oId: '1', userOId: 1, userName: 'first', content: '<p>same</p>'),
        _roomMessage(
            oId: '2', userOId: 2, userName: 'second', content: '<p>same</p>'),
        _roomMessage(
            oId: '3', userOId: 3, userName: 'third', content: '<p>same</p>'),
      ];

      final groups =
          ChatMessageUtils.groupConsecutiveDuplicateMessages(messages);

      expect(groups, hasLength(1));
      expect(groups.single.message.userName, 'first');
      expect(groups.single.repeaters.map((item) => item.userName), [
        'second',
        'third',
      ]);
    });

    test('非连续相同内容不会合并', () {
      final messages = [
        _roomMessage(oId: '1', content: '<p>same</p>'),
        _roomMessage(oId: '2', content: '<p>other</p>'),
        _roomMessage(oId: '3', content: '<p>same</p>'),
      ];

      final groups =
          ChatMessageUtils.groupConsecutiveDuplicateMessages(messages);

      expect(groups.map((item) => item.message.oId), ['1', '2', '3']);
      expect(groups.every((item) => item.repeaters.isEmpty), isTrue);
    });

    test('红包和其它特殊消息不参与重复合并', () {
      final messages = [
        _roomMessage(
          oId: '1',
          content: '<p>same</p>',
          type: ChatRoomMessageType.redPacket,
          redpacket: RedPacketMessage(msg: '红包'),
        ),
        _roomMessage(oId: '2', content: '<p>same</p>'),
      ];

      final groups =
          ChatMessageUtils.groupConsecutiveDuplicateMessages(messages);

      expect(groups, hasLength(2));
    });

    test('同一用户重复消息会合并且头像按用户去重', () {
      final messages = [
        _roomMessage(oId: '1', userOId: 100, userName: 'same-user'),
        _roomMessage(oId: '2', userOId: 100, userName: 'same-user'),
        _roomMessage(oId: '3', userOId: 100, userName: 'same-user'),
      ];

      final groups =
          ChatMessageUtils.groupConsecutiveDuplicateMessages(messages);

      expect(groups, hasLength(1));
      expect(groups.single.repeaters, hasLength(1));
      expect(groups.single.repeaters.single.userName, 'same-user');
    });
  });
}

ChatRoomMessage _roomMessage({
  String oId = 'room-msg',
  int userOId = 1,
  String userName = 'sender',
  String content = '<p>你好</p>',
  String type = ChatRoomMessageType.msg,
  RedPacketMessage? redpacket,
}) {
  return ChatRoomMessage(
    oId: oId,
    userOId: userOId,
    userName: userName,
    avatarURL: '',
    content: content,
    type: type,
    redpacket: redpacket,
  );
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
