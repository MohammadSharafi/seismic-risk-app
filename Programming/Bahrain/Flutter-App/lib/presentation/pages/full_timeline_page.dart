import 'package:flutter/material.dart';
import '../../domain/entities/patient.dart';
import '../../domain/value_objects/risk_tier.dart';
import '../widgets/risk_badge.dart';
import '../widgets/custom_text_field.dart';
import '../theme/app_theme.dart';
import '../theme/tailwind_spacing.dart';
import '../utils/lucide_icons.dart';
import '../utils/svg_icons.dart';

class FullTimelinePage extends StatefulWidget {
  final Patient patient;
  final VoidCallback onClose;
  final VoidCallback onStartNewVisit;
  final Function(String) onOpenDiscussion;

  const FullTimelinePage({
    super.key,
    required this.patient,
    required this.onClose,
    required this.onStartNewVisit,
    required this.onOpenDiscussion,
  });

  @override
  State<FullTimelinePage> createState() => _FullTimelinePageState();
}

class _FullTimelinePageState extends State<FullTimelinePage> {
  String? _expandedVisit;
  String _filterType = 'All';
  String _filterRisk = 'All';
  bool _showAIOnly = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _expandedVisit = 'V001';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> _mockVisits = [
    {
      'id': 'V001',
      'date': 'Jan 8, 2026 10:45 AM',
      'visitType': 'Manual',
      'status': 'Completed',
      'triggerSource': 'Doctor-initiated',
      'patientState': {
        'conditions': ['Atrial Fibrillation', 'Type 2 Diabetes', 'Hypertension'],
        'dataFreshness': 'Current (updated today)'
      },
      'aiAnalysis': {
        'riskTier': RiskTier.high,
        'reasoning': [
          'Multiple high-risk comorbidities detected',
          'Blood pressure elevated above target range (142/88)',
          'Medication interaction potential identified',
          'Historical trend shows progression over 6 months'
        ],
        'evidenceReferences': [
          {'type': 'vitals', 'label': 'BP Readings - Jan 1-8'},
          {'type': 'labs', 'label': 'HbA1c - Jan 5'},
          {'type': 'meds', 'label': 'Medication Review'}
        ],
        'timestamp': 'Jan 8, 2026 10:45 AM',
        'modelVersion': 'ClinicalAI v3.2.1',
        'reviewedByDoctor': true
      },
      'doctorDecision': {
        'riskTier': RiskTier.high,
        'recommendation': 'Immediate medication adjustment. Increased Lisinopril to 20mg. Daily BP monitoring for 1 week.',
        'notes': 'Agreed with AI assessment. Patient counseled on home BP monitoring protocol.',
        'doctorName': 'Dr. Rebecca Smith',
        'timestamp': 'Jan 8, 2026 11:15 AM'
      },
      'outcome': {
        'status': 'Follow-up scheduled',
        'details': 'Scheduled for Jan 15, 2026'
      },
      'hasAlarms': true,
      'hasDiscussion': true
    },
    {
      'id': 'V002',
      'date': 'Jan 6, 2026 2:30 PM',
      'visitType': 'Background',
      'status': 'Completed',
      'triggerSource': 'Background monitoring',
      'patientState': {
        'conditions': ['Atrial Fibrillation', 'Type 2 Diabetes', 'Hypertension'],
        'dataFreshness': 'Current'
      },
      'aiAnalysis': {
        'riskTier': RiskTier.high,
        'reasoning': [
          'Blood pressure spike detected (152/92)',
          'Anomaly detection algorithm flagged for immediate review'
        ],
        'evidenceReferences': [
          {'type': 'vitals', 'label': 'BP Alert - Jan 6'}
        ],
        'timestamp': 'Jan 6, 2026 2:30 PM',
        'modelVersion': 'ClinicalAI v3.2.1',
        'reviewedByDoctor': true
      },
      'doctorDecision': {
        'riskTier': RiskTier.medium,
        'recommendation': 'Monitor for 48 hours before escalation. Patient reported recent stress event.',
        'notes': 'Override AI suggestion. Clinical context: patient experiencing family stress. Will monitor before medication adjustment.',
        'doctorName': 'Dr. Rebecca Smith',
        'timestamp': 'Jan 6, 2026 3:15 PM'
      },
      'outcome': {
        'status': 'Monitoring continued'
      },
      'hasAlarms': true,
      'hasDiscussion': true
    },
  ];

  List<Map<String, dynamic>> get _filteredVisits {
    return _mockVisits.where((visit) {
      final matchesType = _filterType == 'All' || visit['visitType'] == _filterType;
      final aiRisk = visit['aiAnalysis']['riskTier'] as RiskTier;
      final docRisk = visit['doctorDecision']['riskTier'] as RiskTier;
      final matchesRisk = _filterRisk == 'All' || 
          _riskTierToString(aiRisk) == _filterRisk || 
          _riskTierToString(docRisk) == _filterRisk;
      final searchQuery = _searchController.text.toLowerCase();
      final matchesSearch = searchQuery.isEmpty ||
          visit['date'].toString().toLowerCase().contains(searchQuery) ||
          visit['doctorDecision']['notes'].toString().toLowerCase().contains(searchQuery);
      return matchesType && matchesRisk && matchesSearch;
    }).toList();
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

  void _toggleVisit(String visitId) {
    setState(() {
      _expandedVisit = _expandedVisit == visitId ? null : visitId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: const BoxConstraints(maxWidth: 1152, maxHeight: 810),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              _buildHeader(),
              _buildFilters(),
              Expanded(
                child: _buildTimelineContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TailwindSpacing.p8,
        vertical: TailwindSpacing.p6,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.gray200)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Patient Visit Timeline',
                      style: TextStyle(
                        fontSize: TailwindFontSize.text2xl,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.gray900,
                      ),
                    ),
                    SizedBox(height: TailwindSpacing.mb2),
                    const Text(
                      'Chronological record of visits, analyses, and clinical decisions',
                      style: TextStyle(
                        fontSize: TailwindFontSize.textSm,
                        color: AppTheme.gray600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: widget.onClose,
                icon: const Icon(LucideIcons.x, size: 24),
                color: AppTheme.gray400,
              ),
            ],
          ),
          SizedBox(height: TailwindSpacing.mb4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    'Patient: ',
                    style: TextStyle(
                      fontSize: TailwindFontSize.textSm,
                      color: AppTheme.gray600,
                    ),
                  ),
                  Text(
                    widget.patient.name,
                    style: const TextStyle(
                      fontSize: TailwindFontSize.textSm,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.gray900,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 24,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    color: AppTheme.gray300,
                  ),
                  Row(
                    children: [
                      const Text(
                        'Current Risk: ',
                        style: TextStyle(
                          fontSize: TailwindFontSize.textSm,
                          color: AppTheme.gray600,
                        ),
                      ),
                      RiskBadge(tier: widget.patient.riskTier, size: BadgeSize.sm),
                    ],
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: widget.onStartNewVisit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.blue600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: TailwindSpacing.p4,
                    vertical: TailwindSpacing.p2,
                  ),
                ),
                child: const Text('Start New Visit'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TailwindSpacing.p8,
        vertical: TailwindSpacing.p4,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.gray50,
        border: Border(bottom: BorderSide(color: AppTheme.gray200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: CustomTextField(
              controller: _searchController,
              placeholder: 'Search by date or keyword...',
              onChanged: (_) => setState(() {}),
            ),
          ),
          SizedBox(width: TailwindSpacing.gap4),
          SvgIcons.filter(size: 16, color: AppTheme.gray400),
          SizedBox(width: TailwindSpacing.gap2),
          DropdownButton<String>(
            value: _filterType,
            items: const [
              DropdownMenuItem(value: 'All', child: Text('All Visit Types')),
              DropdownMenuItem(value: 'Manual', child: Text('Manual')),
              DropdownMenuItem(value: 'Follow-up', child: Text('Follow-up')),
              DropdownMenuItem(value: 'Background', child: Text('Background')),
            ],
            onChanged: (value) => setState(() => _filterType = value!),
          ),
          SizedBox(width: TailwindSpacing.gap2),
          DropdownButton<String>(
            value: _filterRisk,
            items: const [
              DropdownMenuItem(value: 'All', child: Text('All Risk Tiers')),
              DropdownMenuItem(value: 'High', child: Text('High Risk')),
              DropdownMenuItem(value: 'Medium', child: Text('Medium Risk')),
              DropdownMenuItem(value: 'Low', child: Text('Low Risk')),
            ],
            onChanged: (value) => setState(() => _filterRisk = value!),
          ),
          SizedBox(width: TailwindSpacing.gap2),
          Row(
            children: [
              Checkbox(
                value: _showAIOnly,
                onChanged: (value) => setState(() => _showAIOnly = value ?? false),
              ),
              const Text(
                'Show AI-only evaluations',
                style: TextStyle(fontSize: TailwindFontSize.textSm),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(TailwindSpacing.p8),
      child: Column(
        children: _filteredVisits.asMap().entries.map((entry) {
          final index = entry.key;
          final visit = entry.value;
          final isExpanded = _expandedVisit == visit['id'];
          final isActive = visit['id'] == 'V001';

          return Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isActive ? AppTheme.blue300 : AppTheme.gray200,
                    width: isActive ? 2 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () => _toggleVisit(visit['id']),
                      child: Container(
                        padding: const EdgeInsets.all(TailwindSpacing.p4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(LucideIcons.calendar, size: 20, color: AppTheme.gray400),
                                      SizedBox(width: TailwindSpacing.gap3),
                                      Text(
                                        visit['date'],
                                        style: const TextStyle(
                                          fontSize: TailwindFontSize.textSm,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.gray900,
                                        ),
                                      ),
                                      if (isActive) ...[
                                        SizedBox(width: TailwindSpacing.gap2),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: TailwindSpacing.p2,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppTheme.blue100,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            'Active Visit',
                                            style: TextStyle(
                                              fontSize: TailwindFontSize.textXs,
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.blue700,
                                            ),
                                          ),
                                        ),
                                      ],
                                      SizedBox(width: TailwindSpacing.gap2),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: TailwindSpacing.p2,
                                          vertical: TailwindSpacing.p1,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getVisitTypeColor(visit['visitType']).bg,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          visit['visitType'],
                                          style: TextStyle(
                                            fontSize: TailwindFontSize.textXs,
                                            fontWeight: FontWeight.w600,
                                            color: _getVisitTypeColor(visit['visitType']).text,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: TailwindSpacing.gap2),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: TailwindSpacing.p2,
                                          vertical: TailwindSpacing.p1,
                                        ),
                                        decoration: BoxDecoration(
                                          color: visit['status'] == 'Completed'
                                              ? AppTheme.green100
                                              : AppTheme.gray100,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          visit['status'],
                                          style: TextStyle(
                                            fontSize: TailwindFontSize.textXs,
                                            fontWeight: FontWeight.w600,
                                            color: visit['status'] == 'Completed'
                                                ? AppTheme.green700
                                                : AppTheme.gray700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: TailwindSpacing.mb2),
                                  Text(
                                    'Trigger: ${visit['triggerSource']}',
                                    style: const TextStyle(
                                      fontSize: TailwindFontSize.textSm,
                                      color: AppTheme.gray600,
                                    ),
                                  ),
                                  SizedBox(height: TailwindSpacing.mb2),
                                  Row(
                                    children: [
                                      const Icon(LucideIcons.brain, size: 16, color: AppTheme.purple600),
                                      SizedBox(width: TailwindSpacing.gap2),
                                      const Text(
                                        'AI: ',
                                        style: TextStyle(
                                          fontSize: TailwindFontSize.textSm,
                                          color: AppTheme.gray600,
                                        ),
                                      ),
                                      RiskBadge(
                                        tier: visit['aiAnalysis']['riskTier'] as RiskTier,
                                        size: BadgeSize.sm,
                                      ),
                                      SizedBox(width: TailwindSpacing.gap4),
                                      const Icon(LucideIcons.user, size: 16, color: AppTheme.blue600),
                                      SizedBox(width: TailwindSpacing.gap2),
                                      const Text(
                                        'Doctor: ',
                                        style: TextStyle(
                                          fontSize: TailwindFontSize.textSm,
                                          color: AppTheme.gray600,
                                        ),
                                      ),
                                      RiskBadge(
                                        tier: visit['doctorDecision']['riskTier'] as RiskTier,
                                        size: BadgeSize.sm,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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
              ),
              if (index < _filteredVisits.length - 1)
                Container(
                  width: 1,
                  height: 16,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  color: AppTheme.gray300,
                ),
            ],
          );
        }).toList(),
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

  Widget _buildExpandedVisitDetails(Map<String, dynamic> visit) {
    return Container(
      padding: const EdgeInsets.all(TailwindSpacing.p6),
      decoration: const BoxDecoration(
        color: AppTheme.gray50,
        border: Border(top: BorderSide(color: AppTheme.gray200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPatientStateSection(visit['patientState']),
          SizedBox(height: TailwindSpacing.mb6),
          Row(
            children: [
              Expanded(child: _buildAIAnalysisSection(visit['aiAnalysis'])),
              SizedBox(width: TailwindSpacing.gap6),
              Expanded(child: _buildDoctorDecisionSection(visit['doctorDecision'])),
            ],
          ),
          SizedBox(height: TailwindSpacing.mb4),
          _buildOutcomeSection(visit),
        ],
      ),
    );
  }

  Widget _buildPatientStateSection(Map<String, dynamic> patientState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Patient state at time of visit',
          style: TextStyle(
            fontSize: TailwindFontSize.textSm,
            fontWeight: FontWeight.w600,
            color: AppTheme.gray700,
          ),
        ),
        SizedBox(height: TailwindSpacing.mb3),
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
              Text(
                'Key Conditions: ${(patientState['conditions'] as List).join(', ')}',
                style: const TextStyle(
                  fontSize: TailwindFontSize.textSm,
                  color: AppTheme.gray900,
                ),
              ),
              SizedBox(height: TailwindSpacing.mb2),
              Text(
                'Data Freshness: ${patientState['dataFreshness']}',
                style: const TextStyle(
                  fontSize: TailwindFontSize.textSm,
                  color: AppTheme.gray900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAIAnalysisSection(Map<String, dynamic> aiAnalysis) {
    return Container(
      padding: const EdgeInsets.all(TailwindSpacing.p4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.gray300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.brain, size: 20, color: AppTheme.purple600),
              SizedBox(width: TailwindSpacing.gap2),
              const Text(
                'AI Analysis (Assistive)',
                style: TextStyle(
                  fontSize: TailwindFontSize.textSm,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.gray900,
                ),
              ),
              if (aiAnalysis['reviewedByDoctor'] == true) ...[
                SizedBox(width: TailwindSpacing.gap2),
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
                    'Reviewed',
                    style: TextStyle(
                      fontSize: TailwindFontSize.textXs,
                      color: AppTheme.green700,
                    ),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: TailwindSpacing.mb4),
          const Text(
            'AI Risk Tier',
            style: TextStyle(
              fontSize: TailwindFontSize.textSm,
              color: AppTheme.gray600,
            ),
          ),
          SizedBox(height: TailwindSpacing.mb2),
          RiskBadge(
            tier: aiAnalysis['riskTier'] as RiskTier,
            size: BadgeSize.md,
          ),
          SizedBox(height: TailwindSpacing.mb4),
          const Text(
            'Key Reasons',
            style: TextStyle(
              fontSize: TailwindFontSize.textSm,
              color: AppTheme.gray600,
            ),
          ),
          SizedBox(height: TailwindSpacing.mb2),
          ...(aiAnalysis['reasoning'] as List).map<Widget>((reason) {
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
          SizedBox(height: TailwindSpacing.mb4),
          const Text(
            'Evidence References',
            style: TextStyle(
              fontSize: TailwindFontSize.textSm,
              color: AppTheme.gray600,
            ),
          ),
          SizedBox(height: TailwindSpacing.mb2),
          ...(aiAnalysis['evidenceReferences'] as List).map<Widget>((ref) {
            return Padding(
              padding: EdgeInsets.only(bottom: TailwindSpacing.gap2),
              child: TextButton.icon(
                onPressed: () {},
                icon: const Icon(LucideIcons.externalLink, size: 14),
                label: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: TailwindSpacing.p2,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getEvidenceTypeColor(ref['type']).bg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        ref['type'],
                        style: TextStyle(
                          fontSize: TailwindFontSize.textXs,
                          color: _getEvidenceTypeColor(ref['type']).text,
                        ),
                      ),
                    ),
                    SizedBox(width: TailwindSpacing.gap2),
                    Text(ref['label']),
                  ],
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.blue600,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            );
          }),
          SizedBox(height: TailwindSpacing.mb4),
          Container(
            padding: const EdgeInsets.only(top: TailwindSpacing.p3),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppTheme.gray200)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Timestamp: ${aiAnalysis['timestamp']}',
                  style: const TextStyle(
                    fontSize: TailwindFontSize.textXs,
                    color: AppTheme.gray500,
                  ),
                ),
                Text(
                  'Model: ${aiAnalysis['modelVersion']}',
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
  }

  Widget _buildDoctorDecisionSection(Map<String, dynamic> doctorDecision) {
    return Container(
      padding: const EdgeInsets.all(TailwindSpacing.p4),
      decoration: BoxDecoration(
        color: AppTheme.blue50,
        border: Border.all(color: AppTheme.blue300, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.user, size: 20, color: AppTheme.blue600),
              SizedBox(width: TailwindSpacing.gap2),
              const Text(
                'Doctor Final Decision',
                style: TextStyle(
                  fontSize: TailwindFontSize.textSm,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.gray900,
                ),
              ),
            ],
          ),
          SizedBox(height: TailwindSpacing.mb4),
          const Text(
            'Final Risk Tier',
            style: TextStyle(
              fontSize: TailwindFontSize.textSm,
              fontWeight: FontWeight.w600,
              color: AppTheme.gray700,
            ),
          ),
          SizedBox(height: TailwindSpacing.mb2),
          RiskBadge(
            tier: doctorDecision['riskTier'] as RiskTier,
            size: BadgeSize.md,
          ),
          SizedBox(height: TailwindSpacing.mb4),
          const Text(
            'Recommendation',
            style: TextStyle(
              fontSize: TailwindFontSize.textSm,
              fontWeight: FontWeight.w600,
              color: AppTheme.gray700,
            ),
          ),
          SizedBox(height: TailwindSpacing.mb2),
          Container(
            padding: const EdgeInsets.all(TailwindSpacing.p3),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppTheme.blue200),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              doctorDecision['recommendation'],
              style: const TextStyle(
                fontSize: TailwindFontSize.textSm,
                color: AppTheme.gray900,
              ),
            ),
          ),
          SizedBox(height: TailwindSpacing.mb4),
          const Text(
            'Clinical Notes',
            style: TextStyle(
              fontSize: TailwindFontSize.textSm,
              fontWeight: FontWeight.w600,
              color: AppTheme.gray700,
            ),
          ),
          SizedBox(height: TailwindSpacing.mb2),
          Container(
            padding: const EdgeInsets.all(TailwindSpacing.p3),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppTheme.blue200),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              doctorDecision['notes'],
              style: const TextStyle(
                fontSize: TailwindFontSize.textSm,
                color: AppTheme.gray900,
              ),
            ),
          ),
          SizedBox(height: TailwindSpacing.mb4),
          Container(
            padding: const EdgeInsets.only(top: TailwindSpacing.p3),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppTheme.blue200)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctorDecision['doctorName'],
                  style: const TextStyle(
                    fontSize: TailwindFontSize.textXs,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.gray700,
                  ),
                ),
                Text(
                  doctorDecision['timestamp'],
                  style: const TextStyle(
                    fontSize: TailwindFontSize.textXs,
                    color: AppTheme.gray700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutcomeSection(Map<String, dynamic> visit) {
    final outcome = visit['outcome'] as Map<String, dynamic>;
    return Container(
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
            'Outcome & Follow-up',
            style: TextStyle(
              fontSize: TailwindFontSize.textSm,
              fontWeight: FontWeight.w600,
              color: AppTheme.gray700,
            ),
          ),
          SizedBox(height: TailwindSpacing.mb3),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: TailwindSpacing.p3,
                  vertical: TailwindSpacing.p1,
                ),
                decoration: BoxDecoration(
                  color: _getOutcomeColor(outcome['status']).bg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  outcome['status'],
                  style: TextStyle(
                    fontSize: TailwindFontSize.textSm,
                    fontWeight: FontWeight.w600,
                    color: _getOutcomeColor(outcome['status']).text,
                  ),
                ),
              ),
              if (outcome['details'] != null) ...[
                SizedBox(width: TailwindSpacing.gap3),
                Text(
                  outcome['details'],
                  style: const TextStyle(
                    fontSize: TailwindFontSize.textSm,
                    color: AppTheme.gray600,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: TailwindSpacing.mb3),
          Row(
            children: [
              if (visit['hasAlarms'] == true)
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(LucideIcons.alertTriangle, size: 16),
                  label: const Text('View related alarms'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.orange600,
                  ),
                ),
              if (visit['hasAlarms'] == true && visit['hasDiscussion'] == true)
                SizedBox(width: TailwindSpacing.gap3),
              if (visit['hasDiscussion'] == true)
                TextButton.icon(
                  onPressed: () => widget.onOpenDiscussion(visit['id']),
                  icon: const Icon(LucideIcons.messageSquare, size: 16),
                  label: const Text('View discussion'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.blue600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  ({Color bg, Color text}) _getEvidenceTypeColor(String type) {
    switch (type) {
      case 'vitals':
        return (bg: AppTheme.green100, text: AppTheme.green700);
      case 'labs':
        return (bg: AppTheme.purple100, text: AppTheme.purple700);
      case 'meds':
        return (bg: AppTheme.blue100, text: AppTheme.blue700);
      default:
        return (bg: AppTheme.gray100, text: AppTheme.gray700);
    }
  }

  ({Color bg, Color text}) _getOutcomeColor(String status) {
    switch (status) {
      case 'Follow-up scheduled':
        return (bg: AppTheme.blue100, text: AppTheme.blue700);
      case 'Monitoring continued':
        return (bg: AppTheme.green100, text: AppTheme.green700);
      default:
        return (bg: AppTheme.gray100, text: AppTheme.gray700);
    }
  }
}
