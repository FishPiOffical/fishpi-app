import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fishpi_app/core/network/app_error_message.dart';
import 'package:fishpi_app/widgets/pi_list_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('列表错误文案能区分网络、解析和登录失效', () {
    final requestOptions = RequestOptions(path: '/api/test');

    expect(
      AppErrorMessage.friendly(
        DioException(
          requestOptions: requestOptions,
          type: DioExceptionType.connectionTimeout,
        ),
      ),
      '网络连接超时，请检查网络后重试',
    );
    expect(
      AppErrorMessage.friendly(const SocketException('Failed host lookup')),
      '网络连接失败，请检查网络后重试',
    );
    expect(
      AppErrorMessage.friendly(TypeError(), fallback: '帖子加载失败'),
      '数据解析失败，请下拉重试',
    );
    expect(AppErrorMessage.friendly('401'), '登录状态已失效，请重新登录');
  });

  testWidgets('通用列表状态卡片显示标题、消息和重试按钮', (tester) async {
    var retryCount = 0;

    await tester.pumpWidget(
      _wrap(
        PiListState(
          key: const ValueKey('state_card'),
          retryKey: const ValueKey('state_retry'),
          title: '加载失败',
          message: '网络连接失败，请检查网络后重试',
          onRetry: () => retryCount++,
        ),
      ),
    );

    expect(find.byKey(const ValueKey('state_card')), findsOneWidget);
    expect(find.text('加载失败'), findsOneWidget);
    expect(find.text('网络连接失败，请检查网络后重试'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('state_retry')));
    await tester.pump();

    expect(retryCount, 1);
  });
}

Widget _wrap(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(360, 812),
    builder: (context, _) => MaterialApp(home: Scaffold(body: child)),
  );
}
