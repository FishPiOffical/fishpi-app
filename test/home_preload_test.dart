import 'package:fake_async/fake_async.dart';
import 'package:fishpi_app/pages/home/home_logic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('首页内容流按延迟分级预加载', () {
    fakeAsync((async) {
      var forumPreloadCount = 0;
      var breezemoonsPreloadCount = 0;
      final logic = HomeLogic(
        forumPreloadDelay: const Duration(milliseconds: 600),
        breezemoonsPreloadDelay: const Duration(milliseconds: 1200),
        forumPreloader: () => forumPreloadCount++,
        breezemoonsPreloader: () => breezemoonsPreloadCount++,
      );

      logic.scheduleDeferredTabPreload();
      async.elapse(const Duration(milliseconds: 599));

      expect(forumPreloadCount, 0);
      expect(breezemoonsPreloadCount, 0);

      async.elapse(const Duration(milliseconds: 1));
      expect(forumPreloadCount, 1);
      expect(breezemoonsPreloadCount, 0);

      async.elapse(const Duration(milliseconds: 600));
      expect(forumPreloadCount, 1);
      expect(breezemoonsPreloadCount, 1);

      logic.onClose();
    });
  });

  test('用户先切到内容 Tab 时立即抢占预加载且不重复触发', () {
    fakeAsync((async) {
      var forumPreloadCount = 0;
      var breezemoonsPreloadCount = 0;
      final logic = HomeLogic(
        forumPreloadDelay: const Duration(milliseconds: 600),
        breezemoonsPreloadDelay: const Duration(milliseconds: 1200),
        forumPreloader: () => forumPreloadCount++,
        breezemoonsPreloader: () => breezemoonsPreloadCount++,
      );

      logic.scheduleDeferredTabPreload();
      logic.onPageChanged(1);

      expect(logic.index.value, 1);
      expect(forumPreloadCount, 1);
      expect(breezemoonsPreloadCount, 0);

      async.elapse(const Duration(seconds: 2));

      expect(forumPreloadCount, 1);
      expect(breezemoonsPreloadCount, 1);

      logic.onPageChanged(2);
      expect(breezemoonsPreloadCount, 1);

      logic.onClose();
    });
  });
}
