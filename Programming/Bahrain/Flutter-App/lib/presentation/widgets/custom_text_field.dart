import 'package:flutter/material.dart';
import 'package:dropdown_flutter/custom_dropdown.dart';
import '../theme/app_theme.dart';
import '../theme/tailwind_spacing.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? placeholder;
  final int maxLines;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  const CustomTextField({
    super.key,
    this.controller,
    this.label,
    this.placeholder,
    this.maxLines = 1,
    this.enabled = true,
    this.onChanged,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late FocusNode _focusNode;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _hasFocus = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: const TextStyle(
              fontSize: TailwindFontSize.textXs, // text-xs
              color: AppTheme.gray600,
              height: 1.5,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 6), // mb-1.5
        ],
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF3F3F5), // bg-input-background from React (#f3f3f5)
            border: Border.all(
              color: _hasFocus ? AppTheme.blue600 : AppTheme.gray300,
              width: _hasFocus ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(6), // rounded-md = 6px
            boxShadow: _hasFocus
                ? [
                    BoxShadow(
                      color: AppTheme.blue600.withOpacity(0.15),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            enabled: widget.enabled,
            maxLines: widget.maxLines,
            onChanged: widget.onChanged,
            style: const TextStyle(
              fontSize: TailwindFontSize.textSm, // text-sm = 14px
              color: AppTheme.gray900,
              height: 1.5,
              letterSpacing: 0,
            ),
            decoration: InputDecoration(
              hintText: widget.placeholder,
              hintStyle: TextStyle(
                fontSize: TailwindFontSize.textSm,
                color: AppTheme.gray400.withOpacity(0.8),
                height: 1.5,
                letterSpacing: 0,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12, // px-3
                vertical: widget.maxLines > 1 ? 10 : 8, // py-2 (better for multiline)
              ),
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }
}

class CustomDropdown<T> extends StatelessWidget {
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?>? onChanged;
  final String? label;

  const CustomDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.itemLabel,
    this.onChanged,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              fontSize: TailwindFontSize.textXs, // text-xs
              color: AppTheme.gray600,
              height: 1.5,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 4), // mb-1
        ],
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppTheme.gray300),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              items: items.map((item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: Text(
                    itemLabel(item),
                    style: const TextStyle(
                      fontSize: TailwindFontSize.textSm,
                      color: AppTheme.gray900,
                      height: 1.5,
                      letterSpacing: 0,
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
              icon: Icon(
                Icons.keyboard_arrow_down,
                size: 16,
                color: AppTheme.gray500,
              ),
              dropdownColor: Colors.white,
              style: const TextStyle(
                fontSize: TailwindFontSize.textSm,
                color: AppTheme.gray900,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
