import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/tailwind_spacing.dart';

enum ButtonVariant {
  primary,
  secondary,
  outline,
  ghost,
  danger,
}

enum ButtonSize {
  sm,
  md,
  lg,
}

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final Widget? icon;
  final Widget? trailingIcon;
  final bool fullWidth;
  final bool disabled;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.md,
    this.icon,
    this.trailingIcon,
    this.fullWidth = false,
    this.disabled = false,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.disabled || widget.onPressed == null;

    // Determine colors based on variant
    Color bgColor;
    Color hoverBgColor;
    Color textColor;
    Color? borderColor;

    switch (widget.variant) {
      case ButtonVariant.primary:
        bgColor = isDisabled ? AppTheme.gray300 : AppTheme.blue600;
        hoverBgColor = AppTheme.blue700;
        textColor = Colors.white;
        borderColor = null;
        break;
      case ButtonVariant.secondary:
        bgColor = isDisabled ? AppTheme.gray300 : AppTheme.green600;
        hoverBgColor = AppTheme.green700;
        textColor = Colors.white;
        borderColor = null;
        break;
      case ButtonVariant.outline:
        bgColor = Colors.white;
        hoverBgColor = AppTheme.gray50;
        textColor = AppTheme.gray700;
        borderColor = AppTheme.gray300;
        break;
      case ButtonVariant.ghost:
        bgColor = Colors.transparent;
        hoverBgColor = AppTheme.gray50;
        textColor = AppTheme.blue600;
        borderColor = null;
        break;
      case ButtonVariant.danger:
        bgColor = isDisabled ? AppTheme.gray300 : AppTheme.red600;
        hoverBgColor = AppTheme.red700;
        textColor = Colors.white;
        borderColor = null;
        break;
    }

    // Determine padding based on size
    EdgeInsets padding;
    double fontSize;
    double iconSize;

    switch (widget.size) {
      case ButtonSize.sm:
        padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6); // px-3 py-1.5
        fontSize = TailwindFontSize.textSm; // 14px
        iconSize = 16;
        break;
      case ButtonSize.md:
        padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8); // px-4 py-2
        fontSize = TailwindFontSize.textSm; // 14px
        iconSize = 16;
        break;
      case ButtonSize.lg:
        padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12); // px-6 py-3
        fontSize = TailwindFontSize.textBase; // 16px
        iconSize = 20;
        break;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: isDisabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: isDisabled ? null : widget.onPressed,
        child: Container(
          width: widget.fullWidth ? double.infinity : null,
          padding: padding,
          decoration: BoxDecoration(
            color: _isHovered && !isDisabled ? hoverBgColor : bgColor,
            border: borderColor != null ? Border.all(color: borderColor) : null,
            borderRadius: BorderRadius.circular(8), // rounded-lg
          ),
          child: Row(
            mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                SizedBox(
                  width: iconSize,
                  height: iconSize,
                  child: widget.icon,
                ),
                const SizedBox(width: 8), // gap-2
              ],
              Text(
                widget.text,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500, // font-medium
                  color: textColor,
                  height: 1.5,
                  letterSpacing: 0,
                ),
              ),
              if (widget.trailingIcon != null) ...[
                const SizedBox(width: 8), // gap-2
                SizedBox(
                  width: iconSize,
                  height: iconSize,
                  child: widget.trailingIcon,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
