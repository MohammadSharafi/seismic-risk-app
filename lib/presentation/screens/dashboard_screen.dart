import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seismic_risk_app/core/theme/app_theme.dart';
import 'package:seismic_risk_app/presentation/widgets/responsive/app_card.dart';
import 'package:seismic_risk_app/presentation/widgets/responsive/app_button.dart';
import 'package:seismic_risk_app/presentation/widgets/responsive/responsive_layout.dart';
import 'package:seismic_risk_app/presentation/screens/assessment_wizard_screen.dart';
import 'package:seismic_risk_app/presentation/screens/seismic_map_screen.dart';
import 'package:seismic_risk_app/presentation/screens/building_history_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final padding = ResponsiveLayout.getPadding(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // Clean header bar
          SliverAppBar(
            expandedHeight: isMobile ? 140 : 160,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.surface,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 8,
                    left: padding,
                    right: padding,
                    bottom: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Seismic Risk Assessment',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Assess your building\'s earthquake safety',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(padding),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  const SizedBox(height: 8),
                  _buildHeroSection(context, isMobile),
                  const SizedBox(height: 24),
                  _buildQuickActions(context, isMobile),
                  const SizedBox(height: 24),
                  _buildStatsGrid(context, isMobile),
                  const SizedBox(height: 24),
                  _buildRecentActivity(context, isMobile),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, bool isMobile) {
    return AppCard(
      padding: EdgeInsets.all(isMobile ? 24 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.shield_outlined, color: AppTheme.primary, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'New Assessment',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Get a comprehensive seismic risk analysis',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          AppButton(
            label: 'Start Assessment',
            icon: Icons.assessment_rounded,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AssessmentWizardScreen(),
                ),
              );
            },
            variant: AppButtonVariant.primary,
            fullWidth: true,
            size: AppButtonSize.large,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
        ),
        const SizedBox(height: 16),
        ResponsiveLayout(
          mobile: Column(
            children: _buildActionCards(context, isMobile),
          ),
          desktop: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildActionCards(context, false)
                .map((card) => Expanded(child: card))
                .toList(),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildActionCards(BuildContext context, bool isMobile) {
    return [
      _buildActionCard(
        context,
        icon: Icons.map_outlined,
        iconColor: AppTheme.primary,
        title: 'Seismic Map',
        subtitle: 'View earthquake data and activity',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const SeismicMapScreen(),
            ),
          );
        },
      ),
      SizedBox(height: isMobile ? 16 : 0, width: isMobile ? 0 : 16),
      _buildActionCard(
        context,
        icon: Icons.history_rounded,
        iconColor: AppTheme.secondary,
        title: 'Assessment History',
        subtitle: 'View your previous assessments',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const BuildingHistoryScreen(),
            ),
          );
        },
      ),
      SizedBox(height: isMobile ? 16 : 0, width: isMobile ? 0 : 16),
      _buildActionCard(
        context,
        icon: Icons.insights_outlined,
        iconColor: AppTheme.warning,
        title: 'Risk Insights',
        subtitle: 'Learn about seismic risks',
        onTap: () {},
      ),
    ];
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: AppTheme.grey400, size: 24),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistics',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
        ),
        const SizedBox(height: 16),
        ResponsiveLayout(
          mobile: Column(
            children: _buildStatCards(context, isMobile),
          ),
          desktop: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildStatCards(context, false)
                .map((card) => Expanded(child: card))
                .toList(),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildStatCards(BuildContext context, bool isMobile) {
    return [
      _buildStatCard(
        context,
        label: 'Total Assessments',
        value: '0',
        icon: Icons.assessment_rounded,
        iconColor: AppTheme.primary,
      ),
      SizedBox(height: isMobile ? 16 : 0, width: isMobile ? 0 : 16),
      _buildStatCard(
        context,
        label: 'High Risk Buildings',
        value: '0',
        icon: Icons.warning_amber_rounded,
        iconColor: AppTheme.error,
      ),
    ];
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context, bool isMobile) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.access_time_rounded, color: AppTheme.secondary, size: 24),
              const SizedBox(width: 12),
              Text(
                'Recent Activity',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0),
              child: Column(
                children: [
                  Icon(Icons.history_rounded, size: 64, color: AppTheme.grey300),
                  const SizedBox(height: 16),
                  Text(
                    'No recent activity',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start your first assessment to see activity here',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
