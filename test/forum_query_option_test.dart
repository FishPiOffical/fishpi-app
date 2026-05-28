import 'package:fishpi/fishpi.dart';
import 'package:fishpi_app/core/forum/forum_query_option.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('帖子查询选项映射到 SDK 支持的列表类型', () {
    expect(
      ForumQueryOption.defaults.map((option) => option.type),
      [
        ArticleListType.Reply,
        ArticleListType.Recent,
        ArticleListType.Hot,
        ArticleListType.Perfect,
      ],
    );
    expect(ForumQueryOption.byType(ArticleListType.Hot).title, '热门');
    expect(ForumQueryOption.byType('unknown').title, '最新回复');
  });
}
