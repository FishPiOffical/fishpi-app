import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fishpi/src/request.dart' as fishpi_request;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('网络稳定性工具', () {
    test('Dio 超时和连接错误会转成友好文案', () {
      final requestOptions = RequestOptions(path: '/api/test');

      expect(
        fishpi_request.Request.friendlyError(
          DioException(
            requestOptions: requestOptions,
            type: DioExceptionType.connectionTimeout,
          ),
        ),
        '网络连接超时，请检查网络后重试',
      );
      expect(
        fishpi_request.Request.friendlyError(
          DioException(
            requestOptions: requestOptions,
            type: DioExceptionType.connectionError,
          ),
        ),
        '网络连接失败，请检查网络后重试',
      );
      expect(
        fishpi_request.Request.friendlyError(
          const SocketException('Failed host lookup'),
        ),
        '网络连接失败，请检查网络后重试',
      );
    });

    test('WebSocket 重连使用秒级指数退避并限制最大间隔', () {
      expect(
        fishpi_request.Request.websocketRetryDelay(-1),
        const Duration(seconds: 1),
      );
      expect(
        fishpi_request.Request.websocketRetryDelay(0),
        const Duration(seconds: 1),
      );
      expect(
        fishpi_request.Request.websocketRetryDelay(1),
        const Duration(seconds: 2),
      );
      expect(
        fishpi_request.Request.websocketRetryDelay(4),
        const Duration(seconds: 16),
      );
      expect(
        fishpi_request.Request.websocketRetryDelay(8),
        fishpi_request.Request.websocketMaxRetryDelay,
      );
    });
  });
}
