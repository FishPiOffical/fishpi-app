import 'package:fishpi_app/controller/chatroom.dart';
import 'package:fishpi_app/utils/util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../common_style/style.dart';
import '../controller/chat.dart';

class ChatRoomPage extends StatefulWidget {
  const ChatRoomPage({super.key});

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final ChatController chat = Get.put(ChatController());
  final ChatRoomLogic chatRoom = Get.put(ChatRoomLogic());
  final maxWidth = 1.sw * 0.8;

  @override
  void initState() {
    print(chat.fishpi.token);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: (){Get.back();},
          child: Icon(Icons.arrow_back_ios,color: Colors.white,),
        ),
        backgroundColor: CommonStyle.primaryColor,
        title: const Text(
          '聊天室',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
      body: SafeArea(
        top: false,
        child: Obx(
          () => Container(
            width: 1.sw,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 0),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              reverse: true,
              controller: chatRoom.scrollController,
              itemCount: chat.chatRoomMsg.length,
              itemBuilder: _chatItemBuilder,
            ),
          ),
        ),
      ),
    );
  }

  Widget _chatItemBuilder(context, index) {
    return Container(
      width: maxWidth,
      margin: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(50.w)),
            child: Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1.w,
                  color: Colors.black,
                  style: BorderStyle.solid,
                ),
              ),
              child: Image.network(
                chat.chatRoomMsg[index].avatarURL,
                width: 48.w,
                height: 48.w,
              ),
            )),
        10.horizontalSpace,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  chat.chatRoomMsg[index].nickname,
                  style: TextStyle(
                    color: const Color(0xFF18191F),
                    fontSize: 21.sp,
                  ),
                ),
                5.horizontalSpace,
                Text(
                  FpUtil.getChatTime(chat.chatRoomMsg[index].time),
                  style: TextStyle(
                    color: const Color(0xFF9FA4B4),
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
            Container(
              width: maxWidth - 60.w,
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                border: CommonStyle.commonBorder,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.zero,
                  topRight: Radius.circular(20.r),
                  bottomLeft: Radius.circular(20.r),
                  bottomRight: Radius.circular(20.r),
                ),
              ),
              child: Text(
                chat.chatRoomMsg[index].content,
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        )
      ]),
    );
  }
}
