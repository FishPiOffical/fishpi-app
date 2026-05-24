import 'dart:async';

import 'package:fishpi_app/widgets/chat/chat_input_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('空白内容不发送，发送成功后清空输入框', (tester) async {
    final controller = TextEditingController();
    final focusNode = FocusNode();
    var sendCount = 0;

    await tester.pumpWidget(
      _wrap(
        ChatInputBox(
          controller: controller,
          focusNode: focusNode,
          emojiList: const {},
          diyEmojiList: const [],
          onInput: (_) {},
          clickSend: () async {
            sendCount++;
            controller.clear();
          },
          scrollToBottom: () {},
        ),
      ),
    );

    await tester.tap(_assetImage('assets/images/more_feature.png'));
    await tester.pumpAndSettle();
    expect(sendCount, 0);

    await tester.enterText(find.byType(TextField), '你好');
    await tester.pump();
    await tester.tap(_assetImage('assets/images/send.png'));
    await tester.pumpAndSettle();

    expect(sendCount, 1);
    expect(controller.text, isEmpty);

    focusNode.dispose();
    controller.dispose();
  });

  testWidgets('点击默认表情会同步到输入框内容', (tester) async {
    final controller = TextEditingController();
    final focusNode = FocusNode();
    String content = '';

    await tester.pumpWidget(
      _wrap(
        ChatInputBox(
          controller: controller,
          focusNode: focusNode,
          emojiList: const {'smile': 'https://example.com/smile.png'},
          diyEmojiList: const [],
          onInput: (text) => content = text,
          clickSend: () async {},
          scrollToBottom: () {},
        ),
      ),
    );

    await tester.tap(_assetImage('assets/images/face.png'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('emoji_default_smile')));
    await tester.pumpAndSettle();

    expect(controller.text, ':smile:');
    expect(content, ':smile:');

    focusNode.dispose();
    controller.dispose();
  });

  testWidgets('语音模式支持长按开始并松开发送', (tester) async {
    final controller = TextEditingController();
    final focusNode = FocusNode();
    var startCount = 0;
    var finishCount = 0;

    await tester.pumpWidget(
      _wrap(
        ChatInputBox(
          controller: controller,
          focusNode: focusNode,
          emojiList: const {},
          diyEmojiList: const [],
          onInput: (_) {},
          clickSend: () async {},
          scrollToBottom: () {},
          onVoiceRecordStart: () async {
            startCount++;
          },
          onVoiceRecordFinish: () async {
            finishCount++;
          },
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.keyboard_voice_outlined));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('chat_voice_record_button')), findsOne);

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('chat_voice_record_button'))),
    );
    await tester.pump(const Duration(milliseconds: 600));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(startCount, 1);
    expect(finishCount, 1);

    focusNode.dispose();
    controller.dispose();
  });

  testWidgets('禁用语音时不显示语音切换按钮', (tester) async {
    final controller = TextEditingController();
    final focusNode = FocusNode();

    await tester.pumpWidget(
      _wrap(
        ChatInputBox(
          controller: controller,
          focusNode: focusNode,
          emojiList: const {},
          diyEmojiList: const [],
          onInput: (_) {},
          clickSend: () async {},
          scrollToBottom: () {},
          enableVoice: false,
        ),
      ),
    );

    expect(find.byIcon(Icons.keyboard_voice_outlined), findsNothing);

    focusNode.dispose();
    controller.dispose();
  });

  testWidgets('录音启动较慢时松手后只会触发一次发送', (tester) async {
    final controller = TextEditingController();
    final focusNode = FocusNode();
    final startCompleter = Completer<void>();
    var finishCount = 0;

    await tester.pumpWidget(
      _wrap(
        ChatInputBox(
          controller: controller,
          focusNode: focusNode,
          emojiList: const {},
          diyEmojiList: const [],
          onInput: (_) {},
          clickSend: () async {},
          scrollToBottom: () {},
          onVoiceRecordStart: () => startCompleter.future,
          onVoiceRecordFinish: () async {
            finishCount++;
          },
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.keyboard_voice_outlined));
    await tester.pumpAndSettle();
    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('chat_voice_record_button'))),
    );
    await tester.pump(const Duration(milliseconds: 600));
    await gesture.up();
    await tester.pump();

    expect(finishCount, 0);
    startCompleter.complete();
    await tester.pumpAndSettle();

    expect(finishCount, 1);

    focusNode.dispose();
    controller.dispose();
  });
}

Widget _wrap(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(360, 812),
    builder: (context, _) => MaterialApp(home: Scaffold(body: child)),
  );
}

Finder _assetImage(String assetName) {
  return find.byWidgetPredicate((widget) {
    if (widget is! Image || widget.image is! AssetImage) return false;
    return (widget.image as AssetImage).assetName == assetName;
  });
}
