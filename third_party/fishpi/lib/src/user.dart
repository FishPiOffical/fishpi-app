import 'package:fishpi/fishpi.dart';
import 'package:fishpi/src/request.dart';

/// 用户接口
class User {
  String _token = '';
  UserInfo _infoCache = UserInfo();
  String get token => _token;
  set token(String token) {
    _token = token;
    _infoCache = UserInfo();
  }

  /// 当前登录用户信息，需至少调用一次 `info` 方法
  UserInfo get current => _infoCache;

  /// 查询登录用户信息
  Future<UserInfo> info([bool cache = true]) async {
    try {
      if (_infoCache.userName.isNotEmpty && cache) return _infoCache;

      var rsp = await Request.get('api/user', params: {'apiKey': token});

      if (rsp['code'] != 0) return Future.error(rsp['msg']);

      return _infoCache = UserInfo.from(rsp['data']);
    } catch (e) {
      return Future.error(e);
    }
  }

  /// 查询登录用户常用表情
  ///
  /// 返回常用表情列表
  Future<List<String>> emotions() async {
    try {
      var rsp = await Request.get('users/emotions', params: {'apiKey': token});

      if (rsp['code'] != 0) return Future.error(rsp['msg']);

      return (rsp['data'] as Map<String, dynamic>).keys.toList();
    } catch (e) {
      return Future.error(e);
    }
  }

  /// 查询登录用户当前活跃度，请求频率请控制在 30 ~ 60 秒一次
  ///
  /// 返回活跃度
  Future<double> liveness() async {
    if (token.isEmpty) {
      return 0;
    }
    try {
      var rsp = await Request.get('user/liveness', params: {'apiKey': token});

      return rsp['liveness'] ?? 0.0;
    } catch (e) {
      return Future.error(e);
    }
  }

  /// 检查登录用户是否已经签到
  ///
  /// 返回是否已经签到
  Future<bool> isCheckIn() async {
    if (token.isEmpty) {
      return false;
    }
    try {
      var rsp = await Request.get('user/checkedIn', params: {'apiKey': token});

      return rsp['checkedIn'] ?? false;
    } catch (e) {
      return Future.error(e);
    }
  }

  /// 检查登录用户是否已经领取昨日活跃奖励
  ///
  /// 返回是否已经领取昨日活跃奖励
  Future<bool> isCollectedLiveness() async {
    if (token.isEmpty) {
      return false;
    }
    try {
      var rsp = await Request.get('api/activity/is-collected-liveness',
          params: {'apiKey': token});

      return rsp['isCollectedYesterdayLivenessReward'] ?? false;
    } catch (e) {
      return Future.error(e);
    }
  }

  /// 领取昨日活跃度奖励
  ///
  /// 返回领取的奖励积分
  Future<int> rewardLiveness() async {
    if (token.isEmpty) {
      return 0;
    }
    try {
      var rsp = await Request.get('activity/yesterday-liveness-reward-api',
          params: {'apiKey': token});

      return rsp['sum'] ?? 0;
    } catch (e) {
      return Future.error(e);
    }
  }

  /// 转账
  ///
  /// - `userName` 转账目标用户名
  /// - `amount` 转账金额
  /// - `memo` 转账备注
  /// 返回 code 0 为成功，失败则有 msg
  Future<ResponseResult> transfer(
      String userName, int amount, String memo) async {
    try {
      var rsp = await Request.post('point/transfer', data: {
        'apiKey': token,
        'userName': userName,
        'amount': amount,
        'memo': memo,
      });

      return ResponseResult.from(rsp);
    } catch (e) {
      return Future.error(e);
    }
  }

  /// 关注/取消关注用户
  ///
  /// - `userOId` 用户 ID
  /// - `follow` 是否关注，默认关注
  /// 返回 code 0 为成功，失败则有 msg
  Future<ResponseResult> follow(String userOId, {bool follow = true}) async {
    try {
      var rsp = await Request.post('${!follow ? 'un' : ''}follow/user', data: {
        'apiKey': token,
        'followingId': userOId,
      });

      return ResponseResult.from(rsp);
    } catch (e) {
      return Future.error(e);
    }
  }

  /// 更新用户头像。
  ///
  /// - `userAvatarURL` 用户头像 URL
  /// 返回 code 0 为成功，失败则有 msg。
  Future<ResponseResult> updateAvatar(String userAvatarURL) async {
    try {
      var rsp = await Request.post('api/settings/avatar', data: {
        'apiKey': token,
        'userAvatarURL': userAvatarURL,
      });

      if (rsp['code'] == 0) {
        _infoCache = UserInfo();
      }
      return ResponseResult.from(rsp);
    } catch (e) {
      return Future.error(e);
    }
  }

  /// 更新用户资料。
  ///
  /// 本地 App 已验证资料接口使用 settings/profiles JSON 请求体；
  /// 上游 1.0.29 的 updateUserInfo 目标地址疑似误写为 avatar，本地不照搬。
  Future<ResponseResult> updateUserInfo(UpdateUserParams data) async {
    try {
      var rsp = await Request.post('settings/profiles', data: {
        'apiKey': token,
        ...data.toJson(),
      });

      if (rsp['code'] == 0) {
        _infoCache = UserInfo();
      }
      return ResponseResult.from(rsp);
    } catch (e) {
      return Future.error(e);
    }
  }

  /// 配置 VIP 信息。
  ///
  /// - `config` VIP 配置参数
  /// 返回 code 0 为成功，失败则有 msg。
  Future<ResponseResult> configMembership(MembershipConfig config) async {
    try {
      var rsp = await Request.put(
        'api/membership/config',
        params: {'apiKey': token},
        data: {
          'configJson': config.toJson(),
        },
      );

      return ResponseResult.from(rsp);
    } catch (e) {
      return Future.error(e);
    }
  }

  /// 获取 VIP 套餐列表。
  ///
  /// 返回所有可购买的 VIP 套餐列表。
  Future<List<MembershipLevel>> getMembershipLevels() async {
    try {
      var rsp = await Request.get(
        'api/membership/levels',
        params: {'apiKey': token},
      );

      if (rsp['code'] != 0) return Future.error(rsp['msg']);

      return List.from(rsp['data'] ?? [])
          .whereType<Map>()
          .map((e) => MembershipLevel.from(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      return Future.error(e);
    }
  }

  /// 购买 VIP 会员。
  ///
  /// - `oId` 套餐 ID，来自 getMembershipLevels。
  /// 返回 code 0 为成功，失败则有 msg。
  Future<ResponseResult> openMembership(int oId) async {
    try {
      var rsp = await Request.post(
        'api/membership/open',
        params: {'apiKey': token},
        data: {'oId': oId},
      );

      return ResponseResult.from(rsp);
    } catch (e) {
      return Future.error(e);
    }
  }

  /// 获取所有 VIP 用户配置列表。
  ///
  /// 返回已过滤过期用户的 VIP 配置列表，用于昵称样式批量预热。
  Future<List<MembershipUserConfig>> getMembershipConfigs() async {
    try {
      var rsp = await Request.get(
        'api/memberships/configs',
        params: {'apiKey': token},
      );

      if (rsp['code'] != 0) return Future.error(rsp['msg']);

      return List.from(rsp['data'] ?? [])
          .whereType<Map>()
          .map((e) => MembershipUserConfig.from(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      return Future.error(e);
    }
  }

  /// 获取指定用户的 VIP 信息。
  ///
  /// - `userId` 用户 ID 或 oId
  Future<MembershipInfo> getMembershipInfo(String userId) async {
    try {
      var rsp = await Request.get(
        'api/membership/$userId',
        params: {'apiKey': token},
      );

      if (rsp['code'] != 0) return Future.error(rsp['msg']);

      return MembershipInfo.from(Map<String, dynamic>.from(rsp['data'] ?? {}));
    } catch (e) {
      return Future.error(e);
    }
  }
}
