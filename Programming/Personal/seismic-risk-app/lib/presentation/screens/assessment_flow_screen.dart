import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seismic_risk_app/core/theme/app_theme.dart';
import 'package:seismic_risk_app/presentation/providers/building_provider.dart';
import 'package:seismic_risk_app/presentation/screens/building_forms/year_built_screen.dart';
import 'package:seismic_risk_app/presentation/screens/building_forms/num_floors_screen.dart';
import 'package:seismic_risk_app/presentation/screens/building_forms/structure_type_screen.dart';
import 'package:seismic_risk_app/presentation/screens/building_forms/photo_capture_screen.dart';
import 'package:seismic_risk_app/data/repositories/prediction_repository.dart';
import 'package:seismic_risk_app/presentation/screens/results_screen.dart';
import 'package:seismic_risk_app/domain/entities/recommendation.dart';
import 'package:seismic_risk_app/domain/entities/prediction.dart';

class AssessmentFlowScreen extends ConsumerStatefulWidget {
  const AssessmentFlowScreen({super.key});

  @override
  ConsumerState<AssessmentFlowScreen> createState() => _AssessmentFlowScreenState();
}

class _AssessmentFlowScreenState extends ConsumerState<AssessmentFlowScreen> {
  int _currentStep = 0;
  final List<AssessmentStep> _steps = [
    AssessmentStep(
      title: 'Year Built',
      screen: const YearBuiltScreen(),
    ),
    AssessmentStep(
      title: 'Number of Floors',
      screen: const NumFloorsScreen(),
    ),
    AssessmentStep(
      title: 'Structure Type',
      screen: const StructureTypeScreen(),
    ),
    AssessmentStep(
      title: 'Photos',
      screen: const PhotoCaptureScreen(),
      optional: true,
    ),
  ];

  Future<void> _runAssessment() async {
    final building = ref.read(buildingProvider);
    if (building?.id == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Running assessment...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final apiClient = ref.read(apiClientProvider);
      final predictionRepo = PredictionRepository(apiClient);
      final prediction = await predictionRepo.triggerPrediction(building!.id!);

      // Generate recommendations based on prediction
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
          SnackBar(content: Text('Error running assessment: $e')),
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
    final completedSteps = _currentStep;
    final progress = completedSteps / _steps.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Building Assessment'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
            minHeight: 4,
          ),
        ),
      ),
      body: Column(
        children: [
          // Progress header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primary.withOpacity(0.1),
                  AppTheme.primaryLight.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.assignment_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Assessment Progress',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$completedSteps of ${_steps.length} steps completed',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.primary,
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Steps list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _steps.length,
              itemBuilder: (context, index) {
                final step = _steps[index];
                final isCompleted = index < _currentStep;
                final isCurrent = index == _currentStep;
                final isPending = index > _currentStep;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildStepCard(
                    context,
                    step: step,
                    index: index,
                    isCompleted: isCompleted,
                    isCurrent: isCurrent,
                    isPending: isPending,
                  ),
                );
              },
            ),
          ),
          // Run assessment button
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primary,
                      AppTheme.primaryDark,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _runAssessment,
                  icon: const Icon(Icons.assessment_rounded, size: 22),
                  label: const Text(
                    'Run Assessment',
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
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard(
    BuildContext context, {
    required AssessmentStep step,
    required int index,
    required bool isCompleted,
    required bool isCurrent,
    required bool isPending,
  }) {
    Color getStepColor() {
      if (isCompleted) return AppTheme.success;
      if (isCurrent) return AppTheme.primary;
      return Colors.grey.shade300;
    }

    IconData getStepIcon() {
      if (isCompleted) return Icons.check_circle_rounded;
      if (isCurrent) return Icons.edit_rounded;
      return Icons.radio_button_unchecked_rounded;
    }

    return Card(
      elevation: isCurrent ? 4 : 2,
      shadowColor: isCurrent
          ? AppTheme.primary.withOpacity(0.2)
          : Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isCurrent
              ? AppTheme.primary
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: isCurrent || isCompleted
            ? () {
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (_) => step.screen,
                      ),
                    )
                    .then((_) {
                      setState(() {
                        if (index < _steps.length - 1) {
                          _currentStep = index + 1;
                        }
                      });
                    });
              }
            : null,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Step number/icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: getStepColor().withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: getStepColor(),
                    width: 2.5,
                  ),
                ),
                child: Icon(
                  getStepIcon(),
                  color: getStepColor(),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              // Step content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          step.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isPending
                                    ? Colors.grey.shade400
                                    : null,
                              ),
                        ),
                        if (step.optional) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Optional',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isCompleted
                          ? 'Completed'
                          : isCurrent
                              ? 'Tap to fill out'
                              : 'Pending',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isPending
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                          ),
                    ),
                  ],
                ),
              ),
              // Action icon
              if (isCurrent || isCompleted)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: getStepColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isCompleted ? Icons.arrow_forward_rounded : Icons.arrow_forward_rounded,
                    color: getStepColor(),
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class AssessmentStep {
  final String title;
  final Widget screen;
  final bool optional;

  AssessmentStep({
    required this.title,
    required this.screen,
    this.optional = false,
  });
}


