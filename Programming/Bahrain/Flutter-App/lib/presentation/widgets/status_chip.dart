import 'package:flutter/material.dart';
import '../../domain/value_objects/status.dart';
import '../theme/app_theme.dart';

class StatusChip extends StatelessWidget {
  final Status status;

  const StatusChip({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final (backgroundColor, textColor) = _getColors();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  (Color, Color) _getColors() {
    switch (status) {
      case Status.monitoring:
        return (AppTheme.blue100, AppTheme.blue800); // text-blue-800 (matching React)
      case Status.needsReview:
        return (AppTheme.orange100, AppTheme.orange800); // text-orange-800 (matching React)
      case Status.actionTaken:
        return (AppTheme.green100, AppTheme.green800); // text-green-800 (matching React)
    }
  }
}
