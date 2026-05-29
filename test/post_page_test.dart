import 'package:fishpi_app/core/controller/im.dart';
import 'package:fishpi_app/pages/forum/post/post_logic.dart';
import 'package:fishpi_app/pages/forum/post/post_view.dart';
import 'package:fishpi_app/widgets/pi_title_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  setUp(() {
    Get.testMode = true;
    Get.put(IMController());
  });

  tearDown(() async {
    if (Get.isRegistered<PostLogic>()) {
      await Get.delete<PostLogic>(force: true);
    }
    if (Get.isRegistered<IMController>()) {
      await Get.delete<IMController>(force: true);
    }
    Get.reset();
  });

  test('发帖草稿校验覆盖标题、标签长度和正文', () {
    final logic = Get.put(PostLogic());

    expect(logic.validateDraft(), '请输入帖子标题');

    logic.titleController.text = '标题';
    expect(logic.validateDraft(), '请输入帖子内容');

    logic.tagController.text = 'a' * (PostLogic.maxTagsLength + 1);
    expect(logic.validateDraft(), '标签不能超过 ${PostLogic.maxTagsLength} 字');
  });

  testWidgets('发帖页渲染正式标题、输入区和发布按钮', (tester) async {
    Get.put(PostLogic());

    await tester.pumpWidget(_wrap(const PostPage()));
    await tester.pump();

    expect(find.byType(PiTitleBar), findsOneWidget);
    expect(find.text('发布帖子'), findsOneWidget);
    expect(find.byKey(const ValueKey('post_title_input')), findsOneWidget);
    expect(find.byKey(const ValueKey('post_tag_input')), findsOneWidget);
    expect(find.byKey(const ValueKey('post_content_editor')), findsOneWidget);
    expect(find.byKey(const ValueKey('post_submit_button')), findsOneWidget);
    expect(find.text('发帖(简易版)'), findsNothing);
  });
}

Widget _wrap(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(360, 812),
    builder: (context, _) => GetMaterialApp(home: child),
  );
}
