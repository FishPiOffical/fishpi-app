import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:web_socket_channel/io.dart';

class WebsocketInfo {
  StreamSubscription steam;
  IOWebSocketChannel ws;
  WebsocketInfo({required this.steam, required this.ws});
}

class Request {
  static const connectTimeout = Duration(seconds: 8);
  static const sendTimeout = Duration(seconds: 10);
  static const receiveTimeout = Duration(seconds: 15);
  static const websocketMaxRetryTimes = 10;
  static const websocketMaxRetryDelay = Duration(seconds: 30);

  static String _domain = 'fishpi.cn';
  static String _protocol = 'https';
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: connectTimeout,
      sendTimeout: sendTimeout,
      receiveTimeout: receiveTimeout,
    ),
  );

  static String _parseUrl(String url, Map<String, dynamic>? params) {
    if (params != null) {
      url = '$url?';
      params.forEach((key, value) {
        if (value != null) url += '$key=$value&';
      });
      url = url.substring(0, url.length - 1);
    }
    return url;
  }

  static Future<T> get<T>(String url, {Map<String, dynamic>? params}) async {
    return request(_parseUrl(url, params), method: 'GET');
  }

  static Future<T> post<T>(String url,
      {Map<String, dynamic>? params, dynamic data}) async {
    return request(_parseUrl(url, params), method: 'POST', data: data);
  }

  static Future<T> delete<T>(String url,
      {Map<String, dynamic>? params, dynamic data}) async {
    return request(_parseUrl(url, params), method: 'DELETE', data: data);
  }

  static Future<T> put<T>(String url,
      {Map<String, dynamic>? params, dynamic data}) async {
    return request(_parseUrl(url, params), method: 'PUT', data: data);
  }

  static Future<T> request<T>(String url, {method, data}) async {
    try {
      var response = await _dio.request(
        '$_protocol://$_domain/$url',
        data: data,
        options: Options(
          method: method,
          validateStatus: (_) => true,
        ),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          if (response.data is Map) {
            return response.data;
          } else {
            try {
              return json.decode(response.data);
            } catch (e) {
              return response.data;
            }
          }
        } catch (e) {
          return Future.error('解析响应数据异常');
        }
      } else if (response.statusCode == 401) {
        return Future.error('401');
      } else {
        return Future.error('服务器响应异常(${response.statusCode ?? '未知'})');
      }
    } on DioException catch (e) {
      return Future.error(friendlyError(e));
    } catch (e) {
      return Future.error(friendlyError(e));
    }
  }

  static String friendlyError(Object error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return '网络连接超时，请检查网络后重试';
        case DioExceptionType.connectionError:
          return '网络连接失败，请检查网络后重试';
        case DioExceptionType.badCertificate:
          return '网络证书异常，请稍后重试';
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          if (statusCode == 401) return '401';
          return '服务器响应异常(${statusCode ?? '未知'})';
        case DioExceptionType.cancel:
          return '请求已取消';
        case DioExceptionType.unknown:
          return _friendlyUnknownError(error.error ?? error);
      }
    }
    return _friendlyUnknownError(error);
  }

  static String _friendlyUnknownError(Object error) {
    if (error is SocketException) {
      return '网络连接失败，请检查网络后重试';
    }
    if (error is TimeoutException) {
      return '网络连接超时，请检查网络后重试';
    }
    final raw = error.toString();
    if (raw.contains('Failed host lookup') ||
        raw.contains('SocketException') ||
        raw.contains('Network is unreachable') ||
        raw.contains('Connection refused')) {
      return '网络连接失败，请检查网络后重试';
    }
    if (raw.contains('timed out') || raw.contains('TimeoutException')) {
      return '网络连接超时，请检查网络后重试';
    }
    return raw;
  }

  static Duration websocketRetryDelay(
    int retryTimes, {
    Duration baseDelay = const Duration(seconds: 1),
    Duration maxDelay = websocketMaxRetryDelay,
  }) {
    final safeRetryTimes = retryTimes < 0 ? 0 : retryTimes;
    final multiplier = 1 << safeRetryTimes.clamp(0, 5);
    final delay = baseDelay * multiplier;
    return delay > maxDelay ? maxDelay : delay;
  }

  static WebsocketInfo connect(
    String url, {
    Map? params,
    required void Function(dynamic msg) onMessage,
    void Function(dynamic error, IOWebSocketChannel ws)? onError,
    void Function(IOWebSocketChannel ws)? onClose,
  }) {
    if (params != null) {
      url = '$url?';
      params.forEach((key, value) {
        url += '$key=$value&';
      });
      url = url.substring(0, url.length - 1);
    }

    url = url.startsWith('ws')
        ? url
        : '${_protocol == 'https' ? 'wss' : 'ws'}://$_domain/$url';

    var ws = IOWebSocketChannel.connect(
      url,
      connectTimeout: connectTimeout,
    );
    // 连接失败时 web_socket_channel 会同时让 ready Future 进入 error。
    // SDK 以前只监听了 stream.onError，ready 的错误会变成未捕获异常。
    ws.ready.catchError((error) {
      if (onError != null) onError(error, ws);
      ws.sink.close();
    });
    return WebsocketInfo(
      steam: ws.stream.listen(
        (message) async {
          var msg = message;
          try {
            msg = json.decode(msg);
            // ignore: empty_catches
          } catch (e) {}
          onMessage(msg);
        },
        onDone: onClose == null ? null : () => onClose(ws),
        onError: onError == null ? null : (error) => onError(error, ws),
      ),
      ws: ws,
    );
  }

  static Future<FormData> formData(String key,
      {Map<String, dynamic>? src, List<String>? files, String? value}) async {
    src ??= {};
    if (files != null) {
      src[key] = await Future.wait(files.map((filePath) async {
        return await MultipartFile.fromFile(filePath);
      }));
    } else {
      src[key] = value;
    }
    return FormData.fromMap(src);
  }

  static setDomain({required String domain, protocol = 'https'}) {
    _domain = domain;
    _protocol = protocol;
  }

  static get origin => '$_protocol://$_domain';

  static get domain => _domain;
}
