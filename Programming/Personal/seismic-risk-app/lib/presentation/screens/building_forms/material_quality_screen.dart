import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seismic_risk_app/core/theme/app_theme.dart';
import 'package:seismic_risk_app/domain/entities/building.dart';
import 'package:seismic_risk_app/presentation/providers/building_provider.dart';

class MaterialQualityScreen extends ConsumerStatefulWidget {
  final VoidCallback? onComplete;

  const MaterialQualityScreen({super.key, this.onComplete});

  @override
  ConsumerState<MaterialQualityScreen> createState() => _MaterialQualityScreenState();
}

class _MaterialQualityScreenState extends ConsumerState<MaterialQualityScreen> {
  MaterialQualityIndicator? _selectedQuality;

  final Map<MaterialQualityIndicator, Map<String, dynamic>> _qualityOptions = {
    MaterialQualityIndicator.good: {
      'label': 'Good',
      'description': 'Well-maintained, no visible damage',
      'icon': Icons.thumb_up_rounded,
      'color': AppTheme.success,
    },
    MaterialQualityIndicator.average: {
      'label': 'Average',
      'description': 'Some wear, minor issues visible',
      'icon': Icons.thumb_up_outlined,
      'color': AppTheme.warning,
    },
    MaterialQualityIndicator.poor: {
      'label': 'Poor',
      'description': 'Visible damage, cracks, deterioration',
      'icon': Icons.thumb_down_rounded,
      'color': AppTheme.error,
    },
    MaterialQualityIndicator.unknown: {
      'label': 'Unknown',
      'description': "I'm not sure about the condition",
      'icon': Icons.help_outline_rounded,
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
                'How would you rate the overall condition of your building?',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      color: AppTheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Consider visible cracks, material deterioration, and overall maintenance.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              ..._qualityOptions.entries.map((entry) {
                final quality = entry.key;
                final data = entry.value;
                final isSelected = _selectedQuality == quality;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedQuality = quality;
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
    if (_selectedQuality == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a building condition')),
      );
      return;
    }

    try {
      await ref.read(buildingProvider.notifier).updateBuilding({
        'materialQualityIndicator': _selectedQuality.toString().split('.').last,
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

