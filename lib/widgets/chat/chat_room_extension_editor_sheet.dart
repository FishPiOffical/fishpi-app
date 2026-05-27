import 'package:fishpi_app/core/sql/chat_room_extension_store.dart';
import 'package:fishpi_app/res/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatRoomExtensionEditorSheet extends StatefulWidget {
  final ChatRoomExtension? extension;
  final Future<String?> Function(ChatRoomExtension extension) onSave;

  const ChatRoomExtensionEditorSheet({
    required this.onSave,
    this.extension,
    super.key,
  });

  @override
  State<ChatRoomExtensionEditorSheet> createState() =>
      _ChatRoomExtensionEditorSheetState();
}

class _ChatRoomExtensionEditorSheetState
    extends State<ChatRoomExtensionEditorSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _iconController;
  late final TextEditingController _templateController;
  late final TextEditingController _cooldownController;
  late bool _enabled;
  late bool _autoSendEnabled;
  late String _triggerAction;
  late Set<String> _triggers;
  late Set<String> _dataScopes;
  final List<_EditableExtensionField> _fields = [];
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final extension = widget.extension;
    _nameController = TextEditingController(text: extension?.name ?? '');
    _iconController = TextEditingController(text: extension?.icon ?? '扩');
    _templateController =
        TextEditingController(text: extension?.template ?? '');
    _cooldownController = TextEditingController(
      text: (extension?.cooldownSeconds ??
              ChatRoomExtensionTriggerAction.defaultCooldownSeconds)
          .toString(),
    );
    _enabled = extension?.enabled ?? true;
    _autoSendEnabled = extension?.autoSendEnabled ?? false;
    _triggerAction =
        extension?.triggerAction ?? ChatRoomExtensionTriggerAction.preview;
    _triggers = (extension?.triggers ?? const [ChatRoomExtensionTrigger.manual])
        .toSet();
    _dataScopes =
        (extension?.dataScopes ?? ChatRoomExtensionDataScope.defaults).toSet();
    for (final field in extension?.fields ?? const <ChatRoomExtensionField>[]) {
      _fields.add(_EditableExtensionField.fromField(field));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _iconController.dispose();
    _templateController.dispose();
    _cooldownController.dispose();
    for (final field in _fields) {
      field.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        key: const ValueKey('chat_room_extension_editor_sheet'),
        width: 1.sw,
        constraints: BoxConstraints(maxHeight: 0.9.sh),
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
        decoration: BoxDecoration(
          color: Styles.titleBarColor,
          border: Styles.commonBorder,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTitle(),
              14.verticalSpace,
              _buildInput(
                controller: _nameController,
                label: '扩展名称',
                hintText: '例如：摸鱼日报',
              ),
              10.verticalSpace,
              _buildInput(
                controller: _iconController,
                label: '图标文字',
                hintText: '例如：报',
                maxLength: 2,
              ),
              10.verticalSpace,
              _buildSwitch(),
              12.verticalSpace,
              _buildTriggerSection(),
              12.verticalSpace,
              _buildTriggerActionSection(),
              12.verticalSpace,
              _buildDataScopeSection(),
              12.verticalSpace,
              _buildInput(
                controller: _templateController,
                label: '消息模板',
                hintText: r'例如：今天摸鱼进度：${进度}%',
                maxLines: 5,
              ),
              14.verticalSpace,
              _buildFieldHeader(),
              for (var i = 0; i < _fields.length; i++) ...[
                10.verticalSpace,
                _buildFieldCard(i, _fields[i]),
              ],
              if (_error != null) ...[
                12.verticalSpace,
                Text(
                  _error!,
                  key: const ValueKey('chat_room_extension_editor_error'),
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              16.verticalSpace,
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Row(
      children: [
        Expanded(
          child: Text(
            widget.extension == null ? '新增扩展' : '编辑扩展',
            style: TextStyle(
              color: Styles.primaryTextColor,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.close, size: 22.w, color: Styles.primaryTextColor),
        ),
      ],
    );
  }

  Widget _buildSwitch() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Styles.commonBorder,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '启用扩展',
              style: TextStyle(
                color: Styles.primaryTextColor,
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Switch(
            value: _enabled,
            activeThumbColor: Styles.primaryColor,
            onChanged: (value) {
              setState(() => _enabled = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFieldHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            '输入字段',
            style: TextStyle(
              color: Styles.primaryTextColor,
              fontSize: 17.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _buildSmallButton(
          key: const ValueKey('chat_room_extension_add_field_button'),
          text: '添加字段',
          icon: Icons.add,
          onTap: () {
            if (_fields.length >= ChatRoomExtensionStore.maxFields) {
              setState(() =>
                  _error = '单个扩展最多 ${ChatRoomExtensionStore.maxFields} 个字段');
              return;
            }
            setState(() => _fields.add(_EditableExtensionField()));
          },
        ),
      ],
    );
  }

  Widget _buildTriggerSection() {
    return _buildPanel(
      title: '触发时间',
      child: Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: [
          for (final trigger in ChatRoomExtensionTrigger.values)
            _buildToggleChip(
              key: ValueKey('chat_room_extension_trigger_$trigger'),
              text: ChatRoomExtensionTrigger.labelOf(trigger),
              selected: _triggers.contains(trigger),
              onTap: () {
                setState(() {
                  if (_triggers.contains(trigger)) {
                    _triggers.remove(trigger);
                  } else {
                    _triggers.add(trigger);
                  }
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTriggerActionSection() {
    return _buildPanel(
      title: '触发后动作',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              for (final action in ChatRoomExtensionTriggerAction.values)
                _buildToggleChip(
                  key: ValueKey('chat_room_extension_action_$action'),
                  text: ChatRoomExtensionTriggerAction.labelOf(action),
                  selected: _triggerAction == action,
                  onTap: () {
                    setState(() => _triggerAction = action);
                  },
                ),
            ],
          ),
          10.verticalSpace,
          GestureDetector(
            onTap: () => setState(() => _autoSendEnabled = !_autoSendEnabled),
            child: Row(
              children: [
                Checkbox(
                  key: const ValueKey('chat_room_extension_auto_send_switch'),
                  value: _autoSendEnabled,
                  onChanged: (value) {
                    setState(() => _autoSendEnabled = value == true);
                  },
                ),
                Expanded(
                  child: Text(
                    '允许这个扩展自动发送消息',
                    style: TextStyle(
                      color: Styles.primaryTextColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          8.verticalSpace,
          _buildInput(
            controller: _cooldownController,
            label: '冷却时间（秒）',
            hintText: '自动发送不少于 10 秒',
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget _buildDataScopeSection() {
    return _buildPanel(
      title: '可读取数据',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '模板可使用当前用户、触发消息、聊天室话题和当前时间变量，例如 '
            r'${me.point}、${me.liveness}、${message.preview}、${room.topic}。',
            style: TextStyle(
              color: const Color(0xFF777777),
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          6.verticalSpace,
          Text(
            r'勾选“发消息时”后，${message.content} 是输入框里准备发送的内容，模板输出会替换本次发送正文。',
            style: TextStyle(
              color: const Color(0xFF777777),
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          10.verticalSpace,
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _buildToggleChip(
                key: const ValueKey('chat_room_extension_scope_me'),
                text: '我的数据',
                selected: _dataScopes.contains(ChatRoomExtensionDataScope.me),
                onTap: () => _toggleScope(ChatRoomExtensionDataScope.me),
              ),
              _buildToggleChip(
                key: const ValueKey('chat_room_extension_scope_message'),
                text: '消息数据',
                selected:
                    _dataScopes.contains(ChatRoomExtensionDataScope.message),
                onTap: () => _toggleScope(ChatRoomExtensionDataScope.message),
              ),
              _buildToggleChip(
                key: const ValueKey('chat_room_extension_scope_room'),
                text: '聊天室数据',
                selected: _dataScopes.contains(ChatRoomExtensionDataScope.room),
                onTap: () => _toggleScope(ChatRoomExtensionDataScope.room),
              ),
              _buildToggleChip(
                key: const ValueKey('chat_room_extension_scope_time'),
                text: '当前时间',
                selected: _dataScopes.contains(ChatRoomExtensionDataScope.time),
                onTap: () => _toggleScope(ChatRoomExtensionDataScope.time),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFieldCard(int index, _EditableExtensionField field) {
    return Container(
      key: ValueKey('chat_room_extension_field_$index'),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Styles.commonBorder,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '字段 ${index + 1}',
                  style: TextStyle(
                    color: Styles.primaryTextColor,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    final removed = _fields.removeAt(index);
                    removed.dispose();
                  });
                },
                child: Icon(
                  Icons.delete_outline,
                  size: 20.w,
                  color: Styles.primaryTextColor,
                ),
              ),
            ],
          ),
          10.verticalSpace,
          _buildInput(
            controller: field.keyController,
            label: '字段 key',
            hintText: '例如：进度',
          ),
          8.verticalSpace,
          _buildInput(
            controller: field.labelController,
            label: '显示名称',
            hintText: '留空时使用字段 key',
          ),
          8.verticalSpace,
          Row(
            children: [
              Expanded(child: _buildTypeSelector(field)),
              10.horizontalSpace,
              Expanded(child: _buildRequiredToggle(field)),
            ],
          ),
          if (field.type == ChatRoomExtensionFieldType.select) ...[
            8.verticalSpace,
            _buildInput(
              controller: field.optionsController,
              label: '选项',
              hintText: '用逗号分隔，例如：早,中,晚',
            ),
          ],
          8.verticalSpace,
          _buildInput(
            controller: field.defaultController,
            label: '默认值',
            hintText: '可选',
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector(_EditableExtensionField field) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
        color: Styles.titleBarColor,
        border: Styles.commonBorder,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          key: const ValueKey('chat_room_extension_field_type'),
          value: field.type,
          isExpanded: true,
          items: [
            for (final type in ChatRoomExtensionFieldType.values)
              DropdownMenuItem(
                value: type,
                child: Text(ChatRoomExtensionFieldType.labelOf(type)),
              ),
          ],
          onChanged: (value) {
            if (value == null) return;
            setState(() => field.type = value);
          },
        ),
      ),
    );
  }

  Widget _buildRequiredToggle(_EditableExtensionField field) {
    return GestureDetector(
      onTap: () => setState(() => field.required = !field.required),
      child: Container(
        height: 48.h,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        decoration: BoxDecoration(
          color: Styles.titleBarColor,
          border: Styles.commonBorder,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          children: [
            Checkbox(
              value: field.required,
              onChanged: (value) {
                setState(() => field.required = value == true);
              },
            ),
            Expanded(
              child: Text(
                '必填',
                style: TextStyle(
                  color: Styles.primaryTextColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required String hintText,
    int maxLines = 1,
    int? maxLength,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Styles.primaryTextColor,
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        5.verticalSpace,
        TextField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            counterText: '',
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 10.h,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(
                color: Styles.primaryTextColor,
                width: 2.w,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(
                color: Styles.primaryTextColor,
                width: 2.w,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSmallButton({
    required Key key,
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      key: key,
      onTap: onTap,
      child: Container(
        height: 34.w,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Styles.commonBorder,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16.w, color: Styles.primaryTextColor),
            4.horizontalSpace,
            Text(
              text,
              style: TextStyle(
                color: Styles.primaryTextColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPanel({
    required String title,
    required Widget child,
  }) {
    return Container(
      width: 1.sw - 32.w,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Styles.commonBorder,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Styles.primaryTextColor,
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          10.verticalSpace,
          child,
        ],
      ),
    );
  }

  Widget _buildToggleChip({
    required Key key,
    required String text,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      key: key,
      onTap: onTap,
      child: Container(
        height: 34.w,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? Styles.primaryTextColor : Styles.titleBarColor,
          border: Styles.commonBorder,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.white : Styles.primaryTextColor,
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      key: const ValueKey('chat_room_extension_save_button'),
      onTap: _saving ? null : _save,
      child: Container(
        width: 1.sw - 32.w,
        height: 44.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Styles.primaryTextColor,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          _saving ? '保存中...' : '保存扩展',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final extension = ChatRoomExtension(
      id: widget.extension?.id ?? '',
      name: _nameController.text,
      icon: _iconController.text,
      enabled: _enabled,
      template: _templateController.text,
      fields: _fields.map((field) => field.toField()).toList(),
      triggers: _triggers.toList(),
      triggerAction: _triggerAction,
      cooldownSeconds: int.tryParse(_cooldownController.text.trim()) ??
          ChatRoomExtensionTriggerAction.defaultCooldownSeconds,
      autoSendEnabled: _autoSendEnabled,
      dataScopes: _dataScopes.toList(),
      createdAt: widget.extension?.createdAt ?? 0,
      updatedAt: widget.extension?.updatedAt ?? 0,
    );
    final error = ChatRoomExtensionStore.validateExtension(extension);
    if (error != null) {
      setState(() => _error = error);
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });
    final saveError = await widget.onSave(extension.normalized());
    if (!mounted) return;
    if (saveError != null) {
      setState(() {
        _saving = false;
        _error = saveError;
      });
      return;
    }
    Navigator.pop(context);
  }

  void _toggleScope(String scope) {
    setState(() {
      if (_dataScopes.contains(scope)) {
        _dataScopes.remove(scope);
      } else {
        _dataScopes.add(scope);
      }
    });
  }
}

class _EditableExtensionField {
  final TextEditingController keyController;
  final TextEditingController labelController;
  final TextEditingController optionsController;
  final TextEditingController defaultController;
  String type;
  bool required;

  _EditableExtensionField({
    String key = '',
    String label = '',
    this.type = ChatRoomExtensionFieldType.text,
    this.required = false,
    String options = '',
    String defaultValue = '',
  })  : keyController = TextEditingController(text: key),
        labelController = TextEditingController(text: label),
        optionsController = TextEditingController(text: options),
        defaultController = TextEditingController(text: defaultValue);

  factory _EditableExtensionField.fromField(ChatRoomExtensionField field) {
    return _EditableExtensionField(
      key: field.key,
      label: field.label,
      type: field.type,
      required: field.required,
      options: field.options.join(','),
      defaultValue: field.defaultValue,
    );
  }

  ChatRoomExtensionField toField() {
    return ChatRoomExtensionField(
      key: keyController.text,
      label: labelController.text,
      type: type,
      required: required,
      options: optionsController.text
          .split(RegExp(r'[,，]'))
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList(),
      defaultValue: defaultController.text,
    );
  }

  void dispose() {
    keyController.dispose();
    labelController.dispose();
    optionsController.dispose();
    defaultController.dispose();
  }
}
