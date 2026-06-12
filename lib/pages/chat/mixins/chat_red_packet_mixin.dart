import 'dart:async';

import 'package:fishpi/fishpi.dart';
import 'package:fishpi_app/core/chat/chat_red_packet_utils.dart';
import 'package:fishpi_app/core/controller/im.dart';
import 'package:fishpi_app/core/manager/toast.dart';
import 'package:fishpi_app/core/network/app_error_message.dart';
import 'package:fishpi_app/core/sql/chat_room_auto_grab_settings.dart';
import 'package:get/get.dart';

/// 聊天室红包能力（发送、领取、自动抢、状态更新、自动抢配置）。
///
/// 从 [ChatLogic] 抽出。拥有红包相关状态与定时器，依赖宿主提供消息列表、当前
/// 用户信息以及 [replaceMessages] 这类消息写回钩子。宿主需在收到新消息时调用
/// [scheduleAutoGrabRedPacket]，并在 onClose 中调用 [cancelAutoGrabTimers]。
mixin ChatRedPacketMixin on GetxController {
  // 宿主需要实现的依赖。
  bool get isGroupChat;
  bool get isChatClosed;
  IMController get imController;
  Rx<UserInfo> get userInfoRef;
  RxList<ChatRoomMessage> get messageListRef;
  void scrollToBottom({int? delay});
  void replaceMessages(Iterable<ChatRoomMessage> messages);

  final isSendingRedPacket = false.obs;
  final isOpeningRedPacket = false.obs;
  final autoGrabConfig = ChatRoomAutoGrabConfig.defaults().obs;

  final Map<String, Timer> _autoGrabTimers = {};
  final Map<String, RedPacketInfo> _redPacketInfoCache = {};
  final Set<String> _autoGrabScheduledIds = {};
  final Set<String> _autoGrabOpenedIds = {};
  final Set<String> _openingRedPacketIds = {};

  Future<bool> sendRedPacket(RedPacketMessage redpacket) async {
    if (!isGroupChat || isSendingRedPacket.value) return false;

    isSendingRedPacket.value = true;
    try {
      final result = redpacket.type == RedPacketType.RockPaperScissors &&
              redpacket.gesture != null
          ? await imController.fishpi.chatroom.send(
              ChatRedPacketUtils.toSendContent(redpacket),
            )
          : await imController.fishpi.chatroom.redpacket.send(redpacket);
      if (result is ResponseResult && !result.success) {
        throw result.msg.isEmpty ? '发送红包失败' : result.msg;
      }
      ToastManager.showToast('红包已发送');
      scrollToBottom(delay: 300);
      return true;
    } catch (e) {
      ToastManager.showToast(
        AppErrorMessage.friendly(e, fallback: '发送红包失败'),
      );
      return false;
    } finally {
      isSendingRedPacket.value = false;
    }
  }

  Future<RedPacketInfo?> openRedPacket(
    ChatRoomMessage chat, {
    GestureType? gesture,
  }) async {
    if (!isGroupChat || chat.oId.isEmpty) {
      return null;
    }
    final cachedInfo = _redPacketInfoCache[chat.oId];
    if (cachedInfo != null) {
      return cachedInfo;
    }
    if (_openingRedPacketIds.contains(chat.oId)) {
      return null;
    }

    _cancelScheduledAutoGrab(chat.oId);
    _autoGrabOpenedIds.add(chat.oId);
    _openingRedPacketIds.add(chat.oId);
    isOpeningRedPacket.value = true;
    try {
      final info = await imController.fishpi.chatroom.redpacket.open(
        chat.oId,
        gesture: gesture,
      );
      _redPacketInfoCache[chat.oId] = info;
      return info;
    } catch (e) {
      if (ChatRedPacketUtils.isAlreadyOpenedError(e)) {
        final cached = _redPacketInfoCache[chat.oId];
        if (cached != null) return cached;
        ToastManager.showToast('红包已领取，可稍后查看详情');
        return null;
      }
      _autoGrabOpenedIds.remove(chat.oId);
      ToastManager.showToast(ChatRedPacketUtils.openErrorMessage(e));
      return null;
    } finally {
      _openingRedPacketIds.remove(chat.oId);
      isOpeningRedPacket.value = _openingRedPacketIds.isNotEmpty;
    }
  }

  void _cancelScheduledAutoGrab(String redPacketId) {
    _autoGrabTimers.remove(redPacketId)?.cancel();
    _autoGrabScheduledIds.remove(redPacketId);
  }

  void scheduleAutoGrabRedPacket(ChatRoomMessage chat) {
    if (!isGroupChat || !chat.isRedpacket || chat.oId.isEmpty) return;

    final redpacket = chat.redpacket;
    if (redpacket == null) return;

    final config = autoGrabConfig.value;
    if (!config.canGrabType(redpacket.type)) return;
    if (redpacket.type == RedPacketType.RockPaperScissors &&
        config.gesture == null) {
      return;
    }
    if (_autoGrabScheduledIds.contains(chat.oId) ||
        _autoGrabOpenedIds.contains(chat.oId)) {
      return;
    }

    _autoGrabScheduledIds.add(chat.oId);
    _autoGrabTimers[chat.oId] = Timer(
      Duration(seconds: config.delaySeconds),
      () {
        _autoGrabTimers.remove(chat.oId);
        _openRedPacketAutomatically(chat);
      },
    );
  }

  Future<void> _openRedPacketAutomatically(ChatRoomMessage chat) async {
    if (isChatClosed ||
        !isGroupChat ||
        chat.oId.isEmpty ||
        _autoGrabOpenedIds.contains(chat.oId)) {
      return;
    }

    _autoGrabOpenedIds.add(chat.oId);
    try {
      final redpacket = chat.redpacket;
      final gesture = redpacket?.type == RedPacketType.RockPaperScissors
          ? autoGrabConfig.value.gesture
          : null;
      final info = await imController.fishpi.chatroom.redpacket.open(
        chat.oId,
        gesture: gesture,
      );
      _redPacketInfoCache[chat.oId] = info;
      final point = await _currentUserGotPoint(info);
      if (point > 0) {
        await ChatRoomAutoGrabSettings.recordSuccess(point);
      }
    } catch (_) {
      // 自动抢红包不打断聊天体验，失败时保持静默。
    }
  }

  Future<int> _currentUserGotPoint(RedPacketInfo info) async {
    var current = userInfoRef.value;
    if (current.userName.isEmpty) {
      current = imController.fishpi.user.current;
    }
    if (current.userName.isEmpty) {
      try {
        current = await imController.fishpi.user.info();
        userInfoRef.value = current;
      } catch (_) {
        return 0;
      }
    }

    final currentId = current.oId.trim();
    final currentName = current.userName.trim();
    for (final user in info.who) {
      final gotId = user.userId.trim();
      final gotName = user.userName.trim();
      if ((currentId.isNotEmpty && gotId == currentId) ||
          (currentName.isNotEmpty && gotName == currentName)) {
        return user.money;
      }
    }
    return 0;
  }

  Future<void> loadAutoGrabConfig() async {
    try {
      await ChatRoomAutoGrabSettings.init();
      autoGrabConfig.value = await ChatRoomAutoGrabSettings.getConfig();
      if (!autoGrabConfig.value.enabled) {
        cancelAutoGrabTimers();
      }
    } catch (_) {
      autoGrabConfig.value = ChatRoomAutoGrabConfig.defaults();
      cancelAutoGrabTimers();
    }
  }

  void cancelAutoGrabTimers() {
    for (final timer in _autoGrabTimers.values) {
      timer.cancel();
    }
    _autoGrabTimers.clear();
    _autoGrabScheduledIds.clear();
  }

  void updateRedPacketStatus(RedPacketStatusMsg? status) {
    if (status == null || status.oId.isEmpty) return;
    replaceMessages(
      messageListRef
          .map((message) => ChatRedPacketUtils.updateStatus(message, status))
          .toList(),
    );
  }
}
