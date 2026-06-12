import 'package:flutter/foundation.dart';

/// 统一的轻量日志出口，主要用于给“静默 catch”补一个可观测性通道。
///
/// release 构建保持完全静默，不影响用户也不暴露内部细节；debug/profile
/// 构建下打印异常来源和类型，方便定位被吞掉的失败。
class AppLogger {
  AppLogger._();

  /// 记录一个被有意吞掉、不向用户抛出的异常。
  ///
  /// [tag] 标识发生位置（如 `pi_utils.saveToken`），[error] 为捕获到的异常。
  static void swallow(String tag, Object? error, [StackTrace? stack]) {
    if (!kDebugMode && !kProfileMode) return;
    if (error == null) {
      debugPrint('[swallow] $tag');
      return;
    }
    debugPrint('[swallow] $tag -> ${error.runtimeType}: $error');
  }

  /// 记录一条普通调试信息，release 下静默。
  static void debug(String message) {
    if (!kDebugMode && !kProfileMode) return;
    debugPrint(message);
  }
}
