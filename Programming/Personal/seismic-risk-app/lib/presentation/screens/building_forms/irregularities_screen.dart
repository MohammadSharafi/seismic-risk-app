import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seismic_risk_app/core/theme/app_theme.dart';
import 'package:seismic_risk_app/presentation/providers/building_provider.dart';

class IrregularitiesScreen extends ConsumerStatefulWidget {
  final VoidCallback? onComplete;

  const IrregularitiesScreen({super.key, this.onComplete});

  @override
  ConsumerState<IrregularitiesScreen> createState() => _IrregularitiesScreenState();
}

class _IrregularitiesScreenState extends ConsumerState<IrregularitiesScreen> {
  bool _planIrregularity = false;
  bool _elevationIrregularity = false;
  bool _torsion = false;

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
                'Does your building have any of these structural irregularities?',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
              ),
              const SizedBox(height: 32),
              _buildIrregularityCard(
                title: 'Plan Irregularity',
                description:
                    'The building shape is irregular when viewed from above (L-shaped, U-shaped, or other non-rectangular forms)',
                icon: Icons.grid_view_rounded,
                color: AppTheme.primary,
                value: _planIrregularity,
                onChanged: (value) {
                  setState(() {
                    _planIrregularity = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildIrregularityCard(
                title: 'Elevation Irregularity',
                description:
                    'The building height varies significantly between floors (e.g., soft story, setback, or major height change)',
                icon: Icons.height_rounded,
                color: AppTheme.secondary,
                value: _elevationIrregularity,
                onChanged: (value) {
                  setState(() {
                    _elevationIrregularity = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildIrregularityCard(
                title: 'Torsion',
                description:
                    'The building appears to twist or has an asymmetrical layout that could cause rotation during shaking',
                icon: Icons.rotate_right_rounded,
                color: AppTheme.accent,
                value: _torsion,
                onChanged: (value) {
                  setState(() {
                    _torsion = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.accent, AppTheme.accent],
                  ),
                  color: AppTheme.accent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'If none of these apply, your building is considered regular',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIrregularityCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: value ? color.withOpacity(0.1) : AppTheme.surface,
        border: Border.all(
          color: value ? color : AppTheme.border,
          width: value ? 2.5 : 2,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: value
            ? [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: CheckboxListTile(
        value: value,
        onChanged: (newValue) => onChanged(newValue ?? false),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: value ? color : color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: value ? Colors.white : color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(left: 50, top: 8),
          child: Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ),
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: color,
        checkColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Future<void> _saveAndContinue() async {
    try {
      await ref.read(buildingProvider.notifier).updateBuilding({
        'irregularities': {
          'planIrregularity': _planIrregularity,
          'elevationIrregularity': _elevationIrregularity,
          'torsion': _torsion,
        },
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

