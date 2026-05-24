import 'dart:async';

import 'package:fishpi/fishpi.dart';
import 'package:fishpi/src/request.dart';
import 'package:web_socket_channel/io.dart';

/// 私聊接口
class Chat {
  String token = '';

  final Map<String, WebsocketInfo> _wss = {};
  final Map<String, List<ChatListener>> _wsCallbacks = {};
  final Map<String, int> _retryTimes = {};

  Chat([String? token]) {
    this.token = token ?? this.token;
  }

  /// 获取有私聊用户列表第一条消息
  ///
  /// 返回 私聊消息列表
  Future<List<ChatData>> list() async {
    try {
      var rsp = await Request.get(
        'chat/get-list',
        params: {
          'apiKey': token,
        },
      );

      if (rsp['result'] != 0) return Future.error(rsp['msg']);

      return List.from(rsp['data'] ?? []).map((e) => ChatData.from(e)).toList();
    } catch (e) {
      return Future.error(e);
    }
  }

  /// 获取用户私聊历史消息
  ///
  /// - `param` 消息参数
  ///
  /// 返回 私聊消息列表
  Future<List<ChatData>> get({
    required String user,
    int page = 1,
    int size = 20,
    bool autoRead = true,
  }) async {
    try {
      var rsp = await Request.get(
        'chat/get-message',
        params: {
          'apiKey': token,
          'toUser': user,
          'page': page,
          'pageSize': size,
        },
      );

      if (rsp['result'] != 0) return Future.error(rsp['msg']);

      if (autoRead) markRead(user);

      return List.from(rsp['data'] ?? []).map((e) => ChatData.from(e)).toList();
    } catch (e) {
      return Future.error(e);
    }
  }

  /// 标记用户消息已读
  ///
  /// - `user` 用户名
  ///
  /// 返回 执行结果
  Future<ResponseResult> markRead(String user) async {
    try {
      var rsp = await Request.get(
        'chat/mark-as-read',
        params: {
          'apiKey': token,
          'fromUser': user,
        },
      );

      return ResponseResult.from(rsp);
    } catch (e) {
      return Future.error(e);
    }
  }

  /// 获取未读消息
  ///
  /// 返回 未读消息列表
  Future<ChatData> unread() async {
    try {
      var rsp = await Request.get(
        'chat/has-unread',
        params: {
          'apiKey': token,
        },
      );

      if (rsp['result'] != 0) return Future.error(rsp['msg']);

      return ChatData.from(rsp['data'] ?? {});
    } catch (e) {
      return Future.error(e);
    }
  }

  /// 撤回私聊消息
  ///
  /// - `msgId` 消息 ID
  ///
  /// 返回 执行结果
  Future<bool> revoke(String msgId) async {
    try {
      var rsp = await Request.get(
        'chat/revoke',
        params: {
          'apiKey': token,
          'oId': msgId,
        },
      );

      return rsp['result'] == 0;
    } catch (e) {
      return Future.error(e);
    }
  }

  /// 连接私聊频道
  ///
  /// - `user` 指定用户消息监听函数，空为新信息监听
  /// - `timeout` 连接超时时间
  /// - `error` 连接错误回调
  /// - `close` 连接关闭回调
  ///
  /// 返回 WebSocket 连接
  Future connect(
      {String user = '_user-channel_',
      int timeout = 10,
      Function(dynamic)? error,
      Function? close}) async {
    if (_wss[user] != null) {
      _wss[user]?.steam.cancel();
      _wss[user]?.ws.sink.close();
    }

    var channel = user != '_user-channel_' ? 'chat-channel' : 'user-channel';
    _wss[user] = Request.connect(
      channel,
      params: {'apiKey': token, 'toUser': user},
      onMessage: (msg) {
        for (ChatListener call in _wsCallbacks[user] ?? []) {
          var type = ChatMsgType.data;
          if (['chatUnreadCountRefresh', 'newIdleChatMessage']
              .contains(msg['command'] ?? '')) {
            type = ChatMsgType.notice;
          }
          if (msg['type'] == 'revoke') type = ChatMsgType.revoke;
          if (type != ChatMsgType.notice && msg['command'] != null) return;
          switch (type) {
            case ChatMsgType.data:
              call(type, data: ChatData.from(msg));
              break;
            case ChatMsgType.notice:
              call(type, notice: ChatNotice.from(msg));
              break;
            case ChatMsgType.revoke:
              call(type, revoke: msg['data']);
              break;
          }
        }
      },
      onClose: (IOWebSocketChannel ws) => {
        Timer(Duration(milliseconds: timeout), () {
          ws.sink.close();
          _wss[user]?.steam.cancel();
          _wss.remove(user);
          if (close != null) close();
          if (_retryTimes[user]! >= 10) return;
          connect(user: user, timeout: timeout, error: error, close: close)
              .catchError((err) {
            if (error != null) error(err);
          });
          _retryTimes[user] = (_retryTimes[user] ?? 0) + 1;
        }),
        Timer(Duration(milliseconds: timeout * 100), () {
          _retryTimes[user] = 0;
        })
      },
      onError: (err, ws) {
        if (error != null) {
          error(err);
        }
      },
    );
  }

  /// 添加消息监听函数
  ///
  /// - `wsCallback` 消息监听函数
  /// - `user` 指定为用户消息监听函数，空为新信息监听
  void addListener(ChatListener wsCallback, {String user = '_user-channel_'}) {
    if (_wss[user] != null) {
      if (!_wsCallbacks[user]!.contains(wsCallback)) {
        _wsCallbacks[user]!.add(wsCallback);
      }
      return;
    }

    _wsCallbacks[user] = _wsCallbacks[user] ?? [];
    _wsCallbacks[user]!.add(wsCallback);
    connect(user: user);
  }

  /// 移除消息监听函数
  ///
  /// - `user` 指定用户消息监听函数，空为新信息监听
  /// - `wsCallback` 要移除的函数，若为空，则清空消息监听
  void removeListener({
    String user = '_user-channel_',
    ChatListener? wsCallback,
  }) {
    if (wsCallback == null) {
      _wsCallbacks.remove(user);
      return;
    }

    if (!_wsCallbacks.containsKey(user) ||
        !_wsCallbacks[user]!.contains(wsCallback)) {
      return;
    }

    _wsCallbacks[user]!.remove(wsCallback);
  }

  /// 是否已连接
  ///
  /// - `user` 查看的用户
  bool isConnected({String user = '_user-channel_'}) {
    return _wss[user] != null;
  }

  Future<WebsocketInfo> send(String user, String content) async {
    if (_wss[user] == null || _wss[user]!.ws.closeCode != null) {
      await connect(user: user);
    }
    _wss[user]!.ws.sink.add(content);
    return _wss[user]!;
  }
}
