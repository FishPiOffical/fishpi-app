import 'dart:async';
import 'dart:convert';

import 'package:fishpi/fishpi.dart';
import 'package:fishpi/src/request.dart';
import 'package:web_socket_channel/io.dart';

/// 通知消息接口
class Notice {
  String token = '';
  WebsocketInfo? _wss;
  final List<NoticeListener> _wsCallbacks = [];

  Notice([String? token]) {
    this.token = token ?? this.token;
  }

  /// 获取未读消息数
  ///
  /// 返回 `NoticeCount`
  Future<NoticeCount> count() async {
    try {
      var rsp = await Request.get('notifications/unread/count',
          params: {'apiKey': token});

      return NoticeCount.from(rsp);
    } catch (e) {
      return Future.error(e);
    }
  }

  /// 获取消息列表
  ///
  /// - `type` 消息类型
  ///
  /// 返回消息列表
  Future<NoticeList> list(String type) async {
    try {
      var rsp = await Request.get('api/getNotifications', params: {
        'apiKey': token,
        'type': type,
      });

      if (rsp['code'] != 0) return Future.error(rsp['msg']);

      return List.from(rsp).map((e) {
        switch (type) {
          case NoticeType.point:
            return NoticePoint.from(e);
          case NoticeType.commented:
            return NoticeComment.from(e);
          case NoticeType.at:
            return NoticeAt.from(e);
          case NoticeType.following:
            return NoticeFollow.from(e);
          case NoticeType.system:
            return NoticeSystem.from(e);
        }
      }).toList();
    } catch (e) {
      return Future.error(e);
    }
  }

  /// 已读指定类型消息
  ///
  /// - `type` 消息类型
  ///
  /// 返回执行结果
  Future<ResponseResult> makeRead(String type) async {
    try {
      var rsp = await Request.get('notifications/make-read/$type', params: {
        'apiKey': token,
      });

      return ResponseResult.from(rsp);
    } catch (e) {
      return Future.error(e);
    }
  }

  /// 已读所有消息
  Future<void> readAll() async {
    try {
      await Request.get('notifications/all-read', params: {
        'apiKey': token,
      });
    } catch (e) {
      return Future.error(e);
    }
  }

  /// 连接实时用户通知
  ///
  /// - `timeout` 连接超时时间
  /// - `error` 连接错误回调
  /// - `close` 连接关闭回调
  ///
  /// 返回 WebSocket 连接
  Future connect(
      {int timeout = 10, Function(dynamic)? error, Function? close}) async {
    if (_wss != null) {
      _wss?.steam.cancel();
      _wss?.ws.sink.close();
    }

    _wss = Request.connect(
      'user-channel',
      params: {'apiKey': token},
      onMessage: (msg) {
        try {
          msg = json.decode(msg);
        } catch (e) {
          return;
        }
        for (NoticeListener call in _wsCallbacks) {
          if (NoticeMsgType.values.contains(msg['command'])) {
            call(NoticeMsg.from(msg));
          }
        }
      },
      onClose: (IOWebSocketChannel ws) => {
        Timer(Duration(milliseconds: timeout), () {
          ws.sink.close();
          _wss?.steam.cancel();
          _wss = null;
          connect(
            timeout: timeout,
            error: error,
            close: close,
          );
        }),
      },
      onError: (error, ws) => {if (error != null) error(error)},
    );
  }

  /// 添加通知监听函数
  ///
  /// - `wsCallback` 通知监听函数
  void addListener(NoticeListener wsCallback) {
    if (_wss != null) {
      if (!_wsCallbacks.contains(wsCallback)) {
        _wsCallbacks.add(wsCallback);
      }
      return;
    }

    _wsCallbacks.add(wsCallback);
    connect();
  }

  /// 移除通知监听函数
  ///
  /// - `wsCallback` 要移除的函数，若为空，则清空消息监听
  void removeListener(NoticeListener? wsCallback) {
    if (wsCallback == null) {
      _wsCallbacks.clear();
      return;
    }
    if (_wsCallbacks.contains(wsCallback)) _wsCallbacks.remove(wsCallback);
  }
}
