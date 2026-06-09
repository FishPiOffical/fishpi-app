// ignore_for_file: non_constant_identifier_names, constant_identifier_names
import 'package:fishpi/src/utils.dart';
import 'package:fishpi/src/json_safe.dart' as json_safe;

export 'user.dart';
export 'chatroom.dart';
export 'chat.dart';
export 'redpacket.dart';
export 'breezemoon.dart';
export 'notice.dart';
export 'article.dart';
export 'finger.dart';

/// 登录账户信息
class LoginData {
  /// 用户名
  String username;

  /// 密码
  String passwd;

  /// 二次验证码
  String? mfaCode;

  LoginData({
    this.username = '',
    this.passwd = '',
    this.mfaCode,
  });

  LoginData.from(Map<String, dynamic> data)
      : username = json_safe.readString(data['username']),
        passwd = json_safe.readString(data['passwd']),
        mfaCode = data['mfaCode']?.toString();

  toJson() => {
        'nameOrEmail': username,
        'userPassword': passwd.toMD5(),
        'mfaCode': mfaCode ?? ''
      };

  @override
  toString() {
    return "LoginData{username=$username, passwd=***, mfaCode=${mfaCode == null ? null : '***'}}";
  }
}

/// 预注册账户信息
class PreRegisterInfo {
  /// 用户名
  String username;

  /// 手机号
  String phone;

  /// 邀请码
  String? invitecode;

  /// 验证码
  String captcha;

  PreRegisterInfo({
    this.username = '',
    this.phone = '',
    this.invitecode,
    this.captcha = '',
  });

  PreRegisterInfo.from(Map<String, dynamic> data)
      : username = json_safe.readString(data['username']),
        phone = json_safe.readString(data['phone']),
        invitecode = data['invitecode']?.toString(),
        captcha = json_safe.readString(data['captcha']);

  toJson() => {
        'userName': username,
        'userPhone': phone,
        'invitecode': invitecode ?? '',
        'captcha': captcha
      };

  @override
  toString() {
    return "PreRegisterInfo{username=$username, phone=${_maskPhone(phone)}, invitecode=$invitecode, captcha=***}";
  }
}

/// 注册账户信息
class RegisterInfo {
  /// 用户角色
  String role;

  /// 用户密码
  String passwd;

  /// 用户 Id
  String userId;

  /// 邀请人用户名
  String? r;

  RegisterInfo({
    this.role = '0',
    this.passwd = '',
    this.userId = '',
    this.r,
  });

  RegisterInfo.from(Map<String, dynamic> data)
      : role = json_safe.readString(data['role']),
        passwd = json_safe.readString(data['passwd']),
        userId = json_safe.readString(data['userId']),
        r = data['r']?.toString();

  toJson() => {
        'userAppRole': role,
        'userPassword': passwd.toMD5(),
        'userId': userId,
        'r': r ?? '',
      };

  @override
  toString() {
    return 'RegisterInfo{role: $role, passwd=***, userId: $userId, r: $r}';
  }
}

String _maskPhone(String phone) {
  final trimmed = phone.trim();
  if (trimmed.length < 7) return '***';
  return '${trimmed.substring(0, 3)}****${trimmed.substring(trimmed.length - 4)}';
}

/// 执行结果
class ResponseResult {
  /// 是否成功
  bool success;

  /// 执行结果或错误信息
  String msg;

  ResponseResult({
    this.success = false,
    this.msg = '',
  });

  ResponseResult.from(Map<String, dynamic> data)
      : success = json_safe.readInt(data['code']) == 0,
        msg = json_safe.readString(data['msg']);

  @override
  String toString() {
    return "ResponseResult{ success=$success, msg=$msg }";
  }
}

/// 上传文件信息
class FileInfo {
  /// 文件名
  String filename;

  /// 文件地址
  String url;

  FileInfo({this.filename = '', this.url = ''});

  FileInfo.from(Map<String, dynamic> data)
      : filename = json_safe.readString(data['filename']),
        url = json_safe.readString(data['url']);

  @override
  toString() {
    return "FileInfo{filename=$filename, url=$url}";
  }
}

/// 上传结果
class UploadResult {
  /// 上传失败文件
  List<String> errs;

  /// 上传成功文件
  List<FileInfo> success;

  UploadResult({this.errs = const [], this.success = const []});

  UploadResult.from(Map<String, dynamic> map)
      : errs = json_safe
            .readList(map['errFiles'])
            .map((e) => e.toString())
            .toList(),
        success = json_safe
            .readMap(map['succMap'])
            .entries
            .map(
              (entry) => FileInfo(
                filename: entry.key,
                url: entry.value?.toString() ?? '',
              ),
            )
            .toList();

  toJson() => {
        'errFiles': errs,
        'succMap': success
            .map((e) => {
                  'filename': e.filename,
                  'url': e.url,
                })
            .toList()
      };

  @override
  toString() {
    return "UploadResult{ errFiles=${errs.join(',')}, succFiles=$success }";
  }
}

/// 联想用户信息
class AtUser {
  /// 用户名
  String userName;

  /// 用户头像
  String userAvatarURL;

  /// 全小写用户名
  String userNameLowerCase;

  AtUser({
    this.userName = '',
    this.userAvatarURL = '',
    this.userNameLowerCase = '',
  });

  AtUser.from(Map<String, dynamic> data)
      : userName = json_safe.readString(data['userName']),
        userAvatarURL = json_safe.readString(data['userAvatarURL']),
        userNameLowerCase = json_safe.readString(data['userNameLowerCase']);

  toJson() => {
        'userName': userName,
        'userAvatarURL': userAvatarURL,
        'userNameLowerCase': userNameLowerCase,
      };

  @override
  toString() {
    return 'AtUser{userName: $userName, userAvatarURL: $userAvatarURL, userNameLowerCase: $userNameLowerCase}';
  }
}

/// 联想用户列表
typedef AtUserList = List<AtUser>;

/// 最近注册用户信息
class UserLite {
  String userNickname;
  String userName;

  UserLite({
    this.userName = '',
    this.userNickname = '',
  });

  UserLite.from(Map<String, dynamic> data)
      : userNickname = json_safe.readString(data['userNickname']),
        userName = json_safe.readString(data['userName']);

  toJson() => {
        'userNickname': userNickname,
        'userName': userName,
      };

  @override
  toString() {
    return 'UserLite{userNickname: $userNickname, userName: $userName}';
  }
}

class UserVipInfo {
  bool jointVip;
  String color;
  bool underline;
  bool metal;
  int autoCheckin;
  bool bold;
  String oId;
  bool state;
  String userId;
  String lvCode;
  int expiresAt;
  int createdAt;
  int updatedAt;

  get isVip => state;
  get expiresDate => DateTime.fromMillisecondsSinceEpoch(expiresAt);
  get createdDate => DateTime.fromMillisecondsSinceEpoch(createdAt);
  get updatedDate => DateTime.fromMillisecondsSinceEpoch(updatedAt);
  get VipName =>
      lvCode.replaceAll('_YEAR', '(包年)').replaceAll('_MONTH', '(包月)');

  UserVipInfo({
    this.jointVip = false,
    this.color = '',
    this.underline = false,
    this.metal = false,
    this.autoCheckin = 0,
    this.bold = false,
    this.oId = '',
    this.state = false,
    this.userId = '',
    this.lvCode = '',
    this.expiresAt = 0,
    this.createdAt = 0,
    this.updatedAt = 0,
  });

  UserVipInfo.from(Map<dynamic, dynamic> data)
      : jointVip = json_safe.readBool(data['jointVip']),
        color = json_safe.readString(data['color']),
        underline = json_safe.readBool(data['underline']),
        metal = json_safe.readBool(data['metal']),
        autoCheckin = json_safe.readInt(data['autoCheckin']),
        bold = json_safe.readBool(data['bold']),
        oId = json_safe.readString(data['oId']),
        state = json_safe.readInt(data['state']) == 1,
        userId = json_safe.readString(data['userId']),
        lvCode = json_safe.readString(data['lvCode']),
        expiresAt = json_safe.readInt(data['expiresAt']),
        createdAt = json_safe.readInt(data['createdAt']),
        updatedAt = json_safe.readInt(data['updatedAt']);
}

/// 举报数据类型
enum ReportDataType {
  /// 文章
  article,

  /// 评论
  comment,

  /// 用户
  user,

  /// 聊天消息
  chatroom,
}

/// 举报类型
enum ReportType {
  /// 垃圾广告
  advertise,

  /// 色情
  porn,

  /// 违规
  violate,

  /// 侵权
  infringement,

  /// 人身攻击
  attacks,

  /// 冒充他人账号
  impersonate,

  /// 垃圾广告账号
  advertisingAccount,

  /// 违规泄露个人信息
  leakPrivacy,

  /// 其它
  other,
}

/// 举报数据
class Report {
  /// 举报对象的 oId
  String reportDataId;

  /// 举报数据的类型
  ReportDataType reportDataType = ReportDataType.chatroom;

  /// 举报的类型
  ReportType reportType = ReportType.advertise;

  /// 举报的理由
  String reportMemo = '';

  Report({
    required this.reportDataId,
    this.reportDataType = ReportDataType.chatroom,
    this.reportType = ReportType.advertise,
    required this.reportMemo,
  });

  Report.from(Map<String, dynamic> json)
      : reportDataId = json_safe.readString(json['reportDataId']),
        reportDataType = json_safe.readEnum(
          ReportDataType.values,
          json['reportDataType'],
          fallback: ReportDataType.chatroom,
        ),
        reportType = json_safe.readEnum(
          ReportType.values,
          json['reportType'],
          fallback: ReportType.advertise,
        ),
        reportMemo = json_safe.readString(json['reportMemo']);

  toJson() => {
        'reportDataId': reportDataId,
        'reportDataType': reportDataType.index,
        'reportType': reportType.index,
        'reportMemo': reportMemo,
      };

  @override
  toString() {
    return 'Report{reportDataId: $reportDataId, reportDataType: $reportDataType, reportType: $reportType, reportMemo: $reportMemo}';
  }
}

/// 服务器日志
class Log {
  /// 操作时间
  String key1;

  /// IP
  String key2;

  /// 内容
  String data;

  /// 是否公开
  bool isPublic;

  /// 操作类型
  String key3;

  /// 唯一标识
  String oId;

  /// 类型
  String type;

  Log({
    this.key1 = '',
    this.key2 = '',
    this.data = '',
    this.isPublic = false,
    this.key3 = '',
    this.oId = '',
    this.type = '',
  });

  Log.from(Map<String, dynamic> json)
      : key1 = json_safe.readString(json['key1']),
        key2 = json_safe.readString(json['key2']),
        data = json_safe.readString(json['data']),
        isPublic = json_safe.readBool(json['public']),
        key3 = json_safe.readString(json['key3']),
        oId = json_safe.readString(json['oId']),
        type = json_safe.readString(json['type']);

  toJson() => {
        'key1': key1,
        'key2': key2,
        'data': data,
        'public': isPublic,
        'key3': key3,
        'oId': oId,
        'type': type,
      };

  @override
  toString() {
    return 'Log{key1: $key1, key2: $key2, data: $data, isPublic: $isPublic, key3: $key3, oId: $oId, type: $type}';
  }
}
