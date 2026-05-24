import 'package:fishpi/fishpi.dart';
import 'package:fishpi/src/request.dart';

/// 评论接口
class Comment {
  String token = '';

  Comment([String? token]) {
    this.token = token ?? this.token;
  }

  /// 发布评论
  ///
  /// - `data` 评论信息
  ///
  /// 返回执行结果
  Future<ResponseResult> send(CommentPost data) async {
    try {
      var rsp = await Request.post(
        'comment',
        data: {
          ...data.toJson(),
          'apiKey': token,
        },
      );

      return ResponseResult.from(rsp);
    } catch (e) {
      return Future.error(e);
    }
  }

  /// 更新评论
  ///
  /// - `id` 评论 Id
  /// - `data` 评论信息
  ///
  /// 返回评论内容 HTML
  Future<String> update(String id, CommentPost data) async {
    try {
      var rsp = await Request.put(
        'comment/$id',
        data: {
          ...data.toJson(),
          'apiKey': token,
        },
      );

      if (rsp['code'] != 0) return Future.error(rsp['msg']);

      return rsp["commentContent"] ?? '';
    } catch (e) {
      return Future.error(e);
    }
  }

  /// 评论点赞
  ///
  /// - `id` 评论 Id
  /// - `type` 点赞类型
  ///
  /// 返回文章点赞状态，true 为点赞，false 为点踩
  Future<bool> vote(String id, [bool like = true]) async {
    try {
      var rsp = await Request.post(
        'vote/${like ? 'up' : 'down'}/comment',
        data: {
          'dataId': id,
          'apiKey': token,
        },
      );

      if (rsp['code'] != 0) return Future.error(rsp['msg']);

      return rsp['type'] == 0;
    } catch (e) {
      return Future.error(e);
    }
  }

  /// 评论感谢
  ///
  /// - `id` 评论 Id
  ///
  /// 返回执行结果
  Future<ResponseResult> thank(String id) async {
    try {
      var rsp = await Request.post(
        'comment/thank',
        data: {
          'apiKey': token,
          'commentId': id,
        },
      );

      return ResponseResult.from(rsp);
    } catch (e) {
      return Future.error(e);
    }
  }

  /// 删除评论
  ///
  /// - `id` 评论 Id
  ///
  /// 返回删除的评论 Id
  Future<String> remove(String id) async {
    try {
      var rsp = await Request.post(
        'comment/$id/remove',
        data: {
          'apiKey': token,
        },
      );

      if (rsp['code'] != 0) return Future.error(rsp['msg']);

      return rsp['commentId'].toString();
    } catch (e) {
      return Future.error(e);
    }
  }
}
