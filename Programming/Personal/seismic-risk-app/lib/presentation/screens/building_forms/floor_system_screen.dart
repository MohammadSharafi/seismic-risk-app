import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seismic_risk_app/core/theme/app_theme.dart';
import 'package:seismic_risk_app/domain/entities/building.dart';
import 'package:seismic_risk_app/presentation/providers/building_provider.dart';
import 'package:seismic_risk_app/presentation/widgets/responsive/app_button.dart';
import 'package:seismic_risk_app/presentation/widgets/responsive/app_card.dart';
import 'package:seismic_risk_app/presentation/widgets/responsive/responsive_layout.dart';

class FloorSystemScreen extends ConsumerStatefulWidget {
  final VoidCallback? onComplete;
  const FloorSystemScreen({super.key, this.onComplete});

  @override
  ConsumerState<FloorSystemScreen> createState() => _FloorSystemScreenState();
}

class _FloorSystemScreenState extends ConsumerState<FloorSystemScreen> {
  FloorSystem? _selectedFloorSystem;

  @override
  void initState() {
    super.initState();
    final building = ref.read(buildingProvider);
    _selectedFloorSystem = building?.floorSystem;
  }

  void _saveAndContinue() {
    if (_selectedFloorSystem != null) {
      ref.read(buildingProvider.notifier).updateBuilding({
        'floorSystem': _selectedFloorSystem,
      });
    }
    widget.onComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final padding = ResponsiveLayout.getPadding(context);

    final floorSystems = [
      {'type': FloorSystem.slabOnGrade, 'label': 'Slab on Grade', 'icon': Icons.layers_rounded, 'description': 'Concrete slab directly on ground'},
      {'type': FloorSystem.monolithicRcSlab, 'label': 'Monolithic RC Slab', 'icon': Icons.view_quilt_rounded, 'description': 'Reinforced concrete slab'},
      {'type': FloorSystem.precastSlab, 'label': 'Precast Slab', 'icon': Icons.dashboard_rounded, 'description': 'Pre-fabricated concrete slabs'},
      {'type': FloorSystem.timber, 'label': 'Timber', 'icon': Icons.forest_rounded, 'description': 'Wooden floor system'},
      {'type': FloorSystem.other, 'label': 'Other', 'icon': Icons.category_rounded, 'description': 'Other floor system type'},
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
                'What type of floor system does your building use?',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
              ),
              const SizedBox(height: 32),
              ...floorSystems.map((floorSystem) {
                final type = floorSystem['type'] as FloorSystem;
                final label = floorSystem['label'] as String;
                final icon = floorSystem['icon'] as IconData;
                final description = floorSystem['description'] as String;
                final isSelected = _selectedFloorSystem == type;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: AppCard(
                    padding: EdgeInsets.zero,
                    onTap: () {
                      setState(() {
                        _selectedFloorSystem = type;
                      });
                      // Auto-save when selection is made
                      if (_selectedFloorSystem != null) {
                        ref.read(buildingProvider.notifier).updateBuilding({
                          'floorSystem': _selectedFloorSystem,
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
              onPressed: _selectedFloorSystem != null ? _saveAndContinue : null,
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

