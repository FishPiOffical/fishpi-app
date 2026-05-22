import 'package:fishpi_app/widgets/pi_msg_dom.dart';
import 'package:flutter/cupertino.dart';
import 'package:html/dom.dart' as dom;

class ChatDetailMessage extends StatefulWidget {
  final dom.Element content;
  final dynamic chat;
  final bool? isSelf;
  final String nodePath;

  const ChatDetailMessage({
    super.key,
    required this.content,
    required this.chat,
    this.isSelf = false,
    this.nodePath = '0',
  });

  @override
  State<ChatDetailMessage> createState() => _ChatDetailMessageState();
}

class _ChatDetailMessageState extends State<ChatDetailMessage> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isExpanded = !isExpanded;
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isExpanded ? '#收起' : '#展开'),
          if (isExpanded)
            // details 内可能同时包含普通文本和元素节点，必须按 nodes 渲染。
            ...List.generate(
              widget.content.nodes.length,
              (index) => ChatMessageDomNode(
                node: widget.content.nodes[index],
                chat: widget.chat,
                isSelf: widget.isSelf,
                nodePath: '${widget.nodePath}.$index',
              ),
            ),
        ],
      ),
    );
  }
}
