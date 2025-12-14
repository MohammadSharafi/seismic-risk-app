import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seismic_risk_app/core/theme/app_theme.dart';
import 'package:seismic_risk_app/presentation/providers/building_provider.dart';
import 'package:seismic_risk_app/presentation/widgets/responsive/app_button.dart';
import 'package:seismic_risk_app/presentation/widgets/responsive/app_card.dart';
import 'package:seismic_risk_app/presentation/widgets/responsive/responsive_layout.dart';

class SoftStoreyScreen extends ConsumerStatefulWidget {
  final VoidCallback? onComplete;
  const SoftStoreyScreen({super.key, this.onComplete});

  @override
  ConsumerState<SoftStoreyScreen> createState() => _SoftStoreyScreenState();
}

class _SoftStoreyScreenState extends ConsumerState<SoftStoreyScreen> {
  bool? _hasSoftStorey;

  @override
  void initState() {
    super.initState();
    final building = ref.read(buildingProvider);
    _hasSoftStorey = building?.presenceOfSoftStorey;
  }

  void _saveAndContinue() {
    if (_hasSoftStorey != null) {
      ref.read(buildingProvider.notifier).updateBuilding({
        'presenceOfSoftStorey': _hasSoftStorey,
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
                'Does your building have a soft storey?',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
              ),
              const SizedBox(height: 16),
              AppCard(
                padding: EdgeInsets.all(isMobile ? 20 : 24),
                backgroundColor: AppTheme.warning.withOpacity(0.1),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppTheme.warning, size: 28),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'A soft storey is a floor with significantly less stiffness or resistance to lateral forces compared to other floors, often due to open spaces like parking areas or large windows.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.warning,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              AppCard(
                padding: EdgeInsets.all(isMobile ? 20 : 24),
                child: Column(
                  children: [
                    _buildOption(
                      context,
                      value: false,
                      label: 'No soft storey',
                      description: 'All floors have similar stiffness',
                      icon: Icons.check_circle_outline_rounded,
                      color: AppTheme.success,
                    ),
                    const SizedBox(height: 16),
                    _buildOption(
                      context,
                      value: true,
                      label: 'Yes, has soft storey',
                      description: 'One or more floors are significantly weaker',
                      icon: Icons.warning_rounded,
                      color: AppTheme.error,
                    ),
                  ],
                ),
              ),
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
              onPressed: _hasSoftStorey != null ? _saveAndContinue : null,
              variant: AppButtonVariant.primary,
              fullWidth: true,
              size: AppButtonSize.large,
            ),
          ),
        ),
      ) : null,
    );
  }

  Widget _buildOption(BuildContext context, {
    required bool value,
    required String label,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _hasSoftStorey == value;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _hasSoftStorey = value;
          });
          // Auto-save when selection is made
          ref.read(buildingProvider.notifier).updateBuilding({
            'presenceOfSoftStorey': value,
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? color : AppTheme.grey300,
              width: isSelected ? 2 : 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
            color: isSelected ? color.withOpacity(0.1) : AppTheme.surface,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? color : AppTheme.grey200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? AppTheme.textLight : AppTheme.textSecondary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected ? color : AppTheme.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle_rounded, color: color, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

