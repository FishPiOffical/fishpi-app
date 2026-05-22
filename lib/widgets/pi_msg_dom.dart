import 'package:fishpi_app/res/styles.dart';
import 'package:fishpi_app/widgets/pi_detail_msg.dart';
import 'package:fishpi_app/widgets/pi_hero.dart';
import 'package:fishpi_app/widgets/pi_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:html/dom.dart' as dom;
import 'package:url_launcher/url_launcher.dart';

class ChatMessageDomElement extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return ChatMessageDomNode(
      node: content,
      chat: chat,
      isSelf: isSelf,
      nodePath: nodePath,
    );
  }
}

class ChatMessageDomNode extends StatelessWidget {
  final dom.Node node;
  final dynamic chat;
  final bool? isSelf;
  final String nodePath;
  final TextStyle? textStyle;
  final int? listIndex;

  const ChatMessageDomNode({
    super.key,
    required this.node,
    required this.chat,
    this.isSelf = false,
    this.nodePath = '0',
    this.textStyle,
    this.listIndex,
  });

  @override
  Widget build(BuildContext context) {
    final current = node;
    if (current is dom.Text) return _buildText(current.text);
    if (current is dom.Element) return _buildElement(current);
    return const SizedBox.shrink();
  }

  Widget _buildElement(dom.Element element) {
    switch (element.localName) {
      case "p":
      case "div":
        return _buildFlowChildren(element);
      case "span":
        return _buildInlineChildren(element);
      case "img":
        return buildImg(element, chat, isSelf, nodePath);
      case "details":
        return ChatDetailMessage(
          content: element,
          chat: chat,
          isSelf: isSelf,
          nodePath: nodePath,
        );
      case "pre":
        return _buildCode(element.text, block: true);
      case "code":
        return _buildCode(element.text);
      case "del":
        return _buildInlineChildren(
          element,
          childTextStyle: _mergeTextStyle(
            const TextStyle(decoration: TextDecoration.lineThrough),
          ),
        );
      case "strong":
      case "b":
        return _buildInlineChildren(
          element,
          childTextStyle: _mergeTextStyle(
            const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      case "em":
      case "i":
        return _buildInlineChildren(
          element,
          childTextStyle: _mergeTextStyle(
            const TextStyle(fontStyle: FontStyle.italic),
          ),
        );
      case "blockquote":
        return Container(
          padding: EdgeInsets.only(left: 8.w),
          decoration: const BoxDecoration(
            border: Border(
              left: BorderSide(color: Styles.secondaryTextColor, width: 3),
            ),
          ),
          child: _buildFlowChildren(element),
        );
      case "li":
        return _buildListItem(element);
      case "ul":
        return _buildList(element);
      case "ol":
        return _buildList(element, ordered: true);
      case "video":
        return const Text('[视频]');
      case "iframe":
        return Text(_iframePreview(element.attributes['src'] ?? ''));
      case "a":
        return _buildLink(element);
      case "br":
        return Text('\n', style: textStyle);
      default:
        return _buildFlowChildren(element);
    }
  }

  Widget _buildText(String value) {
    final normalized = _normalizeText(value);
    if (normalized.isEmpty) return const SizedBox.shrink();
    if (normalized.trim().isEmpty) return Text(' ', style: textStyle);
    return Text(normalized, style: textStyle);
  }

  Widget _buildFlowChildren(dom.Element element) {
    final children = <Widget>[];
    final inlineNodes = <_IndexedNode>[];

    void flushInlineNodes() {
      if (inlineNodes.isEmpty) return;
      children.add(_buildInlineGroup(List<_IndexedNode>.from(inlineNodes)));
      inlineNodes.clear();
    }

    for (var index = 0; index < element.nodes.length; index++) {
      final child = element.nodes[index];
      if (!_shouldRenderNode(element.nodes, index)) continue;

      if (_isInlineNode(child)) {
        inlineNodes.add(_IndexedNode(index, child));
      } else {
        flushInlineNodes();
        children.add(_buildChildNode(child, index));
      }
    }

    flushInlineNodes();
    return _packColumn(children);
  }

  Widget _buildInlineChildren(
    dom.Element element, {
    TextStyle? childTextStyle,
  }) {
    final children = <Widget>[];
    for (var index = 0; index < element.nodes.length; index++) {
      if (!_shouldRenderNode(element.nodes, index)) continue;
      children.add(
        _buildChildNode(
          element.nodes[index],
          index,
          childTextStyle: childTextStyle,
        ),
      );
    }
    return _packInline(children);
  }

  Widget _buildInlineGroup(List<_IndexedNode> inlineNodes) {
    final children = inlineNodes
        .map((item) => _buildChildNode(item.node, item.index))
        .toList();
    return _packInline(children);
  }

  Widget _buildChildNode(
    dom.Node child,
    int index, {
    TextStyle? childTextStyle,
    int? childListIndex,
  }) {
    return ChatMessageDomNode(
      node: child,
      chat: chat,
      isSelf: isSelf,
      nodePath: '$nodePath.$index',
      textStyle: childTextStyle ?? textStyle,
      listIndex: childListIndex,
    );
  }

  Widget _buildCode(String value, {bool block = false}) {
    final codeText = block ? value.trimRight() : _normalizeText(value).trim();
    if (codeText.isEmpty) return const SizedBox.shrink();

    return Container(
      width: block ? double.infinity : null,
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
      color: Colors.grey.withValues(alpha: .3),
      child: Text(
        codeText,
        style: _mergeTextStyle(
          TextStyle(fontSize: 12.sp, fontFamily: 'monospace'),
        ),
      ),
    );
  }

  Widget _buildLink(dom.Element element) {
    return GestureDetector(
      onTap: () async {
        final href = element.attributes['href'] ?? '';
        final uri = Uri.tryParse(href);
        if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
          return;
        }
        try {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } catch (_) {
          return;
        }
      },
      child: _buildInlineChildren(
        element,
        childTextStyle: _mergeTextStyle(
          const TextStyle(
            color: Styles.secondaryTextColor,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  Widget _buildList(dom.Element element, {bool ordered = false}) {
    final children = <Widget>[];
    var itemIndex = 1;

    for (var index = 0; index < element.nodes.length; index++) {
      final child = element.nodes[index];
      if (!_shouldRenderNode(element.nodes, index)) continue;

      if (child is dom.Element && child.localName == 'li') {
        children.add(
          _buildChildNode(
            child,
            index,
            childListIndex: ordered ? itemIndex++ : null,
          ),
        );
      } else {
        children.add(_buildChildNode(child, index));
      }
    }

    return _packColumn(children);
  }

  Widget _buildListItem(dom.Element element) {
    final prefix = listIndex == null ? '-' : '$listIndex.';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(prefix, style: textStyle),
        SizedBox(width: 4.w),
        Expanded(child: _buildFlowChildren(element)),
      ],
    );
  }

  Widget _packColumn(List<Widget> children) {
    if (children.isEmpty) return const SizedBox.shrink();
    if (children.length == 1) return children.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _packInline(List<Widget> children) {
    if (children.isEmpty) return const SizedBox.shrink();
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 2.h,
      children: children,
    );
  }

  TextStyle _mergeTextStyle(TextStyle style) {
    return textStyle?.merge(style) ?? style;
  }

  static bool _isInlineNode(dom.Node node) {
    if (node is dom.Text) return true;
    if (node is! dom.Element) return false;

    switch (node.localName) {
      case "p":
      case "div":
      case "blockquote":
      case "ul":
      case "ol":
      case "li":
      case "details":
      case "pre":
        return false;
      default:
        return true;
    }
  }

  static bool _shouldRenderNode(List<dom.Node> nodes, int index) {
    final node = nodes[index];
    if (node is! dom.Text) return node is dom.Element;

    final normalized = _normalizeText(node.text);
    if (normalized.isEmpty) return false;
    if (normalized.trim().isNotEmpty) return true;

    return _hasInlineSibling(nodes, index, -1) &&
        _hasInlineSibling(nodes, index, 1);
  }

  static bool _hasInlineSibling(List<dom.Node> nodes, int index, int step) {
    for (var i = index + step; i >= 0 && i < nodes.length; i += step) {
      final node = nodes[i];
      if (node is dom.Text && _normalizeText(node.text).trim().isEmpty) {
        continue;
      }
      return _isInlineNode(node);
    }
    return false;
  }

  static String _normalizeText(String value) {
    return value.replaceAll(RegExp(r'\s+'), ' ');
  }

  static Widget buildImg(
      dom.Element item, chat, bool? isSelf, String nodePath) {
    final src = item.attributes['src'] ?? '';
    if (src.isEmpty) return const SizedBox.shrink();
    final tag = _heroTag(chat, src, nodePath);
    final alignRight = isSelf ?? false;
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
          alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
          child: PiImage(
            imgUrl: src,
            width: 120.w,
            height: 70.h,
            fit: BoxFit.contain,
            alignment:
                alignRight ? Alignment.centerRight : Alignment.centerLeft,
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

class _IndexedNode {
  final int index;
  final dom.Node node;

  const _IndexedNode(this.index, this.node);
}
