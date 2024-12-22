import 'package:cached_network_image/cached_network_image.dart';
import 'package:fishpi_app/res/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PiAvatar extends StatelessWidget {
  final String? userName;
  final String? avatarURL;
  final double? width;
  final double? height;

  const PiAvatar({
    this.userName,
    this.avatarURL,
    this.width,
    this.height,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 48.w,
      height: height ?? 48.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          width: 2,
          color: Styles.primaryTextColor,
        ),
      ),
      child: ClipOval(
        child: SizedBox(
          width: width ?? 48.w,
          height: height ?? 48.w,
          child: avatarURL != ''
              ? CachedNetworkImage(
                  imageUrl: avatarURL ?? '',
                  width: width ?? 48.w,
                  height: height ?? 48.w,
                  fit: BoxFit.cover,
                  errorWidget: (_, e, a) => _buildDefaultAvatar(),
                )
              : _buildDefaultAvatar(),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: Styles.primaryColor,
      alignment: Alignment.center,
      child: Text(
        userName!.substring(0, 1),
        style: TextStyle(
          fontSize: 20.sp,
          color: Styles.primaryTextColor,
        ),
      ),
    );
  }
}
