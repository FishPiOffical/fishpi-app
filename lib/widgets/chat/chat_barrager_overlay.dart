import 'package:fishpi_app/core/chat/chat_barrager_utils.dart';
import 'package:fishpi_app/res/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatBarragerOverlay extends StatelessWidget {
  final List<ChatBarragerItem> barragers;
  final ValueChanged<String> onFinished;

  const ChatBarragerOverlay({
    super.key,
    required this.barragers,
    required this.onFinished,
  });

  @override
  Widget build(BuildContext context) {
    if (barragers.isEmpty) return const SizedBox.shrink();

    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              for (final item in barragers)
                Positioned(
                  top: 12.h + item.track * 38.h,
                  left: 0,
                  right: 0,
                  child: _ChatBarragerLane(
                    key: ValueKey('chat_barrager_${item.id}'),
                    item: item,
                    width: constraints.maxWidth,
                    onFinished: onFinished,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ChatBarragerLane extends StatefulWidget {
  final ChatBarragerItem item;
  final double width;
  final ValueChanged<String> onFinished;

  const _ChatBarragerLane({
    super.key,
    required this.item,
    required this.width,
    required this.onFinished,
  });

  @override
  State<_ChatBarragerLane> createState() => _ChatBarragerLaneState();
}

class _ChatBarragerLaneState extends State<_ChatBarragerLane>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6800),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onFinished(widget.item.id);
        }
      });
    _offset = CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ).drive(Tween<double>(begin: 1, end: -1));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final msg = widget.item.message;
    final content = ChatBarragerUtils.normalizeContent(msg.barragerContent);
    final name = ChatBarragerUtils.displayName(msg);
    final textColor = _parseColor(msg.barragerColor);

    return AnimatedBuilder(
      animation: _offset,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(widget.width * _offset.value, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: child,
          ),
        );
      },
      child: Container(
        constraints: BoxConstraints(maxWidth: 0.88.sw),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Styles.primaryTextColor.withValues(alpha: .82),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: textColor.withValues(alpha: .55),
            width: 1.w,
          ),
        ),
        child: Text(
          name.isEmpty ? content : '$name：$content',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: textColor,
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Color _parseColor(String color) {
    final normalized = ChatBarragerUtils.normalizeColor(color);
    final hex = normalized.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}
