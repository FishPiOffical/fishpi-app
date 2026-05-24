import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:fishpi/types/user.dart';
import 'package:fishpi_app/core/controller/im.dart';
import 'package:fishpi_app/core/medal/medal_service.dart';
import 'package:fishpi_app/pages/mine/collection_list/collection_list_logic.dart';
import 'package:fishpi_app/pages/mine/collection_list/collection_list_view.dart';
import 'package:fishpi_app/widgets/metail_widget.dart';
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

  group('勋章等级特效', () {
    testWidgets('普通和未知等级按普通样式处理且不显示角标', (tester) async {
      _ignoreNetworkImageErrors();

      await _pumpMedalWidget(tester, level: '普通');
      expect(
        find.byKey(const ValueKey('medal_effect_normal_m1')),
        findsOneWidget,
      );
      expect(find.text('限定'), findsNothing);

      await _pumpMedalWidget(tester, level: '未知等级');
      expect(
        find.byKey(const ValueKey('medal_effect_normal_m1')),
        findsOneWidget,
      );
      expect(find.text('限定'), findsNothing);
    });

    testWidgets('不同等级渲染对应静态特效', (tester) async {
      _ignoreNetworkImageErrors();

      const levels = {
        '精良': 'fine',
        '稀有': 'rare',
        '史诗': 'epic',
        '传说': 'legendary',
        '神话': 'mythic',
        '限定': 'limited',
      };

      for (final entry in levels.entries) {
        await _pumpMedalWidget(tester, level: entry.key);

        expect(
          find.byKey(ValueKey('medal_effect_${entry.value}_m1')),
          findsOneWidget,
        );
      }
    });

    testWidgets('限定等级显示限定角标', (tester) async {
      _ignoreNetworkImageErrors();

      await _pumpMedalWidget(tester, level: '限定');

      expect(
        find.byKey(const ValueKey('medal_level_badge_limited_m1')),
        findsOneWidget,
      );
      expect(find.text('限定'), findsOneWidget);
    });
  });

  test('远端展示状态会合并本地勋章结构', () async {
    Get.testMode = true;
    final imController = Get.put(IMController());
    await imController.init('token');
    final service = MedalService(
      dio: Dio()
        ..httpClientAdapter = _CaptureAdapter(
          response: {
            'code': 0,
            'data': [
              {
                'medal_id': 'm1',
                'medal_name': '摸鱼勋章',
                'display': false,
              },
            ],
          },
        ),
    );
    final logic = Get.put(
      CollectionListLogic(
        medalService: service,
        autoLoad: false,
      ),
    );
    logic.medals.assignAll([CollectionMedal.fromMetal(_metal())]);

    await logic.loadMedals();

    expect(logic.medals.single.display, isFalse);
    expect(logic.medals.single.rawMetal?.name, '摸鱼勋章');
  });

  testWidgets('典藏馆页面展示勋章状态和操作按钮', (tester) async {
    final oldOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exception is NetworkImageLoadException) return;
      oldOnError?.call(details);
    };
    addTearDown(() => FlutterError.onError = oldOnError);

    Get.testMode = true;
    Get.put(IMController());
    final logic = Get.put(CollectionListLogic(autoLoad: false));
    logic.medals.assignAll([
      CollectionMedal(
        id: 'm1',
        name: '摸鱼勋章',
        description: '认真摸鱼',
        type: '神话',
        display: true,
        imageUrl: 'https://fishpi.cn/images/favicon.png',
        rawMetal: _metal(),
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
    expect(find.text('神话'), findsOneWidget);
    expect(find.byType(MedalWidget), findsOneWidget);
    expect(
      find.byKey(const ValueKey('medal_effect_mythic_m1')),
      findsOneWidget,
    );
    expect(find.text('取消展示'), findsOneWidget);
  });
}

Future<void> _pumpMedalWidget(
  WidgetTester tester, {
  required String level,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Center(
        child: MedalWidget(
          medal: _metal(),
          level: level,
        ),
      ),
    ),
  );
  await tester.pump();
}

void _ignoreNetworkImageErrors() {
  final oldOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    if (details.exception is NetworkImageLoadException) return;
    oldOnError?.call(details);
  };
  addTearDown(() => FlutterError.onError = oldOnError);
}

Metal _metal() {
  return Metal(
    attr: MetalAttr(
      url: 'https://fishpi.cn/images/favicon.png',
      backcolor: 'F0D35E',
      fontcolor: '18191F',
    ),
    name: '摸鱼勋章',
    description: '认真摸鱼',
    data: 'm1',
    enable: 'true',
  );
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
