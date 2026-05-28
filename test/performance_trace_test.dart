import 'package:fishpi_app/core/debug/performance_trace.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(PerformanceTrace.resetForTest);

  test('性能标记会记录启动、闪屏和首页可交互耗时', () {
    PerformanceTrace.startApp();
    PerformanceTrace.setMarkForTest(
      'splash_visible',
      const Duration(milliseconds: 420),
    );
    PerformanceTrace.setMarkForTest(
      'home_interactive',
      const Duration(milliseconds: 1800),
    );

    final snapshot = PerformanceTrace.snapshot();

    expect(snapshot['app_start'], Duration.zero);
    expect(snapshot['splash_visible'], const Duration(milliseconds: 420));
    expect(snapshot['home_interactive'], const Duration(milliseconds: 1800));
    expect(
      PerformanceTrace.startupSummary(),
      '性能验收[启动] 冷启动到闪屏: 420ms, 首页可交互: 1800ms',
    );
  });

  test('缺失性能标记时摘要显示未记录', () {
    PerformanceTrace.startApp();

    expect(
      PerformanceTrace.startupSummary(),
      '性能验收[启动] 冷启动到闪屏: 未记录, 首页可交互: 未记录',
    );
  });
}
