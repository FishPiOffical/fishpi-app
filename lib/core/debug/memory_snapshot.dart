import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

class MemorySnapshot {
  final String source;
  final int imageCacheCount;
  final int imageCacheBytes;
  final int liveImageCount;
  final int chatMessages;
  final int articles;
  final int breezemoons;
  final int musicQueue;

  const MemorySnapshot({
    required this.source,
    required this.imageCacheCount,
    required this.imageCacheBytes,
    required this.liveImageCount,
    this.chatMessages = 0,
    this.articles = 0,
    this.breezemoons = 0,
    this.musicQueue = 0,
  });

  factory MemorySnapshot.capture({
    required String source,
    int chatMessages = 0,
    int articles = 0,
    int breezemoons = 0,
    int musicQueue = 0,
  }) {
    final imageCache = PaintingBinding.instance.imageCache;
    return MemorySnapshot(
      source: source,
      imageCacheCount: imageCache.currentSize,
      imageCacheBytes: imageCache.currentSizeBytes,
      liveImageCount: imageCache.liveImageCount,
      chatMessages: chatMessages,
      articles: articles,
      breezemoons: breezemoons,
      musicQueue: musicQueue,
    );
  }

  String get summary {
    final imageMB = (imageCacheBytes / 1024 / 1024).toStringAsFixed(2);
    return '内存快照[$source] 图片缓存: $imageCacheCount 张/${imageMB}MB, '
        '活跃图片: $liveImageCount, 聊天: $chatMessages, 帖子: $articles, '
        '清风明月: $breezemoons, 音乐队列: $musicQueue';
  }

  static void log({
    required String source,
    int chatMessages = 0,
    int articles = 0,
    int breezemoons = 0,
    int musicQueue = 0,
  }) {
    if (!kDebugMode && !kProfileMode) return;
    debugPrint(
      MemorySnapshot.capture(
        source: source,
        chatMessages: chatMessages,
        articles: articles,
        breezemoons: breezemoons,
        musicQueue: musicQueue,
      ).summary,
    );
  }
}
