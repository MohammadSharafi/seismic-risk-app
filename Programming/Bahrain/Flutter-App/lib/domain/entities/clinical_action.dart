import 'package:equatable/equatable.dart';

enum ClinicalActionType {
  medicationChange,
  referral,
  followUpScheduling,
  monitoringAdjustment,
  other;

  String get displayName {
    switch (this) {
      case ClinicalActionType.medicationChange:
        return 'Medication Change';
      case ClinicalActionType.referral:
        return 'Referral';
      case ClinicalActionType.followUpScheduling:
        return 'Follow-up Scheduling';
      case ClinicalActionType.monitoringAdjustment:
        return 'Monitoring Adjustment';
      case ClinicalActionType.other:
        return 'Other';
    }
  }
}

class ClinicalAction extends Equatable {
  final String id;
  final ClinicalActionType type;
  final String description;
  final String rationale;
  final String timestamp;
  final String? visitId;

  const ClinicalAction({
    required this.id,
    required this.type,
    required this.description,
    required this.rationale,
    required this.timestamp,
    this.visitId,
  });

  @override
  List<Object?> get props => [
        id,
        type,
        description,
        rationale,
        timestamp,
        visitId,
      ];
}
