import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

class PiImage extends StatelessWidget {
  final String imgUrl;
  final double width;
  final double height;
  final BoxFit fit;
  final Alignment alignment;

  const PiImage({
    required this.imgUrl,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imgUrl,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      placeholder: (_, e) => _buildLoadingImg(),
      errorWidget: (_, a, e) => _buildErrorImg(),
    );
  }

  Widget _buildLoadingImg() {
    return Container(
      alignment: Alignment.center,
      child: Lottie.asset(
        "assets/logo_lottie.json",
        width: 100.w,
        height: 100.w,
      ),
    );
  }

  Widget _buildErrorImg() {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      color: Colors.grey,
      child: const Icon(Icons.error_outline),
    );
  }
}
