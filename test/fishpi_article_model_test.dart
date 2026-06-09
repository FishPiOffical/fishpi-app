import 'package:fishpi/types/article.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Article model', () {
    test('兼容服务端把随机数字段返回为字符串', () {
      final tag = ArticleTag.from({
        'tagTitle': '系统公告',
        'tagRandomDouble': '0.42',
      });
      final article = ArticleDetail.from({
        'articleTitle': 'Kesini 抽卡站开服试运营公告',
        'articleRandomDouble': '0.88',
        'articleTagObjs': [
          {
            'tagTitle': '系统公告',
            'tagRandomDouble': '0.42',
          },
        ],
      });

      expect(tag.randomDouble, 0.42);
      expect(article.randomDouble, 0.88);
      expect(article.tagObjs.single.randomDouble, 0.42);
    });

    test('非法随机数字段按 0 兜底', () {
      final tag = ArticleTag.from({'tagRandomDouble': 'not-a-number'});
      final article = ArticleDetail.from({
        'articleRandomDouble': 'not-a-number',
      });

      expect(tag.randomDouble, 0);
      expect(article.randomDouble, 0);
    });

    test('兼容文章详情里的字符串数字、布尔和枚举字段', () {
      final article = ArticleDetail.from({
        'articleType': '2',
        'articleStatus': '2',
        'articleVote': '0',
        'articleShowInList': '1',
        'articleViewCount': '12',
        'articleCommentCount': '3',
        'articleCommentable': 'true',
        'articleTagObjs': [
          {
            'tagGoodCnt': '1',
            'tagRandomDouble': '0.12',
          },
        ],
        'pagination': {
          'paginationPageCount': '2',
          'paginationPageNums': ['1', 2, '3.0'],
        },
        'articleComments': [
          {
            'commentVote': '0',
            'commentStatus': '1',
            'commentVisible': '0',
            'commentGoodCnt': '5',
            'commentNice': 'true',
            'rewarded': 'false',
            'sysMetal': null,
            'commenter': null,
          },
        ],
        'articleNiceComments': null,
      });

      expect(article.type, ArticleType.Broadcast);
      expect(article.status, ArticleStatus.Lock);
      expect(article.vote, VoteStatus.up);
      expect(article.showInList, isTrue);
      expect(article.viewCnt, 12);
      expect(article.commentCnt, 3);
      expect(article.commentable, isTrue);
      expect(article.tagObjs.single.goodCnt, 1);
      expect(article.tagObjs.single.randomDouble, 0.12);
      expect(article.pagination?.count, 2);
      expect(article.pagination?.pageNums, [1, 2, 3]);
      expect(article.comments.single.vote, VoteStatus.up);
      expect(article.comments.single.status, ArticleStatus.Ban);
      expect(article.comments.single.visible, isTrue);
      expect(article.comments.single.goodCnt, 5);
      expect(article.comments.single.isNice, isTrue);
      expect(article.comments.single.rewarded, isFalse);
      expect(article.comments.single.sysMetal, isEmpty);
      expect(article.niceComments, isEmpty);
    });

    test('文章列表兼容异常列表、分页和标签结构', () {
      final list = ArticleList.from({
        'articles': [
          {'articleTitle': 123, 'articleRandomDouble': '0.2'},
          'bad-item',
        ],
        'pagination': {'paginationPageCount': '4'},
        'tag': {'tagTitle': 456, 'tagGoodCnt': '7'},
      });

      expect(list.list, hasLength(1));
      expect(list.list.single.title, '123');
      expect(list.list.single.randomDouble, 0.2);
      expect(list.pagination.count, 4);
      expect(list.tag?.title, '456');
      expect(list.tag?.goodCnt, 7);
    });
  });
}
