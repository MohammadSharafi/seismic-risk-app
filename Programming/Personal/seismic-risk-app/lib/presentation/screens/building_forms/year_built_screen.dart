import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seismic_risk_app/core/theme/app_theme.dart';
import 'package:seismic_risk_app/presentation/providers/building_provider.dart';

class YearBuiltScreen extends ConsumerStatefulWidget {
  final VoidCallback? onComplete;
  
  const YearBuiltScreen({super.key, this.onComplete});

  @override
  ConsumerState<YearBuiltScreen> createState() => _YearBuiltScreenState();
}

class _YearBuiltScreenState extends ConsumerState<YearBuiltScreen> {
  int? _selectedYear;
  final TextEditingController _yearController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNeighborhoodDefaults();
  }

  Future<void> _loadNeighborhoodDefaults() async {
    try {
      final defaults = await ref.read(buildingProvider.notifier).getNeighborhoodDefaults();
      if (defaults.defaultYearRange != null && mounted) {
        // Suggest middle of range
        final suggestedYear = (defaults.defaultYearRange!.start +
                defaults.defaultYearRange!.end) ~/
            2;
        setState(() {
          _selectedYear = suggestedYear;
          _yearController.text = suggestedYear.toString();
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _saveAndContinue() async {
    if (_selectedYear == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or enter a year')),
      );
      return;
    }

    try {
      await ref.read(buildingProvider.notifier).updateBuilding({
        'yearBuilt': _selectedYear,
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
                        Icons.calendar_today_rounded,
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
                            'When was this building constructed?',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Helps assess building code standards',
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
              // Year input field
              TextField(
                controller: _yearController,
                decoration: InputDecoration(
                  labelText: 'Year',
                  hintText: 'e.g., 1985',
                  prefixIcon: const Icon(Icons.calendar_today_rounded),
                  suffixIcon: _selectedYear != null
                      ? Icon(
                          Icons.check_circle_rounded,
                          color: AppTheme.success,
                        )
                      : null,
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final year = int.tryParse(value);
                  if (year != null && year > 1800 && year <= DateTime.now().year) {
                    setState(() {
                      _selectedYear = year;
                    });
                  } else {
                    setState(() {
                      _selectedYear = null;
                    });
                  }
                },
              ),
              const SizedBox(height: 32),
              Text(
                'Or select a range:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildYearRangeChip('Before 1970', 1960),
                  _buildYearRangeChip('1970-1999', 1985),
                  _buildYearRangeChip('2000-2010', 2005),
                  _buildYearRangeChip('After 2010', 2015),
                ],
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedYear = null;
                    _yearController.clear();
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
                    gradient: _selectedYear != null
                        ? LinearGradient(
                            colors: [
                              AppTheme.primary,
                              AppTheme.primaryDark,
                            ],
                          )
                        : null,
                    boxShadow: _selectedYear != null
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
                    onPressed: _selectedYear != null ? _saveAndContinue : null,
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

  Widget _buildYearRangeChip(String label, int year) {
    final isSelected = _selectedYear == year;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedYear = year;
          _yearController.text = year.toString();
        });
      },
      selectedColor: AppTheme.primary.withOpacity(0.2),
      checkmarkColor: AppTheme.primary,
      side: BorderSide(
        color: isSelected ? AppTheme.primary : Colors.grey.shade300,
        width: isSelected ? 2 : 1,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  @override
  void dispose() {
    _yearController.dispose();
    super.dispose();
  }
}

