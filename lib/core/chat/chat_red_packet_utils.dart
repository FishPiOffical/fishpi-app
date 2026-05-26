import 'dart:convert';

import 'package:fishpi/types/chatroom.dart';
import 'package:fishpi/types/redpacket.dart';

class ChatRedPacketUtils {
  static const defaultMessage = '恭喜发财，大吉大利';
  static const maxMessageLength = 30;

  static const types = [
    RedPacketType.Random,
    RedPacketType.Average,
    RedPacketType.Specify,
    RedPacketType.Heartbeat,
    RedPacketType.RockPaperScissors,
  ];

  static String typeName(String type) => RedPacketType.toName(type).toString();

  static String gestureName(GestureType gesture) {
    switch (gesture) {
      case GestureType.Rock:
        return '石头';
      case GestureType.Scissors:
        return '剪刀';
      case GestureType.Paper:
        return '布';
    }
  }

  static String openErrorMessage(Object error) {
    final raw = error
        .toString()
        .replaceFirst('Exception:', '')
        .replaceFirst('Invalid argument(s):', '')
        .trim();
    if (raw.isEmpty) return '领取红包失败，请稍后重试';

    final lower = raw.toLowerCase();
    if (lower.contains('null') ||
        lower.contains('type') ||
        lower.contains('rangeerror')) {
      return '红包状态异常，请稍后重试';
    }
    if (isAlreadyOpenedError(error)) return '这个红包已经领取过了';
    if (raw.contains('领完') || raw.contains('抢完') || raw.contains('空了')) {
      return '红包已经被抢完了';
    }
    if (raw.contains('积分') || raw.contains('余额')) return raw;
    return '领取红包失败：$raw';
  }

  static bool isAlreadyOpenedError(Object error) {
    final raw = error
        .toString()
        .replaceFirst('Exception:', '')
        .replaceFirst('Invalid argument(s):', '')
        .trim();
    return raw.contains('已领') ||
        raw.contains('领取过') ||
        raw.contains('抢过') ||
        raw.contains('已经打开');
  }

  static String? validateForm({
    required String type,
    required String moneyText,
    required String countText,
    required List<String> receivers,
    required GestureType? gesture,
    String msg = '',
  }) {
    if (!types.contains(type)) return '请选择红包类型';

    final money = int.tryParse(moneyText.trim());
    if (money == null || money <= 0) return '请输入有效积分';

    if (type == RedPacketType.Specify && receivers.isEmpty) {
      return '请选择专属接收者';
    }

    final count = type == RedPacketType.Specify
        ? receivers.length
        : int.tryParse(countText.trim());
    if (count == null || count <= 0) return '请输入有效红包个数';
    if (money < count) return '总积分不能小于红包个数';

    if (type == RedPacketType.RockPaperScissors && gesture == null) {
      return '请选择出拳';
    }
    if (msg.trim().length > maxMessageLength) {
      return '祝福语不能超过 $maxMessageLength 个字符';
    }
    return null;
  }

  static RedPacketMessage buildMessage({
    required String type,
    required String moneyText,
    required String countText,
    required String senderId,
    required List<String> receivers,
    required GestureType? gesture,
    String msg = '',
  }) {
    final message = RedPacketMessage(
      type: type,
      count: type == RedPacketType.Specify
          ? receivers.length
          : int.parse(countText.trim()),
      got: 0,
      money: int.parse(moneyText.trim()),
      msg: msg.trim().isEmpty ? defaultMessage : msg.trim(),
      senderId: senderId,
      recivers: List<String>.from(receivers),
      who: const [],
    );
    message.gesture = type == RedPacketType.RockPaperScissors ? gesture : null;
    return message;
  }

  static Map<String, dynamic> toSendJson(RedPacketMessage message) {
    final data = Map<String, dynamic>.from(message.toJson());
    if (message.gesture != null) {
      data['gesture'] = message.gesture!.index;
    }
    return data;
  }

  static String toSendContent(RedPacketMessage message) {
    return '[redpacket]${jsonEncode(toSendJson(message))}[/redpacket]';
  }

  static RedPacketMessage? redPacketFromMessage(ChatRoomMessage message) {
    return message.redpacket ?? parseContent(message.content);
  }

  static String previewFor(RedPacketMessage redpacket) {
    final title = typeName(redpacket.type);
    final message = redpacket.msg.trim();
    if (message.isEmpty) return '[红包] $title';
    return '[红包] $title $message';
  }

  static RedPacketMessage? parseContent(String content) {
    final payload = _extractWrappedPayload(content.trim(), 'redpacket');
    final raw = payload ?? content.trim();
    if (raw.isEmpty) return null;

    try {
      final data = jsonDecode(raw);
      if (data is! Map) return null;
      final map = Map<String, dynamic>.from(data);
      if (!_looksLikeRedPacket(map)) return null;
      return RedPacketMessage.from(map);
    } catch (_) {
      return null;
    }
  }

  static ChatRoomMessage updateStatus(
    ChatRoomMessage message,
    RedPacketStatusMsg status,
  ) {
    final redpacket = redPacketFromMessage(message);
    if (redpacket == null || message.oId != status.oId) return message;

    final nextRedpacket = RedPacketMessage(
      type: redpacket.type,
      count: status.count > 0 ? status.count : redpacket.count,
      got: status.got,
      money: redpacket.money,
      msg: redpacket.msg,
      senderId: redpacket.senderId,
      recivers: redpacket.recivers,
      who: redpacket.who,
    );
    nextRedpacket.gesture = redpacket.gesture;

    return ChatRoomMessage(
      oId: message.oId,
      userOId: message.userOId,
      userName: message.userName,
      nickname: message.nickname,
      avatarURL: message.avatarURL,
      sysMetal: message.sysMetal,
      via: message.via,
      content: message.content,
      md: message.md,
      redpacket: nextRedpacket,
      weather: message.weather,
      music: message.music,
      time: message.time,
      type: message.type,
    );
  }

  static bool _looksLikeRedPacket(Map<String, dynamic> data) {
    return data['msgType'] == ChatRoomMessageType.redPacket ||
        (data.containsKey('money') &&
            data.containsKey('count') &&
            (data.containsKey('type') || data.containsKey('interface')));
  }

  static String? _extractWrappedPayload(String content, String tag) {
    final match = RegExp(
      '\\[$tag\\]([\\s\\S]*?)\\[/$tag\\]',
      caseSensitive: false,
    ).firstMatch(content);
    return match?.group(1)?.trim();
  }
}
