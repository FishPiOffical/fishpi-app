import 'dart:io';

import 'package:fishpi_app/core/sql/user_remark.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('user_remark_test_');
    Hive.init(tempDir.path);
  });

  setUp(() async {
    await UserRemark.init();
    await UserRemark.clear();
  });

  tearDownAll(() async {
    await UserRemark.dispose();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('用户备注优先于原昵称显示', () async {
    await UserRemark.setRemark(
      userName: 'fishpi',
      remark: '摸鱼搭子',
    );

    expect(
      UserRemark.displayName('fishpi', fallback: '鱼排(fishpi)'),
      '摸鱼搭子',
    );
  });

  test('空备注会清除并回退原昵称', () async {
    await UserRemark.setRemark(userName: 'fishpi', remark: '摸鱼搭子');
    await UserRemark.setRemark(userName: 'fishpi', remark: ' ');

    expect(UserRemark.remarkOf('fishpi'), isEmpty);
    expect(
      UserRemark.displayName('fishpi', fallback: '鱼排(fishpi)'),
      '鱼排(fishpi)',
    );
  });
}
