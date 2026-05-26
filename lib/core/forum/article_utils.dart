import 'package:fishpi/types/article.dart';

class ArticleUtils {
  static bool isStickyArticle(ArticleDetail article) {
    return article.stick > 0 || article.stickRemains > 0;
  }

  static List<ArticleDetail> sortStickyFirst(Iterable<ArticleDetail> source) {
    final sticky = <ArticleDetail>[];
    final normal = <ArticleDetail>[];
    for (final article in source) {
      if (isStickyArticle(article)) {
        sticky.add(article);
      } else {
        normal.add(article);
      }
    }
    return [...sticky, ...normal];
  }
}
