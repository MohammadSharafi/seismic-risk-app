import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/patient.dart';
import '../../domain/entities/alarm.dart';
import '../../domain/value_objects/risk_tier.dart';
import '../widgets/risk_badge.dart';
import '../widgets/status_chip.dart';
import '../providers/patient_provider.dart';
import '../theme/app_theme.dart';
import '../theme/tailwind_spacing.dart';
import '../utils/svg_icons.dart';
import '../widgets/custom_text_field.dart';

class DoctorDashboardPage extends ConsumerStatefulWidget {
  final Function(Patient) onOpenPatient;

  const DoctorDashboardPage({
    super.key,
    required this.onOpenPatient,
  });

  @override
  ConsumerState<DoctorDashboardPage> createState() =>
      _DoctorDashboardPageState();
}

class _DoctorDashboardPageState extends ConsumerState<DoctorDashboardPage> {
  String _searchQuery = '';
  RiskTier? _filterRisk;
  String _filterCohort = 'All';
  String _filterAlarmStatus = 'All';

  @override
  Widget build(BuildContext context) {
    final patientsAsync = ref.watch(patientsProvider);
    final alarmsAsync = ref.watch(alarmsProvider);

    return Scaffold(
      backgroundColor: AppTheme.gray50,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.all(TailwindSpacing.p4), // p-4 (reduced)
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitle(),
                  const SizedBox(height: 12), // mb-3 (reduced)
                  alarmsAsync.when(
                    data: (alarms) => _buildAlarmsSection(alarms),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 12), // mb-3 (reduced)
                  _buildSearchAndFilters(),
                  const SizedBox(height: 12), // mb-3 (reduced)
                  patientsAsync.when(
                    data: (patients) => _buildPatientList(patients),
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (error, stack) => Center(
                      child: Text('Error: $error'),
                    ),
                  ),
                  const SizedBox(height: 12), // mb-3 (reduced)
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
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 8), // px-4 py-2 (reduced)
      decoration: const BoxDecoration(
        color: Colors.white, // bg-white
        border: Border(
            bottom: BorderSide(
                color: AppTheme.gray200)), // border-b border-gray-200
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40, // w-10 = 40px
                height: 40, // h-10 = 40px
                decoration: BoxDecoration(
                  color: AppTheme.blue600,
                  borderRadius: BorderRadius.circular(8), // rounded-lg
                ),
                child: SvgIcons.building(
                    size: 24, color: Colors.white), // w-6 h-6 = 24px
              ),
              const SizedBox(width: 12),
              const Text(
                'Virtual Hospital',
                style: TextStyle(
                  fontSize: TailwindFontSize
                      .textXl, // text-xl = 20px (matching React)
                  fontWeight: FontWeight.w600, // font-semibold
                  color: AppTheme.gray900,
                  height: 1.5,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 8), // px-3 py-2 (matching React)
            decoration: BoxDecoration(
              color: AppTheme.gray100, // bg-gray-50
              borderRadius: BorderRadius.circular(8), // rounded-lg
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.blue100,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      'DR',
                      style: TextStyle(
                        fontSize: TailwindFontSize
                            .textSm, // text-sm = 14px (matching React)
                        fontWeight:
                            FontWeight.w500, // font-medium (matching React)
                        color: AppTheme.blue700,
                        height: 1.5,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dr. Rebecca Smith',
                      style: TextStyle(
                        fontSize: TailwindFontSize.textSm, // text-sm = 14px
                        fontWeight: FontWeight.w600,
                        color: AppTheme.gray900,
                        height: 1.5,
                        letterSpacing: 0,
                      ),
                    ),
                    Text(
                      'Cardiology',
                      style: TextStyle(
                        fontSize: TailwindFontSize.textXs, // text-xs = 12px
                        color: AppTheme.gray500,
                        height: 1.5,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Patient Dashboard',
          style: TextStyle(
            fontSize: TailwindFontSize.textXl, // text-xl = 20px (reduced)
            fontWeight: FontWeight.w600, // font-semibold
            color: AppTheme.gray900,
            height: 1.5,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 4), // mb-1 = 4px (reduced)
        Text(
          'Manage and monitor Digital Twin patients',
          style: TextStyle(
            fontSize: TailwindFontSize.textSm, // text-sm = 14px (reduced)
            color: AppTheme.gray600,
            height: 1.5,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }

  Widget _buildAlarmsSection(List<Alarm> alarms) {
    final filteredAlarms = alarms.where((alarm) {
      final matchesRisk =
          _filterRisk == null || alarm.patient.riskTier == _filterRisk;
      final matchesStatus = _filterAlarmStatus == 'All' ||
          (_filterAlarmStatus == 'New' && !alarm.acknowledged) ||
          (_filterAlarmStatus == 'Acknowledged' && alarm.acknowledged);
      return matchesRisk && matchesStatus;
    }).toList();

    if (filteredAlarms.isEmpty) {
      return const SizedBox.shrink();
    }

    final newAlarmsCount = filteredAlarms.where((a) => !a.acknowledged).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SvgIcons.alertTriangle(
                    size: 20, color: AppTheme.orange600), // w-5 h-5 = 20px
                const SizedBox(width: 8),
                const Text(
                  'Active Alarms',
                  style: TextStyle(
                    fontSize: TailwindFontSize
                        .textLg, // text-lg = 18px (h3 default font-semibold in React)
                    fontWeight: FontWeight.w600, // font-semibold
                    color: AppTheme.gray900,
                    height: 1.5,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8, // px-2
                    vertical: 2, // py-0.5
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.orange100,
                    borderRadius: BorderRadius.circular(999), // rounded-full
                  ),
                  child: Text(
                    '$newAlarmsCount New',
                    style: const TextStyle(
                      fontSize: TailwindFontSize.textXs, // text-xs = 12px
                      fontWeight:
                          FontWeight.w500, // font-medium (matching React)
                      color: AppTheme
                          .orange700, // text-orange-700 (matching React)
                      height: 1.5,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ],
            ),
            DropdownButton<String>(
              value: _filterAlarmStatus,
              items: const [
                DropdownMenuItem(value: 'All', child: Text('All Alarms')),
                DropdownMenuItem(value: 'New', child: Text('New Only')),
                DropdownMenuItem(
                  value: 'Acknowledged',
                  child: Text('Acknowledged'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _filterAlarmStatus = value ?? 'All';
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 8), // mb-2 (reduced)
        ...filteredAlarms.asMap().entries.map((entry) {
          final index = entry.key;
          final alarm = entry.value;
          return _buildAlarmCard(alarm,
              isLast: index == filteredAlarms.length - 1);
        }),
        const SizedBox(height: 12), // mb-3 (reduced)
      ],
    );
  }

  Widget _buildAlarmCard(Alarm alarm, {bool isLast = false}) {
    return Container(
      margin: EdgeInsets.only(
          bottom:
              isLast ? 0 : 12), // gap-3 = 12px between cards, no margin on last
      padding: const EdgeInsets.all(TailwindSpacing.p3), // p-3 (reduced)
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: alarm.acknowledged ? AppTheme.gray200 : AppTheme.orange200,
          width: 2, // border-2 = 2px (matching React)
        ),
        borderRadius: BorderRadius.circular(8), // rounded-lg
        boxShadow: alarm.acknowledged
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05), // shadow-sm
                  blurRadius: 1,
                  offset: const Offset(0, 1),
                ),
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      alarm.patient.name,
                      style: const TextStyle(
                        fontSize: TailwindFontSize.textSm, // text-sm = 14px
                        fontWeight: FontWeight.w600, // font-semibold
                        color: AppTheme.gray900,
                        height: 1.5,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(width: 12), // gap-3 = 12px
                    RiskBadge(tier: alarm.patient.riskTier, size: BadgeSize.sm),
                    if (!alarm.acknowledged) ...[
                      const SizedBox(width: 12), // gap-3 = 12px
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8, // px-2
                          vertical: 2, // py-0.5
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.orange100,
                          borderRadius: BorderRadius.circular(
                              4), // rounded (not rounded-full) (matching React)
                        ),
                        child: const Text(
                          'New',
                          style: TextStyle(
                            fontSize: TailwindFontSize.textXs, // text-xs = 12px
                            fontWeight: FontWeight.w500, // font-medium
                            color: AppTheme
                                .orange700, // text-orange-700 (matching React)
                            height: 1.5,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8), // mb-2 = 8px
                Text(
                  alarm.summary,
                  style: const TextStyle(
                    fontSize: TailwindFontSize.textSm, // text-sm = 14px
                    color: AppTheme.gray700,
                    height: 1.5,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 8), // mb-2 = 8px
                Row(
                  children: [
                    SvgIcons.clock(
                        size: 14,
                        color: AppTheme
                            .gray500), // w-3.5 h-3.5 = 14px (matching React)
                    const SizedBox(width: 6), // gap-1.5 = 6px
                    Text(
                      alarm.timeTriggered,
                      style: const TextStyle(
                        fontSize: TailwindFontSize.textXs, // text-xs = 12px
                        color: AppTheme.gray500,
                        height: 1.5,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16), // ml-4 = 16px
          Material(
            color: AppTheme.blue600,
            borderRadius: BorderRadius.circular(8), // rounded-lg
            child: InkWell(
              onTap: () => widget.onOpenPatient(alarm.patient),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12, // px-3
                  vertical: 6, // py-1.5
                ),
                child: const Text(
                  'Review Patient',
                  style: TextStyle(
                    fontSize: TailwindFontSize
                        .textSm, // text-sm = 14px (matching React)
                    fontWeight: FontWeight.w500, // font-medium
                    color: Colors.white,
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

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(TailwindSpacing.p3), // p-3 (reduced)
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.gray200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: CustomTextField(
              placeholder: 'Search by patient name or ID...',
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          const SizedBox(width: 16), // gap-4 = 16px (matching React)
          Row(
            children: [
              SvgIcons.filter(
                  size: 20, color: AppTheme.gray400), // w-5 h-5 = 20px
              const SizedBox(width: 8), // gap-2 = 8px (matching React)
              DropdownButton<RiskTier?>(
                value: _filterRisk,
                hint: const Text('All Risk Tiers'),
                items: [
                  const DropdownMenuItem<RiskTier?>(
                      value: null, child: Text('All Risk Tiers')),
                  ...RiskTier.values.map((tier) => DropdownMenuItem(
                        value: tier,
                        child: Text('${tier.displayName} Risk'),
                      )),
                ],
                onChanged: (value) {
                  setState(() {
                    _filterRisk = value;
                  });
                },
              ),
              const SizedBox(width: 8), // gap-2 = 8px (matching React)
              DropdownButton<String>(
                value: _filterCohort,
                items: const [
                  DropdownMenuItem(value: 'All', child: Text('All Cohorts')),
                  DropdownMenuItem(value: 'Cardiac', child: Text('Cardiac')),
                  DropdownMenuItem(value: 'Diabetes', child: Text('Diabetes')),
                  DropdownMenuItem(value: 'Renal', child: Text('Renal')),
                ],
                onChanged: (value) {
                  setState(() {
                    _filterCohort = value ?? 'All';
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPatientList(List<Patient> patients) {
    final filteredPatients = patients.where((patient) {
      final matchesSearch = _searchQuery.isEmpty ||
          patient.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          patient.id.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesRisk =
          _filterRisk == null || patient.riskTier == _filterRisk;
      final matchesCohort =
          _filterCohort == 'All' || patient.cohort.contains(_filterCohort);
      return matchesSearch && matchesRisk && matchesCohort;
    }).toList();

    if (filteredPatients.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppTheme.gray200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            'No patients found matching your criteria',
            style: TextStyle(
              fontSize: TailwindFontSize.textSm,
              color: AppTheme.gray500,
              height: 1.5,
              letterSpacing: 0,
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.gray200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: filteredPatients.length,
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          thickness: 1,
          color: AppTheme.gray200,
        ),
        itemBuilder: (context, index) {
          return _buildPatientListItem(filteredPatients[index]);
        },
      ),
    );
  }

  Widget _buildPatientListItem(Patient patient) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => widget.onOpenPatient(patient),
        hoverColor: AppTheme.gray50,
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 24, vertical: 16), // px-6 py-4 (matching React table)
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Patient Name / ID
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      patient.name,
                      style: const TextStyle(
                        fontSize: TailwindFontSize.textSm, // text-sm = 14px
                        fontWeight: FontWeight.w600,
                        color: AppTheme.gray900,
                        height: 1.5,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      patient.id,
                      style: const TextStyle(
                        fontSize: TailwindFontSize.textXs, // text-xs = 12px
                        color: AppTheme.gray500,
                        height: 1.5,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
              // Risk Tier
              Expanded(
                child: RiskBadge(tier: patient.riskTier),
              ),
              // Last Evaluation (plain text, no background)
              Expanded(
                child: Text(
                  patient.lastEvaluation,
                  style: const TextStyle(
                    fontSize: TailwindFontSize.textSm, // text-sm = 14px
                    color: AppTheme.gray700, // text-gray-700
                    height: 1.5,
                    letterSpacing: 0,
                  ),
                ),
              ),
              // Next Recommended Action (plain text, no background)
              Expanded(
                flex: 2,
                child: Text(
                  patient.nextAction,
                  style: const TextStyle(
                    fontSize: TailwindFontSize.textSm, // text-sm = 14px
                    color: AppTheme.gray700, // text-gray-700
                    height: 1.5,
                    letterSpacing: 0,
                  ),
                ),
              ),
              // Status
              Expanded(
                child: StatusChip(status: patient.status),
              ),
              // Action Button
              Expanded(
                child: Material(
                  color: AppTheme.blue600,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: () => widget.onOpenPatient(patient),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8), // px-4 py-2
                      alignment: Alignment.center,
                      child: const Text(
                        'Review Patient',
                        style: TextStyle(
                          fontSize: TailwindFontSize.textSm, // text-sm = 14px
                          fontWeight: FontWeight.w500, // font-medium
                          color: Colors.white,
                          height: 1.5,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(TailwindSpacing.p3), // p-3 (reduced)
      decoration: BoxDecoration(
        color: AppTheme.amber50,
        border: Border.all(color: AppTheme.amber200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgIcons.alertTriangle(
              size: 20, color: AppTheme.amber600), // w-5 h-5 = 20px
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Clinical Decision Support Notice',
                  style: TextStyle(
                    fontSize: TailwindFontSize.textSm, // text-sm = 14px
                    fontWeight: FontWeight.w500, // font-medium (matching React)
                    color: AppTheme.amber900, // text-amber-900 (matching React)
                    height: 1.5,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 4), // mb-1 = 4px (matching React)
                const Text(
                  'AI recommendations are assistive and require clinical judgment. All decisions must be validated by a licensed healthcare provider.',
                  style: TextStyle(
                    fontSize: TailwindFontSize.textSm, // text-sm = 14px
                    color: AppTheme.amber800,
                    height: 1.5,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
