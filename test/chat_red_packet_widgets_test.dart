import 'package:fishpi/types/chatroom.dart';
import 'package:fishpi/types/redpacket.dart';
import 'package:fishpi_app/core/chat/chat_red_packet_utils.dart';
import 'package:fishpi_app/core/chat/chat_topic_utils.dart';
import 'package:fishpi_app/widgets/chat/chat_red_packet_card.dart';
import 'package:fishpi_app/widgets/chat/chat_red_packet_sheet.dart';
import 'package:fishpi_app/widgets/chat/chat_topic_bar.dart';
import 'package:fishpi_app/widgets/chat/chat_topic_sheet.dart';
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

  testWidgets('红包卡片显示类型、积分和领取进度，并可点击', (tester) async {
    var tapCount = 0;

    await tester.pumpWidget(
      _wrap(
        ChatRedPacketCard(
          redpacket: RedPacketMessage(
            type: RedPacketType.Average,
            count: 3,
            got: 1,
            money: 30,
            msg: '一起摸鱼',
          ),
          isSelf: false,
          onTap: () => tapCount++,
        ),
      ),
    );

    expect(find.text('一起摸鱼'), findsOneWidget);
    expect(find.text('平分红包'), findsOneWidget);
    expect(find.text('30'), findsOneWidget);
    expect(find.text('已领 1/3'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('chat_red_packet_card')));
    await tester.pump();
    expect(tapCount, 1);
  });

  testWidgets('红包弹层能切换专属和猜拳类型字段', (tester) async {
    await tester.pumpWidget(
      _wrap(
        ChatRedPacketSheet(
          onlineUsers: [
            OnlineInfo(userName: 'alice'),
            OnlineInfo(userName: 'bob'),
          ],
          senderId: '100',
          onSubmit: (_) async => false,
        ),
      ),
    );

    for (final type in ChatRedPacketUtils.types) {
      expect(find.text(ChatRedPacketUtils.typeName(type)), findsOneWidget);
    }

    await tester.tap(find.byKey(const ValueKey('red_packet_type_specify')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('red_packet_receiver_input')),
        findsOneWidget);
    expect(find.text('alice'), findsOneWidget);
    expect(find.text('bob'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('red_packet_type_rockPaperScissors')),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('red_packet_gesture_0')), findsOneWidget);
    expect(find.byKey(const ValueKey('red_packet_gesture_1')), findsOneWidget);
    expect(find.byKey(const ValueKey('red_packet_gesture_2')), findsOneWidget);
  });

  testWidgets('红包弹层提交时会校验必填字段', (tester) async {
    var submitCount = 0;

    await tester.pumpWidget(
      _wrap(
        ChatRedPacketSheet(
          onlineUsers: const [],
          senderId: '100',
          onSubmit: (_) async {
            submitCount++;
            return false;
          },
        ),
      ),
    );

    final submitButton = find.byKey(const ValueKey('red_packet_submit_button'));
    await tester.ensureVisible(submitButton);
    await tester.pump();
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(find.text('请输入有效积分'), findsOneWidget);
    expect(submitCount, 0);
  });

  testWidgets('话题条显示空态和当前话题，并响应点击', (tester) async {
    var tapCount = 0;
    var quoteTapCount = 0;

    await tester.pumpWidget(
      _wrap(
        Column(
          children: [
            ChatTopicBar(topic: '', onTap: () => tapCount++),
            ChatTopicBar(
              topic: '今天吃什么',
              onTap: () => tapCount++,
              onQuoteTap: () => quoteTapCount++,
            ),
          ],
        ),
      ),
    );

    expect(find.text('暂无话题'), findsOneWidget);
    expect(find.text('# 今天吃什么'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('chat_topic_bar')).first);
    await tester.pump();
    expect(tapCount, 1);

    await tester.tap(find.byKey(const ValueKey('chat_topic_quote_button')));
    await tester.pump();
    expect(tapCount, 1);
    expect(quoteTapCount, 1);
  });

  testWidgets('话题弹层会拦截超长话题', (tester) async {
    var submitCount = 0;

    await tester.pumpWidget(
      _wrap(
        ChatTopicSheet(
          initialTopic: '',
          onSubmit: (_) async {
            submitCount++;
            return false;
          },
        ),
      ),
    );

    await tester.enterText(
      find.byType(TextField),
      'x' * (ChatTopicUtils.maxTopicLength + 1),
    );
    await tester.tap(find.byKey(const ValueKey('chat_topic_submit_button')));
    await tester.pumpAndSettle();

    expect(
      find.text('话题不能超过 ${ChatTopicUtils.maxTopicLength} 个字符'),
      findsOneWidget,
    );
    expect(submitCount, 0);
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
