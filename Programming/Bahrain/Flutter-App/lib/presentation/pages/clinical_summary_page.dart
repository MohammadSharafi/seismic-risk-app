import 'package:flutter/material.dart';
import '../../domain/entities/patient.dart';
import '../theme/app_theme.dart';
import '../theme/tailwind_spacing.dart';
import '../utils/lucide_icons.dart';

class ClinicalSummaryPage extends StatefulWidget {
  final Patient patient;
  final VoidCallback? onViewFullSummary;

  const ClinicalSummaryPage({
    super.key,
    required this.patient,
    this.onViewFullSummary,
  });

  @override
  State<ClinicalSummaryPage> createState() => _ClinicalSummaryPageState();
}

class _ClinicalSummaryPageState extends State<ClinicalSummaryPage> {
  bool _expandedConditions = false;
  bool _expandedMedications = false;
  bool _expandedVitals = false;

  final List<Map<String, dynamic>> _detailedConditions = [
    {
      'name': 'Type 2 Diabetes Mellitus',
      'status': 'Active',
      'onsetDate': 'Mar 2022',
      'source': 'Manual Visit',
      'tags': ['Chronic', 'High Impact']
    },
    {
      'name': 'Hypertension (Stage 2)',
      'status': 'Active',
      'onsetDate': 'Jan 2021',
      'source': 'Background Monitoring',
      'tags': ['Chronic', 'High Impact']
    },
    {
      'name': 'Chronic Kidney Disease (Stage 3)',
      'status': 'Active',
      'onsetDate': 'Sep 2023',
      'source': 'Manual Visit',
      'tags': ['Chronic', 'High Impact']
    },
    {
      'name': 'Hyperlipidemia',
      'status': 'Active',
      'onsetDate': 'Jun 2020',
      'source': 'Manual Visit',
      'tags': ['Chronic']
    }
  ];

  final List<Map<String, dynamic>> _detailedMedications = [
    {
      'name': 'Metformin',
      'dose': '1000mg twice daily',
      'startDate': 'Mar 2022',
      'prescribingSource': 'Dr. Rebecca Smith',
      'status': 'Active',
      'lastReviewed': 'Jan 8, 2026'
    },
    {
      'name': 'Lisinopril',
      'dose': '20mg once daily',
      'startDate': 'Jan 2021',
      'prescribingSource': 'Dr. James Chen',
      'status': 'Active',
      'lastReviewed': 'Jan 8, 2026'
    },
    {
      'name': 'Atorvastatin',
      'dose': '40mg once daily',
      'startDate': 'Jun 2020',
      'prescribingSource': 'Dr. Rebecca Smith',
      'status': 'Active',
      'lastReviewed': 'Dec 28, 2025'
    },
    {
      'name': 'Aspirin',
      'dose': '81mg once daily',
      'startDate': 'Jun 2020',
      'prescribingSource': 'Dr. Rebecca Smith',
      'status': 'Active',
      'lastReviewed': 'Dec 28, 2025'
    }
  ];

  final List<Map<String, dynamic>> _vitalsTrend = [
    {'type': 'Blood Pressure', 'value': '152/94', 'unit': 'mmHg', 'dateTime': 'Jan 8, 2026 08:30 AM', 'status': 'Elevated'},
    {'type': 'Blood Pressure', 'value': '148/92', 'unit': 'mmHg', 'dateTime': 'Jan 6, 2026 02:15 PM', 'status': 'Elevated'},
    {'type': 'Blood Pressure', 'value': '145/90', 'unit': 'mmHg', 'dateTime': 'Jan 4, 2026 09:00 AM', 'status': 'Elevated'},
    {'type': 'Heart Rate', 'value': '88', 'unit': 'bpm', 'dateTime': 'Jan 8, 2026 08:30 AM', 'status': 'Normal'},
    {'type': 'Heart Rate', 'value': '85', 'unit': 'bpm', 'dateTime': 'Jan 6, 2026 02:15 PM', 'status': 'Normal'},
    {'type': 'Heart Rate', 'value': '82', 'unit': 'bpm', 'dateTime': 'Jan 4, 2026 09:00 AM', 'status': 'Normal'},
    {'type': 'Temperature', 'value': '98.2°F', 'unit': '', 'dateTime': 'Jan 8, 2026 08:30 AM', 'status': 'Normal'},
    {'type': 'Temperature', 'value': '98.4°F', 'unit': '', 'dateTime': 'Jan 6, 2026 02:15 PM', 'status': 'Normal'},
    {'type': 'Temperature', 'value': '98.1°F', 'unit': '', 'dateTime': 'Jan 4, 2026 09:00 AM', 'status': 'Normal'}
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(TailwindSpacing.p3), // p-3 (further reduced)
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildKeyConditions(),
          SizedBox(height: TailwindSpacing.mb3), // mb-3 (further reduced)
          _buildCurrentMedications(),
          if (widget.patient.vitals != null) ...[
            SizedBox(height: TailwindSpacing.mb3), // mb-3 (further reduced)
            _buildLatestVitals(),
          ],
          SizedBox(height: TailwindSpacing.mt6),
          Container(
            padding: const EdgeInsets.only(top: TailwindSpacing.p4),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppTheme.gray200)),
            ),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: widget.onViewFullSummary,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.blue200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16, // px-4 = 16px
                    vertical: 8, // py-2 = 8px
                  ),
                  minimumSize: const Size(0, 36), // h-9 = 36px
                ),
                child: const Text(
                  'View Full Clinical Summary',
                  style: TextStyle(
                    fontSize: TailwindFontSize.textSm, // text-sm = 14px (reduced from w600)
                    fontWeight: FontWeight.w500, // font-medium (reduced from w600)
                    color: AppTheme.blue600,
                    height: 1.5,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyConditions() {
    final conditionsToShow = _expandedConditions
        ? _detailedConditions
        : _detailedConditions.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Key Conditions',
          style: TextStyle(
            fontSize: TailwindFontSize.textSm,
            fontWeight: FontWeight.w600,
            color: AppTheme.gray900,
          ),
        ),
        SizedBox(height: TailwindSpacing.mb2),
        ...conditionsToShow.map((condition) {
          if (!_expandedConditions) {
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
                      condition['name'] as String,
                      style: const TextStyle(
                        fontSize: TailwindFontSize.textSm,
                        color: AppTheme.gray700,
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Container(
              margin: EdgeInsets.only(bottom: TailwindSpacing.gap2),
              padding: const EdgeInsets.all(TailwindSpacing.p3),
              decoration: BoxDecoration(
                color: AppTheme.purple50,
                border: Border.all(color: AppTheme.purple100),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        condition['name'] as String,
                        style: const TextStyle(
                          fontSize: TailwindFontSize.textSm,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.gray900,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: TailwindSpacing.p2,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: condition['status'] == 'Active'
                              ? AppTheme.green100
                              : AppTheme.gray200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          condition['status'] as String,
                          style: TextStyle(
                            fontSize: TailwindFontSize.textXs,
                            fontWeight: FontWeight.w600,
                            color: condition['status'] == 'Active'
                                ? AppTheme.green700
                                : AppTheme.gray600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: TailwindSpacing.mb2),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Onset:',
                              style: TextStyle(
                                fontSize: TailwindFontSize.textXs,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.gray600,
                              ),
                            ),
                            Text(
                              condition['onsetDate'] as String,
                              style: const TextStyle(
                                fontSize: TailwindFontSize.textXs,
                                color: AppTheme.gray600,
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
                                fontSize: TailwindFontSize.textXs,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.gray600,
                              ),
                            ),
                            Text(
                              condition['source'] as String,
                              style: const TextStyle(
                                fontSize: TailwindFontSize.textXs,
                                color: AppTheme.gray600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (condition['tags'] != null &&
                      (condition['tags'] as List).isNotEmpty) ...[
                    SizedBox(height: TailwindSpacing.mt2),
                    Wrap(
                      spacing: TailwindSpacing.gap1,
                      children: (condition['tags'] as List).map<Widget>((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: TailwindSpacing.p2,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: tag == 'High Impact'
                                ? AppTheme.red100
                                : AppTheme.purple100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: TailwindFontSize.textXs,
                              color: tag == 'High Impact'
                                  ? AppTheme.red700
                                  : AppTheme.purple700,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            );
          }
        }),
        TextButton(
          onPressed: () => setState(() => _expandedConditions = !_expandedConditions),
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.blue600,
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _expandedConditions ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                size: 16,
              ),
              SizedBox(width: TailwindSpacing.gap1),
              Text(
                _expandedConditions ? 'Collapse details' : 'View condition details',
                style: const TextStyle(
                  fontSize: TailwindFontSize.textXs, // text-xs = 12px (smaller)
                  fontWeight: FontWeight.w500, // font-medium
                  color: AppTheme.blue600,
                  height: 1.5,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentMedications() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Current Medications',
          style: TextStyle(
            fontSize: TailwindFontSize.textSm,
            fontWeight: FontWeight.w600,
            color: AppTheme.gray900,
          ),
        ),
        SizedBox(height: TailwindSpacing.mb2),
        ..._detailedMedications.map((med) {
          if (!_expandedMedications) {
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
                      '${med['name']} ${med['dose']}',
                      style: const TextStyle(
                        fontSize: TailwindFontSize.textSm,
                        color: AppTheme.gray700,
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Container(
              margin: EdgeInsets.only(bottom: TailwindSpacing.gap2),
              padding: const EdgeInsets.all(TailwindSpacing.p3),
              decoration: BoxDecoration(
                color: AppTheme.blue50,
                border: Border.all(color: AppTheme.blue100),
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
                            Text(
                              med['dose'] as String,
                              style: const TextStyle(
                                fontSize: TailwindFontSize.textXs,
                                color: AppTheme.gray600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: TailwindSpacing.p2,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: med['status'] == 'Active'
                              ? AppTheme.green100
                              : AppTheme.gray200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          med['status'] as String,
                          style: TextStyle(
                            fontSize: TailwindFontSize.textXs,
                            fontWeight: FontWeight.w600,
                            color: med['status'] == 'Active'
                                ? AppTheme.green700
                                : AppTheme.gray600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: TailwindSpacing.mb2),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Started:',
                              style: TextStyle(
                                fontSize: TailwindFontSize.textXs,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.gray600,
                              ),
                            ),
                            Text(
                              med['startDate'] as String,
                              style: const TextStyle(
                                fontSize: TailwindFontSize.textXs,
                                color: AppTheme.gray600,
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
                                fontSize: TailwindFontSize.textXs,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.gray600,
                              ),
                            ),
                            Text(
                              med['prescribingSource'] as String,
                              style: const TextStyle(
                                fontSize: TailwindFontSize.textXs,
                                color: AppTheme.gray600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (med['lastReviewed'] != null) ...[
                    SizedBox(height: TailwindSpacing.mt1),
                    Text(
                      'Last reviewed: ${med['lastReviewed']}',
                      style: const TextStyle(
                        fontSize: TailwindFontSize.textXs,
                        color: AppTheme.blue700,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }
        }),
        TextButton(
          onPressed: () => setState(() => _expandedMedications = !_expandedMedications),
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.blue600,
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _expandedMedications ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                size: 16,
              ),
              SizedBox(width: TailwindSpacing.gap1),
              Text(
                _expandedMedications ? 'Collapse details' : 'View medication details',
                style: const TextStyle(
                  fontSize: TailwindFontSize.textXs, // text-xs = 12px (smaller)
                  fontWeight: FontWeight.w500, // font-medium
                  color: AppTheme.blue600,
                  height: 1.5,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLatestVitals() {
    if (widget.patient.vitals == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Latest Vitals',
          style: TextStyle(
            fontSize: TailwindFontSize.textSm,
            fontWeight: FontWeight.w600,
            color: AppTheme.gray900,
          ),
        ),
        const SizedBox(height: 12), // mb-3 = 12px
        if (!_expandedVitals) ...[
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
          const SizedBox(height: 8), // mb-2 = 8px
        ] else ...[
          ...['Blood Pressure', 'Heart Rate', 'Temperature'].map((type) {
            final readings = _vitalsTrend
                .where((v) => v['type'] == type)
                .take(3)
                .toList();
            if (readings.isEmpty) return const SizedBox();
            return Container(
              margin: EdgeInsets.only(bottom: TailwindSpacing.mb4),
              padding: const EdgeInsets.all(TailwindSpacing.p3),
              decoration: BoxDecoration(
                color: AppTheme.gray50,
                border: Border.all(color: AppTheme.gray200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$type Trend',
                    style: const TextStyle(
                      fontSize: TailwindFontSize.textSm,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.gray900,
                    ),
                  ),
                  SizedBox(height: TailwindSpacing.mb3),
                  ...readings.map((reading) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: TailwindSpacing.gap2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                reading['value'] as String,
                                style: const TextStyle(
                                  fontSize: TailwindFontSize.textSm,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.gray900,
                                ),
                              ),
                              SizedBox(width: TailwindSpacing.gap1),
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
                              SizedBox(width: TailwindSpacing.gap2),
                              Text(
                                reading['dateTime'] as String,
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
                ],
              ),
            );
          }),
        ],
        TextButton(
          onPressed: () => setState(() => _expandedVitals = !_expandedVitals),
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.blue600,
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _expandedVitals ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                size: 16,
              ),
              SizedBox(width: TailwindSpacing.gap1),
              Text(
                _expandedVitals ? 'Collapse trend' : 'View vitals trend',
                style: const TextStyle(
                  fontSize: TailwindFontSize.textXs, // text-xs = 12px (smaller)
                  fontWeight: FontWeight.w500, // font-medium
                  color: AppTheme.blue600,
                  height: 1.5,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
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
