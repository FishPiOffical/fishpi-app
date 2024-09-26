import 'package:fishpi/fishpi.dart';
import 'package:fishpi_app/widgets/pi_avatar.dart';
import 'package:fishpi_app/widgets/pi_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../res/styles.dart';
import '../routers/navigator.dart';
import '../utils/pi_utils.dart';

class PiArticleItem extends StatelessWidget {
  final ArticleDetail article;

  const PiArticleItem({required this.article, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AppNavigator.toForumDetail(oId: article.oId);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 20.h),
        decoration: BoxDecoration(
          border: Styles.commonBorder,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          children: [
            if (article.thumbnailURL != '')
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(14.r),
                  topRight: Radius.circular(14.r),
                ),
                child: PiImage(
                  imgUrl: PiUtils.filterImageWithSize(
                    article.thumbnailURL,
                    width: 750,
                    height: 360,
                  ),
                  width: 1.sw,
                  height: 180.h,
                ),
              ),
            Container(
              padding: EdgeInsets.all(10.w),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              article.titleEmojUnicode,
                              style: TextStyle(
                                fontSize: 27.sp,
                                fontWeight: FontWeight.bold,
                                color: Styles.primaryTextColor,
                              ),
                            ),
                            Text(
                              article.previewContent,
                              style: TextStyle(
                                fontSize: 15.sp,
                                color: Styles.secondaryTextColor,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      PiAvatar(
                        userName: article.authorName,
                        avatarURL: article.thumbnailURL210,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        article.tags.replaceAll(",", " "),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Styles.c4Color,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/comment.png',
                            width: 20.w,
                            height: 20.w,
                          ),
                          5.horizontalSpace,
                          Text(
                            article.commentCnt.toString(),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Styles.primaryTextColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          10.horizontalSpace,
                          Image.asset(
                            'assets/images/thank.png',
                            width: 20.w,
                            height: 20.w,
                          ),
                          5.horizontalSpace,
                          Text(
                            article.goodCnt.toString(),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Styles.primaryTextColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
