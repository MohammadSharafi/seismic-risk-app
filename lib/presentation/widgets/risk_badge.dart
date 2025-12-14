import 'package:flutter/material.dart';
import 'package:seismic_risk_app/core/theme/app_theme.dart';

class RiskBadge extends StatelessWidget {
  final double probability;

  const RiskBadge({
    super.key,
    required this.probability,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.getRiskColor(probability);
    final label = AppTheme.getRiskLabel(probability);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

