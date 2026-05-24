import 'dart:async';
import 'dart:io';
import 'package:fishpi/fishpi.dart';
import 'package:fishpi_app/core/chat/chat_message_utils.dart';
import 'package:fishpi_app/core/chat/chat_voice_message_utils.dart';
import 'package:fishpi_app/core/im_event.dart';
import 'package:fishpi_app/core/manager/toast.dart';
import 'package:fishpi_app/core/sql/black_list.dart';
import 'package:fishpi_app/core/sql/user_remark.dart';
import 'package:fishpi_app/pages/conversation/conversation_logic.dart';
import 'package:fishpi_app/routers/navigator.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:record/record.dart';

import '../../core/controller/im.dart';

class ChatLogic extends GetxController {
  final imController = Get.find<IMController>();
  final messageList = <ChatRoomMessage>[].obs;
  final chatMsgList = <ChatData>[].obs;
  final userInfo = UserInfo().obs;

  final isGroup = false.obs;
  final userName = ''.obs;
  final userID = ''.obs;
  final isClose = true.obs;
  final isSeeHistory = false.obs;
  final isLoadingHistory = false.obs;
  final hasMoreHistory = true.obs;
  final historyPage = 0.obs;
  final remarkVersion = 0.obs;
  final isRecordingVoice = false.obs;
  final isSendingVoice = false.obs;
  final voiceRecordSeconds = 0.obs;
  final int historyPageSize = 20;

  ScrollController chatRoomController = ScrollController();
  TextEditingController chatRoomControllerText = TextEditingController();
  FocusNode chatRoomFocusNode = FocusNode();

  final content = ''.obs;

  get emojiList => imController.fishpi.emoji.defaultEmojis;
  final diyEmojiList = <String>[].obs;
  final emojiIndex = 0.obs;
  final List<BlackUser> _blackUsers = [];
  StreamSubscription<ChatRoomData>? _chatRoomSubscription;
  StreamSubscription<PrivateChatEvent>? _privateChatSubscription;
  StreamSubscription<void>? _blackListSubscription;
  StreamSubscription<void>? _remarkSubscription;
  bool _scrollListenerAttached = false;
  final AudioRecorder _voiceRecorder = AudioRecorder();
  Timer? _voiceTimer;
  DateTime? _voiceStartedAt;
  String? _voiceRecordPath;
  bool _isStoppingVoice = false;

  ConversationLogic? get _conversationController =>
      Get.isRegistered<ConversationLogic>()
          ? Get.find<ConversationLogic>()
          : null;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments ?? {};
    isGroup.value = args['isGroup'] ?? false;
    userName.value = args['userName'] ?? '聊天室';
    userID.value = args['userID'] ?? '';
    if (isGroup.value) {
      messageList.addAll(_conversationController?.chatRoomMsg ?? []);
      messageList.refresh();
      scrollToBottom(delay: 300);
    }
    imController.fishpi.user.info().then((value) => userInfo.value = value);
    isClose.value = false;
    _blackListSubscription ??= BlackList.changes.listen((_) {
      _reloadBlackUsersAndFilterMessages();
    });
    UserRemark.init();
    _remarkSubscription ??= UserRemark.changes.listen((_) {
      remarkVersion.value++;
    });
    initChatRoom();
    loadEmojis();
  }

  @override
  void onReady() {
    super.onReady();
    if (!_scrollListenerAttached) {
      chatRoomController.addListener(_handleScroll);
      _scrollListenerAttached = true;
    }
  }

  void initChatRoom() async {
    await _loadBlackUsers();
    if (isGroup.value) {
      if (messageList.isEmpty) {
        await _loadInitialHistory();
      } else {
        historyPage.value = 1;
      }
      _chatRoomSubscription ??=
          imController.chatRoomStream.listen(_onChatRoomData);
      scrollToBottom(delay: 300);
    } else {
      await _loadInitialHistory(markPrivateRead: true);
      scrollToBottom(delay: 300);
      _privateChatSubscription ??= imController
          .watchPrivateChat(userName.value)
          .listen(_onPrivateChatEvent);
    }
  }

  void _onChatRoomData(ChatRoomData data) {
    if (data.type == ChatRoomMessageType.revoke) {
      _removeMessage(data.revoke ?? '');
      return;
    }
    final message = data.msg;
    if (message == null) return;
    _appendMessage(message);
  }

  void _onPrivateChatEvent(PrivateChatEvent event) {
    if (event.isRevoke) {
      _removeMessage(event.revoke ?? '');
      return;
    }
    final data = event.data;
    if (data == null) return;
    _appendMessage(ChatMessageUtils.chatDataToRoomMessage(data));
  }

  void _appendMessage(
    ChatRoomMessage message, {
    bool shouldScroll = true,
  }) {
    if (ChatMessageUtils.isBlockedMessage(message, _blackUsers)) return;
    messageList.assignAll(
      ChatMessageUtils.appendUniqueChatRoomMessage(
        messageList,
        message,
      ),
    );
    messageList.refresh();
    if (shouldScroll) {
      scrollToBottom(delay: 300);
    }
  }

  void _removeMessage(String messageId) {
    messageList.assignAll(
      ChatMessageUtils.removeChatRoomMessage(messageList, messageId),
    );
    messageList.refresh();
  }

  void _handleScroll() {
    if (!chatRoomController.hasClients) return;
    final position = chatRoomController.position;
    final distance = position.maxScrollExtent - position.pixels;
    isSeeHistory.value = distance >= 100;
    if (position.pixels <= 80) {
      loadMoreHistory();
    }
  }

  Future<void> _loadInitialHistory({bool markPrivateRead = false}) async {
    isLoadingHistory.value = true;
    try {
      final result = await _fetchHistoryPage(
        1,
        markPrivateRead: markPrivateRead,
      );
      hasMoreHistory.value =
          ChatMessageUtils.hasMoreHistoryPage(result.rawCount);
      if (!hasMoreHistory.value) return;

      historyPage.value = 1;
      messageList.assignAll(result.messages);
      messageList.refresh();
    } catch (e) {
      ToastManager.showToast('加载历史消息失败：$e');
    } finally {
      isLoadingHistory.value = false;
    }
  }

  Future<void> loadMoreHistory() async {
    if (isLoadingHistory.value || !hasMoreHistory.value) return;

    final oldMaxScrollExtent = chatRoomController.hasClients
        ? chatRoomController.position.maxScrollExtent
        : 0.0;
    final oldPixels = chatRoomController.hasClients
        ? chatRoomController.position.pixels
        : 0.0;

    isLoadingHistory.value = true;
    try {
      final nextPage = historyPage.value + 1;
      final result = await _fetchHistoryPage(
        nextPage,
        markPrivateRead: false,
      );
      hasMoreHistory.value =
          ChatMessageUtils.hasMoreHistoryPage(result.rawCount);
      if (!hasMoreHistory.value) return;

      historyPage.value = nextPage;
      final beforeLength = messageList.length;
      messageList.assignAll(
        ChatMessageUtils.prependUniqueChatRoomMessages(
          messageList,
          result.messages,
        ),
      );
      messageList.refresh();

      if (messageList.length > beforeLength) {
        _restoreScrollOffsetAfterPrepend(oldMaxScrollExtent, oldPixels);
      }
    } catch (e) {
      ToastManager.showToast('加载历史消息失败：$e');
    } finally {
      isLoadingHistory.value = false;
    }
  }

  Future<_HistoryPageResult> _fetchHistoryPage(
    int page, {
    required bool markPrivateRead,
  }) async {
    if (isGroup.value) {
      final history = await imController.fishpi.chatroom.more(page);
      final messages = ChatMessageUtils.visibleMessages(
        history.reversed,
        _blackUsers,
      );
      return _HistoryPageResult(
        rawCount: history.length,
        messages: messages,
      );
    }

    final history = await imController.fishpi.chat.get(
      user: userName.value,
      page: page,
      size: historyPageSize,
      autoRead: markPrivateRead,
    );
    final messages =
        history.reversed.map(ChatMessageUtils.chatDataToRoomMessage).toList();
    return _HistoryPageResult(
      rawCount: history.length,
      messages: ChatMessageUtils.visibleMessages(messages, _blackUsers),
    );
  }

  void _restoreScrollOffsetAfterPrepend(
    double oldMaxScrollExtent,
    double oldPixels,
  ) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isClose.value || !chatRoomController.hasClients) return;

      final position = chatRoomController.position;
      final addedExtent = position.maxScrollExtent - oldMaxScrollExtent;
      final target = (oldPixels + addedExtent)
          .clamp(0.0, position.maxScrollExtent)
          .toDouble();
      chatRoomController.jumpTo(target);
    });
  }

  void scrollToBottom({int? delay}) {
    if (isClose.value || isSeeHistory.value) return;
    Future.delayed(Duration(milliseconds: delay ?? 200), () {
      if (chatRoomController.hasClients) {
        chatRoomController.animateTo(
          chatRoomController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void onInput(String text) {
    content.value = text;
  }

  void clickUserAvatar(String userName) {
    AppNavigator.toUserPanel(userName: userName);
  }

  void toChatRoomSettings() {
    if (!isGroup.value) return;
    AppNavigator.toChatRoomSettings();
  }

  String displayNameFor(String userName, {String? fallback}) {
    // 让 Obx 感知备注变更，触发当前聊天页的昵称刷新。
    remarkVersion.value;
    return UserRemark.displayName(userName, fallback: fallback);
  }

  Future<void> clickSend() async {
    final text = content.value;
    if (text.trim().isEmpty) return;

    try {
      if (isGroup.value) {
        await imController.fishpi.chatroom.send(text);
      } else {
        await imController.fishpi.chat.send(userName.value, text);
      }
      content.value = '';
      chatRoomControllerText.clear();
      scrollToBottom(delay: 300);
    } catch (e) {
      ToastManager.showToast('发送失败：$e');
    }
  }

  Future<void> startVoiceRecord() async {
    if (!isGroup.value) {
      ToastManager.showToast('私聊暂不支持语音消息');
      return;
    }
    if (isRecordingVoice.value || isSendingVoice.value) return;

    try {
      final hasPermission = await _voiceRecorder.hasPermission();
      if (!hasPermission) {
        ToastManager.showToast('需要麦克风权限才能发送语音消息');
        return;
      }

      final path = _voiceTempPath();
      await _voiceRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 64000,
          sampleRate: 44100,
          numChannels: 1,
          autoGain: true,
          echoCancel: true,
          noiseSuppress: true,
        ),
        path: path,
      );

      _voiceRecordPath = path;
      _voiceStartedAt = DateTime.now();
      voiceRecordSeconds.value = 0;
      isRecordingVoice.value = true;
      _startVoiceTimer();
    } catch (e) {
      await _resetVoiceRecordState(cancelRecorder: true);
      ToastManager.showToast('开始录音失败：$e');
    }
  }

  Future<void> finishVoiceRecord() async {
    await _stopVoiceRecord(shouldSend: true);
  }

  Future<void> cancelVoiceRecord() async {
    await _stopVoiceRecord(shouldSend: false);
  }

  Future<void> _stopVoiceRecord({required bool shouldSend}) async {
    if (!isRecordingVoice.value || _isStoppingVoice) return;
    _isStoppingVoice = true;

    final duration = _currentVoiceDurationSeconds();
    try {
      final path = await _voiceRecorder.stop() ?? _voiceRecordPath;
      _stopVoiceTimer();
      isRecordingVoice.value = false;
      voiceRecordSeconds.value = duration;

      if (!shouldSend) {
        _deleteVoiceFile(path);
        ToastManager.showToast('已取消语音');
        return;
      }

      if (duration < ChatVoiceMessageUtils.minRecordSeconds) {
        _deleteVoiceFile(path);
        ToastManager.showToast('录音时间太短');
        return;
      }

      if (path == null || !File(path).existsSync()) {
        ToastManager.showToast('录音文件不存在');
        return;
      }

      await _sendVoiceRecord(path, duration);
    } catch (e) {
      ToastManager.showToast('语音发送失败：$e');
    } finally {
      _voiceRecordPath = null;
      _voiceStartedAt = null;
      _isStoppingVoice = false;
      isRecordingVoice.value = false;
      voiceRecordSeconds.value = 0;
    }
  }

  Future<void> _sendVoiceRecord(String path, int durationSeconds) async {
    isSendingVoice.value = true;
    try {
      final result = await imController.fishpi.upload([path]);
      if (result.success.isEmpty) {
        throw result.errs.isEmpty ? '上传失败' : result.errs.join('，');
      }
      final url = result.success.first.url.trim();
      if (url.isEmpty) throw '上传地址为空';

      final message = ChatVoiceMessageUtils.buildMusicMessage(
        url: url,
        durationSeconds: durationSeconds,
      );
      await imController.fishpi.chatroom.send(message);
      scrollToBottom(delay: 300);
    } finally {
      isSendingVoice.value = false;
      _deleteVoiceFile(path);
    }
  }

  void _startVoiceTimer() {
    _stopVoiceTimer();
    _voiceTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final seconds = _currentVoiceDurationSeconds();
      voiceRecordSeconds.value = seconds;
      if (seconds >= ChatVoiceMessageUtils.maxRecordSeconds) {
        finishVoiceRecord();
      }
    });
  }

  int _currentVoiceDurationSeconds() {
    final startedAt = _voiceStartedAt;
    if (startedAt == null) return 0;
    final seconds = DateTime.now().difference(startedAt).inSeconds;
    return seconds.clamp(0, ChatVoiceMessageUtils.maxRecordSeconds);
  }

  void _stopVoiceTimer() {
    _voiceTimer?.cancel();
    _voiceTimer = null;
  }

  String _voiceTempPath() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${Directory.systemTemp.path}/fishpi_voice_$timestamp.m4a';
  }

  void _deleteVoiceFile(String? path) {
    if (path == null) return;
    final file = File(path);
    if (file.existsSync()) {
      file.deleteSync();
    }
  }

  Future<void> _resetVoiceRecordState({required bool cancelRecorder}) async {
    _stopVoiceTimer();
    if (cancelRecorder) {
      try {
        await _voiceRecorder.cancel();
      } catch (_) {}
    }
    _deleteVoiceFile(_voiceRecordPath);
    _voiceRecordPath = null;
    _voiceStartedAt = null;
    _isStoppingVoice = false;
    isRecordingVoice.value = false;
    voiceRecordSeconds.value = 0;
  }

  void loadEmojis() async {
    try {
      diyEmojiList.value = await imController.fishpi.emoji.get();
      diyEmojiList.refresh();
    } catch (_) {}
  }

  Future<void> _loadBlackUsers() async {
    try {
      await BlackList.init();
      _blackUsers
        ..clear()
        ..addAll(await BlackList.getAllUser());
    } catch (_) {
      _blackUsers.clear();
    }
  }

  Future<void> _reloadBlackUsersAndFilterMessages() async {
    await _loadBlackUsers();
    messageList.assignAll(
      ChatMessageUtils.visibleMessages(messageList, _blackUsers),
    );
    messageList.refresh();
  }

  @override
  void onClose() {
    isClose.value = true;
    _chatRoomSubscription?.cancel();
    _privateChatSubscription?.cancel();
    _blackListSubscription?.cancel();
    _remarkSubscription?.cancel();
    _stopVoiceTimer();
    _voiceRecorder.dispose();
    if (!isGroup.value) {
      imController.unwatchPrivateChat(userName.value);
    }
    if (_scrollListenerAttached) {
      chatRoomController.removeListener(_handleScroll);
    }
    chatRoomController.dispose();
    chatRoomControllerText.dispose();
    chatRoomFocusNode.dispose();
    super.onClose();
  }
}

class _HistoryPageResult {
  final int rawCount;
  final List<ChatRoomMessage> messages;

  const _HistoryPageResult({
    required this.rawCount,
    required this.messages,
  });
}
