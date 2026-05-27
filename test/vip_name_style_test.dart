import 'dart:io';

import 'package:fishpi/fishpi.dart';
import 'package:fishpi_app/core/sql/user_remark.dart';
import 'package:fishpi_app/core/vip/vip_style_service.dart';
import 'package:fishpi_app/widgets/vip_name_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('vip_name_style_test_');
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

  test('VIP 样式会解析颜色、粗体和下划线', () {
    final style = VipNameStyle.fromVipInfo(
      UserVipInfo(
        state: true,
        expiresAt:
            DateTime.now().add(const Duration(days: 1)).millisecondsSinceEpoch,
        color: '#FF3366',
        bold: true,
        underline: true,
      ),
    );

    final merged = style.mergeInto(const TextStyle(color: Colors.black));

    expect(style.isActive, isTrue);
    expect(merged.color, const Color(0xFFFF3366));
    expect(merged.fontWeight, FontWeight.w800);
    expect(merged.decoration, TextDecoration.underline);
  });

  test('非 VIP 或已过期会员不污染原始样式', () {
    final expired = VipNameStyle.fromVipInfo(
      UserVipInfo(
        state: true,
        expiresAt: DateTime.now()
            .subtract(const Duration(days: 1))
            .millisecondsSinceEpoch,
        color: '#FF3366',
        bold: true,
        underline: true,
      ),
    );

    const base = TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.w400,
    );

    expect(expired.isActive, isFalse);
    expect(expired.mergeInto(base), base);
    expect(VipNameStyle.parseColor('不是颜色'), isNull);
  });

  test('同一用户 ID 在缓存期内只请求一次 VIP 信息', () async {
    var requestCount = 0;
    final service = VipStyleService(
      vipInfoLoader: (userId) async {
        requestCount++;
        return UserVipInfo(
          state: true,
          expiresAt: DateTime.now()
              .add(const Duration(days: 1))
              .millisecondsSinceEpoch,
          color: '3366FF',
        );
      },
    );

    final first = await service.load(userId: 'u1');
    final second = await service.load(userId: 'u1');

    expect(first?.color, const Color(0xFF3366FF));
    expect(second?.color, const Color(0xFF3366FF));
    expect(requestCount, 1);
  });

  test('缺少用户 ID 时会用用户名解析用户后再查询 VIP', () async {
    var userRequestCount = 0;
    var vipRequestCount = 0;
    final service = VipStyleService(
      userLoader: (userName) async {
        userRequestCount++;
        return UserInfo(oId: 'u2', userName: userName);
      },
      vipInfoLoader: (userId) async {
        vipRequestCount++;
        return UserVipInfo(
          state: true,
          expiresAt: DateTime.now()
              .add(const Duration(days: 1))
              .millisecondsSinceEpoch,
          underline: true,
        );
      },
    );

    final first = await service.load(userName: 'fishpi');
    final second = await service.load(userName: 'fishpi');

    expect(first?.underline, isTrue);
    expect(second?.underline, isTrue);
    expect(userRequestCount, 1);
    expect(vipRequestCount, 1);
  });

  testWidgets('VipNameText 保留备注优先，并应用 VIP 样式', (tester) async {
    await tester.runAsync(
      () => UserRemark.setRemark(userName: 'fishpi', remark: '摸鱼搭子'),
    );

    final service = VipStyleService(
      vipInfoLoader: (_) async {
        return UserVipInfo(
          state: true,
          expiresAt: DateTime.now()
              .add(const Duration(days: 1))
              .millisecondsSinceEpoch,
          color: '#00AA66',
          bold: true,
          underline: true,
        );
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: VipNameText(
            userId: 'u1',
            userName: 'fishpi',
            fallback: '鱼排(fishpi)',
            vipService: service,
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));

    final text = tester.widget<Text>(find.text('摸鱼搭子'));
    expect(text.style?.color, const Color(0xFF00AA66));
    expect(text.style?.fontWeight, FontWeight.w800);
    expect(text.style?.decoration, TextDecoration.underline);
  });

  testWidgets('VipNameText 请求失败时显示普通昵称', (tester) async {
    final service = VipStyleService(
      vipInfoLoader: (_) async => Future.error('网络错误'),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: VipNameText(
            userId: 'u1',
            userName: 'fishpi',
            fallback: '鱼排(fishpi)',
            vipService: service,
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));

    final text = tester.widget<Text>(find.text('鱼排(fishpi)'));
    expect(text.style?.color, Colors.black);
    expect(text.style?.decoration, isNull);
  });
}
