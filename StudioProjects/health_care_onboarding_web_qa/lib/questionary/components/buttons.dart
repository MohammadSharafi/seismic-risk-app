import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../march_style/march_size.dart';
import '../../march_style/march_theme.dart';

enum ButtonSize { SMALL, MEDIUM, LARG, INFINITY }

class MarchButton extends StatelessWidget {

  const MarchButton({
    Key? key,
    required this.btnText,
    this.color,
    required this.btnCallBack,
    required this.buttonSize,
    required this.alignment,
    this.textColor,
    this.borderColor,
    this.icon,
    this.hasPadding = true,
    this.buttonWidth,
    this.buttonHeight,
    this.fontSize,
    this.textStyle,
  }) : super(key: key);
  final String btnText;
  final VoidCallback btnCallBack;
  final ButtonSize buttonSize;
  final double? buttonWidth;
  final double? buttonHeight;
  final double? fontSize;
  final Alignment alignment;
  final Color? color;
  final Color? borderColor;
  final Icon? icon;
  final Color? textColor;
  final bool hasPadding;
  final TextStyle? textStyle;

  double width(ButtonSize buttonSize, BuildContext context) {
    if (buttonWidth != null) return buttonWidth!;
    if (buttonSize == ButtonSize.INFINITY) {
      return double.infinity;
    } else if (buttonSize == ButtonSize.LARG) {
      return MediaQuery.of(context).size.width * 0.9;
    } else if (buttonSize == ButtonSize.MEDIUM) {
      return MediaQuery.of(context).size.width * 0.5;
    } else {
      return MediaQuery.of(context).size.width * 0.3;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: btnCallBack,
      pressedOpacity: 0.6,
      padding: EdgeInsets.all(hasPadding ? MarchSize.smallPaddingAll * 1.6 : 0),
      child: Container(
        width: width(buttonSize, context),
        height: buttonHeight ?? 40,
        decoration: BoxDecoration(
            border:
                borderColor == null ? null : Border.all(color: borderColor!),
            color: color ?? marchColorData[MarchColor.primary]!,
            borderRadius: BorderRadius.circular(MarchSize.buttonRadius * 3)),
        child: Center(
          child: Text(
            btnText,
            textAlign: TextAlign.center,
            style: textStyle ??
                Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: textColor ?? marchColorData[MarchColor.white],
                    fontWeight: FontWeight.w300,
                    fontSize: fontSize ?? 12),
          ),
        ),
      ),
    );
  }
}
