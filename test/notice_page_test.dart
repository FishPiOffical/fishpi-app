import 'package:fishpi/fishpi.dart';
import 'package:fishpi_app/pages/notice/notice_logic.dart';
import 'package:fishpi_app/pages/notice/notice_view.dart';
import 'package:fishpi_app/widgets/pi_title_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  setUp(() {
    Get.testMode = true;
  });

  tearDown(() async {
    if (Get.isRegistered<NoticeLogic>()) {
      await Get.delete<NoticeLogic>(force: true);
    }
    Get.reset();
  });

  testWidgets('通知页能渲染分类、未读状态和空态', (tester) async {
    final logic = Get.put(NoticeLogic(autoLoad: false));
    logic.noticeCount.value = NoticeCount(
      notifyStatus: true,
      count: 2,
      reply: 0,
      point: 1,
      at: 1,
      broadcast: 0,
      sysAnnounce: 0,
      newFollower: 0,
      following: 0,
      commented: 0,
    );

    await tester.pumpWidget(_wrap(const NoticePage()));
    await tester.pump();

    expect(find.byType(PiTitleBar), findsOneWidget);
    expect(find.text('通知消息'), findsOneWidget);
    expect(find.byKey(const ValueKey('notice_summary_card')), findsOneWidget);
    expect(find.text('还有 2 条未读消息'), findsOneWidget);
    expect(find.byKey(const ValueKey('notice_category_tabs')), findsOneWidget);
    expect(find.text('积分'), findsOneWidget);
    expect(find.text('@'), findsOneWidget);
    expect(find.byKey(const ValueKey('notice_empty_state')), findsOneWidget);
    expect(find.byKey(const ValueKey('notice_mark_all_read_button')),
        findsOneWidget);
  });

  test('回复通知和未知通知可以转为展示项', () {
    final reply = NoticeDisplayItem.from(
      NoticeType.reply,
      NoticeComment.from({
        'oId': 'reply-1',
        'replyArticleTitle': '帖子标题',
        'replyAuthorName': 'someone',
        'replyContent': '<p>收到</p>',
        'replySharpURL': 'https://fishpi.cn/article/1636516552191#comment-1',
        'commentArticleType': 99,
      }),
    );
    final unknown = NoticeDisplayItem.from(
      NoticeType.system,
      NoticeUnknown.from({
        'oId': 'unknown-1',
        'title': '新通知',
        'content': '<p>未知内容</p>',
      }),
    );

    expect(reply.title, 'someone 回复了你');
    expect(reply.vipUserName, 'someone');
    expect(reply.titleAction, '回复了你');
    expect(reply.content, '帖子标题：收到');
    expect(reply.targetArticleId, '1636516552191');
    expect(reply.targetUserName, 'someone');
    expect(unknown.title, '新通知');
    expect(unknown.vipUserName, isEmpty);
    expect(unknown.content, '未知内容');
  });

  test('通知展示项可以从链接或内容提取跳转目标', () {
    final follow = NoticeDisplayItem.from(
      NoticeType.following,
      NoticeFollow.from({
        'oId': 'follow-1',
        'url': '/article/1736516552191',
        'authorName': 'author',
        'articleTitle': '关注的文章',
      }),
    );
    final at = NoticeDisplayItem.from(
      NoticeType.at,
      NoticeAt.from({
        'oId': 'at-1',
        'userName': 'friend',
        'content': '<a href="/article/1836516552191">提到你</a>',
      }),
    );

    expect(follow.targetArticleId, '1736516552191');
    expect(follow.targetUserName, 'author');
    expect(at.targetArticleId, '1836516552191');
    expect(at.targetUserName, 'friend');
  });
}

Widget _wrap(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(360, 812),
    builder: (context, _) => GetMaterialApp(home: child),
  );
}
