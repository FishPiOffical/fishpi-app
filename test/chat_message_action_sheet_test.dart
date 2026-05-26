import 'package:fishpi_app/widgets/chat/chat_message_action_sheet.dart';
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

  testWidgets('他人消息操作菜单显示引用备注转账和屏蔽', (tester) async {
    await tester.pumpWidget(
      _wrap(
        ChatMessageActionSheet(
          displayName: '小鱼',
          canUseUserActions: true,
          canBlockChatRoomUser: true,
          onQuote: () {},
          onViewProfile: () {},
          onRemark: () {},
          onTransfer: () {},
          onBlock: () {},
        ),
      ),
    );

    expect(find.byKey(const ValueKey('chat_quote_message_action')),
        findsOneWidget);
    expect(find.byKey(const ValueKey('chat_room_view_profile_action')),
        findsOneWidget);
    expect(
        find.byKey(const ValueKey('chat_remark_user_action')), findsOneWidget);
    expect(find.byKey(const ValueKey('chat_transfer_user_action')),
        findsOneWidget);
    expect(find.byKey(const ValueKey('chat_room_block_user_action')),
        findsOneWidget);
  });

  testWidgets('自己的消息操作菜单只显示引用和取消', (tester) async {
    await tester.pumpWidget(
      _wrap(
        ChatMessageActionSheet(
          displayName: '我',
          canUseUserActions: false,
          canBlockChatRoomUser: false,
          onQuote: () {},
          onViewProfile: () {},
          onRemark: () {},
          onTransfer: () {},
          onBlock: () {},
        ),
      ),
    );

    expect(find.byKey(const ValueKey('chat_quote_message_action')),
        findsOneWidget);
    expect(
        find.byKey(const ValueKey('chat_room_cancel_action')), findsOneWidget);
    expect(find.byKey(const ValueKey('chat_remark_user_action')), findsNothing);
    expect(
        find.byKey(const ValueKey('chat_transfer_user_action')), findsNothing);
    expect(find.byKey(const ValueKey('chat_room_block_user_action')),
        findsNothing);
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
