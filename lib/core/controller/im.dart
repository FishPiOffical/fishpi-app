import 'dart:async';

import 'package:fishpi/fishpi.dart';
import 'package:get/get.dart';

import '../im_event.dart';

class IMController extends GetxController {
  Fishpi fishpi = Fishpi();
  final StreamController<ChatRoomData> _chatRoomEvents =
      StreamController<ChatRoomData>.broadcast();
  final StreamController<PrivateChatEvent> _privateChatEvents =
      StreamController<PrivateChatEvent>.broadcast();

  ChatroomListener? _chatRoomListener;
  ChatListener? _privateNoticeListener;
  final Map<String, ChatListener> _privateUserListeners = {};
  final Map<String, int> _privateUserRefs = {};

  Stream<ChatRoomData> get chatRoomStream => _chatRoomEvents.stream;

  Stream<PrivateChatEvent> get privateChatStream => _privateChatEvents.stream;

  Future<String> login(
    LoginData loginData, {
    String mfaCode = '',
    void Function()? mfaCb,
  }) {
    return fishpi.login(loginData).onError((e, stackTrace) {
      if (e.toString() == '两步验证失败，请填写正确的一次性密码' &&
          mfaCb != null &&
          mfaCode.isEmpty) {
        mfaCb();
        e = '请输入正确的二次验证码';
      }
      return Future.error(e!);
    });
  }

  Future<void> init(String token) async {
    fishpi = Fishpi(token);
    _chatRoomListener = null;
    _privateNoticeListener = null;
    _privateUserListeners.clear();
    _privateUserRefs.clear();
  }

  Future<List<ChatData>> getChatList() async {
    List<ChatData> list = await fishpi.chat.list();
    return list;
  }

  Future<void> chatInit() async {
    if (fishpi.token.isEmpty) return;
    await _ensureChatRoomListener();
    _ensurePrivateNoticeListener();
  }

  Stream<PrivateChatEvent> watchPrivateChat(String user) {
    _retainPrivateChat(user);
    return privateChatStream.where((event) => event.user == user);
  }

  void unwatchPrivateChat(String user) {
    if (user.isEmpty) return;
    final refs = _privateUserRefs[user] ?? 0;
    if (refs > 1) {
      _privateUserRefs[user] = refs - 1;
      return;
    }

    _privateUserRefs.remove(user);
    final listener = _privateUserListeners.remove(user);
    if (listener != null) {
      fishpi.chat.removeListener(user: user, wsCallback: listener);
    }
  }

  Future<void> _ensureChatRoomListener() async {
    if (_chatRoomListener != null) return;
    void listener(ChatRoomData data) {
      if (!_chatRoomEvents.isClosed) {
        _chatRoomEvents.add(data);
      }
    }

    _chatRoomListener = listener;
    try {
      await fishpi.chatroom.addListener(
        listener,
        error: (_) {},
      );
    } catch (_) {
      _chatRoomListener = null;
    }
  }

  void _ensurePrivateNoticeListener() {
    if (fishpi.token.isEmpty) return;
    if (_privateNoticeListener != null) return;
    void listener(
      ChatMsgType type, {
      ChatNotice? notice,
      ChatData? data,
      ChatRevoke? revoke,
    }) {
      _emitPrivateChat(
        user: '_user-channel_',
        type: type,
        notice: notice,
        data: data,
        revoke: revoke,
      );
    }

    _privateNoticeListener = listener;
    try {
      fishpi.chat.addListener(listener);
    } catch (_) {
      _privateNoticeListener = null;
    }
  }

  void _retainPrivateChat(String user) {
    if (user.isEmpty) return;
    _privateUserRefs[user] = (_privateUserRefs[user] ?? 0) + 1;
    if (_privateUserListeners.containsKey(user)) return;

    void listener(
      ChatMsgType type, {
      ChatNotice? notice,
      ChatData? data,
      ChatRevoke? revoke,
    }) {
      _emitPrivateChat(
        user: user,
        type: type,
        notice: notice,
        data: data,
        revoke: revoke,
      );
    }

    _privateUserListeners[user] = listener;
    try {
      fishpi.chat.addListener(listener, user: user);
    } catch (_) {
      _privateUserListeners.remove(user);
      _privateUserRefs.remove(user);
    }
  }

  void _emitPrivateChat({
    required String user,
    required ChatMsgType type,
    ChatNotice? notice,
    ChatData? data,
    ChatRevoke? revoke,
  }) {
    if (_privateChatEvents.isClosed) return;
    _privateChatEvents.add(
      PrivateChatEvent(
        user: user,
        type: type,
        notice: notice,
        data: data,
        revoke: revoke,
      ),
    );
  }

  @override
  void onClose() {
    if (_chatRoomListener != null) {
      fishpi.chatroom.removeListener(_chatRoomListener);
    }
    if (_privateNoticeListener != null) {
      fishpi.chat.removeListener(wsCallback: _privateNoticeListener);
    }
    for (final entry in _privateUserListeners.entries) {
      fishpi.chat.removeListener(user: entry.key, wsCallback: entry.value);
    }
    _chatRoomEvents.close();
    _privateChatEvents.close();
    super.onClose();
  }
}
