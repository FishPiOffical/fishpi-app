import 'package:cached_network_image/cached_network_image.dart';
import 'package:fishpi_app/core/memory/image_decode_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PiImage extends StatelessWidget {
  final String imgUrl;
  final double width;
  final double height;
  final BoxFit fit;
  final Alignment alignment;
  final int? memCacheWidth;
  final int? memCacheHeight;

  const PiImage({
    required this.imgUrl,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.memCacheWidth,
    this.memCacheHeight,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedMemCacheWidth = ImageDecodeUtils.resolveDecodeSize(
      context,
      width,
      explicitSize: memCacheWidth,
    );
    final resolvedMemCacheHeight = ImageDecodeUtils.resolveDecodeSize(
      context,
      height,
      explicitSize: memCacheHeight,
    );
    return CachedNetworkImage(
      imageUrl: imgUrl,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      memCacheWidth: resolvedMemCacheWidth,
      memCacheHeight: resolvedMemCacheHeight,
      maxWidthDiskCache: resolvedMemCacheWidth,
      maxHeightDiskCache: resolvedMemCacheHeight,
      placeholder: (_, e) => _buildLoadingImg(),
      errorWidget: (_, a, e) => _buildErrorImg(),
    );
  }

  Widget _buildLoadingImg() {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      color: const Color(0xFFE8E8E8),
      child: Icon(
        Icons.image_outlined,
        size: 24.w,
        color: const Color(0xFF9A9A9A),
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
