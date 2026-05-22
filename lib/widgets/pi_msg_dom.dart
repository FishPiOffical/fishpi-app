import 'package:fishpi_app/res/styles.dart';
import 'package:fishpi_app/widgets/pi_detail_msg.dart';
import 'package:fishpi_app/widgets/pi_hero.dart';
import 'package:fishpi_app/widgets/pi_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:html/dom.dart' as dom;
import 'package:url_launcher/url_launcher.dart';

class ChatMessageDomElement extends StatefulWidget {
  final dom.Element content;
  final dynamic chat;
  final bool? isSelf;
  final String nodePath;

  const ChatMessageDomElement({
    super.key,
    required this.content,
    required this.chat,
    this.isSelf = false,
    this.nodePath = '0',
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
              nodePath: '${widget.nodePath}.$index',
            ),
          ),
      ],
    );
  }

  Widget _buildElement(dom.Element element) {
    switch (element.localName) {
      case "p":
      case "div":
      case "span":
        return element.children.isEmpty ? Text(element.text) : Container();
      case "img":
        return buildImg(element, widget.chat, widget.isSelf, widget.nodePath);
      case "details":
        return ChatDetailMessage(
          content: element,
          chat: widget.chat,
          isSelf: widget.isSelf,
          nodePath: widget.nodePath,
        );
      case "code":
      case "pre":
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
          color: Colors.grey.withValues(alpha: .3),
          child: Text(
            element.text,
            style: TextStyle(fontSize: 12.sp),
          ),
        );
      case "del":
        return Text(
          element.text,
          style: const TextStyle(decoration: TextDecoration.lineThrough),
        );
      case "blockquote":
        return Container(
          padding: EdgeInsets.only(left: 8.w),
          decoration: const BoxDecoration(
            border: Border(
              left: BorderSide(color: Styles.secondaryTextColor, width: 3),
            ),
          ),
          child: Text(element.text),
        );
      case "li":
        return Text('- ${element.text}');
      case "ul":
      case "ol":
        return Container();
      case "video":
        return const Text('[视频]');
      case "iframe":
        return Text(_iframePreview(element.attributes['src'] ?? ''));
      case "a":
        return GestureDetector(
          onTap: () async {
            final href = element.attributes['href'] ?? '';
            final uri = Uri.tryParse(href);
            if (uri == null ||
                (uri.scheme != 'http' && uri.scheme != 'https')) {
              return;
            }
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          },
          child: Text(
            element.text,
            style: const TextStyle(
              color: Styles.secondaryTextColor,
              decoration: TextDecoration.underline,
            ),
          ),
        );
      default:
        return Container();
    }
  }

  static buildImg(item, chat, isSelf, String nodePath) {
    final src = item.attributes['src'] ?? '';
    if (src.isEmpty) return const SizedBox.shrink();
    final tag = _heroTag(chat, src, nodePath);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          Get.context!,
          MaterialPageRoute(
            builder: (context) => PiHero(
              arguments: {
                "imageUrl": src,
                "oId": tag,
              },
            ),
          ),
        );
      },
      child: Hero(
        tag: tag,
        child: Container(
          width: 120.w,
          height: 70.h,
          alignment: isSelf! ? Alignment.centerRight : Alignment.centerLeft,
          child: PiImage(
            imgUrl: src,
            width: 120.w,
            height: 70.h,
            fit: BoxFit.contain,
            alignment: isSelf ? Alignment.centerRight : Alignment.centerLeft,
          ),
        ),
      ),
    );
  }

  static String _heroTag(dynamic chat, String src, String nodePath) {
    final chatId = _chatId(chat);
    return 'chat_image_${chatId}_${src.hashCode}_$nodePath';
  }

  static String _chatId(dynamic chat) {
    try {
      final id = chat.oId;
      if (id is String && id.isNotEmpty) return id;
    } catch (_) {}
    return 'content';
  }

  static String _iframePreview(String src) {
    if (src.startsWith('https://fishpi.yuis.cc')) return '[天气卡片]';
    if (src.startsWith('https://music.163.com')) return '[音乐]';
    return '[不支持的消息,请在web端查看]';
  }
}
