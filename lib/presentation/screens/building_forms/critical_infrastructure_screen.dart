import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seismic_risk_app/core/theme/app_theme.dart';
import 'package:seismic_risk_app/presentation/providers/building_provider.dart';
import 'package:seismic_risk_app/presentation/widgets/responsive/app_button.dart';
import 'package:seismic_risk_app/presentation/widgets/responsive/app_card.dart';
import 'package:seismic_risk_app/presentation/widgets/responsive/responsive_layout.dart';

class CriticalInfrastructureScreen extends ConsumerStatefulWidget {
  final VoidCallback? onComplete;
  const CriticalInfrastructureScreen({super.key, this.onComplete});

  @override
  ConsumerState<CriticalInfrastructureScreen> createState() => _CriticalInfrastructureScreenState();
}

class _CriticalInfrastructureScreenState extends ConsumerState<CriticalInfrastructureScreen> {
  bool? _isCritical;

  @override
  void initState() {
    super.initState();
    final building = ref.read(buildingProvider);
    _isCritical = building?.criticalInfrastructure;
  }

  void _saveAndContinue() {
    if (_isCritical != null) {
      ref.read(buildingProvider.notifier).updateBuilding({
        'criticalInfrastructure': _isCritical,
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
                'Is this building considered critical infrastructure?',
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
                        'Critical infrastructure includes hospitals, schools, emergency services, power plants, water treatment facilities, etc.',
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
                      value: true,
                      label: 'Yes, critical infrastructure',
                      description: 'Hospital, school, emergency services, etc.',
                      icon: Icons.local_hospital_rounded,
                      color: AppTheme.error,
                    ),
                    const SizedBox(height: 16),
                    _buildOption(
                      context,
                      value: false,
                      label: 'No, regular building',
                      description: 'Residential, commercial, or other regular use',
                      icon: Icons.home_rounded,
                      color: AppTheme.primary,
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
              onPressed: _isCritical != null ? _saveAndContinue : null,
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
    final isSelected = _isCritical == value;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _isCritical = value;
          });
          // Auto-save
          ref.read(buildingProvider.notifier).updateBuilding({
            'criticalInfrastructure': value,
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

