import 'package:fishpi_app/pages/chat/chat_room_settings/chat_room_settings_view.dart';
import 'package:fishpi_app/widgets/pi_title_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('聊天室设置页可正常渲染标题和空状态', (tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 812),
        builder: (context, _) => const MaterialApp(
          home: ChatRoomSettingsPage(),
        ),
      ),
    );

    expect(find.byType(PiTitleBar), findsOneWidget);
    expect(find.text('聊天室设置'), findsOneWidget);
    expect(find.text('暂无设置项'), findsOneWidget);
  });
}
