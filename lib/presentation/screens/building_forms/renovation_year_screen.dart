import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seismic_risk_app/core/theme/app_theme.dart';
import 'package:seismic_risk_app/presentation/providers/building_provider.dart';
import 'package:seismic_risk_app/presentation/widgets/responsive/app_button.dart';
import 'package:seismic_risk_app/presentation/widgets/responsive/app_card.dart';
import 'package:seismic_risk_app/presentation/widgets/responsive/responsive_layout.dart';

class RenovationYearScreen extends ConsumerStatefulWidget {
  final VoidCallback? onComplete;
  const RenovationYearScreen({super.key, this.onComplete});

  @override
  ConsumerState<RenovationYearScreen> createState() => _RenovationYearScreenState();
}

class _RenovationYearScreenState extends ConsumerState<RenovationYearScreen> {
  int? _selectedYear;
  final TextEditingController _yearController = TextEditingController();
  bool _hasRenovation = false;

  @override
  void initState() {
    super.initState();
    final building = ref.read(buildingProvider);
    _selectedYear = building?.yearOfMajorRenovation;
    _hasRenovation = _selectedYear != null;
    if (_selectedYear != null) {
      _yearController.text = _selectedYear.toString();
    }
  }

  @override
  void dispose() {
    _yearController.dispose();
    super.dispose();
  }

  void _saveAndContinue() {
    ref.read(buildingProvider.notifier).updateBuilding({
      'yearOfMajorRenovation': _hasRenovation ? _selectedYear : null,
    });
    widget.onComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final padding = ResponsiveLayout.getPadding(context);
    final currentYear = DateTime.now().year;
    final building = ref.read(buildingProvider);
    final yearBuilt = building?.yearBuilt ?? 1900;
    final minYear = yearBuilt;
    final maxYear = currentYear;

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
                'Has your building undergone major structural renovation?',
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
                    // No renovation option
                    _buildOption(
                      context,
                      value: false,
                      label: 'No major renovation',
                      icon: Icons.close_rounded,
                    ),
                    const SizedBox(height: 16),
                    _buildOption(
                      context,
                      value: true,
                      label: 'Yes, has been renovated',
                      icon: Icons.build_rounded,
                    ),
                    if (_hasRenovation) ...[
                      const SizedBox(height: 24),
                      Text(
                        'When was the major renovation completed?',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _yearController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Year of renovation',
                          hintText: 'e.g., 2010',
                          prefixIcon: const Icon(Icons.calendar_today_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          helperText: 'Between $minYear and $maxYear',
                        ),
                        onChanged: (value) {
                          final year = int.tryParse(value);
                          if (year != null && year >= minYear && year <= maxYear) {
                            setState(() {
                              _selectedYear = year;
                            });
                            // Auto-save when valid year is entered
                            if (_hasRenovation) {
                              ref.read(buildingProvider.notifier).updateBuilding({
                                'yearOfMajorRenovation': year,
                              });
                            }
                          } else {
                            setState(() {
                              _selectedYear = null;
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
              onPressed: (!_hasRenovation || _selectedYear != null) ? _saveAndContinue : null,
              variant: AppButtonVariant.primary,
              fullWidth: true,
              size: AppButtonSize.large,
            ),
          ),
        ),
      ) : null,
    );
  }

  Widget _buildOption(BuildContext context, {required bool value, required String label, required IconData icon}) {
    final isSelected = _hasRenovation == value;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _hasRenovation = value;
            if (!value) {
              _selectedYear = null;
              _yearController.clear();
            }
          });
          // Auto-save when selection is made
          ref.read(buildingProvider.notifier).updateBuilding({
            'yearOfMajorRenovation': value ? _selectedYear : null,
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
}

