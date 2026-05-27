import 'package:fishpi_app/core/sql/chat_room_extension_store.dart';
import 'package:fishpi_app/res/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatRoomExtensionSheet extends StatefulWidget {
  final List<ChatRoomExtension> extensions;
  final void Function(String text) onInsert;
  final Future<bool> Function(String text) onSend;

  const ChatRoomExtensionSheet({
    required this.extensions,
    required this.onInsert,
    required this.onSend,
    super.key,
  });

  @override
  State<ChatRoomExtensionSheet> createState() => _ChatRoomExtensionSheetState();
}

class _ChatRoomExtensionSheetState extends State<ChatRoomExtensionSheet> {
  ChatRoomExtension? _selected;
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String> _selectValues = {};
  String? _error;
  bool _sending = false;

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        key: const ValueKey('chat_room_extension_sheet'),
        width: 1.sw,
        constraints: BoxConstraints(maxHeight: 0.84.sh),
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
        decoration: BoxDecoration(
          color: Styles.titleBarColor,
          border: Styles.commonBorder,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
        ),
        child: _selected == null ? _buildExtensionList() : _buildForm(),
      ),
    );
  }

  Widget _buildExtensionList() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(
          title: '选择扩展',
          onBack: null,
        ),
        14.verticalSpace,
        if (widget.extensions.isEmpty)
          Container(
            key: const ValueKey('chat_room_extension_empty'),
            height: 120.h,
            alignment: Alignment.center,
            child: Text(
              '暂无可用扩展，可在聊天室设置中添加',
              style: TextStyle(
                color: const Color(0xFF777777),
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        else
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: widget.extensions.length,
              separatorBuilder: (_, __) => 10.verticalSpace,
              itemBuilder: (context, index) {
                final extension = widget.extensions[index];
                return _buildExtensionRow(extension);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildExtensionRow(ChatRoomExtension extension) {
    return GestureDetector(
      key: ValueKey('chat_room_extension_use_${extension.id}'),
      onTap: () => _selectExtension(extension),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Styles.commonBorder,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          children: [
            _buildIcon(extension.icon),
            10.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    extension.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Styles.primaryTextColor,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  4.verticalSpace,
                  Text(
                    extension.fields.isEmpty
                        ? '无需填写参数'
                        : '${extension.fields.length} 个参数',
                    style: TextStyle(
                      color: const Color(0xFF777777),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 22.w),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    final extension = _selected!;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(
            title: extension.name,
            onBack: () {
              setState(() {
                _selected = null;
                _error = null;
                _disposeControllers();
              });
            },
          ),
          14.verticalSpace,
          if (extension.fields.isEmpty)
            Text(
              '这个扩展无需填写参数。',
              style: TextStyle(
                color: const Color(0xFF777777),
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            )
          else
            for (final field in extension.fields) ...[
              _buildFieldInput(field),
              10.verticalSpace,
            ],
          _buildPreview(extension),
          if (_error != null) ...[
            10.verticalSpace,
            Text(
              _error!,
              key: const ValueKey('chat_room_extension_form_error'),
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          16.verticalSpace,
          Row(
            children: [
              Expanded(
                child: _buildBottomButton(
                  key: const ValueKey('chat_room_extension_insert_button'),
                  text: '填入输入框',
                  primary: false,
                  onTap: _insert,
                ),
              ),
              10.horizontalSpace,
              Expanded(
                child: _buildBottomButton(
                  key: const ValueKey('chat_room_extension_send_button'),
                  text: _sending ? '发送中...' : '立即发送',
                  primary: true,
                  onTap: _sending ? null : _send,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader({
    required String title,
    required VoidCallback? onBack,
  }) {
    return Row(
      children: [
        if (onBack != null) ...[
          GestureDetector(
            key: const ValueKey('chat_room_extension_back_button'),
            onTap: onBack,
            child: Icon(
              Icons.chevron_left,
              size: 26.w,
              color: Styles.primaryTextColor,
            ),
          ),
          4.horizontalSpace,
        ],
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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

  Widget _buildFieldInput(ChatRoomExtensionField field) {
    final label = '${field.displayLabel}${field.required ? ' *' : ''}';
    if (field.type == ChatRoomExtensionFieldType.select) {
      final current = _selectValues[field.key] ?? field.defaultValue;
      final value =
          field.options.contains(current) ? current : field.options.first;
      _selectValues[field.key] = value;
      return _buildLabeledBox(
        label: label,
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            key: ValueKey('chat_room_extension_select_${field.key}'),
            value: value,
            isExpanded: true,
            items: [
              for (final option in field.options)
                DropdownMenuItem(value: option, child: Text(option)),
            ],
            onChanged: (next) {
              if (next == null) return;
              setState(() => _selectValues[field.key] = next);
            },
          ),
        ),
      );
    }

    final controller = _controllers[field.key]!;
    return _buildLabeledBox(
      label: label,
      child: TextField(
        key: ValueKey('chat_room_extension_input_${field.key}'),
        controller: controller,
        maxLines: field.type == ChatRoomExtensionFieldType.multiline ? 3 : 1,
        keyboardType: field.type == ChatRoomExtensionFieldType.number
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        onChanged: (_) => setState(() {}),
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildLabeledBox({
    required String label,
    required Widget child,
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
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Styles.commonBorder,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildPreview(ChatRoomExtension extension) {
    return Container(
      key: const ValueKey('chat_room_extension_preview'),
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
            '发送预览',
            style: TextStyle(
              color: const Color(0xFF777777),
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          6.verticalSpace,
          Text(
            _renderPreview(extension).isEmpty
                ? '预览为空'
                : _renderPreview(extension),
            style: TextStyle(
              color: Styles.primaryTextColor,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton({
    required Key key,
    required String text,
    required bool primary,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      key: key,
      onTap: onTap,
      child: Container(
        height: 42.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: primary ? Styles.primaryTextColor : Colors.white,
          border: Styles.commonBorder,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: primary ? Colors.white : Styles.primaryTextColor,
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(String icon) {
    final value = icon.trim().isEmpty ? '扩' : icon.trim();
    return Container(
      width: 42.w,
      height: 42.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Styles.primaryColor,
        border: Styles.commonBorder,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        value.characters.take(2).toString(),
        style: TextStyle(
          color: Styles.primaryTextColor,
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _selectExtension(ChatRoomExtension extension) {
    _disposeControllers();
    for (final field in extension.fields) {
      if (field.type == ChatRoomExtensionFieldType.select) {
        if (field.options.isNotEmpty) {
          _selectValues[field.key] = field.options.contains(field.defaultValue)
              ? field.defaultValue
              : field.options.first;
        }
      } else {
        _controllers[field.key] =
            TextEditingController(text: field.defaultValue);
      }
    }
    setState(() {
      _selected = extension;
      _error = null;
    });
  }

  Map<String, String> _values() {
    final values = <String, String>{};
    for (final entry in _controllers.entries) {
      values[entry.key] = entry.value.text;
    }
    values.addAll(_selectValues);
    return values;
  }

  String _renderPreview(ChatRoomExtension extension) {
    return ChatRoomExtensionStore.render(extension, _values());
  }

  String? _validate() {
    final extension = _selected;
    if (extension == null) return '请选择扩展';
    final valueError = ChatRoomExtensionStore.validateValues(
      extension,
      _values(),
    );
    if (valueError != null) return valueError;
    if (ChatRoomExtensionStore.render(extension, _values()).trim().isEmpty) {
      return '生成内容不能为空';
    }
    return null;
  }

  void _insert() {
    final error = _validate();
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    widget.onInsert(ChatRoomExtensionStore.render(_selected!, _values()));
    Navigator.pop(context);
  }

  Future<void> _send() async {
    final error = _validate();
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    final success = await widget.onSend(
      ChatRoomExtensionStore.render(_selected!, _values()),
    );
    if (!mounted) return;
    setState(() => _sending = false);
    if (success) Navigator.pop(context);
  }

  void _disposeControllers() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    _selectValues.clear();
  }
}
