import 'package:auto_size_text/auto_size_text.dart';
import 'package:fishpi/types/user.dart';
import 'package:flutter/material.dart';

/// 抄作业完成感谢鸽鸽
class MedalWidget extends StatelessWidget {
  final Metal medal;
  const MedalWidget({super.key, required this.medal});

  @override
  Widget build(BuildContext context) {
    final url = medal.attr.url;
    final backColor = _parseMedalColor(
      medal.attr.backcolor,
      const Color(0xFFF0D35E),
    );
    final fontColor = _parseMedalColor(
      medal.attr.fontcolor,
      const Color(0xFF18191F),
    );

    return SizedBox(
      height: 25,
      width: 120,
      child: Stack(
        children: [
          Positioned(
            left: 12,
            top: 2,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: backColor,
                border: Border.all(color: const Color(0xFFCECECE)),
              ),
              padding: const EdgeInsets.only(left: 15, right: 10),
              child: AutoSizeText(
                medal.name,
                minFontSize: 10,
                style: TextStyle(color: fontColor),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              height: 25,
              width: 25,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: const Color(0xFFCECECE)),
                image: DecorationImage(image: NetworkImage(url)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Color _parseMedalColor(String value, Color fallback) {
  final normalized = value.trim().replaceFirst('#', '');
  final rgbText = normalized.length == 6 ? normalized : '';
  final argbText = normalized.length == 8 ? normalized : '';
  final parsed = int.tryParse(
    rgbText.isNotEmpty ? rgbText : argbText,
    radix: 16,
  );
  if (parsed == null) return fallback;
  return Color(rgbText.isNotEmpty ? 0xFF000000 | parsed : parsed);
}
