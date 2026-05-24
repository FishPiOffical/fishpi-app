import 'package:fishpi/fishpi.dart';
import 'package:fishpi/src/request.dart';

/// 金手指接口
class Finger {
  String key = '';

  Finger([String? key]) {
    this.key = key ?? this.key;
  }

  /// 上传摸鱼大闯关关卡数据
  ///
  /// - `userName` 用户在摸鱼派的用户名
  /// - `stage` 关卡数
  /// - `time` 通过此关时间（毫秒级时间戳）
  ///
  /// 返回执行结果
  Future<ResponseResult> addMofishScore(
      {required String userName, required String stage, int? time}) async {
    try {
      var rsp = await Request.post(
        'api/games/mofish/score',
        data: {
          'goldFingerKey': key,
          'userName': userName,
          'stage': stage,
          'time': time ?? DateTime.now().millisecondsSinceEpoch,
        },
      );

      return ResponseResult.from(rsp);
    } catch (e) {
      return Future.error(e);
    }
  }

  /// 查询用户最近登录的IP地址
  ///
  /// - `userName` 用户在摸鱼派的用户名
  ///
  /// 返回执行结果
  Future<UserIP> queryLatestLoginIP(String userName) async {
    try {
      var rsp = await Request.post(
        'user/query/latest-login-iP',
        data: {
          'goldFingerKey': key,
          'userName': userName,
        },
      );

      if (rsp['code'] != 0) return Future.error(rsp['msg']);

      return UserIP.from(rsp);
    } catch (e) {
      return Future.error(e);
    }
  }

  /// 添加勋章
  ///
  /// - `userName` 用户在摸鱼派的用户名
  /// - `metal` 勋章信息
  ///
  /// 返回执行结果
  Future<ResponseResult> addMetal(String userName, MetalBase metal) async {
    try {
      var rsp = await Request.post(
        'user/edit/give-metal',
        data: {
          'goldFingerKey': key,
          'userName': userName,
          ...metal.toJson(),
          'attr': metal.attr.toString(),
        },
      );

      return ResponseResult.from(rsp);
    } catch (e) {
      return Future.error(e);
    }
  }

  /// 删除勋章
  ///
  /// - `userName` 用户在摸鱼派的用户名
  /// - `name` 勋章名称
  ///
  /// 返回执行结果
  Future<ResponseResult> deleteMetal(String userName, String name) async {
    try {
      var rsp = await Request.post(
        'user/edit/remove-metal',
        data: {
          'goldFingerKey': key,
          'userName': userName,
          'name': name,
        },
      );

      return ResponseResult.from(rsp);
    } catch (e) {
      return Future.error(e);
    }
  }

  /// 通过用户ID删除勋章
  ///
  /// - `userId` 用户在摸鱼派的用户ID
  /// - `name` 勋章名称
  ///
  /// 返回执行结果
  Future<ResponseResult> deleteMetalByUserId(String userId, String name) async {
    try {
      var rsp = await Request.post(
        'user/edit/remove-metal-by-user-id',
        data: {
          'goldFingerKey': key,
          'userId': userId,
          'name': name,
        },
      );

      return ResponseResult.from(rsp);
    } catch (e) {
      return Future.error(e);
    }
  }

  /// 查询用户背包
  ///
  /// - `userName` 用户在摸鱼派的用户名
  ///
  /// 返回执行结果
  Future<UserBag> queryUserBag(String userName) async {
    try {
      var rsp = await Request.post(
        'user/query/items',
        data: {
          'goldFingerKey': key,
          'userName': userName,
        },
      );

      if (rsp['code'] != 0) return Future.error(rsp['msg']);

      return UserBag.from(rsp);
    } catch (e) {
      return Future.error(e);
    }
  }

  /// 调整用户背包
  ///
  /// - `userName` 用户在摸鱼派的用户名
  /// - `item` 物品名称
  /// - `sum` 物品数量
  ///
  /// 返回执行结果
  Future<ResponseResult> editUserBag(
      String userName, UserBagType item, int sum) async {
    try {
      var rsp = await Request.post(
        'user/edit/items',
        data: {
          'goldFingerKey': key,
          'userName': userName,
          'item': item.name,
          'sum': sum,
        },
      );

      return ResponseResult.from(rsp);
    } catch (e) {
      return Future.error(e);
    }
  }

  /// 调整用户积分
  ///
  /// - `userName` 用户在摸鱼派的用户名
  /// - `point` 积分数量
  /// - `memo` 备注
  ///
  /// 返回执行结果
  Future<ResponseResult> editUserPoints(
      String userName, int point, String memo) async {
    try {
      var rsp = await Request.post(
        'user/edit/points',
        data: {
          'goldFingerKey': key,
          'userName': userName,
          'point': point,
          'memo': memo,
        },
      );

      return ResponseResult.from(rsp);
    } catch (e) {
      return Future.error(e);
    }
  }

  /// 查询用户当前活跃度
  ///
  /// - `userName` 用户在摸鱼派的用户名
  ///
  /// 返回活跃度
  Future<double> getLiveness(String userName) async {
    try {
      var rsp = await Request.post(
        'user/liveness',
        data: {
          'goldFingerKey': key,
          'userName': userName,
        },
      );

      if (rsp.code != 0) throw Exception(rsp.msg);

      return rsp['liveness'];
    } catch (e) {
      return Future.error(e);
    }
  }

  /// 查询用户昨日活跃度奖励
  ///
  /// - `userName` 用户在摸鱼派的用户名
  ///
  /// 返回奖励数量
  Future<double> getYesterDayLivenessReward(String userName) async {
    try {
      var rsp = await Request.post(
        'activity/yesterday-liveness-reward-api',
        data: {
          'goldFingerKey': key,
          'userName': userName,
        },
      );

      if (rsp.code != 0) throw Exception(rsp.msg);

      return rsp['sum'];
    } catch (e) {
      return Future.error(e);
    }
  }
}
