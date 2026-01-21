import 'package:equatable/equatable.dart';
import 'patient.dart';

enum AlarmSeverity {
  low,
  medium,
  high;

  String get displayName {
    switch (this) {
      case AlarmSeverity.low:
        return 'Low';
      case AlarmSeverity.medium:
        return 'Medium';
      case AlarmSeverity.high:
        return 'High';
    }
  }
}

enum AlarmType {
  aiTriggered,
  systemAlert;

  String get displayName {
    switch (this) {
      case AlarmType.aiTriggered:
        return 'AI-Triggered';
      case AlarmType.systemAlert:
        return 'System Alert';
    }
  }
}

enum AlarmStatus {
  open,
  acknowledged,
  resolved;

  String get displayName {
    switch (this) {
      case AlarmStatus.open:
        return 'Open';
      case AlarmStatus.acknowledged:
        return 'Acknowledged';
      case AlarmStatus.resolved:
        return 'Resolved';
    }
  }
}

class Alarm extends Equatable {
  final String id;
  final Patient patient;
  final String summary;
  final String timeTriggered;
  final bool acknowledged;
  final AlarmSeverity? severity;
  final AlarmType? type;
  final AlarmStatus? status;
  final String? acknowledgedBy;
  final String? acknowledgedAt;
  final String? visitId;

  const Alarm({
    required this.id,
    required this.patient,
    required this.summary,
    required this.timeTriggered,
    required this.acknowledged,
    this.severity,
    this.type,
    this.status,
    this.acknowledgedBy,
    this.acknowledgedAt,
    this.visitId,
  });

  @override
  List<Object?> get props => [
        id,
        patient,
        summary,
        timeTriggered,
        acknowledged,
        severity,
        type,
        status,
        acknowledgedBy,
        acknowledgedAt,
        visitId,
      ];
}
