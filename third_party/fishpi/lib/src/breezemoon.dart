import 'package:fishpi/fishpi.dart';
import 'package:fishpi/src/request.dart';

/// 清风明月接口
class Breezemoon {
  String token = '';

  Breezemoon([String? token]) {
    this.token = token ?? this.token;
  }

  /// 获取清风明月列表
  ///
  /// - `page` 消息页码
  /// - `size` 每页个数
  Future<List<BreezemoonContent>> list({int page = 1, int size = 20, String? user}) async {
    try {
      var rsp = await Request.get('api/${user != null && user.isNotEmpty ? "user/$user/" : ""}breezemoons',
          params: {'p': page, 'size': size, 'apiKey': token});

      if (rsp['code'] != 0) return Future.error(rsp['msg']);

      rsp = rsp['data'] ?? rsp;

      return List.from(rsp['breezemoons']).map((e) => BreezemoonContent.from(e)).toList();
    } catch (e) {
      return Future.error(e);
    }
  }

  /// 发送清风明月
  ///
  /// [content] 内容
  Future<ResponseResult> send(String content) async {
    try {
      var rsp = await Request.post('breezemoon', data: {'apiKey': token, 'breezemoonContent': content});

      return ResponseResult.from(rsp);
    } catch (e) {
      return Future.error(e);
    }
  }
}
