import 'package:cached_network_image/cached_network_image.dart';
import 'package:fishpi_app/widgets/pi_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PiHero extends StatefulWidget {
  final Map arguments;

  const PiHero({super.key, required this.arguments});

  @override
  State<PiHero> createState() => _HeroPageState();
}

class _HeroPageState extends State<PiHero> {
  @override
  void dispose() {
    final imageUrl = widget.arguments["imageUrl"]?.toString() ?? '';
    if (imageUrl.isNotEmpty) {
      // 大图预览可能解码出高分辨率图片，退出时只释放内存缓存，保留磁盘缓存便于下次查看。
      CachedNetworkImageProvider(imageUrl).evict();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Hero(
          tag: widget.arguments["oId"],
          child: Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: PiImage(
                width: 0.8.sw,
                height: 0.8.sw,
                fit: BoxFit.contain,
                imgUrl: widget.arguments["imageUrl"],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
