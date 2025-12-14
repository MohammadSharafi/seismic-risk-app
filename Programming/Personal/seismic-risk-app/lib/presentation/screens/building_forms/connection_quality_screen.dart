import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seismic_risk_app/core/theme/app_theme.dart';
import 'package:seismic_risk_app/domain/entities/building.dart';
import 'package:seismic_risk_app/presentation/providers/building_provider.dart';
import 'package:seismic_risk_app/presentation/widgets/responsive/app_button.dart';
import 'package:seismic_risk_app/presentation/widgets/responsive/app_card.dart';
import 'package:seismic_risk_app/presentation/widgets/responsive/responsive_layout.dart';

class ConnectionQualityScreen extends ConsumerStatefulWidget {
  final VoidCallback? onComplete;
  const ConnectionQualityScreen({super.key, this.onComplete});

  @override
  ConsumerState<ConnectionQualityScreen> createState() => _ConnectionQualityScreenState();
}

class _ConnectionQualityScreenState extends ConsumerState<ConnectionQualityScreen> {
  ConnectionQuality? _selectedQuality;

  @override
  void initState() {
    super.initState();
    final building = ref.read(buildingProvider);
    _selectedQuality = building?.connectionQuality;
  }

  void _saveAndContinue() {
    if (_selectedQuality != null) {
      ref.read(buildingProvider.notifier).updateBuilding({
        'connectionQuality': _selectedQuality,
      });
    }
    widget.onComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final padding = ResponsiveLayout.getPadding(context);

    final qualities = [
      {'type': ConnectionQuality.good, 'label': 'Good', 'icon': Icons.check_circle_rounded, 'description': 'Well-connected structural elements', 'color': AppTheme.success},
      {'type': ConnectionQuality.moderate, 'label': 'Moderate', 'icon': Icons.info_rounded, 'description': 'Adequate connections with some concerns', 'color': AppTheme.warning},
      {'type': ConnectionQuality.poor, 'label': 'Poor', 'icon': Icons.warning_rounded, 'description': 'Weak or damaged connections', 'color': AppTheme.error},
      {'type': ConnectionQuality.unknown, 'label': 'Unknown', 'icon': Icons.help_outline_rounded, 'description': 'Unable to assess connection quality', 'color': AppTheme.grey500},
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                'How would you rate the quality of structural connections (beam-column, wall-foundation, etc.)?',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
              ),
              const SizedBox(height: 32),
              ...qualities.map((quality) {
                final type = quality['type'] as ConnectionQuality;
                final label = quality['label'] as String;
                final icon = quality['icon'] as IconData;
                final description = quality['description'] as String;
                final color = quality['color'] as Color;
                final isSelected = _selectedQuality == type;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: AppCard(
                    padding: EdgeInsets.zero,
                    onTap: () {
                      setState(() {
                        _selectedQuality = type;
                      });
                      // Auto-save when selection is made
                      if (_selectedQuality != null) {
                        ref.read(buildingProvider.notifier).updateBuilding({
                          'connectionQuality': _selectedQuality,
                        });
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(isMobile ? 20 : 24),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected ? color : AppTheme.grey200,
                          width: isSelected ? 2 : 1.5,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        color: isSelected ? color.withOpacity(0.1) : AppTheme.surface,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected ? color : AppTheme.grey100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              icon,
                              color: isSelected ? AppTheme.textLight : AppTheme.textSecondary,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  label,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: isSelected ? color : AppTheme.textPrimary,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  description,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppTheme.textSecondary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(Icons.check_circle_rounded, color: color, size: 28),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: widget.onComplete == null ? Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: Border(top: BorderSide(color: AppTheme.grey200, width: 1)),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: AppButton(
              label: 'Continue',
              icon: Icons.arrow_forward_rounded,
              onPressed: _selectedQuality != null ? _saveAndContinue : null,
              variant: AppButtonVariant.primary,
              fullWidth: true,
              size: AppButtonSize.large,
            ),
          ),
        ),
      ) : null,
    );
  }
}

