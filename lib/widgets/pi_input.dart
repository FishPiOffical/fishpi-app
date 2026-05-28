import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../res/styles.dart';

class PiInput extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onInputChanged;
  final String? hintText;
  final Icon? prefixIcon;
  final TextAlign? textAlign;
  final FocusNode? focusNode;
  final Function()? onEditingComplete;
  final bool? obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? suffixIcon;
  final EdgeInsetsGeometry? contentPadding;

  const PiInput({
    required this.controller,
    required this.onInputChanged,
    this.hintText,
    this.prefixIcon,
    this.textAlign,
    this.focusNode,
    this.onEditingComplete,
    this.obscureText,
    this.keyboardType,
    this.textInputAction,
    this.suffixIcon,
    this.contentPadding,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      cursorColor: Colors.black,
      textAlign: textAlign ?? TextAlign.center,
      textAlignVertical: TextAlignVertical.center,
      obscureText: obscureText ?? false,
      focusNode: focusNode,
      style: TextStyle(
        fontSize: 14.sp,
        color: Colors.black,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hintText ?? '',
        hintStyle: const TextStyle(
          color: Colors.black,
        ),
        contentPadding: contentPadding ??
            Styles.inputContentPadding(hasSuffix: suffixIcon != null),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: prefixIcon,
        prefixIconColor: Colors.black,
        suffixIcon: suffixIcon,
        suffixIconColor: Colors.black,
        enabledBorder: Styles.inputBorder,
        focusedBorder: Styles.inputBorder,
        border: Styles.inputBorder,
      ),
      keyboardType: keyboardType ?? TextInputType.text,
      textInputAction: textInputAction,
      onChanged: onInputChanged,
      onEditingComplete: onEditingComplete,
    );
  }
}
