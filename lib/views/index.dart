import 'package:fishpi_app/router/app_router.dart';
import 'package:fishpi_app/utils/util.dart';
import 'package:fishpi_app/views/chat.dart';
import 'package:fishpi_app/views/circle.dart';
import 'package:fishpi_app/views/post.dart';
import 'package:fishpi_app/views/user.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:get/get.dart';

import '../utils/event.dart';
import '../utils/event_bus.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  bool isLogin = false;
  int currentIndex = 0;

  final List<Widget> tabBarBodyItems = [
    ChatPage(),
    PostPage(),
    CirclePage(),
    UserPage()
  ];

  @override
  void initState() {
    super.initState();

    tabController = TabController(vsync: this, length: 4)
      ..addListener(() {
        setState(() {
          currentIndex = tabController.index;
        });
      });

    EventBusManager.eventBus.on<LoginEvent>().listen((event) {
      setState(() {
        isLogin = event.isLogin;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: CurvedNavigationBar(
          color: const Color.fromRGBO(236, 212, 99, 1),
          height: 50,
          backgroundColor: Colors.white,
          animationDuration: const Duration(milliseconds: 300),
          index: currentIndex,
          items: const <Widget>[
            Icon(
              Icons.chat,
              size: 30,
              color: Colors.white,
            ),
            Icon(
              Icons.find_in_page,
              size: 30,
              color: Colors.white,
            ),
            Icon(
              Icons.person,
              size: 30,
              color: Colors.white,
            ),
            Icon(
              Icons.settings,
              size: 30,
              color: Colors.white,
            ),
          ],
          onTap: (index) {
            //Handle button tap
            setState(() {
              currentIndex = index;
            });
            tabController.animateTo(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.ease,
            );
          },
        ),
        body: TabBarView(
          controller: tabController,
          children: tabBarBodyItems,
        ));
  }
}