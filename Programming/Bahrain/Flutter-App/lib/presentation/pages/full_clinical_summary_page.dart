import 'package:flutter/material.dart';
import '../../domain/entities/patient.dart';
import '../widgets/risk_badge.dart';
import '../theme/app_theme.dart';
import '../theme/tailwind_spacing.dart';
import '../utils/lucide_icons.dart';
import '../utils/svg_icons.dart';

class FullClinicalSummaryPage extends StatelessWidget {
  final Patient patient;
  final VoidCallback onBack;

  const FullClinicalSummaryPage({
    super.key,
    required this.patient,
    required this.onBack,
  });

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
                vertical: TailwindSpacing.p4, // p-4 (further reduced)
              ),
              child: Column(
                children: [
                  _buildConditionsSection(),
                  SizedBox(height: TailwindSpacing.mb4), // mb-4 (further reduced)
                  _buildMedicationsSection(),
                  SizedBox(height: TailwindSpacing.mb4), // mb-4 (further reduced)
                  _buildVitalsSection(),
                  SizedBox(height: TailwindSpacing.mb4), // mb-4 (further reduced)
                  _buildClinicalNotesSection(),
                  SizedBox(height: TailwindSpacing.mb4), // mb-4 (further reduced)
                  _buildDataFreshnessSection(),
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
          horizontal: TailwindSpacing.p6,
          vertical: TailwindSpacing.p4,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: onBack,
                  icon: SvgIcons.arrowLeft(size: 20, color: AppTheme.gray600),
                  label: const Text(
                    'Back to Patient Overview',
                    style: TextStyle(
                      fontSize: TailwindFontSize.textSm, // text-sm = 14px
                      fontWeight: FontWeight.w500, // font-medium (reduced from w600)
                      height: 1.5,
                      letterSpacing: 0,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.gray600,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // px-3 py-1.5
                    minimumSize: const Size(0, 32), // h-8 = 32px
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: TailwindSpacing.p3,
                    vertical: TailwindSpacing.p1,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.blue50,
                    border: Border.all(color: AppTheme.blue200),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Clinical Summary (Read-only)',
                    style: TextStyle(
                      fontSize: TailwindFontSize.textXs,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.blue700,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: TailwindSpacing.mb3),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.name,
                      style: const TextStyle(
                        fontSize: TailwindFontSize.text2xl,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.gray900,
                      ),
                    ),
                    SizedBox(height: TailwindSpacing.mb1),
                    Row(
                      children: [
                        Text(
                          '${patient.age} years old',
                          style: const TextStyle(
                            fontSize: TailwindFontSize.textSm,
                            color: AppTheme.gray600,
                          ),
                        ),
                        SizedBox(width: TailwindSpacing.gap4),
                        const Text('•', style: TextStyle(color: AppTheme.gray600)),
                        SizedBox(width: TailwindSpacing.gap4),
                        Text(
                          patient.id,
                          style: const TextStyle(
                            fontSize: TailwindFontSize.textSm,
                            color: AppTheme.gray600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    RiskBadge(tier: patient.riskTier, size: BadgeSize.lg),
                    SizedBox(height: TailwindSpacing.mt2),
                    Row(
                      children: [
                        const Icon(LucideIcons.clock, size: 12, color: AppTheme.gray500),
                        SizedBox(width: TailwindSpacing.gap1),
                    Text(
                      'Last updated: ${DateTime.now().toString().substring(0, 16)}',
                      style: TextStyle(
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
          ],
        ),
      ),
    );
  }

  Widget _buildConditionsSection() {
    final conditions = [
      {
        'name': 'Type 2 Diabetes Mellitus',
        'status': 'Active',
        'severity': 'Chronic, well-controlled',
        'onsetDate': 'Mar 2022',
        'source': 'Manual Visit'
      },
      {
        'name': 'Hypertension (Stage 2)',
        'status': 'Active',
        'severity': 'Stage 2, requires monitoring',
        'onsetDate': 'Jan 2021',
        'source': 'Background Monitoring'
      },
      {
        'name': 'Chronic Kidney Disease (Stage 3)',
        'status': 'Active',
        'severity': 'Stage 3A (eGFR 45-59)',
        'onsetDate': 'Sep 2023',
        'source': 'Manual Visit'
      },
      {
        'name': 'Hyperlipidemia',
        'status': 'Active',
        'severity': 'Controlled with medication',
        'onsetDate': 'Jun 2020',
        'source': 'Manual Visit'
      },
      {
        'name': 'Atrial Fibrillation',
        'status': 'Resolved',
        'severity': 'Paroxysmal, cardioverted',
        'onsetDate': 'Jan 2021',
        'source': 'Manual Visit'
      }
    ];

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
              color: AppTheme.purple50,
              border: Border(bottom: BorderSide(color: AppTheme.purple100)),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.alertCircle, size: 20, color: AppTheme.purple600),
                SizedBox(width: TailwindSpacing.gap2),
                const Text(
                  'Conditions',
                  style: TextStyle(
                    fontSize: TailwindFontSize.textLg,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.gray900,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(TailwindSpacing.p3), // p-3 (further reduced)
            child: Column(
              children: conditions.map((condition) {
                final isActive = condition['status'] == 'Active';
                return Container(
                  margin: EdgeInsets.only(bottom: TailwindSpacing.mb4),
                  padding: const EdgeInsets.all(TailwindSpacing.p4),
                  decoration: BoxDecoration(
                    color: isActive ? AppTheme.purple50 : AppTheme.gray50,
                    border: Border.all(
                      color: isActive ? AppTheme.purple200 : AppTheme.gray200,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  condition['name'] as String,
                                  style: const TextStyle(
                                    fontSize: TailwindFontSize.textSm,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.gray900,
                                  ),
                                ),
                                if (condition['severity'] != null) ...[
                                  SizedBox(height: TailwindSpacing.mb1),
                                  Text(
                                    condition['severity'] as String,
                                    style: const TextStyle(
                                      fontSize: TailwindFontSize.textSm,
                                      color: AppTheme.gray600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: TailwindSpacing.p3,
                              vertical: TailwindSpacing.p1,
                            ),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppTheme.green100
                                  : AppTheme.gray200,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              condition['status'] as String,
                              style: TextStyle(
                                fontSize: TailwindFontSize.textXs,
                                fontWeight: FontWeight.w600,
                                color: isActive
                                    ? AppTheme.green700
                                    : AppTheme.gray600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: TailwindSpacing.mb3),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Onset:',
                                  style: TextStyle(
                                    fontSize: TailwindFontSize.textSm,
                                    color: AppTheme.gray500,
                                  ),
                                ),
                                Text(
                                  condition['onsetDate'] as String,
                                  style: const TextStyle(
                                    fontSize: TailwindFontSize.textSm,
                                    color: AppTheme.gray900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Source:',
                                  style: TextStyle(
                                    fontSize: TailwindFontSize.textSm,
                                    color: AppTheme.gray500,
                                  ),
                                ),
                                Text(
                                  condition['source'] as String,
                                  style: const TextStyle(
                                    fontSize: TailwindFontSize.textSm,
                                    color: AppTheme.gray900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationsSection() {
    final currentMeds = [
      {
        'name': 'Metformin',
        'dose': '1000mg',
        'frequency': 'twice daily',
        'startDate': 'Mar 15, 2022',
        'status': 'Active',
        'prescribingSource': 'Dr. Rebecca Smith'
      },
      {
        'name': 'Lisinopril',
        'dose': '20mg',
        'frequency': 'once daily',
        'startDate': 'Jan 12, 2021',
        'status': 'Active',
        'prescribingSource': 'Dr. James Chen'
      },
      {
        'name': 'Atorvastatin',
        'dose': '40mg',
        'frequency': 'once daily',
        'startDate': 'Jun 8, 2020',
        'status': 'Active',
        'prescribingSource': 'Dr. Rebecca Smith'
      },
      {
        'name': 'Aspirin',
        'dose': '81mg',
        'frequency': 'once daily',
        'startDate': 'Jun 8, 2020',
        'status': 'Active',
        'prescribingSource': 'Dr. Rebecca Smith'
      }
    ];

    final historicalMeds = [
      {
        'name': 'Amlodipine',
        'dose': '5mg',
        'frequency': 'once daily',
        'startDate': 'Jan 12, 2021',
        'status': 'Stopped',
        'prescribingSource': 'Dr. James Chen',
        'endDate': 'Mar 20, 2023'
      },
      {
        'name': 'Warfarin',
        'dose': '5mg',
        'frequency': 'once daily',
        'startDate': 'Jan 15, 2021',
        'status': 'Stopped',
        'prescribingSource': 'Dr. Sarah Johnson',
        'endDate': 'Aug 10, 2021'
      }
    ];

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
              color: AppTheme.blue50,
              border: Border(bottom: BorderSide(color: AppTheme.blue100)),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.pill, size: 20, color: AppTheme.blue600),
                SizedBox(width: TailwindSpacing.gap2),
                const Text(
                  'Medications',
                  style: TextStyle(
                    fontSize: TailwindFontSize.textLg,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.gray900,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(TailwindSpacing.p3), // p-3 (further reduced)
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CURRENT MEDICATIONS',
                  style: TextStyle(
                    fontSize: TailwindFontSize.textSm,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.gray700,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: TailwindSpacing.mb3),
                ...currentMeds.map((med) {
                  return Container(
                    margin: EdgeInsets.only(bottom: TailwindSpacing.mb3),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    med['name'] as String,
                                    style: const TextStyle(
                                      fontSize: TailwindFontSize.textSm,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.gray900,
                                    ),
                                  ),
                                  SizedBox(height: TailwindSpacing.mb1),
                                  Text(
                                    '${med['dose']} ${med['frequency']}',
                                    style: const TextStyle(
                                      fontSize: TailwindFontSize.textSm,
                                      color: AppTheme.gray600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: TailwindSpacing.p3,
                                vertical: TailwindSpacing.p1,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.green100,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                med['status'] as String,
                                style: const TextStyle(
                                  fontSize: TailwindFontSize.textXs,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.green700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: TailwindSpacing.mb3),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Started:',
                                    style: TextStyle(
                                      fontSize: TailwindFontSize.textSm,
                                      color: AppTheme.gray500,
                                    ),
                                  ),
                                  Text(
                                    med['startDate'] as String,
                                    style: const TextStyle(
                                      fontSize: TailwindFontSize.textSm,
                                      color: AppTheme.gray900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Prescribed by:',
                                    style: TextStyle(
                                      fontSize: TailwindFontSize.textSm,
                                      color: AppTheme.gray500,
                                    ),
                                  ),
                                  Text(
                                    med['prescribingSource'] as String,
                                    style: const TextStyle(
                                      fontSize: TailwindFontSize.textSm,
                                      color: AppTheme.gray900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
                SizedBox(height: TailwindSpacing.mb6),
                const Text(
                  'HISTORICAL MEDICATIONS',
                  style: TextStyle(
                    fontSize: TailwindFontSize.textSm,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.gray700,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: TailwindSpacing.mb3),
                ...historicalMeds.map((med) {
                  return Container(
                    margin: EdgeInsets.only(bottom: TailwindSpacing.mb3),
                    padding: const EdgeInsets.all(TailwindSpacing.p4),
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
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    med['name'] as String,
                                    style: const TextStyle(
                                      fontSize: TailwindFontSize.textSm,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.gray700,
                                    ),
                                  ),
                                  SizedBox(height: TailwindSpacing.mb1),
                                  Text(
                                    '${med['dose']} ${med['frequency']}',
                                    style: const TextStyle(
                                      fontSize: TailwindFontSize.textSm,
                                      color: AppTheme.gray600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: TailwindSpacing.p3,
                                vertical: TailwindSpacing.p1,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.gray200,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                med['status'] as String,
                                style: const TextStyle(
                                  fontSize: TailwindFontSize.textXs,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.gray600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: TailwindSpacing.mb3),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Started:',
                                    style: TextStyle(
                                      fontSize: TailwindFontSize.textSm,
                                      color: AppTheme.gray500,
                                    ),
                                  ),
                                  Text(
                                    med['startDate'] as String,
                                    style: const TextStyle(
                                      fontSize: TailwindFontSize.textSm,
                                      color: AppTheme.gray900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Stopped:',
                                    style: TextStyle(
                                      fontSize: TailwindFontSize.textSm,
                                      color: AppTheme.gray500,
                                    ),
                                  ),
                                  Text(
                                    med['endDate'] as String,
                                    style: const TextStyle(
                                      fontSize: TailwindFontSize.textSm,
                                      color: AppTheme.gray900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Prescribed by:',
                                    style: TextStyle(
                                      fontSize: TailwindFontSize.textSm,
                                      color: AppTheme.gray500,
                                    ),
                                  ),
                                  Text(
                                    med['prescribingSource'] as String,
                                    style: const TextStyle(
                                      fontSize: TailwindFontSize.textSm,
                                      color: AppTheme.gray900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalsSection() {
    if (patient.vitals == null) return const SizedBox();

    final vitalsTrend = [
      {'type': 'Blood Pressure', 'value': '152/94', 'unit': 'mmHg', 'dateTime': 'Jan 8, 2026 08:30 AM', 'status': 'Elevated'},
      {'type': 'Blood Pressure', 'value': '148/92', 'unit': 'mmHg', 'dateTime': 'Jan 6, 2026 02:15 PM', 'status': 'Elevated'},
      {'type': 'Blood Pressure', 'value': '145/90', 'unit': 'mmHg', 'dateTime': 'Jan 4, 2026 09:00 AM', 'status': 'Elevated'},
      {'type': 'Heart Rate', 'value': '88', 'unit': 'bpm', 'dateTime': 'Jan 8, 2026 08:30 AM', 'status': 'Normal'},
      {'type': 'Heart Rate', 'value': '85', 'unit': 'bpm', 'dateTime': 'Jan 6, 2026 02:15 PM', 'status': 'Normal'},
      {'type': 'Temperature', 'value': '98.2°F', 'unit': '', 'dateTime': 'Jan 8, 2026 08:30 AM', 'status': 'Normal'},
    ];

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
              color: AppTheme.green50,
              border: Border(bottom: BorderSide(color: AppTheme.green100)),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.activity, size: 20, color: AppTheme.green600),
                SizedBox(width: TailwindSpacing.gap2),
                const Text(
                  'Vitals & Trends',
                  style: TextStyle(
                    fontSize: TailwindFontSize.textLg,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.gray900,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(TailwindSpacing.p3), // p-3 (further reduced)
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'LATEST READINGS',
                  style: TextStyle(
                    fontSize: TailwindFontSize.textSm,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.gray700,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: TailwindSpacing.mb3),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(TailwindSpacing.p4),
                        decoration: BoxDecoration(
                          color: AppTheme.gray50,
                          border: Border.all(color: AppTheme.gray200),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Blood Pressure',
                              style: TextStyle(
                                fontSize: TailwindFontSize.textXs,
                                color: AppTheme.gray500,
                              ),
                            ),
                            SizedBox(height: TailwindSpacing.mb1),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: patient.vitals!.bloodPressure,
                                    style: const TextStyle(
                                      fontSize: TailwindFontSize.textXl, // text-xl = 20px
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.gray900,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: ' mmHg',
                                    style: TextStyle(
                                      fontSize: TailwindFontSize.textSm,
                                      color: AppTheme.gray500,
                                    ),
                                  ),
                                ],
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
                                    color: AppTheme.amber100,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Elevated',
                                    style: TextStyle(
                                      fontSize: TailwindFontSize.textXs,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.amber700,
                                    ),
                                  ),
                                ),
                                SizedBox(width: TailwindSpacing.gap1),
                                const Text(
                                  'Jan 8, 2026',
                                  style: TextStyle(
                                    fontSize: TailwindFontSize.textXs,
                                    color: AppTheme.gray500,
                                  ),
                                ),
                              ],
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
                          color: AppTheme.gray50,
                          border: Border.all(color: AppTheme.gray200),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Heart Rate',
                              style: TextStyle(
                                fontSize: TailwindFontSize.textXs,
                                color: AppTheme.gray500,
                              ),
                            ),
                            SizedBox(height: TailwindSpacing.mb1),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: patient.vitals!.heartRate,
                                    style: const TextStyle(
                                      fontSize: TailwindFontSize.textXl, // text-xl = 20px
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.gray900,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: ' bpm',
                                    style: TextStyle(
                                      fontSize: TailwindFontSize.textSm,
                                      color: AppTheme.gray500,
                                    ),
                                  ),
                                ],
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
                                    color: AppTheme.green100,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Normal',
                                    style: TextStyle(
                                      fontSize: TailwindFontSize.textXs,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.green700,
                                    ),
                                  ),
                                ),
                                SizedBox(width: TailwindSpacing.gap1),
                                const Text(
                                  'Jan 8, 2026',
                                  style: TextStyle(
                                    fontSize: TailwindFontSize.textXs,
                                    color: AppTheme.gray500,
                                  ),
                                ),
                              ],
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
                          color: AppTheme.gray50,
                          border: Border.all(color: AppTheme.gray200),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Temperature',
                              style: TextStyle(
                                fontSize: TailwindFontSize.textXs,
                                color: AppTheme.gray500,
                              ),
                            ),
                            SizedBox(height: TailwindSpacing.mb1),
                            Text(
                              patient.vitals!.temperature,
                              style: const TextStyle(
                                fontSize: 20,
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
                                    color: AppTheme.green100,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Normal',
                                    style: TextStyle(
                                      fontSize: TailwindFontSize.textXs,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.green700,
                                    ),
                                  ),
                                ),
                                SizedBox(width: TailwindSpacing.gap1),
                                const Text(
                                  'Jan 8, 2026',
                                  style: TextStyle(
                                    fontSize: TailwindFontSize.textXs,
                                    color: AppTheme.gray500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: TailwindSpacing.mb6),
                const Text(
                  'HISTORICAL TRENDS (LAST 5 READINGS)',
                  style: TextStyle(
                    fontSize: TailwindFontSize.textSm,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.gray700,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: TailwindSpacing.mb3),
                ...['Blood Pressure', 'Heart Rate', 'Temperature'].map((type) {
                  final readings = vitalsTrend.where((v) => v['type'] == type).take(5).toList();
                  if (readings.isEmpty) return const SizedBox();
                  return Container(
                    margin: EdgeInsets.only(bottom: TailwindSpacing.mb4),
                    padding: const EdgeInsets.all(TailwindSpacing.p4),
                    decoration: BoxDecoration(
                      color: AppTheme.gray50,
                      border: Border.all(color: AppTheme.gray200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          type,
                          style: const TextStyle(
                            fontSize: TailwindFontSize.textSm,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.gray900,
                          ),
                        ),
                        SizedBox(height: TailwindSpacing.mb3),
                        ...readings.map((reading) {
                          return Container(
                            padding: EdgeInsets.only(bottom: TailwindSpacing.gap2),
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: AppTheme.gray200)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 80,
                                      child: Text(
                                        reading['value'] as String,
                                        style: const TextStyle(
                                          fontSize: TailwindFontSize.textSm,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.gray900,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: TailwindSpacing.gap3),
                                    Text(
                                      reading['unit'] as String,
                                      style: const TextStyle(
                                        fontSize: TailwindFontSize.textSm,
                                        color: AppTheme.gray500,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: TailwindSpacing.p2,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getVitalStatusColor(reading['status'] as String).bg,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        reading['status'] as String,
                                        style: TextStyle(
                                          fontSize: TailwindFontSize.textXs,
                                          fontWeight: FontWeight.w600,
                                          color: _getVitalStatusColor(reading['status'] as String).text,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: TailwindSpacing.gap3),
                                    SizedBox(
                                      width: 160,
                                      child: Text(
                                        reading['dateTime'] as String,
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(
                                          fontSize: TailwindFontSize.textSm,
                                          color: AppTheme.gray500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClinicalNotesSection() {
    final notes = [
      {
        'content': 'Patient shows good adherence to medication regimen. BP remains elevated despite treatment. Discussed lifestyle modifications including sodium reduction and increased physical activity. Will monitor closely and consider medication adjustment if no improvement in 2 weeks.',
        'timestamp': 'Jan 6, 2026 02:30 PM',
        'author': 'Dr. Rebecca Smith',
        'visitType': 'Manual Visit'
      },
      {
        'content': 'Follow-up on CKD Stage 3. eGFR stable at 52 ml/min. Patient educated on kidney-protective measures. Continue current medications. Renal function panel scheduled for March 2026.',
        'timestamp': 'Dec 28, 2025 04:00 PM',
        'author': 'Dr. James Chen',
        'visitType': 'Manual Visit'
      },
    ];

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
              color: AppTheme.amber50,
              border: Border(bottom: BorderSide(color: AppTheme.amber100)),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.fileText, size: 20, color: AppTheme.amber600),
                SizedBox(width: TailwindSpacing.gap2),
                const Text(
                  'Clinical Notes',
                  style: TextStyle(
                    fontSize: TailwindFontSize.textLg,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.gray900,
                  ),
                ),
                SizedBox(width: TailwindSpacing.gap2),
                const Text(
                  '(From Previous Visits)',
                  style: TextStyle(
                    fontSize: TailwindFontSize.textXs,
                    color: AppTheme.gray500,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(TailwindSpacing.p3), // p-3 (further reduced)
            child: Column(
              children: notes.map((note) {
                return Container(
                  margin: EdgeInsets.only(bottom: TailwindSpacing.mb4),
                  padding: const EdgeInsets.all(TailwindSpacing.p4),
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
                              const Icon(LucideIcons.calendar, size: 16, color: AppTheme.gray500),
                              SizedBox(width: TailwindSpacing.gap2),
                              Text(
                                note['timestamp'] as String,
                                style: const TextStyle(
                                  fontSize: TailwindFontSize.textSm,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.gray900,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: TailwindSpacing.p2,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.blue100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              note['visitType'] as String,
                              style: const TextStyle(
                                fontSize: TailwindFontSize.textXs,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.blue700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: TailwindSpacing.mb3),
                      Text(
                        note['content'] as String,
                        style: const TextStyle(
                          fontSize: TailwindFontSize.textSm,
                          color: AppTheme.gray700,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: TailwindSpacing.mb3),
                      RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Documented by: ',
                              style: TextStyle(
                                fontSize: TailwindFontSize.textXs,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.gray500,
                              ),
                            ),
                            TextSpan(
                              text: note['author'] as String,
                              style: const TextStyle(
                                fontSize: TailwindFontSize.textXs,
                                color: AppTheme.gray500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataFreshnessSection() {
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
          const Icon(LucideIcons.clock, size: 20, color: AppTheme.blue600),
          SizedBox(width: TailwindSpacing.gap3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Data Freshness & Provenance',
                  style: TextStyle(
                    fontSize: TailwindFontSize.textSm,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.blue900,
                  ),
                ),
                SizedBox(height: TailwindSpacing.mb1),
                Text(
                  'Last data update: ${DateTime.now().toString().substring(0, 16)}',
                  style: const TextStyle(
                    fontSize: TailwindFontSize.textSm,
                    color: AppTheme.blue800,
                  ),
                ),
                const Text(
                  'Source systems: Digital Twin Engine, EHR Sync, Background Monitoring',
                  style: TextStyle(
                    fontSize: TailwindFontSize.textSm,
                    color: AppTheme.blue800,
                  ),
                ),
                SizedBox(height: TailwindSpacing.mt2),
                const Text(
                  'This summary reflects the most recent available patient data. Clinical decisions should incorporate current patient context and examination findings.',
                  style: TextStyle(
                    fontSize: TailwindFontSize.textXs,
                    fontStyle: FontStyle.italic,
                    color: AppTheme.blue700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ({Color bg, Color text}) _getVitalStatusColor(String status) {
    switch (status) {
      case 'Normal':
        return (bg: AppTheme.green100, text: AppTheme.green700);
      case 'Elevated':
        return (bg: AppTheme.amber100, text: AppTheme.amber700);
      case 'Critical':
        return (bg: AppTheme.red100, text: AppTheme.red700);
      default:
        return (bg: AppTheme.gray100, text: AppTheme.gray700);
    }
  }
}
