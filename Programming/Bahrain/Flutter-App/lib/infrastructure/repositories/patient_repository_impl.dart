import '../../domain/entities/patient.dart';
import '../../domain/repositories/patient_repository.dart';
import '../../domain/value_objects/risk_tier.dart';
import '../data_sources/mock_patient_data_source.dart';

class PatientRepositoryImpl implements PatientRepository {
  final MockPatientDataSource _dataSource = MockPatientDataSource();

  @override
  Future<List<Patient>> getAllPatients() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _dataSource.getMockPatients();
  }

  @override
  Future<List<Patient>> searchPatients(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final allPatients = _dataSource.getMockPatients();
    final lowerQuery = query.toLowerCase();
    return allPatients.where((patient) {
      return patient.name.toLowerCase().contains(lowerQuery) ||
          patient.id.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  @override
  Future<List<Patient>> filterPatients({
    RiskTier? riskTier,
    String? cohort,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final allPatients = _dataSource.getMockPatients();
    return allPatients.where((patient) {
      final matchesRisk = riskTier == null || patient.riskTier == riskTier;
      final matchesCohort = cohort == null ||
          cohort == 'All' ||
          patient.cohort.contains(cohort);
      return matchesRisk && matchesCohort;
    }).toList();
  }

  @override
  Future<Patient?> getPatientById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final allPatients = _dataSource.getMockPatients();
    try {
      return allPatients.firstWhere((patient) => patient.id == id);
    } catch (e) {
      return null;
    }
  }
}
