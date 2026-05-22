import 'dart:async';

import 'package:hive/hive.dart';

class BlackList {
  static Box? msgBox;
  static final StreamController<void> _changes =
      StreamController<void>.broadcast();

  static Stream<void> get changes => _changes.stream;

  static Future<void> init() async {
    await _box();
  }

  static get blackList => getAllUser();

  static Future<List<BlackUser>> getAllUser() async {
    List<BlackUser> list = [];
    var lists = (await _box()).values.toList();
    for (var item in lists) {
      list.add(BlackUser.fromJson(item));
    }
    return list;
  }

  static getOneUser(String oId) async {
    return await (await _box()).get(oId);
  }

  static addUser(BlackUser user) async {
    final result = await (await _box()).put(user.oId, user.toJson());
    _notifyChange();
    return result;
  }

  static removeUser(String oId) async {
    final result = await (await _box()).delete(oId);
    _notifyChange();
    return result;
  }

  static clear() async {
    final result = await (await _box()).clear();
    _notifyChange();
    return result;
  }

  static bool isBlockedUser(
    Iterable<BlackUser> blackUsers, {
    String? oId,
    String? userName,
  }) {
    final targetId = _normalize(oId);
    final targetName = _normalize(userName);
    if (targetId.isEmpty && targetName.isEmpty) return false;

    return blackUsers.any((user) {
      final blackId = _normalize(user.oId);
      final blackName = _normalize(user.userName);
      return (targetId.isNotEmpty && blackId == targetId) ||
          (targetName.isNotEmpty && blackName == targetName);
    });
  }

  static List<T> visibleItems<T>(
    Iterable<T> items,
    Iterable<BlackUser> blackUsers, {
    String? Function(T item)? oId,
    required String? Function(T item) userName,
  }) {
    return items
        .where(
          (item) => !isBlockedUser(
            blackUsers,
            oId: oId?.call(item),
            userName: userName(item),
          ),
        )
        .toList();
  }

  static Future<void> dispose() async {
    final box = msgBox;
    if (box != null && box.isOpen) {
      await box.close();
    }
    msgBox = null;
  }

  static Future<Box> _box() async {
    final box = msgBox;
    if (box != null && box.isOpen) return box;
    msgBox = await Hive.openBox('blackList');
    return msgBox!;
  }

  static String _normalize(String? value) => value?.trim() ?? '';

  static void _notifyChange() {
    if (!_changes.isClosed) {
      _changes.add(null);
    }
  }
}

class BlackUser {
  String? oId;
  String? userName;
  String? avatarURL;

  BlackUser({this.oId, this.userName, this.avatarURL});

  BlackUser.fromJson(Map<String, dynamic> json) {
    oId = json['oId'];
    userName = json['userName'];
    avatarURL = json['avatarURL'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['oId'] = oId;
    data['userName'] = userName;
    data['avatarURL'] = avatarURL;
    return data;
  }
}
