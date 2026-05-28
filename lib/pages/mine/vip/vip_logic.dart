import 'package:fishpi/fishpi.dart';
import 'package:fishpi_app/core/controller/im.dart';
import 'package:fishpi_app/core/manager/toast.dart';
import 'package:fishpi_app/core/network/app_error_message.dart';
import 'package:fishpi_app/core/vip/vip_style_service.dart';
import 'package:fishpi_app/pages/mine/mine_logic.dart';
import 'package:get/get.dart';

typedef VipStatusInfoLoader = Future<UserVipInfo> Function(String userId);
typedef VipUserInfoLoader = Future<UserInfo> Function();

class VipLogic extends GetxController {
  VipLogic({
    VipStatusInfoLoader? vipInfoLoader,
    VipUserInfoLoader? userInfoLoader,
    UserInfo? initialUser,
    UserVipInfo? initialVipInfo,
    DateTime Function()? nowProvider,
    this.autoLoad = true,
  })  : _vipInfoLoader = vipInfoLoader,
        _userInfoLoader = userInfoLoader,
        nowProvider = nowProvider ?? DateTime.now,
        userInfo = (initialUser ?? UserInfo()).obs,
        profile = Rxn<VipProfile>(
          initialVipInfo == null
              ? null
              : VipProfile.fromVipInfo(initialVipInfo),
        );

  final VipStatusInfoLoader? _vipInfoLoader;
  final VipUserInfoLoader? _userInfoLoader;
  final DateTime Function() nowProvider;
  final bool autoLoad;

  final Rx<UserInfo> userInfo;
  final Rxn<VipProfile> profile;
  final isLoading = false.obs;
  final errorText = ''.obs;

  IMController? get _imController =>
      Get.isRegistered<IMController>() ? Get.find<IMController>() : null;

  bool get hasProfile => profile.value != null;

  bool get isVipActive {
    final current = profile.value;
    if (current == null) return false;
    return VipNameStyle.fromVipInfo(
      current.info,
      now: nowProvider(),
    ).isActive;
  }

  String get statusText {
    final current = profile.value;
    if (current == null) {
      return errorText.value.isNotEmpty ? '加载失败' : '未开通';
    }
    if (isVipActive) return '已开通';
    if (current.info.state) return '已过期';
    return '未开通';
  }

  String get levelText {
    final current = profile.value;
    if (current == null || !current.info.state) return '暂无会员等级';
    return current.levelName;
  }

  String get expiresText {
    final current = profile.value;
    if (current == null || !current.info.state) return '暂无到期时间';
    if (current.expiresText.isEmpty) return '长期有效';
    return '${current.expiresText} 到期';
  }

  String get previewName {
    final current = userInfo.value;
    if (current.name.trim().isNotEmpty) return current.name.trim();
    if (current.userName.trim().isNotEmpty) return current.userName.trim();
    return '摸鱼派用户';
  }

  String get colorText {
    final color = profile.value?.info.color.trim() ?? '';
    return color.isEmpty ? '未设置' : color;
  }

  String get boldText => profile.value?.info.bold == true ? '已开启' : '未开启';

  String get underlineText =>
      profile.value?.info.underline == true ? '已开启' : '未开启';

  String get autoCheckinText {
    final value = profile.value?.info.autoCheckin ?? 0;
    return value == 1 ? '已开启' : '未开启';
  }

  bool get jointVip => profile.value?.info.jointVip == true;

  bool get medalEnabled => profile.value?.info.metal == true;

  @override
  void onInit() {
    super.onInit();
    if (autoLoad) {
      loadVipInfo(silent: true);
    }
  }

  Future<void> loadVipInfo({bool silent = false}) async {
    if (isLoading.value) return;
    isLoading.value = true;
    errorText.value = '';
    try {
      final info = await _loadUserInfo();
      userInfo.value = info;
      final userId = info.oId.trim();
      if (userId.isEmpty) {
        throw '用户信息不完整，无法查询 VIP 状态';
      }

      final vipInfo = await _loadVipInfo(userId);
      profile.value = VipProfile.fromVipInfo(vipInfo);
      if (!silent) ToastManager.showToast('VIP状态已刷新');
    } catch (e) {
      final message = AppErrorMessage.friendly(e, fallback: 'VIP信息加载失败');
      errorText.value = message;
      if (!silent) ToastManager.showToast(message);
    } finally {
      isLoading.value = false;
    }
  }

  Future<UserInfo> _loadUserInfo() async {
    final customLoader = _userInfoLoader;
    if (customLoader != null) return customLoader();

    if (Get.isRegistered<MineLogic>()) {
      final current = Get.find<MineLogic>().userInfo.value;
      if (current.oId.trim().isNotEmpty) return current;
    }

    final im = _imController;
    final cached = im?.fishpi.user.current;
    if (cached != null && cached.oId.trim().isNotEmpty) return cached;
    final loaded = await im?.fishpi.user.info(false);
    return loaded ?? UserInfo();
  }

  Future<UserVipInfo> _loadVipInfo(String userId) {
    final customLoader = _vipInfoLoader;
    if (customLoader != null) return customLoader(userId);
    final im = _imController;
    if (im == null) return Future.error('登录状态不可用');
    return im.fishpi.vipInfo(userId);
  }
}
