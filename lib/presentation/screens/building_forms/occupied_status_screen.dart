import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seismic_risk_app/core/theme/app_theme.dart';
import 'package:seismic_risk_app/presentation/providers/building_provider.dart';
import 'package:seismic_risk_app/presentation/widgets/responsive/app_button.dart';
import 'package:seismic_risk_app/presentation/widgets/responsive/app_card.dart';
import 'package:seismic_risk_app/presentation/widgets/responsive/responsive_layout.dart';

class OccupiedStatusScreen extends ConsumerStatefulWidget {
  final VoidCallback? onComplete;
  const OccupiedStatusScreen({super.key, this.onComplete});

  @override
  ConsumerState<OccupiedStatusScreen> createState() => _OccupiedStatusScreenState();
}

class _OccupiedStatusScreenState extends ConsumerState<OccupiedStatusScreen> {
  bool? _isOccupied;
  int? _householdCount;

  @override
  void initState() {
    super.initState();
    final building = ref.read(buildingProvider);
    _isOccupied = building?.occupied;
    _householdCount = building?.householdCount;
  }

  void _saveAndContinue() {
    if (_isOccupied != null) {
      final updates = <String, dynamic>{
        'occupied': _isOccupied,
      };
      if (_isOccupied == true && _householdCount != null) {
        updates['householdCount'] = _householdCount;
      }
      ref.read(buildingProvider.notifier).updateBuilding(updates);
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
                'Is the building currently occupied?',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'This helps assess potential human impact.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
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
                      label: 'Yes, currently occupied',
                      icon: Icons.people_rounded,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(height: 16),
                    _buildOption(
                      context,
                      value: false,
                      label: 'No, unoccupied/vacant',
                      icon: Icons.home_outlined,
                      color: AppTheme.grey500,
                    ),
                    if (_isOccupied == true) ...[
                      const SizedBox(height: 24),
                      Text(
                        'How many households/families live in this building?',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Number of households',
                          hintText: 'e.g., 10',
                          prefixIcon: const Icon(Icons.family_restroom_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (value) {
                          final count = int.tryParse(value);
                          if (count != null && count > 0) {
                            setState(() {
                              _householdCount = count;
                            });
                            // Auto-save
                            ref.read(buildingProvider.notifier).updateBuilding({
                              'occupied': true,
                              'householdCount': count,
                            });
                          }
                        },
                      ),
                    ],
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
              onPressed: _isOccupied != null ? _saveAndContinue : null,
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
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _isOccupied == value;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _isOccupied = value;
            if (!value) {
              _householdCount = null;
            }
          });
          // Auto-save
          ref.read(buildingProvider.notifier).updateBuilding({
            'occupied': value,
            if (!value) 'householdCount': null,
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
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? color : AppTheme.textPrimary,
                      ),
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

