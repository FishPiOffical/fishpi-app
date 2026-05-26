import 'package:fishpi/types/article.dart';
import 'package:fishpi_app/core/forum/article_utils.dart';
import 'package:fishpi_app/widgets/pi_article_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('帖子列表会把置顶文章排在普通文章前面', () {
    final articles = [
      ArticleDetail(oId: 'normal-1', titleEmojUnicode: '普通 1'),
      ArticleDetail(oId: 'sticky-1', titleEmojUnicode: '置顶 1', stick: 1),
      ArticleDetail(oId: 'normal-2', titleEmojUnicode: '普通 2'),
      ArticleDetail(
        oId: 'sticky-2',
        titleEmojUnicode: '置顶 2',
        stickRemains: 10,
      ),
    ];

    final result = ArticleUtils.sortStickyFirst(articles);

    expect(result.map((item) => item.oId), [
      'sticky-1',
      'sticky-2',
      'normal-1',
      'normal-2',
    ]);
  });

  testWidgets('置顶帖子会显示置顶标识', (tester) async {
    await tester.pumpWidget(
      _wrap(
        PiArticleItem(
          article: ArticleDetail(
            oId: 'sticky',
            titleEmojUnicode: '置顶文章',
            previewContent: '预览',
            stick: 1,
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('article_sticky_badge')), findsOneWidget);
    expect(find.text('置顶'), findsOneWidget);
  });

  testWidgets('普通帖子不显示置顶标识', (tester) async {
    await tester.pumpWidget(
      _wrap(
        PiArticleItem(
          article: ArticleDetail(
            oId: 'normal',
            titleEmojUnicode: '普通文章',
            previewContent: '预览',
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('article_sticky_badge')), findsNothing);
  });
}

Widget _wrap(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(360, 812),
    builder: (context, _) => MaterialApp(home: Scaffold(body: child)),
  );
}
