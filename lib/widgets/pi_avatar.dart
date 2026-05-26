import 'package:cached_network_image/cached_network_image.dart';
import 'package:fishpi_app/core/memory/image_decode_utils.dart';
import 'package:fishpi_app/core/sql/user_remark.dart';
import 'package:fishpi_app/res/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PiAvatar extends StatelessWidget {
  final String? userName;
  final String? avatarURL;
  final double? width;
  final double? height;
  final int? memCacheWidth;
  final int? memCacheHeight;

  const PiAvatar({
    this.userName,
    this.avatarURL,
    this.width,
    this.height,
    this.memCacheWidth,
    this.memCacheHeight,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final safeAvatarURL = avatarURL?.trim() ?? '';
    final avatarWidth = width ?? 48.w;
    final avatarHeight = height ?? 48.w;
    final resolvedMemCacheWidth = ImageDecodeUtils.resolveDecodeSize(
      context,
      avatarWidth,
      explicitSize: memCacheWidth,
    );
    final resolvedMemCacheHeight = ImageDecodeUtils.resolveDecodeSize(
      context,
      avatarHeight,
      explicitSize: memCacheHeight,
    );
    return Container(
      width: avatarWidth,
      height: avatarHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          width: 2,
          color: Styles.primaryTextColor,
        ),
      ),
      child: ClipOval(
        child: SizedBox(
          width: avatarWidth,
          height: avatarHeight,
          child: safeAvatarURL.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: safeAvatarURL,
                  width: avatarWidth,
                  height: avatarHeight,
                  fit: BoxFit.cover,
                  memCacheWidth: resolvedMemCacheWidth,
                  memCacheHeight: resolvedMemCacheHeight,
                  maxWidthDiskCache: resolvedMemCacheWidth,
                  maxHeightDiskCache: resolvedMemCacheHeight,
                  errorWidget: (_, e, a) => _buildDefaultAvatar(),
                )
              : _buildDefaultAvatar(),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    final displayName = UserRemark.displayName(userName);
    final firstLetter = displayName.isEmpty ? '?' : displayName.substring(0, 1);
    return Container(
      color: Styles.primaryColor,
      alignment: Alignment.center,
      child: Text(
        firstLetter,
        style: TextStyle(
          fontSize: 20.sp,
          color: Styles.primaryTextColor,
        ),
      ),
    );
  }
}
