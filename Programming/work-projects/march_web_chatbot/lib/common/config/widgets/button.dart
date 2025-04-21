import 'package:flutter/material.dart';

class ButtonController {
  void Function()? onPressed;
  String buttonText;
  double textSize;
  bool isLoading;
  bool isEnabled;

  ButtonController({
    this.onPressed,
    this.buttonText = 'Button',
    this.textSize=12,
    this.isLoading = false,
    this.isEnabled = true,
  });
}

class Button extends StatefulWidget {
  final ButtonController controller;
  final Color? color;
  final Gradient? gradient;
  final double borderRadius;
  final EdgeInsets padding;
  final TextStyle? textStyle;
  final IconData? icon;
  final double iconSize;
  final Color? iconColor;
  final Widget? customImage;
  final String? tooltip;
  final Duration animationDuration;
  final Color disabledColor;
  final Color loadingIndicatorColor;
  final bool animateOnTap;

  const Button({
    Key? key,
    required this.controller,
    this.color = Colors.blue,
    this.gradient,
    this.borderRadius = 8.0,
    this.padding = const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
    this.textStyle,
    this.icon,
    this.iconSize = 24.0,
    this.iconColor,
    this.customImage,
    this.tooltip,
    this.animationDuration = const Duration(milliseconds: 200),
    this.disabledColor = Colors.grey,
    this.loadingIndicatorColor = Colors.white,
    this.animateOnTap = true,
  }) : super(key: key);

  @override
  _ButtonState createState() => _ButtonState();
}

class _ButtonState extends State<Button> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
      lowerBound: 0.9,
      upperBound: 1.0,
    );
    _animation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);

    if (!widget.controller.isEnabled) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.controller.isEnabled && !widget.controller.isLoading) {
      widget.controller.onPressed?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonContent = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.customImage != null) ...[
          widget.customImage!,
          SizedBox(width: 8),
        ],
        if (widget.icon != null) ...[
          Icon(widget.icon, size: widget.iconSize, color: widget.iconColor ?? Colors.white),
          SizedBox(width: 8),
        ],
        Text(
          widget.controller.buttonText,
          style: widget.textStyle ?? TextStyle(color: Colors.white,fontWeight: FontWeight.w300, fontSize: widget.controller.textSize??12),
        ),
      ],
    );

    final button = AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: child,
        );
      },
      child: InkWell(
        onTap: _handleTap,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: Container(
          decoration: BoxDecoration(
            color: widget.controller.isEnabled
                ? (widget.gradient == null ? widget.color : null)
                : widget.disabledColor,
            gradient: widget.controller.isEnabled ? widget.gradient : null,
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          padding: widget.padding,
          alignment: Alignment.center,
          child: widget.controller.isLoading
              ? CircularProgressIndicator(
            color: widget.loadingIndicatorColor,
          )
              : buttonContent,
        ),
      ),
    );

    return Tooltip(
      message: widget.tooltip ?? '',
      child: widget.animateOnTap
          ? GestureDetector(
        onTapDown: (_) => _animationController.reverse(),
        onTapUp: (_) => _animationController.forward(),
        onTapCancel: () => _animationController.forward(),
        child: button,
      )
          : button,
    );
  }
}
