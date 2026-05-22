import 'package:flutter/material.dart';

// 斑马纹具体实现类
class PiZebraStripesBack extends StatefulWidget {
  const PiZebraStripesBack({
    this.width,
    this.height,
    this.borderRaduis,
    this.child,
    super.key,
  });

  final double? width; // 容器宽度
  final double? height; // 容器高度
  final double? borderRaduis; // 容器圆角
  final Widget? child;

  @override
  State<StatefulWidget> createState() => _ZebraStripesBackState();
}

class _ZebraStripesBackState extends State<PiZebraStripesBack> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/images/zebra.png'),
          repeat: ImageRepeat.repeat,
        ),
        borderRadius: widget.borderRaduis != null
            ? BorderRadius.circular(widget.borderRaduis!)
            : null,
      ),
      height: widget.height,
      width: widget.width,
      child: widget.child,
    );
  }
}
