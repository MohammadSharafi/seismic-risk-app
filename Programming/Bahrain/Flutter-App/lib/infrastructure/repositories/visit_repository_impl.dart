import '../../domain/entities/visit.dart';
import '../../domain/repositories/visit_repository.dart';
import '../../domain/value_objects/risk_tier.dart';
import '../data_sources/mock_patient_data_source.dart';

class VisitRepositoryImpl implements VisitRepository {
  final MockPatientDataSource _dataSource = MockPatientDataSource();

  @override
  Future<List<Visit>> getVisitsByPatientId(String patientId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _getMockVisits(patientId);
  }

  @override
  Future<List<Visit>> filterVisits({
    String? patientId,
    VisitType? visitType,
    RiskTier? riskTier,
    String? searchQuery,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    var visits = _getMockVisits(patientId ?? 'P001');
    
    if (visitType != null) {
      visits = visits.where((v) => v.visitType == visitType).toList();
    }
    
    if (riskTier != null) {
      visits = visits.where((v) =>
          v.aiAnalysis.riskTier == riskTier ||
          v.doctorDecision.riskTier == riskTier).toList();
    }
    
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      visits = visits.where((v) =>
          v.date.toLowerCase().contains(query) ||
          v.doctorDecision.notes.toLowerCase().contains(query)).toList();
    }
    
    return visits;
  }

  @override
  Future<Visit?> getVisitById(String visitId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final visits = _getMockVisits('P001');
    try {
      return visits.firstWhere((visit) => visit.id == visitId);
    } catch (e) {
      return null;
    }
  }

  List<Visit> _getMockVisits(String patientId) {
    return [
      Visit(
        id: 'V001',
        date: 'Jan 8, 2026 10:45 AM',
        visitType: VisitType.manual,
        status: VisitStatus.completed,
        triggerSource: 'Doctor-initiated',
        patientState: const PatientState(
          conditions: ['Atrial Fibrillation', 'Type 2 Diabetes', 'Hypertension'],
          dataFreshness: 'Current (updated today)',
        ),
        aiAnalysis: AIAnalysis(
          riskTier: RiskTier.high,
          reasoning: [
            'Multiple high-risk comorbidities detected',
            'Blood pressure elevated above target range (142/88)',
            'Medication interaction potential identified',
            'Historical trend shows progression over 6 months',
          ],
          evidenceReferences: const [
            EvidenceReference(type: 'vitals', label: 'BP Readings - Jan 1-8'),
            EvidenceReference(type: 'labs', label: 'HbA1c - Jan 5'),
            EvidenceReference(type: 'meds', label: 'Medication Review'),
          ],
          timestamp: 'Jan 8, 2026 10:45 AM',
          modelVersion: 'ClinicalAI v3.2.1',
          reviewedByDoctor: true,
        ),
        doctorDecision: DoctorDecision(
          riskTier: RiskTier.high,
          recommendation: 'Immediate medication adjustment. Increased Lisinopril to 20mg. Daily BP monitoring for 1 week.',
          notes: 'Agreed with AI assessment. Patient counseled on home BP monitoring protocol.',
          doctorName: 'Dr. Rebecca Smith',
          timestamp: 'Jan 8, 2026 11:15 AM',
        ),
        outcome: const VisitOutcome(
          status: 'Follow-up scheduled',
          details: 'Scheduled for Jan 15, 2026',
        ),
        hasAlarms: true,
        hasDiscussion: true,
      ),
      Visit(
        id: 'V002',
        date: 'Jan 6, 2026 2:30 PM',
        visitType: VisitType.background,
        status: VisitStatus.completed,
        triggerSource: 'Background monitoring',
        patientState: const PatientState(
          conditions: ['Atrial Fibrillation', 'Type 2 Diabetes', 'Hypertension'],
          dataFreshness: 'Current',
        ),
        aiAnalysis: AIAnalysis(
          riskTier: RiskTier.high,
          reasoning: [
            'Blood pressure spike detected (152/92)',
            'Anomaly detection algorithm flagged for immediate review',
          ],
          evidenceReferences: const [
            EvidenceReference(type: 'vitals', label: 'BP Alert - Jan 6'),
          ],
          timestamp: 'Jan 6, 2026 2:30 PM',
          modelVersion: 'ClinicalAI v3.2.1',
          reviewedByDoctor: true,
        ),
        doctorDecision: DoctorDecision(
          riskTier: RiskTier.medium,
          recommendation: 'Monitor for 48 hours before escalation. Patient reported recent stress event.',
          notes: 'Override AI suggestion. Clinical context: patient experiencing family stress. Will monitor before medication adjustment.',
          doctorName: 'Dr. Rebecca Smith',
          timestamp: 'Jan 6, 2026 3:15 PM',
        ),
        outcome: const VisitOutcome(
          status: 'Monitoring continued',
        ),
        hasAlarms: true,
        hasDiscussion: true,
      ),
      Visit(
        id: 'V003',
        date: 'Dec 28, 2025 9:15 AM',
        visitType: VisitType.followUp,
        status: VisitStatus.completed,
        triggerSource: 'Doctor-initiated',
        patientState: const PatientState(
          conditions: ['Atrial Fibrillation', 'Type 2 Diabetes', 'Hypertension'],
          dataFreshness: 'Current',
        ),
        aiAnalysis: AIAnalysis(
          riskTier: RiskTier.medium,
          reasoning: [
            'Stable vitals following medication adjustment',
            'Medication appears effective',
            'No adverse effects reported',
          ],
          evidenceReferences: const [
            EvidenceReference(type: 'vitals', label: 'Vitals - Dec 28'),
            EvidenceReference(type: 'labs', label: 'Metabolic Panel - Dec 27'),
          ],
          timestamp: 'Dec 28, 2025 9:15 AM',
          modelVersion: 'ClinicalAI v3.1.8',
          reviewedByDoctor: true,
        ),
        doctorDecision: DoctorDecision(
          riskTier: RiskTier.medium,
          recommendation: 'Continue current regimen. Schedule follow-up in 2 weeks.',
          notes: 'Patient tolerating medication well. No changes needed.',
          doctorName: 'Dr. Rebecca Smith',
          timestamp: 'Dec 28, 2025 9:45 AM',
        ),
        outcome: const VisitOutcome(
          status: 'Follow-up scheduled',
          details: 'Scheduled for Jan 6, 2026',
        ),
        hasAlarms: false,
        hasDiscussion: false,
      ),
    ];
  }
}
