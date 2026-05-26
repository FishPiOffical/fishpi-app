import 'dart:io';

import 'package:fishpi_app/core/sql/chat_emoji_cache.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('chat_emoji_cache_test_');
    Hive.init(tempDir.path);
    await ChatEmojiCache.init();
  });

  tearDown(() async {
    await ChatEmojiCache.dispose();
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('DIY 表情列表会去空、去重并持久化', () async {
    await ChatEmojiCache.saveDiyEmojis([
      'https://example.com/a.png',
      ' ',
      'https://example.com/a.png',
      'https://example.com/b.png',
    ]);

    expect(
      await ChatEmojiCache.getDiyEmojis(),
      ['https://example.com/a.png', 'https://example.com/b.png'],
    );
    expect(await ChatEmojiCache.getUpdatedAt(), isNotNull);
  });

  test('空缓存返回空列表', () async {
    await ChatEmojiCache.clear();
    expect(await ChatEmojiCache.getDiyEmojis(), isEmpty);
  });
}
