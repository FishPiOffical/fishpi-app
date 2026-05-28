import 'package:fishpi/fishpi.dart';
import 'package:fishpi_app/core/forum/article_utils.dart';
import 'package:fishpi_app/widgets/pi_avatar.dart';
import 'package:fishpi_app/widgets/pi_image.dart';
import 'package:fishpi_app/widgets/vip_badge.dart';
import 'package:fishpi_app/widgets/vip_name_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../res/styles.dart';
import '../routers/navigator.dart';
import '../utils/pi_utils.dart';

class PiArticleItem extends StatelessWidget {
  final ArticleDetail article;

  const PiArticleItem({required this.article, super.key});

  @override
  Widget build(BuildContext context) {
    final isSticky = ArticleUtils.isStickyArticle(article);
    return GestureDetector(
      onTap: () {
        AppNavigator.toForumDetail(oId: article.oId);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 20.h),
        decoration: BoxDecoration(
          border: Styles.commonBorder,
          borderRadius: Styles.cardRadius,
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
              padding: Styles.compactCardPadding,
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
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Styles.primaryTextColor,
                              ),
                            ),
                            if (isSticky) ...[
                              6.verticalSpace,
                              _buildStickyBadge(),
                            ],
                            Text(
                              article.previewContent,
                              style: TextStyle(
                                fontSize: 14.sp,
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
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: VipNameText(
                                    userId: article.authorId,
                                    userName: article.authorName,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Styles.primaryTextColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                6.horizontalSpace,
                                VipBadge(
                                  userId: article.authorId,
                                  userName: article.authorName,
                                ),
                              ],
                            ),
                            if (article.tags.trim().isNotEmpty) ...[
                              3.verticalSpace,
                              Text(
                                article.tags.replaceAll(",", " "),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Styles.c4Color,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      10.horizontalSpace,
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

  Widget _buildStickyBadge() {
    return Container(
      key: const ValueKey('article_sticky_badge'),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: Styles.primaryColor,
        border: Styles.commonBorder,
        borderRadius: Styles.controlRadius,
      ),
      child: Text(
        '置顶',
        style: TextStyle(
          color: Styles.primaryTextColor,
          fontSize: 11.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
