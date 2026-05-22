import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Styles {
  Styles._();

  static const primaryColor = Color(0xFFF0D35E);
  static const primaryTextColor = Color(0xFF18191F);
  static const secondaryTextColor = Color(0xFF474A57);
  static const titleBarColor = Color(0xFFEEEFF4);
  static const c4Color = Color(0xFFC4C4C4);
  static const redpacketBorderColor = Color(0xFFF95A2C);
  static TextStyle titleBarStyle = TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.bold,
    color: primaryTextColor,
  );
  static const commonBorder = Border(
    top:
        BorderSide(color: primaryTextColor, width: 2, style: BorderStyle.solid),
    bottom:
        BorderSide(color: primaryTextColor, width: 4, style: BorderStyle.solid),
    left:
        BorderSide(color: primaryTextColor, width: 2, style: BorderStyle.solid),
    right:
        BorderSide(color: primaryTextColor, width: 2, style: BorderStyle.solid),
  );
  static const redpacketBorder = Border(
    top: BorderSide(
        color: redpacketBorderColor, width: 2, style: BorderStyle.solid),
    bottom: BorderSide(
        color: redpacketBorderColor, width: 4, style: BorderStyle.solid),
    left: BorderSide(
        color: redpacketBorderColor, width: 2, style: BorderStyle.solid),
    right: BorderSide(
        color: redpacketBorderColor, width: 2, style: BorderStyle.solid),
  );
  static TextStyle bottomTextStyle = TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.bold,
    color: primaryTextColor,
  );
  static const inputBorder = OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.black,
      width: 2,
    ),
    borderRadius: BorderRadius.all(
      Radius.circular(10),
    ),
  );
}
