import 'package:fishpi/types/article.dart';
import 'package:fishpi_app/res/view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../widgets/pi_article_item.dart';
import 'forum_logic.dart';

class ForumPage extends StatelessWidget {
  final ForumLogic logic = Get.find<ForumLogic>();

  ForumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => Container(
          width: 1.sw,
          height: 1.sh,
          padding: EdgeInsets.symmetric(
            horizontal: 16.w,
          ),
          child: SmartRefresher(
            controller: logic.refresherController,
            header: Views.buildHeader(),
            footer: Views.buildFooter(),
            enablePullUp: true,
            enablePullDown: true,
            onRefresh: logic.onRefresh,
            onLoading: logic.onLoading,
            child: ListView.builder(
              padding: EdgeInsets.only(top: 20.h),
              itemBuilder: _buildArticleList,
              itemCount: logic.list.length,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArticleList(BuildContext context, int idx) {
    ArticleDetail article = logic.list[idx];
    return PiArticleItem(article: article);
  }
}
