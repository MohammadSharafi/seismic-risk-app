import 'package:equatable/equatable.dart';
import 'visit.dart' show EvidenceReference;

enum MedicationSource {
  aiProposed,
  clinicianAdded;

  String get displayName {
    switch (this) {
      case MedicationSource.aiProposed:
        return 'AI Proposed';
      case MedicationSource.clinicianAdded:
        return 'Clinician Added';
    }
  }
}

enum MedicationStatus {
  planned,
  notPlanned;

  String get displayName {
    switch (this) {
      case MedicationStatus.planned:
        return 'Planned';
      case MedicationStatus.notPlanned:
        return 'Not Planned';
    }
  }
}

class Medication extends Equatable {
  final String id;
  final String name;
  final String dose;
  final String route;
  final String frequency;
  final String? duration;
  final String rationale;
  final List<EvidenceReference> evidenceReferences;
  final MedicationSource source;
  final MedicationStatus status;

  const Medication({
    required this.id,
    required this.name,
    required this.dose,
    required this.route,
    required this.frequency,
    this.duration,
    required this.rationale,
    required this.evidenceReferences,
    required this.source,
    required this.status,
  });

  Medication copyWith({
    String? id,
    String? name,
    String? dose,
    String? route,
    String? frequency,
    String? duration,
    String? rationale,
    List<EvidenceReference>? evidenceReferences,
    MedicationSource? source,
    MedicationStatus? status,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      dose: dose ?? this.dose,
      route: route ?? this.route,
      frequency: frequency ?? this.frequency,
      duration: duration ?? this.duration,
      rationale: rationale ?? this.rationale,
      evidenceReferences: evidenceReferences ?? this.evidenceReferences,
      source: source ?? this.source,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        dose,
        route,
        frequency,
        duration,
        rationale,
        evidenceReferences,
        source,
        status,
      ];
}
