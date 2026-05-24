import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:web_socket_channel/io.dart';

class WebsocketInfo {
  StreamSubscription steam;
  IOWebSocketChannel ws;
  WebsocketInfo({required this.steam, required this.ws});
}

class Request {
  static String _domain = 'fishpi.cn';
  static String _protocol = 'https';
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
      var dio = Dio();
      var response = await dio.request('$_protocol://$_domain/$url',
          data: data, options: Options(method: method));
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
        return Future.error('HTTP错误');
      }
    } catch (e) {
      return Future.error(e);
    }
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

    var ws = IOWebSocketChannel.connect(url);
    // 连接失败时 web_socket_channel 会同时让 ready Future 进入 error。
    // SDK 以前只监听了 stream.onError，ready 的错误会变成未捕获异常。
    ws.ready.catchError((error) {
      if (onError != null) onError(error, ws);
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
        onDone: onClose == null
            ? () => print('WebSocket disconnected')
            : () => onClose(ws),
        onError: onError == null
            ? (error) => print('WebSocket error: $error')
            : (error) => onError(error, ws),
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
