import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seismic_risk_app/core/theme/app_theme.dart';
import 'package:seismic_risk_app/domain/entities/building.dart';
import 'package:seismic_risk_app/presentation/providers/building_provider.dart';
import 'package:seismic_risk_app/presentation/widgets/responsive/app_button.dart';
import 'package:seismic_risk_app/presentation/widgets/responsive/app_card.dart';
import 'package:seismic_risk_app/presentation/widgets/responsive/responsive_layout.dart';

class SoilTypeScreen extends ConsumerStatefulWidget {
  final VoidCallback? onComplete;
  const SoilTypeScreen({super.key, this.onComplete});

  @override
  ConsumerState<SoilTypeScreen> createState() => _SoilTypeScreenState();
}

class _SoilTypeScreenState extends ConsumerState<SoilTypeScreen> {
  SoilClass? _selectedSoilClass;

  final soilClasses = [
    {
      'type': SoilClass.a,
      'label': 'Class A - Hard Rock',
      'description': 'Hard rock sites (very stable, low amplification)',
      'icon': Icons.landscape_rounded,
      'color': AppTheme.success,
    },
    {
      'type': SoilClass.b,
      'label': 'Class B - Rock',
      'description': 'Rock sites (stable, moderate amplification)',
      'icon': Icons.terrain_rounded,
      'color': AppTheme.success,
    },
    {
      'type': SoilClass.c,
      'label': 'Class C - Dense Soil',
      'description': 'Very dense soil or soft rock (moderate amplification)',
      'icon': Icons.public_rounded,
      'color': AppTheme.warning,
    },
    {
      'type': SoilClass.d,
      'label': 'Class D - Stiff Soil',
      'description': 'Stiff soil (high amplification, common)',
      'icon': Icons.circle_rounded,
      'color': AppTheme.warning,
    },
    {
      'type': SoilClass.e,
      'label': 'Class E - Soft Clay',
      'description': 'Soft clay or liquefiable soil (very high amplification)',
      'icon': Icons.water_drop_rounded,
      'color': AppTheme.error,
    },
  ];

  @override
  void initState() {
    super.initState();
    final building = ref.read(buildingProvider);
    _selectedSoilClass = building?.soilClass;
  }

  void _saveAndContinue() {
    if (_selectedSoilClass != null) {
      ref.read(buildingProvider.notifier).updateBuilding({
        'soilClass': _selectedSoilClass,
      });
    }
    widget.onComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final padding = ResponsiveLayout.getPadding(context);

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
                'What type of soil is your building built on?',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Soil type significantly affects earthquake shaking intensity.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              const SizedBox(height: 32),
              ...soilClasses.map((soil) {
                final type = soil['type'] as SoilClass;
                final label = soil['label'] as String;
                final icon = soil['icon'] as IconData;
                final description = soil['description'] as String;
                final color = soil['color'] as Color;
                final isSelected = _selectedSoilClass == type;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: AppCard(
                    padding: EdgeInsets.zero,
                    onTap: () {
                      setState(() {
                        _selectedSoilClass = type;
                      });
                      // Auto-save
                      ref.read(buildingProvider.notifier).updateBuilding({
                        'soilClass': type,
                      });
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
              onPressed: _selectedSoilClass != null ? _saveAndContinue : null,
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

