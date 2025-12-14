import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seismic_risk_app/core/theme/app_theme.dart';
import 'package:seismic_risk_app/presentation/providers/building_provider.dart';

class FloorAreaScreen extends ConsumerStatefulWidget {
  final VoidCallback? onComplete;

  const FloorAreaScreen({super.key, this.onComplete});

  @override
  ConsumerState<FloorAreaScreen> createState() => _FloorAreaScreenState();
}

class _FloorAreaScreenState extends ConsumerState<FloorAreaScreen> {
  final TextEditingController _areaController = TextEditingController();
  bool _isSkipped = false;

  @override
  void dispose() {
    _areaController.dispose();
    super.dispose();
  }

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
                'What is the total floor area of your building?',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: AppTheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Enter the total floor area in square meters (m²). You can find this on your building documents or estimate based on floor dimensions.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _areaController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  labelText: 'Floor Area (m²)',
                  hintText: 'e.g., 150.5',
                  prefixIcon: const Icon(Icons.square_foot_rounded),
                  suffixText: 'm²',
                  suffixStyle: TextStyle(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primary, AppTheme.primaryLight],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildQuickOption('50', 'Small apartment'),
                    _buildDivider(),
                    _buildQuickOption('150', 'Medium house'),
                    _buildDivider(),
                    _buildQuickOption('300', 'Large house'),
                    _buildDivider(),
                    _buildQuickOption('500', 'Commercial building'),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _isSkipped = true;
                    });
                    _saveAndContinue();
                  },
                  child: const Text('Skip for now'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickOption(String value, String label) {
    return InkWell(
      onTap: () {
        _areaController.text = value;
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Row(
          children: [
            Text(
              '$value m²',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.white.withOpacity(0.2),
    );
  }

  Future<void> _saveAndContinue() async {
    try {
      final area = _isSkipped
          ? null
          : (double.tryParse(_areaController.text) ?? null);

      await ref.read(buildingProvider.notifier).updateBuilding({
        if (area != null) 'floorAreaM2': area,
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

