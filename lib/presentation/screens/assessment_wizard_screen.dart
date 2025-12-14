import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seismic_risk_app/core/theme/app_theme.dart';
import 'package:seismic_risk_app/domain/entities/building.dart';
import 'package:seismic_risk_app/presentation/providers/building_provider.dart';
import 'package:seismic_risk_app/presentation/screens/location_screen.dart';
import 'package:seismic_risk_app/presentation/screens/address_confirmation_screen.dart';
import 'package:seismic_risk_app/presentation/screens/building_forms/year_built_screen.dart';
import 'package:seismic_risk_app/presentation/screens/building_forms/num_floors_screen.dart';
import 'package:seismic_risk_app/presentation/screens/building_forms/structure_type_screen.dart';
import 'package:seismic_risk_app/presentation/screens/building_forms/building_usage_screen.dart';
import 'package:seismic_risk_app/presentation/screens/building_forms/foundation_type_screen.dart';
import 'package:seismic_risk_app/presentation/screens/building_forms/floor_area_screen.dart';
import 'package:seismic_risk_app/presentation/screens/building_forms/material_quality_screen.dart';
import 'package:seismic_risk_app/presentation/screens/building_forms/irregularities_screen.dart';
import 'package:seismic_risk_app/presentation/screens/building_forms/basement_floors_screen.dart';
import 'package:seismic_risk_app/presentation/screens/building_forms/wall_material_screen.dart';
import 'package:seismic_risk_app/presentation/screens/building_forms/roof_type_screen.dart';
import 'package:seismic_risk_app/presentation/screens/building_forms/floor_system_screen.dart';
import 'package:seismic_risk_app/presentation/screens/building_forms/lateral_resistance_screen.dart';
import 'package:seismic_risk_app/presentation/screens/building_forms/connection_quality_screen.dart';
import 'package:seismic_risk_app/presentation/screens/building_forms/renovation_year_screen.dart';
import 'package:seismic_risk_app/presentation/screens/building_forms/soft_storey_screen.dart';
import 'package:seismic_risk_app/presentation/screens/building_forms/soil_type_screen.dart';
import 'package:seismic_risk_app/presentation/screens/building_forms/distance_to_fault_screen.dart';
import 'package:seismic_risk_app/presentation/screens/building_forms/column_spacing_screen.dart';
import 'package:seismic_risk_app/presentation/screens/building_forms/occupied_status_screen.dart';
import 'package:seismic_risk_app/presentation/screens/building_forms/critical_infrastructure_screen.dart';
import 'package:seismic_risk_app/presentation/screens/building_forms/photo_capture_screen.dart';
import 'package:seismic_risk_app/presentation/screens/results_screen.dart';
import 'package:seismic_risk_app/data/repositories/prediction_repository.dart';
import 'package:seismic_risk_app/domain/entities/recommendation.dart';
import 'package:seismic_risk_app/domain/entities/prediction.dart';
import 'package:seismic_risk_app/data/datasources/api_client.dart';

class AssessmentWizardScreen extends ConsumerStatefulWidget {
  const AssessmentWizardScreen({super.key});

  @override
  ConsumerState<AssessmentWizardScreen> createState() => _AssessmentWizardScreenState();
}

class _AssessmentWizardScreenState extends ConsumerState<AssessmentWizardScreen> {
  int _currentStepIndex = 0;
  final PageController _pageController = PageController();

  final List<WizardStep> _steps = [
    WizardStep(
      id: 'location',
      title: 'Location',
      description: 'Select your building location',
      icon: Icons.location_on_rounded,
      screenBuilder: (context, onNext, onBack) => _LocationStepWrapper(
        onComplete: onNext,
      ),
    ),
    WizardStep(
      id: 'address',
      title: 'Address',
      description: 'Confirm building address',
      icon: Icons.home_rounded,
      screenBuilder: (context, onNext, onBack) => _AddressStepWrapper(
        onComplete: onNext,
        onBack: onBack,
      ),
    ),
    WizardStep(
      id: 'year',
      title: 'Year Built',
      description: 'When was your building constructed?',
      icon: Icons.calendar_today_rounded,
      screenBuilder: (context, onNext, onBack) => _YearBuiltStepWrapper(
        onComplete: onNext,
        onBack: onBack,
      ),
    ),
    WizardStep(
      id: 'floors',
      title: 'Number of Floors',
      description: 'How many floors does your building have?',
      icon: Icons.layers_rounded,
      screenBuilder: (context, onNext, onBack) => _NumFloorsStepWrapper(
        onComplete: onNext,
        onBack: onBack,
      ),
    ),
    WizardStep(
      id: 'structure',
      title: 'Structure Type',
      description: 'What is the primary structural system?',
      icon: Icons.architecture_rounded,
      screenBuilder: (context, onNext, onBack) => _StructureTypeStepWrapper(
        onComplete: onNext,
        onBack: onBack,
      ),
    ),
    WizardStep(
      id: 'usage',
      title: 'Building Usage',
      description: 'What is the building used for?',
      icon: Icons.business_rounded,
      screenBuilder: (context, onNext, onBack) => _BuildingUsageStepWrapper(
        onComplete: onNext,
        onBack: onBack,
      ),
    ),
    WizardStep(
      id: 'foundation',
      title: 'Foundation',
      description: 'What type of foundation?',
      icon: Icons.square_foot_rounded,
      screenBuilder: (context, onNext, onBack) => _FoundationTypeStepWrapper(
        onComplete: onNext,
        onBack: onBack,
      ),
    ),
    WizardStep(
      id: 'area',
      title: 'Floor Area',
      description: 'What is the total floor area?',
      icon: Icons.square_foot_rounded,
      screenBuilder: (context, onNext, onBack) => _FloorAreaStepWrapper(
        onComplete: onNext,
        onBack: onBack,
      ),
      isOptional: true,
    ),
    WizardStep(
      id: 'condition',
      title: 'Building Condition',
      description: 'How is the building condition?',
      icon: Icons.build_rounded,
      screenBuilder: (context, onNext, onBack) => _MaterialQualityStepWrapper(
        onComplete: onNext,
        onBack: onBack,
      ),
    ),
    WizardStep(
      id: 'irregularities',
      title: 'Irregularities',
      description: 'Any structural irregularities?',
      icon: Icons.warning_rounded,
      screenBuilder: (context, onNext, onBack) => _IrregularitiesStepWrapper(
        onComplete: onNext,
        onBack: onBack,
      ),
    ),
    WizardStep(
      id: 'basement',
      title: 'Basement',
      description: 'How many basement floors?',
      icon: Icons.vertical_align_bottom_rounded,
      isOptional: true,
      screenBuilder: (context, onNext, onBack) => _BasementFloorsStepWrapper(
        onComplete: onNext,
        onBack: onBack,
      ),
    ),
    WizardStep(
      id: 'wall_material',
      title: 'Wall Material',
      description: 'What are the walls made of?',
      icon: Icons.wallpaper_rounded,
      screenBuilder: (context, onNext, onBack) => _WallMaterialStepWrapper(
        onComplete: onNext,
        onBack: onBack,
      ),
    ),
    WizardStep(
      id: 'roof_type',
      title: 'Roof Type',
      description: 'What type of roof?',
      icon: Icons.roofing_rounded,
      screenBuilder: (context, onNext, onBack) => _RoofTypeStepWrapper(
        onComplete: onNext,
        onBack: onBack,
      ),
    ),
    WizardStep(
      id: 'floor_system',
      title: 'Floor System',
      description: 'What floor system is used?',
      icon: Icons.layers_rounded,
      screenBuilder: (context, onNext, onBack) => _FloorSystemStepWrapper(
        onComplete: onNext,
        onBack: onBack,
      ),
    ),
    WizardStep(
      id: 'lateral_resistance',
      title: 'Lateral Resistance',
      description: 'What resists horizontal forces?',
      icon: Icons.height_rounded,
      screenBuilder: (context, onNext, onBack) => _LateralResistanceStepWrapper(
        onComplete: onNext,
        onBack: onBack,
      ),
    ),
    WizardStep(
      id: 'connection_quality',
      title: 'Connection Quality',
      description: 'How are structural elements connected?',
      icon: Icons.link_rounded,
      screenBuilder: (context, onNext, onBack) => _ConnectionQualityStepWrapper(
        onComplete: onNext,
        onBack: onBack,
      ),
    ),
    WizardStep(
      id: 'renovation',
      title: 'Renovation',
      description: 'Has the building been renovated?',
      icon: Icons.build_rounded,
      isOptional: true,
      screenBuilder: (context, onNext, onBack) => _RenovationYearStepWrapper(
        onComplete: onNext,
        onBack: onBack,
      ),
    ),
    WizardStep(
      id: 'soft_storey',
      title: 'Soft Storey',
      description: 'Does the building have a soft storey?',
      icon: Icons.layers_outlined,
      screenBuilder: (context, onNext, onBack) => _SoftStoreyStepWrapper(
        onComplete: onNext,
        onBack: onBack,
      ),
    ),
    WizardStep(
      id: 'soil_type',
      title: 'Soil Type',
      description: 'What type of soil is the building on?',
      icon: Icons.landscape_rounded,
      screenBuilder: (context, onNext, onBack) => _SoilTypeStepWrapper(
        onComplete: onNext,
        onBack: onBack,
      ),
    ),
    WizardStep(
      id: 'distance_to_fault',
      title: 'Distance to Fault',
      description: 'How far from the nearest fault?',
      icon: Icons.map_rounded,
      isOptional: true,
      screenBuilder: (context, onNext, onBack) => _DistanceToFaultStepWrapper(
        onComplete: onNext,
        onBack: onBack,
      ),
    ),
    WizardStep(
      id: 'column_spacing',
      title: 'Column Spacing',
      description: 'What is the spacing between columns?',
      icon: Icons.grid_3x3_rounded,
      isOptional: true,
      screenBuilder: (context, onNext, onBack) => _ColumnSpacingStepWrapper(
        onComplete: onNext,
        onBack: onBack,
      ),
    ),
    WizardStep(
      id: 'occupied',
      title: 'Occupancy',
      description: 'Is the building occupied?',
      icon: Icons.people_rounded,
      screenBuilder: (context, onNext, onBack) => _OccupiedStatusStepWrapper(
        onComplete: onNext,
        onBack: onBack,
      ),
    ),
    WizardStep(
      id: 'critical_infrastructure',
      title: 'Critical Infrastructure',
      description: 'Is this critical infrastructure?',
      icon: Icons.local_hospital_rounded,
      screenBuilder: (context, onNext, onBack) => _CriticalInfrastructureStepWrapper(
        onComplete: onNext,
        onBack: onBack,
      ),
    ),
    WizardStep(
      id: 'photos',
      title: 'Photos',
      description: 'Take photos of your building (optional)',
      icon: Icons.camera_alt_rounded,
      isOptional: true,
      screenBuilder: (context, onNext, onBack) => _PhotoStepWrapper(
        onComplete: onNext,
        onBack: onBack,
      ),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStepIndex < _steps.length - 1) {
      setState(() {
        _currentStepIndex++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _runAssessment();
    }
  }

  void _previousStep() {
    if (_currentStepIndex > 0) {
      setState(() {
        _currentStepIndex--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _runAssessment() async {
    // Small delay to ensure any pending saves complete
    await Future.delayed(const Duration(milliseconds: 200));
    
    // Ensure we have the latest building state
    var building = ref.read(buildingProvider);
    
    // If building is null, try to reload it once more
    if (building == null) {
      await Future.delayed(const Duration(milliseconds: 100));
      building = ref.read(buildingProvider);
    }
    
    // If still null, show error
    if (building == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to load building data. Please try again.'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
      return;
    }
    
    // Check for critical required fields - at minimum we need location
    if (building.latitude == 0.0 && building.longitude == 0.0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please provide building location'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
      return;
    }
    
    // Ensure we have an ID (create local ID if needed for offline mode)
    final buildingWithId = building.id == null || building.id!.isEmpty
        ? building.copyWith(
            id: 'local-${DateTime.now().millisecondsSinceEpoch}',
            updatedAt: DateTime.now(),
          )
        : building;
    
    // Use the building with ID for the assessment
    final finalBuilding = buildingWithId;

    // Show enhanced loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.grey.shade50,
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Running Assessment',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Analyzing your building data with AI',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'This may take a few moments...',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final apiClient = ref.read(apiClientProvider);
      final predictionRepo = PredictionRepository(apiClient);
      final prediction = await predictionRepo.triggerPrediction(finalBuilding.id!);

      final recommendations = _generateRecommendations(prediction);

      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ResultsScreen(
              prediction: prediction,
              recommendations: recommendations,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error running assessment: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  List<Recommendation> _generateRecommendations(Prediction prediction) {
    final recommendations = <Recommendation>[];
    
    if (prediction.collapseProbability > 0.8) {
      recommendations.add(Recommendation(
        id: '1',
        priority: RecommendationPriority.immediate,
        title: 'Immediate Safety Measures',
        description: 'Your building has a high collapse risk. Take immediate action.',
        actionSteps: [
          'Consult a licensed structural engineer immediately',
          'Avoid using upper floors, especially at night',
          'Do not store heavy items on upper floors',
          'Have an evacuation plan ready',
        ],
        urgency: 'Critical',
      ));
    }

    if (prediction.collapseProbability > 0.5) {
      recommendations.add(Recommendation(
        id: '2',
        priority: RecommendationPriority.shortTerm,
        title: 'Short-term Safety Improvements',
        description: 'Improve building safety in the short term.',
        actionSteps: [
          'Secure non-structural elements (furniture, appliances)',
          'Bolt heavy furniture to walls',
          'Install earthquake straps for water heaters',
          'Remove heavy objects from high shelves',
        ],
        estimatedCost: 'Low cost',
      ));
    }

    recommendations.add(Recommendation(
      id: '3',
      priority: RecommendationPriority.retrofit,
      title: 'Structural Retrofitting',
      description: 'Consider structural improvements to reduce risk.',
      actionSteps: [
        'Add shear walls or braces',
        'Strengthen foundation connections',
        'Improve column-beam connections',
        'Add tie columns/beams',
      ],
      estimatedCost: 'Medium to high cost',
    ));

    return recommendations;
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = _steps[_currentStepIndex];
    final progress = (_currentStepIndex + 1) / _steps.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              currentStep.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (currentStep.isOptional)
              Text(
                'Optional Step',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        leading: _currentStepIndex > 0
            ? IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_rounded, size: 20),
                ),
                onPressed: _previousStep,
              )
            : null,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: AppTheme.grey200, width: 1),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Step ${_currentStepIndex + 1} of ${_steps.length}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Simple progress bar
                Stack(
                  children: [
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.grey200,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: progress,
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Step content with gradient background
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    const Color(0xFFF5F7FA),
                  ],
                ),
              ),
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _steps.length,
                itemBuilder: (context, index) {
                  final step = _steps[index];
                  return step.screenBuilder(
                    context,
                    _nextStep,
                    _previousStep,
                  );
                },
              ),
            ),
          ),

          // Navigation buttons
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: AppTheme.grey200, width: 1),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    if (_currentStepIndex > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _previousStep,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Back'),
                        ),
                      ),
                    if (_currentStepIndex > 0) const SizedBox(width: 12),
                    Expanded(
                      flex: _currentStepIndex > 0 ? 2 : 1,
                      child: ElevatedButton(
                        onPressed: _nextStep,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _currentStepIndex == _steps.length - 1
                                  ? 'Run Assessment'
                                  : 'Continue',
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              _currentStepIndex == _steps.length - 1
                                  ? Icons.assessment_rounded
                                  : Icons.arrow_forward_rounded,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WizardStep {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final bool isOptional;
  final Widget Function(BuildContext, VoidCallback, VoidCallback) screenBuilder;

  WizardStep({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.screenBuilder,
    this.isOptional = false,
  });
}

// Wrapper widgets that adapt existing screens to the wizard flow

class _LocationStepWrapper extends ConsumerWidget {
  final VoidCallback onComplete;

  const _LocationStepWrapper({required this.onComplete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LocationScreen(onComplete: onComplete);
  }
}

class _AddressStepWrapper extends ConsumerWidget {
  final VoidCallback onComplete;
  final VoidCallback onBack;

  const _AddressStepWrapper({
    required this.onComplete,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AddressConfirmationScreen(onComplete: onComplete);
  }
}

class _YearBuiltStepWrapper extends ConsumerWidget {
  final VoidCallback onComplete;
  final VoidCallback onBack;

  const _YearBuiltStepWrapper({
    required this.onComplete,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return YearBuiltScreen(onComplete: onComplete);
  }
}

class _NumFloorsStepWrapper extends ConsumerWidget {
  final VoidCallback onComplete;
  final VoidCallback onBack;

  const _NumFloorsStepWrapper({
    required this.onComplete,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NumFloorsScreen(onComplete: onComplete);
  }
}

class _StructureTypeStepWrapper extends ConsumerWidget {
  final VoidCallback onComplete;
  final VoidCallback onBack;

  const _StructureTypeStepWrapper({
    required this.onComplete,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StructureTypeScreen(onComplete: onComplete);
  }
}

class _BuildingUsageStepWrapper extends ConsumerWidget {
  final VoidCallback onComplete;
  final VoidCallback onBack;

  const _BuildingUsageStepWrapper({
    required this.onComplete,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BuildingUsageScreen(onComplete: onComplete);
  }
}

class _FoundationTypeStepWrapper extends ConsumerWidget {
  final VoidCallback onComplete;
  final VoidCallback onBack;

  const _FoundationTypeStepWrapper({
    required this.onComplete,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FoundationTypeScreen(onComplete: onComplete);
  }
}

class _FloorAreaStepWrapper extends ConsumerWidget {
  final VoidCallback onComplete;
  final VoidCallback onBack;

  const _FloorAreaStepWrapper({
    required this.onComplete,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloorAreaScreen(onComplete: onComplete);
  }
}

class _MaterialQualityStepWrapper extends ConsumerWidget {
  final VoidCallback onComplete;
  final VoidCallback onBack;

  const _MaterialQualityStepWrapper({
    required this.onComplete,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialQualityScreen(onComplete: onComplete);
  }
}

class _IrregularitiesStepWrapper extends ConsumerWidget {
  final VoidCallback onComplete;
  final VoidCallback onBack;

  const _IrregularitiesStepWrapper({
    required this.onComplete,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IrregularitiesScreen(onComplete: onComplete);
  }
}

class _BasementFloorsStepWrapper extends ConsumerWidget {
  final VoidCallback onComplete;
  final VoidCallback onBack;

  const _BasementFloorsStepWrapper({
    required this.onComplete,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BasementFloorsScreen(onComplete: onComplete);
  }
}

class _WallMaterialStepWrapper extends ConsumerWidget {
  final VoidCallback onComplete;
  final VoidCallback onBack;

  const _WallMaterialStepWrapper({
    required this.onComplete,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WallMaterialScreen(onComplete: onComplete);
  }
}

class _RoofTypeStepWrapper extends ConsumerWidget {
  final VoidCallback onComplete;
  final VoidCallback onBack;

  const _RoofTypeStepWrapper({
    required this.onComplete,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RoofTypeScreen(onComplete: onComplete);
  }
}

class _FloorSystemStepWrapper extends ConsumerWidget {
  final VoidCallback onComplete;
  final VoidCallback onBack;

  const _FloorSystemStepWrapper({
    required this.onComplete,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloorSystemScreen(onComplete: onComplete);
  }
}

class _LateralResistanceStepWrapper extends ConsumerWidget {
  final VoidCallback onComplete;
  final VoidCallback onBack;

  const _LateralResistanceStepWrapper({
    required this.onComplete,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LateralResistanceScreen(onComplete: onComplete);
  }
}

class _ConnectionQualityStepWrapper extends ConsumerWidget {
  final VoidCallback onComplete;
  final VoidCallback onBack;

  const _ConnectionQualityStepWrapper({
    required this.onComplete,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ConnectionQualityScreen(onComplete: onComplete);
  }
}

class _RenovationYearStepWrapper extends ConsumerWidget {
  final VoidCallback onComplete;
  final VoidCallback onBack;

  const _RenovationYearStepWrapper({
    required this.onComplete,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RenovationYearScreen(onComplete: onComplete);
  }
}

class _SoftStoreyStepWrapper extends ConsumerWidget {
  final VoidCallback onComplete;
  final VoidCallback onBack;

  const _SoftStoreyStepWrapper({
    required this.onComplete,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SoftStoreyScreen(onComplete: onComplete);
  }
}

class _SoilTypeStepWrapper extends ConsumerWidget {
  final VoidCallback onComplete;
  final VoidCallback onBack;

  const _SoilTypeStepWrapper({
    required this.onComplete,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SoilTypeScreen(onComplete: onComplete);
  }
}

class _DistanceToFaultStepWrapper extends ConsumerWidget {
  final VoidCallback onComplete;
  final VoidCallback onBack;

  const _DistanceToFaultStepWrapper({
    required this.onComplete,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DistanceToFaultScreen(onComplete: onComplete);
  }
}

class _ColumnSpacingStepWrapper extends ConsumerWidget {
  final VoidCallback onComplete;
  final VoidCallback onBack;

  const _ColumnSpacingStepWrapper({
    required this.onComplete,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ColumnSpacingScreen(onComplete: onComplete);
  }
}

class _OccupiedStatusStepWrapper extends ConsumerWidget {
  final VoidCallback onComplete;
  final VoidCallback onBack;

  const _OccupiedStatusStepWrapper({
    required this.onComplete,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OccupiedStatusScreen(onComplete: onComplete);
  }
}

class _CriticalInfrastructureStepWrapper extends ConsumerWidget {
  final VoidCallback onComplete;
  final VoidCallback onBack;

  const _CriticalInfrastructureStepWrapper({
    required this.onComplete,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CriticalInfrastructureScreen(onComplete: onComplete);
  }
}

class _PhotoStepWrapper extends ConsumerWidget {
  final VoidCallback onComplete;
  final VoidCallback onBack;

  const _PhotoStepWrapper({
    required this.onComplete,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PhotoCaptureScreen(onComplete: onComplete);
  }
}

