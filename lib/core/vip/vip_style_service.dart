import 'package:fishpi/fishpi.dart';
import 'package:flutter/material.dart';

typedef VipInfoLoader = Future<UserVipInfo> Function(String userId);
typedef VipUserLoader = Future<UserInfo> Function(String userName);

class VipNameStyle {
  final bool isActive;
  final Color? color;
  final bool bold;
  final bool underline;

  const VipNameStyle({
    required this.isActive,
    this.color,
    this.bold = false,
    this.underline = false,
  });

  factory VipNameStyle.fromVipInfo(
    UserVipInfo info, {
    DateTime? now,
  }) {
    final current = now ?? DateTime.now();
    final notExpired =
        info.expiresAt <= 0 || info.expiresAt > current.millisecondsSinceEpoch;
    final active = info.state && notExpired;
    if (!active) return const VipNameStyle(isActive: false);

    return VipNameStyle(
      isActive: true,
      color: parseColor(info.color),
      bold: info.bold,
      underline: info.underline,
    );
  }

  static Color? parseColor(String value) {
    var normalized = value.trim();
    if (normalized.isEmpty) return null;
    if (normalized.startsWith('#')) {
      normalized = normalized.substring(1);
    } else if (normalized.toLowerCase().startsWith('0x')) {
      normalized = normalized.substring(2);
    }

    if (normalized.length == 6) {
      normalized = 'FF$normalized';
    }
    if (normalized.length != 8) return null;

    final colorValue = int.tryParse(normalized, radix: 16);
    if (colorValue == null) return null;
    return Color(colorValue);
  }

  TextStyle mergeInto(TextStyle baseStyle) {
    if (!isActive) return baseStyle;

    final mergedColor = color ?? baseStyle.color;
    return baseStyle.copyWith(
      color: mergedColor,
      fontWeight: bold ? FontWeight.w800 : baseStyle.fontWeight,
      decoration: underline ? TextDecoration.underline : baseStyle.decoration,
      decorationColor: underline
          ? (mergedColor ?? baseStyle.decorationColor)
          : baseStyle.decorationColor,
    );
  }
}

class VipStyleService {
  final VipInfoLoader vipInfoLoader;
  final VipUserLoader? userLoader;
  final Duration successTtl;
  final Duration failureTtl;

  static Fishpi? _sharedFishpi;
  static VipStyleService? _shared;

  final Map<String, _VipCacheEntry> _userIdCache = {};
  final Map<String, _VipCacheEntry> _userNameCache = {};
  final Map<String, Future<VipNameStyle?>> _pendingByUserId = {};
  final Map<String, Future<VipNameStyle?>> _pendingByUserName = {};

  VipStyleService({
    required this.vipInfoLoader,
    this.userLoader,
    this.successTtl = const Duration(minutes: 20),
    this.failureTtl = const Duration(minutes: 2),
  });

  factory VipStyleService.forFishpi(Fishpi fishpi) {
    return VipStyleService(
      vipInfoLoader: fishpi.vipInfo,
      userLoader: fishpi.getUser,
    );
  }

  static VipStyleService shared(Fishpi fishpi) {
    if (_shared == null || !identical(_sharedFishpi, fishpi)) {
      _sharedFishpi = fishpi;
      _shared = VipStyleService.forFishpi(fishpi);
    }
    return _shared!;
  }

  static void clearSharedCache() {
    _shared?.clear();
  }

  Future<VipNameStyle?> load({
    String? userId,
    String? userName,
  }) {
    final normalizedUserId = _normalizeUserId(userId);
    if (normalizedUserId.isNotEmpty) {
      return _loadByUserId(normalizedUserId);
    }

    final normalizedUserName = _normalizeUserName(userName);
    if (normalizedUserName.isEmpty) return Future.value(null);
    return _loadByUserName(normalizedUserName);
  }

  void clear() {
    _userIdCache.clear();
    _userNameCache.clear();
    _pendingByUserId.clear();
    _pendingByUserName.clear();
  }

  Future<VipNameStyle?> _loadByUserId(String userId) {
    final cached = _readCache(_userIdCache, userId);
    if (cached != null || _userIdCache.containsKey(userId)) {
      return Future.value(cached);
    }

    final pending = _pendingByUserId[userId];
    if (pending != null) return pending;

    final request = _requestVipStyle(userId).whenComplete(() {
      _pendingByUserId.remove(userId);
    });
    _pendingByUserId[userId] = request;
    return request;
  }

  Future<VipNameStyle?> _loadByUserName(String userName) {
    final cached = _readCache(_userNameCache, userName);
    if (cached != null || _userNameCache.containsKey(userName)) {
      return Future.value(cached);
    }

    final pending = _pendingByUserName[userName];
    if (pending != null) return pending;

    final request = _requestVipStyleByUserName(userName).whenComplete(() {
      _pendingByUserName.remove(userName);
    });
    _pendingByUserName[userName] = request;
    return request;
  }

  Future<VipNameStyle?> _requestVipStyle(String userId) async {
    try {
      final info = await vipInfoLoader(userId);
      final style = VipNameStyle.fromVipInfo(info);
      final result = style.isActive ? style : null;
      _writeCache(_userIdCache, userId, result, successTtl);
      return result;
    } catch (_) {
      _writeCache(_userIdCache, userId, null, failureTtl);
      return null;
    }
  }

  Future<VipNameStyle?> _requestVipStyleByUserName(String userName) async {
    try {
      final loader = userLoader;
      if (loader == null) {
        _writeCache(_userNameCache, userName, null, failureTtl);
        return null;
      }

      final user = await loader(userName);
      final userId = _normalizeUserId(user.oId);
      if (userId.isEmpty) {
        _writeCache(_userNameCache, userName, null, failureTtl);
        return null;
      }

      final style = await _loadByUserId(userId);
      _writeCache(
        _userNameCache,
        userName,
        style,
        style == null ? failureTtl : successTtl,
      );
      return style;
    } catch (_) {
      _writeCache(_userNameCache, userName, null, failureTtl);
      return null;
    }
  }

  VipNameStyle? _readCache(
    Map<String, _VipCacheEntry> cache,
    String key,
  ) {
    final entry = cache[key];
    if (entry == null) return null;
    if (entry.expiresAt.isAfter(DateTime.now())) return entry.style;
    cache.remove(key);
    return null;
  }

  void _writeCache(
    Map<String, _VipCacheEntry> cache,
    String key,
    VipNameStyle? style,
    Duration ttl,
  ) {
    cache[key] = _VipCacheEntry(
      style: style,
      expiresAt: DateTime.now().add(ttl),
    );
  }

  String _normalizeUserId(String? value) {
    final normalized = value?.trim() ?? '';
    return normalized == '0' ? '' : normalized;
  }

  String _normalizeUserName(String? value) => value?.trim() ?? '';
}

class _VipCacheEntry {
  final VipNameStyle? style;
  final DateTime expiresAt;

  _VipCacheEntry({
    required this.style,
    required this.expiresAt,
  });
}
