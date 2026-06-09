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
  });
}
