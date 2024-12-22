import 'package:fishpi/types/chatroom.dart';
import 'package:fishpi/types/redpacket.dart';
import 'package:fishpi_app/res/styles.dart';
import 'package:fishpi_app/utils/pi_utils.dart';
import 'package:fishpi_app/widgets/pi_avatar.dart';
import 'package:fishpi_app/widgets/pi_image.dart';
import 'package:fishpi_app/widgets/pi_title_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../widgets/chat/chat_input_box.dart';
import 'chat_logic.dart';

class ChatPage extends StatelessWidget {
  final ChatLogic logic = Get.put(ChatLogic());

  ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: PiTitleBar.back(
          title: logic.isGroup.value ? '聊天室' : logic.userName.value,
        ),
        body: Column(
          children: [
            Expanded(
              child: logic.messageList.isEmpty
                  ? Container()
                  : GestureDetector(
                      onTap: (){
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
                          itemBuilder: _buildChatItem,
                          itemCount: logic.messageList.length,
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
      ),
    );
  }

  Widget _buildChatItem(BuildContext context, int index) {
    ChatRoomMessage chat = logic.messageList[index];
    return GestureDetector(
      onTap: () {},
      child: chat.userName == logic.userInfo.value.userName
          ? _buildRight(chat)
          : _buildLeft(chat),
    );
  }

  Widget _buildRight(ChatRoomMessage chat) {
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
                  chat.allName,
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

  Widget _buildLeft(ChatRoomMessage chat) {
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
                  chat.allName,
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
              ],
            ),
          )
        ],
      ),
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
}
