import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seismic_risk_app/core/theme/app_theme.dart';
import 'package:seismic_risk_app/domain/entities/building.dart';
import 'package:seismic_risk_app/presentation/providers/building_provider.dart';
import 'package:seismic_risk_app/presentation/widgets/responsive/app_button.dart';
import 'package:seismic_risk_app/presentation/widgets/responsive/app_card.dart';
import 'package:seismic_risk_app/presentation/widgets/responsive/responsive_layout.dart';

class RoofTypeScreen extends ConsumerStatefulWidget {
  final VoidCallback? onComplete;
  const RoofTypeScreen({super.key, this.onComplete});

  @override
  ConsumerState<RoofTypeScreen> createState() => _RoofTypeScreenState();
}

class _RoofTypeScreenState extends ConsumerState<RoofTypeScreen> {
  RoofType? _selectedRoofType;

  @override
  void initState() {
    super.initState();
    final building = ref.read(buildingProvider);
    _selectedRoofType = building?.roofType;
  }

  void _saveAndContinue() {
    if (_selectedRoofType != null) {
      ref.read(buildingProvider.notifier).updateBuilding({
        'roofType': _selectedRoofType,
      });
    }
    widget.onComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final padding = ResponsiveLayout.getPadding(context);

    final roofTypes = [
      {'type': RoofType.flat, 'label': 'Flat Roof', 'icon': Icons.flatware_rounded, 'description': 'Horizontal or nearly horizontal roof'},
      {'type': RoofType.pitched, 'label': 'Pitched Roof', 'icon': Icons.roofing_rounded, 'description': 'Sloped roof with angles'},
      {'type': RoofType.dome, 'label': 'Dome', 'icon': Icons.lens_rounded, 'description': 'Curved dome-shaped roof'},
      {'type': RoofType.other, 'label': 'Other', 'icon': Icons.category_rounded, 'description': 'Other roof type'},
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
                'What type of roof does your building have?',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
              ),
              const SizedBox(height: 32),
              ...roofTypes.map((roofType) {
                final type = roofType['type'] as RoofType;
                final label = roofType['label'] as String;
                final icon = roofType['icon'] as IconData;
                final description = roofType['description'] as String;
                final isSelected = _selectedRoofType == type;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: AppCard(
                    padding: EdgeInsets.zero,
                    onTap: () {
                      setState(() {
                        _selectedRoofType = type;
                      });
                      // Auto-save when selection is made
                      if (_selectedRoofType != null) {
                        ref.read(buildingProvider.notifier).updateBuilding({
                          'roofType': _selectedRoofType,
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
              onPressed: _selectedRoofType != null ? _saveAndContinue : null,
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

