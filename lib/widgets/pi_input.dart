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

  const PiInput({
    required this.controller,
    required this.onInputChanged,
    this.hintText,
    this.prefixIcon,
    this.textAlign,
    this.focusNode,
    this.onEditingComplete,
    this.obscureText,
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
        contentPadding: const EdgeInsets.fromLTRB(10, 0, 50, 0),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: prefixIcon,
        prefixIconColor: Colors.black,
        enabledBorder: Styles.inputBorder,
        focusedBorder: Styles.inputBorder,
        border: Styles.inputBorder,
      ),
      keyboardType: TextInputType.text,
      onChanged: onInputChanged,
      onEditingComplete: onEditingComplete,
    );
  }
}
