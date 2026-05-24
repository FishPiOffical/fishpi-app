import 'dart:async';

import 'package:hive/hive.dart';

class UserRemark {
  static Box? _remarkBox;
  static final Map<String, RemarkUser> _remarks = {};
  static final StreamController<void> _changes =
      StreamController<void>.broadcast();

  static Stream<void> get changes => _changes.stream;

  static Future<void> init() async {
    final box = await _box();
    _reloadCache(box);
  }

  static String remarkOf(String? userName) {
    final key = _normalize(userName);
    if (key.isEmpty) return '';
    return _remarks[key]?.remark.trim() ?? '';
  }

  static String displayName(String? userName, {String? fallback}) {
    final remark = remarkOf(userName);
    if (remark.isNotEmpty) return remark;

    final fallbackText = fallback?.trim() ?? '';
    if (fallbackText.isNotEmpty) return fallbackText;
    return userName?.trim() ?? '';
  }

  static Future<RemarkUser?> getOneUser(String? userName) async {
    await init();
    return _remarks[_normalize(userName)];
  }

  static Future<List<RemarkUser>> getAllUser() async {
    await init();
    return _remarks.values.toList();
  }

  static Future<void> setRemark({
    String? oId,
    required String userName,
    required String remark,
    String? avatarURL,
  }) async {
    final key = _normalize(userName);
    if (key.isEmpty) return;

    final text = remark.trim();
    if (text.isEmpty) {
      await removeRemark(userName);
      return;
    }

    final user = RemarkUser(
      oId: oId,
      userName: userName.trim(),
      remark: text,
      avatarURL: avatarURL,
    );
    await (await _box()).put(key, user.toJson());
    _remarks[key] = user;
    _notifyChange();
  }

  static Future<void> removeRemark(String? userName) async {
    final key = _normalize(userName);
    if (key.isEmpty) return;
    await (await _box()).delete(key);
    _remarks.remove(key);
    _notifyChange();
  }

  static Future<void> clear() async {
    await (await _box()).clear();
    _remarks.clear();
    _notifyChange();
  }

  static Future<void> dispose() async {
    final box = _remarkBox;
    if (box != null && box.isOpen) {
      await box.close();
    }
    _remarkBox = null;
    _remarks.clear();
  }

  static Future<Box> _box() async {
    final box = _remarkBox;
    if (box != null && box.isOpen) return box;
    _remarkBox = await Hive.openBox('userRemark');
    return _remarkBox!;
  }

  static void _reloadCache(Box box) {
    _remarks
      ..clear()
      ..addEntries(
        box.values
            .whereType<Map>()
            .map((item) => RemarkUser.fromJson(Map<String, dynamic>.from(item)))
            .where((item) => item.userName.trim().isNotEmpty)
            .map((item) => MapEntry(_normalize(item.userName), item)),
      );
  }

  static String _normalize(String? value) => value?.trim() ?? '';

  static void _notifyChange() {
    if (!_changes.isClosed) {
      _changes.add(null);
    }
  }
}

class RemarkUser {
  String? oId;
  String userName;
  String remark;
  String? avatarURL;

  RemarkUser({
    this.oId,
    required this.userName,
    required this.remark,
    this.avatarURL,
  });

  factory RemarkUser.fromJson(Map<String, dynamic> json) {
    return RemarkUser(
      oId: json['oId']?.toString(),
      userName: json['userName']?.toString() ?? '',
      remark: json['remark']?.toString() ?? '',
      avatarURL: json['avatarURL']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'oId': oId,
      'userName': userName,
      'remark': remark,
      'avatarURL': avatarURL,
    };
  }
}
