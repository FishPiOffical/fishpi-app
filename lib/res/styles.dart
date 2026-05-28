import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PiStyleTokens {
  PiStyleTokens._();

  static const double borderWidth = 2;
  static const double heavyBorderWidth = 4;
  static const double pageHorizontalPadding = 16;
  static const double pageVerticalPadding = 20;
  static const double cardRadius = 16;
  static const double cardPadding = 14;
  static const double compactCardPadding = 10;
  static const double controlRadius = 10;
  static const double actionRadius = 12;
  static const double smallRadius = 8;
  static const double formFieldHeight = 52;
  static const double compactFieldHeight = 42;
  static const double primaryButtonHeight = 56;
  static const double compactButtonHeight = 44;
  static const double menuItemHorizontalPadding = 10;
  static const double menuItemVerticalMargin = 10;
  static const double inputHorizontalPadding = 12;
  static const double inputTrailingPadding = 50;
}

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

  static BorderRadius get cardRadius =>
      BorderRadius.circular(PiStyleTokens.cardRadius.r);

  static BorderRadius get controlRadius =>
      BorderRadius.circular(PiStyleTokens.controlRadius.r);

  static BorderRadius get actionRadius =>
      BorderRadius.circular(PiStyleTokens.actionRadius.r);

  static BorderRadius get smallRadius =>
      BorderRadius.circular(PiStyleTokens.smallRadius.r);

  static EdgeInsets get pagePadding => EdgeInsets.symmetric(
        horizontal: PiStyleTokens.pageHorizontalPadding.w,
        vertical: PiStyleTokens.pageVerticalPadding.h,
      );

  static EdgeInsets get cardPadding =>
      EdgeInsets.all(PiStyleTokens.cardPadding.w);

  static EdgeInsets get compactCardPadding =>
      EdgeInsets.all(PiStyleTokens.compactCardPadding.w);

  static EdgeInsets get formFieldPadding => EdgeInsets.symmetric(
        horizontal: PiStyleTokens.inputHorizontalPadding.w,
        vertical: PiStyleTokens.inputHorizontalPadding.h,
      );

  static double get formFieldHeight => PiStyleTokens.formFieldHeight.h;

  static double get primaryButtonHeight => PiStyleTokens.primaryButtonHeight.h;

  static double get compactButtonHeight => PiStyleTokens.compactButtonHeight.h;

  static EdgeInsets inputContentPadding({bool hasSuffix = false}) {
    return EdgeInsets.fromLTRB(
      PiStyleTokens.inputHorizontalPadding.w,
      0,
      hasSuffix
          ? PiStyleTokens.inputHorizontalPadding.w
          : PiStyleTokens.inputTrailingPadding.w,
      0,
    );
  }

  static BoxDecoration cardDecoration({
    Color color = Colors.white,
    Border? border,
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      color: color,
      border: border ?? commonBorder,
      borderRadius: borderRadius ?? cardRadius,
    );
  }

  static const commonBorder = Border(
    top: BorderSide(
        color: primaryTextColor,
        width: PiStyleTokens.borderWidth,
        style: BorderStyle.solid),
    bottom: BorderSide(
        color: primaryTextColor,
        width: PiStyleTokens.heavyBorderWidth,
        style: BorderStyle.solid),
    left: BorderSide(
        color: primaryTextColor,
        width: PiStyleTokens.borderWidth,
        style: BorderStyle.solid),
    right: BorderSide(
        color: primaryTextColor,
        width: PiStyleTokens.borderWidth,
        style: BorderStyle.solid),
  );
  static const redpacketBorder = Border(
    top: BorderSide(
        color: redpacketBorderColor,
        width: PiStyleTokens.borderWidth,
        style: BorderStyle.solid),
    bottom: BorderSide(
        color: redpacketBorderColor,
        width: PiStyleTokens.heavyBorderWidth,
        style: BorderStyle.solid),
    left: BorderSide(
        color: redpacketBorderColor,
        width: PiStyleTokens.borderWidth,
        style: BorderStyle.solid),
    right: BorderSide(
        color: redpacketBorderColor,
        width: PiStyleTokens.borderWidth,
        style: BorderStyle.solid),
  );
  static TextStyle bottomTextStyle = TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.bold,
    color: primaryTextColor,
  );
  static const inputBorder = OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.black,
      width: PiStyleTokens.borderWidth,
    ),
    borderRadius: BorderRadius.all(
      Radius.circular(PiStyleTokens.controlRadius),
    ),
  );
}
