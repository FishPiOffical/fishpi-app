import 'package:fishpi_app/res/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('视觉 token 集中定义核心尺寸', () {
    expect(PiStyleTokens.cardRadius, 16);
    expect(PiStyleTokens.controlRadius, 10);
    expect(PiStyleTokens.formFieldHeight, 52);
    expect(PiStyleTokens.primaryButtonHeight, 56);
    expect(PiStyleTokens.pageHorizontalPadding, 16);
  });

  test('基础边框和输入框使用统一 token', () {
    expect(Styles.commonBorder.top.width, PiStyleTokens.borderWidth);
    expect(Styles.commonBorder.bottom.width, PiStyleTokens.heavyBorderWidth);

    final inputBorder = Styles.inputBorder;
    expect(inputBorder.borderSide.width, PiStyleTokens.borderWidth);
    expect(
      inputBorder.borderRadius,
      const BorderRadius.all(Radius.circular(PiStyleTokens.controlRadius)),
    );
  });
}
