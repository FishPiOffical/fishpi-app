import 'package:fishpi_app/views/breeze.dart';
import 'package:fishpi_app/views/login.dart';
import 'package:fishpi_app/views/post.dart';
import 'package:fishpi_app/views/user.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

import '../splash_screen.dart';
import '../views/chat.dart';
import '../views/chatroom.dart';
import '../views/index.dart';

abstract class AppRouters {
  static const splash = '/splash';
  static const index = '/index';
  static const chat = '/chat';
  static const post = '/post';
  static const circle = '/circle';
  static const user = '/user';
  static const login = '/login';
  static const chatroom = '/chatroom';

  static final List<GetPage> getPages = [
    GetPage(name: index, page: () => const IndexPage()),
    GetPage(name: splash, page: () => const SplashScreenPage()),
    GetPage(name: chat, page: () => const ChatPage()),
    GetPage(name: post, page: ()=> const PostPage()),
    GetPage(name: circle, page: ()=> const CirclePage()),
    GetPage(name: user, page: ()=> const UserPage()),
    GetPage(name: login, page: ()=> LoginPage()),
    GetPage(name: chatroom, page: ()=> ChatRoomPage()),

  ];
}