import '../entities/patient.dart';
import '../value_objects/risk_tier.dart';
import '../value_objects/status.dart';

abstract class PatientRepository {
  Future<List<Patient>> getAllPatients();
  Future<List<Patient>> searchPatients(String query);
  Future<List<Patient>> filterPatients({
    RiskTier? riskTier,
    String? cohort,
  });
  Future<Patient?> getPatientById(String id);
}
