import 'package:auto_size_text/auto_size_text.dart';
import 'package:fishpi/types/user.dart';
import 'package:flutter/material.dart';

/// 抄作业完成感谢鸽鸽
class MedalWidget extends StatelessWidget {
  final Metal medal;
  const MedalWidget({Key? key, required this.medal}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String url = medal.attr.url;
    String backcolor = medal.attr.backcolor;
    String fontcolor = medal.attr.fontcolor;
    int backC = int.parse(backcolor, radix: 16) + 0xFF000000;
    int fontC = int.parse(fontcolor, radix: 16) + 0xFF000000;
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
                color: Color(backC),
                border: Border.all(color: const Color(0xFFCECECE)),
              ),
              padding: const EdgeInsets.only(left: 15, right: 10),
              child: AutoSizeText(
                medal.name,
                minFontSize: 10,
                style: TextStyle(color: Color(fontC)),
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