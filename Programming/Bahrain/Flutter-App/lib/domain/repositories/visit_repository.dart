import '../entities/visit.dart';
import '../value_objects/risk_tier.dart';

abstract class VisitRepository {
  Future<List<Visit>> getVisitsByPatientId(String patientId);
  Future<List<Visit>> filterVisits({
    String? patientId,
    VisitType? visitType,
    RiskTier? riskTier,
    String? searchQuery,
  });
  Future<Visit?> getVisitById(String visitId);
}
