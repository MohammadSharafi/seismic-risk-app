import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seismic_risk_app/core/theme/app_theme.dart';
import 'package:seismic_risk_app/presentation/screens/building_forms/year_built_screen.dart';
import 'package:seismic_risk_app/presentation/screens/building_forms/structure_type_screen.dart';
import 'package:seismic_risk_app/presentation/screens/building_forms/photo_capture_screen.dart';
import 'package:seismic_risk_app/presentation/screens/assessment_flow_screen.dart';

class BuildingInfoScreen extends ConsumerWidget {
  const BuildingInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Building Information'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header section
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
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.primary.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.business_rounded,
                        color: AppTheme.primary,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Building Information',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'We need some information about your building to assess its seismic risk.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade700,
                            height: 1.5,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Don\'t worry if you don\'t know everything - we\'ll use neighborhood defaults where possible.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _buildInfoCard(
                context,
                'Basic Information',
                'Year built, floors, usage type',
                Icons.info_rounded,
                AppTheme.primary,
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const YearBuiltScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                context,
                'Structural Details',
                'Structure type, foundation, materials',
                Icons.architecture_rounded,
                AppTheme.warning,
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const StructureTypeScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                context,
                'Photos',
                'Take photos of your building',
                Icons.camera_alt_rounded,
                AppTheme.success,
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PhotoCaptureScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                context,
                'Complete Assessment',
                'Review and run the assessment',
                Icons.assessment_rounded,
                AppTheme.primaryDark,
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AssessmentFlowScreen(),
                    ),
                  );
                },
                isPrimary: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap, {
    bool isPrimary = false,
  }) {
    return Card(
      elevation: isPrimary ? 4 : 2,
      shadowColor: isPrimary
          ? color.withOpacity(0.3)
          : Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: isPrimary
            ? BorderSide(color: color, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: isPrimary
              ? BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withOpacity(0.1),
                      color.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                )
              : null,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: color,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

