import 'package:fishpi/types/breezemoon.dart';
import 'package:fishpi_app/widgets/pi_avatar.dart';
import 'package:fishpi_app/widgets/pi_image.dart';
import 'package:fishpi_app/widgets/vip_name_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:html/parser.dart';

import '../res/styles.dart';

class PiBreezemoonItem extends StatelessWidget {
  final BreezemoonContent breezemoon;

  const PiBreezemoonItem({required this.breezemoon, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        border: Styles.commonBorder,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PiAvatar(
                userName: breezemoon.authorName,
                avatarURL: breezemoon.thumbnailURL48,
                width: 35.w,
                height: 35.w,
              ),
              20.horizontalSpace,
              VipNameText(
                userName: breezemoon.authorName,
                style: TextStyle(
                  color: Styles.primaryTextColor,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Expanded(child: 1.horizontalSpace),
              Text(
                breezemoon.timeAgo,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Styles.c4Color,
                ),
              ),
            ],
          ),
          handleBreeze(breezemoon.content),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/location.png',
                width: 24.w,
                height: 24.w,
              ),
              Text(
                breezemoon.city,
                style: TextStyle(
                  color: Styles.primaryTextColor,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  /// 清风明月内容处理
  Widget handleBreeze(content) {
    var document = parse(content);
    List<Widget> list = [];

    /// 处理文本
    document.querySelectorAll("p,h1,h2,h3,h4,h5,h6,h7").forEach((element) {
      if (element.text.isEmpty) return;
      list.add(
        Text(
          element.text,
          style: TextStyle(
            color: Styles.primaryTextColor,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    });

    /// 处理图片
    document.querySelectorAll("img").forEach((element) {
      if (element.attributes['src']!.isEmpty) return;
      list.add(
        PiImage(
          imgUrl: element.attributes['src']!,
          width: 1.sw,
          height: 180.h,
        ),
      );
    });
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
      child: Column(
        children: list,
      ),
    );
  }
}
