import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

class AppErrorMessage {
  AppErrorMessage._();

  static String friendly(
    Object error, {
    String fallback = '加载失败',
  }) {
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
          if (statusCode == 401) return '登录状态已失效，请重新登录';
          return '服务器响应异常(${statusCode ?? '未知'})';
        case DioExceptionType.cancel:
          return '请求已取消';
        case DioExceptionType.unknown:
          return _friendlyUnknown(error.error ?? error, fallback: fallback);
      }
    }
    return _friendlyUnknown(error, fallback: fallback);
  }

  static String _friendlyUnknown(
    Object error, {
    required String fallback,
  }) {
    if (error is TypeError) {
      return '数据解析失败，请下拉重试';
    }
    if (error is SocketException) {
      return '网络连接失败，请检查网络后重试';
    }
    if (error is TimeoutException) {
      return '网络连接超时，请检查网络后重试';
    }

    final raw = error
        .toString()
        .replaceFirst('Exception:', '')
        .replaceFirst('Invalid argument(s):', '')
        .trim();
    if (raw.isEmpty) return fallback;
    if (raw == '401') return '登录状态已失效，请重新登录';
    if (raw.contains('网络连接失败') || raw.contains('网络连接超时')) {
      return raw;
    }
    if (raw.contains('Failed host lookup') ||
        raw.contains('SocketException') ||
        raw.contains('Network is unreachable') ||
        raw.contains('Connection refused')) {
      return '网络连接失败，请检查网络后重试';
    }
    if (raw.contains('timed out') || raw.contains('TimeoutException')) {
      return '网络连接超时，请检查网络后重试';
    }
    if (raw.contains('解析响应数据异常') ||
        raw.contains('FormatException') ||
        raw.contains('type') ||
        raw.contains('List') ||
        raw.contains('Map')) {
      return '数据解析失败，请下拉重试';
    }
    if (raw.contains('服务器响应异常')) return raw;
    return '$fallback：$raw';
  }
}
