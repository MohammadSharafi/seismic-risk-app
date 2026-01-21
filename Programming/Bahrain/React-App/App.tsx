import { useState } from 'react';
import { LoginPage } from './components/LoginPage';
import { DoctorDashboard } from './components/DoctorDashboard';
import { API_BASE_URL } from './src/config';
import { ClinicalDiscussion } from './components/ClinicalDiscussion';
import { ClinicalDiscussionPreview } from './components/ClinicalDiscussionPreview';
import { VisitTimeline } from './components/VisitTimeline';
// import { DecisionHistory } from './components/DecisionHistory'; // Commented out - audit log section disabled
import { VisitAnalysisFlow } from './components/VisitAnalysisFlow';
import { FullTimeline } from './components/FullTimeline';
import { PatientFullRecord } from './components/PatientFullRecord';
import { ClinicalSummary } from './components/ClinicalSummary';
import { FullClinicalSummary } from './components/FullClinicalSummary';
import { BackgroundMonitoring } from './components/BackgroundMonitoring';
import { RiskBadge } from './components/RiskBadge';
import { ChevronRight, Activity, FileText, MessageSquare, Shield, Clock, ArrowLeft } from 'lucide-react';

export type RiskTier = 'Low' | 'Medium' | 'High' | 'Critical';
export type Status = 'Monitoring' | 'Needs Review' | 'Action Taken';

export interface Patient {
  id: string;
  name: string;
  age: number;
  sex: string;
  twinId: string;
  riskTier: RiskTier;
  lastEvaluation: string;
  nextAction: string;
  status: Status;
  cohort: string[];
  conditions: string[];
  medications: string[];
  detailedConditions?: any[]; // Detailed condition data from BigQuery
  detailedMedications?: any[]; // Detailed medication data from BigQuery
  vitals?: {
    bloodPressure: string;
    heartRate: string;
    temperature: string;
  };
  clinicalSummary?: {
    summary_text?: string;
    summary_json?: any;
    summary_version?: string;
    as_of_time?: string;
    watermark?: string;
    created_at?: string;
  };
}

export interface Practitioner {
  id: string;
  name: string;
  email: string;
  specialty?: string;
  role?: string;
  phone?: string;
}

export default function App() {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [currentView, setCurrentView] = useState<'dashboard' | 'patient' | 'full-record' | 'full-clinical-summary'>('dashboard'); // 'audit' removed - audit log section disabled
  const [selectedPatient, setSelectedPatient] = useState<Patient | null>(null);
  const [activeSection, setActiveSection] = useState<'visit-flow' | 'info'>('visit-flow');
  const [infoTab, setInfoTab] = useState<'summary' | 'history' | 'discussion' | 'monitoring'>('summary'); // 'decisions' removed - audit log disabled
  const [showFullDiscussion, setShowFullDiscussion] = useState(false);
  const [showFullTimeline, setShowFullTimeline] = useState(false);
  const [selectedVisitId, setSelectedVisitId] = useState<string | null>(null);
  const [isLoadingPatientDetails, setIsLoadingPatientDetails] = useState(false);
  const [loggedInPractitioner, setLoggedInPractitioner] = useState<Practitioner | null>(null);

  const handleLogin = (email: string, password: string, practitionerData?: any) => {
    console.log('Login successful:', { email, practitionerData });
    
    // Store practitioner data
    if (practitionerData) {
      setLoggedInPractitioner({
        id: practitionerData.id || practitionerData.practitioner_id || '',
        name: practitionerData.name || practitionerData.full_name || 'Unknown Doctor',
        email: practitionerData.email || email,
        specialty: practitionerData.specialty || '',
        role: practitionerData.role || '',
        phone: practitionerData.phone || '',
      });
    } else {
      // Fallback if no data provided
      setLoggedInPractitioner({
        id: '',
        name: 'Unknown Doctor',
        email: email,
        specialty: '',
        role: '',
      });
    }
    
    setIsAuthenticated(true);
  };

  const handleOpenPatient = async (patient: Patient) => {
    // Set loading state
    setIsLoadingPatientDetails(true);
    setSelectedPatient(patient);
    setCurrentView('patient');
    setActiveSection('visit-flow');
    setShowFullDiscussion(false);
    setShowFullTimeline(false);

    // Fetch full patient details including clinical summary
    try {
      const response = await fetch(`${API_BASE_URL}/patients/${patient.id}/details`, {
        headers: {
          'X-User-Id': 'doctor-001',
          'X-User-Role': 'DOCTOR',
        },
      });

      if (response.ok) {
        const result = await response.json();
        const patientDetails = result.data;
        
        if (patientDetails) {
          // Update patient with full details including clinical summary and vitals
          setSelectedPatient({
            ...patient,
            conditions: patientDetails.conditions || patient.conditions,
            medications: patientDetails.medications || patient.medications,
            cohort: patientDetails.cohort || patient.cohort,
            detailedConditions: patientDetails.detailedConditions,
            detailedMedications: patientDetails.detailedMedications,
            clinicalSummary: patientDetails.clinicalSummary,
            vitals: patientDetails.vitals ? {
              bloodPressure: (patientDetails.vitals.bloodPressure as string) || '',
              heartRate: (patientDetails.vitals.heartRate as string) || '',
              temperature: (patientDetails.vitals.temperature as string) || '',
            } : undefined,
          });
        }
      }
    } catch (err) {
      console.error('Error fetching patient details:', err);
      // Continue with basic patient data if fetch fails
    } finally {
      // Clear loading state once fetch completes (success or error)
      setIsLoadingPatientDetails(false);
    }
  };

  const handleBackToDashboard = () => {
    setCurrentView('dashboard');
    setSelectedPatient(null);
  };

  // Audit log handler - commented out
  // const handleOpenAuditLog = () => {
  //   setCurrentView('audit');
  // };

  const handleBackToPatient = () => {
    setCurrentView('patient');
  };

  const handleOpenFullRecord = () => {
    setCurrentView('full-record');
  };

  const handleBackToPatientFromRecord = () => {
    setCurrentView('patient');
  };

  const handleOpenFullClinicalSummary = () => {
    setCurrentView('full-clinical-summary');
  };

  const handleOpenClinicalDiscussionFromVisit = () => {
    setInfoTab('discussion');
    setActiveSection('info');
  };

  const handleOpenDiscussionFromTimeline = (visitId: string) => {
    setSelectedVisitId(visitId);
    setShowFullTimeline(false);
    setShowFullDiscussion(true);
  };

  const handleViewVisitFromDiscussion = (visitId: string) => {
    setSelectedVisitId(visitId);
    setShowFullDiscussion(false);
    setShowFullTimeline(true);
  };

  const handleStartNewVisit = () => {
    setShowFullTimeline(false);
    setActiveSection('visit-flow');
  };

  // Show login page if not authenticated
  if (!isAuthenticated) {
    return <LoginPage onLogin={handleLogin} />;
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {currentView === 'dashboard' && (
        <DoctorDashboard 
          onOpenPatient={handleOpenPatient}
          loggedInPractitioner={loggedInPractitioner}
        />
      )}
      
      {currentView === 'patient' && selectedPatient && (
        <div className="min-h-screen">
          {/* Header */}
          <header className="bg-white border-b border-gray-200 shadow-sm">
            <div className="px-6 py-3">
              <button
                onClick={handleBackToDashboard}
                className="text-xs text-blue-600 hover:text-blue-700 mb-2 flex items-center gap-1 font-medium transition-colors"
              >
                <ArrowLeft className="w-3.5 h-3.5" />
                Back to Dashboard
              </button>
              
              <div className="flex items-center gap-3">
                {/* Patient Avatar */}
                <div className="w-10 h-10 bg-gradient-to-br from-blue-500 to-blue-600 rounded-lg flex items-center justify-center shadow-sm flex-shrink-0">
                  <span className="text-sm font-bold text-white">
                    {selectedPatient.name.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2)}
                  </span>
                </div>
                
                {/* Patient Info */}
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2 mb-1">
                    <h1 className="text-lg font-semibold text-gray-900 truncate">{selectedPatient.name}</h1>
                  </div>
                  <div className="flex items-center gap-2 text-xs text-gray-600">
                    <span>{selectedPatient.age} years</span>
                    <span>•</span>
                    <span>{selectedPatient.sex}</span>
                    <span>•</span>
                    <span className="font-mono text-gray-500">Twin ID: {selectedPatient.twinId}</span>
                  </div>
                </div>
              </div>
            </div>
          </header>

          {/* Loading State */}
          {isLoadingPatientDetails && (
            <div className="flex items-center justify-center min-h-[500px] bg-gray-50">
              <div className="text-center">
                <div className="mb-6 flex justify-center">
                  <div className="relative">
                    <div className="w-12 h-12 border-4 border-blue-200 rounded-full"></div>
                    <div className="w-12 h-12 border-4 border-blue-600 border-t-transparent rounded-full animate-spin absolute top-0 left-0"></div>
                  </div>
                </div>
                <h3 className="text-lg font-semibold text-gray-900 mb-1">Loading patient data</h3>
                <p className="text-sm text-gray-500">Please wait...</p>
              </div>
            </div>
          )}

          {/* Main Layout - Two Sections (only show when not loading) */}
          {!isLoadingPatientDetails && (
          <div className="grid grid-cols-3 gap-6 p-8">
            {/* Section A - Visit & Analysis Flow (Primary - 2 columns) */}
            <div className="col-span-2">
              <div className="mb-4">
                <div className="flex items-center gap-2 mb-2">
                  <div className="w-2 h-2 bg-blue-600 rounded-full"></div>
                  <h2 className="font-semibold text-gray-900">Active Visit & Analysis</h2>
                  <span className="px-2 py-0.5 bg-blue-100 text-blue-700 text-xs font-medium rounded">
                    Current
                  </span>
                </div>
                <p className="text-sm text-gray-600">Step-by-step clinical workflow</p>
              </div>
              
              <VisitAnalysisFlow 
                patient={selectedPatient} 
                onViewFullRecord={handleOpenFullRecord}
                onViewClinicalDiscussion={handleOpenClinicalDiscussionFromVisit}
                visitTrigger={{
                  type: 'Background Monitoring Alert',
                  timestamp: 'Jan 8, 2026 09:15 AM',
                  source: 'AI'
                }}
                discussionReferenced={false}
                loggedInPractitioner={loggedInPractitioner}
              />
            </div>

            {/* Section B - Patient Information & History (Secondary - 1 column) */}
            <div className="col-span-1">
              <div className="mb-4">
                <h2 className="font-semibold text-gray-900 mb-2">Patient Information</h2>
                <p className="text-sm text-gray-600">Historical data and records</p>
              </div>

              {/* Tab Navigation */}
              <div className="bg-white rounded-lg border border-gray-200 overflow-hidden shadow-sm">
                <div className="bg-gray-50 px-4 py-2 border-b border-gray-200">
                  <h3 className="text-xs font-semibold text-gray-500 uppercase tracking-wide">Patient Information</h3>
                </div>
                <div className="divide-y divide-gray-100">
                  <button
                    onClick={() => setInfoTab('summary')}
                    className={`w-full text-left px-4 py-3 text-sm flex items-center gap-3 transition-all ${
                      infoTab === 'summary' 
                        ? 'bg-blue-50 text-blue-700 font-semibold border-l-4 border-blue-600' 
                        : 'text-gray-700 hover:bg-gray-50 hover:text-gray-900'
                    }`}
                  >
                    <Activity className={`w-4 h-4 flex-shrink-0 ${infoTab === 'summary' ? 'text-blue-600' : 'text-gray-400'}`} />
                    <span>Clinical Summary</span>
                  </button>
                  <button
                    onClick={() => setInfoTab('history')}
                    className={`w-full text-left px-4 py-3 text-sm flex items-center gap-3 transition-all ${
                      infoTab === 'history' 
                        ? 'bg-blue-50 text-blue-700 font-semibold border-l-4 border-blue-600' 
                        : 'text-gray-700 hover:bg-gray-50 hover:text-gray-900'
                    }`}
                  >
                    <Clock className={`w-4 h-4 flex-shrink-0 ${infoTab === 'history' ? 'text-blue-600' : 'text-gray-400'}`} />
                    <span>Visit History</span>
                  </button>
                  {/* Audit Log tab - commented out */}
                  {/* <button
                    onClick={() => setInfoTab('decisions')}
                    className={`w-full text-left px-4 py-3 text-sm flex items-center gap-3 transition-all ${
                      infoTab === 'decisions' 
                        ? 'bg-blue-50 text-blue-700 font-semibold border-l-4 border-blue-600' 
                        : 'text-gray-700 hover:bg-gray-50 hover:text-gray-900'
                    }`}
                  >
                    <Shield className={`w-4 h-4 flex-shrink-0 ${infoTab === 'decisions' ? 'text-blue-600' : 'text-gray-400'}`} />
                    <span>Audit Log</span>
                  </button> */}
                  <button
                    onClick={() => setInfoTab('discussion')}
                    className={`w-full text-left px-4 py-3 text-sm flex items-center gap-3 transition-all ${
                      infoTab === 'discussion' 
                        ? 'bg-blue-50 text-blue-700 font-semibold border-l-4 border-blue-600' 
                        : 'text-gray-700 hover:bg-gray-50 hover:text-gray-900'
                    }`}
                  >
                    <MessageSquare className={`w-4 h-4 flex-shrink-0 ${infoTab === 'discussion' ? 'text-blue-600' : 'text-gray-400'}`} />
                    <span>Clinical Discussion</span>
                  </button>
                  <button
                    onClick={() => setInfoTab('monitoring')}
                    className={`w-full text-left px-4 py-3 text-sm flex items-center gap-3 transition-all ${
                      infoTab === 'monitoring' 
                        ? 'bg-blue-50 text-blue-700 font-semibold border-l-4 border-blue-600' 
                        : 'text-gray-700 hover:bg-gray-50 hover:text-gray-900'
                    }`}
                  >
                    <FileText className={`w-4 h-4 flex-shrink-0 ${infoTab === 'monitoring' ? 'text-blue-600' : 'text-gray-400'}`} />
                    <span>Background Monitoring</span>
                  </button>
                </div>

                {/* Tab Content */}
                <div className="p-4 max-h-[calc(100vh-20rem)] overflow-y-auto">
                  {infoTab === 'summary' && (
                    <ClinicalSummary patient={selectedPatient} onViewFullSummary={handleOpenFullClinicalSummary} />
                  )}

                  {infoTab === 'history' && selectedPatient && (
                    <div className="space-y-3">
                      <VisitTimeline 
                        patient={selectedPatient} 
                        onViewFullTimeline={() => setShowFullTimeline(true)}
                      />
                    </div>
                  )}

                  {/* Audit Log tab content - commented out */}
                  {/* {infoTab === 'decisions' && (
                    <div>
                      <h3 className="font-medium text-gray-900 mb-3">Audit Log</h3>
                      <p className="text-sm text-gray-600 mb-3">Recent audit entries</p>
                      <div className="space-y-2 mb-3">
                        {[
                          { 
                            date: 'Jan 8, 2026 11:15 AM', 
                            action: 'Approved Clinical Decision', 
                            actor: 'Dr. Rebecca Smith',
                            type: 'Final Decision'
                          },
                          { 
                            date: 'Jan 8, 2026 10:45 AM', 
                            action: 'Generated Risk Assessment', 
                            actor: 'AI Clinical System',
                            type: 'AI Output'
                          },
                          { 
                            date: 'Jan 6, 2026 3:15 PM', 
                            action: 'Modified Risk Assessment', 
                            actor: 'Dr. Rebecca Smith',
                            type: 'Doctor Edit'
                          }
                        ].map((entry, idx) => (
                          <div key={idx} className="p-3 border border-gray-200 rounded-lg bg-gray-50">
                            <div className="flex items-center gap-2 mb-1">
                              <span className={`text-xs px-2 py-0.5 font-medium rounded ${
                                entry.type === 'AI Output' ? 'bg-purple-100 text-purple-700' :
                                entry.type === 'Doctor Edit' ? 'bg-blue-100 text-blue-700' :
                                'bg-green-100 text-green-700'
                              }`}>
                                {entry.type}
                              </span>
                            </div>
                            <div className="text-sm font-medium text-gray-900 mb-1">{entry.action}</div>
                            <div className="text-xs text-gray-600 mb-1">{entry.actor}</div>
                            <div className="text-xs text-gray-500">{entry.date}</div>
                          </div>
                        ))}
                      </div>
                      <button 
                        onClick={handleOpenAuditLog}
                        className="w-full mt-2 px-3 py-2 text-sm text-blue-600 hover:text-blue-700 border border-blue-200 rounded-lg hover:bg-blue-50 transition-colors">
                        View Full Audit Log
                      </button>
                    </div>
                  )} */}

                  {infoTab === 'discussion' && (
                    <ClinicalDiscussionPreview 
                      patient={selectedPatient}
                      visitId={selectedVisitId}
                      onOpenFull={() => setShowFullDiscussion(true)}
                    />
                  )}

                  {infoTab === 'monitoring' && selectedPatient && (
                    <BackgroundMonitoring patient={selectedPatient} />
                  )}
                </div>
              </div>
            </div>
          </div>
          )}

          {/* Full Screen Modals for expanded views */}
          {showFullDiscussion && selectedPatient && (
            <ClinicalDiscussion 
              patient={selectedPatient}
              visitId={selectedVisitId || undefined}
              onClose={() => setShowFullDiscussion(false)}
              onViewVisit={handleViewVisitFromDiscussion}
              loggedInPractitioner={loggedInPractitioner}
            />
          )}

          {showFullTimeline && selectedPatient && (
            <FullTimeline
              patient={selectedPatient}
              onClose={() => setShowFullTimeline(false)}
              onStartNewVisit={handleStartNewVisit}
              onOpenDiscussion={handleOpenDiscussionFromTimeline}
            />
          )}
        </div>
      )}

      {/* Full-Page Audit Log View - commented out */}
      {/* {currentView === 'audit' && selectedPatient && (
        <DecisionHistory 
          patient={selectedPatient} 
          onBack={handleBackToPatient} 
        />
      )} */}

      {/* Full-Page Patient Record View */}
      {currentView === 'full-record' && selectedPatient && (
        <PatientFullRecord 
          patient={selectedPatient} 
          onBack={handleBackToPatientFromRecord} 
        />
      )}

      {/* Full-Page Clinical Summary View */}
      {currentView === 'full-clinical-summary' && selectedPatient && (
        <FullClinicalSummary 
          patient={selectedPatient} 
          onBack={() => setCurrentView('patient')} 
        />
      )}
    </div>
  );
}