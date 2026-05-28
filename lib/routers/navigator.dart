import 'package:fishpi/types/user.dart';
import 'package:fishpi_app/widgets/pi_scan.dart';
import 'package:fishpi_app/widgets/pi_scan_result.dart';
import 'package:get/get.dart';
import 'pages.dart';

class AppNavigator {
  AppNavigator._();

  static void startLogin() {
    Get.offAllNamed(AppRoutes.login);
  }

  /// 注册
  static void toRegister() => Get.toNamed(AppRoutes.register);

  static void closeAllToHome() {
    Get.offAllNamed(AppRoutes.home);
  }

  /// 通知中心
  static void toNotice() => Get.toNamed(AppRoutes.notice);

  static void toForumDetail({String? oId}) => Get.toNamed(
        AppRoutes.forumDetail,
        arguments: {
          "oId": oId,
        },
        preventDuplicates: false,
      );

  static void toChat({
    isGroup = false,
    String? userName,
    String? userID,
  }) =>
      Get.toNamed(
        AppRoutes.chat,
        arguments: {
          "isGroup": isGroup,
          "userName": userName,
          "userID": userID,
        },
      );

  /// 聊天室设置
  static void toChatRoomSettings() => Get.toNamed(AppRoutes.chatRoomSettings);

  /// 自动抢红包设置
  static void toChatRoomAutoGrabSettings() =>
      Get.toNamed(AppRoutes.chatRoomAutoGrabSettings);

  /// 聊天室扩展插件
  static void toChatRoomExtensions() =>
      Get.toNamed(AppRoutes.chatRoomExtensions);

  /// 聊天室屏蔽名单
  static void toChatRoomBlockList() => Get.toNamed(AppRoutes.chatRoomBlockList);

  /// 设置页面
  static void toForumCreate() => Get.toNamed(AppRoutes.forumCreate);

  /// 设置页面
  static void toSetting() => Get.toNamed(AppRoutes.setUp);

  /// 关于
  static void toAboutUs() => Get.toNamed(AppRoutes.about);

  /// 黑名单
  static void toBlackList() => Get.toNamed(AppRoutes.blackList);

  /// 意见反馈
  static void toFeedback() => Get.toNamed(AppRoutes.feedback);

  /// 投诉
  static void toComplaint() => Get.toNamed(AppRoutes.complaint);

  /// 典藏馆
  static void toCollection(List<Metal> metals) =>
      Get.toNamed(AppRoutes.collection, arguments: {"metals": metals});

  /// 账号与安全
  static void toAccount() => Get.toNamed(AppRoutes.account);

  /// 修改用户信息
  static void toEditInfo() => Get.toNamed(AppRoutes.editInfo);

  /// 修改密码
  static void toChangePassword() => Get.toNamed(AppRoutes.changePassword);

  /// VIP会员
  static void toVip() => Get.toNamed(AppRoutes.vip);

  /// Ta人主页
  static void toUserPanel({String? userName}) => Get.toNamed(
        AppRoutes.userPanel,
        arguments: {
          "userName": userName,
        },
        preventDuplicates: false,
      );

  /// 扫码页面
  static void toScan() => Get.to(
        () => const PiScan(),
        transition: Transition.cupertino,
        popGesture: true,
      );

  /// 扫码结果页面
  static void toScanResult(String result) => Get.off(
        () => PiScanResult(result),
        transition: Transition.cupertino,
        popGesture: true,
      );
}
