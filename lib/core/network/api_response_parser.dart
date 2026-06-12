import 'package:fishpi/fishpi.dart';

/// 摸鱼派开放 API 统一响应解析。
///
/// account/medal 等未被 SDK 封装的设置类接口共用这套约定：HTTP 200 且响应体
/// 是 `{code, msg, data}` 结构，`code == 0` 视为成功。dio 在非 2xx 时已抛
/// 异常，因此进入这里的都是 200 响应。
class ApiResponseParser {
  ApiResponseParser._();

  /// 解析响应体并在失败时抛出服务端消息。
  ///
  /// 兼容部分直接返回 data 而不带 code 包装的接口：缺失 code 时按成功处理，
  /// 与历史行为保持一致。
  static ResponseResult parse(dynamic data) {
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
}
