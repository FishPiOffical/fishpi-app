import 'package:fishpi/fishpi.dart';
import 'package:fishpi_app/core/forum/forum_interaction_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('感谢文章只更新感谢数，失败可回滚', () {
    final article = ArticleDetail(
      thanked: false,
      thankedCnt: 2,
      goodCnt: 9,
    );

    final snapshot = ForumInteractionUtils.applyArticleThank(article);

    expect(article.thanked, isTrue);
    expect(article.thankedCnt, 3);
    expect(article.goodCnt, 9);

    ForumInteractionUtils.rollbackArticleThank(article, snapshot);

    expect(article.thanked, isFalse);
    expect(article.thankedCnt, 2);
    expect(article.goodCnt, 9);
  });

  test('取消感谢不会让感谢数变成负数', () {
    final article = ArticleDetail(
      thanked: true,
      thankedCnt: 0,
    );

    ForumInteractionUtils.applyArticleThank(article);

    expect(article.thanked, isFalse);
    expect(article.thankedCnt, 0);
  });

  test('文章和评论点赞支持乐观更新和回滚', () {
    final article = ArticleDetail(
      vote: VoteStatus.normal,
      goodCnt: 1,
    );
    final comment = ArticleComment(
      vote: VoteStatus.up,
      goodCnt: 1,
    );

    final articleSnapshot = ForumInteractionUtils.applyArticleVote(article);
    final commentSnapshot = ForumInteractionUtils.applyCommentVote(comment);

    expect(article.vote, VoteStatus.up);
    expect(article.goodCnt, 2);
    expect(comment.vote, VoteStatus.normal);
    expect(comment.goodCnt, 0);

    ForumInteractionUtils.rollbackArticleVote(article, articleSnapshot);
    ForumInteractionUtils.rollbackCommentVote(comment, commentSnapshot);

    expect(article.vote, VoteStatus.normal);
    expect(article.goodCnt, 1);
    expect(comment.vote, VoteStatus.up);
    expect(comment.goodCnt, 1);
  });
}
