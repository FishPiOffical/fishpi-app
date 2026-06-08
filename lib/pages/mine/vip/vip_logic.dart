import 'package:fishpi/fishpi.dart';
import 'package:fishpi_app/core/controller/im.dart';
import 'package:fishpi_app/core/manager/toast.dart';
import 'package:fishpi_app/core/network/app_error_message.dart';
import 'package:fishpi_app/core/vip/vip_style_service.dart';
import 'package:fishpi_app/pages/mine/mine_logic.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

typedef VipStatusInfoLoader = Future<UserVipInfo> Function(String userId);
typedef VipUserInfoLoader = Future<UserInfo> Function();
typedef VipMembershipLevelsLoader = Future<List<MembershipLevel>> Function();
typedef VipMembershipOpener = Future<ResponseResult> Function(int oId);
typedef VipMembershipConfigSaver = Future<ResponseResult> Function(
  MembershipConfig config,
);

class VipLogic extends GetxController {
  VipLogic({
    VipStatusInfoLoader? vipInfoLoader,
    VipUserInfoLoader? userInfoLoader,
    VipMembershipLevelsLoader? membershipLevelsLoader,
    VipMembershipOpener? membershipOpener,
    VipMembershipConfigSaver? membershipConfigSaver,
    UserInfo? initialUser,
    UserVipInfo? initialVipInfo,
    List<MembershipLevel>? initialMembershipLevels,
    DateTime Function()? nowProvider,
    this.autoLoad = true,
  })  : _vipInfoLoader = vipInfoLoader,
        _userInfoLoader = userInfoLoader,
        _membershipLevelsLoader = membershipLevelsLoader,
        _membershipOpener = membershipOpener,
        _membershipConfigSaver = membershipConfigSaver,
        nowProvider = nowProvider ?? DateTime.now,
        userInfo = (initialUser ?? UserInfo()).obs,
        profile = Rxn<VipProfile>(
          initialVipInfo == null
              ? null
              : VipProfile.fromVipInfo(initialVipInfo),
        ),
        membershipLevels = (initialMembershipLevels ?? <MembershipLevel>[]).obs;

  final VipStatusInfoLoader? _vipInfoLoader;
  final VipUserInfoLoader? _userInfoLoader;
  final VipMembershipLevelsLoader? _membershipLevelsLoader;
  final VipMembershipOpener? _membershipOpener;
  final VipMembershipConfigSaver? _membershipConfigSaver;
  final DateTime Function() nowProvider;
  final bool autoLoad;

  final Rx<UserInfo> userInfo;
  final Rxn<VipProfile> profile;
  final RxList<MembershipLevel> membershipLevels;
  final isLoading = false.obs;
  final isLoadingLevels = false.obs;
  final isSavingConfig = false.obs;
  final isOpeningMembership = false.obs;
  final errorText = ''.obs;
  final levelsErrorText = ''.obs;
  final editColor = ''.obs;
  final editBold = false.obs;
  final editUnderline = false.obs;
  final editMetal = false.obs;
  final editAutoCheckin = false.obs;
  final TextEditingController editColorController = TextEditingController();

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
    final current = profile.value;
    if (current == null) return '未设置';

    final style = VipNameStyle.fromVipInfo(
      current.info,
      now: nowProvider(),
    );
    final rawColor = current.info.color.trim();
    if (style.hasGradient) {
      return VipNameStyle.parseGradientColors(rawColor).isEmpty
          ? 'VIP4渐变'
          : rawColor;
    }

    final color = rawColor;
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

  bool get canEditStyle => isVipActive;

  String get editButtonText => canEditStyle ? '编辑昵称样式' : '开通后可编辑';

  VipNameStyle get editingPreviewStyle {
    final current = profile.value?.info;
    return VipNameStyle.fromVipInfo(
      UserVipInfo(
        state: true,
        lvCode: current?.lvCode ?? 'VIP',
        expiresAt: current?.expiresAt ?? 0,
        color: editColor.value,
        bold: editBold.value,
        underline: editUnderline.value,
      ),
      now: nowProvider(),
    );
  }

  @override
  void onInit() {
    super.onInit();
    _syncEditStateFromProfile();
    if (autoLoad) {
      loadVipInfo(silent: true);
    }
  }

  @override
  void onClose() {
    editColorController.dispose();
    super.onClose();
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
      _syncEditStateFromProfile();
      await loadMembershipLevels(silent: true);
      if (!silent) _showToast('VIP状态已刷新');
    } catch (e) {
      final message = AppErrorMessage.friendly(e, fallback: 'VIP信息加载失败');
      errorText.value = message;
      if (!silent) _showToast(message);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMembershipLevels({bool silent = false}) async {
    if (isLoadingLevels.value) return;
    isLoadingLevels.value = true;
    levelsErrorText.value = '';
    try {
      final loader = _membershipLevelsLoader;
      final im = _imController;
      if (loader == null && im == null) return;
      final levels = await (loader ?? im!.fishpi.user.getMembershipLevels)();
      membershipLevels.assignAll(levels);
    } catch (e) {
      final message = AppErrorMessage.friendly(e, fallback: 'VIP套餐加载失败');
      levelsErrorText.value = message;
      if (!silent) _showToast(message);
    } finally {
      isLoadingLevels.value = false;
    }
  }

  void prepareEditConfig() {
    _syncEditStateFromProfile();
  }

  void updateEditColor(String value) {
    editColor.value = value.trim();
  }

  Future<bool> saveMembershipConfig() async {
    if (!canEditStyle || isSavingConfig.value) return false;
    isSavingConfig.value = true;
    try {
      final config = MembershipConfig(
        jointVip: profile.value?.info.jointVip,
        color: editColorController.text.trim(),
        underline: editUnderline.value,
        metal: editMetal.value,
        autoCheckin: editAutoCheckin.value ? 1 : 0,
        bold: editBold.value,
      );
      final result = await _saveMembershipConfig(config);
      if (!result.success) {
        throw result.msg.isEmpty ? 'VIP配置保存失败' : result.msg;
      }
      profile.value = VipProfile.fromVipInfo(_copyVipInfoWithConfig(config));
      _syncEditStateFromProfile();
      VipStyleService.clearSharedCache();
      _showToast('VIP昵称样式已保存');
      await loadVipInfo(silent: true);
      return true;
    } catch (e) {
      final message = AppErrorMessage.friendly(e, fallback: 'VIP配置保存失败');
      _showToast(message);
      return false;
    } finally {
      isSavingConfig.value = false;
    }
  }

  Future<void> openMembership(
    MembershipLevel level, {
    bool requireConfirm = true,
  }) async {
    if (isOpeningMembership.value) return;
    if (requireConfirm && !(await _confirmOpenMembership(level))) return;

    isOpeningMembership.value = true;
    try {
      final result = await _openMembership(level.oId);
      if (!result.success) {
        throw result.msg.isEmpty ? 'VIP开通失败' : result.msg;
      }
      VipStyleService.clearSharedCache();
      _showToast('VIP已开通/续费成功');
      await loadVipInfo(silent: true);
    } catch (e) {
      final message = AppErrorMessage.friendly(e, fallback: 'VIP开通失败');
      _showToast(message);
    } finally {
      isOpeningMembership.value = false;
    }
  }

  String membershipLevelTitle(MembershipLevel level) {
    final name = level.lvName.trim();
    final code = level.lvCode.trim();
    if (name.isNotEmpty && code.isNotEmpty) return '$name · $code';
    if (name.isNotEmpty) return name;
    return code.isEmpty ? 'VIP套餐' : code;
  }

  String membershipLevelMeta(MembershipLevel level) {
    final duration = level.durationType.trim();
    final price = '${level.price} 积分';
    return duration.isEmpty ? price : '$duration · $price';
  }

  String membershipBenefitsText(MembershipLevel level) {
    final raw = level.benefits.trim();
    if (raw.isEmpty) return '以服务端套餐说明为准';
    return raw
        .replaceAll(RegExp(r'[\[\]{}"]'), '')
        .replaceAll(',', ' · ')
        .replaceAll(':', '：')
        .trim();
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

  Future<ResponseResult> _saveMembershipConfig(MembershipConfig config) {
    final customSaver = _membershipConfigSaver;
    if (customSaver != null) return customSaver(config);
    final im = _imController;
    if (im == null) return Future.error('登录状态不可用');
    return im.fishpi.user.configMembership(config);
  }

  Future<ResponseResult> _openMembership(int oId) {
    final customOpener = _membershipOpener;
    if (customOpener != null) return customOpener(oId);
    final im = _imController;
    if (im == null) return Future.error('登录状态不可用');
    return im.fishpi.user.openMembership(oId);
  }

  Future<bool> _confirmOpenMembership(MembershipLevel level) async {
    final result = await Get.dialog<bool>(
      CupertinoAlertDialog(
        title: const Text('确认开通 VIP？'),
        content: Text(
          '将消耗 ${level.price} 积分开通/续费「${membershipLevelTitle(level)}」。',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Get.back(result: false),
            child: const Text('取消'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Get.back(result: true),
            child: const Text('确认'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _syncEditStateFromProfile() {
    final info = profile.value?.info;
    final color = info?.color.trim() ?? '';
    editColorController.text = color;
    editColor.value = color;
    editBold.value = info?.bold == true;
    editUnderline.value = info?.underline == true;
    editMetal.value = info?.metal == true;
    editAutoCheckin.value = (info?.autoCheckin ?? 0) == 1;
  }

  UserVipInfo _copyVipInfoWithConfig(MembershipConfig config) {
    final current = profile.value?.info ?? UserVipInfo();
    return UserVipInfo(
      jointVip: config.jointVip ?? current.jointVip,
      color: config.color ?? current.color,
      underline: config.underline ?? current.underline,
      metal: config.metal ?? current.metal,
      autoCheckin: config.autoCheckin ?? current.autoCheckin,
      bold: config.bold ?? current.bold,
      oId: current.oId,
      state: current.state,
      userId: current.userId,
      lvCode: current.lvCode,
      expiresAt: current.expiresAt,
      createdAt: current.createdAt,
      updatedAt: current.updatedAt,
    );
  }

  void _showToast(String message) {
    if (Get.testMode) return;
    ToastManager.showToast(message);
  }
}
