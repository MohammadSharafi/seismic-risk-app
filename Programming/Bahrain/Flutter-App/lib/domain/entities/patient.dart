import 'package:equatable/equatable.dart';
import '../value_objects/risk_tier.dart';
import '../value_objects/status.dart';
import 'vitals.dart';

class Patient extends Equatable {
  final String id;
  final String name;
  final int age;
  final String sex;
  final String twinId;
  final RiskTier riskTier;
  final String lastEvaluation;
  final String nextAction;
  final Status status;
  final List<String> cohort;
  final List<String> conditions;
  final List<String> medications;
  final Vitals? vitals;

  const Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.sex,
    required this.twinId,
    required this.riskTier,
    required this.lastEvaluation,
    required this.nextAction,
    required this.status,
    required this.cohort,
    required this.conditions,
    required this.medications,
    this.vitals,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        age,
        sex,
        twinId,
        riskTier,
        lastEvaluation,
        nextAction,
        status,
        cohort,
        conditions,
        medications,
        vitals,
      ];
}
