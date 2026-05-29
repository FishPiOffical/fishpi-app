import 'dart:async';

import 'package:fishpi/types/types.dart';
import 'package:fishpi_app/core/controller/im.dart';
import 'package:fishpi_app/core/forum/forum_interaction_utils.dart';
import 'package:fishpi_app/core/manager/toast.dart';
import 'package:fishpi_app/core/sql/user_remark.dart';
import 'package:fishpi_app/widgets/pi_editer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../widgets/pop_route.dart';

class ForumDetailLogic extends GetxController {
  final imController = Get.find<IMController>();
  final oId = ''.obs;
  final targetCommentId = ''.obs;
  final article = ArticleDetail().obs;
  final remarkVersion = 0.obs;

  final isLoading = false.obs;
  final isArticleVoting = false.obs;
  final isArticleThanking = false.obs;
  final votingCommentIds = <String>{}.obs;
  final commentSectionKey = GlobalKey();
  StreamSubscription<void>? _remarkSubscription;
  bool _shouldFocusComments = false;

  @override
  void onInit() {
    var args = Get.arguments;
    oId.value = args['oId'] ?? '';
    targetCommentId.value = args['commentId'] ?? '';
    _shouldFocusComments =
        (args['focusComments'] ?? false) || targetCommentId.value.isNotEmpty;
    UserRemark.init();
    _remarkSubscription ??= UserRemark.changes.listen((_) {
      remarkVersion.value++;
    });
    initArticleInfo();
    super.onInit();
  }

  String displayNameFor(String userName, {String? fallback}) {
    remarkVersion.value;
    return UserRemark.displayName(userName, fallback: fallback);
  }

  void initArticleInfo() async {
    isLoading.value = true;
    try {
      ArticleDetail res = await imController.fishpi.article.detail(oId.value);
      article.value = res;
      _scrollToCommentsIfNeeded();
    } catch (e) {
      ToastManager.showToast('文章加载失败：$e');
    } finally {
      isLoading.value = false;
    }
  }

  void toReward() async {
    ResponseResult res =
        await imController.fishpi.article.reward(article.value.oId);
    if (res.success) {
      initArticleInfo();
    } else {
      ToastManager.showToast(res.msg);
    }
  }

  void handleCommentTap() {
    if (!article.value.commentable) {
      ToastManager.showToast('该文章暂不可评论');
      scrollToComments();
      return;
    }
    showEdit();
  }

  void scrollToComments() {
    final context = commentSectionKey.currentContext;
    if (context == null) return;
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      alignment: 0.08,
    );
  }

  void _scrollToCommentsIfNeeded() {
    if (!_shouldFocusComments) return;
    _shouldFocusComments = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToComments();
    });
  }

  void showEdit() async {
    if (!article.value.commentable) {
      ToastManager.showToast('该文章暂不可评论');
      return;
    }
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
                  content: '<p>$context</p>',
                  author: user.userName,
                  authorId: user.oId,
                  thumbnailURL: user.avatarURL,
                  articleId: article.value.oId,
                  timeAgo: '刚刚',
                  goodCnt: 0,
                );
                article.value.comments = [
                  ...article.value.comments,
                  comment,
                ];
                article.value.commentCnt++;
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
    final key = comment.oId.isNotEmpty ? comment.oId : '$index';
    if (votingCommentIds.contains(key)) return;
    votingCommentIds.add(key);

    final snapshot = ForumInteractionUtils.applyCommentVote(comment);
    article.value.comments[index] = comment;
    article.refresh();

    try {
      await imController.fishpi.comment.vote(comment.oId);
    } catch (e) {
      ForumInteractionUtils.rollbackCommentVote(comment, snapshot);
      article.value.comments[index] = comment;
      article.refresh();
      ToastManager.showToast('操作失败：$e');
    } finally {
      votingCommentIds.remove(key);
    }
  }

  toGoodArticle() async {
    if (isArticleVoting.value) return;
    isArticleVoting.value = true;
    final snapshot = ForumInteractionUtils.applyArticleVote(article.value);
    article.refresh();

    try {
      await imController.fishpi.article.vote(article.value.oId);
    } catch (e) {
      ForumInteractionUtils.rollbackArticleVote(article.value, snapshot);
      article.refresh();
      ToastManager.showToast('操作失败：$e');
    } finally {
      isArticleVoting.value = false;
    }
  }

  toThankArticle() async {
    if (isArticleThanking.value) return;
    isArticleThanking.value = true;
    final snapshot = ForumInteractionUtils.applyArticleThank(article.value);
    article.refresh();

    try {
      ResponseResult res =
          await imController.fishpi.article.thank(article.value.oId);
      if (!res.success) {
        ForumInteractionUtils.rollbackArticleThank(article.value, snapshot);
        article.refresh();
        ToastManager.showToast(res.msg);
      }
    } catch (e) {
      ForumInteractionUtils.rollbackArticleThank(article.value, snapshot);
      article.refresh();
      ToastManager.showToast('操作失败：$e');
    } finally {
      isArticleThanking.value = false;
    }
  }

  Future<void> openMarkdownLink(String? url) async {
    final value = url?.trim() ?? '';
    if (value.isEmpty) return;
    final uri = Uri.tryParse(value);
    if (uri == null) {
      ToastManager.showToast('链接地址无效');
      return;
    }
    final target = uri.hasScheme ? uri : Uri.parse('https://fishpi.cn$value');
    final success =
        await launchUrl(target, mode: LaunchMode.externalApplication);
    if (!success) {
      ToastManager.showToast('链接打开失败');
    }
  }

  @override
  void onClose() {
    _remarkSubscription?.cancel();
    super.onClose();
  }
}
