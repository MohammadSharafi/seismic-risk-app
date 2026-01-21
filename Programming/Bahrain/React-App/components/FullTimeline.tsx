import { useState, useEffect } from 'react';
import { ChevronDown, ChevronUp, Calendar, User, Brain, Filter, Search, ExternalLink, MessageSquare, AlertTriangle, X } from 'lucide-react';
import { Patient, RiskTier } from '../App';
import { RiskBadge } from './RiskBadge';
import { API_BASE_URL } from '../src/config';

interface Visit {
  id: string;
  date: string;
  visitType: 'Manual' | 'Follow-up' | 'Background';
  status: 'Completed' | 'Draft';
  triggerSource: 'Doctor-initiated' | 'Background monitoring';
  patientState: {
    conditions: string[];
    dataFreshness: string;
  };
  aiAnalysis: {
    riskTier: RiskTier;
    reasoning: string[];
    evidenceReferences: { type: string; label: string }[];
    timestamp: string;
    modelVersion: string;
    confidence?: string;
    reviewedByDoctor: boolean;
  };
  doctorDecision: {
    riskTier: RiskTier;
    recommendation: string;
    notes: string;
    doctorName: string;
    doctorId?: string;
    timestamp: string;
    aiRiskTier?: RiskTier;
    riskTierOverride?: boolean;
  };
  outcome: {
    status: 'No action' | 'Follow-up scheduled' | 'Monitoring continued';
    details?: string;
    followUpDate?: string | null;
    monitoringStatus?: string;
    medications?: Array<{
      medication: string;
      dose?: string;
      frequency?: string;
      duration?: string;
      rationale?: string;
      status?: string;
    }>;
    procedures?: Array<{
      procedure: string;
      timing?: string;
      rationale?: string;
      status?: string;
    }>;
    ai_medication_recommendations?: Array<{
      medication: string;
      dose?: string;
      frequency?: string;
      duration?: string;
      rationale?: string;
      reasoning?: string[];
      status?: string;
      doctor_modified?: boolean;
      doctor_notes?: string;
    }>;
    ai_procedure_recommendations?: Array<{
      procedure: string;
      timing?: string;
      rationale?: string;
      reasoning?: string[];
      status?: string;
      doctor_modified?: boolean;
      doctor_notes?: string;
    }>;
    patient_snapshot?: any;
    alarms?: any[];
    risk_factors?: any[];
    latest_twin_summary?: any;
  };
  hasAlarms: boolean;
  hasDiscussion: boolean;
  // Additional fields from API
  twinId?: string;
  twinSummaryVersion?: string;
  planSummary?: string;
  createdAt?: string;
  updatedAt?: string;
}

interface ApiVisit {
  visit_id: string;
  visit_date: string;
  visit_type: string;
  trigger_source: string;
  visit_status: string;
  ai_analysis?: {
    risk_tier: 'Low' | 'Medium' | 'High';
    reasoning?: string[];
    reasoning_references?: Array<{ type: string; label: string }>;
    timestamp?: string;
    model_version?: string;
  };
  doctor_decision?: {
    final_risk_tier: 'Low' | 'Medium' | 'High';
    doctor_name?: string;
    reasoning_notes?: string;
    decision_timestamp?: string;
  };
  visit_outcome?: {
    status: string;
    details?: string;
    follow_up_date?: string | null;
    monitoring_status?: string;
    medications?: Array<{
      medication: string;
      dose?: string;
      frequency?: string;
      duration?: string;
      rationale?: string;
      status?: string;
    }>;
    procedures?: Array<{
      procedure: string;
      timing?: string;
      rationale?: string;
      status?: string;
    }>;
    ai_medication_recommendations?: Array<{
      medication: string;
      dose?: string;
      frequency?: string;
      duration?: string;
      rationale?: string;
      reasoning?: string[];
      status?: string;
      doctor_modified?: boolean;
      doctor_notes?: string;
    }>;
    ai_procedure_recommendations?: Array<{
      procedure: string;
      timing?: string;
      rationale?: string;
      reasoning?: string[];
      status?: string;
      doctor_modified?: boolean;
      doctor_notes?: string;
    }>;
    patient_snapshot?: any;
    alarms?: any[];
    risk_factors?: any[];
    latest_twin_summary?: any;
  };
  plan_summary?: string;
}

interface FullTimelineProps {
  patient: Patient;
  onClose: () => void;
  onStartNewVisit: () => void;
  onOpenDiscussion: (visitId: string) => void;
}

// Visits will be fetched from API later
const visits: Visit[] = []; // Removed mock data

export function FullTimeline({ patient, onClose, onStartNewVisit, onOpenDiscussion }: FullTimelineProps) {
  const [expandedVisit, setExpandedVisit] = useState<string | null>(null);
  const [filterType, setFilterType] = useState<'All' | 'Manual' | 'Follow-up' | 'Background'>('All');
  const [filterRisk, setFilterRisk] = useState<RiskTier | 'All'>('All');
  const [showAIOnly, setShowAIOnly] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  const [visits, setVisits] = useState<Visit[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Fetch visits from API
  useEffect(() => {
    const fetchVisits = async () => {
      try {
        setLoading(true);
        setError(null);
        const response = await fetch(`${API_BASE_URL}/analyze/visit-history/${patient.id}`, {
          headers: {
            'X-User-Id': 'doctor-001',
            'X-User-Role': 'DOCTOR'
          }
        });
        
        if (!response.ok) {
          throw new Error(`Failed to fetch visit history: ${response.statusText}`);
        }
        
        const result = await response.json();
        if (result.data) {
          // Map API visits to FullTimeline Visit format
          const mappedVisits: Visit[] = result.data.map((apiVisit: ApiVisit) => {
            const visitDate = apiVisit.visit_date 
              ? new Date(apiVisit.visit_date).toLocaleDateString('en-US', {
                  year: 'numeric',
                  month: 'short',
                  day: 'numeric',
                  hour: 'numeric',
                  minute: '2-digit'
                })
              : 'Unknown date';
            
            // Determine visit type
            const visitTypeStr = (apiVisit.visit_type || apiVisit.trigger_source || '').toLowerCase();
            let visitType: 'Manual' | 'Follow-up' | 'Background' = 'Manual';
            if (visitTypeStr.includes('background')) visitType = 'Background';
            else if (visitTypeStr.includes('follow')) visitType = 'Follow-up';
            
            // Map risk tiers
            const normalizeRiskTier = (tier: string | undefined): RiskTier => {
              if (!tier) return 'Medium';
              const upper = tier.toUpperCase();
              if (upper === 'HIGH') return 'High';
              if (upper === 'LOW') return 'Low';
              return 'Medium';
            };
            
            const aiRiskTier = normalizeRiskTier(apiVisit.ai_analysis?.risk_tier);
            const doctorRiskTier = normalizeRiskTier(apiVisit.doctor_decision?.final_risk_tier);
            
            return {
              id: apiVisit.visit_id,
              date: visitDate,
              visitType,
              status: (apiVisit.visit_status === 'Completed' ? 'Completed' : 'Draft') as 'Completed' | 'Draft',
              triggerSource: (apiVisit.trigger_source?.includes('Doctor') ? 'Doctor-initiated' : 'Background monitoring') as 'Doctor-initiated' | 'Background monitoring',
              patientState: {
                conditions: [],
                dataFreshness: 'Current'
              },
              aiAnalysis: {
                riskTier: aiRiskTier,
                reasoning: apiVisit.ai_analysis?.reasoning || [],
                evidenceReferences: apiVisit.ai_analysis?.reasoning_references || [],
                timestamp: apiVisit.ai_analysis?.timestamp || apiVisit.visit_date || '',
                modelVersion: apiVisit.ai_analysis?.model_version || 'ClinicalAI v3.2.1',
                confidence: apiVisit.ai_analysis?.confidence,
                reviewedByDoctor: !!apiVisit.doctor_decision
              },
              doctorDecision: {
                riskTier: doctorRiskTier,
                recommendation: apiVisit.plan_summary || '',
                notes: apiVisit.doctor_decision?.reasoning_notes || '',
                doctorName: apiVisit.doctor_decision?.doctor_name || 'Unknown',
                doctorId: apiVisit.doctor_decision?.doctor_id,
                timestamp: apiVisit.doctor_decision?.decision_timestamp || apiVisit.visit_date || '',
                aiRiskTier: normalizeRiskTier(apiVisit.doctor_decision?.ai_risk_tier),
                riskTierOverride: apiVisit.doctor_decision?.risk_tier_override || false
              },
              outcome: {
                status: (apiVisit.visit_outcome?.status?.includes('Follow-up') 
                  ? 'Follow-up scheduled' 
                  : apiVisit.visit_outcome?.status?.includes('Monitoring')
                  ? 'Monitoring continued'
                  : 'No action') as 'No action' | 'Follow-up scheduled' | 'Monitoring continued',
                details: apiVisit.visit_outcome?.details,
                followUpDate: apiVisit.visit_outcome?.follow_up_date,
                monitoringStatus: apiVisit.visit_outcome?.monitoring_status,
                medications: apiVisit.visit_outcome?.medications || [],
                procedures: apiVisit.visit_outcome?.procedures || [],
                ai_medication_recommendations: apiVisit.visit_outcome?.ai_medication_recommendations || [],
                ai_procedure_recommendations: apiVisit.visit_outcome?.ai_procedure_recommendations || [],
                patient_snapshot: apiVisit.visit_outcome?.patient_snapshot,
                alarms: apiVisit.visit_outcome?.alarms || [],
                risk_factors: apiVisit.visit_outcome?.risk_factors || [],
                latest_twin_summary: apiVisit.visit_outcome?.latest_twin_summary
              },
              hasAlarms: false,
              hasDiscussion: false,
              twinId: apiVisit.twin_id,
              twinSummaryVersion: apiVisit.twin_summary_version,
              planSummary: apiVisit.plan_summary,
              createdAt: apiVisit.created_at,
              updatedAt: apiVisit.updated_at
            };
          });
          
          setVisits(mappedVisits);
        } else {
          setVisits([]);
        }
      } catch (err: any) {
        console.error('Error fetching visit history:', err);
        setError(err.message || 'Failed to load visit history');
        setVisits([]);
      } finally {
        setLoading(false);
      }
    };

    fetchVisits();
  }, [patient.id]);

  const filteredVisits = visits.filter(visit => {
    const matchesType = filterType === 'All' || visit.visitType === filterType;
    const matchesRisk = filterRisk === 'All' || visit.aiAnalysis.riskTier === filterRisk || visit.doctorDecision.riskTier === filterRisk;
    const matchesSearch = searchQuery === '' || 
      visit.date.toLowerCase().includes(searchQuery.toLowerCase()) ||
      visit.doctorDecision.notes.toLowerCase().includes(searchQuery.toLowerCase());
    return matchesType && matchesRisk && matchesSearch;
  });

  const toggleVisit = (visitId: string) => {
    setExpandedVisit(expandedVisit === visitId ? null : visitId);
  };

  return (
    <div className="fixed inset-0 bg-gray-900 bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg w-[90%] max-w-6xl max-h-[90vh] flex flex-col">
        {/* Sticky Header */}
        <div className="sticky top-0 bg-white border-b border-gray-200 px-8 py-6 rounded-t-lg">
          <div className="flex items-start justify-between mb-4">
            <div className="flex-1">
              <h1 className="text-2xl font-semibold text-gray-900 mb-2">Patient Visit Timeline</h1>
              <p className="text-gray-600">Chronological record of visits, analyses, and clinical decisions</p>
            </div>
            <button onClick={onClose} className="text-gray-400 hover:text-gray-600">
              <X className="w-6 h-6" />
            </button>
          </div>

          <div className="flex items-center justify-between">
            <div className="flex items-center gap-4">
              <div>
                <span className="text-sm text-gray-600">Patient: </span>
                <span className="font-semibold text-gray-900">{patient.name}</span>
              </div>
              <div className="h-6 w-px bg-gray-300"></div>
              <div className="flex items-center gap-2">
                <span className="text-sm text-gray-600">Current Risk: </span>
                <RiskBadge tier={patient.riskTier} size="sm" />
              </div>
            </div>
            <button
              onClick={onStartNewVisit}
              className="px-4 py-2 bg-blue-600 text-white font-medium rounded-lg hover:bg-blue-700 transition-colors"
            >
              Start New Visit
            </button>
          </div>
        </div>

        {/* Filters */}
        <div className="px-8 py-4 bg-gray-50 border-b border-gray-200">
          <div className="flex gap-4 items-center">
            <div className="flex-1 relative">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
              <input
                type="text"
                placeholder="Search by date or keyword..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="w-full pl-9 pr-4 py-2 text-sm border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>

            <div className="flex gap-2 items-center">
              <Filter className="w-4 h-4 text-gray-400" />
              <select
                value={filterType}
                onChange={(e) => setFilterType(e.target.value as any)}
                className="px-3 py-2 text-sm border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                <option value="All">All Visit Types</option>
                <option value="Manual">Manual</option>
                <option value="Follow-up">Follow-up</option>
                <option value="Background">Background</option>
              </select>

              <select
                value={filterRisk}
                onChange={(e) => setFilterRisk(e.target.value as any)}
                className="px-3 py-2 text-sm border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                <option value="All">All Risk Tiers</option>
                <option value="Critical">Critical Alert</option>
                <option value="High">High Alert</option>
                <option value="Medium">Moderate Alert</option>
                <option value="Low">Low Alert</option>
              </select>

              <label className="flex items-center gap-2 text-sm text-gray-700 cursor-pointer">
                <input
                  type="checkbox"
                  checked={showAIOnly}
                  onChange={(e) => setShowAIOnly(e.target.checked)}
                  className="w-4 h-4 text-blue-600 rounded focus:ring-2 focus:ring-blue-500"
                />
                Show AI-only evaluations
              </label>
            </div>
          </div>
        </div>

        {/* Timeline Content */}
        <div className="flex-1 overflow-y-auto px-8 py-6">
          {loading && (
            <div className="text-center py-12">
              <div className="text-gray-600">Loading visit history...</div>
            </div>
          )}

          {error && (
            <div className="bg-amber-50 border border-amber-200 rounded-lg p-4 text-amber-800 mb-4">
              <div className="text-sm">{error}</div>
            </div>
          )}

          {!loading && !error && filteredVisits.length === 0 && (
            <div className="text-center py-12">
              <Calendar className="w-12 h-12 text-gray-400 mx-auto mb-3" />
              <h3 className="font-medium text-gray-900 mb-1">No Visits Found</h3>
              <p className="text-sm text-gray-600">
                {visits.length === 0 
                  ? 'No visits have been recorded for this patient yet.'
                  : 'No visits match the current filters.'}
              </p>
            </div>
          )}

          {!loading && !error && filteredVisits.length > 0 && (
            <div className="space-y-4">
              {filteredVisits.map((visit, index) => (
              <div
                key={visit.id}
                className={`bg-white rounded-lg border-2 transition-all ${
                  visit.id === 'V001' ? 'border-blue-300 shadow-md' : 'border-gray-200'
                }`}
              >
                {/* Visit Metadata - Always Visible */}
                <div
                  className="p-4 cursor-pointer hover:bg-gray-50 transition-colors"
                  onClick={() => toggleVisit(visit.id)}
                >
                  <div className="flex items-start justify-between">
                    <div className="flex-1">
                      <div className="flex items-center gap-3 mb-2">
                        <Calendar className="w-5 h-5 text-gray-400" />
                        <span className="font-semibold text-gray-900">{visit.date}</span>
                        
                        {visit.id === 'V001' && (
                          <span className="px-2 py-0.5 bg-blue-100 text-blue-700 text-xs font-medium rounded">
                            Active Visit
                          </span>
                        )}

                        <span className={`px-2 py-1 text-xs font-medium rounded ${
                          visit.visitType === 'Manual' ? 'bg-blue-100 text-blue-700' :
                          visit.visitType === 'Follow-up' ? 'bg-green-100 text-green-700' :
                          'bg-purple-100 text-purple-700'
                        }`}>
                          {visit.visitType}
                        </span>

                        <span className={`px-2 py-1 text-xs font-medium rounded ${
                          visit.status === 'Completed' ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-700'
                        }`}>
                          {visit.status}
                        </span>
                      </div>

                      <div className="text-sm text-gray-600 mb-2">
                        Trigger: {visit.triggerSource}
                      </div>

                      <div className="flex items-center gap-4 text-sm">
                        <div className="flex items-center gap-2">
                          <Brain className="w-4 h-4 text-purple-500" />
                          <span className="text-gray-600">AI: </span>
                          <RiskBadge tier={visit.aiAnalysis.riskTier} size="sm" />
                        </div>
                        <div className="flex items-center gap-2">
                          <User className="w-4 h-4 text-blue-500" />
                          <span className="text-gray-600">Doctor: </span>
                          <RiskBadge tier={visit.doctorDecision.riskTier} size="sm" />
                        </div>
                      </div>
                    </div>

                    <button className="text-gray-400 hover:text-gray-600">
                      {expandedVisit === visit.id ? (
                        <ChevronUp className="w-5 h-5" />
                      ) : (
                        <ChevronDown className="w-5 h-5" />
                      )}
                    </button>
                  </div>
                </div>

                {/* Expanded Visit Details */}
                {expandedVisit === visit.id && (
                  <div className="border-t border-gray-200 p-6 bg-gray-50">
                    {/* Visit Summary - Patient State */}
                    <div className="mb-6">
                      <h3 className="text-sm font-medium text-gray-700 mb-3">Patient state at time of visit</h3>
                      <div className="bg-white rounded-lg border border-gray-200 p-4">
                        {visit.outcome.patient_snapshot ? (
                          <div className="space-y-3">
                            {visit.outcome.patient_snapshot.current_conditions && (
                              <div>
                                <span className="text-sm text-gray-600 font-medium">Conditions: </span>
                                <span className="text-sm text-gray-900">
                                  {Array.isArray(visit.outcome.patient_snapshot.current_conditions) 
                                    ? visit.outcome.patient_snapshot.current_conditions.map((c: any) => c.condition_name || c).join(', ')
                                    : 'N/A'}
                                </span>
                              </div>
                            )}
                            {visit.outcome.patient_snapshot.current_medications && (
                              <div>
                                <span className="text-sm text-gray-600 font-medium">Medications: </span>
                                <span className="text-sm text-gray-900">
                                  {Array.isArray(visit.outcome.patient_snapshot.current_medications)
                                    ? visit.outcome.patient_snapshot.current_medications.map((m: any) => m.medication_name || m).join(', ')
                                    : 'N/A'}
                                </span>
                              </div>
                            )}
                            {visit.outcome.patient_snapshot.latest_vitals && (
                              <div className="grid grid-cols-3 gap-3 mt-3 pt-3 border-t border-gray-200">
                                {visit.outcome.patient_snapshot.latest_vitals.bloodPressure && (
                                  <div>
                                    <span className="text-xs text-gray-500">BP: </span>
                                    <span className="text-sm text-gray-900">{visit.outcome.patient_snapshot.latest_vitals.bloodPressure}</span>
                                  </div>
                                )}
                                {visit.outcome.patient_snapshot.latest_vitals.heartRate && (
                                  <div>
                                    <span className="text-xs text-gray-500">HR: </span>
                                    <span className="text-sm text-gray-900">{visit.outcome.patient_snapshot.latest_vitals.heartRate}</span>
                                  </div>
                                )}
                                {visit.outcome.patient_snapshot.latest_vitals.temperature && (
                                  <div>
                                    <span className="text-xs text-gray-500">Temp: </span>
                                    <span className="text-sm text-gray-900">{visit.outcome.patient_snapshot.latest_vitals.temperature}</span>
                                  </div>
                                )}
                              </div>
                            )}
                          </div>
                        ) : (
                          <div className="space-y-2">
                            <div className="mb-3">
                              <span className="text-sm text-gray-600">Key Conditions: </span>
                              <span className="text-sm text-gray-900">{visit.patientState.conditions.length > 0 ? visit.patientState.conditions.join(', ') : 'N/A'}</span>
                            </div>
                            <div>
                              <span className="text-sm text-gray-600">Data Freshness: </span>
                              <span className="text-sm text-gray-900">{visit.patientState.dataFreshness}</span>
                            </div>
                          </div>
                        )}
                      </div>
                      
                      {/* Alarms and Risk Factors */}
                      {(visit.outcome.alarms && visit.outcome.alarms.length > 0) || (visit.outcome.risk_factors && visit.outcome.risk_factors.length > 0) ? (
                        <div className="mt-4 grid grid-cols-2 gap-4">
                          {visit.outcome.alarms && visit.outcome.alarms.length > 0 && (
                            <div className="bg-amber-50 rounded-lg border border-amber-200 p-3">
                              <div className="text-xs font-medium text-amber-900 mb-2">Active Alarms ({visit.outcome.alarms.length})</div>
                              <div className="space-y-1">
                                {visit.outcome.alarms.slice(0, 3).map((alarm: any, idx: number) => (
                                  <div key={idx} className="text-xs text-amber-800">
                                    • {alarm.alarm_type || alarm.alarm_summary || 'Alarm'}
                                  </div>
                                ))}
                                {visit.outcome.alarms.length > 3 && (
                                  <div className="text-xs text-amber-600">+{visit.outcome.alarms.length - 3} more</div>
                                )}
                              </div>
                            </div>
                          )}
                          {visit.outcome.risk_factors && visit.outcome.risk_factors.length > 0 && (
                            <div className="bg-red-50 rounded-lg border border-red-200 p-3">
                              <div className="text-xs font-medium text-red-900 mb-2">Risk Factors ({visit.outcome.risk_factors.length})</div>
                              <div className="space-y-1">
                                {visit.outcome.risk_factors.slice(0, 3).map((risk: any, idx: number) => (
                                  <div key={idx} className="text-xs text-red-800">
                                    • {risk.risk_factor_name || risk.factor || 'Risk Factor'}
                                  </div>
                                ))}
                                {visit.outcome.risk_factors.length > 3 && (
                                  <div className="text-xs text-red-600">+{visit.outcome.risk_factors.length - 3} more</div>
                                )}
                              </div>
                            </div>
                          )}
                        </div>
                      ) : null}
                    </div>

                    {/* Two Column: AI Analysis + Doctor Decision */}
                    <div className="grid grid-cols-2 gap-6 mb-6">
                      {/* AI Analysis Section */}
                      <div className="bg-white rounded-lg border border-gray-300 p-4">
                        <div className="flex items-center gap-2 mb-4">
                          <Brain className="w-5 h-5 text-purple-600" />
                          <h3 className="font-medium text-gray-900">AI Analysis (Assistive)</h3>
                          {visit.aiAnalysis.reviewedByDoctor && (
                            <span className="px-2 py-0.5 bg-green-100 text-green-700 text-xs rounded">
                              Reviewed
                            </span>
                          )}
                        </div>

                        <div className="mb-4">
                          <div className="text-sm text-gray-600 mb-2">AI Risk Tier</div>
                          <RiskBadge tier={visit.aiAnalysis.riskTier} size="md" />
                          {visit.aiAnalysis.confidence && (
                            <div className="mt-2 text-xs text-gray-500">
                              Confidence: <span className="font-medium">{visit.aiAnalysis.confidence}</span>
                            </div>
                          )}
                        </div>

                        {visit.aiAnalysis.reasoning && visit.aiAnalysis.reasoning.length > 0 && (
                          <div className="mb-4">
                            <div className="text-sm text-gray-600 mb-2">Key Reasons</div>
                            <ul className="space-y-2">
                              {visit.aiAnalysis.reasoning.map((reason, idx) => (
                                <li key={idx} className="flex items-start gap-2 text-sm text-gray-700">
                                  <div className="w-1.5 h-1.5 bg-purple-500 rounded-full mt-1.5 flex-shrink-0"></div>
                                  {reason}
                                </li>
                              ))}
                            </ul>
                          </div>
                        )}
                        
                        {visit.aiAnalysis.reasoning && visit.aiAnalysis.reasoning.length === 0 && (
                          <div className="mb-4 text-sm text-gray-500 italic">No reasoning provided</div>
                        )}

                        <div className="mb-4">
                          <div className="text-sm text-gray-600 mb-2">Evidence References</div>
                          <div className="space-y-2">
                            {visit.aiAnalysis.evidenceReferences.map((ref, idx) => (
                              <button
                                key={idx}
                                className="flex items-center gap-2 text-sm text-blue-600 hover:text-blue-700"
                              >
                                <ExternalLink className="w-3.5 h-3.5" />
                                <span className={`px-2 py-0.5 rounded text-xs ${
                                  ref.type === 'vitals' ? 'bg-green-100 text-green-700' :
                                  ref.type === 'labs' ? 'bg-purple-100 text-purple-700' :
                                  'bg-blue-100 text-blue-700'
                                }`}>
                                  {ref.type}
                                </span>
                                {ref.label}
                              </button>
                            ))}
                          </div>
                        </div>

                        <div className="text-xs text-gray-500 pt-3 border-t border-gray-200">
                          <div>Timestamp: {visit.aiAnalysis.timestamp}</div>
                          <div>Model: {visit.aiAnalysis.modelVersion}</div>
                        </div>
                      </div>

                      {/* Doctor Decision Section */}
                      <div className="bg-blue-50 rounded-lg border-2 border-blue-300 p-4">
                        <div className="flex items-center gap-2 mb-4">
                          <User className="w-5 h-5 text-blue-600" />
                          <h3 className="font-semibold text-gray-900">Doctor Final Decision</h3>
                        </div>

                        <div className="mb-4">
                          <div className="text-sm text-gray-700 font-medium mb-2">Final Risk Tier</div>
                          <RiskBadge tier={visit.doctorDecision.riskTier} size="md" />
                          {visit.doctorDecision.aiRiskTier && visit.doctorDecision.aiRiskTier !== visit.doctorDecision.riskTier && (
                            <div className="mt-2 text-xs text-amber-600">
                              Changed from AI suggestion: <RiskBadge tier={visit.doctorDecision.aiRiskTier} size="sm" />
                            </div>
                          )}
                          {visit.doctorDecision.riskTierOverride && (
                            <div className="mt-2 text-xs text-orange-600 font-medium">
                              ⚠️ Risk tier overridden by doctor
                            </div>
                          )}
                        </div>

                        {visit.planSummary && (
                          <div className="mb-4">
                            <div className="text-sm text-gray-700 font-medium mb-2">Plan Summary</div>
                            <p className="text-sm text-gray-900 bg-white p-3 rounded border border-blue-200">
                              {visit.planSummary}
                            </p>
                          </div>
                        )}

                        {visit.doctorDecision.notes && (
                          <div className="mb-4">
                            <div className="text-sm text-gray-700 font-medium mb-2">Clinical Notes</div>
                            <p className="text-sm text-gray-900 bg-white p-3 rounded border border-blue-200">
                              {visit.doctorDecision.notes || 'No notes provided'}
                            </p>
                          </div>
                        )}

                        <div className="text-xs text-gray-700 pt-3 border-t border-blue-200">
                          <div className="font-medium">{visit.doctorDecision.doctorName}</div>
                          {visit.doctorDecision.doctorId && (
                            <div className="text-gray-500">ID: {visit.doctorDecision.doctorId}</div>
                          )}
                          <div className="mt-1">{new Date(visit.doctorDecision.timestamp).toLocaleString()}</div>
                        </div>
                      </div>
                    </div>

                    {/* Medications & Procedures from AI */}
                    {(visit.outcome.medications && visit.outcome.medications.length > 0) || 
                     (visit.outcome.procedures && visit.outcome.procedures.length > 0) ? (
                      <div className="grid grid-cols-2 gap-6 mb-4">
                        {/* Medications Section */}
                        {visit.outcome.medications && visit.outcome.medications.length > 0 && (
                          <div className="bg-white rounded-lg border border-gray-200 p-4">
                            <h3 className="text-sm font-medium text-gray-700 mb-3 flex items-center gap-2">
                              <Brain className="w-4 h-4 text-purple-600" />
                              AI Medication Recommendations
                            </h3>
                            <div className="space-y-3">
                              {visit.outcome.medications.map((med, idx) => (
                                <div key={idx} className="border border-gray-200 rounded p-3 bg-gray-50">
                                  <div className="font-medium text-sm text-gray-900 mb-1">{med.medication}</div>
                                  <div className="text-xs text-gray-600 space-y-1">
                                    {med.dose && <div><span className="font-medium">Dose:</span> {med.dose}</div>}
                                    {med.frequency && <div><span className="font-medium">Frequency:</span> {med.frequency}</div>}
                                    {med.duration && <div><span className="font-medium">Duration:</span> {med.duration}</div>}
                                    {med.rationale && <div className="mt-2 text-gray-700"><span className="font-medium">Rationale:</span> {med.rationale}</div>}
                                    {med.status && (
                                      <div className="mt-2">
                                        <span className={`px-2 py-0.5 rounded text-xs ${
                                          med.status === 'Active' || med.status === 'Continue' || med.status === 'Planned' 
                                            ? 'bg-green-100 text-green-700' 
                                            : 'bg-gray-100 text-gray-700'
                                        }`}>
                                          {med.status}
                                        </span>
                                      </div>
                                    )}
                                  </div>
                                </div>
                              ))}
                            </div>
                          </div>
                        )}

                        {/* Procedures Section */}
                        {visit.outcome.procedures && visit.outcome.procedures.length > 0 && (
                          <div className="bg-white rounded-lg border border-gray-200 p-4">
                            <h3 className="text-sm font-medium text-gray-700 mb-3 flex items-center gap-2">
                              <Brain className="w-4 h-4 text-purple-600" />
                              AI Procedure Recommendations
                            </h3>
                            <div className="space-y-3">
                              {visit.outcome.procedures.map((proc, idx) => (
                                <div key={idx} className="border border-gray-200 rounded p-3 bg-gray-50">
                                  <div className="font-medium text-sm text-gray-900 mb-1">{proc.procedure}</div>
                                  <div className="text-xs text-gray-600 space-y-1">
                                    {proc.timing && <div><span className="font-medium">Timing:</span> {proc.timing}</div>}
                                    {proc.rationale && <div className="mt-2 text-gray-700"><span className="font-medium">Rationale:</span> {proc.rationale}</div>}
                                    {proc.status && (
                                      <div className="mt-2">
                                        <span className={`px-2 py-0.5 rounded text-xs ${
                                          proc.status === 'Planned' || proc.status === 'Order'
                                            ? 'bg-blue-100 text-blue-700' 
                                            : 'bg-gray-100 text-gray-700'
                                        }`}>
                                          {proc.status}
                                        </span>
                                      </div>
                                    )}
                                  </div>
                                </div>
                              ))}
                            </div>
                          </div>
                        )}
                      </div>
                    ) : null}

                    {/* Outcome & Follow-up */}
                    <div className="bg-white rounded-lg border border-gray-200 p-4 mb-4">
                      <h3 className="text-sm font-medium text-gray-700 mb-3">Outcome & Follow-up</h3>
                      <div className="space-y-3">
                        <div className="flex items-center gap-3">
                          <span className={`px-3 py-1 text-sm font-medium rounded ${
                            visit.outcome.status === 'Follow-up scheduled' ? 'bg-blue-100 text-blue-700' :
                            visit.outcome.status === 'Monitoring continued' ? 'bg-green-100 text-green-700' :
                            'bg-gray-100 text-gray-700'
                          }`}>
                            {visit.outcome.status}
                          </span>
                          {visit.outcome.details && (
                            <span className="text-sm text-gray-600">{visit.outcome.details}</span>
                          )}
                        </div>
                        
                        {visit.outcome.followUpDate && (
                          <div className="text-sm text-gray-700">
                            <span className="font-medium">Follow-up Date: </span>
                            <span>{new Date(visit.outcome.followUpDate).toLocaleDateString()}</span>
                          </div>
                        )}
                        
                        {visit.outcome.monitoringStatus && (
                          <div className="text-sm text-gray-700">
                            <span className="font-medium">Monitoring Status: </span>
                            <span className={`px-2 py-0.5 rounded text-xs ${
                              visit.outcome.monitoringStatus === 'Active' ? 'bg-green-100 text-green-700' :
                              'bg-gray-100 text-gray-700'
                            }`}>
                              {visit.outcome.monitoringStatus}
                            </span>
                          </div>
                        )}
                      </div>

                      <div className="flex gap-3 mt-4">
                        {visit.hasAlarms && (
                          <button className="flex items-center gap-2 text-sm text-orange-600 hover:text-orange-700">
                            <AlertTriangle className="w-4 h-4" />
                            View related alarms
                          </button>
                        )}
                        {visit.hasDiscussion && (
                          <button
                            onClick={() => onOpenDiscussion(visit.id)}
                            className="flex items-center gap-2 text-sm text-blue-600 hover:text-blue-700"
                          >
                            <MessageSquare className="w-4 h-4" />
                            View discussion
                          </button>
                        )}
                      </div>
                    </div>

                    {/* Visit Metadata */}
                    <div className="bg-white rounded-lg border border-gray-200 p-4">
                      <h3 className="text-sm font-medium text-gray-700 mb-3">Visit Metadata</h3>
                      <div className="grid grid-cols-2 gap-4 text-sm">
                        <div>
                          <span className="text-gray-600">Visit ID: </span>
                          <span className="text-gray-900 font-mono text-xs">{visit.id}</span>
                        </div>
                        {visit.twinId && (
                          <div>
                            <span className="text-gray-600">Twin ID: </span>
                            <span className="text-gray-900 font-mono text-xs">{visit.twinId}</span>
                          </div>
                        )}
                        {visit.twinSummaryVersion && (
                          <div>
                            <span className="text-gray-600">Twin Summary Version: </span>
                            <span className="text-gray-900 font-mono text-xs">{visit.twinSummaryVersion}</span>
                          </div>
                        )}
                        {visit.createdAt && (
                          <div>
                            <span className="text-gray-600">Created: </span>
                            <span className="text-gray-900">{new Date(visit.createdAt).toLocaleString()}</span>
                          </div>
                        )}
                        {visit.updatedAt && (
                          <div>
                            <span className="text-gray-600">Updated: </span>
                            <span className="text-gray-900">{new Date(visit.updatedAt).toLocaleString()}</span>
                          </div>
                        )}
                      </div>
                    </div>
                  </div>
                )}

                {/* Timeline Connector */}
                {index < filteredVisits.length - 1 && (
                  <div className="flex justify-center">
                    <div className="w-px h-4 bg-gray-300"></div>
                  </div>
                )}
              </div>
            ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
