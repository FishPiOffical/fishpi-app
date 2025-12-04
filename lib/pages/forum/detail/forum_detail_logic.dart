import 'dart:ffi';

import 'package:fishpi/types/types.dart';
import 'package:fishpi_app/core/controller/im.dart';
import 'package:fishpi_app/core/manager/toast.dart';
import 'package:fishpi_app/widgets/pi_editer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/pop_route.dart';

class ForumDetailLogic extends GetxController {
  final imController = Get.find<IMController>();
  final oId = ''.obs;
  final article = ArticleDetail().obs;

  final isLoading = false.obs;

  @override
  void onInit() {
    var args = Get.arguments;
    oId.value = args['oId'] ?? '';
    initArticleInfo();
    super.onInit();
  }

  void initArticleInfo() async {
    isLoading.value = true;
    ArticleDetail res = await imController.fishpi.article.detail(oId.value);
    isLoading.value = false;
    article.value = res;
    print(article.value.toJson());
  }

  void toReward() async {
    ResponseResult res =
        await imController.fishpi.article.reward(article.value.oId);
    print(res.msg);
    if (res.success) {
      initArticleInfo();
    } else {
      ToastManager.showToast(res.msg);
    }
  }

  void showEdit() async {
    Navigator.push(
      Get.context!,
      PopRoute(
        child: PiEditWidget(
          onEditingCompleteText: (text) async {
            String context = text;
            if (context.trim() == '') {
              return;
            } else {
              CommentPost data = CommentPost(
                content: context,
                articleId: article.value.oId,
              );
              ResponseResult res = await imController.fishpi.comment.send(data);
              UserInfo user = await imController.fishpi.user.info();
              if (res.success) {
                ToastManager.showToast('提交成功');
                ArticleComment comment = ArticleComment(
                  content: '<p>$context<\/p>',
                  author: user.userName,
                  thumbnailURL: user.avatarURL,
                  timeAgo: '刚刚',
                  goodCnt: 0,
                );
                article.value.comments.add(comment);
                article.refresh();
              } else {
                ToastManager.showToast(res.msg);
              }
            }
          },
        ),
      ),
    );
  }

  toGoodComment(ArticleComment comment, int index) async {
    if (comment.rewarded) {
      comment.goodCnt--;
      comment.rewarded = false;
    } else {
      comment.goodCnt++;
      comment.rewarded = true;
    }
    article.value.comments[index] = comment;
    article.refresh();
    bool res = await imController.fishpi.comment.vote(comment.oId);
    if (!res) {
      ToastManager.showToast('操作失败');
    }
  }
}
