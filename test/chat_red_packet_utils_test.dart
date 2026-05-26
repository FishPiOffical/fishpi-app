import 'dart:convert';

import 'package:fishpi/types/chatroom.dart';
import 'package:fishpi/types/redpacket.dart';
import 'package:fishpi_app/core/chat/chat_red_packet_utils.dart';
import 'package:fishpi_app/core/chat/chat_topic_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('聊天室红包工具', () {
    test('红包表单会拦截非法积分和个数', () {
      expect(
        ChatRedPacketUtils.validateForm(
          type: RedPacketType.Random,
          moneyText: '0',
          countText: '1',
          receivers: const [],
          gesture: null,
        ),
        '请输入有效积分',
      );
      expect(
        ChatRedPacketUtils.validateForm(
          type: RedPacketType.Average,
          moneyText: '1',
          countText: '2',
          receivers: const [],
          gesture: null,
        ),
        '总积分不能小于红包个数',
      );
    });

    test('专属红包必须选择接收者', () {
      expect(
        ChatRedPacketUtils.validateForm(
          type: RedPacketType.Specify,
          moneyText: '10',
          countText: '1',
          receivers: const [],
          gesture: null,
        ),
        '请选择专属接收者',
      );
      expect(
        ChatRedPacketUtils.validateForm(
          type: RedPacketType.Specify,
          moneyText: '10',
          countText: '1',
          receivers: const ['someone'],
          gesture: null,
        ),
        isNull,
      );
    });

    test('猜拳红包必须选择出拳', () {
      expect(
        ChatRedPacketUtils.validateForm(
          type: RedPacketType.RockPaperScissors,
          moneyText: '10',
          countText: '1',
          receivers: const [],
          gesture: null,
        ),
        '请选择出拳',
      );
      expect(
        ChatRedPacketUtils.validateForm(
          type: RedPacketType.RockPaperScissors,
          moneyText: '10',
          countText: '1',
          receivers: const [],
          gesture: GestureType.Rock,
        ),
        isNull,
      );
    });

    test('构建红包消息会写入类型、积分、接收者和出拳', () {
      final message = ChatRedPacketUtils.buildMessage(
        type: RedPacketType.RockPaperScissors,
        moneyText: '20',
        countText: '2',
        senderId: '100',
        receivers: const ['u1', 'u2'],
        gesture: GestureType.Paper,
        msg: '',
      );

      expect(message.type, RedPacketType.RockPaperScissors);
      expect(message.money, 20);
      expect(message.count, 2);
      expect(message.msg, ChatRedPacketUtils.defaultMessage);
      expect(message.senderId, '100');
      expect(message.recivers, ['u1', 'u2']);
      expect(message.gesture, GestureType.Paper);
    });

    test('猜拳红包发送内容会保留 gesture 字段', () {
      final message = ChatRedPacketUtils.buildMessage(
        type: RedPacketType.RockPaperScissors,
        moneyText: '10',
        countText: '1',
        senderId: '100',
        receivers: const [],
        gesture: GestureType.Scissors,
      );

      final content = ChatRedPacketUtils.toSendContent(message);
      final payload = content
          .replaceFirst('[redpacket]', '')
          .replaceFirst('[/redpacket]', '');
      final data = jsonDecode(payload) as Map<String, dynamic>;

      expect(content, startsWith('[redpacket]'));
      expect(content, endsWith('[/redpacket]'));
      expect(data['gesture'], GestureType.Scissors.index);
    });

    test('红包状态事件会按 oId 更新领取进度', () {
      final message = ChatRoomMessage(
        oId: 'packet-1',
        redpacket: RedPacketMessage(
          type: RedPacketType.Random,
          count: 3,
          got: 1,
          money: 30,
          msg: '好运',
        ),
      );
      final result = ChatRedPacketUtils.updateStatus(
        message,
        RedPacketStatusMsg(oId: 'packet-1', count: 3, got: 2),
      );

      expect(result.redpacket?.got, 2);
      expect(result.redpacket?.count, 3);
      expect(result.redpacket?.money, 30);
      expect(result.redpacket?.msg, '好运');
    });
  });

  group('聊天室话题工具', () {
    test('话题会去掉首尾空格并限制长度', () {
      expect(ChatTopicUtils.normalizeTopic('  摸鱼  '), '摸鱼');
      expect(ChatTopicUtils.validateTopic('摸鱼'), isNull);
      expect(
        ChatTopicUtils.validateTopic('x' * (ChatTopicUtils.maxTopicLength + 1)),
        '话题不能超过 ${ChatTopicUtils.maxTopicLength} 个字符',
      );
    });
  });
}
