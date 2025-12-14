import 'package:flutter/material.dart';
import 'package:seismic_risk_app/core/theme/app_theme.dart';

enum AppButtonSize { small, medium, large }
enum AppButtonVariant { primary, secondary, outline, text }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final AppButtonSize size;
  final AppButtonVariant variant;
  final bool fullWidth;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.size = AppButtonSize.medium,
    this.variant = AppButtonVariant.primary,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final height = _getHeight();
    final fontSize = _getFontSize(isMobile);
    final iconSize = _getIconSize();
    final horizontalPadding = _getHorizontalPadding(isMobile);

    Widget button;

    switch (variant) {
      case AppButtonVariant.primary:
        button = _buildPrimaryButton(height, fontSize, iconSize, horizontalPadding);
        break;
      case AppButtonVariant.secondary:
        button = _buildSecondaryButton(height, fontSize, iconSize, horizontalPadding);
        break;
      case AppButtonVariant.outline:
        button = _buildOutlineButton(height, fontSize, iconSize, horizontalPadding);
        break;
      case AppButtonVariant.text:
        button = _buildTextButton(fontSize, iconSize, horizontalPadding);
        break;
    }

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }

    return button;
  }

  double _getHeight() {
    switch (size) {
      case AppButtonSize.small:
        return 40;
      case AppButtonSize.medium:
        return 52;
      case AppButtonSize.large:
        return 56;
    }
  }

  double _getFontSize(bool isMobile) {
    switch (size) {
      case AppButtonSize.small:
        return isMobile ? 14 : 15;
      case AppButtonSize.medium:
        return isMobile ? 15 : 16;
      case AppButtonSize.large:
        return isMobile ? 16 : 17;
    }
  }

  double _getIconSize() {
    switch (size) {
      case AppButtonSize.small:
        return 18;
      case AppButtonSize.medium:
        return 20;
      case AppButtonSize.large:
        return 22;
    }
  }

  double _getHorizontalPadding(bool isMobile) {
    switch (size) {
      case AppButtonSize.small:
        return isMobile ? 20 : 24;
      case AppButtonSize.medium:
        return isMobile ? 24 : 32;
      case AppButtonSize.large:
        return isMobile ? 28 : 36;
    }
  }

  Widget _buildButtonContent(
    IconData? icon,
    String label,
    double iconSize,
    double fontSize,
    Color textColor,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: iconSize, color: textColor),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton(
      double height, double fontSize, double iconSize, double horizontalPadding) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: onPressed == null || isLoading ? AppTheme.grey300 : AppTheme.primary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            alignment: Alignment.center,
            child: isLoading
                ? SizedBox(
                    width: iconSize,
                    height: iconSize,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.textLight),
                    ),
                  )
                : _buildButtonContent(
                    icon, label, iconSize, fontSize, AppTheme.textLight),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(
      double height, double fontSize, double iconSize, double horizontalPadding) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: AppTheme.accentGradient,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            alignment: Alignment.center,
            child: isLoading
                ? SizedBox(
                    width: iconSize,
                    height: iconSize,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.textLight),
                    ),
                  )
                : _buildButtonContent(
                    icon, label, iconSize, fontSize, AppTheme.textLight),
          ),
        ),
      ),
    );
  }

  Widget _buildOutlineButton(
      double height, double fontSize, double iconSize, double horizontalPadding) {
    return SizedBox(
      height: height,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.primary,
          side: BorderSide(color: AppTheme.borderMedium, width: 1.5),
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: iconSize,
                height: iconSize,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                ),
              )
            : _buildButtonContent(icon, label, iconSize, fontSize, AppTheme.primary),
      ),
    );
  }

  Widget _buildTextButton(
      double fontSize, double iconSize, double horizontalPadding) {
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppTheme.primary,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding * 0.8, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: TextStyle(
          fontSize: fontSize * 0.95,
          fontWeight: FontWeight.w600,
        ),
      ),
      child: isLoading
          ? SizedBox(
              width: iconSize,
              height: iconSize,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
              ),
            )
          : _buildButtonContent(icon, label, iconSize, fontSize * 0.95, AppTheme.primary),
    );
  }
}
