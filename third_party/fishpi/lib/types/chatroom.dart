// ignore_for_file: non_constant_identifier_names, camel_case_types, constant_identifier_names

import 'dart:convert';

import 'package:fishpi/fishpi.dart';
import 'package:fishpi/src/utils.dart';

/// 客户端类型
class ClientType {
  /// 网页端
  static const Web = 'Web';

  /// PC 端
  static const PC = 'PC';

  /// 移动端聊天室
  static const Mobile = 'Mobile';

  /// Windows 客户端
  static const Windows = 'Windows';

  /// macOS 客户端
  static const macOS = 'macOS';

  /// iOS 客户端
  static const iOS = 'iOS';

  /// Android 客户端
  static const Android = 'Android';

  /// IDEA 插件
  static const IDEA = 'IDEA';

  /// Chrome 插件
  static const Chrome = 'Chrome';

  /// Edge 插件
  static const Edge = 'Edge';

  /// VSCode 插件
  static const VSCode = 'VSCode';

  /// Python 插件
  static const Python = 'Python';

  /// Golang 插件
  static const Golang = 'Golang';

  /// 小冰机器人
  static const IceNet = 'IceNet';

  /// 凌机器人
  static const ElvesOnline = 'ElvesOnline';

  /// Dart 客户端
  static const Dart = 'Dart';

  /// 鸽机器人
  static const Bird = 'Bird';

  /// 其他插件
  static const Other = 'Other';
}

/// 消息来源
class ChatSource {
  /// 客户端类型
  String client = ClientType.Other;

  /// 客户端版本
  String version = '';

  ChatSource({this.client = ClientType.Dart, this.version = 'latest'});

  ChatSource.from(String? client) {
    if ((client ?? '').isEmpty) return;
    final via = client!.split('/');
    if (client.length < 2) return;
    client = via[0];
    version = via[1];
  }

  toJson() => {
        'client': client,
        'version': version,
      };

  @override
  String toString() {
    return "$client/$version";
  }
}

/// 聊天室消息
class ChatRoomMessage {
  /// 消息 Id
  String oId = '';

  /// 发送者用户 Id
  int userOId = 0;

  /// 发送者用户名
  String userName = '';

  /// 用户昵称
  String nickname = '';

  String get allName => nickname.isEmpty ? userName : '$nickname($userName)';

  /// 用户头像
  String avatarURL = '';

  /// 用户徽章
  MetalList sysMetal = [];

  /// 消息来源
  String get client => via.toString();

  /// 消息来源结构
  ChatSource via = ChatSource();

  /// 消息内容
  String content = '';

  /// 消息内容 Markdown
  String md = '';

  /// 是否为红包消息
  bool get isRedpacket => redpacket != null;

  /// 红包消息内容
  RedPacketMessage? redpacket;

  /// 是否为天气消息
  bool get isWeather => weather != null;

  /// 天气消息内容
  WeatherMsg? weather;

  /// 是否为音乐消息
  bool get isMusic => music != null;

  /// 音乐消息内容
  MusicMsg? music;

  /// 未知消息内容
  dynamic unknown;

  /// 发送时间
  String time = '';

  /// 消息类型
  String type = ChatRoomMessageType.msg;

  ChatRoomMessage({
    this.oId = '',
    this.userOId = 0,
    this.userName = '',
    this.nickname = '',
    this.avatarURL = '',
    this.sysMetal = const [],
    ChatSource? via,
    this.content = '',
    this.md = '',
    this.redpacket,
    this.weather,
    this.music,
    this.time = '',
    this.type = ChatRoomMessageType.msg,
  }) {
    this.via = via ?? ChatSource();
  }

  ChatRoomMessage.from(Map<String, dynamic> data) {
    oId = data['oId'] ?? '';
    userOId = data['userOId'] ?? 0;
    userName = data['userName'] ?? '';
    nickname = data['userNickname'] ?? '';
    avatarURL = data['userAvatarURL'] ?? '';
    sysMetal = toMetal(data['sysMetal']);
    via = ChatSource.from(data['client']);
    content = data['content'];
    md = data['md'] ?? data['content'] ?? '';
    try {
      dynamic contentData = json.decode(data['content'] ?? 'null');
      type = contentData["msgType"];
      if (type == ChatRoomMessageType.redPacket) {
        redpacket = RedPacketMessage.from(contentData);
      } else if (type == ChatRoomMessageType.weather) {
        weather = WeatherMsg.from(contentData);
      } else if (type == ChatRoomMessageType.music) {
        music = MusicMsg.from(contentData);
      } else {
        unknown = contentData;
      }
      // ignore: empty_catches
    } catch (e) {}
    time = data['time'];
  }

  toJson() => {
        'oId': oId,
        'userOId': userOId,
        'userName': userName,
        'userNickname': nickname,
        'userAvatarURL': avatarURL,
        'sysMetal': sysMetal.map((e) => e.toJson()).toList(),
        'client': client,
        'content': content,
        'time': time,
        'redpacket': redpacket?.toJson(),
        'isRedpacket': isRedpacket,
        'via': via.toJson(),
      };

  @override
  String toString() {
    return "ChatRoomMessage{ oId=$oId, userOId=$userOId, userName=$userName, userNickname=$nickname, userAvatarURL=$avatarURL, sysMetal=$sysMetal, client=$client, via=$via, content=$content, redpacket=$redpacket, time=$time }";
  }
}

/// 历史消息类型
class ChatContentType {
  /// 原始 Markdown
  static const Markdown = "md";

  /// 渲染 HTML
  static const HTML = "html";
}

/// 相关消息位置类型
enum ChatMessageType {
  /// 前后消息
  Context,

  /// 前面的消息
  Before,

  /// 后面的消息
  After
}

/// 聊天室消息类型
class ChatRoomMessageType {
  /// 在线用户
  static const online = "online";

  /// 话题修改
  static const discussChanged = "discussChanged";

  /// 消息撤回
  static const revoke = "revoke";

  /// 消息
  static const msg = "msg";

  /// 红包
  static const redPacket = "redPacket";

  /// 红包状态
  static const redPacketStatus = "redPacketStatus";

  /// 弹幕
  static const barrager = "barrager";

  /// 自定义消息
  static const custom = "customMessage";

  /// 天气消息
  static const weather = "weather";

  /// 音乐消息
  static const music = "music";
}

/// 聊天室消息
class ChatRoomData {
  /// 消息类型，
  String type = ChatRoomMessageType.msg;

  /// 消息内容
  /// OnlineMsg | discussMsg | RevokeMsg | ChatRoomMessage | RedPacketStatusMsg | BarragerMsg | CustomMsg
  OnlineMsg? online;
  DiscussMsg? discuss;
  RevokeMsg? revoke;
  ChatRoomMessage? msg;
  RedPacketStatusMsg? status;
  BarragerMsg? barrager;
  CustomMsg? custom;
  dynamic unknown;

  ChatRoomData(this.type, data) {
    switch (type) {
      case ChatRoomMessageType.online:
        online = data;
        break;
      case ChatRoomMessageType.discussChanged:
        discuss = data;
        break;
      case ChatRoomMessageType.revoke:
        revoke = data;
        break;
      case ChatRoomMessageType.music:
      case ChatRoomMessageType.weather:
      case ChatRoomMessageType.redPacket:
      case ChatRoomMessageType.msg:
        msg = data;
        break;
      case ChatRoomMessageType.redPacketStatus:
        status = data;
        break;
      case ChatRoomMessageType.barrager:
        barrager = data;
        break;
      case ChatRoomMessageType.custom:
        custom = data;
        break;
      default:
        unknown = data;
        break;
    }
  }
}

/// 聊天室监听
typedef ChatroomListener = void Function(ChatRoomData);

// 自定义消息
typedef CustomMsg = String;

/// 弹幕消息
class BarragerMsg {
  /// 用户名
  String userName;

  /// 用户昵称
  String userNickname;

  String get allName => userNickname.isEmpty ? userName : '$userNickname($userName)';

  /// 弹幕内容
  String barragerContent;

  /// 弹幕颜色
  String barragerColor;

  /// 用户头像地址
  String avatarURL;

  /// 用户头像地址 20x20
  String avatarURL20;

  /// 用户头像地址 48x48
  String avatarURL48;

  /// 用户头像地址 210x210
  String avatarURL210;

  BarragerMsg({
    this.userName = '',
    this.userNickname = '',
    this.barragerContent = '',
    this.barragerColor = '',
    this.avatarURL = '',
    this.avatarURL20 = '',
    this.avatarURL48 = '',
    this.avatarURL210 = '',
  });

  BarragerMsg.from(Map data)
      : userName = data['userName'] ?? '',
        userNickname = data['userNickname'] ?? '',
        barragerContent = data['barragerContent'] ?? '',
        barragerColor = data['barragerColor'] ?? '',
        avatarURL = data['userAvatarURL'] ?? '',
        avatarURL20 = data['userAvatarURL20'] ?? '',
        avatarURL48 = data['userAvatarURL48'] ?? '',
        avatarURL210 = data['userAvatarURL210'] ?? '';

  toJson() => {
        'userName': userName,
        'userNickname': userNickname,
        'barragerContent': barragerContent,
        'barragerColor': barragerColor,
        'userAvatarURL': avatarURL,
        'userAvatarURL20': avatarURL20,
        'userAvatarURL48': avatarURL48,
        'userAvatarURL210': avatarURL210,
      };

  @override
  String toString() {
    return "BarragerMsg{ userName=$userName, userNickname=$userNickname, barragerContent=$barragerContent, barragerColor=$barragerColor, userAvatarURL=$avatarURL, userAvatarURL20=$avatarURL20, userAvatarURL48=$avatarURL48, userAvatarURL210=$avatarURL210 }";
  }
}

/// 在线用户信息
class OnlineInfo {
  /// 用户首页
  String homePage;

  /// 用户头像
  String avatarURL;

  /// 用户名
  String userName;

  OnlineInfo({
    this.homePage = '',
    this.avatarURL = '',
    this.userName = '',
  });

  OnlineInfo.from(Map data)
      : homePage = data['homePage'] ?? '',
        avatarURL = data['userAvatarURL'] ?? '',
        userName = data['userName'] ?? '';

  toJson() => {
        'homePage': homePage,
        'userAvatarURL': avatarURL,
        'userName': userName,
      };

  @override
  String toString() {
    return "OnlineInfo{ homePage=$homePage, userAvatarURL=$avatarURL, userName=$userName }";
  }
}

/// 在线用户列表
typedef OnlineMsg = List<OnlineInfo>;

/// 主题修改消息，主题内容
typedef DiscussMsg = String;

/// 撤回消息，被撤回消息的 oId
typedef RevokeMsg = String;

/// 弹幕花费
class BarrageCost {
  int cost;
  String unit;

  BarrageCost({
    this.cost = 20,
    this.unit = '积分',
  });

  BarrageCost.from(Map data)
      : cost = data['cost'] ?? 20,
        unit = data['unit'] ?? '积分';

  toJson() => {
        'cost': cost,
        'unit': unit,
      };

  @override
  toString() {
    return "BarrageCose{ cost=$cost, unit=$unit }";
  }
}

/// 被禁言用户信息
class MuteItem {
  /// 解除禁言时间戳
  int time;

  /// 用户头像
  String avatarURL;

  /// 用户名
  String userName;

  /// 用户昵称
  String nickname;

  MuteItem({
    required this.time,
    required this.avatarURL,
    required this.userName,
    required this.nickname,
  });

  MuteItem.from(Map<String, dynamic> data)
      : time = data['time'] ?? '',
        avatarURL = data['userAvatarURL'] ?? '',
        userName = data['userName'] ?? '',
        nickname = data['userNickname'] ?? '';

  Map<String, dynamic> toJson() => {
        'time': time,
        'userAvatarURL': avatarURL,
        'userName': userName,
        'userNickname': nickname,
      };

  @override
  String toString() {
    return 'MuteItem{ time: $time, userAvatarURL: $avatarURL, userName: $userName, userNickname: $nickname }';
  }
}

class WeatherMsgData {
  String date = '';
  String code = '';
  double min = 0;
  double max = 0;

  WeatherMsgData({
    this.date = '',
    this.code = '',
    this.min = 0,
    this.max = 0,
  });

  toJson() => {
        'date': date,
        'code': code,
        'min': min,
        'max': max,
      };

  @override
  String toString() {
    return "WeatherMsgData{ date=$date, code=$code, min=$min, max=$max }";
  }
}

class WeatherMsg {
  String city = '';
  String description = '';
  List<WeatherMsgData> data = [];

  WeatherMsg({
    this.city = '',
    this.description = '',
    this.data = const [],
  });

  WeatherMsg.from(Map data)
      : city = data['t'] ?? '',
        description = data['st'] ?? '',
        data = WeatherMsg.getData(data);

  static List<WeatherMsgData> getData(Map data) {
    List<WeatherMsgData> dataList = [];
    List<String> dates = data["date"].split(",");
    List<String> codes = data["weatherCode"].split(",");
    List<String> maxs = data["max"].split(",");
    List<String> mins = data["min"].split(",");
    for (int i = 0; i < dates.length; i++) {
      dataList.add(WeatherMsgData(
        date: dates[i],
        code: codes[i],
        max: double.parse(maxs[i]),
        min: double.parse(mins[i]),
      ));
    }
    return dataList;
  }

  toJson() => {
        'city': city,
        'description': description,
        'data': data.map((e) => e.toJson()).toList(),
      };

  @override
  String toString() {
    return "WeatherMsg{ city=$city, description=$description, data=$data }";
  }
}

class MusicMsg {
  String type = 'music';
  String source = '';
  String coverURL = '';
  String title = '';
  String from = '';

  MusicMsg({
    this.type = 'music',
    this.source = '',
    this.coverURL = '',
    this.title = '',
    this.from = '',
  });

  MusicMsg.from(Map data)
      : type = data['type'] ?? 'music',
        source = data['source'] ?? '',
        coverURL = data['coverURL'] ?? '',
        title = data['title'] ?? '',
        from = data['from'] ?? '';

  toJson() => {
        'type': type,
        'source': source,
        'coverURL': coverURL,
        'title': title,
        'from': from,
      };

  @override
  String toString() {
    return "MusicMsg{ type=$type, source=$source, coverURL=$coverURL, title=$title, from=$from }";
  }
}

class ChatRoomNode {
  String node;
  String name;
  int online;

  ChatRoomNode({
    required this.node,
    required this.name,
    required this.online,
  });

  ChatRoomNode.from(Map data)
      : node = data['node'] ?? '',
        name = data['name'] ?? '',
        online = data['online'] ?? 0;
}

class ChatRoomNodeInfo {
  ChatRoomNode recommend;
  List<ChatRoomNode> avaliable;

  ChatRoomNodeInfo({
    required this.recommend,
    required this.avaliable,
  });

  ChatRoomNodeInfo.from(Map data)
      : recommend = ChatRoomNode.from({
          'node': data['data'],
          'name': data['msg'],
          'online':
              List.from(data['avaliable']).firstWhere((element) => element['name'] == data['msg'])?['online'] ?? 0,
        }),
        avaliable = List.from(data['avaliable']).map((element) => ChatRoomNode.from(element)).toList();
}
