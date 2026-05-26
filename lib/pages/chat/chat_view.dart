import 'package:fishpi/types/chatroom.dart';
import 'package:fishpi/types/redpacket.dart';
import 'package:fishpi_app/core/chat/chat_message_utils.dart';
import 'package:fishpi_app/res/styles.dart';
import 'package:fishpi_app/utils/pi_utils.dart';
import 'package:fishpi_app/widgets/chat/chat_barrager_overlay.dart';
import 'package:fishpi_app/widgets/chat/chat_barrager_sheet.dart';
import 'package:fishpi_app/widgets/chat/chat_message_action_sheet.dart';
import 'package:fishpi_app/widgets/chat/chat_red_packet_card.dart';
import 'package:fishpi_app/widgets/chat/chat_red_packet_detail_sheet.dart';
import 'package:fishpi_app/widgets/chat/chat_red_packet_sheet.dart';
import 'package:fishpi_app/widgets/chat/chat_repeat_avatar_strip.dart';
import 'package:fishpi_app/widgets/chat/chat_topic_sheet.dart';
import 'package:fishpi_app/widgets/chat/chat_voice_message.dart';
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
                child: Stack(
                  children: [
                    if (messageGroups.isNotEmpty)
                      GestureDetector(
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
                    if (logic.isGroup.value)
                      Positioned.fill(
                        child: ChatBarragerOverlay(
                          barragers: logic.barragers.toList(),
                          onFinished: logic.dismissBarrager,
                        ),
                      ),
                  ],
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
                enableVoice: logic.isGroup.value,
                isRecordingVoice: logic.isRecordingVoice.value,
                isSendingVoice: logic.isSendingVoice.value,
                voiceRecordSeconds: logic.voiceRecordSeconds.value,
                onVoiceRecordStart: logic.startVoiceRecord,
                onVoiceRecordFinish: logic.finishVoiceRecord,
                onVoiceRecordCancel: logic.cancelVoiceRecord,
                onRedPacketTap:
                    logic.isGroup.value ? _showRedPacketSheet : null,
                onBarragerTap: logic.isGroup.value ? _showBarragerSheet : null,
                topic: logic.isGroup.value ? logic.currentTopic.value : null,
                onTopicTap: logic.isGroup.value ? _showTopicSheet : null,
                onTopicQuoteTap: logic.isGroup.value &&
                        logic.currentTopic.value.trim().isNotEmpty
                    ? logic.quoteCurrentTopic
                    : null,
                quoteDraft: logic.quoteDraft.value,
                onClearQuote: logic.clearQuote,
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
      onLongPress: () => _showChatMessageActions(chat),
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
                    ? _buildRedpacket(chat, true)
                    : chat.isMusic
                        ? _buildMusic(chat, true)
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        PiUtils.getChatPreview(chat,
                                            isSelf: true)
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
            onLongPress: logic.canBlockChatRoomUser(chat)
                ? () => _showChatMessageActions(chat)
                : null,
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
                    ? _buildRedpacket(chat, false)
                    : chat.isMusic
                        ? _buildMusic(chat, false)
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
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
      onLongPressUser: (message) {
        _showChatMessageActions(message);
      },
    );
  }

  void _showChatMessageActions(ChatRoomMessage chat) {
    final displayName = logic.displayNameFor(
      chat.userName,
      fallback: chat.allName,
    );
    Get.bottomSheet(
      ChatMessageActionSheet(
        displayName: displayName,
        canUseUserActions: logic.canUseOtherUserActions(chat),
        canBlockChatRoomUser: logic.canBlockChatRoomUser(chat),
        onQuote: () {
          Get.back();
          logic.quoteMessage(chat);
        },
        onViewProfile: () {
          Get.back();
          logic.clickUserAvatar(chat.userName);
        },
        onRemark: () {
          Get.back();
          logic.quickSetRemark(chat);
        },
        onTransfer: () {
          Get.back();
          logic.quickTransfer(chat);
        },
        onBlock: () {
          Get.back();
          logic.blockChatRoomUser(chat);
        },
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  Widget _buildActionButton({
    required Key key,
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      key: key,
      onTap: onTap,
      child: Container(
        width: 1.sw - 32.w,
        height: 44.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Styles.commonBorder,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20.w, color: Styles.primaryTextColor),
            10.horizontalSpace,
            Text(
              text,
              style: TextStyle(
                color: Styles.primaryTextColor,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRedpacket(ChatRoomMessage chat, bool isSelf) {
    final redpacket = chat.redpacket;
    if (redpacket == null) return const SizedBox.shrink();
    return ChatRedPacketCard(
      redpacket: redpacket,
      isSelf: isSelf,
      onTap: () => _handleRedPacketTap(chat),
    );
  }

  void _showRedPacketSheet() {
    Get.bottomSheet(
      ChatRedPacketSheet(
        onlineUsers: logic.onlineUsers,
        senderId: logic.userInfo.value.oId,
        onSubmit: logic.sendRedPacket,
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  void _showTopicSheet() {
    Get.bottomSheet(
      ChatTopicSheet(
        initialTopic: logic.currentTopic.value,
        onSubmit: logic.setTopic,
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  Future<void> _showBarragerSheet() async {
    await logic.loadBarrageCost();
    Get.bottomSheet(
      ChatBarragerSheet(
        cost: logic.barrageCost.value,
        onSubmit: logic.sendBarrager,
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  void _handleRedPacketTap(ChatRoomMessage chat) {
    if (chat.redpacket?.type == RedPacketType.RockPaperScissors) {
      _showGestureSheet(chat);
      return;
    }
    _openRedPacket(chat);
  }

  void _showGestureSheet(ChatRoomMessage chat) {
    Get.bottomSheet(
      SafeArea(
        child: Container(
          width: 1.sw,
          padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 16.h),
          decoration: BoxDecoration(
            color: Styles.titleBarColor,
            border: Styles.commonBorder,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '选择出拳',
                style: TextStyle(
                  color: Styles.primaryTextColor,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              14.verticalSpace,
              _buildActionButton(
                key: const ValueKey('red_packet_open_rock'),
                icon: Icons.back_hand_outlined,
                text: '石头',
                onTap: () {
                  Get.back();
                  _openRedPacket(chat, gesture: GestureType.Rock);
                },
              ),
              10.verticalSpace,
              _buildActionButton(
                key: const ValueKey('red_packet_open_scissors'),
                icon: Icons.content_cut,
                text: '剪刀',
                onTap: () {
                  Get.back();
                  _openRedPacket(chat, gesture: GestureType.Scissors);
                },
              ),
              10.verticalSpace,
              _buildActionButton(
                key: const ValueKey('red_packet_open_paper'),
                icon: Icons.article_outlined,
                text: '布',
                onTap: () {
                  Get.back();
                  _openRedPacket(chat, gesture: GestureType.Paper);
                },
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  Future<void> _openRedPacket(
    ChatRoomMessage chat, {
    GestureType? gesture,
  }) async {
    final info = await logic.openRedPacket(chat, gesture: gesture);
    if (info == null) return;
    Get.bottomSheet(
      ChatRedPacketDetailSheet(info: info),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  Widget _buildMusic(ChatRoomMessage chat, bool isSelf) {
    final music = chat.music;
    if (music == null) return PiUtils.getChatPreview(chat, isSelf: isSelf);
    return ChatVoiceMessage(
      music: music,
      isSelf: isSelf,
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
