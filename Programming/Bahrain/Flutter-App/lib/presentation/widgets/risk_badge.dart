import 'package:flutter/material.dart';
import '../../domain/value_objects/risk_tier.dart';
import '../theme/app_theme.dart';
import '../theme/tailwind_spacing.dart';

enum BadgeSize { sm, md, lg }

class RiskBadge extends StatelessWidget {
  final RiskTier tier;
  final BadgeSize size;

  const RiskBadge({
    super.key,
    required this.tier,
    this.size = BadgeSize.md,
  });

  @override
  Widget build(BuildContext context) {
    final (backgroundColor, textColor, borderColor, dotColor) = _getColors();
    final (horizontalPadding, verticalPadding, fontSize) = _getSizing();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(TailwindRadius.rounded), // rounded
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5, // smaller dot
            height: 5, // smaller dot
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle, // rounded-full
            ),
          ),
          const SizedBox(width: 5), // smaller gap
          Text(
            '${tier.displayName} Risk',
            style: TextStyle(
              color: textColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w500, // font-medium (matching React)
              height: 1.5,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color, Color, Color) _getColors() {
    switch (tier) {
      case RiskTier.high:
        return (
          AppTheme.red100, // bg-red-100
          AppTheme.red800, // text-red-800 (not red-700)
          AppTheme.red200, // border-red-200
          AppTheme.red600, // dot bg-red-500 (using red-600)
        );
      case RiskTier.medium:
        return (
          AppTheme.amber100, // bg-amber-100
          AppTheme.amber800, // text-amber-800
          AppTheme.amber200, // border-amber-200
          AppTheme.amber600, // dot bg-amber-500 (using amber-600)
        );
      case RiskTier.low:
        return (
          AppTheme.green100, // bg-green-100
          AppTheme.green800, // text-green-800
          AppTheme.green200, // border-green-200
          AppTheme.green600, // dot bg-green-500 (using green-600)
        );
    }
  }

  (double, double, double) _getSizing() {
    switch (size) {
      case BadgeSize.sm:
        return (6, 2, TailwindFontSize.textXs); // px-1.5 py-0.5 text-xs
      case BadgeSize.md:
        return (8, 2, TailwindFontSize.textXs); // px-2 py-0.5 text-xs (reduced)
      case BadgeSize.lg:
        return (10, 3, TailwindFontSize.textSm); // px-2.5 py-0.75 text-sm
    }
  }
}
