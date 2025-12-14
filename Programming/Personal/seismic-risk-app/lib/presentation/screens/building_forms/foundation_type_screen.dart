import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seismic_risk_app/core/theme/app_theme.dart';
import 'package:seismic_risk_app/domain/entities/building.dart';
import 'package:seismic_risk_app/presentation/providers/building_provider.dart';

class FoundationTypeScreen extends ConsumerStatefulWidget {
  final VoidCallback? onComplete;

  const FoundationTypeScreen({super.key, this.onComplete});

  @override
  ConsumerState<FoundationTypeScreen> createState() => _FoundationTypeScreenState();
}

class _FoundationTypeScreenState extends ConsumerState<FoundationTypeScreen> {
  FoundationType? _selectedType;

  final Map<FoundationType, Map<String, dynamic>> _foundationOptions = {
    FoundationType.shallowSpreadFooting: {
      'label': 'Shallow Spread Footing',
      'icon': Icons.square_foot_rounded,
      'description': 'Individual footings under columns',
      'color': AppTheme.primary,
    },
    FoundationType.raftMat: {
      'label': 'Raft/Mat Foundation',
      'icon': Icons.view_quilt_rounded,
      'description': 'Large slab supporting entire building',
      'color': AppTheme.secondary,
    },
    FoundationType.pileFoundation: {
      'label': 'Pile Foundation',
      'icon': Icons.vertical_align_bottom_rounded,
      'description': 'Deep foundation with piles',
      'color': AppTheme.accent,
    },
    FoundationType.mixed: {
      'label': 'Mixed',
      'icon': Icons.apps_rounded,
      'description': 'Combination of foundation types',
      'color': AppTheme.warning,
    },
    FoundationType.unknown: {
      'label': 'Unknown',
      'icon': Icons.help_outline_rounded,
      'description': "I'm not sure",
      'color': AppTheme.textSecondary,
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
                'Foundation Type',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'What type of foundation does your building have?',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              const SizedBox(height: 32),
              ..._foundationOptions.entries.map((entry) {
                final type = entry.key;
                final data = entry.value;
                final isSelected = _selectedType == type;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedType = type;
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
              const SizedBox(height: 20),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedType = FoundationType.unknown;
                  });
                },
                icon: const Icon(Icons.help_outline_rounded),
                label: const Text('I need help identifying this'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveAndContinue() async {
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a foundation type')),
      );
      return;
    }

    try {
      await ref.read(buildingProvider.notifier).updateBuilding({
        'foundationType': _selectedType.toString().split('.').last,
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

