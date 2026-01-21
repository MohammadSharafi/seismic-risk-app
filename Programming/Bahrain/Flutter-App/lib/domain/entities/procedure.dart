import 'package:equatable/equatable.dart';
import 'visit.dart' show EvidenceReference;

enum ProcedureSource {
  aiProposed,
  clinicianAdded;

  String get displayName {
    switch (this) {
      case ProcedureSource.aiProposed:
        return 'AI Proposed';
      case ProcedureSource.clinicianAdded:
        return 'Clinician Added';
    }
  }
}

enum ProcedureStatus {
  planned,
  notPlanned;

  String get displayName {
    switch (this) {
      case ProcedureStatus.planned:
        return 'Planned';
      case ProcedureStatus.notPlanned:
        return 'Not Planned';
    }
  }
}

class Procedure extends Equatable {
  final String id;
  final String name;
  final String? timing;
  final String rationale;
  final List<EvidenceReference> evidenceReferences;
  final ProcedureSource source;
  final ProcedureStatus status;

  const Procedure({
    required this.id,
    required this.name,
    this.timing,
    required this.rationale,
    required this.evidenceReferences,
    required this.source,
    required this.status,
  });

  Procedure copyWith({
    String? id,
    String? name,
    String? timing,
    String? rationale,
    List<EvidenceReference>? evidenceReferences,
    ProcedureSource? source,
    ProcedureStatus? status,
  }) {
    return Procedure(
      id: id ?? this.id,
      name: name ?? this.name,
      timing: timing ?? this.timing,
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
        timing,
        rationale,
        evidenceReferences,
        source,
        status,
      ];
}
