import 'dart:async';

import 'package:fishpi/types/redpacket.dart';
import 'package:hive/hive.dart';

class ChatRoomAutoGrabSettings {
  static const int minDelaySeconds = 3;
  static const String _boxName = 'chatRoomAutoGrabSettings';
  static const String _configKey = 'config';
  static Box? _settingsBox;
  static final StreamController<void> _changes =
      StreamController<void>.broadcast();

  static Stream<void> get changes => _changes.stream;

  static Future<void> init() async {
    await _box();
  }

  static Future<ChatRoomAutoGrabConfig> getConfig() async {
    final value = await (await _box()).get(_configKey);
    if (value is! Map) return ChatRoomAutoGrabConfig.defaults();
    return ChatRoomAutoGrabConfig.fromJson(Map<String, dynamic>.from(value));
  }

  static Future<String?> saveConfig(ChatRoomAutoGrabConfig config) async {
    final error = validate(config);
    if (error != null) return error;

    final normalized = config.normalized();
    await (await _box()).put(_configKey, normalized.toJson());
    _notifyChange();
    return null;
  }

  static Future<void> recordSuccess(int point) async {
    final config = await getConfig();
    await (await _box()).put(
      _configKey,
      config
          .copyWith(
            totalPoint: config.totalPoint + point,
            successCount: config.successCount + 1,
          )
          .toJson(),
    );
    _notifyChange();
  }

  static Future<void> resetStats() async {
    final config = await getConfig();
    await (await _box()).put(
      _configKey,
      config.copyWith(totalPoint: 0, successCount: 0).toJson(),
    );
    _notifyChange();
  }

  static String? validate(ChatRoomAutoGrabConfig config) {
    if (!config.enabled) return null;
    if (config.delaySeconds < minDelaySeconds) {
      return '自动抢红包延迟不能少于 $minDelaySeconds 秒';
    }
    if (config.enabledTypes.isEmpty) {
      return '请至少选择一种红包类型';
    }
    if (config.enabledTypes.contains(RedPacketType.RockPaperScissors) &&
        config.gesture == null) {
      return '抢猜拳红包需要先选择出拳';
    }
    return null;
  }

  static Future<void> dispose() async {
    final box = _settingsBox;
    if (box != null && box.isOpen) {
      await box.close();
    }
    _settingsBox = null;
  }

  static Future<Box> _box() async {
    final box = _settingsBox;
    if (box != null && box.isOpen) return box;
    _settingsBox = await Hive.openBox(_boxName);
    return _settingsBox!;
  }

  static void _notifyChange() {
    if (!_changes.isClosed) {
      _changes.add(null);
    }
  }
}

class ChatRoomAutoGrabConfig {
  final bool enabled;
  final int delaySeconds;
  final List<String> enabledTypes;
  final GestureType? gesture;
  final int totalPoint;
  final int successCount;

  const ChatRoomAutoGrabConfig({
    required this.enabled,
    required this.delaySeconds,
    required this.enabledTypes,
    this.gesture,
    required this.totalPoint,
    required this.successCount,
  });

  factory ChatRoomAutoGrabConfig.defaults() {
    return const ChatRoomAutoGrabConfig(
      enabled: false,
      delaySeconds: ChatRoomAutoGrabSettings.minDelaySeconds,
      enabledTypes: [
        RedPacketType.Random,
        RedPacketType.Average,
        RedPacketType.Specify,
        RedPacketType.Heartbeat,
      ],
      gesture: GestureType.Rock,
      totalPoint: 0,
      successCount: 0,
    );
  }

  factory ChatRoomAutoGrabConfig.fromJson(Map<String, dynamic> json) {
    return ChatRoomAutoGrabConfig(
      enabled: json['enabled'] == true,
      delaySeconds: int.tryParse(json['delaySeconds']?.toString() ?? '') ??
          ChatRoomAutoGrabSettings.minDelaySeconds,
      enabledTypes: List.from(json['enabledTypes'] ?? [])
          .map((item) => item.toString())
          .where((item) => item.trim().isNotEmpty)
          .toList(),
      gesture: _gestureFrom(json['gesture']),
      totalPoint: int.tryParse(json['totalPoint']?.toString() ?? '') ?? 0,
      successCount: int.tryParse(json['successCount']?.toString() ?? '') ?? 0,
    );
  }

  bool canGrabType(String type) {
    return enabled && enabledTypes.contains(type);
  }

  ChatRoomAutoGrabConfig normalized() {
    return copyWith(
      delaySeconds: delaySeconds < ChatRoomAutoGrabSettings.minDelaySeconds
          ? ChatRoomAutoGrabSettings.minDelaySeconds
          : delaySeconds,
      enabledTypes: enabledTypes.toSet().toList(),
    );
  }

  ChatRoomAutoGrabConfig copyWith({
    bool? enabled,
    int? delaySeconds,
    List<String>? enabledTypes,
    GestureType? gesture,
    bool clearGesture = false,
    int? totalPoint,
    int? successCount,
  }) {
    return ChatRoomAutoGrabConfig(
      enabled: enabled ?? this.enabled,
      delaySeconds: delaySeconds ?? this.delaySeconds,
      enabledTypes: enabledTypes ?? List<String>.from(this.enabledTypes),
      gesture: clearGesture ? null : gesture ?? this.gesture,
      totalPoint: totalPoint ?? this.totalPoint,
      successCount: successCount ?? this.successCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'delaySeconds': delaySeconds,
      'enabledTypes': enabledTypes,
      'gesture': gesture?.index,
      'totalPoint': totalPoint,
      'successCount': successCount,
    };
  }

  static GestureType? _gestureFrom(dynamic value) {
    final index = int.tryParse(value?.toString() ?? '');
    if (index == null || index < 0 || index >= GestureType.values.length) {
      return null;
    }
    return GestureType.values[index];
  }
}
