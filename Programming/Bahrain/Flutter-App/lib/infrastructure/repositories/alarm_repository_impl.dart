import '../../domain/entities/alarm.dart';
import '../../domain/repositories/alarm_repository.dart';
import '../../domain/value_objects/risk_tier.dart';
import '../data_sources/mock_patient_data_source.dart';

class AlarmRepositoryImpl implements AlarmRepository {
  final MockPatientDataSource _dataSource = MockPatientDataSource();
  final List<Alarm> _alarms = [];

  AlarmRepositoryImpl() {
    _initializeAlarms();
  }

  void _initializeAlarms() {
    final patients = _dataSource.getMockPatients();
    _alarms.addAll([
      Alarm(
        id: 'A001',
        patient: patients[0],
        summary: 'Critical BP spike detected - 152/92 mmHg',
        timeTriggered: '2 hours ago',
        acknowledged: false,
        severity: AlarmSeverity.high,
        type: AlarmType.aiTriggered,
        status: AlarmStatus.open,
      ),
      Alarm(
        id: 'A002',
        patient: patients[3],
        summary: 'Irregular heart rhythm pattern identified',
        timeTriggered: '4 hours ago',
        acknowledged: false,
        severity: AlarmSeverity.high,
        type: AlarmType.aiTriggered,
        status: AlarmStatus.open,
      ),
    ]);
  }

  @override
  Future<List<Alarm>> getAllAlarms() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _alarms;
  }

  @override
  Future<List<Alarm>> filterAlarms({
    RiskTier? riskTier,
    String? status,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _alarms.where((alarm) {
      final matchesRisk = riskTier == null || alarm.patient.riskTier == riskTier;
      final matchesStatus = status == null ||
          status == 'All' ||
          (status == 'New' && !alarm.acknowledged) ||
          (status == 'Acknowledged' && alarm.acknowledged);
      return matchesRisk && matchesStatus;
    }).toList();
  }

  @override
  Future<void> acknowledgeAlarm(String alarmId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _alarms.indexWhere((alarm) => alarm.id == alarmId);
    if (index != -1) {
      final alarm = _alarms[index];
      _alarms[index] = Alarm(
        id: alarm.id,
        patient: alarm.patient,
        summary: alarm.summary,
        timeTriggered: alarm.timeTriggered,
        acknowledged: true,
        severity: alarm.severity,
        type: alarm.type,
        status: AlarmStatus.acknowledged,
        acknowledgedBy: 'Dr. Rebecca Smith',
        acknowledgedAt: DateTime.now().toString(),
        visitId: alarm.visitId,
      );
    }
  }
}
