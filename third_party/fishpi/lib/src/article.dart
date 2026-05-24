import 'dart:convert';

import 'package:fishpi/fishpi.dart';
import 'package:fishpi/src/request.dart';
import 'package:web_socket_channel/io.dart';

/// 文章接口
class Article {
  String token = '';

  Article([String? token]) {
    this.token = token ?? this.token;
  }

  /// 发布文章
  ///
  /// - `data` 文章信息
  ///
  /// 返回文章 Id
  Future<String> post(ArticlePost data) async {
    try {
      var rsp = await Request.post(
        'article',
        data: {
          ...data.toJson(),
          'apiKey': token,
        },
      );

      if (rsp['code'] != 0) return Future.error(rsp['msg']);

      return rsp['articleId'];
    } catch (e) {
      return Future.error(e);
    }
  }

  /// 更新文章
  ///
  /// - `id` 文章 Id
  /// - `data` 文章信息
  ///
  /// 返回文章 Id
  Future<String> update(String id, ArticlePost data) async {
    try {
      var rsp = await Request.put(
        'article/$id',
        data: {
          ...data.toJson(),
          'apiKey': token,
        },
      );

      if (rsp['code'] != 0) return Future.error(rsp['msg']);

      return rsp['articleId'];
    } catch (e) {
      return Future.error(e);
    }
  }

  /// 查询文章列表
  ///
  /// - `type` 查询类型，来自 ArticleListType
  /// - `tag` 指定查询标签，可选
  /// - `page` 页码
  /// - `size` 每页数量
  ///
  /// 返回文章列表
  Future<ArticleList> list({
    required String type,
    int page = 1,
    int size = 20,
    String? tag,
  }) async {
    try {
      var rsp = await Request.get(
        'api/articles/${tag != null && tag.isNotEmpty ? "tag/$tag" : "recent"}${ArticleListType.toCode(type)}',
        params: {"p": page, "size": size, "apiKey": token},
      );

      if (rsp['code'] != 0) return Future.error(rsp['msg']);

      return ArticleList.from(rsp['data']);
    } catch (e) {
      return Future.error(e);
    }
  }

  /// 查询文章列表
  ///
  /// - `user` 指定用户
  /// - `page` 页码
  /// - `size` 每页数量
  ///
  /// 返回文章列表
  Future<ArticleList> listByUser({required String user, int page = 1, int size = 20}) async {
    try {
      var rsp = await Request.get(
        'api/user/$user/articles/',
        params: {"p": page, "size": size, "apiKey": token},
      );

      if (rsp['code'] != 0) return Future.error(rsp['msg']);

      return ArticleList.from(rsp['data']);
    } catch (e) {
      return Future.error(e);
    }
  }

  /// 获取文章详情
  ///
  /// - `id` 文章id
  /// - `p` 评论页码
  ///
  /// 返回文章详情
  Future<ArticleDetail> detail(String id, {int p = 1}) async {
    try {
      var rsp = await Request.get(
        'api/article/$id',
        params: {"apiKey": token, "p": p},
      );

      if (rsp['code'] != 0) return Future.error(rsp['msg']);

      return ArticleDetail.from(rsp['data']?['article'] ?? {})
        ..pagination = Pagination.from(rsp['data']?['pagination'] ?? {});
    } catch (e) {
      return Future.error(e);
    }
  }

  /// 点赞/取消点赞文章
  ///
  /// - `id` 文章id
  /// - `type` 点赞类型
  ///
  /// 返回文章点赞状态，true 为点赞，false 为点踩
  Future<bool> vote(String id, [bool like = true]) async {
    try {
      var rsp = await Request.post(
        'vote/${like ? 'up' : 'down'}/article',
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

  /// 感谢文章
  ///
  /// - `id` 文章id
  ///
  /// 返回执行结果
  Future<ResponseResult> thank(String id) async {
    try {
      var rsp = await Request.post(
        'article/thank',
        params: {"articleId": id},
        data: {
          'apiKey': token,
        },
      );

      return ResponseResult.from(rsp);
    } catch (e) {
      return Future.error(e);
    }
  }

  /// 收藏/取消收藏文章
  ///
  /// - `id` 文章id
  ///
  /// 返回执行结果
  Future<ResponseResult> follow(String followingId) async {
    try {
      var rsp = await Request.post(
        'follow/article',
        data: {
          'apiKey': token,
          'followingId': followingId,
        },
      );

      return ResponseResult.from(rsp);
    } catch (e) {
      return Future.error(e);
    }
  }

  /// 关注/取消关注文章
  ///
  /// - `followingId` 文章id
  ///
  /// 返回执行结果
  Future<ResponseResult> watch(String followingId) async {
    try {
      var rsp = await Request.post(
        'follow/article-watch',
        data: {
          'apiKey': token,
          'followingId': followingId,
        },
      );

      return ResponseResult.from(rsp);
    } catch (e) {
      return Future.error(e);
    }
  }

  /// 打赏文章
  ///
  /// - `id` 文章id
  ///
  /// 返回执行结果
  Future<ResponseResult> reward(String id) async {
    try {
      var rsp = await Request.post(
        'article/reward?articleId=$id',
        data: {
          'apiKey': token,
        },
      );

      return ResponseResult.from(rsp);
    } catch (e) {
      return Future.error(e);
    }
  }

  /// 获取文章在线人数
  ///
  /// - `id` 文章id
  ///
  /// 返回在线人数
  Future<int> heat(String id) async {
    try {
      var rsp = await Request.get('api/article/heat/$id', params: {"apiKey": token});

      if (rsp['code'] != 0) return Future.error(rsp['msg']);

      return rsp["articleHeat"] ?? 0;
    } catch (e) {
      return Future.error(e);
    }
  }

  /// 添加文章监听器
  ///
  /// - `id` 文章id
  /// - `type` 文章类型
  /// - `callback` 监听回调
  ///
  /// 返回 WebSocketChannel
  Future<WebsocketInfo> addListener({required String id, int type = 0, required Function cb}) async {
    return Request.connect(
      '/article-channel',
      params: {'apiKey': token, 'articleId': id, 'articleType': type},
      onMessage: (msg) {
        try {
          msg = json.decode(msg);
          // ignore: empty_catches
        } catch (e) {}
        cb(msg);
      },
      onClose: (IOWebSocketChannel ws) => print('WebSocket is closed'),
      onError: (error, ws) => print(error),
    );
  }
}
