import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../march_style/march_size.dart';
import '../../../march_style/march_theme.dart';
import 'custom_text_form_field_notifier.dart';




// Custom formatter for phone number input
class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Allow only digits, +, (, ), -, and spaces
    String cleaned = newValue.text.replaceAll(RegExp(r'[^\d+()-]'), '');

    // If the input is empty, return as is
    if (cleaned.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Extract country code and number part
    String countryCode = '';
    String numberPart = '';
    String digits = cleaned.replaceAll(RegExp(r'[^\d]'), '');

    // Identify country code (e.g., +X, +XX, or +XXX)
    if (cleaned.startsWith('+')) {
      int countryCodeLength = cleaned.indexOf(RegExp(r'\d'), 1) + 1;
      if (countryCodeLength > 1 && countryCodeLength <= 4) {
        countryCode = cleaned.substring(0, countryCodeLength);
        numberPart = digits.substring(countryCodeLength - 1);
      } else {
        countryCode = cleaned[0]; // Just the '+' if no valid country code
        numberPart = digits;
      }
    } else {
      // If no country code, treat all as number part
      numberPart = digits;
    }

    // Format the number part: (XXX) XXX-XXXX
    String formatted = countryCode;
    if (numberPart.isNotEmpty) {
      if (numberPart.length > 0) {
        formatted += ' (';
        int i = 0;
        while (i < numberPart.length && i < 3) {
          formatted += numberPart[i];
          i++;
        }
        formatted += ')';
        if (i < numberPart.length) {
          formatted += ' ';
          while (i < numberPart.length && i < 6) {
            formatted += numberPart[i];
            i++;
          }
          if (i < numberPart.length) {
            formatted += '-';
            while (i < numberPart.length && i < 10) {
              formatted += numberPart[i];
              i++;
            }
          }
        }
      }
    }

    // Adjust cursor position
    int cursorOffset = newValue.selection.baseOffset +
        (formatted.length - newValue.text.length);
    cursorOffset = cursorOffset.clamp(0, formatted.length);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursorOffset),
    );
  }
}


// Phone number input field with country code
class _PhoneTextFormField extends CustomTextFormField {
  _PhoneTextFormField({
    required String labelText,
    TextEditingController? controller,
    void Function()? onTap,
    bool? deActive,
    int? lengthOfInput,
  }) : super(
    labelText: labelText,
    controller: controller,
    onTap: onTap,
    deActive: deActive,
    lengthOfInput: lengthOfInput,
    keyboardType: TextInputType.phone,
    inputFormatters: [
      PhoneNumberFormatter(), // Use custom formatter
    ],
    maxLength: 18,
    maxLine: 1,
    hintText: '+91 (123) 456-7890',
    validator: (text) {
      if (text == null || text.isEmpty) {
        return 'Phone number is required';
      }
      // Regex for international phone numbers with country code
      final phoneRegex = RegExp(
          r'^\+\d{1,3}\s?\(\d{1,3}\)\s?\d{1,3}-\d{1,4}$');
      if (!phoneRegex.hasMatch(text)) {
        return 'Enter a valid phone number (e.g., +91 (123) 456-7890)';
      }
      return null;
    },
  );

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: deActive ?? false,
      child: ChangeNotifierProvider(
        create: (context) => CustomTextFormFieldProvider(TypeTextFormInput.phone)
          ..setText(controller?.text ?? ''),
        child: Consumer<CustomTextFormFieldProvider>(
          builder: (context, provider, child) {
            return TextFormField(
              cursorColor: Colors.black54,
              cursorWidth: 1,
              controller: controller,
              onTap: onTap,
              keyboardType: keyboardType,
              maxLines: maxLine,
              inputFormatters: inputFormatters,
              maxLength: maxLength,
              onChanged: (value) {
                provider.setText(value);
                onChanged?.call(value);
              },
              style: TextStyle(
                color: marchColorData[MarchColor.blackInput],
                fontSize: 14,
                height: 1.5,
              ),
              validator: validator,
              decoration: InputDecoration(
                filled: true,
                fillColor:
                deActive == true ? Colors.black.withOpacity(0.1) : Colors.white,
                hintText: hintText,
                hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: marchColorData[MarchColor.extraLightBlack],
                  fontSize: 13,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: MarchSize.smallPaddingAll,
                  vertical: MarchSize.smallPaddingAll * 1.5,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: marchColorData[MarchColor.extraLightBlack]!,
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: marchColorData[MarchColor.purpleExtraDark]!,
                    width: 1.0,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: marchColorData[MarchColor.errorColor]!,
                    width: 1.0,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: marchColorData[MarchColor.errorColor]!,
                    width: 1.0,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
























// Provider for multiline input fields
class CustomMultiLineTextFormFieldProvider extends ChangeNotifier {
  int lengthOfInputValue;

  CustomMultiLineTextFormFieldProvider(this.lengthOfInputValue);

  void changeState(String value) {
    lengthOfInputValue = value.length;
    notifyListeners();
  }
}

// Main CustomTextFormField widget
class CustomTextFormField extends StatelessWidget {
  // Factory for multiline mode
  factory CustomTextFormField.multiLine({
    required String labelText,
    void Function()? onTap,
    ScrollController? scrollController,
    TextEditingController? controller,
    bool? deActive,
    int? lengthOfInput,
  }) = _MultiLineTextFormField;

  // Factory for phone number mode
  factory CustomTextFormField.phone({
    required String labelText,
    void Function()? onTap,
    TextEditingController? controller,
    bool? deActive,
    int? lengthOfInput,
  }) = _PhoneTextFormField;

  // Constructor for single-line mode
  CustomTextFormField({
    Key? key,
    this.labelText,
    this.hintText,
    this.deActive,
    this.suffixIconPressed,
    this.suffixIcon,
    this.suffixIconSize = 11,
    this.typeTextFormInput,
    this.inputFormatters,
    this.scrollController,
    this.onTap,
    this.controller,
    this.lengthOfInput,
    this.maxLength,
    this.enabledBorder,
    this.focusedBorder,
    this.suffixIconWidget,
    this.labelColorText,
    this.readOnly,
    this.autoFocus,
    this.prefixIconWidget,
    this.floatingLabelBehavior,
    this.fillColor,
    this.contentPadding,
    this.isDense,
    this.onFieldSubmitted,
    this.onChanged,
    this.validator,
    this.counterText,
    this.title,
    this.titleColor,
    this.textColor,
    this.expands,
    this.suffixText,
    this.enabledWithingTextBorder,
    this.focusNode,
    this.error,
    this.helperText,
    this.errorColor,
    this.prefixText,
    this.isCollapsed = false,
    this.maxLine,
    this.keyboardType,
  }) : super(key: key);

  // Properties
  final String? labelText;
  final String? hintText;
  final String? suffixText;
  final Color? labelColorText;
  final Color? textColor;
  final int? lengthOfInput;
  final int? maxLength;
  final Color? titleColor;
  final TextEditingController? controller;
  final String? suffixIcon;
  final double suffixIconSize;
  final void Function()? suffixIconPressed;
  final TypeTextFormInput? typeTextFormInput;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final ScrollController? scrollController;
  final void Function()? onTap;
  final InputBorder? enabledBorder;
  final InputBorder? enabledWithingTextBorder;
  final InputBorder? focusedBorder;
  final Widget? suffixIconWidget;
  final Widget? prefixIconWidget;
  final FloatingLabelBehavior? floatingLabelBehavior;
  final Color? fillColor;
  final EdgeInsetsGeometry? contentPadding;
  final bool? isDense;
  final bool? readOnly;
  final bool isCollapsed;
  final bool? autoFocus;
  final bool? expands;
  final String? counterText;
  final String? title;
  final String? error;
  final String? helperText;
  final String? prefixText;
  final int? maxLine;
  final Color? errorColor;
  final void Function(String)? onFieldSubmitted;
  final Function(String)? onChanged;
  final FocusNode? focusNode;
  final bool? deActive;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => CustomTextFormFieldProvider(
              typeTextFormInput ?? TypeTextFormInput.userName)
            ..setText(controller?.text ?? ''),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(context),
          expands == true ? Expanded(child: _buildTextField(context)) : _buildTextField(context),
        ],
      ),
    );
  }

  // Builds the title widget if provided
  Widget _buildTitle(BuildContext context) {
    return Consumer<CustomTextFormFieldProvider>(
      builder: (context, provider, child) {
        if (title == null || (!provider.isFocused && controller!.text.isEmpty)) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: EdgeInsets.only(bottom: MarchSize.smallPaddingAll),
          child: Text(
            title!,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              fontSize: 12,
              color: titleColor ?? marchColorData[MarchColor.primary],
            ),
          ),
        );
      },
    );
  }

  // Builds the TextFormField
  Widget _buildTextField(BuildContext context) {
    return Consumer<CustomTextFormFieldProvider>(
      builder: (context, provider, child) {
        return Focus(
          focusNode: focusNode ?? FocusNode(),
          onFocusChange: (value) => provider.setIsFocused(value),
          child: TextFormField(
            expands: expands ?? false,
            maxLines: maxLine,
            cursorColor: Colors.black54,
            cursorWidth: 1,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            readOnly: readOnly ?? false,
            autofocus: autoFocus ?? false,
            onFieldSubmitted: onFieldSubmitted,
            controller: controller
              ?..addListener(() {
                provider.refresh();
              }),
            inputFormatters: inputFormatters,
            maxLength: maxLength,
            onTap: onTap,
            keyboardType: keyboardType ?? TextInputType.multiline,
            onChanged: (value) {
              provider.setText(value);
              onChanged?.call(value);
            },
            style: TextStyle(color: marchColorData[MarchColor.blackInput]),
            validator: validator ?? (text) => error,
            decoration: InputDecoration(
              isDense: isDense,
              alignLabelWithHint: true,
              isCollapsed: isCollapsed,
              counterText: counterText,
              contentPadding: contentPadding,
              floatingLabelBehavior: floatingLabelBehavior,
              hintText: hintText,
              helperText: (controller!.text.isNotEmpty && !provider.isFocused)
                  ? null
                  : helperText,
              helperMaxLines: 2,
              helperStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: marchColorData[provider.isFocused
                    ? MarchColor.focusBorder
                    : MarchColor.extraLightBlack],
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(MarchSize.tinyRadius)),
                borderSide: BorderSide(
                    color: errorColor ?? marchColorData[MarchColor.errorColor]!),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(MarchSize.tinyRadius)),
                borderSide: BorderSide(
                    color: errorColor ?? marchColorData[MarchColor.errorColor]!),
              ),
              focusedBorder: focusedBorder ??
                  OutlineInputBorder(
                    borderRadius:
                    BorderRadius.all(Radius.circular(MarchSize.tinyRadius)),
                    borderSide: BorderSide(
                        color: deActive == true
                            ? Colors.transparent
                            : marchColorData[MarchColor.primary]!),
                  ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(MarchSize.tinyRadius)),
                borderSide: BorderSide(
                    color: deActive == true
                        ? Colors.transparent
                        : marchColorData[MarchColor.primary]!),
              ),
              enabledBorder: enabledBorder ??
                  OutlineInputBorder(
                      borderRadius:
                      BorderRadius.all(Radius.circular(MarchSize.tinyRadius)),
                      borderSide: BorderSide(
                          color: marchColorData[controller!.text.isNotEmpty
                              ? (error == null
                              ? MarchColor.primary
                              : MarchColor.errorColor)
                              : MarchColor.extraLightBlack]!)),
              filled: true,
              fillColor: deActive == true
                  ? Colors.black.withOpacity(0.1)
                  : fillColor ?? Colors.transparent,
              hintStyle: TextStyle(color: labelColorText, fontSize: 12),
              errorText: error == '' ? null : error,
              errorMaxLines: 2,
              errorStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: errorColor ?? marchColorData[MarchColor.redDark]),
              prefixText: controller!.text.isNotEmpty ? prefixText : null,
              prefixStyle: TextStyle(
                  color: marchColorData[provider.isFocused
                      ? MarchColor.focusBorder
                      : MarchColor.primary]),
              prefixIcon: prefixIconWidget,
              prefixIconConstraints: const BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
              suffixIconConstraints: BoxConstraints(
                minWidth: MarchSize.smallWidth,
                minHeight: MarchSize.smallWidth,
              ),
              suffixIcon: _buildSuffixIcon(context, provider),
            ),
          ),
        );
      },
    );
  }

  // Builds the suffix icon or text
  Widget? _buildSuffixIcon(BuildContext context, CustomTextFormFieldProvider provider) {
    if (suffixText != null && controller!.text.isNotEmpty) {
      return Padding(
        padding: EdgeInsets.only(right: MarchSize.smallPaddingAll * 2),
        child: Text(
          suffixText!,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            color: marchColorData[MarchColor.extraLightBlack],
          ),
        ),
      );
    }
    if (suffixIconWidget != null) return suffixIconWidget;
    return Padding(
      padding: EdgeInsetsDirectional.only(top: MarchSize.paddingMediumTop * 1.25),
      child: InkWell(
        onTap: suffixIconPressed,
        child: SvgPicture.asset(
          suffixIcon ?? '',
          color: marchColorData[MarchColor.primary],
          height: suffixIconSize,
          width: suffixIconSize,
        ),
      ),
    );
  }
}

// Multiline input field
class _MultiLineTextFormField extends CustomTextFormField {
  _MultiLineTextFormField({
    required String labelText,
    TextEditingController? controller,
    void Function()? onTap,
    ScrollController? scrollController,
    bool? deActive,
    int? lengthOfInput,
  }) : super(
    labelText: labelText,
    scrollController: scrollController,
    onTap: onTap,
    controller: controller,
    deActive: deActive,
    lengthOfInput: lengthOfInput,
  );

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: deActive ?? false,
      child: ChangeNotifierProvider(
        create: (context) => CustomMultiLineTextFormFieldProvider(lengthOfInput ?? 0),
        child: Consumer<CustomMultiLineTextFormFieldProvider>(
          builder: (context, provider, child) {
            return Stack(
              alignment: Alignment.bottomRight,
              children: [
                TextFormField(
                  cursorColor: Colors.black54,
                  cursorWidth: 1,
                  controller: controller,
                  onTap: onTap ??
                          () {
                        scrollController?.jumpTo(
                            scrollController!.position.maxScrollExtent);
                      },
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  minLines: 8,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(150),
                  ],
                  onChanged: provider.changeState,
                  style: TextStyle(
                    color: marchColorData[MarchColor.blackInput],
                    fontSize: 14,
                    height: 1.5,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: deActive == true ? Colors.black.withOpacity(0.1) : Colors.white,
                    hintText: labelText,
                    hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: marchColorData[MarchColor.extraLightBlack],
                      fontSize: 13,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: MarchSize.smallPaddingAll,
                      vertical: MarchSize.smallPaddingAll * 1.5,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(
                        color: marchColorData[MarchColor.extraLightBlack]!,
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(
                        color: marchColorData[MarchColor.purpleExtraDark]!,
                        width: 1.0,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(
                        color: marchColorData[MarchColor.errorColor]!,
                        width: 1.0,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(
                        color: marchColorData[MarchColor.errorColor]!,
                        width: 1.0,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    '${provider.lengthOfInputValue}/150',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: marchColorData[MarchColor.extraLightBlack],
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// Phone number input field with country code
