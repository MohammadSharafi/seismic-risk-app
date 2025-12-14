import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seismic_risk_app/core/theme/app_theme.dart';
import 'package:seismic_risk_app/domain/entities/building.dart';
import 'package:seismic_risk_app/presentation/providers/building_provider.dart';
import 'package:seismic_risk_app/presentation/widgets/responsive/app_button.dart';
import 'package:seismic_risk_app/presentation/widgets/responsive/app_card.dart';
import 'package:seismic_risk_app/presentation/widgets/responsive/responsive_layout.dart';

class LateralResistanceScreen extends ConsumerStatefulWidget {
  final VoidCallback? onComplete;
  const LateralResistanceScreen({super.key, this.onComplete});

  @override
  ConsumerState<LateralResistanceScreen> createState() => _LateralResistanceScreenState();
}

class _LateralResistanceScreenState extends ConsumerState<LateralResistanceScreen> {
  LateralResistanceSystem? _selectedSystem;

  @override
  void initState() {
    super.initState();
    final building = ref.read(buildingProvider);
    _selectedSystem = building?.lateralResistanceSystem;
  }

  void _saveAndContinue() {
    if (_selectedSystem != null) {
      ref.read(buildingProvider.notifier).updateBuilding({
        'lateralResistanceSystem': _selectedSystem,
      });
    }
    widget.onComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final padding = ResponsiveLayout.getPadding(context);

    final systems = [
      {'type': LateralResistanceSystem.momentFrames, 'label': 'Moment Frames', 'icon': Icons.view_module_rounded, 'description': 'Rigid frame connections resist lateral forces'},
      {'type': LateralResistanceSystem.shearWalls, 'label': 'Shear Walls', 'icon': Icons.border_vertical_rounded, 'description': 'Vertical walls that resist lateral loads'},
      {'type': LateralResistanceSystem.braces, 'label': 'Braces', 'icon': Icons.height_rounded, 'description': 'Diagonal bracing systems'},
      {'type': LateralResistanceSystem.noneUnknown, 'label': 'None / Unknown', 'icon': Icons.help_outline_rounded, 'description': 'No specific lateral resistance system or unknown'},
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
                'What system does your building use to resist lateral (horizontal) forces?',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
              ),
              const SizedBox(height: 32),
              ...systems.map((system) {
                final type = system['type'] as LateralResistanceSystem;
                final label = system['label'] as String;
                final icon = system['icon'] as IconData;
                final description = system['description'] as String;
                final isSelected = _selectedSystem == type;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: AppCard(
                    padding: EdgeInsets.zero,
                    onTap: () {
                      setState(() {
                        _selectedSystem = type;
                      });
                      // Auto-save when selection is made
                      if (_selectedSystem != null) {
                        ref.read(buildingProvider.notifier).updateBuilding({
                          'lateralResistanceSystem': _selectedSystem,
                        });
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(isMobile ? 20 : 24),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected ? AppTheme.primary : AppTheme.grey200,
                          width: isSelected ? 2 : 1.5,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        color: isSelected ? AppTheme.primary.withOpacity(0.1) : AppTheme.surface,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.primary : AppTheme.grey100,
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
                                        color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
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
                            Icon(Icons.check_circle_rounded, color: AppTheme.primary, size: 28),
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
              onPressed: _selectedSystem != null ? _saveAndContinue : null,
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

