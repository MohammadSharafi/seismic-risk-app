import 'package:flutter/material.dart';
import '../../domain/entities/patient.dart';
import '../widgets/risk_badge.dart';
import '../theme/app_theme.dart';
import '../theme/tailwind_spacing.dart';
import '../utils/lucide_icons.dart';
import '../utils/svg_icons.dart';
import 'visit_analysis_flow_page.dart';
import 'clinical_summary_page.dart';

class _TabInfo {
  final String id;
  final Widget icon;
  final String label;

  const _TabInfo(this.id, this.icon, this.label);
}

class PatientDetailPage extends StatefulWidget {
  final Patient patient;
  final VoidCallback onBack;
  final VoidCallback? onViewFullRecord;
  final VoidCallback? onViewFullClinicalSummary;
  final VoidCallback? onViewAuditLog;
  final VoidCallback? onViewFullTimeline;
  final VoidCallback? onViewFullDiscussion;

  const PatientDetailPage({
    super.key,
    required this.patient,
    required this.onBack,
    this.onViewFullRecord,
    this.onViewFullClinicalSummary,
    this.onViewAuditLog,
    this.onViewFullTimeline,
    this.onViewFullDiscussion,
  });

  @override
  State<PatientDetailPage> createState() => _PatientDetailPageState();
}

class _PatientDetailPageState extends State<PatientDetailPage> {
  String _infoTab = 'summary';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.gray50,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(TailwindSpacing.p4), // p-4 (further reduced)
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section A - Visit & Analysis Flow (2/3 width) - col-span-2
                  Expanded(
                    flex: 2,
                    child: Padding(
                          padding: const EdgeInsets.only(right: TailwindSpacing.gap3), // gap-3 (further reduced)
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader(
                                'Active Visit & Analysis',
                                'Step-by-step clinical workflow',
                                isActive: true,
                              ),
                              SizedBox(height: TailwindSpacing.mb2), // mb-2 (further reduced)
                          Expanded(
                            child: VisitAnalysisFlowPage(patient: widget.patient),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Section B - Patient Information (1/3 width) - col-span-1
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(
                          'Patient Information',
                          'Historical data and records',
                        ),
                        SizedBox(height: TailwindSpacing.mb2), // mb-2 (further reduced)
                        Expanded(
                          child: _buildInfoTabs(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white, // bg-white
        border: Border(bottom: BorderSide(color: AppTheme.gray200, width: 1)), // border-b border-gray-200
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: TailwindSpacing.p4, // px-4 (further reduced)
        vertical: TailwindSpacing.p2, // py-2 (further reduced)
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: widget.onBack,
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.blue600, // text-blue-600
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgIcons.chevronLeft(size: 16, color: AppTheme.blue600),
                  const SizedBox(width: TailwindSpacing.gap1), // gap-1
                  const Text(
                    'Back to Dashboard',
                    style: TextStyle(
                      fontSize: TailwindFontSize.textSm, // text-sm
                      color: AppTheme.blue600,
                      height: 1.5,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: TailwindSpacing.mb1), // mb-1 (further reduced)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.patient.name,
                      style: const TextStyle(
                        fontSize: TailwindFontSize.textXl, // text-xl (reduced from text-2xl)
                        fontWeight: FontWeight.w600, // font-semibold
                        color: AppTheme.gray900,
                        height: 1.5,
                        letterSpacing: 0,
                      ),
                    ),
                    SizedBox(height: TailwindSpacing.mb1), // mb-1
                    Text(
                      '${widget.patient.age} years • ${widget.patient.sex} • Twin ID: ${widget.patient.twinId}',
                      style: const TextStyle(
                        fontSize: TailwindFontSize.textSm, // text-sm (reduced from text-base)
                        color: AppTheme.gray600,
                        height: 1.5,
                        letterSpacing: 0,
                      ),
                    ),
                    SizedBox(height: TailwindSpacing.mb1), // mb-1 (further reduced)
                    Wrap(
                      spacing: TailwindSpacing.gap2, // gap-2
                      runSpacing: TailwindSpacing.gap2,
                      children: widget.patient.cohort.map((c) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: TailwindSpacing.p2, // px-2
                            vertical: TailwindSpacing.p1, // py-1
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.blue50, // bg-blue-50
                            borderRadius: BorderRadius.circular(TailwindRadius.rounded), // rounded
                          ),
                          child: Text(
                            c,
                            style: const TextStyle(
                              fontSize: TailwindFontSize.textXs, // text-xs
                              color: AppTheme.blue700, // text-blue-700
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Current Risk Tier',
                    style: TextStyle(
                      fontSize: TailwindFontSize.textSm, // text-sm
                      color: AppTheme.gray500, // text-gray-500
                    ),
                  ),
                  SizedBox(height: TailwindSpacing.mb2), // mb-2
                  RiskBadge(tier: widget.patient.riskTier, size: BadgeSize.lg),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, {bool isActive = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (isActive) ...[
              Container(
                width: TailwindSize.w2, // w-2
                height: TailwindSize.h2, // h-2
                decoration: const BoxDecoration(
                  color: AppTheme.blue600, // bg-blue-600
                  shape: BoxShape.circle, // rounded-full
                ),
              ),
              SizedBox(width: TailwindSpacing.gap2), // gap-2
            ],
            Text(
              title,
              style: const TextStyle(
                fontSize: TailwindFontSize.textLg, // font-semibold (default is text-lg for h2)
                fontWeight: FontWeight.w600, // font-semibold
                color: AppTheme.gray900,
              ),
            ),
            if (isActive) ...[
              SizedBox(width: TailwindSpacing.gap2), // gap-2
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: TailwindSpacing.p2, // px-2
                  vertical: 2, // py-0.5 (0.125rem = 2px)
                ),
                decoration: BoxDecoration(
                  color: AppTheme.blue100, // bg-blue-100
                  borderRadius: BorderRadius.circular(TailwindRadius.rounded), // rounded
                ),
                child: const Text(
                  'Current',
                  style: TextStyle(
                    fontSize: TailwindFontSize.textXs, // text-xs
                    fontWeight: FontWeight.w600, // font-medium (500, but using 600 for semibold)
                    color: AppTheme.blue700, // text-blue-700
                  ),
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: TailwindSpacing.mb2), // mb-2
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: TailwindFontSize.textSm, // text-sm
            color: AppTheme.gray600, // text-gray-600
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTabs() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.gray200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildTabButtons(),
          Expanded(
            child: _buildTabContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabIcon(String tabId, bool isSelected) {
    final color = isSelected ? AppTheme.blue700 : AppTheme.gray700;
    switch (tabId) {
      case 'summary':
        return SvgIcons.activity(size: 16, color: color);
      case 'history':
        return SvgIcons.clock(size: 16, color: color);
      case 'decisions':
        return SvgIcons.shield(size: 16, color: color);
      case 'discussion':
        return SvgIcons.messageSquare(size: 16, color: color);
      case 'monitoring':
        return SvgIcons.fileText(size: 16, color: color);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTabButtons() {
    final tabs = [
      _TabInfo('summary', const SizedBox.shrink(), 'Clinical Summary'),
      _TabInfo('history', const SizedBox.shrink(), 'Visit History'),
      _TabInfo('decisions', const SizedBox.shrink(), 'Audit Log'),
      _TabInfo('discussion', const SizedBox.shrink(), 'Clinical Discussion'),
      _TabInfo('monitoring', const SizedBox.shrink(), 'Background Monitoring'),
    ];

    return Column(
      children: tabs.map((tab) {
        final isSelected = _infoTab == tab.id;
        return InkWell(
          onTap: () {
            setState(() {
              _infoTab = tab.id;
            });
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.blue50 : Colors.transparent,
              border: isSelected
                  ? const Border(
                      left: BorderSide(color: AppTheme.blue600, width: 2),
                    )
                  : null,
            ),
            child: Row(
              children: [
                _buildTabIcon(tab.id, isSelected),
                const SizedBox(width: 8),
                Text(
                  tab.label,
                  style: TextStyle(
                    fontSize: TailwindFontSize.textSm, // text-sm = 14px
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? AppTheme.blue700 : AppTheme.gray700,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTabContent() {
    switch (_infoTab) {
      case 'summary':
        return ClinicalSummaryPage(
          patient: widget.patient,
          onViewFullSummary: widget.onViewFullClinicalSummary,
        );
      case 'history':
        return _buildVisitHistory();
      case 'decisions':
        return _buildAuditLog();
      case 'discussion':
        return _buildClinicalDiscussion();
      case 'monitoring':
        return _buildBackgroundMonitoring();
      default:
        return const SizedBox();
    }
  }

  Widget _buildVisitHistory() {
    final visits = [
      {'date': 'Jan 8, 2026', 'type': 'Manual', 'status': 'Completed'},
      {'date': 'Jan 6, 2026', 'type': 'Background', 'status': 'Completed'},
      {'date': 'Dec 28, 2025', 'type': 'Follow-up', 'status': 'Completed'}
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(TailwindSpacing.p4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent visit timeline',
            style: TextStyle(
              fontSize: TailwindFontSize.textSm,
              color: AppTheme.gray600,
            ),
          ),
          SizedBox(height: TailwindSpacing.mb3),
          ...visits.map((visit) {
            return Container(
              margin: EdgeInsets.only(bottom: TailwindSpacing.mb2),
              padding: const EdgeInsets.all(TailwindSpacing.p3),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.gray200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        visit['date'] as String,
                        style: const TextStyle(
                          fontSize: TailwindFontSize.textSm,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.gray900,
                        ),
                      ),
                      const Icon(LucideIcons.chevronRight, size: 16, color: AppTheme.gray400),
                    ],
                  ),
                  SizedBox(height: TailwindSpacing.mb1),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: TailwindSpacing.p2,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.blue50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          visit['type'] as String,
                          style: const TextStyle(
                            fontSize: TailwindFontSize.textXs,
                            color: AppTheme.blue700,
                          ),
                        ),
                      ),
                      SizedBox(width: TailwindSpacing.gap2),
                      Text(
                        visit['status'] as String,
                        style: const TextStyle(
                          fontSize: TailwindFontSize.textXs,
                          color: AppTheme.gray500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
          SizedBox(height: TailwindSpacing.mt2),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: widget.onViewFullTimeline,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.blue200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12, // px-3 = 12px
                  vertical: 6, // py-1.5 = 6px
                ),
                minimumSize: const Size(0, 32), // h-8 = 32px
              ),
              child: const Text(
                'View Full Timeline',
                style: TextStyle(
                  fontSize: TailwindFontSize.textXs, // text-xs = 12px (smaller)
                  fontWeight: FontWeight.w500, // font-medium
                  color: AppTheme.blue600,
                  height: 1.5,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditLog() {
    final entries = [
      {
        'date': 'Jan 8, 2026 11:15 AM',
        'action': 'Approved Clinical Decision',
        'actor': 'Dr. Rebecca Smith',
        'type': 'Final Decision'
      },
      {
        'date': 'Jan 8, 2026 10:45 AM',
        'action': 'Generated Risk Assessment',
        'actor': 'AI Clinical System',
        'type': 'AI Output'
      },
      {
        'date': 'Jan 6, 2026 3:15 PM',
        'action': 'Modified Risk Assessment',
        'actor': 'Dr. Rebecca Smith',
        'type': 'Doctor Edit'
      }
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(TailwindSpacing.p4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Audit Log',
            style: TextStyle(
              fontSize: TailwindFontSize.textSm,
              fontWeight: FontWeight.w600,
              color: AppTheme.gray900,
            ),
          ),
          SizedBox(height: TailwindSpacing.mb3),
          const Text(
            'Recent audit entries',
            style: TextStyle(
              fontSize: TailwindFontSize.textSm,
              color: AppTheme.gray600,
            ),
          ),
          SizedBox(height: TailwindSpacing.mb3),
          ...entries.map((entry) {
            return Container(
              margin: EdgeInsets.only(bottom: TailwindSpacing.mb2),
              padding: const EdgeInsets.all(TailwindSpacing.p3),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.gray200),
                borderRadius: BorderRadius.circular(8),
                color: AppTheme.gray50,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: TailwindSpacing.p2,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getEntryTypeColor(entry['type'] as String).bg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      entry['type'] as String,
                      style: TextStyle(
                        fontSize: TailwindFontSize.textXs,
                        fontWeight: FontWeight.w600,
                        color: _getEntryTypeColor(entry['type'] as String).text,
                      ),
                    ),
                  ),
                  SizedBox(height: TailwindSpacing.mb1),
                  Text(
                    entry['action'] as String,
                    style: const TextStyle(
                      fontSize: TailwindFontSize.textSm,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.gray900,
                    ),
                  ),
                  SizedBox(height: TailwindSpacing.mb1),
                  Text(
                    entry['actor'] as String,
                    style: const TextStyle(
                      fontSize: TailwindFontSize.textXs,
                      color: AppTheme.gray600,
                    ),
                  ),
                  Text(
                    entry['date'] as String,
                    style: const TextStyle(
                      fontSize: TailwindFontSize.textXs,
                      color: AppTheme.gray500,
                    ),
                  ),
                ],
              ),
            );
          }),
          SizedBox(height: TailwindSpacing.mt2),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: widget.onViewAuditLog,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.blue200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12, // px-3 = 12px
                  vertical: 6, // py-1.5 = 6px
                ),
                minimumSize: const Size(0, 32), // h-8 = 32px
              ),
              child: const Text(
                'View Full Audit Log',
                style: TextStyle(
                  fontSize: TailwindFontSize.textXs, // text-xs = 12px (smaller)
                  fontWeight: FontWeight.w500, // font-medium
                  color: AppTheme.blue600,
                  height: 1.5,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClinicalDiscussion() {
    final messages = [
      {'doctor': 'Dr. Smith', 'time': '11:20 AM', 'message': 'Adjusted medication dosage based on latest labs'},
      {'doctor': 'Dr. Chen', 'time': '10:45 AM', 'message': 'Reviewed renal function - looks stable'}
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(TailwindSpacing.p4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Clinical team conversation',
            style: TextStyle(
              fontSize: TailwindFontSize.textSm,
              color: AppTheme.gray600,
            ),
          ),
          SizedBox(height: TailwindSpacing.mb3),
          ...messages.map((msg) {
            return Padding(
              padding: EdgeInsets.only(bottom: TailwindSpacing.mb3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppTheme.blue100,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            (msg['doctor'] as String).split(' ')[1][0],
                            style: const TextStyle(
                              fontSize: TailwindFontSize.textXs,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.blue700,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: TailwindSpacing.gap2),
                      Text(
                        msg['doctor'] as String,
                        style: const TextStyle(
                          fontSize: TailwindFontSize.textXs,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.gray900,
                        ),
                      ),
                      SizedBox(width: TailwindSpacing.gap2),
                      Text(
                        msg['time'] as String,
                        style: const TextStyle(
                          fontSize: TailwindFontSize.textXs,
                          color: AppTheme.gray400,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 32),
                    child: Text(
                      msg['message'] as String,
                      style: const TextStyle(
                        fontSize: TailwindFontSize.textSm,
                        color: AppTheme.gray700,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: widget.onViewFullDiscussion,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.blue200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12, // px-3 = 12px
                  vertical: 6, // py-1.5 = 6px
                ),
                minimumSize: const Size(0, 32), // h-8 = 32px
              ),
              child: const Text(
                'Open Full Discussion',
                style: TextStyle(
                  fontSize: TailwindFontSize.textXs, // text-xs = 12px (smaller)
                  fontWeight: FontWeight.w500, // font-medium
                  color: AppTheme.blue600,
                  height: 1.5,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundMonitoring() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(TailwindSpacing.p4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(TailwindSpacing.p4),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppTheme.gray200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Monitoring Status',
                  style: TextStyle(
                    fontSize: TailwindFontSize.textSm,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.gray900,
                  ),
                ),
                SizedBox(height: TailwindSpacing.mb3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Last Check:',
                      style: TextStyle(
                        fontSize: TailwindFontSize.textSm,
                        color: AppTheme.gray600,
                      ),
                    ),
                    const Text(
                      'Jan 8, 2026 08:30 AM',
                      style: TextStyle(
                        fontSize: TailwindFontSize.textSm,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.gray900,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: TailwindSpacing.gap2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Current State:',
                      style: TextStyle(
                        fontSize: TailwindFontSize.textSm,
                        color: AppTheme.gray600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: TailwindSpacing.p2,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.green100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Stable',
                        style: TextStyle(
                          fontSize: TailwindFontSize.textXs,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.green800,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: TailwindSpacing.mb3),
          Container(
            padding: const EdgeInsets.all(TailwindSpacing.p3),
            decoration: BoxDecoration(
              color: AppTheme.green50,
              border: Border.all(color: AppTheme.green200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppTheme.green600,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: TailwindSpacing.gap2),
                    const Text(
                      'Active',
                      style: TextStyle(
                        fontSize: TailwindFontSize.textSm,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.green800,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: TailwindSpacing.mb1),
                const Text(
                  'Background monitoring enabled',
                  style: TextStyle(
                    fontSize: TailwindFontSize.textXs,
                    color: AppTheme.green800,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: TailwindSpacing.gap2),
          Container(
            padding: const EdgeInsets.all(TailwindSpacing.p2),
            decoration: BoxDecoration(
              color: AppTheme.gray50,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Next Evaluation',
                  style: TextStyle(
                    fontSize: TailwindFontSize.textXs,
                    color: AppTheme.gray500,
                  ),
                ),
                SizedBox(height: TailwindSpacing.mb1),
                const Text(
                  'Jan 15, 2026 09:00 AM',
                  style: TextStyle(
                    fontSize: TailwindFontSize.textSm,
                    color: AppTheme.gray900,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: TailwindSpacing.gap2),
          Container(
            padding: const EdgeInsets.all(TailwindSpacing.p2),
            decoration: BoxDecoration(
              color: AppTheme.gray50,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Last Data Sync',
                  style: TextStyle(
                    fontSize: TailwindFontSize.textXs,
                    color: AppTheme.gray500,
                  ),
                ),
                SizedBox(height: TailwindSpacing.mb1),
                const Text(
                  'Jan 8, 2026 08:30 AM',
                  style: TextStyle(
                    fontSize: TailwindFontSize.textSm,
                    color: AppTheme.gray900,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: TailwindSpacing.mt3),
          Container(
            padding: const EdgeInsets.all(TailwindSpacing.p2),
            decoration: BoxDecoration(
              color: AppTheme.blue50,
              border: Border.all(color: AppTheme.blue200),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Status: No new data detected',
              style: TextStyle(
                fontSize: TailwindFontSize.textXs,
                color: AppTheme.blue900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  ({Color bg, Color text}) _getEntryTypeColor(String type) {
    switch (type) {
      case 'AI Output':
        return (bg: AppTheme.purple100, text: AppTheme.purple700);
      case 'Doctor Edit':
        return (bg: AppTheme.blue100, text: AppTheme.blue700);
      case 'Final Decision':
        return (bg: AppTheme.green100, text: AppTheme.green700);
      default:
        return (bg: AppTheme.gray100, text: AppTheme.gray700);
    }
  }
}
