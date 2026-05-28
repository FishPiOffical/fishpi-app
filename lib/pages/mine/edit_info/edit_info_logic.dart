import 'package:fishpi/types/user.dart';
import 'package:fishpi_app/core/account/account_service.dart';
import 'package:fishpi_app/core/controller/im.dart';
import 'package:fishpi_app/core/manager/toast.dart';
import 'package:fishpi_app/core/network/app_error_message.dart';
import 'package:fishpi_app/pages/mine/account/account_logic.dart';
import 'package:fishpi_app/pages/mine/mine_logic.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditInfoLogic extends GetxController {
  EditInfoLogic({
    AccountService? accountService,
    UserInfo? initialUser,
    this.autoLoad = true,
  })  : accountService = accountService ?? AccountService(),
        _initialUser = initialUser;

  final AccountService accountService;
  final UserInfo? _initialUser;
  final bool autoLoad;

  final imController = Get.find<IMController>();
  final nicknameController = TextEditingController();
  final urlController = TextEditingController();
  final introController = TextEditingController();
  final tagsController = TextEditingController();
  final mbtiController = TextEditingController();

  final isLoading = false.obs;
  final isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (_initialUser != null) {
      fillUserInfo(_initialUser!);
    } else if (autoLoad) {
      loadUserInfo();
    }
  }

  Future<void> loadUserInfo() async {
    final cached = imController.fishpi.user.current;
    if (cached.userName.isNotEmpty) {
      fillUserInfo(cached);
    }
    if (imController.fishpi.token.isEmpty) return;

    isLoading.value = true;
    try {
      final info = await imController.fishpi.user.info(false);
      fillUserInfo(info);
      _syncUserInfo(info);
    } catch (e) {
      ToastManager.showToast(
        AppErrorMessage.friendly(e, fallback: '加载用户信息失败'),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void fillUserInfo(UserInfo info) {
    nicknameController.text = info.nickname;
    urlController.text = info.userURL;
    introController.text = info.intro;
  }

  static String? validateProfile({
    required String nickname,
    required String userURL,
    required String intro,
    required String tags,
    required String mbti,
  }) {
    if (nickname.trim().length > 20) return '昵称不能超过 20 个字符';
    if (userURL.trim().length > 255) return '个人主页不能超过 255 个字符';
    if (intro.trim().length > 255) return '简介不能超过 255 个字符';
    if (tags.trim().length > 255) return '标签不能超过 255 个字符';
    if (mbti.trim().length > 255) return 'MBTI 不能超过 255 个字符';

    final url = userURL.trim();
    if (url.isNotEmpty) {
      final uri = Uri.tryParse(url);
      if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
        return '个人主页请输入完整链接';
      }
      if (uri.scheme != 'http' && uri.scheme != 'https') {
        return '个人主页仅支持 http/https';
      }
    }
    return null;
  }

  Future<void> submit() async {
    if (isSaving.value) return;

    final error = validateProfile(
      nickname: nicknameController.text,
      userURL: urlController.text,
      intro: introController.text,
      tags: tagsController.text,
      mbti: mbtiController.text,
    );
    if (error != null) {
      ToastManager.showToast(error);
      return;
    }

    isSaving.value = true;
    ToastManager.show(content: '保存中...');
    try {
      await accountService.updateProfile(
        fishpi: imController.fishpi,
        input: AccountProfileInput(
          nickname: nicknameController.text,
          userURL: urlController.text,
          intro: introController.text,
          tags: tagsController.text,
          mbti: mbtiController.text,
        ),
      );
      final info = await imController.fishpi.user.info();
      _syncUserInfo(info);
      ToastManager.dismiss();
      ToastManager.showToast('用户信息已更新');
      Get.back();
    } catch (e) {
      ToastManager.dismiss();
      ToastManager.showToast(
        AppErrorMessage.friendly(e, fallback: '保存用户信息失败'),
      );
    } finally {
      isSaving.value = false;
    }
  }

  void _syncUserInfo(UserInfo info) {
    if (Get.isRegistered<MineLogic>()) {
      Get.find<MineLogic>().userInfo.value = info;
    }
    if (Get.isRegistered<AccountLogic>()) {
      Get.find<AccountLogic>().userInfo.value = info;
    }
  }

  @override
  void onClose() {
    nicknameController.dispose();
    urlController.dispose();
    introController.dispose();
    tagsController.dispose();
    mbtiController.dispose();
    super.onClose();
  }
}
