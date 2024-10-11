import 'package:fishpi/fishpi.dart';
import 'package:fishpi_app/core/controller/im.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/manager/toast.dart';
import '../../../widgets/pi_transfer.dart';
import '../../../widgets/pop_route.dart';

class UserPanelLogic extends GetxController {
  final imController = Get.find<IMController>();
  final isLoading = false.obs;
  final userName = ''.obs;
  final userInfo = UserInfo().obs;
  final tabIndex = 0.obs;

  final userArticles = <ArticleDetail>[].obs;
  final userBreezemoons = <BreezemoonContent>[].obs;

  @override
  void onInit() {
    var args = Get.arguments;
    userName.value = args['userName'] ?? '';
    getUserInfo();
    super.onInit();
  }

  void getUserInfo() async {
    isLoading.value = true;
    userInfo.value = await imController.fishpi.getUser(userName.value);
    print(userInfo.toJson());
    isLoading.value = false;
    getUserArticles();
    getUserBreezemoons();
  }

  void getUserArticles() async {
    ArticleList res = await imController.fishpi.article.listByUser(
      user: userName.value,
      page: 1,
      size: 15,
    );
    userArticles.value = res.list;
    print(res);
  }

  void getUserBreezemoons() async {
    List<BreezemoonContent> res = await imController.fishpi.breezemoon.list(
      user: userName.value,
      page: 1,
      size: 15,
    );
    userBreezemoons.value = res;
  }

  void toFollow() async {
    ResponseResult res = await imController.fishpi.user.follow(
      userInfo.value.oId,
      follow: userInfo.value.canFollow == 'yes',
    );
    if (userInfo.value.canFollow == 'yes') {
      userInfo.value.canFollow = 'no';
    } else {
      userInfo.value.canFollow = 'yes';
    }
    print('success: ${res.success},msg: ${res.msg}');
    userInfo.refresh();
  }

  void toTransfer() {
    Navigator.push(
      Get.context!,
      PopRoute(
        child: PiTransferPage(
            user: userInfo.value.userName,
            onEditingCompleteText: (text) async {
              String context = text;
              if (context.trim() == '') {
                return;
              } else {
                int point;
                try {
                  point = int.parse(context);
                } catch (e) {
                  ToastManager.showToast('请输入数字');
                  return;
                }
                ResponseResult res = await imController.fishpi.user.transfer(
                  userInfo.value.userName,
                  point,
                  '',
                );
                if (res.success) {
                  ToastManager.showToast('转账成功');
                } else {
                  ToastManager.showToast(res.msg);
                }
              }
            }),
      ),
    );
  }

  void toChat() {}

  void toSetLabel() {}

  void changeTab(int idx) {
    tabIndex.value = idx;
  }
}
