import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EmojiBox extends StatefulWidget {
  final Map<String, String> emojiList;
  final List<String> diyEmojiList;
  final Function(String t) onTap;

  const EmojiBox({
    required this.emojiList,
    required this.diyEmojiList,
    required this.onTap,
    super.key,
  });

  @override
  State<EmojiBox> createState() => _EmojiBoxState();
}

class _EmojiBoxState extends State<EmojiBox> {
  static const int _defaultPrecacheCount = 40;
  static const int _diyPrecacheCount = 24;

  int emojiIndex = 0;
  final Set<String> _precachedUrls = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _precacheVisibleEmojis();
  }

  @override
  void didUpdateWidget(covariant EmojiBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.emojiList != widget.emojiList ||
        oldWidget.diyEmojiList != widget.diyEmojiList) {
      _precacheVisibleEmojis();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 1.sw,
      height: 224.h,
      child: Column(
        children: [
          Container(
            height: 30.h,
            margin: EdgeInsets.symmetric(vertical: 5.h),
            alignment: Alignment.center,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      emojiIndex = 0;
                    });
                  },
                  child: AnimatedOpacity(
                    opacity: emojiIndex == 0 ? 1 : 0.3,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      width: 24.w,
                      height: 24.w,
                      margin: EdgeInsets.symmetric(horizontal: 5.w),
                      child: Image.asset(
                        'assets/images/face.png',
                        width: 24.w,
                        height: 24.w,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      emojiIndex = 1;
                    });
                  },
                  child: AnimatedOpacity(
                    opacity: emojiIndex == 1 ? 1 : 0.3,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      width: 30.w,
                      height: 30.w,
                      margin: EdgeInsets.symmetric(horizontal: 5.w),
                      child: Icon(
                        Icons.photo,
                        size: 30.w,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SizedBox(
              width: 1.sw,
              child: [
                _buildDefaultEmojiBox(widget.emojiList),
                _buildDiyEmojiBox(widget.diyEmojiList)
              ][emojiIndex],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDefaultEmojiBox(emojiList) {
    List<Widget> list = [];
    emojiList.forEach((emojiName, value) {
      list.add(
        GestureDetector(
          key: ValueKey('emoji_default_$emojiName'),
          onTap: () {
            // logic.chatRoomControllerText.text = ':$key:';
            // logic.onInput(':$key:');
            // logic.clickSend();
            widget.onTap(':$emojiName:');
          },
          child: Container(
            width: 24.w,
            height: 24.w,
            alignment: Alignment.center,
            child: _buildEmojiImage(
              value,
              width: 24.w,
              height: 24.w,
            ),
          ),
        ),
      );
    });
    // 返回一个GridView
    return GridView.count(
      crossAxisCount: 8,
      scrollDirection: Axis.vertical,
      //设置横向间距
      crossAxisSpacing: 4.w,
      //设置主轴间距
      mainAxisSpacing: 4.w,
      children: list,
    );
  }

  Widget _buildDiyEmojiBox(diyEmojiList) {
    List<Widget> list = [];
    for (var item in diyEmojiList) {
      list.add(
        GestureDetector(
          key: ValueKey('emoji_diy_$item'),
          onTap: () {
            // logic.chatRoomControllerText.text = '![图片表情]($item)';
            // logic.onInput('![图片表情]($item)');
            // logic.clickSend();
            widget.onTap('![图片表情]($item)');
          },
          child: Container(
            width: 24.w,
            height: 24.w,
            alignment: Alignment.center,
            child: _buildEmojiImage(
              item,
              width: 80.w,
              height: 80.w,
            ),
          ),
        ),
      );
    }
    return GridView.count(
      crossAxisCount: 4,
      scrollDirection: Axis.vertical,
      //设置横向间距
      crossAxisSpacing: 4.w,
      //设置主轴间距
      mainAxisSpacing: 4.w,
      children: list,
    );
  }

  Widget _buildEmojiImage(
    String url, {
    required double width,
    required double height,
  }) {
    return SizedBox(
      width: width,
      height: height,
      child: CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.contain,
        placeholder: (_, __) => _buildEmojiPlaceholder(width, height),
        errorWidget: (_, __, ___) => _buildEmojiPlaceholder(width, height),
      ),
    );
  }

  Widget _buildEmojiPlaceholder(double width, double height) {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFE8E8E8),
        borderRadius: BorderRadius.circular(6.r),
      ),
    );
  }

  void _precacheVisibleEmojis() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final urls = [
        ...widget.emojiList.values.take(_defaultPrecacheCount),
        ...widget.diyEmojiList.take(_diyPrecacheCount),
      ].where((url) => url.trim().isNotEmpty);

      for (final url in urls) {
        if (!_precachedUrls.add(url)) continue;
        precacheImage(CachedNetworkImageProvider(url), context)
            .catchError((_) {});
      }
    });
  }
}
