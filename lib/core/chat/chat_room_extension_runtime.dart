import 'package:fishpi/types/chatroom.dart';
import 'package:fishpi/types/user.dart';
import 'package:fishpi_app/core/chat/chat_message_utils.dart';
import 'package:fishpi_app/core/sql/chat_room_extension_store.dart';

class ChatRoomExtensionRuntime {
  final Future<UserInfo> Function() userLoader;
  final Future<double> Function() livenessLoader;
  final String Function() topicProvider;
  final DateTime Function() nowProvider;
  final Duration livenessCacheTtl;

  final Map<String, DateTime> _lastTriggeredAt = {};
  double? _cachedLiveness;
  DateTime? _livenessFetchedAt;

  ChatRoomExtensionRuntime({
    required this.userLoader,
    required this.livenessLoader,
    required this.topicProvider,
    DateTime Function()? nowProvider,
    this.livenessCacheTtl = const Duration(seconds: 60),
  }) : nowProvider = nowProvider ?? DateTime.now;

  Future<ChatRoomExtensionRenderResult?> renderForTrigger({
    required ChatRoomExtension extension,
    required String trigger,
    ChatRoomMessage? message,
    Map<String, String> values = const {},
    bool respectCooldown = true,
  }) async {
    final normalized = extension.normalized();
    if (!normalized.enabled || !normalized.canTrigger(trigger)) return null;
    if (trigger != ChatRoomExtensionTrigger.manual &&
        respectCooldown &&
        isCoolingDown(normalized, trigger)) {
      return null;
    }

    final context = await contextValues(
      extension: normalized,
      message: message,
    );
    final text = ChatRoomExtensionStore.render(
      normalized,
      {
        ...values,
        ...context,
      },
    );
    if (text.trim().isEmpty) return null;

    if (trigger != ChatRoomExtensionTrigger.manual && respectCooldown) {
      markTriggered(normalized, trigger);
    }
    return ChatRoomExtensionRenderResult(
      extension: normalized,
      trigger: trigger,
      text: text,
      message: message,
    );
  }

  Future<Map<String, String>> contextValues({
    ChatRoomExtension? extension,
    ChatRoomMessage? message,
  }) async {
    final scopes = extension?.normalized().dataScopes ??
        ChatRoomExtensionDataScope.defaults;
    final values = <String, String>{};
    final template = extension?.template ?? '';

    if (scopes.contains(ChatRoomExtensionDataScope.me)) {
      final user = await _loadCurrentUser();
      values.addAll({
        'me.userName': user.userName,
        'me.nickname': user.nickname,
        'me.point': user.point.toString(),
        'me.onlineMinute': user.onlineMinute.toString(),
        'me.followingCount': user.followingCnt.toString(),
        'me.followerCount': user.followerCnt.toString(),
      });
      if (template.contains(r'${me.liveness}')) {
        values['me.liveness'] = _formatNumber(await _loadLiveness());
      }
    }

    if (scopes.contains(ChatRoomExtensionDataScope.message)) {
      values.addAll(_messageValues(message));
    }

    if (scopes.contains(ChatRoomExtensionDataScope.room)) {
      values['room.topic'] = topicProvider().trim();
    }

    if (scopes.contains(ChatRoomExtensionDataScope.time)) {
      values['now'] = _formatTime(nowProvider());
    }

    return values;
  }

  bool isCoolingDown(ChatRoomExtension extension, String trigger) {
    final seconds = extension.normalized().cooldownSeconds;
    if (seconds <= 0) return false;
    final last = _lastTriggeredAt[_cooldownKey(extension, trigger)];
    if (last == null) return false;
    return nowProvider().difference(last).inSeconds < seconds;
  }

  void markTriggered(ChatRoomExtension extension, String trigger) {
    _lastTriggeredAt[_cooldownKey(extension, trigger)] = nowProvider();
  }

  static String? triggerForReceivedMessage(ChatRoomMessage message) {
    if (ChatMessageUtils.singleImageUrl(message.content) != null) {
      return ChatRoomExtensionTrigger.receiveSingleImage;
    }
    if (_isPlainTextMessage(message)) {
      return ChatRoomExtensionTrigger.receiveText;
    }
    return null;
  }

  static bool canAutoSend(ChatRoomExtension extension) {
    final normalized = extension.normalized();
    return normalized.triggerAction ==
            ChatRoomExtensionTriggerAction.autoSend &&
        normalized.autoSendEnabled &&
        normalized.cooldownSeconds >=
            ChatRoomExtensionTriggerAction.minAutoSendCooldownSeconds;
  }

  static bool _isPlainTextMessage(ChatRoomMessage message) {
    if (message.type != ChatRoomMessageType.msg) return false;
    if (message.isRedpacket || message.isWeather || message.isMusic) {
      return false;
    }
    return ChatMessageUtils.conversationPreview(message.content).isNotEmpty;
  }

  Map<String, String> _messageValues(ChatRoomMessage? message) {
    if (message == null) {
      return const {
        'message.content': '',
        'message.preview': '',
        'message.senderName': '',
        'message.senderUserName': '',
        'message.imageUrl': '',
        'message.time': '',
      };
    }
    return {
      'message.content': message.content,
      'message.preview': ChatMessageUtils.conversationPreview(message.content),
      'message.senderName':
          message.nickname.trim().isEmpty ? message.userName : message.nickname,
      'message.senderUserName': message.userName,
      'message.imageUrl':
          ChatMessageUtils.singleImageUrl(message.content) ?? '',
      'message.time': message.time,
    };
  }

  Future<UserInfo> _loadCurrentUser() async {
    try {
      return await userLoader();
    } catch (_) {
      return UserInfo();
    }
  }

  Future<double> _loadLiveness() async {
    final now = nowProvider();
    final fetchedAt = _livenessFetchedAt;
    if (_cachedLiveness != null &&
        fetchedAt != null &&
        now.difference(fetchedAt) < livenessCacheTtl) {
      return _cachedLiveness!;
    }
    try {
      final value = await livenessLoader();
      _cachedLiveness = value;
      _livenessFetchedAt = now;
      return value;
    } catch (_) {
      return _cachedLiveness ?? 0;
    }
  }

  String _cooldownKey(ChatRoomExtension extension, String trigger) {
    final id = extension.id.isEmpty ? extension.name : extension.id;
    return '$id|$trigger';
  }

  static String _formatNumber(double value) {
    return value == value.roundToDouble()
        ? value.round().toString()
        : value.toStringAsFixed(2);
  }

  static String _formatTime(DateTime time) {
    return time.toLocal().toString().split('.').first;
  }
}

class ChatRoomExtensionRenderResult {
  final ChatRoomExtension extension;
  final String trigger;
  final String text;
  final ChatRoomMessage? message;

  const ChatRoomExtensionRenderResult({
    required this.extension,
    required this.trigger,
    required this.text,
    this.message,
  });

  String get triggerLabel => ChatRoomExtensionTrigger.labelOf(trigger);
}
