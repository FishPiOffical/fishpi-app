import 'package:flutter/widgets.dart';

import 'memory_limits.dart';

class ImageDecodeUtils {
  ImageDecodeUtils._();

  static int? resolveDecodeSize(
    BuildContext context,
    double logicalSize, {
    int? explicitSize,
  }) {
    if (explicitSize != null) return explicitSize;
    if (!logicalSize.isFinite || logicalSize <= 0) return null;

    final mediaQuery = MediaQuery.maybeOf(context);
    final view = View.maybeOf(context);
    final devicePixelRatio =
        mediaQuery?.devicePixelRatio ?? view?.devicePixelRatio ?? 1.0;
    final rawSize = (logicalSize * devicePixelRatio).ceil();
    return rawSize.clamp(1, MemoryLimits.imageDecodeMaxPixels).toInt();
  }
}
