import 'dart:async';
import 'dart:convert';

import 'package:hive/hive.dart';

class ChatRoomExtensionStore {
  static const int maxExtensions = 50;
  static const int maxFields = 12;
  static const int maxTemplateLength = 1000;
  static const String _boxName = 'chatRoomExtensions';
  static Box? _extensionBox;
  static final StreamController<void> _changes =
      StreamController<void>.broadcast();
  static final RegExp _placeholderRegExp = RegExp(r'\$\{([^}]+)\}');

  static Stream<void> get changes => _changes.stream;

  static Future<void> init() async {
    await _box();
  }

  static Future<List<ChatRoomExtension>> getAll() async {
    final values = (await _box()).values.toList();
    final list = values
        .whereType<Map>()
        .map((item) => ChatRoomExtension.fromJson(
              Map<String, dynamic>.from(item),
            ))
        .where((item) => validateExtension(item) == null)
        .toList();
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  static Future<List<ChatRoomExtension>> getEnabled() async {
    return (await getAll()).where((item) => item.enabled).toList();
  }

  static Future<String?> saveExtension(ChatRoomExtension extension) async {
    final box = await _box();
    final normalized = extension.normalized();
    final error = validateExtension(normalized);
    if (error != null) return error;

    final isNew = normalized.id.isEmpty || !box.containsKey(normalized.id);
    if (isNew && box.length >= maxExtensions) {
      return '扩展数量不能超过 $maxExtensions 个';
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final next = normalized.copyWith(
      id: normalized.id.isEmpty ? _generateId() : normalized.id,
      createdAt: normalized.createdAt == 0 ? now : normalized.createdAt,
      updatedAt: now,
    );
    await box.put(next.id, next.toJson());
    _notifyChange();
    return null;
  }

  static Future<String?> duplicateExtension(ChatRoomExtension extension) async {
    final all = await getAll();
    if (all.length >= maxExtensions) return '扩展数量不能超过 $maxExtensions 个';

    final now = DateTime.now().millisecondsSinceEpoch;
    return saveExtension(
      extension.copyWith(
        id: _generateId(),
        name: '${extension.name} 副本',
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  static Future<void> deleteExtension(String id) async {
    if (id.trim().isEmpty) return;
    await (await _box()).delete(id);
    _notifyChange();
  }

  static Future<void> clear() async {
    await (await _box()).clear();
    _notifyChange();
  }

  static String exportJson(List<ChatRoomExtension> extensions) {
    return const JsonEncoder.withIndent('  ').convert({
      'version': 2,
      'extensions': extensions.map((item) => item.toJson()).toList(),
    });
  }

  static Future<int> importJson(String raw) async {
    final text = raw.trim();
    if (text.isEmpty) throw '剪贴板中没有扩展配置';

    dynamic decoded;
    try {
      decoded = jsonDecode(text);
    } catch (_) {
      throw '扩展配置不是有效 JSON';
    }

    final rawList = decoded is List
        ? decoded
        : decoded is Map
            ? decoded['extensions']
            : null;
    if (rawList is! List) throw '扩展配置格式不正确';

    final incoming = rawList
        .whereType<Map>()
        .map((item) => ChatRoomExtension.fromJson(
              Map<String, dynamic>.from(item),
            ))
        .map((item) => item.normalized())
        .toList();
    if (incoming.isEmpty) throw '没有可导入的扩展';

    for (final extension in incoming) {
      final error = validateExtension(extension);
      if (error != null) throw error;
    }

    final box = await _box();
    if (box.length + incoming.length > maxExtensions) {
      throw '扩展数量不能超过 $maxExtensions 个';
    }

    final existingIds = box.keys.map((item) => item.toString()).toSet();
    final now = DateTime.now().millisecondsSinceEpoch;
    for (final extension in incoming) {
      final id = extension.id.isNotEmpty && !existingIds.contains(extension.id)
          ? extension.id
          : _generateId();
      existingIds.add(id);
      final next = extension.copyWith(
        id: id,
        createdAt: extension.createdAt == 0 ? now : extension.createdAt,
        updatedAt: now,
      );
      await box.put(next.id, next.toJson());
    }
    _notifyChange();
    return incoming.length;
  }

  static String? validateExtension(ChatRoomExtension extension) {
    final normalized = extension.normalized();
    if (normalized.name.isEmpty) return '扩展名称不能为空';
    if (normalized.template.isEmpty) return '消息模板不能为空';
    if (normalized.template.length > maxTemplateLength) {
      return '消息模板不能超过 $maxTemplateLength 字';
    }
    if (normalized.fields.length > maxFields) {
      return '单个扩展最多 $maxFields 个字段';
    }
    if (normalized.triggers.isEmpty) return '请至少选择一个触发时间';
    if (!normalized.triggers.every(ChatRoomExtensionTrigger.values.contains)) {
      return '触发时间不支持';
    }
    if (!ChatRoomExtensionTriggerAction.values
        .contains(normalized.triggerAction)) {
      return '触发后动作不支持';
    }
    if (normalized.triggerAction == ChatRoomExtensionTriggerAction.autoSend &&
        !normalized.autoSendEnabled) {
      return '自动发送需要先开启自动发送开关';
    }
    if (normalized.triggerAction == ChatRoomExtensionTriggerAction.autoSend &&
        normalized.cooldownSeconds <
            ChatRoomExtensionTriggerAction.minAutoSendCooldownSeconds) {
      return '自动发送冷却不能少于 ${ChatRoomExtensionTriggerAction.minAutoSendCooldownSeconds} 秒';
    }
    if (!normalized.dataScopes
        .every(ChatRoomExtensionDataScope.values.contains)) {
      return '可读取数据范围不支持';
    }

    final keys = <String>{};
    for (final field in normalized.fields) {
      if (field.key.isEmpty) return '字段 key 不能为空';
      if (field.key.contains(r'$') ||
          field.key.contains('{') ||
          field.key.contains('}')) {
        return '字段 key 不能包含 \$、{、}';
      }
      if (!keys.add(field.key)) return '字段 key 不能重复';
      if (!ChatRoomExtensionFieldType.values.contains(field.type)) {
        return '字段类型不支持';
      }
      if (field.type == ChatRoomExtensionFieldType.select &&
          field.options.isEmpty) {
        return '单选字段至少需要一个选项';
      }
    }
    return null;
  }

  static String? validateValues(
    ChatRoomExtension extension,
    Map<String, String> values,
  ) {
    for (final field in extension.normalized().fields) {
      final value = values[field.key]?.trim() ?? '';
      if (field.required && value.isEmpty) {
        return '${field.displayLabel}不能为空';
      }
      if (field.type == ChatRoomExtensionFieldType.number &&
          value.isNotEmpty &&
          num.tryParse(value) == null) {
        return '${field.displayLabel}必须是数字';
      }
      if (field.type == ChatRoomExtensionFieldType.select &&
          value.isNotEmpty &&
          !field.options.contains(value)) {
        return '${field.displayLabel}选项无效';
      }
    }
    return null;
  }

  static String render(
    ChatRoomExtension extension,
    Map<String, String> values,
  ) {
    final normalized = extension.normalized();
    return normalized.template.replaceAllMapped(_placeholderRegExp, (match) {
      final key = match.group(1)?.trim() ?? '';
      return values[key]?.trim() ?? '';
    }).trim();
  }

  static Future<void> dispose() async {
    final box = _extensionBox;
    if (box != null && box.isOpen) {
      await box.close();
    }
    _extensionBox = null;
  }

  static Future<Box> _box() async {
    final box = _extensionBox;
    if (box != null && box.isOpen) return box;
    _extensionBox = await Hive.openBox(_boxName);
    return _extensionBox!;
  }

  static String _generateId() =>
      DateTime.now().microsecondsSinceEpoch.toString();

  static void _notifyChange() {
    if (!_changes.isClosed) _changes.add(null);
  }
}

class ChatRoomExtensionBuiltInTemplates {
  ChatRoomExtensionBuiltInTemplates._();

  static const tail = ChatRoomExtensionTemplate(
    id: 'tail',
    name: '小尾巴',
    description: '发消息时自动在正文后附加昵称、积分、活跃度和时间。',
    extension: ChatRoomExtension(
      name: '小尾巴',
      icon: '尾',
      template: r'''${message.content}

-- ${me.nickname} · 积分 ${me.point} · 活跃 ${me.liveness} · ${now}''',
      triggers: [ChatRoomExtensionTrigger.beforeSend],
      triggerAction: ChatRoomExtensionTriggerAction.insert,
      cooldownSeconds: 0,
      dataScopes: [
        ChatRoomExtensionDataScope.me,
        ChatRoomExtensionDataScope.message,
        ChatRoomExtensionDataScope.time,
      ],
    ),
  );

  static const dailyStatus = ChatRoomExtensionTemplate(
    id: 'daily_status',
    name: '今日状态',
    description: '手动填写状态、摸鱼进度和备注，生成一条状态消息。',
    extension: ChatRoomExtension(
      name: '今日状态',
      icon: '状',
      template: r'''今日状态：${状态}
摸鱼进度：${进度}%
当前积分：${me.point} · 活跃度：${me.liveness}
聊天室话题：${room.topic}
${备注}''',
      fields: [
        ChatRoomExtensionField(
          key: '状态',
          label: '今天状态',
          type: ChatRoomExtensionFieldType.select,
          required: true,
          options: ['摸鱼中', '搬砖中', '准备下班', '灵感充电'],
          defaultValue: '摸鱼中',
        ),
        ChatRoomExtensionField(
          key: '进度',
          label: '摸鱼进度',
          type: ChatRoomExtensionFieldType.number,
          required: true,
          defaultValue: '60',
        ),
        ChatRoomExtensionField(
          key: '备注',
          label: '补充说明',
          type: ChatRoomExtensionFieldType.multiline,
        ),
      ],
      triggers: [ChatRoomExtensionTrigger.manual],
      triggerAction: ChatRoomExtensionTriggerAction.preview,
      dataScopes: [
        ChatRoomExtensionDataScope.me,
        ChatRoomExtensionDataScope.room,
      ],
    ),
  );

  static const imageCaption = ChatRoomExtensionTemplate(
    id: 'image_caption',
    name: '自动图片说明',
    description: '收到单张图片时生成说明草稿，确认后可发送或填入输入框。',
    extension: ChatRoomExtension(
      name: '自动图片说明',
      icon: '图',
      template: r'''图片说明草稿
来自：${message.senderName}
图片地址：${message.imageUrl}
发送时间：${message.time}

我看到了这张图，可以补一句想法再发送。''',
      triggers: [ChatRoomExtensionTrigger.receiveSingleImage],
      triggerAction: ChatRoomExtensionTriggerAction.preview,
      dataScopes: [
        ChatRoomExtensionDataScope.message,
      ],
    ),
  );

  static const all = [
    tail,
    dailyStatus,
    imageCaption,
  ];
}

class ChatRoomExtensionTemplate {
  final String id;
  final String name;
  final String description;
  final ChatRoomExtension extension;

  const ChatRoomExtensionTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.extension,
  });
}

class ChatRoomExtension {
  final String id;
  final String name;
  final String icon;
  final bool enabled;
  final String template;
  final List<ChatRoomExtensionField> fields;
  final List<String> triggers;
  final String triggerAction;
  final int cooldownSeconds;
  final bool autoSendEnabled;
  final List<String> dataScopes;
  final int createdAt;
  final int updatedAt;

  const ChatRoomExtension({
    this.id = '',
    required this.name,
    this.icon = '扩',
    this.enabled = true,
    required this.template,
    this.fields = const [],
    this.triggers = const [ChatRoomExtensionTrigger.manual],
    this.triggerAction = ChatRoomExtensionTriggerAction.preview,
    this.cooldownSeconds =
        ChatRoomExtensionTriggerAction.defaultCooldownSeconds,
    this.autoSendEnabled = false,
    this.dataScopes = ChatRoomExtensionDataScope.defaults,
    this.createdAt = 0,
    this.updatedAt = 0,
  });

  factory ChatRoomExtension.fromJson(Map<String, dynamic> json) {
    return ChatRoomExtension(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '扩',
      enabled: json['enabled'] != false,
      template: json['template']?.toString() ?? '',
      fields: List.from(json['fields'] ?? [])
          .whereType<Map>()
          .map((item) => ChatRoomExtensionField.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .toList(),
      triggers: List.from(json['triggers'] ??
              // 旧版扩展没有触发器字段，迁移时只允许手动触发，避免升级后自动响应消息。
              const [ChatRoomExtensionTrigger.manual])
          .map((item) => item.toString())
          .where((item) => item.trim().isNotEmpty)
          .toList(),
      triggerAction: json['triggerAction']?.toString() ??
          ChatRoomExtensionTriggerAction.preview,
      cooldownSeconds:
          int.tryParse(json['cooldownSeconds']?.toString() ?? '') ??
              ChatRoomExtensionTriggerAction.defaultCooldownSeconds,
      autoSendEnabled: json['autoSendEnabled'] == true,
      dataScopes: List.from(
        json['dataScopes'] ?? ChatRoomExtensionDataScope.defaults,
      )
          .map((item) => item.toString())
          .where((item) => item.trim().isNotEmpty)
          .toList(),
      createdAt: int.tryParse(json['createdAt']?.toString() ?? '') ?? 0,
      updatedAt: int.tryParse(json['updatedAt']?.toString() ?? '') ?? 0,
    );
  }

  bool canTrigger(String trigger) => triggers.contains(trigger);

  ChatRoomExtension normalized() {
    final normalizedTriggers = triggers
        .map((item) => item.trim())
        .where(ChatRoomExtensionTrigger.values.contains)
        .toSet()
        .toList();
    final normalizedScopes = dataScopes
        .map((item) => item.trim())
        .where(ChatRoomExtensionDataScope.values.contains)
        .toSet()
        .toList();
    return copyWith(
      name: name.trim(),
      icon: icon.trim().isEmpty ? '扩' : icon.trim(),
      template: template.trim(),
      fields: fields.map((field) => field.normalized()).toList(),
      triggers: normalizedTriggers.isEmpty
          ? const [ChatRoomExtensionTrigger.manual]
          : normalizedTriggers,
      triggerAction:
          ChatRoomExtensionTriggerAction.values.contains(triggerAction)
              ? triggerAction
              : ChatRoomExtensionTriggerAction.preview,
      cooldownSeconds: cooldownSeconds < 0
          ? ChatRoomExtensionTriggerAction.defaultCooldownSeconds
          : cooldownSeconds,
      dataScopes: normalizedScopes.isEmpty
          ? ChatRoomExtensionDataScope.defaults
          : normalizedScopes,
    );
  }

  ChatRoomExtension copyWith({
    String? id,
    String? name,
    String? icon,
    bool? enabled,
    String? template,
    List<ChatRoomExtensionField>? fields,
    List<String>? triggers,
    String? triggerAction,
    int? cooldownSeconds,
    bool? autoSendEnabled,
    List<String>? dataScopes,
    int? createdAt,
    int? updatedAt,
  }) {
    return ChatRoomExtension(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      enabled: enabled ?? this.enabled,
      template: template ?? this.template,
      fields: fields ?? List<ChatRoomExtensionField>.from(this.fields),
      triggers: triggers ?? List<String>.from(this.triggers),
      triggerAction: triggerAction ?? this.triggerAction,
      cooldownSeconds: cooldownSeconds ?? this.cooldownSeconds,
      autoSendEnabled: autoSendEnabled ?? this.autoSendEnabled,
      dataScopes: dataScopes ?? List<String>.from(this.dataScopes),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'enabled': enabled,
      'template': template,
      'fields': fields.map((item) => item.toJson()).toList(),
      'triggers': triggers,
      'triggerAction': triggerAction,
      'cooldownSeconds': cooldownSeconds,
      'autoSendEnabled': autoSendEnabled,
      'dataScopes': dataScopes,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class ChatRoomExtensionField {
  final String key;
  final String label;
  final String type;
  final bool required;
  final List<String> options;
  final String defaultValue;

  const ChatRoomExtensionField({
    required this.key,
    this.label = '',
    this.type = ChatRoomExtensionFieldType.text,
    this.required = false,
    this.options = const [],
    this.defaultValue = '',
  });

  factory ChatRoomExtensionField.fromJson(Map<String, dynamic> json) {
    return ChatRoomExtensionField(
      key: json['key']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      type: json['type']?.toString() ?? ChatRoomExtensionFieldType.text,
      required: json['required'] == true,
      options: List.from(json['options'] ?? [])
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList(),
      defaultValue: json['defaultValue']?.toString() ?? '',
    );
  }

  String get displayLabel => label.trim().isEmpty ? key : label.trim();

  ChatRoomExtensionField normalized() {
    return ChatRoomExtensionField(
      key: key.trim(),
      label: label.trim(),
      type: ChatRoomExtensionFieldType.values.contains(type)
          ? type
          : ChatRoomExtensionFieldType.text,
      required: required,
      options: options
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toSet()
          .toList(),
      defaultValue: defaultValue.trim(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'label': label,
      'type': type,
      'required': required,
      'options': options,
      'defaultValue': defaultValue,
    };
  }
}

class ChatRoomExtensionFieldType {
  static const text = 'text';
  static const multiline = 'multiline';
  static const number = 'number';
  static const select = 'select';

  static const values = [
    text,
    multiline,
    number,
    select,
  ];

  static String labelOf(String type) {
    switch (type) {
      case multiline:
        return '多行文本';
      case number:
        return '数字';
      case select:
        return '单选';
      case text:
      default:
        return '短文本';
    }
  }
}

class ChatRoomExtensionTrigger {
  static const manual = 'manual';
  static const beforeSend = 'beforeSend';
  static const afterSend = 'afterSend';
  static const receiveText = 'receiveText';
  static const receiveSingleImage = 'receiveSingleImage';

  static const values = [
    manual,
    beforeSend,
    afterSend,
    receiveText,
    receiveSingleImage,
  ];

  static String labelOf(String trigger) {
    switch (trigger) {
      case beforeSend:
        return '发消息时';
      case afterSend:
        return '发消息后';
      case receiveText:
        return '收到文字';
      case receiveSingleImage:
        return '收到图片';
      case manual:
      default:
        return '手动使用';
    }
  }
}

class ChatRoomExtensionTriggerAction {
  static const preview = 'preview';
  static const insert = 'insert';
  static const autoSend = 'autoSend';
  static const defaultCooldownSeconds = 10;
  static const minAutoSendCooldownSeconds = 10;

  static const values = [
    preview,
    insert,
    autoSend,
  ];

  static String labelOf(String action) {
    switch (action) {
      case insert:
        return '填入输入框';
      case autoSend:
        return '自动发送';
      case preview:
      default:
        return '预览确认';
    }
  }
}

class ChatRoomExtensionDataScope {
  static const me = 'me';
  static const message = 'message';
  static const room = 'room';
  static const time = 'time';

  static const defaults = [
    me,
    message,
    room,
    time,
  ];

  static const values = defaults;
}
