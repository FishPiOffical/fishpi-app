import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:fishpi_app/core/controller/im.dart';
import 'package:fishpi_app/core/medal/medal_service.dart';
import 'package:fishpi_app/pages/mine/collection_list/collection_list_logic.dart';
import 'package:fishpi_app/pages/mine/collection_list/collection_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  tearDown(Get.reset);

  group('典藏馆勋章服务', () {
    test('解析我的勋章列表并保留展示状态', () async {
      final adapter = _CaptureAdapter(
        response: {
          'code': 0,
          'data': [
            {
              'medal_id': 'm2',
              'medal_name': '第二枚',
              'medal_description': '描述二',
              'medal_type': '稀有',
              'display': false,
              'display_order': 2,
              'expire_time': 0,
            },
            {
              'medal_id': 'm1',
              'medal_name': '第一枚',
              'medal_description': '描述一',
              'medal_type': '精良',
              'display': true,
              'display_order': 1,
            },
          ],
        },
      );
      final service = MedalService(
        dio: Dio()..httpClientAdapter = adapter,
        baseUrl: 'https://fishpi.cn',
      );

      final medals = await service.listMyMedals(apiKey: 'token');

      expect(medals.map((item) => item.id), ['m1', 'm2']);
      expect(medals.first.display, isTrue);
      expect(medals.last.display, isFalse);
      expect(medals.last.expireTime, '永久');
    });

    test('切换展示状态使用 JSON 请求体', () async {
      final adapter = _CaptureAdapter(response: {'code': 0, 'msg': 'ok'});
      final service = MedalService(dio: Dio()..httpClientAdapter = adapter);

      await service.updateDisplay(
        apiKey: 'token',
        medalId: 'm1',
        display: true,
      );

      expect(adapter.options?.contentType, Headers.jsonContentType);
      expect(adapter.body, contains('"apiKey":"token"'));
      expect(adapter.body, contains('"medalId":"m1"'));
      expect(adapter.body, contains('"display":true'));
    });
  });

  testWidgets('典藏馆页面展示勋章状态和开关', (tester) async {
    Get.testMode = true;
    Get.put(IMController());
    final logic = Get.put(CollectionListLogic(autoLoad: false));
    logic.medals.assignAll([
      const CollectionMedal(
        id: 'm1',
        name: '摸鱼勋章',
        description: '认真摸鱼',
        type: '稀有',
        display: true,
        imageUrl: 'https://fishpi.cn/gen?id=m1',
      ),
    ]);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 812),
        builder: (context, _) => GetMaterialApp(home: CollectionListPage()),
      ),
    );
    await tester.pump();

    expect(find.text('典藏馆'), findsOneWidget);
    expect(find.text('摸鱼勋章'), findsOneWidget);
    expect(find.text('展示中'), findsOneWidget);
    expect(find.byType(Switch), findsOneWidget);
  });
}

class _CaptureAdapter implements HttpClientAdapter {
  _CaptureAdapter({required this.response});

  final Map<String, dynamic> response;
  RequestOptions? options;
  String body = '';

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    this.options = options;
    if (requestStream != null) {
      final bytes = await requestStream.expand((chunk) => chunk).toList();
      body = utf8.decode(bytes);
    }
    return ResponseBody.fromString(
      jsonEncode(response),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
