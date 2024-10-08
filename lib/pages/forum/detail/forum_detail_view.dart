import 'package:fishpi/types/article.dart';
import 'package:fishpi_app/res/styles.dart';
import 'package:fishpi_app/routers/navigator.dart';
import 'package:fishpi_app/utils/pi_utils.dart';
import 'package:fishpi_app/widgets/loading.dart';
import 'package:fishpi_app/widgets/pi_avatar.dart';
import 'package:fishpi_app/widgets/pi_title_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:markdown_widget/markdown_widget.dart';
import '../../../widgets/pi_sm.dart';
import 'forum_detail_logic.dart';

class ForumDetailPage extends StatelessWidget {
  final ForumDetailLogic logic = Get.find();

  ForumDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PiTitleBar.back(
        title: '详情',
      ),
      body: Obx(
        () => SizedBox(
          width: 1.sw,
          height: 1.sh,
          child: logic.isLoading.value
              ? const Loading()
              : ListView(
                  padding:
                      EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
                  children: [
                    Text(
                      logic.article.value.titleEmojUnicode,
                      style: TextStyle(
                        fontSize: 36.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${logic.article.value.authorName}·${logic.article.value.timeAgo}·${logic.article.value.viewCnt}人看过',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF9FA4B4),
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const Divider(),
                    ...buildMarkdown(),
                    if (logic.article.value.rewardPoint != 0)
                      SizedBox(
                        width: 1.sw - 32.w,
                        child: Stack(
                          children: [
                            Positioned(
                              child: PiZebraStripesBack(
                                width: 1.sw - 32.w,
                                height: 88.h,
                                lineWidth: 10.w,
                                lineColor: Styles.c4Color,
                                spacing: 10.w,
                              ),
                            ),
                            logic.article.value.rewarded
                                ? Positioned(
                                    child: GestureDetector(
                                      onTap: () {
                                        // 打赏
                                      },
                                      child: Container(
                                        width: 1.sw - 32.w,
                                        padding: EdgeInsets.all(10.w),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Text(
                                              logic.article.value.rewardContent,
                                              style: TextStyle(
                                                color: Styles.primaryTextColor,
                                                fontSize: 16.sp,
                                              ),
                                              textAlign: TextAlign.left,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                : Positioned(
                                    child: GestureDetector(
                                      onTap: () {
                                        // 打赏
                                      },
                                      child: Container(
                                        width: 1.sw - 32.w,
                                        height: 88.h,
                                        padding: EdgeInsets.all(10.w),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            SizedBox(
                                              width: 1.sw - 32.w,
                                              child: RichText(
                                                text: TextSpan(
                                                  text: '打赏',
                                                  style: TextStyle(
                                                    color:
                                                        const Color(0xFFED8F26),
                                                    fontSize: 16.sp,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  children: [
                                                    TextSpan(
                                                      text:
                                                          '${logic.article.value.rewardPoint}积分后可见',
                                                      style: TextStyle(
                                                        fontSize: 16.sp,
                                                        color: Styles
                                                            .primaryTextColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 1.sw - 32.w,
                                              child: Text(
                                                '${logic.article.value.rewardedCnt}人打赏',
                                                style: TextStyle(
                                                  color:
                                                      const Color(0xFFED8F26),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12.sp,
                                                ),
                                                textAlign: TextAlign.right,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    const Divider(),
                    10.verticalSpace,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '评论 ${logic.article.value.commentCnt}',
                          style: TextStyle(
                            color: Styles.primaryTextColor,
                            fontSize: 14.sp,
                          ),
                        ),
                        GestureDetector(
                          onTap: (){
                            logic.showEdit();
                          },
                          child: Text(
                            '写评论',
                            style: TextStyle(
                              color: Styles.primaryColor,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    10.verticalSpace,
                    ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: buildCommentItem,
                      reverse: true,
                      itemCount: logic.article.value.comments.length,
                    )
                  ],
                ),
        ),
      ),
    );
  }

  List<Widget> buildMarkdown() {
    String article = logic.article.value.source;
    var parser = EmojiParser();
    article = parser.emojify(article);
    return MarkdownGenerator().buildWidgets(
      article,
      config: MarkdownConfig(
        configs: [
          LinkConfig(
            style: const TextStyle(
              color: Styles.primaryColor,
              decoration: TextDecoration.underline,
              decorationColor: Styles.primaryColor,
            ),
            onTap: (url) {},
          )
        ],
      ),
    );
  }

  Widget buildCommentItem(BuildContext context, int index) {
    ArticleComment item = logic.article.value.comments[index];
    return Container(
      width: 1.sw - 32.w,
      margin: EdgeInsets.only(bottom: 20.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: (){
              AppNavigator.toUserPanel(userName: item.author);
            },
            child: PiAvatar(
              userName: item.author,
              avatarURL: item.thumbnailURL,
              width: 30.w,
              height: 30.w,
            ),
          ),
          10.horizontalSpace,
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.author,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Styles.primaryTextColor,
                          ),
                        ),
                        10.horizontalSpace,
                        Text(
                          item.timeAgo,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Styles.c4Color,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/unlike.png',
                          width: 20.w,
                          height: 20.w,
                        ),
                        Text(
                          '${item.goodCnt}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Styles.c4Color,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                PiUtils.getChatPreview(item.content),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
