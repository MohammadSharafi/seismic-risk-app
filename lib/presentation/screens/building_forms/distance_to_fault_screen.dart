import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seismic_risk_app/core/theme/app_theme.dart';
import 'package:seismic_risk_app/presentation/providers/building_provider.dart';
import 'package:seismic_risk_app/presentation/widgets/responsive/app_button.dart';
import 'package:seismic_risk_app/presentation/widgets/responsive/app_card.dart';
import 'package:seismic_risk_app/presentation/widgets/responsive/responsive_layout.dart';

class DistanceToFaultScreen extends ConsumerStatefulWidget {
  final VoidCallback? onComplete;
  const DistanceToFaultScreen({super.key, this.onComplete});

  @override
  ConsumerState<DistanceToFaultScreen> createState() => _DistanceToFaultScreenState();
}

class _DistanceToFaultScreenState extends ConsumerState<DistanceToFaultScreen> {
  double? _distanceKm;
  final TextEditingController _distanceController = TextEditingController();
  bool _dontKnow = false;

  @override
  void initState() {
    super.initState();
    final building = ref.read(buildingProvider);
    _distanceKm = building?.distanceToFaultKm;
    if (_distanceKm != null) {
      _distanceController.text = _distanceKm!.toStringAsFixed(1);
    }
  }

  @override
  void dispose() {
    _distanceController.dispose();
    super.dispose();
  }

  void _saveAndContinue() {
    if (!_dontKnow && _distanceKm != null) {
      ref.read(buildingProvider.notifier).updateBuilding({
        'distanceToFaultKm': _distanceKm,
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
                'How far is your building from the nearest earthquake fault?',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Buildings closer to faults experience stronger shaking.',
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
                        _buildQuickOption('< 5 km', 2.5, AppTheme.error),
                        _buildQuickOption('5-10 km', 7.5, AppTheme.warning),
                        _buildQuickOption('10-20 km', 15, AppTheme.warning),
                        _buildQuickOption('20-50 km', 35, AppTheme.success),
                        _buildQuickOption('> 50 km', 75, AppTheme.success),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _distanceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Enter exact distance (km)',
                        hintText: 'e.g., 12.5',
                        prefixIcon: const Icon(Icons.straighten_rounded),
                        suffixText: 'km',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        helperText: 'Distance from nearest active fault line',
                      ),
                      onChanged: (value) {
                        final distance = double.tryParse(value);
                        if (distance != null && distance >= 0) {
                          setState(() {
                            _distanceKm = distance;
                            _dontKnow = false;
                          });
                          // Auto-save
                          ref.read(buildingProvider.notifier).updateBuilding({
                            'distanceToFaultKm': distance,
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
                            _distanceController.clear();
                            _distanceKm = null;
                          }
                        });
                      },
                      title: const Text('I don\'t know the distance'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              if (_distanceKm != null && !_dontKnow)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: AppCard(
                    padding: const EdgeInsets.all(20),
                    backgroundColor: _getDistanceColor().withOpacity(0.1),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: _getDistanceColor()),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _getDistanceRiskMessage(),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: _getDistanceColor(),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
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

  Widget _buildQuickOption(String label, double distance, Color color) {
    final isSelected = _distanceKm != null && 
        (_distanceKm! >= distance - 5 && _distanceKm! <= distance + 5);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _distanceKm = distance;
            _distanceController.text = distance.toStringAsFixed(1);
            _dontKnow = false;
          });
          // Auto-save
          ref.read(buildingProvider.notifier).updateBuilding({
            'distanceToFaultKm': distance,
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? color : AppTheme.grey300,
              width: isSelected ? 2 : 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
            color: isSelected ? color.withOpacity(0.1) : AppTheme.surface,
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSelected ? color : AppTheme.textPrimary,
                ),
          ),
        ),
      ),
    );
  }

  Color _getDistanceColor() {
    if (_distanceKm == null) return AppTheme.grey500;
    if (_distanceKm! < 5) return AppTheme.error;
    if (_distanceKm! < 10) return AppTheme.warning;
    if (_distanceKm! < 20) return AppTheme.warning;
    return AppTheme.success;
  }

  String _getDistanceRiskMessage() {
    if (_distanceKm == null) return '';
    if (_distanceKm! < 5) return 'Very close to fault - high risk of strong shaking';
    if (_distanceKm! < 10) return 'Close to fault - moderate to high risk';
    if (_distanceKm! < 20) return 'Moderate distance - some risk';
    return 'Far from fault - lower risk';
  }
}

