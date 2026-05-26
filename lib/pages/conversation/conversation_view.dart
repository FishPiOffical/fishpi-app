import 'package:fishpi/types/chat.dart';
import 'package:fishpi_app/res/styles.dart';
import 'package:fishpi_app/routers/navigator.dart';
import 'package:fishpi_app/utils/pi_utils.dart';
import 'package:fishpi_app/widgets/pi_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../widgets/pi_dashed.dart';
import 'conversation_logic.dart';

class ConversationPage extends StatelessWidget {
  final ConversationLogic logic = Get.find<ConversationLogic>();

  ConversationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: ListView.builder(
          itemCount: logic.chatList.length + 1,
          itemBuilder: _buildItem,
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    ChatData? chat = index == 0 ? null : logic.chatList[index - 1];
    final peerName = chat == null ? '聊天室' : logic.privatePeerName(chat);
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        AppNavigator.toChat(
          isGroup: chat == null,
          userID: chat == null ? null : logic.privatePeerId(chat),
          userName: peerName,
        );
      },
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: Row(
              children: [
                chat != null
                    ? PiAvatar(
                        userName: peerName,
                        avatarURL: logic.privatePeerAvatar(chat),
                        width: 48.w,
                        height: 48.w,
                      )
                    : Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(48.w),
                          border: Border.all(
                            width: 2.w,
                            color: Styles.primaryTextColor,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(48.w),
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 48.w,
                            height: 48.w,
                          ),
                        ),
                      ),
                10.horizontalSpace,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              chat != null
                                  ? logic.displayNameFor(peerName)
                                  : '聊天室',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Styles.primaryTextColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            PiUtils.getChatTime(
                              chat != null
                                  ? chat.time
                                  : logic.chatRoomLastMsg.value.time,
                            ),
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: const Color(0xFF9FA4B4),
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                      Text(
                        chat != null ? chat.preview : _chatRoomPreview(),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Styles.secondaryTextColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          PiDashed(
            dashedWidth: 2.w,
            color: chat == null ? Styles.secondaryTextColor : Styles.c4Color,
          ),
        ],
      ),
    );
  }

  String _chatRoomPreview() {
    final message = logic.chatRoomLastMsg.value;
    if (message.oId.isEmpty && message.content.isEmpty) return '暂无消息';
    final name = logic.displayNameFor(
      message.userName,
      fallback: message.allName,
    );
    return '$name:${PiUtils.getConversationPreview(message.content)}';
  }
}
