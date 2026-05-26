import 'package:fishpi/types/chatroom.dart';
import 'package:fishpi/types/redpacket.dart';
import 'package:fishpi_app/core/chat/chat_red_packet_utils.dart';
import 'package:fishpi_app/res/styles.dart';
import 'package:fishpi_app/widgets/pi_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ChatRedPacketSheet extends StatefulWidget {
  final List<OnlineInfo> onlineUsers;
  final String senderId;
  final Future<bool> Function(RedPacketMessage message) onSubmit;

  const ChatRedPacketSheet({
    super.key,
    required this.onlineUsers,
    required this.senderId,
    required this.onSubmit,
  });

  @override
  State<ChatRedPacketSheet> createState() => _ChatRedPacketSheetState();
}

class _ChatRedPacketSheetState extends State<ChatRedPacketSheet> {
  final _moneyController = TextEditingController();
  final _countController = TextEditingController(text: '1');
  final _msgController = TextEditingController();
  final _receiverController = TextEditingController();
  final _receivers = <String>{};

  String _type = RedPacketType.Random;
  GestureType? _gesture;
  String _error = '';
  bool _submitting = false;

  @override
  void dispose() {
    _moneyController.dispose();
    _countController.dispose();
    _msgController.dispose();
    _receiverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: 1.sw,
        constraints: BoxConstraints(maxHeight: .86.sh),
        padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 16.h),
        decoration: BoxDecoration(
          color: Styles.titleBarColor,
          border: Styles.commonBorder,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              14.verticalSpace,
              _buildTypeSelector(),
              14.verticalSpace,
              _buildInput(
                key: const ValueKey('red_packet_money_input'),
                title: '总积分',
                hintText: '输入积分',
                controller: _moneyController,
                keyboardType: TextInputType.number,
              ),
              if (_type != RedPacketType.Specify) ...[
                12.verticalSpace,
                _buildInput(
                  key: const ValueKey('red_packet_count_input'),
                  title: '红包个数',
                  hintText: '输入个数',
                  controller: _countController,
                  keyboardType: TextInputType.number,
                ),
              ],
              12.verticalSpace,
              _buildInput(
                key: const ValueKey('red_packet_msg_input'),
                title: '祝福语',
                hintText: ChatRedPacketUtils.defaultMessage,
                controller: _msgController,
              ),
              if (_type == RedPacketType.Specify) ...[
                14.verticalSpace,
                _buildReceiverSection(),
              ],
              if (_type == RedPacketType.RockPaperScissors) ...[
                14.verticalSpace,
                _buildGestureSection(),
              ],
              if (_error.isNotEmpty) ...[
                12.verticalSpace,
                Text(
                  _error,
                  key: const ValueKey('red_packet_form_error'),
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              18.verticalSpace,
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Image.asset(
          'assets/images/red-packet.png',
          width: 34.w,
          height: 34.w,
        ),
        10.horizontalSpace,
        Expanded(
          child: Text(
            '发红包',
            style: TextStyle(
              color: Styles.primaryTextColor,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        GestureDetector(
          onTap: _submitting ? null : () => Get.back(),
          child: Icon(
            Icons.close,
            size: 22.w,
            color: Styles.primaryTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildTypeSelector() {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        for (final type in ChatRedPacketUtils.types)
          _buildChoiceChip(
            key: ValueKey('red_packet_type_$type'),
            text: ChatRedPacketUtils.typeName(type),
            selected: _type == type,
            onTap: () {
              setState(() {
                _type = type;
                _error = '';
              });
            },
          ),
      ],
    );
  }

  Widget _buildInput({
    required Key key,
    required String title,
    required String hintText,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Styles.primaryTextColor,
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        6.verticalSpace,
        SizedBox(
          height: 46.h,
          child: PiInput(
            key: key,
            controller: controller,
            hintText: hintText,
            textAlign: TextAlign.left,
            keyboardType: keyboardType,
            textInputAction: TextInputAction.next,
            onInputChanged: (_) {
              if (_error.isNotEmpty) setState(() => _error = '');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReceiverSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '专属接收者',
          style: TextStyle(
            color: Styles.primaryTextColor,
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        6.verticalSpace,
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 46.h,
                child: PiInput(
                  key: const ValueKey('red_packet_receiver_input'),
                  controller: _receiverController,
                  hintText: '输入用户名',
                  textAlign: TextAlign.left,
                  textInputAction: TextInputAction.done,
                  onInputChanged: (_) {},
                ),
              ),
            ),
            8.horizontalSpace,
            _buildSmallButton(
              key: const ValueKey('red_packet_add_receiver_button'),
              text: '添加',
              onTap: _addManualReceiver,
            ),
          ],
        ),
        if (widget.onlineUsers.isNotEmpty) ...[
          10.verticalSpace,
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              for (final user in widget.onlineUsers.take(20))
                _buildChoiceChip(
                  key: ValueKey('red_packet_online_${user.userName}'),
                  text: user.userName,
                  selected: _receivers.contains(user.userName),
                  onTap: () => _toggleReceiver(user.userName),
                ),
            ],
          ),
        ],
        if (_receivers.isNotEmpty) ...[
          10.verticalSpace,
          Wrap(
            spacing: 6.w,
            runSpacing: 6.h,
            children: [
              for (final userName in _receivers)
                _buildSelectedReceiver(userName),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildGestureSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '我的出拳',
          style: TextStyle(
            color: Styles.primaryTextColor,
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        8.verticalSpace,
        Wrap(
          spacing: 8.w,
          children: [
            for (final gesture in GestureType.values)
              _buildChoiceChip(
                key: ValueKey('red_packet_gesture_${gesture.index}'),
                text: ChatRedPacketUtils.gestureName(gesture),
                selected: _gesture == gesture,
                onTap: () {
                  setState(() {
                    _gesture = gesture;
                    _error = '';
                  });
                },
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildChoiceChip({
    required Key key,
    required String text,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      key: key,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? Styles.primaryColor : Colors.white,
          border: Styles.commonBorder,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Styles.primaryTextColor,
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedReceiver(String userName) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Styles.primaryColor,
        border: Styles.commonBorder,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            userName,
            style: TextStyle(
              color: Styles.primaryTextColor,
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          4.horizontalSpace,
          GestureDetector(
            onTap: () => _toggleReceiver(userName),
            child: Icon(
              Icons.close,
              size: 14.w,
              color: Styles.primaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallButton({
    required Key key,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      key: key,
      onTap: onTap,
      child: Container(
        width: 62.w,
        height: 46.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Styles.primaryColor,
          border: Styles.commonBorder,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Styles.primaryTextColor,
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return GestureDetector(
      key: const ValueKey('red_packet_submit_button'),
      onTap: _submitting ? null : _submit,
      child: Opacity(
        opacity: _submitting ? .55 : 1,
        child: Container(
          height: 48.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Styles.primaryTextColor,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            _submitting ? '发送中...' : '塞钱进红包',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _addManualReceiver() {
    final userName = _receiverController.text.trim();
    if (userName.isEmpty) return;
    setState(() {
      _receivers.add(userName);
      _receiverController.clear();
      _error = '';
    });
  }

  void _toggleReceiver(String userName) {
    if (userName.trim().isEmpty) return;
    setState(() {
      if (_receivers.contains(userName)) {
        _receivers.remove(userName);
      } else {
        _receivers.add(userName);
      }
      _error = '';
    });
  }

  Future<void> _submit() async {
    final receivers = _receivers.toList();
    final error = ChatRedPacketUtils.validateForm(
      type: _type,
      moneyText: _moneyController.text,
      countText: _countController.text,
      receivers: receivers,
      gesture: _gesture,
      msg: _msgController.text,
    );
    if (error != null) {
      setState(() => _error = error);
      return;
    }

    final message = ChatRedPacketUtils.buildMessage(
      type: _type,
      moneyText: _moneyController.text,
      countText: _countController.text,
      senderId: widget.senderId,
      receivers: receivers,
      gesture: _gesture,
      msg: _msgController.text,
    );

    setState(() => _submitting = true);
    final success = await widget.onSubmit(message);
    if (!mounted) return;
    setState(() => _submitting = false);
    if (success) Get.back();
  }
}
