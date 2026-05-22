//显示一个浮动图标
import 'package:flutter/material.dart';

class FloatingIcon {
  static OverlayEntry? entry;
  static Offset offset = Offset.zero;

  static show(
    BuildContext context, {
    bool autoDismiss = false,
    String key = "entry",
    Duration duration = const Duration(seconds: 3),
    double? x,
    double? y,
    bool cantTap = false,
    Function? onTap,
    double? height,
    double? width,
    Widget? child,
  }) {
    FloatingIcon.entry = OverlayEntry(
      builder: (context) {
        return cantTap
            ? IgnorePointer(
                child: Stack(
                  children: [
                    Positioned(
                      left: x,
                      top: y,
                      width: width,
                      height: height,
                      child: Material(
                        color: Colors.transparent,
                        child: GestureDetector(
                          onTap: () {
                            if (onTap != null) {
                              onTap();
                            }
                          },
                          child: child,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Positioned(
                left: x,
                top: y,
                width: width,
                height: height,
                child: Material(
                  color: Colors.transparent,
                  child: GestureDetector(
                    onTap: () {
                      if (onTap != null) {
                        onTap();
                      }
                    },
                    child: child,
                  ),
                ),
              );
      },
    );
    Overlay.of(context).insert(FloatingIcon.entry!);
    if (autoDismiss) {
      Future.delayed(duration, () {
        FloatingIcon.entry?.remove();
      });
    }
  }

  static hide() {
    FloatingIcon.entry?.remove();
    FloatingIcon.entry = null;
  }

  static update() {
    final overlayEntry = FloatingIcon.entry;
    if (overlayEntry != null) {
      overlayEntry.markNeedsBuild();
    }
  }
}
