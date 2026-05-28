import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../res/styles.dart';

class PiMenuItem extends StatelessWidget {
  final IconData? icon;
  final Color? iconColor;
  final Widget? image;
  final String? title;
  final bool? isShowArrow;
  final String? rightText;
  final Function()? onTap;

  const PiMenuItem({
    this.icon,
    this.iconColor,
    this.image,
    this.title,
    this.isShowArrow = true,
    this.rightText,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Ink(
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 1.sw - 32.w,
          padding: EdgeInsets.symmetric(
            horizontal: PiStyleTokens.menuItemHorizontalPadding.w,
          ),
          margin: EdgeInsets.symmetric(
            vertical: PiStyleTokens.menuItemVerticalMargin.h,
          ),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (icon != null && image == null)
                Icon(
                  icon,
                  color: iconColor,
                  size: 20.w,
                ),
              if (image != null) image!,
              10.horizontalSpace,
              Text(
                '$title',
                style: TextStyle(
                  color: Styles.primaryTextColor,
                  fontSize: 17.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: 1.horizontalSpace,
              ),
              if (rightText != null)
                Text(
                  '$rightText',
                  style: TextStyle(
                    color: Styles.primaryTextColor,
                    fontSize: 14.sp,
                  ),
                ),
              if (isShowArrow!)
                Icon(
                  Icons.keyboard_arrow_right_outlined,
                  color: Styles.primaryTextColor,
                  size: 24.w,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
