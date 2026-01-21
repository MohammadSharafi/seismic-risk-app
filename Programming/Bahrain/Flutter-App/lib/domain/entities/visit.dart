import 'package:equatable/equatable.dart';
import '../value_objects/risk_tier.dart';

enum VisitType {
  manual,
  followUp,
  background;

  String get displayName {
    switch (this) {
      case VisitType.manual:
        return 'Manual';
      case VisitType.followUp:
        return 'Follow-up';
      case VisitType.background:
        return 'Background';
    }
  }
}

enum VisitStatus {
  completed,
  draft;

  String get displayName {
    switch (this) {
      case VisitStatus.completed:
        return 'Completed';
      case VisitStatus.draft:
        return 'Draft';
    }
  }
}

class AIAnalysis extends Equatable {
  final RiskTier riskTier;
  final List<String> reasoning;
  final List<EvidenceReference> evidenceReferences;
  final String timestamp;
  final String modelVersion;
  final bool reviewedByDoctor;

  const AIAnalysis({
    required this.riskTier,
    required this.reasoning,
    required this.evidenceReferences,
    required this.timestamp,
    required this.modelVersion,
    required this.reviewedByDoctor,
  });

  @override
  List<Object?> get props => [
        riskTier,
        reasoning,
        evidenceReferences,
        timestamp,
        modelVersion,
        reviewedByDoctor,
      ];
}

class EvidenceReference extends Equatable {
  final String type;
  final String label;

  const EvidenceReference({
    required this.type,
    required this.label,
  });

  @override
  List<Object?> get props => [type, label];
}

class DoctorDecision extends Equatable {
  final RiskTier riskTier;
  final String recommendation;
  final String notes;
  final String doctorName;
  final String timestamp;

  const DoctorDecision({
    required this.riskTier,
    required this.recommendation,
    required this.notes,
    required this.doctorName,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
        riskTier,
        recommendation,
        notes,
        doctorName,
        timestamp,
      ];
}

class VisitOutcome extends Equatable {
  final String status;
  final String? details;

  const VisitOutcome({
    required this.status,
    this.details,
  });

  @override
  List<Object?> get props => [status, details];
}

class Visit extends Equatable {
  final String id;
  final String date;
  final VisitType visitType;
  final VisitStatus status;
  final String triggerSource;
  final PatientState patientState;
  final AIAnalysis aiAnalysis;
  final DoctorDecision doctorDecision;
  final VisitOutcome outcome;
  final bool hasAlarms;
  final bool hasDiscussion;

  const Visit({
    required this.id,
    required this.date,
    required this.visitType,
    required this.status,
    required this.triggerSource,
    required this.patientState,
    required this.aiAnalysis,
    required this.doctorDecision,
    required this.outcome,
    required this.hasAlarms,
    required this.hasDiscussion,
  });

  @override
  List<Object?> get props => [
        id,
        date,
        visitType,
        status,
        triggerSource,
        patientState,
        aiAnalysis,
        doctorDecision,
        outcome,
        hasAlarms,
        hasDiscussion,
      ];
}

class PatientState extends Equatable {
  final List<String> conditions;
  final String dataFreshness;

  const PatientState({
    required this.conditions,
    required this.dataFreshness,
  });

  @override
  List<Object?> get props => [conditions, dataFreshness];
}
