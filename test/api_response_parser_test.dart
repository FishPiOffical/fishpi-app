import 'package:fishpi/fishpi.dart';
import 'package:fishpi_app/core/account/account_service.dart';
import 'package:fishpi_app/core/medal/medal_service.dart';
import 'package:fishpi_app/core/network/api_response_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiResponseParser', () {
    test('code 为 0 解析成功', () {
      final result = ApiResponseParser.parse({'code': 0, 'msg': 'ok'});
      expect(result.success, isTrue);
      expect(result.msg, 'ok');
    });

    test('code 为字符串 0 解析成功', () {
      final result = ApiResponseParser.parse({'code': '0'});
      expect(result.success, isTrue);
    });

    test('缺失 code 字段按成功处理', () {
      final result = ApiResponseParser.parse({'data': []});
      expect(result.success, isTrue);
    });

    test('code 非 0 抛出服务端消息', () {
      expect(
        () => ApiResponseParser.parse({'code': 1, 'msg': '失败'}),
        throwsA('失败'),
      );
    });

    test('code 非 0 且无消息时抛出兜底文案', () {
      expect(
        () => ApiResponseParser.parse({'code': -1}),
        throwsA('操作失败'),
      );
    });

    test('非 Map 响应抛出数据异常', () {
      expect(
        () => ApiResponseParser.parse('not a map'),
        throwsA('响应数据异常'),
      );
    });

    test('account 与 medal 服务复用同一解析约定', () {
      final ResponseResult viaAccount =
          AccountService.parseResponse({'code': 0, 'msg': 'a'});
      final ResponseResult viaMedal =
          MedalService.parseResponse({'code': 0, 'msg': 'm'});
      expect(viaAccount.success, isTrue);
      expect(viaMedal.success, isTrue);
    });
  });
}
