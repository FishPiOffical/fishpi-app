import 'dart:async';

import 'package:hive/hive.dart';

class ChatEmojiCache {
  static const String _boxName = 'chatEmojiCache';
  static const String _diyEmojiListKey = 'diyEmojiList';
  static const String _updatedAtKey = 'updatedAt';
  static Box? _emojiBox;
  static final StreamController<void> _changes =
      StreamController<void>.broadcast();

  static Stream<void> get changes => _changes.stream;

  static Future<void> init() async {
    await _box();
  }

  static Future<List<String>> getDiyEmojis() async {
    final value = await (await _box()).get(_diyEmojiListKey);
    if (value is! List) return const [];
    return value
        .map((item) => item?.toString() ?? '')
        .where((item) => item.trim().isNotEmpty)
        .toList();
  }

  static Future<DateTime?> getUpdatedAt() async {
    final value = await (await _box()).get(_updatedAtKey);
    final milliseconds = int.tryParse(value?.toString() ?? '');
    if (milliseconds == null || milliseconds <= 0) return null;
    return DateTime.fromMillisecondsSinceEpoch(milliseconds);
  }

  static Future<void> saveDiyEmojis(Iterable<String> urls) async {
    final normalized = urls
        .map((url) => url.trim())
        .where((url) => url.isNotEmpty)
        .toSet()
        .toList();
    final box = await _box();
    await box.put(_diyEmojiListKey, normalized);
    await box.put(_updatedAtKey, DateTime.now().millisecondsSinceEpoch);
    _notifyChange();
  }

  static Future<void> clear() async {
    await (await _box()).clear();
    _notifyChange();
  }

  static Future<void> dispose() async {
    final box = _emojiBox;
    if (box != null && box.isOpen) {
      await box.close();
    }
    _emojiBox = null;
  }

  static Future<Box> _box() async {
    final box = _emojiBox;
    if (box != null && box.isOpen) return box;
    _emojiBox = await Hive.openBox(_boxName);
    return _emojiBox!;
  }

  static void _notifyChange() {
    if (!_changes.isClosed) {
      _changes.add(null);
    }
  }
}
