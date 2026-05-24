import 'package:fishpi/types/user.dart';
import 'package:fishpi_app/core/controller/im.dart';
import 'package:fishpi_app/core/manager/toast.dart';
import 'package:fishpi_app/core/medal/medal_service.dart';
import 'package:fishpi_app/pages/mine/mine_logic.dart';
import 'package:get/get.dart';

import '../../../utils/pi_utils.dart';

class CollectionListLogic extends GetxController {
  CollectionListLogic({
    MedalService? medalService,
    this.autoLoad = true,
  }) : medalService = medalService ?? MedalService();

  final MedalService medalService;
  final bool autoLoad;
  final imController = Get.find<IMController>();

  final medals = <CollectionMedal>[].obs;
  final updatingMedalIds = <String>{}.obs;
  final isLoading = false.obs;
  final apikey = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadArgumentMedals();
    apikey.value = _currentApiKey();
    if (autoLoad) {
      loadMedals();
    }
  }

  Future<void> loadMedals() async {
    final token = _currentApiKey();
    if (token.isEmpty) return;

    isLoading.value = true;
    try {
      final remoteMedals = await medalService.listMyMedals(apiKey: token);
      if (remoteMedals.isNotEmpty) {
        medals.assignAll(_mergeWithRawMedals(remoteMedals));
        return;
      }
      await _loadUserInfoFallback();
    } catch (e) {
      if (medals.isEmpty) {
        await _loadUserInfoFallback();
      }
      ToastManager.showToast('加载勋章失败：$e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleDisplay(CollectionMedal medal) async {
    if (medal.id.isEmpty || updatingMedalIds.contains(medal.id)) return;
    final token = _currentApiKey();
    if (token.isEmpty) {
      ToastManager.showToast('请先登录后再操作');
      return;
    }

    final nextDisplay = !medal.display;
    updatingMedalIds.add(medal.id);
    try {
      await medalService.updateDisplay(
        apiKey: token,
        medalId: medal.id,
        display: nextDisplay,
      );
      _updateLocalDisplay(medal.id, nextDisplay);
      await _refreshMineUserInfo();
      ToastManager.showToast(nextDisplay ? '已展示勋章' : '已卸下勋章');
    } catch (e) {
      ToastManager.showToast(e.toString());
    } finally {
      updatingMedalIds.remove(medal.id);
    }
  }

  bool isUpdating(CollectionMedal medal) {
    return updatingMedalIds.contains(medal.id);
  }

  void _loadArgumentMedals() {
    final args = Get.arguments;
    if (args is! Map) return;
    final rawMedals = args['metals'];
    if (rawMedals is List<CollectionMedal>) {
      medals.assignAll(rawMedals);
      return;
    }
    if (rawMedals is List<Metal>) {
      medals.assignAll(rawMedals.map(CollectionMedal.fromMetal));
    }
  }

  Future<void> _loadUserInfoFallback() async {
    final info = await imController.fishpi.user.info(false);
    _syncMineUserInfo(info);
    final ownedMedals =
        info.allMetals.isNotEmpty ? info.allMetals : info.sysMetal;
    medals.assignAll(ownedMedals.map(CollectionMedal.fromMetal));
  }

  Future<void> _refreshMineUserInfo() async {
    if (imController.fishpi.token.isEmpty) return;
    final info = await imController.fishpi.user.info(false);
    _syncMineUserInfo(info);
  }

  void _syncMineUserInfo(UserInfo info) {
    if (Get.isRegistered<MineLogic>()) {
      Get.find<MineLogic>().userInfo.value = info;
    }
  }

  void _updateLocalDisplay(String medalId, bool display) {
    final index = medals.indexWhere((item) => item.id == medalId);
    if (index < 0) return;
    medals[index] = medals[index].copyWith(display: display);
  }

  List<CollectionMedal> _mergeWithRawMedals(
      List<CollectionMedal> remoteMedals) {
    final rawMedals = <String, Metal>{};
    for (final medal in medals) {
      _putRawMedal(rawMedals, medal.rawMetal);
    }

    final cachedInfo = imController.fishpi.user.current;
    for (final medal in cachedInfo.allMetals) {
      _putRawMedal(rawMedals, medal);
    }
    for (final medal in cachedInfo.sysMetal) {
      _putRawMedal(rawMedals, medal);
    }

    if (Get.isRegistered<MineLogic>()) {
      final mineInfo = Get.find<MineLogic>().userInfo.value;
      for (final medal in mineInfo.allMetals) {
        _putRawMedal(rawMedals, medal);
      }
      for (final medal in mineInfo.sysMetal) {
        _putRawMedal(rawMedals, medal);
      }
    }

    return remoteMedals.map((medal) {
      final rawMetal = rawMedals[_metalKey(medal.id)] ??
          rawMedals[_metalKey(medal.name)] ??
          medal.rawMetal;
      return medal.copyWith(rawMetal: rawMetal);
    }).toList();
  }

  void _putRawMedal(Map<String, Metal> rawMedals, Metal? medal) {
    if (medal == null) return;
    final keys = [
      medal.data,
      medal.name,
    ].map(_metalKey).where((key) => key.isNotEmpty);
    for (final key in keys) {
      rawMedals.putIfAbsent(key, () => medal);
    }
  }

  String _metalKey(String value) => value.trim().toLowerCase();

  String _currentApiKey() {
    final token = imController.fishpi.token.isNotEmpty
        ? imController.fishpi.token
        : PiUtils.getString('token');
    apikey.value = token;
    return token;
  }
}
