import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seismic_risk_app/core/theme/app_theme.dart';
import 'package:seismic_risk_app/presentation/providers/building_provider.dart';
import 'package:seismic_risk_app/presentation/widgets/responsive/app_button.dart';
import 'package:seismic_risk_app/presentation/widgets/responsive/app_card.dart';
import 'package:seismic_risk_app/presentation/widgets/responsive/responsive_layout.dart';

class ColumnSpacingScreen extends ConsumerStatefulWidget {
  final VoidCallback? onComplete;
  const ColumnSpacingScreen({super.key, this.onComplete});

  @override
  ConsumerState<ColumnSpacingScreen> createState() => _ColumnSpacingScreenState();
}

class _ColumnSpacingScreenState extends ConsumerState<ColumnSpacingScreen> {
  double? _spacingM;
  final TextEditingController _spacingController = TextEditingController();
  bool _dontKnow = false;

  @override
  void initState() {
    super.initState();
    final building = ref.read(buildingProvider);
    _spacingM = building?.typicalColumnSpacingM;
    if (_spacingM != null) {
      _spacingController.text = _spacingM!.toStringAsFixed(1);
    }
  }

  @override
  void dispose() {
    _spacingController.dispose();
    super.dispose();
  }

  void _saveAndContinue() {
    if (!_dontKnow && _spacingM != null) {
      ref.read(buildingProvider.notifier).updateBuilding({
        'typicalColumnSpacingM': _spacingM,
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
                'What is the typical distance between columns?',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Closer spacing provides better structural stability.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              const SizedBox(height: 32),
              AppCard(
                padding: EdgeInsets.all(isMobile ? 20 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick select options
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _buildQuickOption('3-4 m', 3.5),
                        _buildQuickOption('4-5 m', 4.5),
                        _buildQuickOption('5-6 m', 5.5),
                        _buildQuickOption('6-8 m', 7.0),
                        _buildQuickOption('> 8 m', 9.0),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _spacingController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Enter spacing (meters)',
                        hintText: 'e.g., 5.5',
                        prefixIcon: const Icon(Icons.straighten_rounded),
                        suffixText: 'meters',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        helperText: 'Average distance between structural columns',
                      ),
                      onChanged: (value) {
                        final spacing = double.tryParse(value);
                        if (spacing != null && spacing > 0) {
                          setState(() {
                            _spacingM = spacing;
                            _dontKnow = false;
                          });
                          // Auto-save
                          ref.read(buildingProvider.notifier).updateBuilding({
                            'typicalColumnSpacingM': spacing,
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      value: _dontKnow,
                      onChanged: (value) {
                        setState(() {
                          _dontKnow = value ?? false;
                          if (_dontKnow) {
                            _spacingController.clear();
                            _spacingM = null;
                          }
                        });
                      },
                      title: const Text('I don\'t know the spacing'),
                      contentPadding: EdgeInsets.zero,
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

  Widget _buildQuickOption(String label, double spacing) {
    final isSelected = _spacingM != null && 
        (_spacingM! >= spacing - 1 && _spacingM! <= spacing + 1);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _spacingM = spacing;
            _spacingController.text = spacing.toStringAsFixed(1);
            _dontKnow = false;
          });
          // Auto-save
          ref.read(buildingProvider.notifier).updateBuilding({
            'typicalColumnSpacingM': spacing,
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? AppTheme.primary : AppTheme.grey300,
              width: isSelected ? 2 : 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
            color: isSelected ? AppTheme.primary.withOpacity(0.1) : AppTheme.surface,
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
                ),
          ),
        ),
      ),
    );
  }
}

