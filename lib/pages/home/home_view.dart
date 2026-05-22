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

class HomePage extends StatelessWidget {
  final HomeLogic logic = Get.find<HomeLogic>();

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: PiTitleBar.home(
          title: [
            '聊天',
            '帖子',
            '清风明月',
            '我的',
          ][logic.index.value],
        ),
        body: PageView(
          controller: logic.pageController,
          onPageChanged: logic.onPageChanged,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            ConversationPage(),
            ForumPage(),
            BreezemoonsPage(),
            MinePage(),
          ],
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
