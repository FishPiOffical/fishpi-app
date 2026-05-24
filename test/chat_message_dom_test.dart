import 'package:fishpi_app/widgets/pi_msg_dom.dart';
import 'package:fishpi_app/widgets/pi_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/parser.dart' as html_parser;

void main() {
  group('聊天 HTML 渲染', () {
    testWidgets('嵌套 blockquote 不重复渲染后代文本', (tester) async {
      await tester
          .pumpWidget(_wrap(_message('<blockquote><p>hello</p></blockquote>')));

      expect(_textWithTrim('hello'), findsOneWidget);
    });

    testWidgets('混合文本和链接按原位置渲染且不丢文本', (tester) async {
      await tester.pumpWidget(
        _wrap(_message('<p>hello <a href="https://x.com">link</a> world</p>')),
      );

      expect(_textWithTrim('hello'), findsOneWidget);
      expect(_textWithTrim('link'), findsOneWidget);
      expect(_textWithTrim('world'), findsOneWidget);
    });

    testWidgets('行内 code 替换到原位置且不重复内容', (tester) async {
      await tester
          .pumpWidget(_wrap(_message('<p>before <code>x</code> after</p>')));

      expect(_textWithTrim('before'), findsOneWidget);
      expect(_textWithTrim('x'), findsOneWidget);
      expect(_textWithTrim('after'), findsOneWidget);
    });

    testWidgets('列表和 strong 嵌套内容不重复', (tester) async {
      await tester.pumpWidget(
          _wrap(_message('<ul><li>a <strong>b</strong></li></ul>')));

      expect(_textWithTrim('-'), findsOneWidget);
      expect(_textWithTrim('a'), findsOneWidget);
      expect(_textWithTrim('b'), findsOneWidget);
    });

    testWidgets('details 展开后按 nodes 渲染且不重复', (tester) async {
      await tester
          .pumpWidget(_wrap(_message('<details><p>hidden</p></details>')));

      expect(find.text('#展开'), findsOneWidget);
      expect(_textWithTrim('hidden'), findsNothing);

      await tester.tap(find.text('#展开'));
      await tester.pumpAndSettle();

      expect(find.text('#收起'), findsOneWidget);
      expect(_textWithTrim('hidden'), findsOneWidget);
    });

    testWidgets('纯图片缩略图可使用 cover 保证圆角裁剪一致', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ChatMessageDomNode.buildImageUrl(
            'https://example.com/a.png',
            'chat-1',
            false,
            'single_image',
            width: 100,
            height: 80,
            borderRadius: 10,
            fit: BoxFit.cover,
          ),
        ),
      );

      final image = tester.widget<PiImage>(find.byType(PiImage));
      final clip = tester.widget<ClipRRect>(find.byType(ClipRRect));

      expect(image.fit, BoxFit.cover);
      expect(clip.borderRadius, BorderRadius.circular(10));
    });

    testWidgets('普通 HTML 图片保持固定尺寸防止撑开消息列表', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ChatMessageDomNode.buildImageUrl(
            'https://example.com/a.png',
            'chat-1',
            false,
            '0',
          ),
        ),
      );

      final image = tester.widget<PiImage>(find.byType(PiImage));

      expect(image.width, 120.w);
      expect(image.height, 70.h);
      expect(image.fit, BoxFit.contain);
    });
  });
}

Widget _message(String content) {
  final document = html_parser.parse(content);
  final elements = document.body?.children ?? const [];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (var index = 0; index < elements.length; index++)
        ChatMessageDomElement(
          content: elements[index],
          chat: content,
          nodePath: '$index',
        ),
    ],
  );
}

Widget _wrap(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(360, 812),
    builder: (context, _) => MaterialApp(home: Scaffold(body: child)),
  );
}

Finder _textWithTrim(String text) {
  return find.byWidgetPredicate((widget) {
    return widget is Text && widget.data?.trim() == text;
  });
}
