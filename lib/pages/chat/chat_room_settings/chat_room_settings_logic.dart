import 'dart:async';

import 'package:fishpi/types/redpacket.dart';
import 'package:fishpi_app/core/chat/chat_red_packet_utils.dart';
import 'package:fishpi_app/core/manager/toast.dart';
import 'package:fishpi_app/core/sql/chat_room_auto_grab_settings.dart';
import 'package:fishpi_app/core/sql/chat_room_block_list.dart';
import 'package:fishpi_app/core/sql/chat_room_extension_store.dart';
import 'package:fishpi_app/core/sql/user_remark.dart';
import 'package:fishpi_app/pages/chat/chat_logic.dart';
import 'package:fishpi_app/widgets/chat/chat_room_extension_editor_sheet.dart';
import 'package:fishpi_app/widgets/pi_editer.dart';
import 'package:fishpi_app/widgets/pop_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ChatRoomSettingsLogic extends GetxController {
  final bool autoLoad;
  final blockedUsers = <ChatRoomBlockedUser>[].obs;
  final recentUsers = <ChatRoomBlockedUser>[].obs;
  final autoGrabConfig = ChatRoomAutoGrabConfig.defaults().obs;
  final extensions = <ChatRoomExtension>[].obs;
  final remarkVersion = 0.obs;

  StreamSubscription<void>? _blockListSubscription;
  StreamSubscription<void>? _autoGrabSubscription;
  StreamSubscription<void>? _extensionSubscription;
  StreamSubscription<void>? _remarkSubscription;

  ChatLogic? get _chatLogic =>
      Get.isRegistered<ChatLogic>() ? Get.find<ChatLogic>() : null;

  ChatRoomSettingsLogic({this.autoLoad = true});

  @override
  void onInit() {
    super.onInit();
    if (!autoLoad) return;
    _loadAll();
    _blockListSubscription ??= ChatRoomBlockList.changes.listen((_) {
      _loadAll();
    });
    _autoGrabSubscription ??= ChatRoomAutoGrabSettings.changes.listen((_) {
      _loadAutoGrabConfig();
    });
    _extensionSubscription ??= ChatRoomExtensionStore.changes.listen((_) {
      _loadExtensions();
    });
    UserRemark.init();
    _remarkSubscription ??= UserRemark.changes.listen((_) {
      remarkVersion.value++;
    });
  }

  String displayNameFor(ChatRoomBlockedUser user) {
    // 让设置页在备注变化时刷新用户显示名。
    remarkVersion.value;
    return UserRemark.displayName(user.userName, fallback: user.userName);
  }

  Future<void> blockUser(ChatRoomBlockedUser user) async {
    if (user.matchKey.isEmpty) {
      ToastManager.showToast('用户信息不完整');
      return;
    }

    await ChatRoomBlockList.addUser(user);
    ToastManager.showToast('已加入聊天室屏蔽');
    await _loadAll();
  }

  Future<void> removeUser(ChatRoomBlockedUser user) async {
    await ChatRoomBlockList.removeUser(user);
    ToastManager.showToast('已移出聊天室屏蔽');
    await _loadAll();
  }

  Future<void> clearBlockedUsers() async {
    if (blockedUsers.isEmpty) return;
    await ChatRoomBlockList.clear();
    ToastManager.showToast('已清空聊天室屏蔽');
    await _loadAll();
  }

  List<String> get redPacketTypes => ChatRedPacketUtils.types;

  String redPacketTypeName(String type) => ChatRedPacketUtils.typeName(type);

  String gestureName(GestureType gesture) =>
      ChatRedPacketUtils.gestureName(gesture);

  int get enabledExtensionCount =>
      extensions.where((extension) => extension.enabled).length;

  bool isAutoGrabTypeSelected(String type) {
    return autoGrabConfig.value.enabledTypes.contains(type);
  }

  Future<void> toggleAutoGrab(bool enabled) async {
    await _saveAutoGrabConfig(autoGrabConfig.value.copyWith(enabled: enabled));
  }

  Future<void> increaseDelay() async {
    await _saveAutoGrabConfig(
      autoGrabConfig.value.copyWith(
        delaySeconds: autoGrabConfig.value.delaySeconds + 1,
      ),
    );
  }

  Future<void> decreaseDelay() async {
    final next = autoGrabConfig.value.delaySeconds - 1;
    if (next < ChatRoomAutoGrabSettings.minDelaySeconds) {
      ToastManager.showToast(
        '自动抢红包延迟不能少于 ${ChatRoomAutoGrabSettings.minDelaySeconds} 秒',
      );
      return;
    }
    await _saveAutoGrabConfig(
        autoGrabConfig.value.copyWith(delaySeconds: next));
  }

  Future<void> toggleAutoGrabType(String type) async {
    final types = List<String>.from(autoGrabConfig.value.enabledTypes);
    if (types.contains(type)) {
      types.remove(type);
    } else {
      types.add(type);
    }
    await _saveAutoGrabConfig(
      autoGrabConfig.value.copyWith(enabledTypes: types),
    );
  }

  Future<void> selectAutoGrabGesture(GestureType gesture) async {
    await _saveAutoGrabConfig(autoGrabConfig.value.copyWith(gesture: gesture));
  }

  Future<void> resetAutoGrabStats() async {
    await ChatRoomAutoGrabSettings.resetStats();
    ToastManager.showToast('自动抢红包统计已重置');
    await _loadAutoGrabConfig();
  }

  Future<String?> saveExtension(ChatRoomExtension extension) async {
    final error = await ChatRoomExtensionStore.saveExtension(extension);
    if (error != null) return error;
    ToastManager.showToast('扩展已保存');
    await _loadExtensions();
    return null;
  }

  Future<void> toggleExtension(
      ChatRoomExtension extension, bool enabled) async {
    final error = await ChatRoomExtensionStore.saveExtension(extension.copyWith(
      enabled: enabled,
    ));
    if (error != null) {
      ToastManager.showToast(error);
      return;
    }
    await _loadExtensions();
  }

  Future<void> deleteExtension(ChatRoomExtension extension) async {
    await ChatRoomExtensionStore.deleteExtension(extension.id);
    ToastManager.showToast('扩展已删除');
    await _loadExtensions();
  }

  Future<void> duplicateExtension(ChatRoomExtension extension) async {
    final error = await ChatRoomExtensionStore.duplicateExtension(extension);
    if (error != null) {
      ToastManager.showToast(error);
      return;
    }
    ToastManager.showToast('扩展已复制');
    await _loadExtensions();
  }

  void openNewExtensionEditor() {
    _openExtensionEditor(null);
  }

  void openExtensionEditor(ChatRoomExtension extension) {
    _openExtensionEditor(extension);
  }

  Future<void> exportExtensions() async {
    if (extensions.isEmpty) {
      ToastManager.showToast('暂无可导出的扩展');
      return;
    }
    await Clipboard.setData(
      ClipboardData(text: ChatRoomExtensionStore.exportJson(extensions)),
    );
    ToastManager.showToast('扩展配置已复制到剪贴板');
  }

  Future<void> importExtensionsFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final raw = data?.text?.trim() ?? '';
    try {
      final count = await ChatRoomExtensionStore.importJson(raw);
      ToastManager.showToast('已导入 $count 个扩展');
      await _loadExtensions();
    } catch (e) {
      ToastManager.showToast(e.toString());
    }
  }

  void openManualAddEditor() {
    final context = Get.context;
    if (context == null) return;

    Navigator.push(
      context,
      PopRoute(
        child: PiEditWidget(
          title: '添加屏蔽用户',
          hintText: '输入用户名',
          maxLength: 32,
          onEditingCompleteText: (text) {
            final userName = text.toString().trim();
            if (userName.isEmpty) {
              ToastManager.showToast('请输入用户名');
              return;
            }
            blockUser(ChatRoomBlockedUser(userName: userName));
          },
        ),
      ),
    );
  }

  Future<void> _loadAll() async {
    await _loadBlockedUsers();
    await _loadAutoGrabConfig();
    await _loadExtensions();
    _loadRecentUsers();
  }

  Future<void> _loadBlockedUsers() async {
    try {
      await ChatRoomBlockList.init();
      blockedUsers.assignAll(await ChatRoomBlockList.getAllUser());
    } catch (_) {
      blockedUsers.clear();
    }
    blockedUsers.refresh();
  }

  void _loadRecentUsers() {
    final logic = _chatLogic;
    if (logic == null) {
      recentUsers.clear();
      return;
    }

    final seen = <String>{};
    final users = <ChatRoomBlockedUser>[];
    for (final message in logic.messageList.reversed) {
      if (!logic.canBlockChatRoomUser(message)) continue;
      final user = ChatRoomBlockedUser.fromChatRoomMessage(message);
      if (user.matchKey.isEmpty ||
          ChatRoomBlockList.isBlockedUser(
            blockedUsers,
            oId: user.oId,
            userName: user.userName,
          ) ||
          !seen.add(user.matchKey)) {
        continue;
      }

      users.add(user);
      if (users.length >= 20) break;
    }

    recentUsers.assignAll(users);
    recentUsers.refresh();
  }

  Future<void> _loadAutoGrabConfig() async {
    try {
      await ChatRoomAutoGrabSettings.init();
      autoGrabConfig.value = await ChatRoomAutoGrabSettings.getConfig();
    } catch (_) {
      autoGrabConfig.value = ChatRoomAutoGrabConfig.defaults();
    }
  }

  Future<void> _loadExtensions() async {
    try {
      await ChatRoomExtensionStore.init();
      extensions.assignAll(await ChatRoomExtensionStore.getAll());
    } catch (_) {
      extensions.clear();
    }
    extensions.refresh();
  }

  Future<void> _saveAutoGrabConfig(ChatRoomAutoGrabConfig config) async {
    final error = await ChatRoomAutoGrabSettings.saveConfig(config);
    if (error != null) {
      ToastManager.showToast(error);
      return;
    }
    autoGrabConfig.value = await ChatRoomAutoGrabSettings.getConfig();
    ToastManager.showToast('自动抢红包设置已保存');
  }

  void _openExtensionEditor(ChatRoomExtension? extension) {
    Get.bottomSheet(
      ChatRoomExtensionEditorSheet(
        extension: extension,
        onSave: saveExtension,
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  @override
  void onClose() {
    _blockListSubscription?.cancel();
    _autoGrabSubscription?.cancel();
    _extensionSubscription?.cancel();
    _remarkSubscription?.cancel();
    super.onClose();
  }
}
