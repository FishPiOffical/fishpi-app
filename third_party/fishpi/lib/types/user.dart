// ignore_for_file: constant_identifier_names

import 'package:fishpi/src/request.dart';
import 'package:fishpi/src/utils.dart';

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
      : url = attr?['url'] ?? '',
        backcolor = attr?['backcolor'] ?? '',
        fontcolor = attr?['fontcolor'] ?? '',
        scale = attr?['scale'] ?? 0.79,
        ver = attr?['ver'] ?? 0.1;

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
      : attr = MetalAttr.from(metal['attr']),
        name = metal['name'] ?? '',
        description = metal['description'] ?? '',
        data = metal['data'] ?? '';

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
    required MetalAttr attr,
    required String name,
    required String description,
    String data = '',
    this.enable,
  }) : super(
          attr: attr,
          name: name,
          description: description,
          data: data,
        );

  Metal.from(Map<String, dynamic> metal)
      : enable = metal['enable'],
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
      : oId = data['oId'] ?? '',
        userNo = data['userNo'] ?? '',
        userName = data['userName'] ?? '',
        nickname = data['userNickname'] ?? '',
        userURL = data['userURL'] ?? '',
        city = data['userCity'] ?? '',
        intro = data['userIntro'] ?? '',
        isOnline = data['userOnlineFlag'] ?? '',
        point = data['userPoint'] ?? '',
        role = data['userRole'] ?? '',
        appRole = UserAppRole.values[int.parse(data['userAppRole'] ?? '0')],
        avatarURL = data['userAvatarURL'] ?? '',
        cardBg = data['cardBg'] ?? '',
        followingCnt = data['followingUserCount'] ?? '',
        followerCnt = data['followerCount'] ?? '',
        onlineMinute = data['onlineMinute'] ?? '',
        canFollow = data['canFollow'] ?? 'self',
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
