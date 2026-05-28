import 'package:fishpi/types/chat.dart';
import 'package:fishpi_app/res/styles.dart';
import 'package:fishpi_app/routers/navigator.dart';
import 'package:fishpi_app/utils/pi_utils.dart';
import 'package:fishpi_app/widgets/pi_avatar.dart';
import 'package:fishpi_app/widgets/vip_name_text.dart';
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
        body: RefreshIndicator(
          onRefresh: logic.refreshConversations,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: logic.chatList.length + 1 + _errorItemCount,
            itemBuilder: _buildItem,
          ),
        ),
      ),
    );
  }

  int get _errorItemCount => logic.errorText.value.trim().isEmpty ? 0 : 1;

  Widget _buildItem(BuildContext context, int index) {
    final hasError = _errorItemCount == 1;
    if (hasError && index == 1) {
      return _buildErrorBanner();
    }

    final chatIndex = hasError && index > 1 ? index - 1 : index;
    ChatData? chat = chatIndex == 0 ? null : logic.chatList[chatIndex - 1];
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
                            child: chat != null
                                ? VipNameText(
                                    userId: logic.privatePeerId(chat),
                                    userName: peerName,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: Styles.primaryTextColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                : Text(
                                    '聊天室',
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

  Widget _buildErrorBanner() {
    return Container(
      key: const ValueKey('conversation_error_banner'),
      margin: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Styles.commonBorder,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.cloud_off_outlined,
            size: 18.w,
            color: Colors.redAccent,
          ),
          8.horizontalSpace,
          Expanded(
            child: Text(
              logic.errorText.value,
              style: TextStyle(
                color: Styles.secondaryTextColor,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
          8.horizontalSpace,
          GestureDetector(
            key: const ValueKey('conversation_retry_button'),
            onTap: logic.refreshConversations,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Styles.primaryTextColor,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                '重试',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
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
