import 'package:fishpi_app/widgets/pi_detail_msg.dart';
import 'package:fishpi_app/widgets/pi_hero.dart';
import 'package:fishpi_app/widgets/pi_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:html/dom.dart' as dom;
import 'dart:math';

import '../utils/pi_utils.dart';

class ChatMessageDomElement extends StatefulWidget {
  final dom.Element content;
  final dynamic chat;
  final bool? isSelf;

  const ChatMessageDomElement({
    super.key,
    required this.content,
    required this.chat,
    this.isSelf = false,
  });

  @override
  State<ChatMessageDomElement> createState() => _ChatMessageDomElementState();
}

class _ChatMessageDomElementState extends State<ChatMessageDomElement> {
  @override
  Widget build(BuildContext context) {
    return Column(
      // 这个column如果在p标签里，可以使用textspan，这样内部的del code 等标签就不会一样一个了，children再无脑column
      // 现状使用column模拟之前的list
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.centerLeft,
          // 可以写一个子组件或者方法switch case，根据localName返回不同的widget，p标签记得需要外层column就换成textspan，否则del，code等标签会换行
          child: _buildElement(widget.content),
        ),
        if (widget.content.localName != 'details')
          //通用children在这里，details的children由ChatDetailMessage托管，以便于展开收起
          ...List.generate(
            widget.content.children.length,
            (index) => ChatMessageDomElement(
              content: widget.content.children[index],
              chat: widget.chat,
              isSelf: widget.isSelf,
            ),
          ),
      ],
    );
  }

  Widget _buildElement(dom.Element element) {
    switch (widget.content.localName) {
      case "p":
        return Text(widget.content.text);
        break;
      case "img":
        return buildImg(widget.content, widget.chat, widget.isSelf);
      case "details":
        return ChatDetailMessage(
          content: widget.content,
          chat: widget.chat,
        );
      case "code":
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
          color: Colors.grey.withOpacity(.3),
          child: Text(
            widget.content.text,
            style: TextStyle(fontSize: 12.sp),
          ),
        );
      case "del":
        return Text(
          widget.content.text,
          style: const TextStyle(decoration: TextDecoration.lineThrough),
        );
      default:
        return Container();
    }
  }

  static buildImg(item, chat, isSelf) {
    int random = Random().nextInt(1000);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          Get.context!,
          MaterialPageRoute(
            builder: (context) => PiHero(
              arguments: {
                "imageUrl": item.attributes['src']!,
                "oId": "${chat.oId}_$random",
              },
            ),
          ),
        );
      },
      child: Hero(
        tag: "${chat.oId}_$random",
        child: Container(
          width: 120.w,
          height: 70.h,
          alignment: isSelf! ? Alignment.centerRight : Alignment.centerLeft,
          child: PiImage(
            imgUrl: item.attributes['src']!,
            width: 120.w,
            height: 70.h,
            fit: BoxFit.contain,
            alignment: isSelf ? Alignment.centerRight : Alignment.centerLeft,
          ),
        ),
      ),
    );
  }
}
