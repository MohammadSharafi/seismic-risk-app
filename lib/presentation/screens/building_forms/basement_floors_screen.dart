import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seismic_risk_app/core/theme/app_theme.dart';
import 'package:seismic_risk_app/presentation/providers/building_provider.dart';
import 'package:seismic_risk_app/presentation/widgets/responsive/app_button.dart';
import 'package:seismic_risk_app/presentation/widgets/responsive/app_card.dart';
import 'package:seismic_risk_app/presentation/widgets/responsive/responsive_layout.dart';

class BasementFloorsScreen extends ConsumerStatefulWidget {
  final VoidCallback? onComplete;
  const BasementFloorsScreen({super.key, this.onComplete});

  @override
  ConsumerState<BasementFloorsScreen> createState() => _BasementFloorsScreenState();
}

class _BasementFloorsScreenState extends ConsumerState<BasementFloorsScreen> {
  int? _selectedBasementFloors;

  @override
  void initState() {
    super.initState();
    final building = ref.read(buildingProvider);
    _selectedBasementFloors = building?.numBasementFloors;
  }

  void _saveAndContinue() {
    if (_selectedBasementFloors != null) {
      ref.read(buildingProvider.notifier).updateBuilding({
        'numBasementFloors': _selectedBasementFloors,
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
                'How many basement floors does your building have?',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
              ),
              const SizedBox(height: 32),
              AppCard(
                padding: EdgeInsets.all(isMobile ? 20 : 24),
                child: Column(
                  children: [
                    // Option: No basement
                    _buildOption(
                      context,
                      value: 0,
                      label: 'No basement',
                      icon: Icons.terrain_rounded,
                    ),
                    const SizedBox(height: 12),
                    // Quick select buttons for common values
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [1, 2, 3, 4, 5, 6].map((count) {
                        return _buildQuickSelectButton(context, count);
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    // Custom input
                    TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Custom number (7 or more)',
                        hintText: 'Enter number',
                        prefixIcon: const Icon(Icons.edit_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) {
                        final num = int.tryParse(value);
                        if (num != null && num >= 7) {
                          setState(() {
                            _selectedBasementFloors = num;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              if (_selectedBasementFloors != null)
                AppCard(
                  padding: const EdgeInsets.all(20),
                  backgroundColor: AppTheme.primary.withOpacity(0.1),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: AppTheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Selected: $_selectedBasementFloors ${_selectedBasementFloors == 1 ? 'floor' : 'floors'}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.primary,
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
      // Only show bottom navigation if not used in wizard (onComplete is provided)
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
              onPressed: _saveAndContinue,
              variant: AppButtonVariant.primary,
              fullWidth: true,
              size: AppButtonSize.large,
            ),
          ),
        ),
      ) : null,
    );
  }

  Widget _buildOption(BuildContext context, {required int value, required String label, required IconData icon}) {
    final isSelected = _selectedBasementFloors == value;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedBasementFloors = value;
          });
          // Auto-save when selection is made
          ref.read(buildingProvider.notifier).updateBuilding({
            'numBasementFloors': value,
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? AppTheme.primary : AppTheme.grey300,
              width: isSelected ? 2 : 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
            color: isSelected ? AppTheme.primary.withOpacity(0.1) : AppTheme.surface,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primary : AppTheme.grey200,
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
                        color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
                      ),
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle_rounded, color: AppTheme.primary, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickSelectButton(BuildContext context, int count) {
    final isSelected = _selectedBasementFloors == count;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedBasementFloors = count;
          });
          // Auto-save when selection is made
          ref.read(buildingProvider.notifier).updateBuilding({
            'numBasementFloors': count,
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? AppTheme.primary : AppTheme.grey300,
              width: isSelected ? 2 : 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
            color: isSelected ? AppTheme.primary.withOpacity(0.1) : AppTheme.surface,
          ),
          child: Text(
            '$count',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
                ),
          ),
        ),
      ),
    );
  }
}

