import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seismic_risk_app/core/theme/app_theme.dart';
import 'package:seismic_risk_app/presentation/widgets/responsive/app_card.dart';
import 'package:seismic_risk_app/presentation/widgets/responsive/app_button.dart';
import 'package:seismic_risk_app/presentation/widgets/responsive/responsive_layout.dart';

class BuildingHistoryScreen extends ConsumerStatefulWidget {
  const BuildingHistoryScreen({super.key});

  @override
  ConsumerState<BuildingHistoryScreen> createState() => _BuildingHistoryScreenState();
}

class _BuildingHistoryScreenState extends ConsumerState<BuildingHistoryScreen> {
  // In a real app, this would come from a repository/provider
  final List<Map<String, dynamic>> _assessments = [];

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final padding = ResponsiveLayout.getPadding(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assessment History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: _assessments.isEmpty
          ? _buildEmptyState(context, isMobile)
          : SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, isMobile),
                  const SizedBox(height: 24),
                  ..._assessments.map((assessment) => _buildAssessmentCard(
                        context,
                        assessment,
                        isMobile,
                      )),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isMobile) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 24 : 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.history,
                size: 64,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Assessments Yet',
              style: TextStyle(
                fontSize: isMobile ? 24 : 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Start your first seismic risk assessment\nto see it here',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),
            AppButton(
              label: 'Start Assessment',
              icon: Icons.assessment,
              onPressed: () {
                Navigator.of(context).pop();
              },
              fullWidth: isMobile,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Your Assessments',
          style: TextStyle(
            fontSize: isMobile ? 24 : 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        AppButton(
          label: 'New Assessment',
          icon: Icons.add,
          onPressed: () {
            Navigator.of(context).pop();
          },
          size: AppButtonSize.small,
        ),
      ],
    );
  }

  Widget _buildAssessmentCard(
      BuildContext context, Map<String, dynamic> assessment, bool isMobile) {
    return AppCard(
      margin: EdgeInsets.only(bottom: isMobile ? 16 : 20),
      onTap: () {
        // Navigate to results
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assessment['address'] ?? 'Unknown Address',
                      style: TextStyle(
                        fontSize: isMobile ? 18 : 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      assessment['date'] ?? 'Unknown Date',
                      style: TextStyle(
                        fontSize: isMobile ? 13 : 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getRiskColor(assessment['riskLevel'])
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  assessment['riskLevel'] ?? 'UNKNOWN',
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    fontWeight: FontWeight.bold,
                    color: _getRiskColor(assessment['riskLevel']),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoChip(
                Icons.calendar_today,
                'Year: ${assessment['yearBuilt'] ?? 'N/A'}',
                isMobile,
              ),
              const SizedBox(width: 12),
              _buildInfoChip(
                Icons.stairs,
                'Floors: ${assessment['numFloors'] ?? 'N/A'}',
                isMobile,
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  // Navigate to details
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 12,
        vertical: isMobile ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isMobile ? 14 : 16, color: Colors.grey.shade700),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: isMobile ? 11 : 12,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRiskColor(String? riskLevel) {
    switch (riskLevel?.toUpperCase()) {
      case 'HIGH':
        return AppTheme.error;
      case 'MODERATE':
        return AppTheme.warning;
      case 'LOW':
        return AppTheme.success;
      default:
        return Colors.grey;
    }
  }
}

