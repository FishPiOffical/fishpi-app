import 'package:fishpi/types/chatroom.dart';
import 'package:fishpi_app/core/chat/chat_barrager_utils.dart';
import 'package:fishpi_app/widgets/chat/chat_barrager_overlay.dart';
import 'package:fishpi_app/widgets/chat/chat_barrager_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  setUp(() {
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('弹幕发送弹层校验空内容并提交颜色和内容', (tester) async {
    String? content;
    String? color;

    await tester.pumpWidget(
      _wrap(
        ChatBarragerSheet(
          cost: BarrageCost(cost: 20, unit: '积分'),
          onSubmit: (value, selectedColor) async {
            content = value;
            color = selectedColor;
            return true;
          },
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('chat_barrager_submit_button')));
    await tester.pumpAndSettle();
    expect(find.text('请输入弹幕内容'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '  你好弹幕  ');
    await tester.tap(
      find.byKey(const ValueKey('chat_barrager_color_#FF9F1C')),
    );
    await tester.tap(find.byKey(const ValueKey('chat_barrager_submit_button')));
    await tester.pumpAndSettle();

    expect(content, '你好弹幕');
    expect(color, '#FF9F1C');
  });

  testWidgets('弹幕覆盖层从右到左展示并结束回调', (tester) async {
    final finished = <String>[];

    await tester.pumpWidget(
      _wrap(
        SizedBox(
          width: 360,
          height: 240,
          child: ChatBarragerOverlay(
            barragers: [
              ChatBarragerItem(
                id: 'b1',
                track: 0,
                message: BarragerMsg(
                  userName: 'alice',
                  barragerContent: '摸鱼快乐',
                  barragerColor: '#FFE66D',
                ),
              ),
            ],
            onFinished: finished.add,
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('chat_barrager_b1')), findsOneWidget);
    expect(find.text('alice：摸鱼快乐'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 7000));
    await tester.pump();
    expect(finished, ['b1']);
  });
}

Widget _wrap(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(360, 812),
    builder: (context, _) => GetMaterialApp(
      home: Scaffold(body: child),
    ),
  );
}
