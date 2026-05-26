// ignore_for_file: constant_identifier_names

import 'dart:convert';

/// 猜拳类型
enum GestureType {
  /// 石头
  Rock,

  /// 剪刀
  Scissors,

  /// 布
  Paper,
}

/// 红包类型
class RedPacketType {
  /// 拼手气
  static const Random = "random";

  /// 平分
  static const Average = "average";

  /// 专属
  static const Specify = "specify";

  /// 心跳
  static const Heartbeat = "heartbeat";

  /// 猜拳
  static const RockPaperScissors = "rockPaperScissors";

  static toName(String type) {
    switch (type) {
      case Random:
        return "拼手气红包";
      case Average:
        return "平分红包";
      case Specify:
        return "专属红包";
      case Heartbeat:
        return "心跳红包";
      case RockPaperScissors:
        return "猜拳红包";
      default:
        return "未知红包";
    }
  }
}

/// 红包领取者信息
class RedPacketGot {
  /// 用户 id
  String userId;

  /// 用户名
  String userName;

  /// 用户头像
  String avatar;

  /// 领取到的积分
  int money;

  /// 领取积分时间
  String time;

  RedPacketGot({
    this.userId = '',
    this.userName = '',
    this.avatar = '',
    this.money = 0,
    this.time = '',
  });

  RedPacketGot.from(Map? data)
      : userId = _readString(data, 'userId'),
        userName = _readString(data, 'userName'),
        avatar = _readString(data, 'avatar'),
        money = _readInt(data, 'userMoney'),
        time = _readString(data, 'time');

  toJson() => {
        'userId': userId,
        'userName': userName,
        'avatar': avatar,
        'userMoney': money,
        'time': time,
      };

  @override
  String toString() {
    return "RedPacketGot{ userId=$userId, userName=$userName, avatar=$avatar, userMoney=$money, time=$time }";
  }
}

/// 红包历史信息
class RedPacketMessage {
  /// 红包类型，使用 RedPacketType.toName(type) 获取名称
  String type;

  /// 红包数
  int count;

  /// 领取数
  int got;

  /// 内含积分
  int money;

  /// 祝福语
  String msg;

  /// 发送者 id
  String senderId;

  /// 接收者，专属红包有效
  List<String> recivers;

  /// 已领取者列表
  List<RedPacketGot> who;

  /// 出拳，猜拳红包有效
  GestureType? gesture;

  RedPacketMessage({
    this.type = '',
    this.count = 0,
    this.got = 0,
    this.money = 0,
    this.msg = '',
    this.senderId = '',
    this.recivers = const [],
    this.who = const [],
  });

  RedPacketMessage.from(Map data)
      : type = _readString(data, 'type').isEmpty
            ? _readString(data, 'interface')
            : _readString(data, 'type'),
        count = _readInt(data, 'count'),
        got = _readInt(data, 'got'),
        money = _readInt(data, 'money'),
        msg = _readString(data, 'msg'),
        senderId = _readString(data, 'senderId'),
        recivers = _stringList(data['recivers']),
        who = _mapList(data['who']).map((e) => RedPacketGot.from(e)).toList(),
        gesture = _gestureFrom(data['gesture']);

  toJson() => {
        'type': type,
        'count': count,
        'got': got,
        'money': money,
        'msg': msg,
        'senderId': senderId,
        'recivers': recivers,
        'who': who.map((e) => e.toJson()).toList(),
      };

  @override
  String toString() {
    return "RedPacketMessage{ type=$type, count=$count, got=$got, money=$money, msg=$msg, senderId=$senderId, recivers=$recivers, who=$who }";
  }
}

/// 红包基本信息
class RedPacketBase {
  /// 数量
  int count;

  /// 猜拳类型
  GestureType? gesture;

  /// 领取数
  int got;

  /// 祝福语
  String msg;

  /// 发送者用户名
  String userName;

  /// 用户头像
  String avatarURL;

  RedPacketBase({
    this.count = 0,
    this.gesture = GestureType.Rock,
    this.got = 0,
    this.msg = '',
    this.userName = '',
    this.avatarURL = '',
  });

  RedPacketBase.from(Map? data)
      : count = _readInt(data, 'count'),
        gesture = _gestureFrom(data?['gesture']),
        got = _readInt(data, 'got'),
        msg = _readString(data, 'msg'),
        userName = _readString(data, 'userName'),
        avatarURL = _readString(data, 'userAvatarURL');

  toJson() => {
        'count': count,
        'gesture': gesture?.index,
        'got': got,
        'msg': msg,
        'userName': userName,
        'userAvatarURL': avatarURL,
      };

  @override
  String toString() {
    return "RedPacketBase{ count=$count, gesture=$gesture, got=$got, msg=$msg, userName=$userName, userAvatarURL=$avatarURL }";
  }
}

/// 红包信息
class RedPacketInfo {
  /// 红包基本信息
  RedPacketBase info = RedPacketBase();

  /// 接收者，专属红包有效
  List<String> recivers = [];

  /// 已领取者列表
  List<RedPacketGot> who = [];

  RedPacketInfo({
    RedPacketBase? info,
    this.recivers = const [],
    this.who = const [],
  }) {
    this.info = info ?? RedPacketBase();
  }

  RedPacketInfo.from(Map data)
      : info = RedPacketBase.from(data['info'] is Map ? data['info'] : null),
        recivers = _stringList(data['recivers']),
        who = _mapList(data['who']).map((e) => RedPacketGot.from(e)).toList();

  toJson() => {
        'info': info.toJson(),
        'recivers': recivers,
        'who': who.map((e) => e.toJson()).toList(),
      };

  @override
  String toString() {
    return "RedPacketInfo{ info=$info, recivers=$recivers, who=$who }";
  }
}

int _readInt(Map? data, String key) {
  final value = data?[key];
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String _readString(Map? data, String key) {
  return data?[key]?.toString() ?? '';
}

List _decodeList(dynamic value) {
  if (value == null) return [];
  if (value is List) return value;
  if (value is String) {
    try {
      final decoded = json.decode(value);
      return decoded is List ? decoded : [];
    } catch (_) {
      return [];
    }
  }
  return [];
}

List<String> _stringList(dynamic value) {
  return _decodeList(value)
      .map((item) => item?.toString() ?? '')
      .where((item) => item.trim().isNotEmpty)
      .toList();
}

List<Map> _mapList(dynamic value) {
  return _decodeList(value).whereType<Map>().toList();
}

GestureType? _gestureFrom(dynamic value) {
  if (value == null) return null;
  if (value is GestureType) return value;

  final index = value is int ? value : int.tryParse(value.toString());
  if (index != null && index >= 0 && index < GestureType.values.length) {
    return GestureType.values[index];
  }

  final name = value.toString().split('.').last;
  for (final gesture in GestureType.values) {
    if (gesture.name == name) return gesture;
  }
  return null;
}

/// 红包状态信息
class RedPacketStatusMsg {
  /// 对应红包消息 oId
  String oId;

  /// 红包个数
  int count;

  /// 已领取数量
  int got;

  /// 发送者信息
  String whoGive;

  /// 领取者信息
  String whoGot;

  /// 领取者头像 20x20
  String avatarURL20;

  /// 领取者头像 48x48
  String avatarURL48;

  /// 领取者头像 210x210
  String avatarURL210;

  RedPacketStatusMsg({
    this.oId = '',
    this.count = 0,
    this.got = 0,
    this.whoGive = '',
    this.whoGot = '',
    this.avatarURL20 = '',
    this.avatarURL48 = '',
    this.avatarURL210 = '',
  });

  RedPacketStatusMsg.from(Map data)
      : oId = data['oId'] ?? '',
        count = data['count'] ?? 0,
        got = data['got'] ?? 0,
        whoGive = data['whoGive'] ?? '',
        whoGot = data['whoGot'] ?? '',
        avatarURL20 = data['userAvatarURL20'] ?? '',
        avatarURL48 = data['userAvatarURL48'] ?? '',
        avatarURL210 = data['userAvatarURL210'] ?? '';

  toJson() => {
        'oId': oId,
        'count': count,
        'got': got,
        'whoGive': whoGive,
        'whoGot': whoGot,
        'userAvatarURL20': avatarURL20,
        'userAvatarURL48': avatarURL48,
        'userAvatarURL210': avatarURL210,
      };

  @override
  String toString() {
    return "RedPacketStatusMsg{ oId=$oId, count=$count, got=$got, whoGive=$whoGive, whoGot=$whoGot, userAvatarURL20=$avatarURL20, userAvatarURL48=$avatarURL48, userAvatarURL210=$avatarURL210 }";
  }
}
