import 'package:flutter/foundation.dart';

class PerformanceTrace {
  PerformanceTrace._();

  static final Stopwatch _stopwatch = Stopwatch();
  static final Map<String, Duration> _marks = {};

  static void startApp() {
    if (_stopwatch.isRunning) return;
    _marks.clear();
    _stopwatch
      ..reset()
      ..start();
    _marks['app_start'] = Duration.zero;
  }

  static void mark(String name) {
    if (name.trim().isEmpty) return;
    if (!_stopwatch.isRunning) {
      startApp();
    }
    final elapsed = _stopwatch.elapsed;
    _marks[name.trim()] = elapsed;
    _log('性能标记[$name] ${elapsed.inMilliseconds}ms');
  }

  static void markSplashVisible() {
    mark('splash_visible');
  }

  static void markHomeInteractive() {
    mark('home_interactive');
    logStartupSummary();
  }

  static Duration? markElapsed(String name) {
    return _marks[name];
  }

  static Map<String, Duration> snapshot() {
    return Map.unmodifiable(_marks);
  }

  static String startupSummary() {
    final splash = _formatDuration(_marks['splash_visible']);
    final home = _formatDuration(_marks['home_interactive']);
    return '性能验收[启动] 冷启动到闪屏: $splash, 首页可交互: $home';
  }

  static void logStartupSummary() {
    _log(startupSummary());
  }

  static String _formatDuration(Duration? duration) {
    if (duration == null) return '未记录';
    return '${duration.inMilliseconds}ms';
  }

  static void _log(String message) {
    if (!kDebugMode && !kProfileMode) return;
    debugPrint(message);
  }

  @visibleForTesting
  static void resetForTest() {
    _stopwatch.stop();
    _stopwatch.reset();
    _marks.clear();
  }

  @visibleForTesting
  static void setMarkForTest(String name, Duration elapsed) {
    _marks[name] = elapsed;
  }
}
