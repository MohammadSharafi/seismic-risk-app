import 'package:flutter/material.dart';
import '../../domain/entities/visit.dart';
import '../theme/app_theme.dart';
import '../theme/tailwind_spacing.dart';

class EvidenceChip extends StatelessWidget {
  final EvidenceReference evidence;
  final VoidCallback? onTap;

  const EvidenceChip({
    super.key,
    required this.evidence,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: _buildTooltipMessage(),
      preferBelow: false,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8, // px-2
            vertical: 4, // py-1
          ),
          decoration: BoxDecoration(
            color: AppTheme.blue50, // bg-blue-50
            border: Border.all(color: AppTheme.blue200), // border-blue-200
            borderRadius: BorderRadius.circular(4), // rounded
          ),
          child: Text(
            evidence.label,
            style: const TextStyle(
              fontSize: TailwindFontSize.textXs, // text-xs = 12px
              fontWeight: FontWeight.w500, // font-medium
              color: AppTheme.blue700, // text-blue-700
              height: 1.5,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }

  String _buildTooltipMessage() {
    // Build tooltip message based on evidence type
    // This is a simplified version - in real app, evidence would have more fields
    return 'Type: ${evidence.type}\n${evidence.label}';
  }
}

class EvidenceTooltip extends StatelessWidget {
  final EvidenceReference evidence;

  const EvidenceTooltip({
    super.key,
    required this.evidence,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12), // p-3
      decoration: BoxDecoration(
        color: AppTheme.gray900, // bg-gray-900
        borderRadius: BorderRadius.circular(8), // rounded-lg
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Type: ${evidence.type}',
            style: const TextStyle(
              fontSize: TailwindFontSize.textSm, // text-sm = 14px
              fontWeight: FontWeight.w600, // font-semibold
              color: Colors.white,
              height: 1.5,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 4), // mb-1
          Text(
            evidence.label,
            style: const TextStyle(
              fontSize: TailwindFontSize.textSm, // text-sm = 14px
              color: AppTheme.gray300, // text-gray-300
              height: 1.5,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}
