/// 摸鱼派服务端地址集中配置。
///
/// 各处的 baseUrl / WebSocket 地址统一引用这里，便于切换测试环境与维护。
class ApiConfig {
  ApiConfig._();

  /// HTTP 接口根地址。
  static const String baseUrl = 'https://fishpi.cn';

  /// 文件存储域名（头像、图片等）。
  static const String fileBaseUrl = 'https://file.fishpi.cn';

  /// 扫码登录 WebSocket 地址。
  static const String loginWsUrl = 'wss://fishpi.cn/login-channel';

  /// 隐私政策页地址。
  static String get privacyUrl => '$baseUrl/privacy';

  /// 网页端登录/找回密码地址。
  static String get loginPageUrl => '$baseUrl/login';
}
