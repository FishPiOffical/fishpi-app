import 'dart:async';
import 'dart:io';
import 'package:fishpi/fishpi.dart';
import 'package:fishpi_app/core/chat/chat_barrager_utils.dart';
import 'package:fishpi_app/core/chat/chat_message_utils.dart';
import 'package:fishpi_app/core/chat/chat_quote_utils.dart';
import 'package:fishpi_app/core/chat/chat_red_packet_utils.dart';
import 'package:fishpi_app/core/chat/chat_room_extension_runtime.dart';
import 'package:fishpi_app/core/chat/chat_topic_utils.dart';
import 'package:fishpi_app/core/chat/chat_voice_message_utils.dart';
import 'package:fishpi_app/core/debug/memory_snapshot.dart';
import 'package:fishpi_app/core/im_event.dart';
import 'package:fishpi_app/core/manager/toast.dart';
import 'package:fishpi_app/core/memory/memory_limits.dart';
import 'package:fishpi_app/core/network/app_error_message.dart';
import 'package:fishpi_app/core/sql/black_list.dart';
import 'package:fishpi_app/core/sql/chat_room_auto_grab_settings.dart';
import 'package:fishpi_app/core/sql/chat_room_block_list.dart';
import 'package:fishpi_app/core/sql/chat_emoji_cache.dart';
import 'package:fishpi_app/core/sql/chat_room_extension_store.dart';
import 'package:fishpi_app/core/sql/user_remark.dart';
import 'package:fishpi_app/pages/conversation/conversation_logic.dart';
import 'package:fishpi_app/routers/navigator.dart';
import 'package:fishpi_app/widgets/pi_editer.dart';
import 'package:fishpi_app/widgets/pi_transfer.dart';
import 'package:fishpi_app/widgets/pop_route.dart';
import 'package:fishpi_app/widgets/chat/chat_room_extension_trigger_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';

import '../../core/controller/im.dart';

typedef DiyEmojiRemoteLoader = Future<List<String>> Function();

class ChatLogic extends GetxController {
  ChatLogic({DiyEmojiRemoteLoader? diyEmojiRemoteLoader})
      : _diyEmojiRemoteLoader = diyEmojiRemoteLoader;

  final DiyEmojiRemoteLoader? _diyEmojiRemoteLoader;
  final imController = Get.find<IMController>();
  final messageList = <ChatRoomMessage>[].obs;
  final displayGroups = <ChatMessageGroup>[].obs;
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
  final isSendingImage = false.obs;
  final voiceRecordSeconds = 0.obs;
  final currentTopic = ''.obs;
  final onlineUsers = <OnlineInfo>[].obs;
  final isSettingTopic = false.obs;
  final isSendingRedPacket = false.obs;
  final isOpeningRedPacket = false.obs;
  final isSendingBarrager = false.obs;
  final quoteDraft = Rxn<ChatQuoteDraft>();
  final autoGrabConfig = ChatRoomAutoGrabConfig.defaults().obs;
  final barrageCost = Rxn<BarrageCost>();
  final barragers = <ChatBarragerItem>[].obs;
  final extensions = <ChatRoomExtension>[].obs;
  final int historyPageSize = 20;

  ScrollController chatRoomController = ScrollController();
  TextEditingController chatRoomControllerText = TextEditingController();
  FocusNode chatRoomFocusNode = FocusNode();
  final ImagePicker _imagePicker = ImagePicker();

  final content = ''.obs;

  get emojiList => imController.fishpi.emoji.defaultEmojis;
  final diyEmojiList = <String>[].obs;
  final emojiIndex = 0.obs;
  final List<BlackUser> _blackUsers = [];
  final List<ChatRoomBlockedUser> _chatRoomBlockedUsers = [];
  StreamSubscription<ChatRoomData>? _chatRoomSubscription;
  StreamSubscription<PrivateChatEvent>? _privateChatSubscription;
  StreamSubscription<void>? _blackListSubscription;
  StreamSubscription<void>? _chatRoomBlockListSubscription;
  StreamSubscription<void>? _autoGrabSettingsSubscription;
  StreamSubscription<void>? _extensionSubscription;
  StreamSubscription<void>? _remarkSubscription;
  bool _scrollListenerAttached = false;
  AudioRecorder? _voiceRecorder;
  Timer? _voiceTimer;
  Timer? _scrollToBottomTimer;
  final Map<String, Timer> _autoGrabTimers = {};
  final Map<String, RedPacketInfo> _redPacketInfoCache = {};
  final Set<String> _autoGrabScheduledIds = {};
  final Set<String> _autoGrabOpenedIds = {};
  final Set<String> _openingRedPacketIds = {};
  DateTime? _voiceStartedAt;
  String? _voiceRecordPath;
  bool _isStoppingVoice = false;
  bool _hasLoadedRemoteEmojis = false;
  int _barragerSequence = 0;
  int _barragerTrack = 0;
  late final ChatRoomExtensionRuntime _extensionRuntime;

  ConversationLogic? get _conversationController =>
      Get.isRegistered<ConversationLogic>()
          ? Get.find<ConversationLogic>()
          : null;

  @override
  void onInit() {
    super.onInit();
    _extensionRuntime = ChatRoomExtensionRuntime(
      userLoader: _loadCurrentUserForExtension,
      livenessLoader: () => imController.fishpi.user.liveness(),
      topicProvider: () => currentTopic.value,
    );
    final args = Get.arguments ?? {};
    isGroup.value = args['isGroup'] ?? false;
    userName.value = args['userName'] ?? '聊天室';
    userID.value = args['userID'] ?? '';
    if (isGroup.value) {
      _replaceMessages(
        ChatMessageUtils.trimChatRoomMessages(
          _conversationController?.chatRoomMsg ?? const <ChatRoomMessage>[],
          MemoryLimits.chatRealtimeMessages,
        ),
      );
      scrollToBottom(delay: 300);
    }
    imController.fishpi.user.info().then((value) => userInfo.value = value);
    isClose.value = false;
    _blackListSubscription ??= BlackList.changes.listen((_) {
      _reloadBlackUsersAndFilterMessages();
    });
    if (isGroup.value) {
      _chatRoomBlockListSubscription ??= ChatRoomBlockList.changes.listen((_) {
        _reloadChatRoomBlockedUsersAndFilterMessages();
      });
      _autoGrabSettingsSubscription ??=
          ChatRoomAutoGrabSettings.changes.listen((_) {
        _loadAutoGrabConfig();
      });
      _extensionSubscription ??= ChatRoomExtensionStore.changes.listen((_) {
        loadExtensions();
      });
    }
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
      await _loadChatRoomBlockedUsers();
      await _loadAutoGrabConfig();
      await loadExtensions();
      _replaceMessages(_visibleMessages(messageList));
      if (messageList.isEmpty) {
        await _loadInitialHistory();
      } else {
        historyPage.value = 1;
      }
      _chatRoomSubscription ??=
          imController.chatRoomStream.listen(_onChatRoomData);
      currentTopic.value = imController.fishpi.chatroom.discusse.toString();
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
    if (data.type == ChatRoomMessageType.online) {
      onlineUsers.assignAll(data.online ?? const []);
      currentTopic.value = imController.fishpi.chatroom.discusse.toString();
      return;
    }
    if (data.type == ChatRoomMessageType.discussChanged) {
      currentTopic.value = data.discuss ?? '';
      return;
    }
    if (data.type == ChatRoomMessageType.revoke) {
      _removeMessage(data.revoke ?? '');
      return;
    }
    if (data.type == ChatRoomMessageType.redPacketStatus) {
      _updateRedPacketStatus(data.status);
      return;
    }
    if (data.type == ChatRoomMessageType.barrager) {
      _appendBarrager(data.barrager);
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
    if (_isMessageBlocked(message)) return;
    _replaceMessages(
      ChatMessageUtils.appendUniqueChatRoomMessage(
        messageList,
        message,
        maxLength: _messageMemoryLimit,
      ),
    );
    _scheduleAutoGrabRedPacket(message);
    _triggerReceiveExtensions(message);
    if (shouldScroll) {
      scrollToBottom(delay: 300);
    }
  }

  void _removeMessage(String messageId) {
    _replaceMessages(
      ChatMessageUtils.removeChatRoomMessage(messageList, messageId),
    );
  }

  void _handleScroll() {
    if (!chatRoomController.hasClients) return;
    final position = chatRoomController.position;
    final distance = position.maxScrollExtent - position.pixels;
    final nextIsSeeHistory = distance >= 100;
    if (isSeeHistory.value != nextIsSeeHistory) {
      isSeeHistory.value = nextIsSeeHistory;
    }
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
      _replaceMessages(
        ChatMessageUtils.trimChatRoomMessages(
          result.messages,
          MemoryLimits.chatRealtimeMessages,
        ),
      );
      _logMemorySnapshot('聊天首屏历史');
    } catch (e) {
      ToastManager.showToast(
        AppErrorMessage.friendly(e, fallback: '加载历史消息失败'),
      );
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
      _replaceMessages(
        ChatMessageUtils.prependUniqueChatRoomMessages(
          messageList,
          result.messages,
          maxLength: MemoryLimits.chatHistoryMessages,
        ),
      );
      _logMemorySnapshot('聊天分页历史');

      if (messageList.length > beforeLength) {
        _restoreScrollOffsetAfterPrepend(oldMaxScrollExtent, oldPixels);
      }
    } catch (e) {
      ToastManager.showToast(
        AppErrorMessage.friendly(e, fallback: '加载历史消息失败'),
      );
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
      final messages = _visibleMessages(history.reversed);
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
      messages: _visibleMessages(messages),
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
    _scrollToBottomTimer?.cancel();
    _scrollToBottomTimer = Timer(Duration(milliseconds: delay ?? 200), () {
      _scrollToBottomTimer = null;
      if (!isClose.value &&
          !isSeeHistory.value &&
          chatRoomController.hasClients) {
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

  bool canBlockChatRoomUser(ChatRoomMessage message) {
    if (!isGroup.value) return false;
    return canUseOtherUserActions(message);
  }

  bool canUseOtherUserActions(ChatRoomMessage message) {
    if (message.userName.trim().isEmpty && message.userOId <= 0) return false;
    final currentUser = userInfo.value;
    if (currentUser.userName.isNotEmpty &&
        message.userName == currentUser.userName) {
      return false;
    }
    if (currentUser.oId.isNotEmpty &&
        message.userOId.toString() == currentUser.oId) {
      return false;
    }
    return true;
  }

  void quoteCurrentTopic() {
    final quote = ChatQuoteUtils.fromTopic(currentTopic.value);
    if (quote == null) {
      ToastManager.showToast('暂无话题可引用');
      return;
    }
    quoteDraft.value = quote;
    chatRoomFocusNode.requestFocus();
  }

  void quoteMessage(ChatRoomMessage message) {
    quoteDraft.value = ChatQuoteUtils.fromMessage(
      message: message,
      displayName: chatUserDisplayNameFor(message),
    );
    chatRoomFocusNode.requestFocus();
  }

  void clearQuote() {
    quoteDraft.value = null;
  }

  Future<void> blockChatRoomUser(ChatRoomMessage message) async {
    if (!canBlockChatRoomUser(message)) return;

    await ChatRoomBlockList.addUser(
      ChatRoomBlockedUser.fromChatRoomMessage(message),
    );
    await _reloadChatRoomBlockedUsersAndFilterMessages();
    final displayName = chatUserDisplayNameFor(message);
    ToastManager.showToast('已在聊天室屏蔽$displayName');
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

  String chatUserDisplayNameFor(ChatRoomMessage message) {
    return displayNameFor(
      message.userName,
      fallback: chatUserFallbackNameFor(message),
    );
  }

  String chatUserFallbackNameFor(ChatRoomMessage message) {
    final nickname = message.nickname.trim();
    if (nickname.isNotEmpty) return nickname;

    final userName = message.userName.trim();
    if (userName.isNotEmpty) return userName;

    return '';
  }

  Future<void> clickSend() async {
    await _sendComposedText(
      content.value,
      clearComposerOnSuccess: true,
      triggerExtensions: true,
    );
  }

  Future<bool> sendExtensionResult(String text) {
    if (!isGroup.value) return Future.value(false);
    return _sendComposedText(
      text,
      clearComposerOnSuccess: false,
      triggerExtensions: false,
    );
  }

  void insertExtensionResult(String text) {
    if (!isGroup.value) return;
    final value = text.trim();
    if (value.isEmpty) return;
    chatRoomControllerText.text = value;
    chatRoomControllerText.selection = TextSelection.collapsed(
      offset: chatRoomControllerText.text.length,
    );
    content.value = value;
    chatRoomFocusNode.requestFocus();
  }

  Future<bool> _sendComposedText(
    String text, {
    required bool clearComposerOnSuccess,
    required bool triggerExtensions,
  }) async {
    if (text.trim().isEmpty) return false;
    final bodyText = triggerExtensions && isGroup.value
        ? await _applyBeforeSendExtensions(text)
        : text;
    final sendText = ChatQuoteUtils.composeMessage(
      quote: quoteDraft.value,
      text: bodyText,
    );

    try {
      if (isGroup.value) {
        await imController.fishpi.chatroom.send(sendText);
      } else {
        await imController.fishpi.chat.send(userName.value, sendText);
      }
      if (clearComposerOnSuccess) {
        content.value = '';
        chatRoomControllerText.clear();
      }
      quoteDraft.value = null;
      scrollToBottom(delay: 300);
      if (triggerExtensions && isGroup.value) {
        await _runExtensionTriggers(
          ChatRoomExtensionTrigger.afterSend,
          message: _localSentMessage(sendText),
        );
      }
      return true;
    } catch (e) {
      ToastManager.showToast(
        AppErrorMessage.friendly(e, fallback: '发送失败'),
      );
      return false;
    }
  }

  Future<void> pickAndSendImages() async {
    if (isSendingImage.value) return;

    try {
      final images = await _imagePicker.pickMultiImage(
        imageQuality: 88,
      );
      if (images.isEmpty) return;
      await _uploadAndSendImages(images);
    } catch (e) {
      ToastManager.showToast(
        AppErrorMessage.friendly(e, fallback: '选择图片失败'),
      );
    }
  }

  Future<void> takeAndSendImage() async {
    if (isSendingImage.value) return;

    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 88,
      );
      if (image == null) return;
      await _uploadAndSendImages([image]);
    } catch (e) {
      ToastManager.showToast(
        AppErrorMessage.friendly(e, fallback: '拍摄图片失败'),
      );
    }
  }

  Future<void> _uploadAndSendImages(List<XFile> images) async {
    if (images.isEmpty || isSendingImage.value) return;

    isSendingImage.value = true;
    ToastManager.show(content: images.length > 1 ? '图片发送中...' : '图片上传中...');
    try {
      for (final image in images) {
        final result = await imController.fishpi.upload([image.path]);
        if (result.success.isEmpty) {
          throw result.errs.isEmpty ? '上传失败' : result.errs.join('，');
        }

        final url = result.success.first.url.trim();
        if (url.isEmpty) throw '上传地址为空';

        final sent = await _sendRawChatContent(_imageMessageHtml(url));
        if (!sent) throw '发送失败';
      }

      ToastManager.dismiss();
      ToastManager.showToast(images.length > 1 ? '图片已发送' : '图片发送成功');
    } catch (e) {
      ToastManager.dismiss();
      ToastManager.showToast(
        AppErrorMessage.friendly(e, fallback: '图片发送失败'),
      );
    } finally {
      isSendingImage.value = false;
    }
  }

  Future<bool> _sendRawChatContent(String sendText) async {
    if (sendText.trim().isEmpty) return false;

    try {
      if (isGroup.value) {
        await imController.fishpi.chatroom.send(sendText);
      } else {
        await imController.fishpi.chat.send(userName.value, sendText);
      }
      scrollToBottom(delay: 300);
      return true;
    } catch (_) {
      return false;
    }
  }

  String _imageMessageHtml(String url) {
    final escapedUrl = url
        .replaceAll('&', '&amp;')
        .replaceAll('"', '&quot;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;');
    return '<p><img src="$escapedUrl"/></p>';
  }

  void quickSetRemark(ChatRoomMessage message) {
    if (!canUseOtherUserActions(message)) return;
    final targetUserName = message.userName.trim();
    if (targetUserName.isEmpty) return;

    Navigator.push(
      Get.context!,
      PopRoute(
        child: PiEditWidget(
          title: '设置备注',
          hintText: '给$targetUserName设置备注，留空清除备注',
          initialText: UserRemark.remarkOf(targetUserName),
          maxLength: 8,
          onEditingCompleteText: (text) async {
            final remark = text.toString().trim();
            if (remark.isEmpty) {
              await UserRemark.removeRemark(targetUserName);
              ToastManager.showToast('备注已清除');
            } else {
              await UserRemark.setRemark(
                oId: message.userOId > 0 ? message.userOId.toString() : '',
                userName: targetUserName,
                remark: remark,
                avatarURL: message.avatarURL,
              );
              ToastManager.showToast('备注已保存');
            }
          },
        ),
      ),
    );
  }

  void quickTransfer(ChatRoomMessage message) {
    if (!canUseOtherUserActions(message)) return;
    final targetUserName = message.userName.trim();
    if (targetUserName.isEmpty) return;

    Navigator.push(
      Get.context!,
      PopRoute(
        child: PiTransferPage(
          user: chatUserDisplayNameFor(message),
          userId: message.userOId > 0 ? message.userOId.toString() : '',
          userName: targetUserName,
          onEditingCompleteText: (text) async {
            final raw = text.toString().trim();
            if (raw.isEmpty) return;
            final point = int.tryParse(raw);
            if (point == null || point <= 0) {
              ToastManager.showToast('请输入有效积分');
              return;
            }
            final result = await imController.fishpi.user.transfer(
              targetUserName,
              point,
              '',
            );
            ToastManager.showToast(result.success ? '转账成功' : result.msg);
          },
        ),
      ),
    );
  }

  Future<bool> sendRedPacket(RedPacketMessage redpacket) async {
    if (!isGroup.value || isSendingRedPacket.value) return false;

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
    if (!isGroup.value || chat.oId.isEmpty) {
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

  void _scheduleAutoGrabRedPacket(ChatRoomMessage chat) {
    if (!isGroup.value || !chat.isRedpacket || chat.oId.isEmpty) return;

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
    if (isClose.value ||
        !isGroup.value ||
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
    var current = userInfo.value;
    if (current.userName.isEmpty) {
      current = imController.fishpi.user.current;
    }
    if (current.userName.isEmpty) {
      try {
        current = await imController.fishpi.user.info();
        userInfo.value = current;
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

  Future<bool> setTopic(String topic) async {
    if (!isGroup.value || isSettingTopic.value) return false;

    final normalized = ChatTopicUtils.normalizeTopic(topic);
    final error = ChatTopicUtils.validateTopic(normalized);
    if (error != null) {
      ToastManager.showToast(error);
      return false;
    }

    isSettingTopic.value = true;
    try {
      final result = await imController.fishpi.chatroom.send(
        '[setdiscuss]$normalized[/setdiscuss]',
      );
      if (!result.success) {
        throw result.msg.isEmpty ? '设置话题失败' : result.msg;
      }
      currentTopic.value = normalized;
      ToastManager.showToast(normalized.isEmpty ? '已清空话题' : '话题已更新');
      return true;
    } catch (e) {
      ToastManager.showToast('设置话题失败：$e');
      return false;
    } finally {
      isSettingTopic.value = false;
    }
  }

  Future<void> loadBarrageCost() async {
    if (!isGroup.value || barrageCost.value != null) return;
    try {
      barrageCost.value = await imController.fishpi.chatroom.barragePay();
    } catch (_) {
      barrageCost.value = BarrageCost();
    }
  }

  Future<void> loadExtensions() async {
    if (!isGroup.value) {
      extensions.clear();
      return;
    }
    try {
      await ChatRoomExtensionStore.init();
      extensions.assignAll(await ChatRoomExtensionStore.getEnabled());
    } catch (_) {
      extensions.clear();
    }
  }

  Future<String> _applyBeforeSendExtensions(String text) async {
    var nextText = text;
    for (final extension in extensions.toList()) {
      if (!extension.canTrigger(ChatRoomExtensionTrigger.beforeSend)) continue;
      final result = await _extensionRuntime.renderForTrigger(
        extension: extension,
        trigger: ChatRoomExtensionTrigger.beforeSend,
        message: _localSentMessage(nextText),
        // 发送前小尾巴应当每次发送都生效，冷却只用于事件自动响应。
        respectCooldown: false,
      );
      if (result == null || result.text.trim().isEmpty) continue;
      nextText = result.text;
    }
    return nextText;
  }

  Future<Map<String, String>> extensionContextValues() {
    return _extensionRuntime.contextValues(
      extension: const ChatRoomExtension(
        name: '上下文',
        template: r'${me.liveness}',
      ),
    );
  }

  Future<UserInfo> _loadCurrentUserForExtension() async {
    var current = userInfo.value;
    if (current.userName.isNotEmpty) return current;
    current = imController.fishpi.user.current;
    if (current.userName.isNotEmpty) {
      userInfo.value = current;
      return current;
    }
    current = await imController.fishpi.user.info();
    userInfo.value = current;
    return current;
  }

  void _triggerReceiveExtensions(ChatRoomMessage message) {
    if (!isGroup.value || _isOwnMessage(message)) return;
    final trigger = ChatRoomExtensionRuntime.triggerForReceivedMessage(message);
    if (trigger == null) return;
    _runExtensionTriggers(trigger, message: message);
  }

  Future<void> _runExtensionTriggers(
    String trigger, {
    ChatRoomMessage? message,
  }) async {
    if (!isGroup.value || extensions.isEmpty) return;
    for (final extension in extensions.toList()) {
      final result = await _extensionRuntime.renderForTrigger(
        extension: extension,
        trigger: trigger,
        message: message,
      );
      if (result == null) continue;
      await _handleExtensionTriggerResult(result);
    }
  }

  Future<void> _handleExtensionTriggerResult(
    ChatRoomExtensionRenderResult result,
  ) async {
    switch (result.extension.triggerAction) {
      case ChatRoomExtensionTriggerAction.insert:
        insertExtensionResult(result.text);
        return;
      case ChatRoomExtensionTriggerAction.autoSend:
        if (!ChatRoomExtensionRuntime.canAutoSend(result.extension)) {
          _showExtensionTriggerPreview(result);
          return;
        }
        await _sendComposedText(
          result.text,
          clearComposerOnSuccess: false,
          triggerExtensions: false,
        );
        return;
      case ChatRoomExtensionTriggerAction.preview:
      default:
        _showExtensionTriggerPreview(result);
        return;
    }
  }

  void _showExtensionTriggerPreview(ChatRoomExtensionRenderResult result) {
    if (Get.context == null) return;
    Get.bottomSheet(
      ChatRoomExtensionTriggerSheet(
        result: result,
        onInsert: insertExtensionResult,
        onSend: sendExtensionResult,
      ),
      backgroundColor: CupertinoColors.transparent,
      isScrollControlled: true,
    );
  }

  ChatRoomMessage _localSentMessage(String text) {
    final current = userInfo.value;
    return ChatRoomMessage(
      content: text,
      md: text,
      userName: current.userName,
      nickname: current.nickname,
      userOId: int.tryParse(current.oId) ?? 0,
      avatarURL: current.avatarURL,
      time: DateTime.now().toLocal().toString().split('.').first,
    );
  }

  bool _isOwnMessage(ChatRoomMessage message) {
    final current = userInfo.value.userName.isNotEmpty
        ? userInfo.value
        : imController.fishpi.user.current;
    final currentName = current.userName.trim();
    final currentId = current.oId.trim();
    return (currentName.isNotEmpty && message.userName == currentName) ||
        (currentId.isNotEmpty && message.userOId.toString() == currentId);
  }

  Future<bool> sendBarrager(String content, String color) async {
    if (!isGroup.value || isSendingBarrager.value) return false;

    final normalizedContent = ChatBarragerUtils.normalizeContent(content);
    final error = ChatBarragerUtils.validateContent(normalizedContent);
    if (error != null) {
      ToastManager.showToast(error);
      return false;
    }

    isSendingBarrager.value = true;
    try {
      final result = await imController.fishpi.chatroom.barrage(
        normalizedContent,
        color: ChatBarragerUtils.normalizeColor(color),
      );
      if (!result.success) {
        throw result.msg.isEmpty ? '发送弹幕失败' : result.msg;
      }
      ToastManager.showToast('弹幕已发送');
      return true;
    } catch (e) {
      ToastManager.showToast(
        AppErrorMessage.friendly(e, fallback: '发送弹幕失败'),
      );
      return false;
    } finally {
      isSendingBarrager.value = false;
    }
  }

  void dismissBarrager(String id) {
    barragers.removeWhere((item) => item.id == id);
  }

  Future<void> startVoiceRecord() async {
    if (!isGroup.value) {
      ToastManager.showToast('私聊暂不支持语音消息');
      return;
    }
    if (isRecordingVoice.value || isSendingVoice.value) return;

    try {
      final recorder = _voiceRecorderInstance;
      final hasPermission = await recorder.hasPermission();
      if (!hasPermission) {
        ToastManager.showToast('需要麦克风权限才能发送语音消息');
        return;
      }

      final path = _voiceTempPath();
      await recorder.start(
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
      ToastManager.showToast(
        AppErrorMessage.friendly(e, fallback: '开始录音失败'),
      );
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
      final path = await _voiceRecorder?.stop() ?? _voiceRecordPath;
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
      ToastManager.showToast(
        AppErrorMessage.friendly(e, fallback: '语音发送失败'),
      );
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
        await _voiceRecorder?.cancel();
      } catch (_) {}
    }
    _deleteVoiceFile(_voiceRecordPath);
    _voiceRecordPath = null;
    _voiceStartedAt = null;
    _isStoppingVoice = false;
    isRecordingVoice.value = false;
    voiceRecordSeconds.value = 0;
  }

  AudioRecorder get _voiceRecorderInstance {
    return _voiceRecorder ??= AudioRecorder();
  }

  Future<void> loadEmojis() async {
    try {
      await ChatEmojiCache.init();
      final cached = await ChatEmojiCache.getDiyEmojis();
      if (cached.isNotEmpty) {
        diyEmojiList.assignAll(cached);
      }
    } catch (_) {}
  }

  Future<void> ensureDiyEmojiRemoteLoaded() async {
    if (_hasLoadedRemoteEmojis) return;
    _hasLoadedRemoteEmojis = true;
    try {
      await ChatEmojiCache.init();
      final remote = await (_diyEmojiRemoteLoader?.call() ??
          imController.fishpi.emoji.get());
      await ChatEmojiCache.saveDiyEmojis(remote);
      diyEmojiList.assignAll(remote);
    } catch (_) {
      _hasLoadedRemoteEmojis = false;
    }
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

  Future<void> _loadChatRoomBlockedUsers() async {
    if (!isGroup.value) {
      _chatRoomBlockedUsers.clear();
      return;
    }

    try {
      await ChatRoomBlockList.init();
      _chatRoomBlockedUsers
        ..clear()
        ..addAll(await ChatRoomBlockList.getAllUser());
    } catch (_) {
      _chatRoomBlockedUsers.clear();
    }
  }

  Iterable<ChatRoomBlockedUser> get _activeChatRoomBlockedUsers {
    if (!isGroup.value) return const <ChatRoomBlockedUser>[];
    return _chatRoomBlockedUsers;
  }

  bool _isMessageBlocked(ChatRoomMessage message) {
    return ChatMessageUtils.isBlockedMessage(
      message,
      _blackUsers,
      chatRoomBlockedUsers: _activeChatRoomBlockedUsers,
    );
  }

  bool _isBarragerBlocked(BarragerMsg message) {
    return ChatBarragerUtils.isBlockedBarrager(
      message,
      _blackUsers,
      chatRoomBlockedUsers: _activeChatRoomBlockedUsers,
    );
  }

  List<ChatRoomMessage> _visibleMessages(
    Iterable<ChatRoomMessage> messages,
  ) {
    return ChatMessageUtils.visibleMessages(
      messages,
      _blackUsers,
      chatRoomBlockedUsers: _activeChatRoomBlockedUsers,
    );
  }

  int get _messageMemoryLimit {
    return historyPage.value > 1
        ? MemoryLimits.chatHistoryMessages
        : MemoryLimits.chatRealtimeMessages;
  }

  void _replaceMessages(Iterable<ChatRoomMessage> messages) {
    messageList.assignAll(messages);
    _syncDisplayGroups();
  }

  void _syncDisplayGroups() {
    if (isGroup.value) {
      displayGroups.assignAll(
        ChatMessageUtils.groupConsecutiveDuplicateMessages(messageList),
      );
      return;
    }

    displayGroups.assignAll(
      messageList.map((message) => ChatMessageGroup(message: message)),
    );
  }

  void _logMemorySnapshot(String source) {
    MemorySnapshot.log(
      source: source,
      chatMessages: messageList.length,
    );
  }

  Future<void> _reloadBlackUsersAndFilterMessages() async {
    await _loadBlackUsers();
    _replaceMessages(
      ChatMessageUtils.trimChatRoomMessages(
        _visibleMessages(messageList),
        _messageMemoryLimit,
      ),
    );
  }

  Future<void> _reloadChatRoomBlockedUsersAndFilterMessages() async {
    await _loadChatRoomBlockedUsers();
    _replaceMessages(
      ChatMessageUtils.trimChatRoomMessages(
        _visibleMessages(messageList),
        _messageMemoryLimit,
      ),
    );
  }

  @visibleForTesting
  void debugReplaceMessagesForTest(Iterable<ChatRoomMessage> messages) {
    _replaceMessages(messages);
  }

  @visibleForTesting
  void debugUpdateRedPacketStatusForTest(RedPacketStatusMsg status) {
    _updateRedPacketStatus(status);
  }

  @visibleForTesting
  Timer? get debugScrollToBottomTimer => _scrollToBottomTimer;

  Future<void> _loadAutoGrabConfig() async {
    try {
      await ChatRoomAutoGrabSettings.init();
      autoGrabConfig.value = await ChatRoomAutoGrabSettings.getConfig();
      if (!autoGrabConfig.value.enabled) {
        _cancelAutoGrabTimers();
      }
    } catch (_) {
      autoGrabConfig.value = ChatRoomAutoGrabConfig.defaults();
      _cancelAutoGrabTimers();
    }
  }

  void _cancelAutoGrabTimers() {
    for (final timer in _autoGrabTimers.values) {
      timer.cancel();
    }
    _autoGrabTimers.clear();
    _autoGrabScheduledIds.clear();
  }

  void _updateRedPacketStatus(RedPacketStatusMsg? status) {
    if (status == null || status.oId.isEmpty) return;
    _replaceMessages(
      messageList
          .map((message) => ChatRedPacketUtils.updateStatus(message, status))
          .toList(),
    );
  }

  void _appendBarrager(BarragerMsg? message) {
    if (!isGroup.value || message == null) return;
    if (ChatBarragerUtils.normalizeContent(message.barragerContent).isEmpty) {
      return;
    }
    if (_isBarragerBlocked(message)) return;

    final track = _barragerTrack % 4;
    _barragerTrack++;
    _barragerSequence++;
    barragers.add(
      ChatBarragerItem(
        id: '${DateTime.now().microsecondsSinceEpoch}_$_barragerSequence',
        message: message,
        track: track,
      ),
    );

    // 弹幕是短生命周期 UI，保留最近几条即可，避免极端刷屏时堆积动画对象。
    if (barragers.length > 12) {
      barragers.removeRange(0, barragers.length - 12);
    }
  }

  @override
  void onClose() {
    isClose.value = true;
    _logMemorySnapshot('聊天页关闭前');
    _chatRoomSubscription?.cancel();
    _privateChatSubscription?.cancel();
    _blackListSubscription?.cancel();
    _chatRoomBlockListSubscription?.cancel();
    _autoGrabSettingsSubscription?.cancel();
    _extensionSubscription?.cancel();
    _remarkSubscription?.cancel();
    _cancelAutoGrabTimers();
    _scrollToBottomTimer?.cancel();
    barragers.clear();
    _stopVoiceTimer();
    _voiceRecorder?.dispose();
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
