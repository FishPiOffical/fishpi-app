import 'dart:async';

import 'package:fishpi_app/core/chat/chat_quote_utils.dart';
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

  testWidgets('工具栏点击红包和话题会触发对应回调', (tester) async {
    final controller = TextEditingController();
    final focusNode = FocusNode();
    var redPacketTapCount = 0;
    var topicTapCount = 0;

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
          onRedPacketTap: () => redPacketTapCount++,
          onTopicTap: () => topicTapCount++,
        ),
      ),
    );

    await tester.tap(_assetImage('assets/images/more_feature.png'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('chat_tool_red_packet')));
    await tester.pumpAndSettle();

    await tester.tap(_assetImage('assets/images/more_feature.png'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('chat_tool_topic')));
    await tester.pumpAndSettle();

    expect(redPacketTapCount, 1);
    expect(topicTapCount, 1);

    focusNode.dispose();
    controller.dispose();
  });

  testWidgets('没有聊天室回调时工具栏不显示红包和话题', (tester) async {
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
        ),
      ),
    );

    await tester.tap(_assetImage('assets/images/more_feature.png'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('chat_tool_red_packet')), findsNothing);
    expect(find.byKey(const ValueKey('chat_tool_topic')), findsNothing);

    await tester.tap(_assetImage('assets/images/more_feature.png'));
    await tester.pumpAndSettle();

    focusNode.dispose();
    controller.dispose();
  });

  testWidgets('引用预览条显示摘要并支持关闭', (tester) async {
    final controller = TextEditingController();
    final focusNode = FocusNode();
    var clearCount = 0;

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
          quoteDraft: const ChatQuoteDraft(
            type: ChatQuoteType.message,
            title: '引用消息',
            preview: '小鱼：你好',
            markdown: '> 小鱼：你好',
          ),
          onClearQuote: () => clearCount++,
        ),
      ),
    );

    expect(find.byKey(const ValueKey('chat_quote_preview')), findsOneWidget);
    expect(find.text('引用消息'), findsOneWidget);
    expect(find.text('小鱼：你好'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('chat_quote_clear_button')));
    await tester.pump();

    expect(clearCount, 1);

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
