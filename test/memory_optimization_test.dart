import 'package:cached_network_image/cached_network_image.dart';
import 'package:fishpi_app/core/memory/memory_limits.dart';
import 'package:fishpi_app/core/memory/memory_list_utils.dart';
import 'package:fishpi_app/widgets/pi_avatar.dart';
import 'package:fishpi_app/widgets/pi_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';

void main() {
  test('内容列表超过上限时保留前面的最新数据', () {
    final source = List.generate(200, (index) => index);

    final result = MemoryListUtils.keepFirst(
      source,
      MemoryLimits.contentListItems,
    );

    expect(result, hasLength(MemoryLimits.contentListItems));
    expect(result.first, 0);
    expect(result.last, MemoryLimits.contentListItems - 1);
  });

  testWidgets('PiImage 会传递解码尺寸并使用轻量静态占位', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const PiImage(
          imgUrl: 'https://example.com/a.png',
          width: 100,
          height: 80,
        ),
      ),
    );

    final image = tester.widget<CachedNetworkImage>(
      find.byType(CachedNetworkImage),
    );

    expect(image.memCacheWidth, isNotNull);
    expect(image.memCacheHeight, isNotNull);
    expect(image.memCacheWidth,
        lessThanOrEqualTo(MemoryLimits.imageDecodeMaxPixels));
    expect(find.byType(Lottie), findsNothing);
  });

  testWidgets('PiAvatar 会按头像展示尺寸传递解码尺寸', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const PiAvatar(
          userName: 'fish',
          avatarURL: 'https://example.com/avatar.png',
          width: 40,
          height: 40,
        ),
      ),
    );

    final avatar = tester.widget<CachedNetworkImage>(
      find.byType(CachedNetworkImage),
    );

    expect(avatar.memCacheWidth, isNotNull);
    expect(avatar.memCacheHeight, isNotNull);
    expect(avatar.memCacheWidth,
        lessThanOrEqualTo(MemoryLimits.imageDecodeMaxPixels));
  });
}

Widget _wrap(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(360, 812),
    builder: (context, _) => MaterialApp(home: Scaffold(body: child)),
  );
}
