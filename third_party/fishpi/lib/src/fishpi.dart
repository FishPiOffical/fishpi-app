import 'dart:convert';
import 'dart:io';

import 'package:fishpi/fishpi.dart';
import 'package:fishpi/src/request.dart';

/// 摸鱼派接口
class Fishpi {
  String _apiKey = '';
  User user = User();
  Chatroom chatroom = Chatroom();
  Chat chat = Chat();
  Breezemoon breezemoon = Breezemoon();
  Emoji emoji = Emoji();
  Article article = Article();
  Notice notice = Notice();
  Comment comment = Comment();

  static setOrigin(String? url) {
    if (url == null) return;

    var urls = url.split('://');
    var protocol = 'https';
    var domain = '';

    if (urls.length == 1) {
      domain = urls[0];
    } else {
      protocol = urls[0];
      domain = urls[1];
    }
    Request.setDomain(protocol: protocol, domain: domain);
  }

  Fishpi([String token = '']) {
    this.token = token;
  }

  String get token => _apiKey;

  get isLogin => _apiKey != '';

  set token(String token) {
    _apiKey = token;
    user.token = token;
    chatroom.token = token;
    chat.token = token;
    breezemoon.token = token;
    emoji.token = token;
    article.token = token;
    notice.token = token;
    comment.token = token;
  }

  /// 登录
  ///
  /// - `data` 登录账密
  ///
  /// 返回用户的 Token
  Future<String> login(LoginData data) async {
    try {
      var rsp = await Request.post('api/getKey', data: data.toJson());

      if (rsp['code'] != 0) return Future.error(rsp['msg']);

      token = rsp['Key'].trim();
      return token;
    } catch (e) {
      return Future.error(e);
    }
  }

  static String get captcha => '${Request.origin}/captcha';

  /// 预注册
  ///
  /// - `data` 预注册数据
  ///
  /// 返回预注册结果
  Future<ResponseResult> preRegister(PreRegisterInfo data) async {
    try {
      var rsp = await Request.post('register', data: data.toJson());

      return ResponseResult.from(rsp);
    } catch (e) {
      return Future.error(e);
    }
  }

  /// 验证手机验证码
  ///
  /// - `code` 验证码
  ///
  /// 返回用户 ID
  Future<String> verify(String code) async {
    try {
      var rsp = await Request.get('verify', params: {'code': code});

      if (rsp['code'] != 0) return Future.error(rsp['msg']);

      return rsp['userId'];
    } catch (e) {
      return Future.error(e);
    }
  }

  /// 注册
  ///
  /// - `data` 注册数据
  ///
  /// 返回注册结果
  Future<ResponseResult> register(RegisterInfo data) async {
    try {
      var rsp = await Request.post(
        'register2',
        params: {"r": data.r},
        data: data.toJson(),
      );

      if (rsp['code'] != null && rsp['code'] != 0) {
        return Future.error(rsp['msg']);
      }

      return ResponseResult.from(rsp);
    } catch (e) {
      return Future.error(e);
    }
  }

  /// 获取用户信息
  ///
  /// - `username` 用户名
  ///
  /// 返回用户信息
  Future<UserInfo> getUser(String username) async {
    try {
      var rsp = await Request.get(
        'user/$username',
        params: {'apiKey': _apiKey},
      );

      if ((rsp['code'] ?? 0) != 0) return Future.error(rsp['msg']);

      return UserInfo.from(rsp);
    } catch (e) {
      return Future.error(e);
    }
  }

  /// 获取用户名联想
  ///
  /// - `name` 用户名
  ///
  /// 返回用户名联想列表
  Future<AtUserList> names(String name) async {
    try {
      var rsp = await Request.post(
        'users/names',
        data: {
          'name': name,
        },
      );

      if ((rsp['code'] ?? 0) != 0) return Future.error(rsp['msg']);

      return List.from(rsp.data).map((e) => AtUser.from(e)).toList();
    } catch (e) {
      return Future.error(e);
    }
  }

  /// 获取最近注册的 20 个用户
  ///
  /// 返回用户列表
  Future<List<UserLite>> recentRegister() async {
    try {
      var rsp = await Request.get('api/user/recentReg');

      return List.from(rsp["data"] ?? []).map((e) => UserLite.from(e)).toList();
    } catch (e) {
      return Future.error(e);
    }
  }

  /// 获取用户VIP信息
  ///
  /// 返回用户VIP信息
  Future<UserVipInfo> vipInfo(userId) async {
    try {
      var rsp = await Request.get(
        'api/membership/$userId',
      );

      if ((rsp['code'] ?? 0) != 0) return Future.error(rsp['msg']);

      dynamic data = json.decode(rsp['data']['configJson'] ?? 'null') ?? {};

      data['state'] = rsp['data']['state'];
      if (data['state'] == 1) {
        data['oId'] = rsp['data']['oId'];
        data['userId'] = rsp['data']['userId'];
        data['lvCode'] = rsp['data']['lvCode'];
        data['expiresAt'] = rsp['data']['expiresAt'];
        data['createdAt'] = rsp['data']['createdAt'];
        data['updatedAt'] = rsp['data']['updatedAt'];
      }

      return UserVipInfo.from(data);
    } catch (e) {
      return Future.error(e);
    }
  }

  /// 举报
  ///
  /// - `data` 举报数据
  Future<ResponseResult> report(Report data) async {
    try {
      var rsp = await Request.post('report', data: {
        'apiKey': _apiKey,
        ...data.toJson(),
      });

      return ResponseResult.from(rsp);
    } catch (e) {
      return Future.error(e);
    }
  }

  /// 获取操作日志
  ///
  /// - `page` 页码
  /// - `pageSize` 每页数量
  Future<List<Log>> log({int page = 1, int pageSize = 30}) async {
    try {
      var rsp = await Request.get('logs/more', params: {'page': page, 'pageSize': pageSize});

      return List.from(rsp['data'] ?? []).map((e) => Log.from(e)).toList();
    } catch (e) {
      return Future.error(e);
    }
  }

  /// 上传文件
  ///
  /// - `files` 文件路径
  ///
  /// 返回上传结果
  Future<UploadResult> upload(List<String> files) async {
    try {
      var notExist = files.where(
        (element) => !File(element).existsSync(),
      );
      if (notExist.isNotEmpty) {
        return Future.error('File not exist: ${notExist.join(',')}');
      }
      var data = await Request.formData('file[]', files: files, src: {"apiKey": _apiKey});
      var rsp = await Request.post('upload', data: data);

      if (rsp['code'] != 0) return Future.error(rsp['msg']);

      return UploadResult.from(rsp['data']);
    } catch (e) {
      return Future.error(e);
    }
  }
}
