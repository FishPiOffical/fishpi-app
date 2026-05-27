import 'package:fishpi_app/core/sql/chat_room_extension_store.dart';
import 'package:fishpi_app/widgets/chat/chat_room_extension_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('扩展使用弹层可填写字段、预览并填入输入框', (tester) async {
    var inserted = '';
    var sent = '';

    await tester.pumpWidget(
      _wrap(
        ChatRoomExtensionSheet(
          extensions: const [
            ChatRoomExtension(
              id: 'daily',
              name: '摸鱼日报',
              icon: '报',
              template: r'进度：${进度}',
              fields: [
                ChatRoomExtensionField(
                  key: '进度',
                  label: '进度',
                  type: ChatRoomExtensionFieldType.number,
                  required: true,
                ),
              ],
            ),
          ],
          onInsert: (text) => inserted = text,
          onSend: (text) async {
            sent = text;
            return true;
          },
        ),
      ),
    );

    await tester.tap(find.text('摸鱼日报'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('chat_room_extension_input_进度')),
      '80',
    );
    await tester.pump();

    expect(find.text('进度：80'), findsOneWidget);

    await tester
        .tap(find.byKey(const ValueKey('chat_room_extension_insert_button')));
    await tester.pumpAndSettle();

    expect(inserted, '进度：80');
    expect(sent, isEmpty);
  });

  testWidgets('扩展使用弹层可以立即发送渲染结果', (tester) async {
    var sent = '';

    await tester.pumpWidget(
      _wrap(
        ChatRoomExtensionSheet(
          extensions: const [
            ChatRoomExtension(
              id: 'hello',
              name: '问候',
              template: '大家好',
            ),
          ],
          onInsert: (_) {},
          onSend: (text) async {
            sent = text;
            return true;
          },
        ),
      ),
    );

    await tester.tap(find.text('问候'));
    await tester.pumpAndSettle();
    await tester
        .tap(find.byKey(const ValueKey('chat_room_extension_send_button')));
    await tester.pumpAndSettle();

    expect(sent, '大家好');
  });
}

Widget _wrap(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(360, 812),
    builder: (context, _) => MaterialApp(home: Scaffold(body: child)),
  );
}
