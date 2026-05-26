import 'dart:async';

import 'package:fishpi/types/chatroom.dart';
import 'package:hive/hive.dart';

class ChatRoomBlockList {
  static Box? _blockBox;
  static final StreamController<void> _changes =
      StreamController<void>.broadcast();

  static Stream<void> get changes => _changes.stream;

  static Future<void> init() async {
    await _box();
  }

  static Future<List<ChatRoomBlockedUser>> getAllUser() async {
    final values = (await _box()).values.toList();
    return values
        .whereType<Map>()
        .map((item) => ChatRoomBlockedUser.fromJson(
              Map<String, dynamic>.from(item),
            ))
        .where((item) => item.matchKey.isNotEmpty)
        .toList();
  }

  static Future<ChatRoomBlockedUser?> getOneUser({
    String? oId,
    String? userName,
  }) async {
    final key = _storageKey(oId: oId, userName: userName);
    if (key.isEmpty) return null;
    final value = await (await _box()).get(key);
    if (value is! Map) return null;
    return ChatRoomBlockedUser.fromJson(Map<String, dynamic>.from(value));
  }

  static Future<void> addUser(ChatRoomBlockedUser user) async {
    final key = user.matchKey;
    if (key.isEmpty) return;
    await (await _box()).put(key, user.toJson());
    _notifyChange();
  }

  static Future<void> removeUser(ChatRoomBlockedUser user) async {
    final key = user.matchKey;
    if (key.isEmpty) return;
    await (await _box()).delete(key);
    _notifyChange();
  }

  static Future<void> removeUserByInfo({
    String? oId,
    String? userName,
  }) async {
    final key = _storageKey(oId: oId, userName: userName);
    if (key.isEmpty) return;
    await (await _box()).delete(key);
    _notifyChange();
  }

  static Future<void> clear() async {
    await (await _box()).clear();
    _notifyChange();
  }

  static bool isBlockedUser(
    Iterable<ChatRoomBlockedUser> blockedUsers, {
    String? oId,
    String? userName,
  }) {
    final targetId = _normalize(oId);
    final targetName = _normalize(userName);
    if (targetId.isEmpty && targetName.isEmpty) return false;

    return blockedUsers.any((user) {
      final blockedId = _normalize(user.oId);
      final blockedName = _normalize(user.userName);
      return (targetId.isNotEmpty && blockedId == targetId) ||
          (targetName.isNotEmpty && blockedName == targetName);
    });
  }

  static List<T> visibleItems<T>(
    Iterable<T> items,
    Iterable<ChatRoomBlockedUser> blockedUsers, {
    String? Function(T item)? oId,
    required String? Function(T item) userName,
  }) {
    return items
        .where(
          (item) => !isBlockedUser(
            blockedUsers,
            oId: oId?.call(item),
            userName: userName(item),
          ),
        )
        .toList();
  }

  static Future<void> dispose() async {
    final box = _blockBox;
    if (box != null && box.isOpen) {
      await box.close();
    }
    _blockBox = null;
  }

  static Future<Box> _box() async {
    final box = _blockBox;
    if (box != null && box.isOpen) return box;
    _blockBox = await Hive.openBox('chatRoomBlockList');
    return _blockBox!;
  }

  static String _storageKey({String? oId, String? userName}) {
    final id = _normalize(oId);
    if (id.isNotEmpty) return 'id:$id';

    final name = _normalize(userName);
    if (name.isNotEmpty) return 'name:$name';
    return '';
  }

  static String _normalize(String? value) => value?.trim() ?? '';

  static void _notifyChange() {
    if (!_changes.isClosed) {
      _changes.add(null);
    }
  }
}

class ChatRoomBlockedUser {
  String? oId;
  String? userName;
  String? avatarURL;

  ChatRoomBlockedUser({
    this.oId,
    this.userName,
    this.avatarURL,
  });

  factory ChatRoomBlockedUser.fromChatRoomMessage(ChatRoomMessage message) {
    final id = message.userOId > 0 ? message.userOId.toString() : null;
    return ChatRoomBlockedUser(
      oId: id,
      userName: message.userName,
      avatarURL: message.avatarURL,
    );
  }

  factory ChatRoomBlockedUser.fromJson(Map<String, dynamic> json) {
    return ChatRoomBlockedUser(
      oId: json['oId']?.toString(),
      userName: json['userName']?.toString(),
      avatarURL: json['avatarURL']?.toString(),
    );
  }

  String get matchKey {
    final id = oId?.trim() ?? '';
    if (id.isNotEmpty) return 'id:$id';

    final name = userName?.trim() ?? '';
    if (name.isNotEmpty) return 'name:$name';
    return '';
  }

  Map<String, dynamic> toJson() {
    return {
      'oId': oId,
      'userName': userName,
      'avatarURL': avatarURL,
    };
  }
}
