import 'package:fishpi/fishpi.dart';

class ArticleVoteSnapshot {
  const ArticleVoteSnapshot({
    required this.vote,
    required this.goodCnt,
  });

  final VoteStatus vote;
  final int goodCnt;
}

class ArticleThankSnapshot {
  const ArticleThankSnapshot({
    required this.thanked,
    required this.thankedCnt,
  });

  final bool thanked;
  final int thankedCnt;
}

class CommentVoteSnapshot {
  const CommentVoteSnapshot({
    required this.vote,
    required this.goodCnt,
  });

  final VoteStatus vote;
  final int goodCnt;
}

class ForumInteractionUtils {
  ForumInteractionUtils._();

  static ArticleVoteSnapshot applyArticleVote(ArticleDetail article) {
    final snapshot = ArticleVoteSnapshot(
      vote: article.vote,
      goodCnt: article.goodCnt,
    );
    final nextUp = article.vote != VoteStatus.up;
    article.vote = nextUp ? VoteStatus.up : VoteStatus.normal;
    article.goodCnt = _nonNegative(article.goodCnt + (nextUp ? 1 : -1));
    return snapshot;
  }

  static void rollbackArticleVote(
    ArticleDetail article,
    ArticleVoteSnapshot snapshot,
  ) {
    article.vote = snapshot.vote;
    article.goodCnt = snapshot.goodCnt;
  }

  static ArticleThankSnapshot applyArticleThank(ArticleDetail article) {
    final snapshot = ArticleThankSnapshot(
      thanked: article.thanked,
      thankedCnt: article.thankedCnt,
    );
    final nextThanked = !article.thanked;
    article.thanked = nextThanked;
    article.thankedCnt =
        _nonNegative(article.thankedCnt + (nextThanked ? 1 : -1));
    return snapshot;
  }

  static void rollbackArticleThank(
    ArticleDetail article,
    ArticleThankSnapshot snapshot,
  ) {
    article.thanked = snapshot.thanked;
    article.thankedCnt = snapshot.thankedCnt;
  }

  static CommentVoteSnapshot applyCommentVote(ArticleComment comment) {
    final snapshot = CommentVoteSnapshot(
      vote: comment.vote,
      goodCnt: comment.goodCnt,
    );
    final nextUp = comment.vote != VoteStatus.up;
    comment.vote = nextUp ? VoteStatus.up : VoteStatus.normal;
    comment.goodCnt = _nonNegative(comment.goodCnt + (nextUp ? 1 : -1));
    return snapshot;
  }

  static void rollbackCommentVote(
    ArticleComment comment,
    CommentVoteSnapshot snapshot,
  ) {
    comment.vote = snapshot.vote;
    comment.goodCnt = snapshot.goodCnt;
  }

  static int _nonNegative(int value) => value < 0 ? 0 : value;
}
