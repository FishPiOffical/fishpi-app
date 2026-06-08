import 'package:fishpi/fishpi.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('MembershipConfig 只序列化非空字段', () {
    final config = MembershipConfig(
      color: '#FFAA00',
      bold: true,
      underline: false,
    );

    expect(config.toJson(), {
      'color': '#FFAA00',
      'underline': false,
      'bold': true,
    });
  });

  test('MembershipUserConfig 可以解析 configJson', () {
    final item = MembershipUserConfig.from({
      'userId': '100',
      'configJson':
          '{"color":"#00AA66","bold":true,"underline":true,"autoCheckin":1}',
    });

    expect(item.userId, '100');
    expect(item.config?.color, '#00AA66');
    expect(item.config?.bold, isTrue);
    expect(item.config?.underline, isTrue);
    expect(item.config?.autoCheckin, 1);
  });

  test('VIP 套餐和会员信息缺字段时安全兜底', () {
    final level = MembershipLevel.from({
      'oId': '9',
      'lvCode': 'VIP_YEAR',
      'price': '1200',
    });
    final info = MembershipInfo.from({
      'state': '1',
      'configJson': '{"bold":true}',
    });

    expect(level.oId, 9);
    expect(level.lvName, isEmpty);
    expect(level.price, 1200);
    expect(info.state, 1);
    expect(info.lvCode, isEmpty);
    expect(info.configJson, '{"bold":true}');
  });

  test('账号资料更新参数保留服务端字段名', () {
    final params = UpdateUserParams(
      userNickname: '鱼排',
      userTags: 'Flutter',
      userURL: 'https://fishpi.cn',
      userIntro: '摸鱼中',
      mbti: 'INTJ',
    );

    expect(params.toJson(), {
      'userNickname': '鱼排',
      'userTags': 'Flutter',
      'userURL': 'https://fishpi.cn',
      'userIntro': '摸鱼中',
      'mbti': 'INTJ',
    });
  });
}
