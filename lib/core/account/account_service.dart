import 'package:dio/dio.dart';
import 'package:fishpi/fishpi.dart';
import 'package:fishpi_app/core/network/api_config.dart';
import 'package:fishpi_app/core/network/api_response_parser.dart';

class AccountProfileInput {
  final String nickname;
  final String tags;
  final String userURL;
  final String intro;
  final String mbti;

  const AccountProfileInput({
    this.nickname = '',
    this.tags = '',
    this.userURL = '',
    this.intro = '',
    this.mbti = '',
  });

  Map<String, dynamic> toJson(String apiKey) {
    return {
      'apiKey': apiKey,
      'userNickname': nickname.trim(),
      'userTags': tags.trim(),
      'userURL': userURL.trim(),
      'userIntro': intro.trim(),
      'mbti': mbti.trim(),
    };
  }
}

class AccountService {
  AccountService({
    Dio? dio,
    this.baseUrl = ApiConfig.baseUrl,
  }) : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 8),
                sendTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 15),
              ),
            );

  final Dio _dio;
  final String baseUrl;

  static ResponseResult parseResponse(dynamic data) =>
      ApiResponseParser.parse(data);

  Future<ResponseResult> updateProfile({
    required Fishpi fishpi,
    required AccountProfileInput input,
  }) async {
    final response = await _post(
      '/settings/profiles',
      data: input.toJson(fishpi.token),
    );
    await fishpi.user.info(false);
    return parseResponse(response);
  }

  Future<ResponseResult> updatePassword({
    required Fishpi fishpi,
    required String oldPassword,
    required String newPassword,
  }) async {
    final response = await _post(
      '/settings/password',
      data: {
        'apiKey': fishpi.token,
        'userPassword': _passwordMd5(oldPassword),
        'userNewPassword': _passwordMd5(newPassword),
      },
    );
    return parseResponse(response);
  }

  Future<String> uploadAvatar({
    required Fishpi fishpi,
    required String filePath,
  }) async {
    final result = await fishpi.upload([filePath]);
    if (result.success.isEmpty) {
      throw result.errs.isEmpty ? '头像上传失败' : result.errs.join('，');
    }
    return result.success.first.url;
  }

  Future<ResponseResult> updateAvatar({
    required Fishpi fishpi,
    required String avatarURL,
  }) async {
    final response = await _post(
      '/settings/avatar',
      data: {
        'apiKey': fishpi.token,
        'userAvatarURL': avatarURL,
      },
    );
    await fishpi.user.info(false);
    return parseResponse(response);
  }

  Future<dynamic> _post(String path,
      {required Map<String, dynamic> data}) async {
    // 设置页接口目前没有被 fishpi SDK 封装，按开放 API 文档使用 JSON 请求体。
    try {
      final response = await _dio.post(
        '$baseUrl$path',
        data: data,
        options: Options(
          contentType: Headers.jsonContentType,
          headers: {'Accept': Headers.jsonContentType},
        ),
      );
      return response.data;
    } on DioException catch (e) {
      throw _friendlyDioError(e);
    }
  }

  String _passwordMd5(String password) {
    // 复用 SDK 登录数据的加密逻辑，避免本地维护另一套 MD5 实现。
    return LoginData(passwd: password).toJson()['userPassword'] as String;
  }

  String _friendlyDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return '网络连接超时，请检查网络后重试';
      case DioExceptionType.connectionError:
        return '网络连接失败，请检查网络后重试';
      case DioExceptionType.badResponse:
        return '服务器响应异常(${error.response?.statusCode ?? '未知'})';
      case DioExceptionType.cancel:
        return '请求已取消';
      case DioExceptionType.badCertificate:
        return '网络证书异常，请稍后重试';
      case DioExceptionType.unknown:
        return '网络异常，请稍后重试';
    }
  }
}
