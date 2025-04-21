import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hexcolor/hexcolor.dart';

class BaseTextFieldController {
  TextEditingController textController;
  FocusNode focusNode;
  String? Function(String?)? validator;
  bool _obscured;

  BaseTextFieldController({
    String initialValue = '',
    this.validator,
    bool obscured = false, // Default value for password fields
  })  : textController = TextEditingController(text: initialValue),
        focusNode = FocusNode(),
        _obscured = obscured;

  bool get obscured => _obscured;

  void toggleObscured() {
    _obscured = !_obscured;
  }
}

class BaseTextField extends StatelessWidget {
  final BaseTextFieldController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool enabled;
  final String? hintText;
  final String? labelText;
  final String? prefixSvgIcon;
  final Color? prefixSvgColor;
  final Color? suffixSvgColor;
  final Widget? suffixSvgIcon;
  final VoidCallback? onSuffixIconTap;
  final int? maxLength;
  final TextStyle? textStyle;
  final InputDecoration? decoration;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final String? tooltip;
  final Color? fillColor;
  final Color? borderColor;
  final double borderRadius;
  final double borderWidth;
  final bool autoFocus;

  final int ? maxLines;
  final bool ? expands;

  const BaseTextField({
    Key? key,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.enabled = true,
    this.hintText,
    this.labelText,
    this.prefixSvgIcon,
    this.suffixSvgIcon,
    this.onSuffixIconTap,
    this.maxLength,
    this.textStyle,
    this.decoration,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.tooltip,
    this.fillColor,
    this.borderColor,
    this.borderRadius = 8.0,
    this.borderWidth = 1.0,
    this.autoFocus = false,
    this.prefixSvgColor,
    this.suffixSvgColor,
    this.maxLines,
    this.expands,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: TextFormField(
        controller: controller.textController,
        focusNode: controller.focusNode,
        textAlignVertical: TextAlignVertical.top,
        keyboardType: keyboardType,
        obscureText: obscureText,
        enabled: enabled,
        cursorColor: HexColor('#1890FF'),
        maxLength: maxLength,
        maxLines: maxLines,
        expands: expands??false,
        textCapitalization: textCapitalization,
        inputFormatters: inputFormatters,
        style: textStyle ?? TextStyle(fontSize: 12.0),
        autofocus: autoFocus,
        decoration: decoration ??
            InputDecoration(
              hintText: hintText,
              labelText: labelText,
              prefixIcon: prefixSvgIcon != null
                  ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset(
                  prefixSvgIcon!,
                  color: prefixSvgColor,
                  width: 12.0,
                  height: 12.0,
                ),
              )
                  : null,
              suffixIcon: suffixSvgIcon != null
                  ? GestureDetector(
                onTap: onSuffixIconTap,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: suffixSvgIcon
                ),
              )
                  : null,
              filled: fillColor != null,
              fillColor: fillColor,
              hintStyle: TextStyle(fontSize: 12.0,color: Colors.grey.shade500,fontWeight: FontWeight.w300),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide(
                  color: borderColor ?? Colors.grey,
                  width: borderWidth,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide(
                  color: borderColor ?? Theme.of(context).primaryColor,
                  width: borderWidth,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide(
                  color: borderColor ?? Colors.grey,
                  width: borderWidth,
                ),
              ),
            ),
        validator: controller.validator,
      ),
    );
  }
}
