import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'doctor_dashboard_page.dart';
import 'patient_detail_page.dart';
import 'full_timeline_page.dart';
import 'patient_full_record_page.dart';
import 'full_clinical_summary_page.dart';
import 'clinical_discussion_page.dart';
import 'decision_history_page.dart';
import '../../domain/entities/patient.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  String _currentView = 'dashboard';
  Patient? _selectedPatient;
  bool _showFullDiscussion = false;
  bool _showFullTimeline = false;
  String? _selectedVisitId;

  void _handleOpenPatient(Patient patient) {
    setState(() {
      _selectedPatient = patient;
      _currentView = 'patient';
      _showFullDiscussion = false;
      _showFullTimeline = false;
    });
  }

  void _handleBackToDashboard() {
    setState(() {
      _currentView = 'dashboard';
      _selectedPatient = null;
      _showFullDiscussion = false;
      _showFullTimeline = false;
    });
  }

  void _handleOpenFullRecord() {
    setState(() {
      _currentView = 'full-record';
    });
  }

  void _handleBackToPatientFromRecord() {
    setState(() {
      _currentView = 'patient';
    });
  }

  void _handleOpenFullClinicalSummary() {
    setState(() {
      _currentView = 'full-clinical-summary';
    });
  }

  void _handleBackToPatientFromSummary() {
    setState(() {
      _currentView = 'patient';
    });
  }

  void _handleOpenAuditLog() {
    setState(() {
      _currentView = 'audit';
    });
  }

  void _handleBackToPatientFromAudit() {
    setState(() {
      _currentView = 'patient';
    });
  }

  void _handleOpenClinicalDiscussionFromVisit() {
    setState(() {
      _showFullDiscussion = true;
    });
  }

  void _handleOpenDiscussionFromTimeline(String visitId) {
    setState(() {
      _selectedVisitId = visitId;
      _showFullTimeline = false;
      _showFullDiscussion = true;
    });
  }

  void _handleViewVisitFromDiscussion(String visitId) {
    setState(() {
      _selectedVisitId = visitId;
      _showFullDiscussion = false;
      _showFullTimeline = true;
    });
  }

  void _handleStartNewVisit() {
    setState(() {
      _showFullTimeline = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentView == 'dashboard') {
      return DoctorDashboardPage(
        onOpenPatient: _handleOpenPatient,
      );
    } else if (_currentView == 'patient' && _selectedPatient != null) {
      return Stack(
        children: [
          PatientDetailPage(
            patient: _selectedPatient!,
            onBack: _handleBackToDashboard,
            onViewFullRecord: _handleOpenFullRecord,
            onViewFullClinicalSummary: _handleOpenFullClinicalSummary,
            onViewAuditLog: _handleOpenAuditLog,
            onViewFullTimeline: () => setState(() => _showFullTimeline = true),
            onViewFullDiscussion: _handleOpenClinicalDiscussionFromVisit,
          ),
          if (_showFullDiscussion && _selectedPatient != null)
            ClinicalDiscussionPage(
              patient: _selectedPatient!,
              visitId: _selectedVisitId,
              onClose: () => setState(() => _showFullDiscussion = false),
              onViewVisit: _handleViewVisitFromDiscussion,
            ),
          if (_showFullTimeline && _selectedPatient != null)
            FullTimelinePage(
              patient: _selectedPatient!,
              onClose: () => setState(() => _showFullTimeline = false),
              onStartNewVisit: _handleStartNewVisit,
              onOpenDiscussion: _handleOpenDiscussionFromTimeline,
            ),
        ],
      );
    } else if (_currentView == 'full-record' && _selectedPatient != null) {
      return PatientFullRecordPage(
        patient: _selectedPatient!,
        onBack: _handleBackToPatientFromRecord,
      );
    } else if (_currentView == 'full-clinical-summary' && _selectedPatient != null) {
      return FullClinicalSummaryPage(
        patient: _selectedPatient!,
        onBack: _handleBackToPatientFromSummary,
      );
    } else if (_currentView == 'audit' && _selectedPatient != null) {
      return DecisionHistoryPage(
        patient: _selectedPatient!,
        onBack: _handleBackToPatientFromAudit,
      );
    }

    return const Scaffold(
      body: Center(child: Text('Unknown view')),
    );
  }
}
