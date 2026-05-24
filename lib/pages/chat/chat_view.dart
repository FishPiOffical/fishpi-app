import 'package:fishpi/types/chatroom.dart';
import 'package:fishpi/types/redpacket.dart';
import 'package:fishpi_app/core/chat/chat_message_utils.dart';
import 'package:fishpi_app/res/styles.dart';
import 'package:fishpi_app/utils/pi_utils.dart';
import 'package:fishpi_app/widgets/chat/chat_repeat_avatar_strip.dart';
import 'package:fishpi_app/widgets/pi_avatar.dart';
import 'package:fishpi_app/widgets/pi_msg_dom.dart';
import 'package:fishpi_app/widgets/pi_title_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../widgets/chat/chat_input_box.dart';
import 'chat_logic.dart';

class ChatPage extends StatelessWidget {
  final ChatLogic logic = Get.find<ChatLogic>();

  ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final messageGroups = logic.isGroup.value
            ? ChatMessageUtils.groupConsecutiveDuplicateMessages(
                logic.messageList,
              )
            : logic.messageList
                .map((message) => ChatMessageGroup(message: message))
                .toList();

        return Scaffold(
          appBar: PiTitleBar.back(
            title: logic.isGroup.value
                ? '聊天室'
                : logic.displayNameFor(logic.userName.value),
            rightWidget: logic.isGroup.value
                ? const Icon(
                    Icons.more_horiz,
                    key: ValueKey('chat_room_more_button'),
                    color: Styles.primaryTextColor,
                  )
                : null,
            onRightTap: logic.isGroup.value ? logic.toChatRoomSettings : null,
          ),
          body: Column(
            children: [
              Expanded(
                child: messageGroups.isEmpty
                    ? Container()
                    : GestureDetector(
                        onTap: () {
                          FocusScope.of(Get.context!).requestFocus(FocusNode());
                        },
                        child: Container(
                          width: 1.sw,
                          height: 1.sh,
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                          ),
                          child: ListView.builder(
                            controller: logic.chatRoomController,
                            padding: EdgeInsets.symmetric(vertical: 20.h),
                            itemBuilder: (context, index) =>
                                _buildChatItem(context, messageGroups[index]),
                            itemCount: messageGroups.length,
                          ),
                        ),
                      ),
              ),
              ChatInputBox(
                emojiList: logic.emojiList,
                diyEmojiList: logic.diyEmojiList,
                controller: logic.chatRoomControllerText,
                focusNode: logic.chatRoomFocusNode,
                onInput: logic.onInput,
                clickSend: logic.clickSend,
                scrollToBottom: logic.scrollToBottom,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChatItem(BuildContext context, ChatMessageGroup group) {
    ChatRoomMessage chat = group.message;
    return GestureDetector(
      onTap: () {},
      child: chat.userName == logic.userInfo.value.userName
          ? _buildRight(group)
          : _buildLeft(group),
    );
  }

  Widget _buildRight(ChatMessageGroup group) {
    final chat = group.message;
    final singleImageUrl = ChatMessageUtils.singleImageUrl(chat.content);
    return Container(
      width: 0.8.sw,
      margin: EdgeInsets.only(bottom: 5.h, top: 5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  logic.displayNameFor(chat.userName, fallback: chat.allName),
                  style: TextStyle(
                    color: Styles.primaryTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                chat.isRedpacket
                    ? _buildRedpacket(chat.redpacket!)
                    : singleImageUrl != null
                        ? _buildSingleImage(chat, singleImageUrl, true)
                        : Container(
                            width: 0.8.sw - 58.w,
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16.w),
                                bottomRight: Radius.circular(16.w),
                                bottomLeft: Radius.circular(16.w),
                              ),
                              border: Styles.commonBorder,
                              color: Styles.primaryColor,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    PiUtils.getChatPreview(chat, isSelf: true)
                                  ],
                                ),
                                SizedBox(
                                  width: 0.8.sw - 58.w,
                                  child: Text(
                                    chat.time,
                                    style: TextStyle(
                                      color: const Color(0xFF9FA4B4),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11.sp,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          ),
                _buildRepeaters(group, true),
              ],
            ),
          ),
          10.horizontalSpace,
          PiAvatar(
            avatarURL: chat.avatarURL,
            userName: chat.userName,
            width: 48.w,
            height: 48.w,
          ),
        ],
      ),
    );
  }

  Widget _buildLeft(ChatMessageGroup group) {
    final chat = group.message;
    final singleImageUrl = ChatMessageUtils.singleImageUrl(chat.content);
    return Container(
      width: 0.8.sw,
      margin: EdgeInsets.only(bottom: 5.h, top: 5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              logic.clickUserAvatar(chat.userName);
            },
            child: PiAvatar(
              avatarURL: chat.avatarURL,
              userName: chat.userName,
              width: 48.w,
              height: 48.w,
            ),
          ),
          10.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  logic.displayNameFor(chat.userName, fallback: chat.allName),
                  style: TextStyle(
                    color: Styles.primaryTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                chat.isRedpacket
                    ? _buildRedpacket(chat.redpacket!)
                    : singleImageUrl != null
                        ? _buildSingleImage(chat, singleImageUrl, false)
                        : Container(
                            width: 0.8.sw - 58.w,
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(16.w),
                                bottomRight: Radius.circular(16.w),
                                bottomLeft: Radius.circular(16.w),
                              ),
                              border: Styles.commonBorder,
                              color: Colors.white,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      PiUtils.getChatPreview(chat),
                                    ]),
                                SizedBox(
                                  width: 0.8.sw - 58.w,
                                  child: Text(
                                    chat.time,
                                    style: TextStyle(
                                      color: const Color(0xFF9FA4B4),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11.sp,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          ),
                _buildRepeaters(group, false),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildRepeaters(ChatMessageGroup group, bool isSelf) {
    if (!logic.isGroup.value || !group.hasRepeaters) {
      return const SizedBox.shrink();
    }
    return ChatRepeatAvatarStrip(
      repeaters: group.repeaters,
      isSelf: isSelf,
      onTapUser: logic.clickUserAvatar,
    );
  }

  Widget _buildRedpacket(RedPacketMessage redpacket) {
    return Container(
      width: 0.8.sw - 58.w,
      alignment: Alignment.centerLeft,
      child: Container(
        width: 210.w,
        height: 88.w,
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: const Color(0xFFFF9900),
          borderRadius: BorderRadius.circular(8.w),
          border: Styles.redpacketBorder,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/redpack_icon.png',
                  width: 30.w,
                  height: 30.h,
                ),
                5.horizontalSpace,
                Expanded(
                  child: Text(
                    redpacket.msg,
                    style: TextStyle(fontSize: 21.sp, color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              ],
            ),
            Container(
              height: 2.h,
              margin: EdgeInsets.symmetric(vertical: 5.h),
              color: const Color(0xFFF95A2C),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${RedPacketType.toName(redpacket.type)}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFFF0D35E),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/coin_line_white.png',
                      width: 14.w,
                      height: 10.w,
                    ),
                    5.horizontalSpace,
                    Text(
                      '${redpacket.money}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFFF0D35E),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleImage(
    ChatRoomMessage chat,
    String src,
    bool isSelf,
  ) {
    return Padding(
      padding: EdgeInsets.only(top: 4.h),
      child: ChatMessageDomNode.buildImageUrl(
        src,
        chat,
        isSelf,
        'single_image',
        width: 190.w,
        height: 150.h,
        borderRadius: 10.r,
        // 纯图片消息是固定缩略图，使用 cover 保证图片铺满圆角裁剪框，
        // 避免 contain 留白时只裁到外框、没有裁到真实图片边缘。
        fit: BoxFit.cover,
      ),
    );
  }
}
