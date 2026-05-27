import 'package:fishpi_app/core/chat/chat_room_extension_runtime.dart';
import 'package:fishpi_app/core/sql/chat_room_extension_store.dart';
import 'package:fishpi_app/widgets/chat/chat_room_extension_trigger_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('触发预览弹层显示来源和结果并支持发送', (tester) async {
    var sent = '';

    await tester.pumpWidget(
      _wrap(
        ChatRoomExtensionTriggerSheet(
          result: const ChatRoomExtensionRenderResult(
            extension: ChatRoomExtension(name: '自动回复', template: 'hi'),
            trigger: ChatRoomExtensionTrigger.receiveText,
            text: '你好呀',
          ),
          onInsert: (_) {},
          onSend: (text) async {
            sent = text;
            return true;
          },
        ),
      ),
    );

    expect(find.text('自动回复'), findsOneWidget);
    expect(find.text('触发来源：收到文字'), findsOneWidget);
    expect(find.text('你好呀'), findsOneWidget);

    await tester
        .tap(find.byKey(const ValueKey('chat_room_extension_trigger_send')));
    await tester.pumpAndSettle();

    expect(sent, '你好呀');
  });
}

Widget _wrap(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(360, 812),
    builder: (context, _) => MaterialApp(home: Scaffold(body: child)),
  );
}
