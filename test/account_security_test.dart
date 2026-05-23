import 'package:fishpi/types/user.dart';
import 'package:fishpi_app/core/account/account_service.dart';
import 'package:fishpi_app/core/controller/im.dart';
import 'package:fishpi_app/pages/mine/account/account_logic.dart';
import 'package:fishpi_app/pages/mine/account/account_view.dart';
import 'package:fishpi_app/pages/mine/change_password/change_password_logic.dart';
import 'package:fishpi_app/pages/mine/change_password/change_password_view.dart';
import 'package:fishpi_app/pages/mine/edit_info/edit_info_logic.dart';
import 'package:fishpi_app/pages/mine/edit_info/edit_info_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  tearDown(Get.reset);

  group('账号服务响应解析', () {
    test('code 为 0 时解析成功', () {
      final result = AccountService.parseResponse({'code': 0, 'msg': 'ok'});

      expect(result.success, isTrue);
      expect(result.msg, 'ok');
    });

    test('code 非 0 时抛出服务端消息', () {
      expect(
        () => AccountService.parseResponse({'code': 1, 'msg': '失败'}),
        throwsA('失败'),
      );
    });
  });

  group('资料表单校验', () {
    test('字段长度超限时返回对应错误', () {
      expect(
        EditInfoLogic.validateProfile(
          nickname: 'a' * 21,
          userURL: '',
          intro: '',
          tags: '',
          mbti: '',
        ),
        '昵称不能超过 20 个字符',
      );
      expect(
        EditInfoLogic.validateProfile(
          nickname: '',
          userURL: 'a' * 256,
          intro: '',
          tags: '',
          mbti: '',
        ),
        '个人主页不能超过 255 个字符',
      );
      expect(
        EditInfoLogic.validateProfile(
          nickname: '',
          userURL: '',
          intro: 'a' * 256,
          tags: '',
          mbti: '',
        ),
        '简介不能超过 255 个字符',
      );
      expect(
        EditInfoLogic.validateProfile(
          nickname: '',
          userURL: '',
          intro: '',
          tags: 'a' * 256,
          mbti: '',
        ),
        '标签不能超过 255 个字符',
      );
      expect(
        EditInfoLogic.validateProfile(
          nickname: '',
          userURL: '',
          intro: '',
          tags: '',
          mbti: 'a' * 256,
        ),
        'MBTI 不能超过 255 个字符',
      );
    });

    test('合法资料输入通过校验', () {
      expect(
        EditInfoLogic.validateProfile(
          nickname: '鱼排',
          userURL: 'https://fishpi.cn',
          intro: '摸鱼中',
          tags: 'Flutter',
          mbti: 'INTJ',
        ),
        isNull,
      );
    });
  });

  group('密码表单校验', () {
    test('空旧密码、弱新密码、两次不一致返回错误', () {
      expect(
        ChangePasswordLogic.validatePasswordForm(
          oldPassword: '',
          newPassword: 'abc123',
          confirmPassword: 'abc123',
        ),
        '请输入旧密码',
      );
      expect(
        ChangePasswordLogic.validatePasswordForm(
          oldPassword: 'old123',
          newPassword: 'abcdef',
          confirmPassword: 'abcdef',
        ),
        '新密码需为 6-16 位且包含字母和数字',
      );
      expect(
        ChangePasswordLogic.validatePasswordForm(
          oldPassword: 'old123',
          newPassword: 'abc123',
          confirmPassword: 'abc124',
        ),
        '两次输入的新密码不一致',
      );
    });

    test('合法密码输入通过校验', () {
      expect(
        ChangePasswordLogic.validatePasswordForm(
          oldPassword: 'old123',
          newPassword: 'abc123',
          confirmPassword: 'abc123',
        ),
        isNull,
      );
    });
  });

  testWidgets('账号与安全页能渲染头像区和三项菜单', (tester) async {
    Get.testMode = true;
    Get.put(IMController());
    Get.put(
      AccountLogic(
        autoLoad: false,
        initialUser: _userInfo(),
      ),
    );

    await tester.pumpWidget(_wrap(AccountPage()));
    await tester.pump();

    expect(find.text('账号与安全'), findsOneWidget);
    expect(find.text('鱼排'), findsOneWidget);
    expect(find.text('修改头像'), findsOneWidget);
    expect(find.text('修改用户信息'), findsOneWidget);
    expect(find.text('修改密码'), findsOneWidget);
  });

  testWidgets('编辑资料页能预填用户信息并显示保存按钮', (tester) async {
    Get.testMode = true;
    Get.put(IMController());
    final logic = Get.put(
      EditInfoLogic(
        autoLoad: false,
        initialUser: _userInfo(),
      ),
    );

    await tester.pumpWidget(_wrap(EditInfoPage()));
    await tester.pump();

    expect(find.text('修改用户信息'), findsOneWidget);
    expect(logic.nicknameController.text, '鱼排');
    expect(logic.urlController.text, 'https://fishpi.cn');
    expect(find.text('保存'), findsOneWidget);
  });

  testWidgets('修改密码页能显示三个密码输入框和保存按钮', (tester) async {
    Get.testMode = true;
    Get.put(IMController());
    Get.put(ChangePasswordLogic());

    await tester.pumpWidget(_wrap(ChangePasswordPage()));
    await tester.pump();

    expect(find.byKey(const ValueKey('change_password_old_input')),
        findsOneWidget);
    expect(find.byKey(const ValueKey('change_password_new_input')),
        findsOneWidget);
    expect(find.byKey(const ValueKey('change_password_confirm_input')),
        findsOneWidget);
    expect(find.text('保存'), findsOneWidget);
  });
}

Widget _wrap(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(360, 812),
    builder: (context, _) => GetMaterialApp(home: child),
  );
}

UserInfo _userInfo() {
  return UserInfo(
    oId: '100',
    userNo: '42',
    userName: 'fishpi',
    nickname: '鱼排',
    userURL: 'https://fishpi.cn',
    intro: '摸鱼中',
    avatarURL: '',
  );
}
