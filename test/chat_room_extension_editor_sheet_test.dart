import 'package:fishpi_app/core/sql/chat_room_extension_store.dart';
import 'package:fishpi_app/widgets/chat/chat_room_extension_editor_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('扩展编辑器可设置触发时间、触发动作和冷却时间', (tester) async {
    ChatRoomExtension? saved;

    await tester.pumpWidget(
      _wrap(
        ChatRoomExtensionEditorSheet(
          extension: const ChatRoomExtension(
            id: 'e1',
            name: '触发扩展',
            template: 'hello',
          ),
          onSave: (extension) async {
            saved = extension;
            return null;
          },
        ),
      ),
    );

    final receiveTextTrigger =
        find.byKey(const ValueKey('chat_room_extension_trigger_receiveText'));
    await tester.ensureVisible(receiveTextTrigger);
    await tester.tap(receiveTextTrigger);
    await tester.pump();

    final insertAction =
        find.byKey(const ValueKey('chat_room_extension_action_insert'));
    await tester.ensureVisible(insertAction);
    await tester.tap(insertAction);
    await tester.pump();

    await tester.enterText(
      find.widgetWithText(TextField, '10'),
      '12',
    );
    final saveButton =
        find.byKey(const ValueKey('chat_room_extension_save_button'));
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(saved, isNotNull);
    expect(saved!.triggers, contains(ChatRoomExtensionTrigger.manual));
    expect(saved!.triggers, contains(ChatRoomExtensionTrigger.receiveText));
    expect(saved!.triggerAction, ChatRoomExtensionTriggerAction.insert);
    expect(saved!.cooldownSeconds, 12);
  });

  testWidgets('扩展编辑器展示发消息时触发器和小尾巴变量说明', (tester) async {
    await tester.pumpWidget(
      _wrap(
        ChatRoomExtensionEditorSheet(
          extension: const ChatRoomExtension(
            id: 'tail',
            name: '小尾巴',
            template: r'${message.content}\n-- 来自摸鱼派',
          ),
          onSave: (_) async => null,
        ),
      ),
    );

    expect(find.text('发消息时'), findsOneWidget);
    expect(
      find.textContaining(r'${message.content} 是输入框里准备发送的内容'),
      findsOneWidget,
    );
    expect(
      find.textContaining(r'${message.imageUrl}'),
      findsWidgets,
    );
  });

  testWidgets('扩展编辑器可以点击常用变量插入模板', (tester) async {
    ChatRoomExtension? saved;

    await tester.pumpWidget(
      _wrap(
        ChatRoomExtensionEditorSheet(
          extension: const ChatRoomExtension(
            id: 'var',
            name: '变量测试',
            template: 'hello',
          ),
          onSave: (extension) async {
            saved = extension;
            return null;
          },
        ),
      ),
    );

    final nowVariable =
        find.byKey(const ValueKey(r'chat_room_extension_variable_${now}'));
    await tester.ensureVisible(nowVariable);
    await tester.tap(nowVariable);
    await tester.pump();

    final saveButton =
        find.byKey(const ValueKey('chat_room_extension_save_button'));
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(saved, isNotNull);
    expect(saved!.template, contains(r'${now}'));
  });
}

Widget _wrap(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(360, 812),
    builder: (context, _) => MaterialApp(home: Scaffold(body: child)),
  );
}
