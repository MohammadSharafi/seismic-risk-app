import { useState, useEffect } from 'react';
import { Patient } from '../App';
import { RiskBadge } from './RiskBadge';
import { API_BASE_URL } from '../src/config';
import { 
  ChevronDown, 
  ChevronUp, 
  Activity, 
  Brain, 
  User, 
  FileCheck, 
  MessageSquare, 
  AlertTriangle,
  Shield,
  Calendar,
  Clock
} from 'lucide-react';

interface PatientFullRecordProps {
  patient: Patient;
  onBack: () => void;
}

interface VisitRecord {
  id: string;
  date: string;
  type: 'Manual' | 'Follow-up' | 'Background';
  status: 'Completed';
  aiAnalysis: {
    riskTier: 'Low' | 'Medium' | 'High';
    reasoning: string[];
    model: string;
    timestamp: string;
  };
  doctorDecision: {
    riskTier: 'Low' | 'Medium' | 'High';
    doctor: string;
    notes: string;
    timestamp: string;
  };
  outcome: {
    type: 'Follow-up Scheduled' | 'Continue Monitoring' | 'No Action Required';
    details: string;
  };
}

interface DiscussionEntry {
  id: string;
  visitId: string;
  doctor: string;
  timestamp: string;
  message: string;
  type: 'clinical-note' | 'ai-question' | 'ai-response';
}

interface AlarmRecord {
  id: string;
  visitId: string;
  timestamp: string;
  severity: 'High' | 'Medium' | 'Low';
  type: 'AI-Triggered' | 'System Alert';
  description: string;
  status: 'Open' | 'Acknowledged' | 'Resolved';
  acknowledgedBy?: string;
  acknowledgedAt?: string;
}

interface AuditEntry {
  id: string;
  timestamp: string;
  action: string;
  actor: string;
  actorType: 'AI' | 'Doctor' | 'System';
  details: string;
  visitId?: string;
}

export function PatientFullRecord({ patient, onBack }: PatientFullRecordProps) {
  const [expandedVisits, setExpandedVisits] = useState<Set<string>>(new Set());
  const [visitHistory, setVisitHistory] = useState<VisitRecord[]>([]);
  const [discussions, setDiscussions] = useState<DiscussionEntry[]>([]);
  const [alarms, setAlarms] = useState<AlarmRecord[]>([]);
  const [auditLog, setAuditLog] = useState<AuditEntry[]>([]);
  const [loading, setLoading] = useState(true);
  const [lastDataSync, setLastDataSync] = useState<string>('');

  // Normalize risk tier
  const normalizeRiskTier = (tier: string | undefined): 'Low' | 'Medium' | 'High' => {
    if (!tier) return 'Medium';
    const upper = tier.toUpperCase();
    if (upper === 'HIGH') return 'High';
    if (upper === 'LOW') return 'Low';
    return 'Medium';
  };

  useEffect(() => {
    const fetchAllData = async () => {
      try {
        setLoading(true);
        
        // Fetch visit history
        const visitResponse = await fetch(`${API_BASE_URL}/analyze/visit-history/${patient.id}`);
        if (visitResponse.ok) {
          const visitResult = await visitResponse.json();
          if (visitResult.data) {
            const mappedVisits: VisitRecord[] = visitResult.data.map((v: any) => ({
              id: v.visit_id,
              date: v.visit_date ? new Date(v.visit_date).toLocaleDateString('en-US', {
                year: 'numeric',
                month: 'short',
                day: 'numeric',
                hour: 'numeric',
                minute: '2-digit'
              }) : 'Unknown date',
              type: (v.visit_type || v.trigger_source || '').toLowerCase().includes('background') 
                ? 'Background' as const
                : (v.visit_type || '').toLowerCase().includes('follow') 
                  ? 'Follow-up' as const
                  : 'Manual' as const,
              status: 'Completed' as const,
              aiAnalysis: {
                riskTier: normalizeRiskTier(v.ai_analysis?.risk_tier),
                reasoning: Array.isArray(v.ai_analysis?.reasoning) 
                  ? v.ai_analysis.reasoning 
                  : (v.ai_analysis?.reasoning ? [v.ai_analysis.reasoning] : []),
                model: v.ai_analysis?.model_version || 'ClinicalAI v3.2.1',
                timestamp: v.ai_analysis?.timestamp || v.visit_date || ''
              },
              doctorDecision: {
                riskTier: normalizeRiskTier(v.doctor_decision?.final_risk_tier),
                doctor: v.doctor_decision?.doctor_name || 'Unknown Doctor',
                notes: v.doctor_decision?.reasoning_notes || v.plan_summary || '',
                timestamp: v.doctor_decision?.decision_timestamp || v.visit_date || ''
              },
              outcome: {
                type: (v.visit_outcome?.status?.includes('Follow-up')
                  ? 'Follow-up Scheduled' as const
                  : v.visit_outcome?.status?.includes('Monitoring')
                    ? 'Continue Monitoring' as const
                    : 'No Action Required' as const),
                details: v.visit_outcome?.details || 'Visit completed'
              }
            }));
            setVisitHistory(mappedVisits);
            // Set last data sync from most recent visit
            if (mappedVisits.length > 0) {
              setLastDataSync(mappedVisits[0].date);
            }
          }
        }

        // Fetch alarms - IMPORTANT: Only show the most recent alarm per patient
        const alarmResponse = await fetch(`${API_BASE_URL}/alarms?patientId=${patient.id}&pageSize=100`);
        if (alarmResponse.ok) {
          const alarmResult = await alarmResponse.json();
          if (alarmResult.data && alarmResult.data.items) {
            // Filter to only the most recent alarm (backend should already return only one, but ensure it here)
            const alarms = alarmResult.data.items as any[];
            const mostRecentAlarm = alarms.length > 0 
              ? alarms.reduce((latest, current) => {
                  const latestTime = latest.createdAt || latest.created_at || 0;
                  const currentTime = current.createdAt || current.created_at || 0;
                  const latestTimestamp = typeof latestTime === 'string' ? new Date(latestTime).getTime() : (typeof latestTime === 'number' ? latestTime : 0);
                  const currentTimestamp = typeof currentTime === 'string' ? new Date(currentTime).getTime() : (typeof currentTime === 'number' ? currentTime : 0);
                  return currentTimestamp > latestTimestamp ? current : latest;
                })
              : null;
            
            const mappedAlarms: AlarmRecord[] = mostRecentAlarm ? [{
              id: mostRecentAlarm.id || mostRecentAlarm.alarm_id,
              visitId: mostRecentAlarm.visitId || '',
              timestamp: mostRecentAlarm.createdAt || mostRecentAlarm.created_at ? new Date(mostRecentAlarm.createdAt || mostRecentAlarm.created_at).toLocaleString('en-US', {
                year: 'numeric',
                month: 'short',
                day: 'numeric',
                hour: 'numeric',
                minute: '2-digit'
              }) : '',
              severity: (mostRecentAlarm.severity || mostRecentAlarm.tier || 'Medium').toUpperCase() === 'HIGH' ? 'High' as const
                : (mostRecentAlarm.severity || mostRecentAlarm.tier || 'Medium').toUpperCase() === 'LOW' ? 'Low' as const
                : 'Medium' as const,
              type: 'AI-Triggered' as const,
              description: mostRecentAlarm.message || mostRecentAlarm.alarm_summary || 'Alarm triggered',
              status: (mostRecentAlarm.status || 'OPEN').toUpperCase() === 'ACKNOWLEDGED' ? 'Acknowledged' as const
                : (mostRecentAlarm.status || 'OPEN').toUpperCase() === 'RESOLVED' ? 'Resolved' as const
                : 'Open' as const,
              acknowledgedBy: mostRecentAlarm.acknowledgedBy,
              acknowledgedAt: mostRecentAlarm.acknowledgedAt
            }] : [];
            setAlarms(mappedAlarms);
          }
        }

        // Fetch audit log
        const auditResponse = await fetch(`${API_BASE_URL}/audit/logs?patientId=${patient.id}&pageSize=100`);
        if (auditResponse.ok) {
          const auditResult = await auditResponse.json();
          if (auditResult.data && auditResult.data.items) {
            const mappedAudit: AuditEntry[] = auditResult.data.items.map((a: any) => ({
              id: a.id || String(Date.now()),
              timestamp: a.timestamp ? new Date(a.timestamp).toLocaleString('en-US', {
                year: 'numeric',
                month: 'short',
                day: 'numeric',
                hour: 'numeric',
                minute: '2-digit'
              }) : '',
              action: a.action || 'Unknown action',
              actor: a.actor || a.userId || 'Unknown',
              actorType: (a.actorType || 'System').toUpperCase() === 'AI' ? 'AI' as const
                : (a.actorType || 'System').toUpperCase() === 'DOCTOR' ? 'Doctor' as const
                : 'System' as const,
              details: a.details || a.description || '',
              visitId: a.visitId
            }));
            setAuditLog(mappedAudit);
          }
        }

        // Fetch clinical notes/discussions
        const discussionResponse = await fetch(`${API_BASE_URL}/discussion/clinical-notes/${patient.id}`);
        if (discussionResponse.ok) {
          const discussionResult = await discussionResponse.json();
          if (discussionResult.data && Array.isArray(discussionResult.data)) {
            const mappedDiscussions: DiscussionEntry[] = discussionResult.data.map((note: any) => ({
              id: note.clinical_note_id || note.clinicalNoteId || String(Date.now()),
              visitId: note.visit_id || note.visitId || '',
              doctor: note.practitioner_name || note.practitionerName || 
                     (note.is_ai_response || note.isAiResponse ? 'AI Clinical Assistant' : 'Unknown Doctor'),
              timestamp: note.created_at || note.createdAt ? 
                        new Date(note.created_at || note.createdAt).toLocaleString('en-US', {
                          year: 'numeric',
                          month: 'short',
                          day: 'numeric',
                          hour: 'numeric',
                          minute: '2-digit'
                        }) : '',
              message: note.content || '',
              type: (note.message_type || note.messageType || 'clinical-note') as 'clinical-note' | 'ai-question' | 'ai-response'
            }));
            setDiscussions(mappedDiscussions);
          } else {
            setDiscussions([]);
          }
        } else {
          setDiscussions([]);
        }

      } catch (error) {
        console.error('Error fetching patient record data:', error);
      } finally {
        setLoading(false);
      }
    };

    fetchAllData();
  }, [patient.id]);

  const toggleVisit = (visitId: string) => {
    setExpandedVisits(prev => {
      const newSet = new Set(prev);
      if (newSet.has(visitId)) {
        newSet.delete(visitId);
      } else {
        newSet.add(visitId);
      }
      return newSet;
    });
  };

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Sticky Header */}
      <header className="bg-white border-b border-gray-200 sticky top-0 z-10 shadow-sm">
        <div className="px-8 py-4">
          <button
            onClick={onBack}
            className="text-sm text-blue-600 hover:text-blue-700 mb-3 flex items-center gap-1"
          >
            ← Back to Active Visit
          </button>
          <div className="flex items-start justify-between">
            <div>
              <h1 className="text-2xl font-semibold text-gray-900 mb-1">{patient.name}</h1>
              <p className="text-gray-600 mb-2">
                {patient.age} years • {patient.sex} • Twin ID: {patient.twinId}
              </p>
              <div className="flex items-center gap-3">
                <div className="flex flex-wrap gap-2">
                  {patient.cohort.map(c => (
                    <span key={c} className="px-2 py-1 bg-blue-50 text-blue-700 text-xs rounded">
                      {c}
                    </span>
                  ))}
                </div>
                <span className="px-3 py-1 bg-amber-50 text-amber-700 text-xs font-medium rounded border border-amber-200">
                  Record View (Read-Only)
                </span>
              </div>
            </div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <div className="max-w-7xl mx-auto px-8 py-6">
        {loading && (
          <div className="flex items-center justify-center min-h-[400px]">
            <div className="text-center">
              <div className="mb-4 flex justify-center">
                <div className="relative">
                  <div className="w-12 h-12 border-4 border-blue-200 rounded-full"></div>
                  <div className="w-12 h-12 border-4 border-blue-600 border-t-transparent rounded-full animate-spin absolute top-0 left-0"></div>
                </div>
              </div>
              <h3 className="text-lg font-semibold text-gray-900 mb-1">Loading patient record</h3>
              <p className="text-sm text-gray-500">Fetching data from BigQuery...</p>
            </div>
          </div>
        )}

        {!loading && (
          <>
        {/* Section A: Patient Snapshot */}
        <div className="bg-white rounded-lg border border-gray-200 p-6 mb-6">
          <div className="flex items-center gap-2 mb-4">
            <Activity className="w-5 h-5 text-blue-600" />
            <h2 className="font-semibold text-gray-900">Patient Snapshot</h2>
            <span className="text-xs text-gray-500">(Current Status)</span>
          </div>

          <div className="grid grid-cols-3 gap-6">
            {/* Key Conditions */}
            <div>
              <h3 className="text-sm font-medium text-gray-700 mb-3">Key Conditions</h3>
              <div className="space-y-2">
                {patient.detailedConditions && patient.detailedConditions.length > 0 ? (
                  patient.detailedConditions.map((condition: any, idx: number) => (
                    <div key={idx} className="flex items-start gap-2 text-sm text-gray-700">
                      <div className="w-1.5 h-1.5 bg-purple-500 rounded-full mt-1.5 flex-shrink-0"></div>
                      {condition.condition_name || condition.name || String(condition)}
                    </div>
                  ))
                ) : patient.conditions && patient.conditions.length > 0 ? (
                  patient.conditions.map((condition, idx) => (
                    <div key={idx} className="flex items-start gap-2 text-sm text-gray-700">
                      <div className="w-1.5 h-1.5 bg-purple-500 rounded-full mt-1.5 flex-shrink-0"></div>
                      {condition}
                    </div>
                  ))
                ) : (
                  <p className="text-sm text-gray-500">No conditions recorded</p>
                )}
              </div>
            </div>

            {/* Current Medications */}
            <div>
              <h3 className="text-sm font-medium text-gray-700 mb-3">Current Medications</h3>
              <div className="space-y-2">
                {patient.detailedMedications && patient.detailedMedications.length > 0 ? (
                  patient.detailedMedications.map((med: any, idx: number) => (
                    <div key={idx} className="flex items-start gap-2 text-sm text-gray-700">
                      <div className="w-1.5 h-1.5 bg-blue-500 rounded-full mt-1.5 flex-shrink-0"></div>
                      {med.medication_name || med.name || String(med)}
                      {med.dose && <span className="text-gray-500"> - {med.dose}</span>}
                    </div>
                  ))
                ) : patient.medications && patient.medications.length > 0 ? (
                  patient.medications.map((med, idx) => (
                    <div key={idx} className="flex items-start gap-2 text-sm text-gray-700">
                      <div className="w-1.5 h-1.5 bg-blue-500 rounded-full mt-1.5 flex-shrink-0"></div>
                      {med}
                    </div>
                  ))
                ) : (
                  <p className="text-sm text-gray-500">No medications recorded</p>
                )}
              </div>
            </div>

            {/* Latest Vitals */}
            {patient.vitals && (
              <div>
                <h3 className="text-sm font-medium text-gray-700 mb-3">Latest Vitals</h3>
                <div className="space-y-2">
                  <div className="p-2 bg-gray-50 rounded text-sm">
                    <div className="text-gray-500 text-xs mb-1">Blood Pressure</div>
                    <div className="font-medium text-gray-900">{patient.vitals.bloodPressure} mmHg</div>
                  </div>
                  <div className="p-2 bg-gray-50 rounded text-sm">
                    <div className="text-gray-500 text-xs mb-1">Heart Rate</div>
                    <div className="font-medium text-gray-900">{patient.vitals.heartRate} bpm</div>
                  </div>
                  <div className="p-2 bg-gray-50 rounded text-sm">
                    <div className="text-gray-500 text-xs mb-1">Temperature</div>
                    <div className="font-medium text-gray-900">{patient.vitals.temperature}</div>
                  </div>
                </div>
              </div>
            )}
          </div>

          <div className="mt-4 p-3 bg-blue-50 border border-blue-200 rounded text-sm">
            <div className="flex items-center gap-2">
              <Clock className="w-4 h-4 text-blue-600" />
              <span className="font-medium text-blue-900">Last Data Sync:</span>
              <span className="text-blue-800">
                {lastDataSync || (patient.clinicalSummary?.created_at 
                  ? new Date(patient.clinicalSummary.created_at).toLocaleString('en-US', {
                      year: 'numeric',
                      month: 'short',
                      day: 'numeric',
                      hour: 'numeric',
                      minute: '2-digit'
                    })
                  : 'Not available')}
              </span>
            </div>
          </div>
        </div>

        {/* Section B: Visit Timeline (Core Section) */}
        <div className="bg-white rounded-lg border border-gray-200 p-6 mb-6">
          <div className="flex items-center gap-2 mb-4">
            <Calendar className="w-5 h-5 text-blue-600" />
            <h2 className="font-semibold text-gray-900">Visit Timeline</h2>
            <span className="text-xs text-gray-500">(Longitudinal History)</span>
          </div>

          {visitHistory.length === 0 ? (
            <div className="text-center py-8 text-gray-500">
              <Calendar className="w-12 h-12 mx-auto mb-3 text-gray-400" />
              <p className="text-sm">No visit history recorded yet</p>
            </div>
          ) : (
            <div className="space-y-4">
              {visitHistory.map((visit) => (
                <div key={visit.id} className="border border-gray-200 rounded-lg overflow-hidden">
                {/* Visit Header */}
                <button
                  onClick={() => toggleVisit(visit.id)}
                  className="w-full p-4 bg-gray-50 hover:bg-gray-100 transition-colors flex items-center justify-between"
                >
                  <div className="flex items-center gap-4">
                    <div className="text-left">
                      <div className="font-medium text-gray-900">{visit.date}</div>
                      <div className="flex items-center gap-2 mt-1">
                        <span className={`text-xs px-2 py-0.5 rounded font-medium ${
                          visit.type === 'Manual' ? 'bg-blue-100 text-blue-700' :
                          visit.type === 'Follow-up' ? 'bg-green-100 text-green-700' :
                          'bg-purple-100 text-purple-700'
                        }`}>
                          {visit.type}
                        </span>
                        <span className="text-xs text-gray-500">• {visit.status}</span>
                      </div>
                    </div>
                    <div className="ml-8">
                      <div className="text-xs text-gray-500 mb-1">Final Risk Tier</div>
                      <RiskBadge tier={visit.doctorDecision.riskTier} size="sm" />
                    </div>
                  </div>
                  {expandedVisits.has(visit.id) ? (
                    <ChevronUp className="w-5 h-5 text-gray-400" />
                  ) : (
                    <ChevronDown className="w-5 h-5 text-gray-400" />
                  )}
                </button>

                {/* Expanded Visit Details */}
                {expandedVisits.has(visit.id) && (
                  <div className="p-4 space-y-4">
                    {/* AI Analysis */}
                    <div className="p-4 bg-purple-50 border border-purple-200 rounded-lg">
                      <div className="flex items-center gap-2 mb-3">
                        <Brain className="w-4 h-4 text-purple-600" />
                        <span className="text-sm font-medium text-purple-900">AI Analysis</span>
                      </div>
                      <div className="mb-3">
                        <div className="text-xs text-purple-700 mb-2">AI Recommended Risk Tier</div>
                        <RiskBadge tier={visit.aiAnalysis.riskTier} size="sm" />
                      </div>
                      <div className="mb-3">
                        <div className="text-xs text-purple-700 mb-2">Key Reasons</div>
                        <ul className="space-y-1">
                          {visit.aiAnalysis.reasoning.map((reason, idx) => (
                            <li key={idx} className="flex items-start gap-2 text-sm text-gray-700">
                              <div className="w-1.5 h-1.5 bg-purple-500 rounded-full mt-1.5 flex-shrink-0"></div>
                              {reason}
                            </li>
                          ))}
                        </ul>
                      </div>
                      <div className="text-xs text-purple-600">
                        {visit.aiAnalysis.model} • {visit.aiAnalysis.timestamp}
                      </div>
                    </div>

                    {/* Doctor Final Decision */}
                    <div className="p-4 bg-blue-50 border border-blue-200 rounded-lg">
                      <div className="flex items-center gap-2 mb-3">
                        <User className="w-4 h-4 text-blue-600" />
                        <span className="text-sm font-medium text-blue-900">Doctor Final Decision</span>
                      </div>
                      <div className="mb-3">
                        <div className="text-xs text-blue-700 mb-2">Final Risk Tier</div>
                        <RiskBadge tier={visit.doctorDecision.riskTier} size="sm" />
                      </div>
                      <div className="mb-3">
                        <div className="text-xs text-blue-700 mb-2">Clinical Notes</div>
                        <p className="text-sm text-gray-700">{visit.doctorDecision.notes}</p>
                      </div>
                      <div className="text-xs text-blue-600">
                        {visit.doctorDecision.doctor} • {visit.doctorDecision.timestamp}
                      </div>
                    </div>

                    {/* Outcome */}
                    <div className="p-4 bg-green-50 border border-green-200 rounded-lg">
                      <div className="flex items-center gap-2 mb-2">
                        <FileCheck className="w-4 h-4 text-green-600" />
                        <span className="text-sm font-medium text-green-900">Outcome</span>
                      </div>
                      <div className="text-sm text-gray-700">
                        <span className="font-medium">{visit.outcome.type}:</span> {visit.outcome.details}
                      </div>
                    </div>
                  </div>
                )}
                </div>
              ))}
            </div>
          )}
        </div>

        {/* Section C: Clinical Discussion Log */}
        <div className="bg-white rounded-lg border border-gray-200 p-6 mb-6">
          <div className="flex items-center gap-2 mb-4">
            <MessageSquare className="w-5 h-5 text-blue-600" />
            <h2 className="font-semibold text-gray-900">Clinical Discussion Log</h2>
            <span className="text-xs text-gray-500">(AI ↔ Doctor Conversations)</span>
          </div>

          {discussions.length === 0 ? (
            <div className="text-center py-8 text-gray-500">
              <MessageSquare className="w-12 h-12 mx-auto mb-3 text-gray-400" />
              <p className="text-sm">No clinical discussions recorded yet</p>
            </div>
          ) : (
            <div className="space-y-3">
            {discussions.map((disc) => (
              <div key={disc.id} className={`p-4 rounded-lg border ${
                disc.type === 'ai-question' ? 'bg-purple-50 border-purple-200' :
                disc.type === 'ai-response' ? 'bg-purple-50 border-purple-200' :
                'bg-blue-50 border-blue-200'
              }`}>
                <div className="flex items-start gap-3">
                  <div className={`w-8 h-8 rounded-full flex items-center justify-center flex-shrink-0 ${
                    disc.type.startsWith('ai') ? 'bg-purple-200' : 'bg-blue-200'
                  }`}>
                    {disc.type.startsWith('ai') ? (
                      <Brain className="w-4 h-4 text-purple-700" />
                    ) : (
                      <User className="w-4 h-4 text-blue-700" />
                    )}
                  </div>
                  <div className="flex-1">
                    <div className="flex items-center gap-2 mb-1">
                      <span className="text-sm font-medium text-gray-900">{disc.doctor}</span>
                      <span className="text-xs text-gray-500">{disc.timestamp}</span>
                      <span className="text-xs px-2 py-0.5 bg-gray-200 text-gray-600 rounded">
                        Visit: {discussions.find(d => d.id === disc.id)?.visitId}
                      </span>
                    </div>
                    <p className="text-sm text-gray-700">{disc.message}</p>
                  </div>
                </div>
              </div>
            ))}
            </div>
          )}
        </div>

        {/* Section D: Alarms History */}
        <div className="bg-white rounded-lg border border-gray-200 p-6 mb-6">
          <div className="flex items-center gap-2 mb-4">
            <AlertTriangle className="w-5 h-5 text-amber-600" />
            <h2 className="font-semibold text-gray-900">Alarms History</h2>
            <span className="text-xs text-gray-500">(All Alerts)</span>
          </div>

          {alarms.length === 0 ? (
            <div className="text-center py-8 text-gray-500">
              <AlertTriangle className="w-12 h-12 mx-auto mb-3 text-gray-400" />
              <p className="text-sm">No alarms recorded</p>
            </div>
          ) : (
            <div className="space-y-3">
            {alarms.map((alarm) => (
              <div key={alarm.id} className={`p-4 rounded-lg border ${
                alarm.severity === 'High' ? 'bg-red-50 border-red-200' :
                alarm.severity === 'Medium' ? 'bg-amber-50 border-amber-200' :
                'bg-yellow-50 border-yellow-200'
              }`}>
                <div className="flex items-start justify-between mb-2">
                  <div className="flex items-center gap-2">
                    <span className={`text-xs px-2 py-1 font-medium rounded ${
                      alarm.severity === 'High' ? 'bg-red-200 text-red-800' :
                      alarm.severity === 'Medium' ? 'bg-amber-200 text-amber-800' :
                      'bg-yellow-200 text-yellow-800'
                    }`}>
                      {alarm.severity}
                    </span>
                    <span className={`text-xs px-2 py-1 rounded ${
                      alarm.type === 'AI-Triggered' ? 'bg-purple-100 text-purple-700' :
                      'bg-gray-200 text-gray-700'
                    }`}>
                      {alarm.type}
                    </span>
                    <span className={`text-xs px-2 py-1 font-medium rounded ${
                      alarm.status === 'Acknowledged' ? 'bg-green-100 text-green-700' :
                      alarm.status === 'Resolved' ? 'bg-blue-100 text-blue-700' :
                      'bg-red-100 text-red-700'
                    }`}>
                      {alarm.status}
                    </span>
                  </div>
                  <span className="text-xs text-gray-500">{alarm.timestamp}</span>
                </div>
                <p className="text-sm text-gray-900 font-medium mb-2">{alarm.description}</p>
                {alarm.acknowledgedBy && (
                  <div className="text-xs text-gray-600">
                    Acknowledged by {alarm.acknowledgedBy} at {alarm.acknowledgedAt}
                  </div>
                )}
                <div className="text-xs text-gray-500 mt-1">
                  Related to: {alarm.visitId}
                </div>
              </div>
            ))}
            </div>
          )}
        </div>

        {/* Section E: Audit Log */}
        <div className="bg-white rounded-lg border border-gray-200 p-6 mb-6">
          <div className="flex items-center gap-2 mb-4">
            <Shield className="w-5 h-5 text-gray-600" />
            <h2 className="font-semibold text-gray-900">Audit Log</h2>
            <span className="text-xs text-gray-500">(Immutable Compliance Record)</span>
          </div>

          {auditLog.length === 0 ? (
            <div className="text-center py-8 text-gray-500">
              <Shield className="w-12 h-12 mx-auto mb-3 text-gray-400" />
              <p className="text-sm">No audit log entries recorded yet</p>
            </div>
          ) : (
            <div className="space-y-2">
              {auditLog.map((entry) => (
              <div key={entry.id} className="p-3 bg-gray-50 border border-gray-200 rounded-lg">
                <div className="flex items-start justify-between mb-2">
                  <div className="flex items-center gap-2">
                    <span className={`text-xs px-2 py-1 font-medium rounded ${
                      entry.actorType === 'AI' ? 'bg-purple-100 text-purple-700' :
                      entry.actorType === 'Doctor' ? 'bg-blue-100 text-blue-700' :
                      'bg-gray-200 text-gray-700'
                    }`}>
                      {entry.actorType}
                    </span>
                    <span className="text-sm font-medium text-gray-900">{entry.action}</span>
                  </div>
                  <span className="text-xs text-gray-500">{entry.timestamp}</span>
                </div>
                <div className="text-sm text-gray-700 mb-1">{entry.details}</div>
                <div className="flex items-center gap-3 text-xs text-gray-600">
                  <span>Actor: {entry.actor}</span>
                  {entry.visitId && <span>• Visit: {entry.visitId}</span>}
                </div>
              </div>
              ))}
            </div>
          )}
        </div>

        {/* Disclaimer Footer */}
        <div className="bg-amber-50 border border-amber-200 rounded-lg p-4">
          <div className="text-sm text-amber-900">
            <span className="font-medium">Read-Only Record View:</span> This is a comprehensive longitudinal view of all patient data. 
            No edits, decisions, or workflows can be initiated from this page. To perform clinical actions, return to the Active Visit view.
          </div>
        </div>
          </>
        )}
      </div>
    </div>
  );
}
