import 'package:dio/dio.dart';
import 'package:fishpi/fishpi.dart';

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
    this.baseUrl = 'https://fishpi.cn',
  }) : _dio = dio ?? Dio();

  final Dio _dio;
  final String baseUrl;

  static ResponseResult parseResponse(dynamic data) {
    if (data is! Map) {
      throw '响应数据异常';
    }

    final response = Map<String, dynamic>.from(data);
    final code = response['code'];
    final result = ResponseResult(
      success: code == 0 || code == '0' || code == null,
      msg: response['msg']?.toString() ?? '',
    );
    if (!result.success) {
      throw result.msg.isEmpty ? '操作失败' : result.msg;
    }
    return result;
  }

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
    // 设置页接口目前没有被 fishpi SDK 封装，这里按网页端表单提交方式调用。
    final response = await _dio.post(
      '$baseUrl$path',
      data: data,
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    return response.data;
  }

  String _passwordMd5(String password) {
    // 复用 SDK 登录数据的加密逻辑，避免本地维护另一套 MD5 实现。
    return LoginData(passwd: password).toJson()['userPassword'] as String;
  }
}
