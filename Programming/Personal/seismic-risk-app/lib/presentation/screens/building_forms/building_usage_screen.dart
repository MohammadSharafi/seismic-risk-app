import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seismic_risk_app/core/theme/app_theme.dart';
import 'package:seismic_risk_app/domain/entities/building.dart';
import 'package:seismic_risk_app/presentation/providers/building_provider.dart';

class BuildingUsageScreen extends ConsumerStatefulWidget {
  final VoidCallback? onComplete;

  const BuildingUsageScreen({super.key, this.onComplete});

  @override
  ConsumerState<BuildingUsageScreen> createState() => _BuildingUsageScreenState();
}

class _BuildingUsageScreenState extends ConsumerState<BuildingUsageScreen> {
  BuildingUsage? _selectedUsage;

  final Map<BuildingUsage, Map<String, dynamic>> _usageOptions = {
    BuildingUsage.residential: {
      'label': 'Residential',
      'icon': Icons.home_rounded,
      'description': 'Houses, apartments, condos',
      'color': AppTheme.primary,
    },
    BuildingUsage.commercial: {
      'label': 'Commercial',
      'icon': Icons.store_rounded,
      'description': 'Shops, offices, retail spaces',
      'color': AppTheme.secondary,
    },
    BuildingUsage.mixed: {
      'label': 'Mixed Use',
      'icon': Icons.business_rounded,
      'description': 'Residential and commercial combined',
      'color': AppTheme.accent,
    },
    BuildingUsage.public: {
      'label': 'Public',
      'icon': Icons.account_balance_rounded,
      'description': 'Schools, hospitals, government buildings',
      'color': AppTheme.warning,
    },
    BuildingUsage.industrial: {
      'label': 'Industrial',
      'icon': Icons.factory_rounded,
      'description': 'Factories, warehouses, workshops',
      'color': AppTheme.error,
    },
  };

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 20 : 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Building Usage',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'What is the primary use of this building?',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              const SizedBox(height: 32),
              ..._usageOptions.entries.map((entry) {
                final usage = entry.key;
                final data = entry.value;
                final isSelected = _selectedUsage == usage;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedUsage = usage;
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (data['color'] as Color).withOpacity(0.1)
                            : AppTheme.surface,
                        border: Border.all(
                          color: isSelected
                              ? data['color'] as Color
                              : AppTheme.border,
                          width: isSelected ? 2.5 : 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: (data['color'] as Color).withOpacity(0.2),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? data['color'] as Color
                                  : (data['color'] as Color).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              data['icon'] as IconData,
                              color: isSelected
                                  ? Colors.white
                                  : data['color'] as Color,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['label'] as String,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textPrimary,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  data['description'] as String,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: AppTheme.textSecondary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle_rounded,
                              color: data['color'] as Color,
                              size: 28,
                            ),
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
    );
  }

  Future<void> _saveAndContinue() async {
    if (_selectedUsage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a building usage type')),
      );
      return;
    }

    try {
      await ref.read(buildingProvider.notifier).updateBuilding({
        'buildingUsage': _selectedUsage.toString().split('.').last,
      });

      if (widget.onComplete != null) {
        widget.onComplete!();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void saveData() {
    _saveAndContinue();
  }
}

