import '../entities/alarm.dart';
import '../value_objects/risk_tier.dart';

abstract class AlarmRepository {
  Future<List<Alarm>> getAllAlarms();
  Future<List<Alarm>> filterAlarms({
    RiskTier? riskTier,
    String? status,
  });
  Future<void> acknowledgeAlarm(String alarmId);
}
