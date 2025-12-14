import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seismic_risk_app/core/theme/app_theme.dart';
import 'package:seismic_risk_app/domain/entities/building.dart';
import 'package:seismic_risk_app/presentation/providers/building_provider.dart';

class StructureTypeScreen extends ConsumerStatefulWidget {
  final VoidCallback? onComplete;
  
  const StructureTypeScreen({super.key, this.onComplete});

  @override
  ConsumerState<StructureTypeScreen> createState() => _StructureTypeScreenState();
}

class _StructureTypeScreenState extends ConsumerState<StructureTypeScreen> {
  PrimaryStructureType? _selectedType;

  @override
  void initState() {
    super.initState();
    _loadDefaults();
  }

  Future<void> _loadDefaults() async {
    try {
      await ref.read(buildingProvider.notifier).getNeighborhoodDefaults();
      // Use defaults if available
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _saveAndContinue() async {
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a structure type')),
      );
      return;
    }

    try {
      await ref.read(buildingProvider.notifier).updateBuilding({
        'primaryStructureType': _selectedType!.name,
      });

      if (mounted) {
        if (widget.onComplete != null) {
          widget.onComplete!();
        } else {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primary.withOpacity(0.1),
                      AppTheme.primaryLight.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.primary.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.architecture_rounded,
                        color: AppTheme.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Primary Structural System',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'The main load-bearing system of your building',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Structure type options
              _buildOption(
                PrimaryStructureType.rcFrame,
                'Reinforced Concrete Frame',
                'Most common in modern buildings. Columns and beams made of reinforced concrete.',
                Icons.business_rounded,
              ),
              const SizedBox(height: 12),
              _buildOption(
                PrimaryStructureType.rcShearWall,
                'RC Shear Wall',
                'Reinforced concrete walls that resist lateral forces.',
                Icons.apartment_rounded,
              ),
              const SizedBox(height: 12),
              _buildOption(
                PrimaryStructureType.masonryUnreinforced,
                'Unreinforced Masonry',
                'Brick or stone walls without steel reinforcement. Higher risk.',
                Icons.warning_rounded,
                isHighRisk: true,
              ),
              const SizedBox(height: 12),
              _buildOption(
                PrimaryStructureType.masonryReinforced,
                'Reinforced Masonry',
                'Masonry walls with steel reinforcement.',
                Icons.apartment_rounded,
              ),
              const SizedBox(height: 12),
              _buildOption(
                PrimaryStructureType.steelFrame,
                'Steel Frame',
                'Structural steel columns and beams.',
                Icons.build_rounded,
              ),
              const SizedBox(height: 12),
              _buildOption(
                PrimaryStructureType.timber,
                'Timber',
                'Wood frame construction.',
                Icons.forest_rounded,
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedType = PrimaryStructureType.unknown;
                  });
                },
                icon: const Icon(Icons.help_outline_rounded),
                label: const Text('I don\'t know'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              // Only show Continue button if NOT in wizard (wizard has its own navigation)
              if (widget.onComplete == null) ...[
                const SizedBox(height: 32),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: _selectedType != null
                        ? LinearGradient(
                            colors: [
                              AppTheme.primary,
                              AppTheme.primaryDark,
                            ],
                          )
                        : null,
                    boxShadow: _selectedType != null
                        ? [
                            BoxShadow(
                              color: AppTheme.primary.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : null,
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _selectedType != null ? _saveAndContinue : null,
                    icon: const Icon(Icons.check_circle_rounded, size: 22),
                    label: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption(
    PrimaryStructureType type,
    String title,
    String description,
    IconData icon, {
    bool isHighRisk = false,
  }) {
    final isSelected = _selectedType == type;
    return Card(
      elevation: isSelected ? 4 : 2,
      shadowColor: isSelected
          ? AppTheme.primary.withOpacity(0.2)
          : Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: isSelected
              ? AppTheme.primary
              : isHighRisk
                  ? AppTheme.error.withOpacity(0.3)
                  : Colors.transparent,
          width: isSelected || isHighRisk ? 2 : 0,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedType = type;
          });
        },
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isHighRisk
                      ? AppTheme.error.withOpacity(0.1)
                      : isSelected
                          ? AppTheme.primary.withOpacity(0.1)
                          : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isHighRisk
                      ? AppTheme.error
                      : isSelected
                          ? AppTheme.primary
                          : Colors.grey.shade600,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? AppTheme.primary
                                      : null,
                                ),
                          ),
                        ),
                        if (isHighRisk) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.warning_rounded,
                                  color: AppTheme.error,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'High Risk',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                            height: 1.4,
                          ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

