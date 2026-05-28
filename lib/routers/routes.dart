part of 'pages.dart';

abstract class AppRoutes {
  static const notFound = '/not-found';
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const notice = '/notice';
  static const conversation = '/conversation';
  static const chat = '/chat';
  static const chatRoomSettings = '/chat_room_settings';
  static const chatRoomAutoGrabSettings = '/chat_room_settings/auto_grab';
  static const chatRoomExtensions = '/chat_room_settings/extensions';
  static const chatRoomBlockList = '/chat_room_settings/block_list';
  static const userPanel = '/user_panel';
  static const forum = '/forum';
  static const forumDetail = '/forum_detail';
  static const forumCreate = '/forum_create';
  static const breezemoons = '/breezemoons';
  static const mine = '/mine';
  static const editInfo = '/edit_info';
  static const changePassword = '/change_password';
  static const vip = '/vip';
  static const setUp = '/set_up';
  static const about = '/about';
  static const blackList = '/black_list';
  static const complaint = '/complaint';
  static const feedback = '/feedback';
  static const account = '/account';
  static const collection = '/collection';
}

extension RoutesExtension on String {
  String toRoute() => '/${toLowerCase()}';
}
