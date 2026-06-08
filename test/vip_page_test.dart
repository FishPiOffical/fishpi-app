import 'package:fishpi/fishpi.dart';
import 'package:fishpi_app/pages/mine/vip/vip_logic.dart';
import 'package:fishpi_app/pages/mine/vip/vip_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  tearDown(Get.reset);

  test('VIP 页面逻辑可以加载当前用户会员状态', () async {
    final logic = VipLogic(
      autoLoad: false,
      userInfoLoader: () async => _userInfo(),
      vipInfoLoader: (_) async => _vipInfo(),
      nowProvider: () => DateTime(2026, 5, 28),
    );

    await logic.loadVipInfo(silent: true);

    expect(logic.statusText, '已开通');
    expect(logic.levelText, 'VIP(包年)');
    expect(logic.expiresText, '2026-08-09 到期');
    expect(logic.colorText, '#FFAA00');
    expect(logic.boldText, '已开启');
    expect(logic.underlineText, '已开启');
  });

  testWidgets('VIP 页面展示会员状态和昵称样式', (tester) async {
    Get.put(
      VipLogic(
        autoLoad: false,
        initialUser: _userInfo(),
        initialVipInfo: _vipInfo(),
        initialMembershipLevels: [_membershipLevel()],
        nowProvider: () => DateTime(2026, 5, 28),
      ),
    );

    await tester.pumpWidget(_wrap(VipPage()));
    await tester.pump();

    expect(find.text('VIP会员'), findsOneWidget);
    expect(find.byKey(const ValueKey('vip_status_card')), findsOneWidget);
    expect(find.text('已开通'), findsOneWidget);
    expect(find.text('VIP(包年)'), findsOneWidget);
    expect(find.text('2026-08-09 到期'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('vip_membership_levels_card')),
      findsOneWidget,
    );
    expect(find.text('基础版 · VIP_YEAR'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('vip_name_style_card')),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();
    expect(find.byKey(const ValueKey('vip_name_style_card')), findsOneWidget);
    expect(find.text('#FFAA00'), findsOneWidget);
    expect(find.text('已开启'), findsWidgets);

    final preview = tester.widget<Text>(find.text('鱼排'));
    expect(preview.style?.color, const Color(0xFFFFAA00));
    expect(preview.style?.fontWeight, FontWeight.w800);
    expect(preview.style?.decoration, TextDecoration.underline);
  });

  testWidgets('VIP 页面展示 VIP4 默认渐变昵称样式', (tester) async {
    Get.put(
      VipLogic(
        autoLoad: false,
        initialUser: _userInfo(),
        initialVipInfo: _vipInfo(lvCode: 'VIP4_YEAR', color: ''),
        nowProvider: () => DateTime(2026, 5, 28),
      ),
    );

    await tester.pumpWidget(_wrap(VipPage()));
    await tester.pump();

    expect(find.text('VIP4(包年)'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('vip_name_style_card')),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();
    expect(find.text('VIP4渐变'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('vip_name_preview_gradient_mask')),
      findsOneWidget,
    );

    final swatch = tester
        .widget<Container>(find.byKey(const ValueKey('vip_color_swatch')));
    final decoration = swatch.decoration as BoxDecoration;
    expect(decoration.gradient, isNotNull);
  });

  testWidgets('VIP 页面展示未开通状态和开通后可编辑入口', (tester) async {
    Get.put(
      VipLogic(
        autoLoad: false,
        initialUser: _userInfo(),
        initialVipInfo: UserVipInfo(state: false),
        nowProvider: () => DateTime(2026, 5, 28),
      ),
    );

    await tester.pumpWidget(_wrap(VipPage()));
    await tester.pump();

    expect(find.text('未开通'), findsOneWidget);
    expect(find.text('暂无会员等级'), findsOneWidget);
    expect(find.text('暂无到期时间'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -320));
    await tester.pump();
    expect(find.byKey(const ValueKey('vip_edit_style_button')), findsOneWidget);
    expect(find.text('开通后可编辑'), findsOneWidget);
  });

  testWidgets('VIP 页面可以打开样式编辑并保存配置', (tester) async {
    Get.testMode = true;
    MembershipConfig? savedConfig;
    Get.put(
      VipLogic(
        autoLoad: false,
        initialUser: _userInfo(),
        initialVipInfo: _vipInfo(),
        nowProvider: () => DateTime(2026, 5, 28),
        membershipConfigSaver: (config) async {
          savedConfig = config;
          return ResponseResult(success: true, msg: 'ok');
        },
        vipInfoLoader: (_) async => _vipInfo(color: '#00AA66'),
        userInfoLoader: () async => _userInfo(),
      ),
    );

    await tester.pumpWidget(_wrap(VipPage()));
    await tester.pump();

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('vip_edit_style_button')),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('vip_edit_style_button')));
    await tester.pumpAndSettle();

    expect(
        find.byKey(const ValueKey('vip_style_editor_sheet')), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('vip_style_color_input')),
      '#00AA66',
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('vip_style_underline_switch')));
    await tester.pump();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('vip_style_save_button')),
      160,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('vip_style_save_button')));
    await tester.pumpAndSettle();

    expect(savedConfig?.color, '#00AA66');
    expect(savedConfig?.bold, isTrue);
    expect(savedConfig?.underline, isFalse);
    expect(savedConfig?.metal, isTrue);
    expect(savedConfig?.autoCheckin, 1);
    expect(find.byKey(const ValueKey('vip_style_editor_sheet')), findsNothing);
  });

  test('VIP 购买成功后会刷新状态', () async {
    Get.testMode = true;
    var openedId = 0;
    var loadCount = 0;
    final logic = VipLogic(
      autoLoad: false,
      userInfoLoader: () async => _userInfo(),
      vipInfoLoader: (_) async {
        loadCount++;
        return _vipInfo();
      },
      membershipOpener: (oId) async {
        openedId = oId;
        return ResponseResult(success: true);
      },
    );

    await logic.openMembership(_membershipLevel(), requireConfirm: false);

    expect(openedId, 9);
    expect(loadCount, 1);
  });
}

Widget _wrap(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(360, 812),
    builder: (context, _) => GetMaterialApp(
      home: child,
      builder: EasyLoading.init(),
    ),
  );
}

UserInfo _userInfo() {
  return UserInfo(
    oId: '100',
    userNo: '42',
    userName: 'fishpi',
    nickname: '鱼排',
    avatarURL: '',
  );
}

UserVipInfo _vipInfo({
  String lvCode = 'VIP_YEAR',
  String color = '#FFAA00',
}) {
  return UserVipInfo(
    state: true,
    userId: '100',
    lvCode: lvCode,
    expiresAt: DateTime(2026, 8, 9).millisecondsSinceEpoch,
    color: color,
    bold: true,
    underline: true,
    autoCheckin: 1,
    jointVip: true,
    metal: true,
  );
}

MembershipLevel _membershipLevel() {
  return MembershipLevel(
    oId: 9,
    lvCode: 'VIP_YEAR',
    lvName: '基础版',
    price: 1200,
    durationType: '年卡',
    benefits: '["昵称样式","自动签到"]',
  );
}
