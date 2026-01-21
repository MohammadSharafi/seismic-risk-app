import 'package:flutter/material.dart';
import '../../domain/entities/patient.dart';
import '../../domain/value_objects/risk_tier.dart';
import '../theme/app_theme.dart';
import '../theme/tailwind_spacing.dart';
import '../utils/lucide_icons.dart';
import '../utils/svg_icons.dart';

class DecisionHistoryPage extends StatelessWidget {
  final Patient patient;
  final VoidCallback onBack;

  const DecisionHistoryPage({
    super.key,
    required this.patient,
    required this.onBack,
  });

  final List<Map<String, dynamic>> _auditLog = const [
    {
      'id': 'A001',
      'timestamp': 'Jan 8, 2026 11:15:23 AM',
      'type': 'Final Decision',
      'actor': 'Dr. Rebecca Smith',
      'riskTier': RiskTier.high,
      'action': 'Approved Clinical Decision',
      'details': 'Final risk tier: High. Medication adjustment ordered. Follow-up scheduled for Jan 15, 2026.',
      'linkedReferences': [
        {'type': 'visit', 'label': 'Visit V-2026-001'},
        {'type': 'decision', 'label': 'Decision Record D-2026-001'}
      ],
      'evaluationId': 'EVAL-2026-001'
    },
    {
      'id': 'A002',
      'timestamp': 'Jan 8, 2026 11:02:45 AM',
      'type': 'Doctor Edit',
      'actor': 'Dr. Rebecca Smith',
      'riskTier': RiskTier.high,
      'action': 'Modified Care Plan',
      'details': 'Reviewed AI recommendation. Accepted risk tier assessment. Added additional monitoring protocol for BP.',
      'linkedReferences': [
        {'type': 'visit', 'label': 'Visit V-2026-001'}
      ],
      'evaluationId': 'EVAL-2026-001'
    },
    {
      'id': 'A003',
      'timestamp': 'Jan 8, 2026 10:45:12 AM',
      'type': 'AI Output',
      'actor': 'AI Clinical System',
      'modelVersion': 'ClinicalAI v3.2.1',
      'riskTier': RiskTier.high,
      'action': 'Generated Risk Assessment',
      'details': 'AI analyzed patient data including vitals, lab results, and medication history. Risk factors: elevated BP, multiple comorbidities, medication interaction potential.',
      'linkedReferences': [
        {'type': 'analysis', 'label': 'AI Analysis Report'},
        {'type': 'visit', 'label': 'Visit V-2026-001'}
      ],
      'evaluationId': 'EVAL-2026-001'
    },
    {
      'id': 'A004',
      'timestamp': 'Jan 6, 2026 3:15:00 PM',
      'type': 'Final Decision',
      'actor': 'Dr. Rebecca Smith',
      'riskTier': RiskTier.medium,
      'action': 'Approved Clinical Decision',
      'details': 'Override AI suggestion (High → Medium). Rationale: Patient-reported stress event, monitoring before escalation.',
      'linkedReferences': [
        {'type': 'visit', 'label': 'Visit V-2026-002'}
      ],
      'evaluationId': 'EVAL-2026-002'
    },
    {
      'id': 'A005',
      'timestamp': 'Jan 6, 2026 3:05:30 PM',
      'type': 'Doctor Edit',
      'actor': 'Dr. Rebecca Smith',
      'riskTier': RiskTier.medium,
      'action': 'Modified Risk Assessment',
      'details': 'Downgraded from AI recommendation based on clinical context and patient interview.',
      'linkedReferences': [
        {'type': 'visit', 'label': 'Visit V-2026-002'}
      ],
      'evaluationId': 'EVAL-2026-002'
    },
    {
      'id': 'A006',
      'timestamp': 'Jan 6, 2026 2:30:15 PM',
      'type': 'Background Evaluation',
      'actor': 'AI Clinical System',
      'modelVersion': 'ClinicalAI v3.2.1',
      'riskTier': RiskTier.high,
      'action': 'Automated Alert Triggered',
      'details': 'Background monitoring detected BP spike (152/92). Anomaly detection algorithm flagged for immediate review.',
      'linkedReferences': [
        {'type': 'analysis', 'label': 'Anomaly Detection Report'}
      ],
      'evaluationId': 'EVAL-2026-002'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.gray50,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(TailwindSpacing.p4), // p-4 (further reduced)
              child: Column(
                children: [
                  _buildInfoBanner(),
                  SizedBox(height: TailwindSpacing.mb3), // mb-3 (further reduced)
                  _buildStatistics(),
                  SizedBox(height: TailwindSpacing.mb3), // mb-3 (further reduced)
                  _buildAuditLogTimeline(),
                  SizedBox(height: TailwindSpacing.mb3), // mb-3 (further reduced)
                  _buildComplianceNotice(),
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
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppTheme.gray200)),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: TailwindSpacing.p4, // p-4 (further reduced)
          vertical: TailwindSpacing.p3, // p-3 (further reduced)
        ),
        child: Column(
          children: [
            TextButton.icon(
              onPressed: onBack,
              icon: SvgIcons.chevronLeft(size: 16, color: AppTheme.blue600),
              label: const Text(
                'Back to Patient Overview',
                style: TextStyle(
                  fontSize: TailwindFontSize.textSm, // text-sm = 14px
                  fontWeight: FontWeight.w500, // font-medium
                  height: 1.5,
                  letterSpacing: 0,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.blue600,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            SizedBox(height: TailwindSpacing.mb4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Clinical Audit Log',
                        style: TextStyle(
                          fontSize: TailwindFontSize.text2xl,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.gray900,
                        ),
                      ),
                      SizedBox(height: TailwindSpacing.mb2),
                      const Text(
                        'Immutable, read-only record of all AI outputs, doctor actions, and clinical decisions for compliance and transparency.',
                        style: TextStyle(
                          fontSize: TailwindFontSize.textSm,
                          color: AppTheme.gray600,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Patient',
                      style: TextStyle(
                        fontSize: TailwindFontSize.textSm,
                        color: AppTheme.gray500,
                      ),
                    ),
                    SizedBox(height: TailwindSpacing.mb1),
                    Text(
                      patient.name,
                      style: const TextStyle(
                        fontSize: TailwindFontSize.textSm,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.gray900,
                      ),
                    ),
                    Text(
                      patient.twinId,
                      style: const TextStyle(
                        fontSize: TailwindFontSize.textSm,
                        color: AppTheme.gray600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(TailwindSpacing.p4),
      decoration: BoxDecoration(
        color: AppTheme.blue50,
        border: Border.all(color: AppTheme.blue200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.shield, size: 20, color: AppTheme.blue600),
          SizedBox(width: TailwindSpacing.gap3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Immutable Audit Trail',
                  style: TextStyle(
                    fontSize: TailwindFontSize.textSm,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.blue900,
                  ),
                ),
                SizedBox(height: TailwindSpacing.mb1),
                const Text(
                  'All entries are read-only and permanently stored for compliance, quality assurance, and medico-legal purposes. Each action is timestamped and attributed to the responsible party.',
                  style: TextStyle(
                    fontSize: TailwindFontSize.textSm,
                    color: AppTheme.blue800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    final aiOutputs = _auditLog.where((e) =>
        e['type'] == 'AI Output' || e['type'] == 'Background Evaluation').length;
    final doctorEdits = _auditLog.where((e) => e['type'] == 'Doctor Edit').length;
    final finalDecisions = _auditLog.where((e) => e['type'] == 'Final Decision').length;

    return Row(
      children: [
        Expanded(
          child: Container(
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
                  'Total Entries',
                  style: TextStyle(
                    fontSize: TailwindFontSize.textSm,
                    color: AppTheme.gray500,
                  ),
                ),
                SizedBox(height: TailwindSpacing.mb1),
                Text(
                  '${_auditLog.length}',
                  style: const TextStyle(
                    fontSize: TailwindFontSize.text2xl,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.gray900,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: TailwindSpacing.gap4),
        Expanded(
          child: Container(
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
                  'AI Outputs',
                  style: TextStyle(
                    fontSize: TailwindFontSize.textSm,
                    color: AppTheme.gray500,
                  ),
                ),
                SizedBox(height: TailwindSpacing.mb1),
                Text(
                  '$aiOutputs',
                  style: const TextStyle(
                    fontSize: TailwindFontSize.text2xl,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.purple600,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: TailwindSpacing.gap4),
        Expanded(
          child: Container(
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
                  'Doctor Edits',
                  style: TextStyle(
                    fontSize: TailwindFontSize.textSm,
                    color: AppTheme.gray500,
                  ),
                ),
                SizedBox(height: TailwindSpacing.mb1),
                Text(
                  '$doctorEdits',
                  style: const TextStyle(
                    fontSize: TailwindFontSize.text2xl,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.blue600,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: TailwindSpacing.gap4),
        Expanded(
          child: Container(
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
                  'Final Decisions',
                  style: TextStyle(
                    fontSize: TailwindFontSize.textSm,
                    color: AppTheme.gray500,
                  ),
                ),
                SizedBox(height: TailwindSpacing.mb1),
                Text(
                  '$finalDecisions',
                  style: const TextStyle(
                    fontSize: TailwindFontSize.text2xl,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.green600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAuditLogTimeline() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.gray200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: TailwindSpacing.p6,
              vertical: TailwindSpacing.p4,
            ),
            decoration: const BoxDecoration(
              color: AppTheme.gray50,
              border: Border(bottom: BorderSide(color: AppTheme.gray200)),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Chronological Audit Log',
                  style: TextStyle(
                    fontSize: TailwindFontSize.textLg,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.gray900,
                  ),
                ),
                Row(
                  children: [
                    const Icon(LucideIcons.lock, size: 16, color: AppTheme.gray600),
                    SizedBox(width: TailwindSpacing.gap2),
                    const Text(
                      'Read-only',
                      style: TextStyle(
                        fontSize: TailwindFontSize.textSm,
                        color: AppTheme.gray600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ..._auditLog.asMap().entries.map((entry) {
            final index = entry.key;
            final logEntry = entry.value;
            final isLast = index == _auditLog.length - 1;

            return Container(
              padding: const EdgeInsets.all(TailwindSpacing.p6),
              decoration: BoxDecoration(
                border: Border(
                  bottom: isLast
                      ? BorderSide.none
                      : const BorderSide(color: AppTheme.gray200),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _getEntryTypeColor(logEntry['type'] as String).bg,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getEntryTypeIcon(logEntry['type'] as String),
                          size: 20,
                          color: _getEntryTypeColor(logEntry['type'] as String).icon,
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 40,
                          margin: const EdgeInsets.only(top: 8),
                          color: AppTheme.gray200,
                        ),
                    ],
                  ),
                  SizedBox(width: TailwindSpacing.gap4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: TailwindSpacing.p2,
                                    vertical: TailwindSpacing.p1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getEntryTypeColor(logEntry['type'] as String).badge,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    logEntry['type'] as String,
                                    style: TextStyle(
                                      fontSize: TailwindFontSize.textXs,
                                      fontWeight: FontWeight.w600,
                                      color: _getEntryTypeColor(logEntry['type'] as String).text,
                                    ),
                                  ),
                                ),
                                SizedBox(width: TailwindSpacing.gap3),
                                Text(
                                  logEntry['action'] as String,
                                  style: const TextStyle(
                                    fontSize: TailwindFontSize.textSm,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.gray900,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(LucideIcons.clock, size: 16, color: AppTheme.gray500), // w-4 h-4 = 16px
                                SizedBox(width: 4),
                                Text(
                                  logEntry['timestamp'] as String,
                                  style: const TextStyle(
                                    fontSize: TailwindFontSize.textSm,
                                    color: AppTheme.gray500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: TailwindSpacing.mb2),
                        Text(
                          '${logEntry['actor']}${logEntry['modelVersion'] != null ? ' • ${logEntry['modelVersion']}' : ''}',
                          style: const TextStyle(
                            fontSize: TailwindFontSize.textSm,
                            color: AppTheme.gray600,
                          ),
                        ),
                        SizedBox(height: TailwindSpacing.mb3),
                        Container(
                          padding: const EdgeInsets.all(TailwindSpacing.p3),
                          decoration: BoxDecoration(
                            color: AppTheme.gray50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            logEntry['details'] as String,
                            style: const TextStyle(
                              fontSize: TailwindFontSize.textSm,
                              color: AppTheme.gray700,
                            ),
                          ),
                        ),
                        SizedBox(height: TailwindSpacing.mb3),
                        Row(
                          children: [
                            const Text(
                              'Risk Tier:',
                              style: TextStyle(
                                fontSize: TailwindFontSize.textXs,
                                color: AppTheme.gray500,
                              ),
                            ),
                            SizedBox(width: TailwindSpacing.gap2),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: TailwindSpacing.p2,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getRiskTierColor(logEntry['riskTier'] as RiskTier).bg,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _riskTierToString(logEntry['riskTier'] as RiskTier),
                                style: TextStyle(
                                  fontSize: TailwindFontSize.textXs,
                                  fontWeight: FontWeight.w600,
                                  color: _getRiskTierColor(logEntry['riskTier'] as RiskTier).text,
                                ),
                              ),
                            ),
                            if (logEntry['evaluationId'] != null) ...[
                              SizedBox(width: TailwindSpacing.gap4),
                              const Text(
                                'Evaluation ID:',
                                style: TextStyle(
                                  fontSize: TailwindFontSize.textXs,
                                  color: AppTheme.gray500,
                                ),
                              ),
                              SizedBox(width: TailwindSpacing.gap2),
                              Text(
                                logEntry['evaluationId'] as String,
                                style: const TextStyle(
                                  fontSize: TailwindFontSize.textXs,
                                  fontFamily: 'monospace',
                                  color: AppTheme.gray700,
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (logEntry['linkedReferences'] != null &&
                            (logEntry['linkedReferences'] as List).isNotEmpty) ...[
                          SizedBox(height: TailwindSpacing.mb3),
                          Wrap(
                            spacing: TailwindSpacing.gap2,
                            runSpacing: TailwindSpacing.gap2,
                            children: (logEntry['linkedReferences'] as List).map<Widget>((ref) {
                              return TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                  backgroundColor: AppTheme.blue50,
                                  foregroundColor: AppTheme.blue600,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8, // px-2 = 8px
                                    vertical: 4, // py-1 = 4px
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  textStyle: const TextStyle(
                                    fontSize: TailwindFontSize.textXs, // text-xs = 12px
                                    fontWeight: FontWeight.w500, // font-medium
                                    height: 1.5,
                                    letterSpacing: 0,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getReferenceTypeColor(ref['type']).bg,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        ref['type'],
                                        style: TextStyle(
                                          fontSize: TailwindFontSize.textXs,
                                          fontWeight: FontWeight.w600,
                                          color: _getReferenceTypeColor(ref['type']).text,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: TailwindSpacing.gap1),
                                    Text(ref['label']),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildComplianceNotice() {
    return Container(
      padding: const EdgeInsets.all(TailwindSpacing.p4),
      decoration: BoxDecoration(
        color: AppTheme.gray50,
        border: Border.all(color: AppTheme.gray200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.lock, size: 16, color: AppTheme.gray500),
          SizedBox(width: TailwindSpacing.gap2),
          Expanded(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: TailwindFontSize.textSm,
                  color: AppTheme.gray700,
                ),
                children: [
                  TextSpan(
                    text: 'Compliance & Data Integrity: ',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(
                    text: 'This audit log is maintained in accordance with HIPAA, 21 CFR Part 11, and institutional clinical documentation requirements. All entries are cryptographically signed and tamper-evident.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _riskTierToString(RiskTier tier) {
    switch (tier) {
      case RiskTier.high:
        return 'High';
      case RiskTier.medium:
        return 'Medium';
      case RiskTier.low:
        return 'Low';
    }
  }

  ({Color bg, Color icon, Color badge, Color text}) _getEntryTypeColor(String type) {
    switch (type) {
      case 'AI Output':
      case 'Background Evaluation':
        return (
          bg: AppTheme.purple100,
          icon: AppTheme.purple600,
          badge: AppTheme.purple100,
          text: AppTheme.purple700
        );
      case 'Doctor Edit':
        return (
          bg: AppTheme.blue100,
          icon: AppTheme.blue600,
          badge: AppTheme.blue100,
          text: AppTheme.blue700
        );
      case 'Final Decision':
        return (
          bg: AppTheme.green100,
          icon: AppTheme.green600,
          badge: AppTheme.green100,
          text: AppTheme.green700
        );
      default:
        return (
          bg: AppTheme.gray100,
          icon: AppTheme.gray600,
          badge: AppTheme.gray200,
          text: AppTheme.gray700
        );
    }
  }

  IconData _getEntryTypeIcon(String type) {
    switch (type) {
      case 'AI Output':
      case 'Background Evaluation':
        return LucideIcons.brain;
      case 'Doctor Edit':
        return LucideIcons.fileText;
      case 'Final Decision':
        return LucideIcons.user;
      default:
        return LucideIcons.alertCircle;
    }
  }

  ({Color bg, Color text}) _getRiskTierColor(RiskTier tier) {
    switch (tier) {
      case RiskTier.high:
        return (bg: AppTheme.red100, text: AppTheme.red700);
      case RiskTier.medium:
        return (bg: AppTheme.amber100, text: AppTheme.amber700);
      case RiskTier.low:
        return (bg: AppTheme.green100, text: AppTheme.green700);
    }
  }

  ({Color bg, Color text}) _getReferenceTypeColor(String type) {
    switch (type) {
      case 'visit':
        return (bg: AppTheme.blue200, text: AppTheme.blue800);
      case 'analysis':
        return (bg: AppTheme.purple200, text: AppTheme.purple800);
      case 'decision':
        return (bg: AppTheme.green200, text: AppTheme.green800);
      default:
        return (bg: AppTheme.gray200, text: AppTheme.gray800);
    }
  }
}
