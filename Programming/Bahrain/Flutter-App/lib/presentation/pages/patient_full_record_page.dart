import 'package:flutter/material.dart';
import '../../domain/entities/patient.dart';
import '../../domain/value_objects/risk_tier.dart';
import '../widgets/risk_badge.dart';
import '../theme/app_theme.dart';
import '../theme/tailwind_spacing.dart';
import '../utils/lucide_icons.dart';
import '../utils/svg_icons.dart';

class PatientFullRecordPage extends StatefulWidget {
  final Patient patient;
  final VoidCallback onBack;

  const PatientFullRecordPage({
    super.key,
    required this.patient,
    required this.onBack,
  });

  @override
  State<PatientFullRecordPage> createState() => _PatientFullRecordPageState();
}

class _PatientFullRecordPageState extends State<PatientFullRecordPage> {
  final Set<String> _expandedVisits = {'visit-1'};

  final List<Map<String, dynamic>> _visitHistory = [
    {
      'id': 'visit-1',
      'date': 'Jan 8, 2026',
      'type': 'Manual',
      'status': 'Completed',
      'aiAnalysis': {
        'riskTier': RiskTier.high,
        'reasoning': [
          'Multiple high-risk comorbidities detected',
          'Elevated blood pressure above target range',
          'Medication interaction risk identified'
        ],
        'model': 'ClinicalAI v3.2.1',
        'timestamp': 'Jan 8, 2026 10:45 AM'
      },
      'doctorDecision': {
        'riskTier': RiskTier.high,
        'doctor': 'Dr. Rebecca Smith',
        'notes': 'Concur with AI assessment. Adjusting medication dosage and scheduling follow-up in 2 weeks.',
        'timestamp': 'Jan 8, 2026 11:15 AM'
      },
      'outcome': {
        'type': 'Follow-up Scheduled',
        'details': 'Follow-up visit scheduled for Jan 22, 2026'
      }
    },
    {
      'id': 'visit-2',
      'date': 'Jan 6, 2026',
      'type': 'Background',
      'status': 'Completed',
      'aiAnalysis': {
        'riskTier': RiskTier.high,
        'reasoning': [
          'Persistent elevated blood pressure readings',
          'Lab results indicate declining renal function'
        ],
        'model': 'ClinicalAI v3.2.1',
        'timestamp': 'Jan 6, 2026 3:00 PM'
      },
      'doctorDecision': {
        'riskTier': RiskTier.high,
        'doctor': 'Dr. Rebecca Smith',
        'notes': 'Reviewed background analysis. Patient informed of lab results. Continuing current treatment plan.',
        'timestamp': 'Jan 6, 2026 3:30 PM'
      },
      'outcome': {
        'type': 'Continue Monitoring',
        'details': 'Continue background monitoring'
      }
    },
    {
      'id': 'visit-3',
      'date': 'Dec 28, 2025',
      'type': 'Follow-up',
      'status': 'Completed',
      'aiAnalysis': {
        'riskTier': RiskTier.medium,
        'reasoning': [
          'Blood pressure slightly above target',
          'Medication adherence appears good'
        ],
        'model': 'ClinicalAI v3.2.0',
        'timestamp': 'Dec 28, 2025 9:15 AM'
      },
      'doctorDecision': {
        'riskTier': RiskTier.high,
        'doctor': 'Dr. James Chen',
        'notes': 'Upgrading risk tier due to patient history. Increasing monitoring frequency.',
        'timestamp': 'Dec 28, 2025 9:45 AM'
      },
      'outcome': {
        'type': 'Follow-up Scheduled',
        'details': 'Follow-up in 2 weeks'
      }
    }
  ];

  final List<Map<String, dynamic>> _discussions = [
    {
      'id': 'disc-1',
      'visitId': 'visit-1',
      'doctor': 'Dr. Rebecca Smith',
      'timestamp': 'Jan 8, 2026 11:20 AM',
      'message': 'Adjusted medication dosage based on latest labs. Monitoring renal function closely.',
      'type': 'clinical-note'
    },
    {
      'id': 'disc-2',
      'visitId': 'visit-2',
      'doctor': 'Dr. Rebecca Smith',
      'timestamp': 'Jan 6, 2026 3:35 PM',
      'message': 'Patient reports feeling well despite lab results. Discussed importance of medication adherence.',
      'type': 'clinical-note'
    },
  ];

  final List<Map<String, dynamic>> _alarms = [
    {
      'id': 'alarm-1',
      'visitId': 'visit-1',
      'timestamp': 'Jan 8, 2026 10:45 AM',
      'severity': 'High',
      'type': 'AI-Triggered',
      'description': 'Critical drug interaction detected: Current medications may affect renal function',
      'status': 'Acknowledged',
      'acknowledgedBy': 'Dr. Rebecca Smith',
      'acknowledgedAt': 'Jan 8, 2026 11:15 AM'
    },
    {
      'id': 'alarm-2',
      'visitId': 'visit-2',
      'timestamp': 'Jan 6, 2026 3:00 PM',
      'severity': 'Medium',
      'type': 'AI-Triggered',
      'description': 'Elevated blood pressure trend detected over 7-day period',
      'status': 'Acknowledged',
      'acknowledgedBy': 'Dr. Rebecca Smith',
      'acknowledgedAt': 'Jan 6, 2026 3:30 PM'
    }
  ];

  final List<Map<String, dynamic>> _auditLog = [
    {
      'id': 'audit-1',
      'timestamp': 'Jan 8, 2026 11:15 AM',
      'action': 'Approved Clinical Decision',
      'actor': 'Dr. Rebecca Smith',
      'actorType': 'Doctor',
      'details': 'Approved final risk tier: High. Modified treatment plan.',
      'visitId': 'visit-1'
    },
    {
      'id': 'audit-2',
      'timestamp': 'Jan 8, 2026 10:45 AM',
      'action': 'Generated Risk Assessment',
      'actor': 'ClinicalAI v3.2.1',
      'actorType': 'AI',
      'details': 'AI analysis completed. Recommended risk tier: High',
      'visitId': 'visit-1'
    },
  ];

  void _toggleVisit(String visitId) {
    setState(() {
      if (_expandedVisits.contains(visitId)) {
        _expandedVisits.remove(visitId);
      } else {
        _expandedVisits.add(visitId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.gray50,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: TailwindSpacing.p4, // p-4 (further reduced)
                vertical: TailwindSpacing.p3, // p-3 (further reduced)
              ),
              child: Column(
                children: [
                  _buildPatientSnapshot(),
                  SizedBox(height: TailwindSpacing.mb3), // mb-3 (further reduced)
                  _buildVisitTimeline(),
                  SizedBox(height: TailwindSpacing.mb3), // mb-3 (further reduced)
                  _buildClinicalDiscussionLog(),
                  SizedBox(height: TailwindSpacing.mb3), // mb-3 (further reduced)
                  _buildAlarmsHistory(),
                  SizedBox(height: TailwindSpacing.mb3), // mb-3 (further reduced)
                  _buildAuditLog(),
                  SizedBox(height: TailwindSpacing.mb3), // mb-3 (further reduced)
                  _buildDisclaimer(),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: TailwindSpacing.p8,
          vertical: TailwindSpacing.p4,
        ),
        child: Column(
          children: [
            TextButton(
              onPressed: widget.onBack,
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.blue600,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgIcons.chevronLeft(size: 16, color: AppTheme.blue600),
                  SizedBox(width: TailwindSpacing.gap1),
                  const Text(
                    'Back to Active Visit',
                    style: TextStyle(
                      fontSize: TailwindFontSize.textSm, // text-sm = 14px
                      fontWeight: FontWeight.w500, // font-medium
                      color: AppTheme.blue600,
                      height: 1.5,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: TailwindSpacing.mb3),
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
                          fontSize: TailwindFontSize.text2xl,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.gray900,
                        ),
                      ),
                      SizedBox(height: TailwindSpacing.mb1),
                      Text(
                        '${widget.patient.age} years • ${widget.patient.sex} • Twin ID: ${widget.patient.twinId}',
                        style: const TextStyle(
                          fontSize: TailwindFontSize.textBase,
                          color: AppTheme.gray600,
                        ),
                      ),
                      SizedBox(height: TailwindSpacing.mb2),
                      Row(
                        children: [
                          Wrap(
                            spacing: TailwindSpacing.gap2,
                            runSpacing: TailwindSpacing.gap2,
                            children: widget.patient.cohort.map((c) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: TailwindSpacing.p2,
                                  vertical: TailwindSpacing.p1,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.blue50,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  c,
                                  style: const TextStyle(
                                    fontSize: TailwindFontSize.textXs,
                                    color: AppTheme.blue700,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          SizedBox(width: TailwindSpacing.gap3),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: TailwindSpacing.p3,
                              vertical: TailwindSpacing.p1,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.amber50,
                              border: Border.all(color: AppTheme.amber200),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Record View (Read-Only)',
                              style: TextStyle(
                                fontSize: TailwindFontSize.textXs,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.amber700,
                              ),
                            ),
                          ),
                        ],
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
                        fontSize: TailwindFontSize.textSm,
                        color: AppTheme.gray500,
                      ),
                    ),
                    SizedBox(height: TailwindSpacing.mb2),
                    RiskBadge(tier: widget.patient.riskTier, size: BadgeSize.lg),
                    SizedBox(height: TailwindSpacing.mt2),
                    Text(
                      'Last updated: ${widget.patient.lastEvaluation}',
                      style: const TextStyle(
                        fontSize: TailwindFontSize.textXs,
                        color: AppTheme.gray500,
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

  Widget _buildPatientSnapshot() {
    return Container(
      padding: const EdgeInsets.all(TailwindSpacing.p3), // p-3 (further reduced)
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.gray200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.activity, size: 20, color: AppTheme.blue600),
              SizedBox(width: TailwindSpacing.gap2),
              const Text(
                'Patient Snapshot',
                style: TextStyle(
                  fontSize: TailwindFontSize.textLg,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.gray900,
                ),
              ),
              SizedBox(width: TailwindSpacing.gap2),
              const Text(
                '(Current Status)',
                style: TextStyle(
                  fontSize: TailwindFontSize.textXs,
                  color: AppTheme.gray500,
                ),
              ),
            ],
          ),
          SizedBox(height: TailwindSpacing.mb4),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Key Conditions',
                      style: TextStyle(
                        fontSize: TailwindFontSize.textSm,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.gray700,
                      ),
                    ),
                    SizedBox(height: TailwindSpacing.mb3),
                    ...widget.patient.conditions.map((condition) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: TailwindSpacing.gap2),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              margin: EdgeInsets.only(
                                top: 6,
                                right: TailwindSpacing.gap2,
                              ),
                              decoration: const BoxDecoration(
                                color: AppTheme.purple600,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                condition,
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
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Medications',
                      style: TextStyle(
                        fontSize: TailwindFontSize.textSm,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.gray700,
                      ),
                    ),
                    SizedBox(height: TailwindSpacing.mb3),
                    ...widget.patient.medications.map((med) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: TailwindSpacing.gap2),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              margin: EdgeInsets.only(
                                top: 6,
                                right: TailwindSpacing.gap2,
                              ),
                              decoration: const BoxDecoration(
                                color: AppTheme.blue600,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                med,
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
                  ],
                ),
              ),
              if (widget.patient.vitals != null)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Latest Vitals',
                        style: TextStyle(
                          fontSize: TailwindFontSize.textSm,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.gray700,
                        ),
                      ),
                      const SizedBox(height: 12), // mb-3 = 12px
                      // Each vital in its own container, separated by space-y-2 (matching React)
                      Column(
                        children: [
                          _buildVitalContainer('Blood Pressure', '${widget.patient.vitals!.bloodPressure} mmHg'),
                          const SizedBox(height: 8), // space-y-2 = 8px
                          _buildVitalContainer('Heart Rate', '${widget.patient.vitals!.heartRate} bpm'),
                          const SizedBox(height: 8), // space-y-2 = 8px
                          _buildVitalContainer('Temperature', widget.patient.vitals!.temperature),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: TailwindSpacing.mb4),
          Container(
            padding: const EdgeInsets.all(TailwindSpacing.p3),
            decoration: BoxDecoration(
              color: AppTheme.blue50,
              border: Border.all(color: AppTheme.blue200),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.clock, size: 16, color: AppTheme.blue600),
                SizedBox(width: TailwindSpacing.gap2),
                const Text(
                  'Last Data Sync:',
                  style: TextStyle(
                    fontSize: TailwindFontSize.textSm,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.blue900,
                  ),
                ),
                SizedBox(width: TailwindSpacing.gap2),
                const Text(
                  'Jan 8, 2026 08:30 AM',
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

  Widget _buildVisitTimeline() {
    return Container(
      padding: const EdgeInsets.all(TailwindSpacing.p3), // p-3 (further reduced)
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.gray200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.calendar, size: 20, color: AppTheme.blue600),
              SizedBox(width: TailwindSpacing.gap2),
              const Text(
                'Visit Timeline',
                style: TextStyle(
                  fontSize: TailwindFontSize.textLg,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.gray900,
                ),
              ),
              SizedBox(width: TailwindSpacing.gap2),
              const Text(
                '(Longitudinal History)',
                style: TextStyle(
                  fontSize: TailwindFontSize.textXs,
                  color: AppTheme.gray500,
                ),
              ),
            ],
          ),
          SizedBox(height: TailwindSpacing.mb4),
          ..._visitHistory.map((visit) {
            final isExpanded = _expandedVisits.contains(visit['id']);
            return Container(
              margin: EdgeInsets.only(bottom: TailwindSpacing.mb4),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.gray200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  InkWell(
                    onTap: () => _toggleVisit(visit['id']),
                    child: Container(
                      padding: const EdgeInsets.all(TailwindSpacing.p4),
                      decoration: const BoxDecoration(
                        color: AppTheme.gray50,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    visit['date'],
                                    style: const TextStyle(
                                      fontSize: TailwindFontSize.textSm,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.gray900,
                                    ),
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
                                          color: _getVisitTypeColor(visit['type']).bg,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          visit['type'],
                                          style: TextStyle(
                                            fontSize: TailwindFontSize.textXs,
                                            color: _getVisitTypeColor(visit['type']).text,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: TailwindSpacing.gap2),
                                      Text(
                                        '• ${visit['status']}',
                                        style: const TextStyle(
                                          fontSize: TailwindFontSize.textXs,
                                          color: AppTheme.gray500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(width: 32),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Final Risk Tier',
                                    style: TextStyle(
                                      fontSize: TailwindFontSize.textXs,
                                      color: AppTheme.gray500,
                                    ),
                                  ),
                                  SizedBox(height: TailwindSpacing.mb1),
                                  RiskBadge(
                                    tier: visit['doctorDecision']['riskTier'] as RiskTier,
                                    size: BadgeSize.sm,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Icon(
                            isExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                            size: 20,
                            color: AppTheme.gray400,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isExpanded) _buildExpandedVisitDetails(visit),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildExpandedVisitDetails(Map<String, dynamic> visit) {
    return Container(
      padding: const EdgeInsets.all(TailwindSpacing.p4),
      child: Column(
        children: [
          _buildAIAnalysisCard(visit['aiAnalysis']),
          SizedBox(height: TailwindSpacing.mb4),
          _buildDoctorDecisionCard(visit['doctorDecision']),
          SizedBox(height: TailwindSpacing.mb4),
          _buildOutcomeCard(visit['outcome']),
        ],
      ),
    );
  }

  Widget _buildAIAnalysisCard(Map<String, dynamic> aiAnalysis) {
    return Container(
      padding: const EdgeInsets.all(TailwindSpacing.p4),
      decoration: BoxDecoration(
        color: AppTheme.purple50,
        border: Border.all(color: AppTheme.purple200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.brain, size: 16, color: AppTheme.purple600),
              SizedBox(width: TailwindSpacing.gap2),
              const Text(
                'AI Analysis',
                style: TextStyle(
                  fontSize: TailwindFontSize.textSm,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.purple900,
                ),
              ),
            ],
          ),
          SizedBox(height: TailwindSpacing.mb3),
          const Text(
            'AI Recommended Risk Tier',
            style: TextStyle(
              fontSize: TailwindFontSize.textXs,
              color: AppTheme.purple700,
            ),
          ),
          SizedBox(height: TailwindSpacing.mb2),
          RiskBadge(
            tier: aiAnalysis['riskTier'] as RiskTier,
            size: BadgeSize.sm,
          ),
          SizedBox(height: TailwindSpacing.mb3),
          const Text(
            'Key Reasons',
            style: TextStyle(
              fontSize: TailwindFontSize.textXs,
              color: AppTheme.purple700,
            ),
          ),
          SizedBox(height: TailwindSpacing.mb2),
          ...(aiAnalysis['reasoning'] as List).map<Widget>((reason) {
            return Padding(
              padding: EdgeInsets.only(bottom: TailwindSpacing.gap1),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: EdgeInsets.only(
                      top: 6,
                      right: TailwindSpacing.gap2,
                    ),
                    decoration: const BoxDecoration(
                      color: AppTheme.purple600,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      reason,
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
          SizedBox(height: TailwindSpacing.mb3),
          Text(
            '${aiAnalysis['model']} • ${aiAnalysis['timestamp']}',
            style: const TextStyle(
              fontSize: TailwindFontSize.textXs,
              color: AppTheme.purple600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorDecisionCard(Map<String, dynamic> doctorDecision) {
    return Container(
      padding: const EdgeInsets.all(TailwindSpacing.p4),
      decoration: BoxDecoration(
        color: AppTheme.blue50,
        border: Border.all(color: AppTheme.blue200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.user, size: 16, color: AppTheme.blue600),
              SizedBox(width: TailwindSpacing.gap2),
              const Text(
                'Doctor Final Decision',
                style: TextStyle(
                  fontSize: TailwindFontSize.textSm,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.blue900,
                ),
              ),
            ],
          ),
          SizedBox(height: TailwindSpacing.mb3),
          const Text(
            'Final Risk Tier',
            style: TextStyle(
              fontSize: TailwindFontSize.textXs,
              color: AppTheme.blue700,
            ),
          ),
          SizedBox(height: TailwindSpacing.mb2),
          RiskBadge(
            tier: doctorDecision['riskTier'] as RiskTier,
            size: BadgeSize.sm,
          ),
          SizedBox(height: TailwindSpacing.mb3),
          const Text(
            'Clinical Notes',
            style: TextStyle(
              fontSize: TailwindFontSize.textXs,
              color: AppTheme.blue700,
            ),
          ),
          SizedBox(height: TailwindSpacing.mb2),
          Text(
            doctorDecision['notes'],
            style: const TextStyle(
              fontSize: TailwindFontSize.textSm,
              color: AppTheme.gray700,
            ),
          ),
          SizedBox(height: TailwindSpacing.mb3),
          Text(
            '${doctorDecision['doctor']} • ${doctorDecision['timestamp']}',
            style: const TextStyle(
              fontSize: TailwindFontSize.textXs,
              color: AppTheme.blue600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutcomeCard(Map<String, dynamic> outcome) {
    return Container(
      padding: const EdgeInsets.all(TailwindSpacing.p4),
      decoration: BoxDecoration(
        color: AppTheme.green50,
        border: Border.all(color: AppTheme.green200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.fileCheck, size: 16, color: AppTheme.green600),
          SizedBox(width: TailwindSpacing.gap2),
          Expanded(
            child: Text(
              '${outcome['type']}: ${outcome['details']}',
              style: const TextStyle(
                fontSize: TailwindFontSize.textSm,
                fontWeight: FontWeight.w600,
                color: AppTheme.green900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClinicalDiscussionLog() {
    return Container(
      padding: const EdgeInsets.all(TailwindSpacing.p3), // p-3 (further reduced)
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.gray200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.messageSquare, size: 20, color: AppTheme.blue600),
              SizedBox(width: TailwindSpacing.gap2),
              const Text(
                'Clinical Discussion Log',
                style: TextStyle(
                  fontSize: TailwindFontSize.textLg,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.gray900,
                ),
              ),
              SizedBox(width: TailwindSpacing.gap2),
              const Text(
                '(AI ↔ Doctor Conversations)',
                style: TextStyle(
                  fontSize: TailwindFontSize.textXs,
                  color: AppTheme.gray500,
                ),
              ),
            ],
          ),
          SizedBox(height: TailwindSpacing.mb4),
          ..._discussions.map((disc) {
            final isAI = disc['type'].toString().startsWith('ai');
            return Container(
              margin: EdgeInsets.only(bottom: TailwindSpacing.mb3),
              padding: const EdgeInsets.all(TailwindSpacing.p4),
              decoration: BoxDecoration(
                color: isAI ? AppTheme.purple50 : AppTheme.blue50,
                border: Border.all(
                  color: isAI ? AppTheme.purple200 : AppTheme.blue200,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isAI ? AppTheme.purple200 : AppTheme.blue200,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isAI ? LucideIcons.brain : LucideIcons.user,
                      size: 16,
                      color: isAI ? AppTheme.purple700 : AppTheme.blue700,
                    ),
                  ),
                  SizedBox(width: TailwindSpacing.gap3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              disc['doctor'],
                              style: const TextStyle(
                                fontSize: TailwindFontSize.textSm,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.gray900,
                              ),
                            ),
                            SizedBox(width: TailwindSpacing.gap2),
                            Text(
                              disc['timestamp'],
                              style: const TextStyle(
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
                                color: AppTheme.gray200,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Visit: ${disc['visitId']}',
                                style: const TextStyle(
                                  fontSize: TailwindFontSize.textXs,
                                  color: AppTheme.gray600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: TailwindSpacing.mb1),
                        Text(
                          disc['message'],
                          style: const TextStyle(
                            fontSize: TailwindFontSize.textSm,
                            color: AppTheme.gray700,
                          ),
                        ),
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

  Widget _buildAlarmsHistory() {
    return Container(
      padding: const EdgeInsets.all(TailwindSpacing.p3), // p-3 (further reduced)
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.gray200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.alertTriangle, size: 20, color: AppTheme.amber600),
              SizedBox(width: TailwindSpacing.gap2),
              const Text(
                'Alarms History',
                style: TextStyle(
                  fontSize: TailwindFontSize.textLg,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.gray900,
                ),
              ),
              SizedBox(width: TailwindSpacing.gap2),
              const Text(
                '(All Alerts)',
                style: TextStyle(
                  fontSize: TailwindFontSize.textXs,
                  color: AppTheme.gray500,
                ),
              ),
            ],
          ),
          SizedBox(height: TailwindSpacing.mb4),
          ..._alarms.map((alarm) {
            final severity = alarm['severity'] as String;
            return Container(
              margin: EdgeInsets.only(bottom: TailwindSpacing.mb3),
              padding: const EdgeInsets.all(TailwindSpacing.p4),
              decoration: BoxDecoration(
                color: _getSeverityColor(severity).bg,
                border: Border.all(color: _getSeverityColor(severity).border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Wrap(
                        spacing: TailwindSpacing.gap2,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: TailwindSpacing.p2,
                              vertical: TailwindSpacing.p1,
                            ),
                            decoration: BoxDecoration(
                              color: _getSeverityColor(severity).badge,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              severity,
                              style: TextStyle(
                                fontSize: TailwindFontSize.textXs,
                                fontWeight: FontWeight.w600,
                                color: _getSeverityColor(severity).text,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: TailwindSpacing.p2,
                              vertical: TailwindSpacing.p1,
                            ),
                            decoration: BoxDecoration(
                              color: alarm['type'] == 'AI-Triggered'
                                  ? AppTheme.purple100
                                  : AppTheme.gray200,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              alarm['type'],
                              style: TextStyle(
                                fontSize: TailwindFontSize.textXs,
                                color: alarm['type'] == 'AI-Triggered'
                                    ? AppTheme.purple700
                                    : AppTheme.gray700,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: TailwindSpacing.p2,
                              vertical: TailwindSpacing.p1,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(alarm['status']).bg,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              alarm['status'],
                              style: TextStyle(
                                fontSize: TailwindFontSize.textXs,
                                fontWeight: FontWeight.w600,
                                color: _getStatusColor(alarm['status']).text,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        alarm['timestamp'],
                        style: const TextStyle(
                          fontSize: TailwindFontSize.textXs,
                          color: AppTheme.gray500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: TailwindSpacing.mb2),
                  Text(
                    alarm['description'],
                    style: const TextStyle(
                      fontSize: TailwindFontSize.textSm,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.gray900,
                    ),
                  ),
                  if (alarm['acknowledgedBy'] != null) ...[
                    SizedBox(height: TailwindSpacing.mb1),
                    Text(
                      'Acknowledged by ${alarm['acknowledgedBy']} at ${alarm['acknowledgedAt']}',
                      style: const TextStyle(
                        fontSize: TailwindFontSize.textXs,
                        color: AppTheme.gray600,
                      ),
                    ),
                  ],
                  SizedBox(height: TailwindSpacing.mt1),
                  Text(
                    'Related to: ${alarm['visitId']}',
                    style: const TextStyle(
                      fontSize: TailwindFontSize.textXs,
                      color: AppTheme.gray500,
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

  Widget _buildAuditLog() {
    return Container(
      padding: const EdgeInsets.all(TailwindSpacing.p3), // p-3 (further reduced)
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.gray200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.shield, size: 20, color: AppTheme.gray600),
              SizedBox(width: TailwindSpacing.gap2),
              const Text(
                'Audit Log',
                style: TextStyle(
                  fontSize: TailwindFontSize.textLg,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.gray900,
                ),
              ),
              SizedBox(width: TailwindSpacing.gap2),
              const Text(
                '(Immutable Compliance Record)',
                style: TextStyle(
                  fontSize: TailwindFontSize.textXs,
                  color: AppTheme.gray500,
                ),
              ),
            ],
          ),
          SizedBox(height: TailwindSpacing.mb4),
          ..._auditLog.map((entry) {
            return Container(
              margin: EdgeInsets.only(bottom: TailwindSpacing.mb2),
              padding: const EdgeInsets.all(TailwindSpacing.p3),
              decoration: BoxDecoration(
                color: AppTheme.gray50,
                border: Border.all(color: AppTheme.gray200),
                borderRadius: BorderRadius.circular(8),
              ),
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
                              color: _getActorTypeColor(entry['actorType']).bg,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              entry['actorType'],
                              style: TextStyle(
                                fontSize: TailwindFontSize.textXs,
                                fontWeight: FontWeight.w600,
                                color: _getActorTypeColor(entry['actorType']).text,
                              ),
                            ),
                          ),
                          SizedBox(width: TailwindSpacing.gap3),
                          Text(
                            entry['action'],
                            style: const TextStyle(
                              fontSize: TailwindFontSize.textSm,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.gray900,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        entry['timestamp'],
                        style: const TextStyle(
                          fontSize: TailwindFontSize.textXs,
                          color: AppTheme.gray500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: TailwindSpacing.mb1),
                  Text(
                    entry['details'],
                    style: const TextStyle(
                      fontSize: TailwindFontSize.textSm,
                      color: AppTheme.gray700,
                    ),
                  ),
                  SizedBox(height: TailwindSpacing.mt1),
                  Row(
                    children: [
                      Text(
                        'Actor: ${entry['actor']}',
                        style: const TextStyle(
                          fontSize: TailwindFontSize.textXs,
                          color: AppTheme.gray600,
                        ),
                      ),
                      if (entry['visitId'] != null) ...[
                        SizedBox(width: TailwindSpacing.gap3),
                        Text(
                          '• Visit: ${entry['visitId']}',
                          style: const TextStyle(
                            fontSize: TailwindFontSize.textXs,
                            color: AppTheme.gray600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(TailwindSpacing.p4),
      decoration: BoxDecoration(
        color: AppTheme.amber50,
        border: Border.all(color: AppTheme.amber200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'Read-Only Record View: This is a comprehensive longitudinal view of all patient data. '
        'No edits, decisions, or workflows can be initiated from this page. To perform clinical actions, return to the Active Visit view.',
        style: TextStyle(
          fontSize: TailwindFontSize.textSm,
          fontWeight: FontWeight.w600,
          color: AppTheme.amber900,
        ),
      ),
    );
  }

  ({Color bg, Color text}) _getVisitTypeColor(String type) {
    switch (type) {
      case 'Manual':
        return (bg: AppTheme.blue100, text: AppTheme.blue700);
      case 'Follow-up':
        return (bg: AppTheme.green100, text: AppTheme.green700);
      case 'Background':
        return (bg: AppTheme.purple100, text: AppTheme.purple700);
      default:
        return (bg: AppTheme.gray100, text: AppTheme.gray700);
    }
  }

  ({Color bg, Color border, Color badge, Color text}) _getSeverityColor(String severity) {
    switch (severity) {
      case 'High':
        return (
          bg: AppTheme.red50,
          border: AppTheme.red200,
          badge: AppTheme.red200,
          text: AppTheme.red800
        );
      case 'Medium':
        return (
          bg: AppTheme.amber50,
          border: AppTheme.amber200,
          badge: AppTheme.amber200,
          text: AppTheme.amber800
        );
      default:
        return (
          bg: AppTheme.amber50,
          border: AppTheme.amber200,
          badge: AppTheme.amber200,
          text: AppTheme.amber800
        );
    }
  }

  ({Color bg, Color text}) _getStatusColor(String status) {
    switch (status) {
      case 'Acknowledged':
        return (bg: AppTheme.green100, text: AppTheme.green700);
      case 'Resolved':
        return (bg: AppTheme.blue100, text: AppTheme.blue700);
      default:
        return (bg: AppTheme.red100, text: AppTheme.red700);
    }
  }

  ({Color bg, Color text}) _getActorTypeColor(String type) {
    switch (type) {
      case 'AI':
        return (bg: AppTheme.purple100, text: AppTheme.purple700);
      case 'Doctor':
        return (bg: AppTheme.blue100, text: AppTheme.blue700);
      default:
        return (bg: AppTheme.gray200, text: AppTheme.gray700);
    }
  }

  Widget _buildVitalContainer(String label, String value) {
    // Each vital in its own container, matching React app structure
    return Container(
      padding: const EdgeInsets.all(8), // p-2 = 8px
      decoration: BoxDecoration(
        color: AppTheme.gray50, // bg-gray-50
        borderRadius: BorderRadius.circular(4), // rounded
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: TailwindFontSize.textXs, // text-xs
              color: AppTheme.gray500, // text-gray-500
              height: 1.5,
            ),
          ),
          const SizedBox(height: 4), // mb-1 = 4px
          Text(
            value,
            style: const TextStyle(
              fontSize: TailwindFontSize.textSm, // text-sm
              fontWeight: FontWeight.w600, // font-medium
              color: AppTheme.gray900, // text-gray-900
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
