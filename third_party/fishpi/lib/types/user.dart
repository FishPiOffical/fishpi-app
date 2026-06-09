// ignore_for_file: constant_identifier_names

import 'dart:convert';

import 'package:fishpi/src/request.dart';
import 'package:fishpi/src/utils.dart';
import 'package:fishpi/src/json_safe.dart' as json_safe;

/// 徽章属性
class MetalAttr {
  /// 徽标图地址
  String url;

  /// 背景色
  String backcolor;

  /// 文字颜色
  String fontcolor;

  /// 缩放
  double scale;

  /// 版本号
  double ver;

  MetalAttr({
    this.url = '',
    this.backcolor = '',
    this.fontcolor = '',
    this.scale = 0.79,
    this.ver = 0.1,
  });

  MetalAttr.from(Map<String, dynamic>? attr)
      : url = json_safe.readString(attr?['url']),
        backcolor = json_safe.readString(attr?['backcolor']),
        fontcolor = json_safe.readString(attr?['fontcolor']),
        scale = json_safe.readDouble(attr?['scale'], fallback: 0.79),
        ver = json_safe.readDouble(attr?['ver'], fallback: 0.1);

  toJson() => {
        'url': url,
        'backcolor': backcolor,
        'fontcolor': fontcolor,
        'scale': scale,
        'ver': ver,
      };

  @override
  toString() {
    return 'url=$url&backcolor=$backcolor&fontcolor=$fontcolor&scale=$scale&ver=$ver';
  }
}

/// 徽章基础信息
class MetalBase {
  /// 徽章属性
  MetalAttr attr;

  /// 徽章名
  String name;

  /// 徽章描述
  String description;

  /// 徽章数据
  String data;

  MetalBase({
    required this.attr,
    required this.name,
    required this.description,
    this.data = '',
  });

  MetalBase.from(Map<String, dynamic> metal)
      : attr = MetalAttr.from(json_safe.readMap(metal['attr'])),
        name = json_safe.readString(metal['name']),
        description = json_safe.readString(metal['description']),
        data = json_safe.readString(metal['data']);

  toJson() => {
        'attr': attr.toJson(),
        'name': name,
        'description': description,
        'data': data,
      };

  toUrl([includeText = true]) {
    var url = '${Request.origin}/gen?txt=$name}&$attr';
    if (!includeText) {
      url = '${Request.origin}/gen?txt=&$attr';
    }
    return url;
  }
}

/// 徽章信息
class Metal extends MetalBase {
  /// 完整徽章地址（含文字）
  String get url => toUrl();

  /// 徽章地址（不含文字）
  String get icon => toUrl(false);

  /// 是否佩戴
  String? enable;

  Metal({
    required super.attr,
    required super.name,
    required super.description,
    super.data = '',
    this.enable,
  });

  // ignore: use_super_parameters
  Metal.from(Map<String, dynamic> metal)
      : enable = metal['enable']?.toString(),
        super.from(metal);

  @override
  toJson() => {
        ...super.toJson(),
        'enable': enable,
      };

  @override
  toString() {
    return "{ url=$url, icon=$icon, enable=$enable, attr=$attr, name=$name, description=$description, data=$data }";
  }
}

/// 徽章列表
typedef MetalList = List<Metal>;

/// 应用角色
enum UserAppRole {
  /// 黑客
  Hack,

  /// 画家
  Artist,
}

/// 用户信息
class UserInfo {
  /// 用户 id
  String oId;

  /// 用户编号
  String userNo;

  String get name => nickname.isEmpty ? userName : nickname;

  String get allName => nickname.isEmpty ? userName : '$nickname($userName)';

  /// 用户名
  String userName;

  /// 昵称
  String nickname;

  /// 首页地址
  String userURL;

  /// 所在城市
  String city;

  /// 签名
  String intro;

  /// 是否在线
  bool isOnline;

  /// 用户积分
  int point;

  /// 用户组
  String role;

  /// 角色
  UserAppRole appRole;

  /// 用户头像地址
  String avatarURL;

  /// 用户卡片背景
  String cardBg;

  /// 用户关注数
  int followingCnt;

  /// 用户被关注数
  int followerCnt;

  /// 在线时长，单位分钟
  int onlineMinute;

  /// 是否已经关注，未登录则为 `hide`
  String canFollow;

  /// 用户所有勋章列表，包含未佩戴
  MetalList allMetals;

  /// 用户勋章列表
  MetalList sysMetal;

  UserInfo({
    this.oId = '',
    this.userNo = '',
    this.userName = '',
    this.nickname = '',
    this.userURL = '',
    this.city = '',
    this.intro = '',
    this.isOnline = false,
    this.point = 0,
    this.role = '',
    this.appRole = UserAppRole.Hack,
    this.avatarURL = '',
    this.cardBg = '',
    this.followingCnt = 0,
    this.followerCnt = 0,
    this.onlineMinute = 0,
    this.canFollow = 'hide',
    this.allMetals = const [],
    this.sysMetal = const [],
  });

  UserInfo.from(Map data)
      : oId = json_safe.readString(data['oId']),
        userNo = json_safe.readString(data['userNo']),
        userName = json_safe.readString(data['userName']),
        nickname = json_safe.readString(data['userNickname']),
        userURL = json_safe.readString(data['userURL']),
        city = json_safe.readString(data['userCity']),
        intro = json_safe.readString(data['userIntro']),
        isOnline = json_safe.readBool(data['userOnlineFlag']),
        point = json_safe.readInt(data['userPoint']),
        role = json_safe.readString(data['userRole']),
        appRole = json_safe.readEnum(
          UserAppRole.values,
          data['userAppRole'],
          fallback: UserAppRole.Hack,
        ),
        avatarURL = json_safe.readString(data['userAvatarURL']),
        cardBg = json_safe.readString(data['cardBg']),
        followingCnt = json_safe.readInt(data['followingUserCount']),
        followerCnt = json_safe.readInt(data['followerCount']),
        onlineMinute = json_safe.readInt(data['onlineMinute']),
        canFollow = json_safe.readString(data['canFollow'], fallback: 'self'),
        allMetals = toMetal(data['allMetalOwned'] ?? '[]'),
        sysMetal = toMetal(data['sysMetal'] ?? '[]');

  toJson() => {
        'oId': oId,
        'userNo': userNo,
        'userName': userName,
        'userNickname': nickname,
        'userURL': userURL,
        'userCity': city,
        'userIntro': intro,
        'userOnlineFlag': isOnline,
        'userPoint': point,
        'userRole': role,
        'userAppRole': appRole.index,
        'userAvatarURL': avatarURL,
        'cardBg': cardBg,
        'followingUserCount': followingCnt,
        'followerCount': followerCnt,
        'onlineMinute': onlineMinute,
        'canFollow': canFollow,
        'allMetalOwned': allMetals.map((e) => e.toJson()).toList(),
        'sysMetal': sysMetal.map((e) => e.toJson()).toList(),
      };

  @override
  toString() {
    return "{ oId=$oId, userNo=$userNo, userName=$userName, userNickname=$nickname, userURL=$userURL, userCity=$city, userIntro=$intro, userOnlineFlag=$isOnline, userPoint=$point, userRole=$role, userAppRole=$appRole, userAvatarURL=$avatarURL, cardBg=$cardBg, followingUserCount=$followingCnt, followerCount=$followerCnt, onlineMinute=$onlineMinute, canFollow=$canFollow, allMetalOwned=$allMetals, sysMetal=$sysMetal }";
  }
}

/// 用户资料更新参数。
class UpdateUserParams {
  /// 昵称
  String? userNickname;

  /// 用户标签
  String? userTags;

  /// 个人主页 URL
  String? userURL;

  /// 个性签名
  String? userIntro;

  /// MBTI
  String? mbti;

  UpdateUserParams({
    this.userNickname,
    this.userTags,
    this.userURL,
    this.userIntro,
    this.mbti,
  });

  UpdateUserParams.from(Map data)
      : userNickname = data['userNickname']?.toString(),
        userTags = data['userTags']?.toString(),
        userURL = data['userURL']?.toString(),
        userIntro = data['userIntro']?.toString(),
        mbti = data['mbti']?.toString();

  Map<String, dynamic> toJson() => {
        'userNickname': userNickname,
        'userTags': userTags,
        'userURL': userURL,
        'userIntro': userIntro,
        'mbti': mbti,
      };

  @override
  String toString() {
    return '{ userNickname=$userNickname, userTags=$userTags, userURL=$userURL, userIntro=$userIntro, mbti=$mbti }';
  }
}

/// VIP 套餐信息。
class MembershipLevel {
  /// 套餐 ID
  int oId;

  /// 套餐代码，如 VIP1_MONTH、VIP2_YEAR
  String lvCode;

  /// 套餐名称
  String lvName;

  /// 价格，单位为积分
  int price;

  /// 时长类型
  String durationType;

  /// 功能说明，服务端返回 JSON 字符串
  String benefits;

  MembershipLevel({
    required this.oId,
    required this.lvCode,
    required this.lvName,
    required this.price,
    required this.durationType,
    required this.benefits,
  });

  MembershipLevel.from(Map<String, dynamic> data)
      : oId = _readInt(data['oId']),
        lvCode = data['lvCode']?.toString() ?? '',
        lvName = data['lvName']?.toString() ?? '',
        price = _readInt(data['price']),
        durationType = data['durationType']?.toString() ?? '',
        benefits = data['benefits']?.toString() ?? '';

  Map<String, dynamic> toJson() => {
        'oId': oId,
        'lvCode': lvCode,
        'lvName': lvName,
        'price': price,
        'durationType': durationType,
        'benefits': benefits,
      };

  @override
  String toString() {
    return '{ oId=$oId, lvCode=$lvCode, lvName=$lvName, price=$price, durationType=$durationType, benefits=$benefits }';
  }
}

/// 用户 VIP 信息。
class MembershipInfo {
  /// 用户 ID
  String oId;

  /// VIP 等级和类型，如 VIP2_MONTH
  String lvCode;

  /// 状态：0 为非 VIP，非 0 为 VIP 状态
  int state;

  /// 过期时间，服务端 ISO 字符串
  String expiresAt;

  /// 昵称样式配置 JSON
  String configJson;

  MembershipInfo({
    required this.oId,
    required this.lvCode,
    required this.state,
    required this.expiresAt,
    required this.configJson,
  });

  MembershipInfo.from(Map<String, dynamic> data)
      : oId = data['oId']?.toString() ?? '',
        lvCode = data['lvCode']?.toString() ?? '',
        state = _readInt(data['state']),
        expiresAt = data['expiresAt']?.toString() ?? '',
        configJson = data['configJson']?.toString() ?? '';

  Map<String, dynamic> toJson() => {
        'oId': oId,
        'lvCode': lvCode,
        'state': state,
        'expiresAt': expiresAt,
        'configJson': configJson,
      };

  @override
  String toString() {
    return '{ oId=$oId, lvCode=$lvCode, state=$state, expiresAt=$expiresAt, configJson=$configJson }';
  }
}

/// VIP 用户配置信息，用于批量查询昵称样式。
class MembershipUserConfig {
  /// 用户 ID
  String userId;

  /// 昵称样式配置 JSON 字符串
  String configJson;

  /// 解析后的配置对象
  MembershipConfig? config;

  MembershipUserConfig({
    required this.userId,
    required this.configJson,
    this.config,
  });

  MembershipUserConfig.from(Map<String, dynamic> data)
      : userId = data['userId']?.toString() ?? '',
        configJson = data['configJson']?.toString() ?? '',
        config = _parseMembershipConfig(data['configJson']);

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'configJson': configJson,
      };

  @override
  String toString() {
    return '{ userId=$userId, configJson=$configJson, config=$config }';
  }
}

/// VIP 配置参数。
class MembershipConfig {
  /// 是否开启联合会员
  bool? jointVip;

  /// 昵称颜色或渐变配置
  String? color;

  /// 是否显示下划线
  bool? underline;

  /// 是否显示会员勋章
  bool? metal;

  /// 自动签到，0 为关闭，1 为开启
  int? autoCheckin;

  /// 是否加粗
  bool? bold;

  /// 免签卡数量
  int? checkinCard;

  MembershipConfig({
    this.jointVip,
    this.color,
    this.underline,
    this.metal,
    this.autoCheckin,
    this.bold,
    this.checkinCard,
  });

  MembershipConfig.from(Map<String, dynamic> data)
      : jointVip = _readBoolOrNull(data['jointVip']),
        color = data['color']?.toString(),
        underline = _readBoolOrNull(data['underline']),
        metal = _readBoolOrNull(data['metal']),
        autoCheckin = data.containsKey('autoCheckin')
            ? _readInt(data['autoCheckin'])
            : null,
        bold = _readBoolOrNull(data['bold']),
        checkinCard = data.containsKey('checkinCard')
            ? _readInt(data['checkinCard'])
            : null;

  Map<String, dynamic> toJson() => {
        if (jointVip != null) 'jointVip': jointVip,
        if (color != null) 'color': color,
        if (underline != null) 'underline': underline,
        if (metal != null) 'metal': metal,
        if (autoCheckin != null) 'autoCheckin': autoCheckin,
        if (bold != null) 'bold': bold,
        if (checkinCard != null) 'checkinCard': checkinCard,
      };

  @override
  String toString() {
    return '{ jointVip=$jointVip, color=$color, underline=$underline, metal=$metal, autoCheckin=$autoCheckin, bold=$bold, checkinCard=$checkinCard }';
  }
}

MembershipConfig? _parseMembershipConfig(dynamic value) {
  if (value == null) return null;
  if (value is Map) {
    return MembershipConfig.from(Map<String, dynamic>.from(value));
  }
  try {
    final decoded = jsonDecode(value.toString());
    if (decoded is Map<String, dynamic>) {
      return MembershipConfig.from(decoded);
    }
  } catch (_) {}
  return null;
}

int _readInt(dynamic value) {
  return json_safe.readInt(value);
}

bool? _readBoolOrNull(dynamic value) {
  return json_safe.readBoolOrNull(value);
}
