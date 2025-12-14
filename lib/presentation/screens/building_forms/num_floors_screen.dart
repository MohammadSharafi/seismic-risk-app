import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seismic_risk_app/core/constants/app_constants.dart';
import 'package:seismic_risk_app/core/theme/app_theme.dart';
import 'package:seismic_risk_app/presentation/providers/building_provider.dart';

class NumFloorsScreen extends ConsumerStatefulWidget {
  final VoidCallback? onComplete;
  
  const NumFloorsScreen({super.key, this.onComplete});

  @override
  ConsumerState<NumFloorsScreen> createState() => _NumFloorsScreenState();
}

class _NumFloorsScreenState extends ConsumerState<NumFloorsScreen> {
  final TextEditingController _controller = TextEditingController();
  int? _selectedFloors;

  @override
  void initState() {
    super.initState();
    _loadDefaults();
  }

  Future<void> _loadDefaults() async {
    try {
      final defaults = await ref.read(buildingProvider.notifier).getNeighborhoodDefaults();
      if (defaults.typicalNumFloorsMean != null && mounted) {
        final suggested = defaults.typicalNumFloorsMean!.round();
        setState(() {
          _selectedFloors = suggested;
          _controller.text = suggested.toString();
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _saveAndContinue() async {
    if (_selectedFloors == null ||
        _selectedFloors! < AppConstants.minFloors ||
        _selectedFloors! > AppConstants.maxFloors) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a number between ${AppConstants.minFloors} and ${AppConstants.maxFloors}',
          ),
        ),
      );
      return;
    }

    try {
      await ref.read(buildingProvider.notifier).updateBuilding({
        'numFloors': _selectedFloors,
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
                        Icons.layers_rounded,
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
                            'How many floors?',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Include all floors above ground level',
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
              // Input field
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: 'Number of Floors',
                  hintText: 'e.g., 5',
                  prefixIcon: const Icon(Icons.layers_rounded),
                  suffixIcon: _selectedFloors != null
                      ? Icon(
                          Icons.check_circle_rounded,
                          color: AppTheme.success,
                        )
                      : null,
                  helperText: 'Between ${AppConstants.minFloors} and ${AppConstants.maxFloors} floors',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final floors = int.tryParse(value);
                  if (floors != null &&
                      floors >= AppConstants.minFloors &&
                      floors <= AppConstants.maxFloors) {
                    setState(() {
                      _selectedFloors = floors;
                    });
                  } else {
                    setState(() {
                      _selectedFloors = null;
                    });
                  }
                },
              ),
              const SizedBox(height: 32),
              Text(
                'Quick select:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 15, 20]
                    .map((num) => _buildQuickButton(num))
                    .toList(),
              ),
              // Only show Continue button if NOT in wizard (wizard has its own navigation)
              if (widget.onComplete == null) ...[
                const SizedBox(height: 32),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: _selectedFloors != null
                        ? LinearGradient(
                            colors: [
                              AppTheme.primary,
                              AppTheme.primaryDark,
                            ],
                          )
                        : null,
                    boxShadow: _selectedFloors != null
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
                    onPressed: _selectedFloors != null ? _saveAndContinue : null,
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

  Widget _buildQuickButton(int floors) {
    final isSelected = _selectedFloors == floors;
    return FilterChip(
      label: Text(
        '$floors',
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 15,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFloors = floors;
          _controller.text = floors.toString();
        });
      },
      selectedColor: AppTheme.primary.withOpacity(0.2),
      checkmarkColor: AppTheme.primary,
      side: BorderSide(
        color: isSelected ? AppTheme.primary : Colors.grey.shade300,
        width: isSelected ? 2 : 1,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      avatar: isSelected
          ? Icon(Icons.layers_rounded, size: 18, color: AppTheme.primary)
          : null,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

