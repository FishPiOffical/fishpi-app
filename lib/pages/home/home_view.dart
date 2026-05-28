import 'package:fishpi_app/core/debug/performance_trace.dart';
import 'package:fishpi_app/pages/breezemoons/breezemoons_view.dart';
import 'package:fishpi_app/pages/mine/mine_view.dart';
import 'package:fishpi_app/res/styles.dart';
import 'package:fishpi_app/widgets/pi_title_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/pi_bottom_bar.dart';
import '../conversation/conversation_view.dart';
import '../forum/forum_view.dart';
import 'home_logic.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const List<String> _titles = [
    '聊天',
    '帖子',
    '清风明月',
    '我的',
  ];

  final HomeLogic logic = Get.find<HomeLogic>();
  late final List<Widget> _pages = [
    ConversationPage(),
    ForumPage(),
    BreezemoonsPage(),
    MinePage(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PerformanceTrace.markHomeInteractive();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: PiTitleBar.home(
          title: _titles[logic.index.value],
        ),
        body: PageView(
          controller: logic.pageController,
          onPageChanged: logic.onPageChanged,
          physics: const NeverScrollableScrollPhysics(),
          children: _pages,
        ),
        bottomNavigationBar: Container(
          color: Styles.primaryColor,
          child: SafeArea(
            child: PiBottomBar(
              callback: logic.changeIndex,
              index: logic.index.value,
            ),
          ),
        ),
      ),
    );
  }
}
