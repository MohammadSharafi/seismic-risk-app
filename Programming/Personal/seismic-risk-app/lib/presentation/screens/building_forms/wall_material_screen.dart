import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seismic_risk_app/core/theme/app_theme.dart';
import 'package:seismic_risk_app/domain/entities/building.dart';
import 'package:seismic_risk_app/presentation/providers/building_provider.dart';
import 'package:seismic_risk_app/presentation/widgets/responsive/app_button.dart';
import 'package:seismic_risk_app/presentation/widgets/responsive/app_card.dart';
import 'package:seismic_risk_app/presentation/widgets/responsive/responsive_layout.dart';

class WallMaterialScreen extends ConsumerStatefulWidget {
  final VoidCallback? onComplete;
  const WallMaterialScreen({super.key, this.onComplete});

  @override
  ConsumerState<WallMaterialScreen> createState() => _WallMaterialScreenState();
}

class _WallMaterialScreenState extends ConsumerState<WallMaterialScreen> {
  WallMaterial? _selectedMaterial;

  @override
  void initState() {
    super.initState();
    final building = ref.read(buildingProvider);
    _selectedMaterial = building?.wallMaterial;
  }

  void _saveAndContinue() {
    if (_selectedMaterial != null) {
      ref.read(buildingProvider.notifier).updateBuilding({
        'wallMaterial': _selectedMaterial,
      });
    }
    widget.onComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final padding = ResponsiveLayout.getPadding(context);

    final materials = [
      {'type': WallMaterial.brick, 'label': 'Brick', 'icon': Icons.square_rounded, 'description': 'Traditional brick masonry'},
      {'type': WallMaterial.stone, 'label': 'Stone', 'icon': Icons.diamond_rounded, 'description': 'Natural stone construction'},
      {'type': WallMaterial.concreteBlock, 'label': 'Concrete Block', 'icon': Icons.view_quilt_rounded, 'description': 'Concrete block walls'},
      {'type': WallMaterial.pouredInPlaceConcrete, 'label': 'Poured Concrete', 'icon': Icons.water_drop_rounded, 'description': 'Cast-in-place concrete'},
      {'type': WallMaterial.timber, 'label': 'Timber/Wood', 'icon': Icons.forest_rounded, 'description': 'Wooden frame construction'},
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
                'What material are the exterior walls made of?',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
              ),
              const SizedBox(height: 32),
              ...materials.map((material) {
                final type = material['type'] as WallMaterial;
                final label = material['label'] as String;
                final icon = material['icon'] as IconData;
                final description = material['description'] as String;
                final isSelected = _selectedMaterial == type;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: AppCard(
                    padding: EdgeInsets.zero,
                    onTap: () {
                      setState(() {
                        _selectedMaterial = type;
                      });
                      // Auto-save when selection is made
                      if (_selectedMaterial != null) {
                        ref.read(buildingProvider.notifier).updateBuilding({
                          'wallMaterial': _selectedMaterial,
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
              onPressed: _selectedMaterial != null ? _saveAndContinue : null,
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

