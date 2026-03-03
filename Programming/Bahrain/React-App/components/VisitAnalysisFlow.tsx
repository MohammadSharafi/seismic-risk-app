import { useState, useEffect } from 'react';
import ReactMarkdown from 'react-markdown';
import rehypeRaw from 'rehype-raw';
import { CheckCircle, Circle, ArrowRight, Brain, User, FileCheck, AlertCircle, Clock, FileText, Download, ChevronDown, ChevronUp, X, ShieldAlert } from 'lucide-react';
import { Patient } from '../App';
import { RiskBadge } from './RiskBadge';
import { MarkdownText, normalizeMarkdown } from './MarkdownText';
import { API_BASE_URL } from '../src/config';
import jsPDF from 'jspdf';

interface Practitioner {
  id: string;
  name: string;
  email: string;
  specialty?: string;
  role?: string;
}

interface VisitAnalysisFlowProps {
  patient: Patient;
  onViewFullRecord?: () => void;
  onViewClinicalDiscussion?: () => void;
  visitTrigger?: {
    type: 'Background Monitoring Alert' | 'Scheduled Follow-up' | 'Manual Review' | 'Alarm-Triggered Review';
    timestamp: string;
    source: 'AI' | 'System' | 'Doctor';
  };
  discussionReferenced?: boolean;
  loggedInPractitioner?: Practitioner | null;
}

type FlowStep = 1 | 2 | 3 | 4;

interface MedicationRecommendation {
  id: string;
  medication: string;
  dose: string;
  frequency: string;
  duration?: string;
  rationale: string;
  evidence: string[];
  status: string; // Original status from LLM (e.g., "Continue", "Start", "Stop", "Planned", etc.)
}

interface ProcedureRecommendation {
  id: string;
  procedure: string;
  timing: string;
  rationale: string;
  evidence: string[];
  status: string; // Original status from LLM (e.g., "Planned", "Consider", "Order", etc.)
  cptCode?: string; // Procedure code (CPT) from API
}

type DrugInteractionPair = { drugA: string; drugB: string; interactionTexts: string[] };

/** Matches [1], [2], [1, 2], [1, 2, 4] etc. */
const CITATION_RE = /\[(\d+(?:\s*,\s*\d+)*)\]/g;

function escapeHtmlAttr(s: string): string {
  return s
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

/**
 * Renders rag_results (or any text) with [1], [2], [1, 2] as inline citation circles
 * so references stay in the text flow (no newline before the circle).
 */
function RagResultsWithCitations({
  text,
  references = [],
  className = '',
  compact = false,
}: {
  text: string;
  references?: Array<{ index?: number; source?: string }>;
  className?: string;
  compact?: boolean;
}) {
  const getRef = (index: number) =>
    references.find((r) => Number(r.index) === index);

  const normalized = normalizeMarkdown(typeof text === 'string' ? text : '');
  // Replace [1], [2], [1, 2] with inline HTML so they render in the same line as the text
  const withInlineCitations = normalized.replace(CITATION_RE, (_, nums: string) => {
    const indices = nums.split(/\s*,\s*/).map((s) => parseInt(s.trim(), 10)).filter((n) => !Number.isNaN(n));
    if (!indices.length) return '';
    const circles = indices.map((index) => {
      const rawSource = getRef(index)?.source ?? 'No source';
      const tooltip = escapeHtmlAttr(`Reference ${index}: ${rawSource}`);
      return `<span class="citation-inline" data-source="${tooltip}" role="button" tabindex="0" aria-label="Citation ${index}">${index}</span>`;
    });
    return circles.join('<span class="inline-block w-0.5 shrink-0" aria-hidden="true"></span>');
  });

  const markdownComponents = {
    p: ({ children }: { children?: React.ReactNode }) => <p className="mb-2 last:mb-0 text-inherit leading-relaxed markdown-p">{children}</p>,
    strong: ({ children }: { children?: React.ReactNode }) => <strong className="font-semibold text-gray-900">{children}</strong>,
    ul: ({ children }: { children?: React.ReactNode }) => <ul className="list-disc list-inside mb-2 space-y-0.5 pl-2 markdown-ul">{children}</ul>,
    ol: ({ children }: { children?: React.ReactNode }) => <ol className="list-decimal list-inside mb-2 space-y-0.5 pl-2 markdown-ol">{children}</ol>,
    li: ({ children }: { children?: React.ReactNode }) => <li className="text-inherit leading-relaxed">{children}</li>,
    em: ({ children }: { children?: React.ReactNode }) => <em>{children}</em>,
  };

  if (!withInlineCitations.trim()) return <span className={className} />;

  return (
    <div className={`markdown-content text-inherit ${className} ${compact ? 'space-y-0 markdown-compact' : ''}`}>
      <ReactMarkdown rehypePlugins={[rehypeRaw]} components={markdownComponents}>
        {withInlineCitations.trim()}
      </ReactMarkdown>
    </div>
  );
}

export function VisitAnalysisFlow({ patient, onViewFullRecord, onViewClinicalDiscussion, visitTrigger, discussionReferenced, loggedInPractitioner }: VisitAnalysisFlowProps) {
  const [currentStep, setCurrentStep] = useState<FlowStep>(1);
  const [flowStatus, setFlowStatus] = useState<'not-started' | 'in-progress' | 'completed'>('not-started');
  const [analysisRun, setAnalysisRun] = useState(false);
  const [aiRecommendation, setAiRecommendation] = useState<{
    riskTier: 'Low' | 'Medium' | 'High' | 'Critical';
    reasoning: string[];
    confidence?: string;
    reasoningReferences?: Array<{type: string; label: string; source: string}>;
    medicationRecommendations?: any[];
    procedureRecommendations?: any[];
    additionalRecommendations?: string[];
    riskAssessment?: any;
    differentialDiagnosis?: Array<{
      diagnosisName: string;
      probabilityBin: string;
      confidenceScore?: number;
      reasoning?: string;
      supportingEvidence?: string[];
    }>;
  } | null>(null);
  const [doctorDecision, setDoctorDecision] = useState<any>(null);
  const [showStructuredRationale, setShowStructuredRationale] = useState(false);
  const [selectedRiskTier, setSelectedRiskTier] = useState<'Low' | 'Medium' | 'High' | 'Critical'>('High');
  const [reasoningNotes, setReasoningNotes] = useState('');
      const [loadingData, setLoadingData] = useState(false);
      const [loadingAI, setLoadingAI] = useState(false);
      const [finalizing, setFinalizing] = useState(false);
      const [assessmentInputData, setAssessmentInputData] = useState<any>(null);
      const [error, setError] = useState<string | null>(null);
  const [dataFetchSummary, setDataFetchSummary] = useState<{
    alarms: number;
    riskFactors: number;
    twinSummaries: number;
  } | null>(null);
  const [summaryText, setSummaryText] = useState<string | null>(null);
  const [openRisks, setOpenRisks] = useState<any[]>([]);
  // Clinical Watchlist: time-sensitive / time-insensitive sections collapsed by default
  const [riskTimeSensitiveOpen, setRiskTimeSensitiveOpen] = useState(false);
  const [riskTimeInsensitiveOpen, setRiskTimeInsensitiveOpen] = useState(false);
  // Expand/collapse states for Step 3 cards
  const [expandedDiagnosis, setExpandedDiagnosis] = useState<Set<number>>(new Set());
  const [expandedMedications, setExpandedMedications] = useState<Set<string>>(new Set());
  const [expandedProcedures, setExpandedProcedures] = useState<Set<string>>(new Set());
  const [expandedRiskAssessment, setExpandedRiskAssessment] = useState(false);
  const [expandedAdditionalRecs, setExpandedAdditionalRecs] = useState(false);
  const [evidenceSummaryModal, setEvidenceSummaryModal] = useState<{ title: string; content: string; references?: Array<{ index?: number; source?: string }> } | null>(null);
  // Start with empty arrays - will be populated from LLM response in Step 3
  const [medications, setMedications] = useState<MedicationRecommendation[]>([]);
  const [procedures, setProcedures] = useState<ProcedureRecommendation[]>([]);
  // Drug interactions among recommended medications (section below Medications)
  const [drugInteractionsSection, setDrugInteractionsSection] = useState<
    'idle' | 'loading' | { pairs: DrugInteractionPair[] } | { error: true }
  >('idle');

  // Toggle functions for expand/collapse
  const toggleDiagnosis = (idx: number) => {
    setExpandedDiagnosis(prev => {
      const newSet = new Set(prev);
      if (newSet.has(idx)) {
        newSet.delete(idx);
      } else {
        newSet.add(idx);
      }
      return newSet;
    });
  };

  const toggleMedication = (id: string) => {
    setExpandedMedications(prev => {
      const newSet = new Set(prev);
      if (newSet.has(id)) {
        newSet.delete(id);
      } else {
        newSet.add(id);
      }
      return newSet;
    });
  };

  const toggleProcedure = (id: string) => {
    setExpandedProcedures(prev => {
      const newSet = new Set(prev);
      if (newSet.has(id)) {
        newSet.delete(id);
      } else {
        newSet.add(id);
      }
      return newSet;
    });
  };

  // Load drug interactions among recommended medications (run when medications list is set)
  useEffect(() => {
    const names = medications.map((m) => m.medication.trim()).filter(Boolean);
    if (names.length === 0) {
      setDrugInteractionsSection('idle');
      return;
    }
    const recommendedSet = new Set(names.map((n) => n.toLowerCase()));
    const nameByLower = new Map<string, string>();
    names.forEach((n) => nameByLower.set(n.toLowerCase(), n));
    setDrugInteractionsSection('loading');
    Promise.all(
      names.map((drugName) =>
        fetch(`${API_BASE_URL}/drug-interactions?drug=${encodeURIComponent(drugName)}`)
          .then((r) => r.json())
          .then((res) => {
            const data = res?.data ?? res;
            const interactionTexts: string[] = data?.interactionTexts ?? [];
            const mentionedDrugs: string[] = data?.mentionedDrugs ?? [];
            const others = mentionedDrugs
              .filter(
                (d) => d && recommendedSet.has(d.trim().toLowerCase()) && d.trim().toLowerCase() !== drugName.toLowerCase()
              )
              .map((d) => nameByLower.get(d.trim().toLowerCase()) ?? d.trim());
            return { drug: drugName, others: [...new Set(others)], interactionTexts };
          })
          .catch(() => ({ drug: drugName, others: [] as string[], interactionTexts: [] as string[] }))
      )
    )
      .then((results) => {
        const pairKeys = new Set<string>();
        const pairs: DrugInteractionPair[] = [];
        results.forEach((r) => {
          r.others.forEach((other) => {
            const key = [r.drug.toLowerCase(), other.toLowerCase()].sort().join('|');
            if (pairKeys.has(key)) return;
            pairKeys.add(key);
            pairs.push({ drugA: r.drug, drugB: other, interactionTexts: r.interactionTexts });
          });
        });
        setDrugInteractionsSection({ pairs });
      })
      .catch(() => setDrugInteractionsSection({ error: true }));
  }, [medications]);

  // Normalize risk tier to only allow Low, Medium, High, or Critical
  const normalizeRiskTier = (tier: string | undefined | null): 'Low' | 'Medium' | 'High' | 'Critical' => {
    if (!tier) return 'Medium';
    const normalized = tier.trim();
    const lower = normalized.toLowerCase();
    
    // Map various risk tier values to valid ones
    if (lower === 'low' || lower === 'low risk' || lower === 'low alert') return 'Low';
    if (lower === 'medium' || lower === 'medium risk' || lower === 'moderate' || lower === 'moderate risk' || lower === 'moderate alert') return 'Medium';
    if (lower === 'critical' || lower === 'critical risk' || lower === 'critical alert' || lower === 'severe' || lower === 'severe risk') return 'Critical';
    if (lower === 'high' || lower === 'high risk' || lower === 'high alert') return 'High';
    
    // Default to Medium if unknown
    return 'Medium';
  };

  const handleRunAnalysis = async () => {
    setLoadingData(true);
    setFlowStatus('in-progress');
    setError(null);
    
    try {
      // Step 1: Fetch patient data
      const visitId = `visit_${Date.now()}`;
      const visitType = visitTrigger?.type || 'Manual Review';
      
      const fetchResponse = await fetch(
        `${API_BASE_URL}/analyze/fetch-data/${patient.id}?visitId=${visitId}&visitType=${encodeURIComponent(visitType)}`
      );
      
      if (!fetchResponse.ok) {
        const errorData = await fetchResponse.json().catch(() => ({}));
        throw new Error(errorData.error?.message || `Failed to fetch data: ${fetchResponse.statusText}`);
      }
      
      const fetchResult = await fetchResponse.json();
      const inputData = fetchResult.data;
      setAssessmentInputData(inputData);
      
      // Set data summary for display
      setDataFetchSummary({
        alarms: inputData.alarm?.length || 0,
        riskFactors: inputData.risk_factor?.length || 0,
        twinSummaries: inputData.twin_summary_versions?.length || 0,
      });
      
      // Extract summary text from latest twin summary
      if (inputData.twin_summary_versions && inputData.twin_summary_versions.length > 0) {
        const latestSummary = inputData.twin_summary_versions[0];
        // summary_text might be a string or parsed JSON
        if (typeof latestSummary.summary_text === 'string') {
          setSummaryText(latestSummary.summary_text);
        } else if (latestSummary.summary_text) {
          setSummaryText(JSON.stringify(latestSummary.summary_text));
        }
      }
      
      // Extract open risks from risk_factor table
      if (inputData.risk_factor && Array.isArray(inputData.risk_factor)) {
        // Filter for active/open risks
        const open = inputData.risk_factor.filter((risk: any) => {
          // Check various ways is_active might be represented
          const isActive = risk.is_active === true || 
                          risk.is_active === 'true' || 
                          String(risk.is_active).toLowerCase() === 'true' ||
                          risk.status === 'OPEN' ||
                          risk.status === 'ACTIVE';
          return isActive;
        });
        setOpenRisks(open);
      }
      
      setAnalysisRun(true);
      setCurrentStep(2);
      setLoadingData(false);
    } catch (error: any) {
      console.error('Error fetching Function 1 input data:', error);
      setError(error.message || 'Failed to fetch data');
      setLoadingData(false);
      // Don't proceed on error - let user retry
    }
  };

  const handleReviewAI = async () => {
    if (!assessmentInputData) {
      // If no input data, just proceed to step 3
      setCurrentStep(3);
      return;
    }
    
    setLoadingAI(true);
    setError(null);
    
    try {
      // Step 2: Send data to LLM API (Assessment mode)
      const response = await fetch(`${API_BASE_URL}/analyze/generate-assessment`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(assessmentInputData),
      });
      
      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.error?.message || `Failed to generate assessment: ${response.statusText}`);
      }
      
      const result = await response.json();
      // Support both wrapped { data: ... } and direct payload
      const aiResponse = result?.data ?? result;
      if (!aiResponse) {
        throw new Error('No assessment data received from server');
      }
      
      // Normalize risk tier from LLM response
      const normalizedRiskTier = normalizeRiskTier(aiResponse.ai_recommendation?.risk_tier || patient.riskTier);
      
      // Normalize differential_diagnosis so UI always has rag_results, diagnosis_code, and references (snake_case from API)
      // references: from LLM or backend fallback (populated from [1], [2] in rag_results when LLM returns null)
      const rawDiagnosis = aiResponse.differential_diagnosis || [];
      const differentialDiagnosis = rawDiagnosis.map((d: any) => {
        const ragResults = (d.rag_results ?? d.ragResults ?? '').toString().trim();
        const refs: Array<{ index?: number; source?: string }> = Array.isArray(d.references) ? d.references : [];
        return {
          ...d,
          diagnosis_name: d.diagnosis_name ?? d.diagnosisName,
          diagnosis_code: (d.diagnosis_code ?? d.diagnosisCode ?? '').toString().trim(),
          rag_results: ragResults,
          ragResults,
          supporting_evidence: d.supporting_evidence ?? d.supportingEvidence ?? [],
          probability_bin: d.probability_bin ?? d.probabilityBin,
          confidence_score: d.confidence_score ?? d.confidenceScore,
          references: refs,
        };
      });

      // Update AI recommendation with response
      setAiRecommendation({
        riskTier: normalizedRiskTier,
        reasoning: aiResponse.ai_recommendation?.reasoning || [
          'Multiple high-risk comorbidities detected',
          'Elevated blood pressure above target range',
          'Medication interaction risk identified'
        ],
        confidence: aiResponse.ai_recommendation?.confidence || 'High',
        reasoningReferences: aiResponse.ai_recommendation?.reasoning_references || [],
        medicationRecommendations: aiResponse.medication_recommendations || [],
        procedureRecommendations: aiResponse.procedure_recommendations || [],
        additionalRecommendations: aiResponse.additional_recommendations || [],
        riskAssessment: aiResponse.risk_assessment || null,
        differentialDiagnosis,
      });
      
      // Also update selected risk tier to match AI recommendation initially
      setSelectedRiskTier(normalizedRiskTier);
      
      // Update medications and procedures from AI response - keep original status from LLM
      if (aiResponse.medication_recommendations && aiResponse.medication_recommendations.length > 0) {
        const meds = aiResponse.medication_recommendations.map((med: any, idx: number) => ({
          id: `med_${idx + 1}`,
          medication: med.medication || 'Unknown medication',
          medicationCode: med.medication_code || '',
          dose: med.dose || '',
          frequency: med.frequency || '',
          duration: med.duration || 'Ongoing',
          rationale: med.rationale || '',
          evidence: Array.isArray(med.reasoning) ? med.reasoning : (med.reasoning ? [med.reasoning] : []),
          status: med.status || 'Unknown', // Keep original status from LLM
          priority: med.priority || '',
          contraindications: Array.isArray(med.contraindications) ? med.contraindications : [],
          monitoringRequired: Array.isArray(med.monitoring_required) ? med.monitoring_required : []
        }));
        setMedications(meds);
      } else {
        // If no medications from AI, clear existing ones (or keep empty)
        setMedications([]);
      }
      
      if (aiResponse.procedure_recommendations && aiResponse.procedure_recommendations.length > 0) {
        const procs = aiResponse.procedure_recommendations.map((proc: any, idx: number) => ({
          id: `proc_${idx + 1}`,
          procedure: proc.procedure || 'Unknown procedure',
          timing: proc.timing || '',
          rationale: proc.rationale || '',
          evidence: Array.isArray(proc.reasoning) ? proc.reasoning : (proc.reasoning ? [proc.reasoning] : []),
          status: proc.status || 'Unknown',
          priority: proc.priority || '',
          cptCode: (proc.cpt_code ?? proc.cptCode ?? '').toString().trim() || undefined,
        }));
        setProcedures(procs);
      } else {
        // If no procedures from AI, clear existing ones (or keep empty)
        setProcedures([]);
      }
      
      setLoadingAI(false);
      setCurrentStep(3);
    } catch (error: any) {
      console.error('Error generating clinical assessment:', error);
      setError(error.message || 'Failed to generate clinical assessment');
      setLoadingAI(false);
      // Don't proceed on error - show error message
    }
  };

  // Helper function to determine if status indicates "active/planned"
  const isActiveStatus = (status: string): boolean => {
    const lower = (status || '').toLowerCase();
    return lower === 'planned' || lower === 'continue' || lower === 'start' || 
           lower === 'increase' || lower === 'add' || lower === 'adjust' || 
           lower === 'order' || lower === 'schedule' || lower === 'urgent' || 
           lower === 'asap';
  };

  // Helper function to get status badge styling
  const getStatusBadgeClass = (status: string): string => {
    const lower = (status || '').toLowerCase();
    if (lower === 'planned' || lower === 'continue' || lower === 'start' || 
        lower === 'order' || lower === 'schedule' || lower === 'urgent' || 
        lower === 'asap' || lower === 'critical') {
      return 'bg-green-100 text-green-800 border border-green-200';
    } else if (lower === 'consider' || lower === 'defer' || lower === 'not planned') {
      return 'bg-amber-100 text-amber-800 border border-amber-200';
    } else if (lower === 'stop' || lower === 'discontinue') {
      return 'bg-red-100 text-red-800 border border-red-200';
    }
    return 'bg-gray-100 text-gray-600 border border-gray-200';
  };

  const handleApproveDecision = async () => {
    if (!assessmentInputData || !aiRecommendation) {
      setError('Missing required data to finalize decision');
      return;
    }

    setFinalizing(true);
    setError(null);

    try {
      // Get twin_id from assessment input data
      const twinId = assessmentInputData.twinId || assessmentInputData.twin_id || `twin_${patient.id}`;
      const visitId = assessmentInputData.visitId || assessmentInputData.visit_id || `visit_${Date.now()}`;
      const visitType = assessmentInputData.visitType || assessmentInputData.visit_type || visitTrigger?.type || 'Manual Review';
      
      // Get current timestamp
      const now = new Date().toISOString();
      
      // Build finalized medications array
      const finalizedMeds = medications.map((med) => ({
        id: med.id,
        medication: med.medication,
        dose: med.dose,
        frequency: med.frequency,
        duration: med.duration || 'Ongoing',
        rationale: med.rationale,
        reasoning: med.evidence || [],
        status: med.status,
        doctor_modified: false, // TODO: Track if doctor modified
        doctor_notes: null
      }));

      // Build finalized procedures array
      const finalizedProcs = procedures.map((proc) => ({
        id: proc.id,
        procedure: proc.procedure,
        timing: proc.timing,
        rationale: proc.rationale,
        reasoning: proc.evidence || [],
        status: proc.status,
        doctor_modified: false, // TODO: Track if doctor modified
        doctor_notes: null
      }));

      // Build visit context
      const visitContext = {
        visit_type: visitType,
        trigger_source: visitTrigger?.source || 'Doctor-initiated',
        visit_reason: visitTrigger?.type || 'Routine follow-up',
        encounter_id: visitId,
        encounter_start: assessmentInputData.asOfTimeUtc || assessmentInputData.as_of_time_utc || now,
        encounter_end: now
      };

      // Build patient data snapshot from assessment input
      const patientDataSnapshot = {
        conditions: assessmentInputData.patientSnapshot?.currentConditions || assessmentInputData.patient_snapshot?.current_conditions || [],
        medications: assessmentInputData.patientSnapshot?.currentMedications || assessmentInputData.patient_snapshot?.current_medications || [],
        latest_vitals: assessmentInputData.patientSnapshot?.latestVitals || assessmentInputData.patient_snapshot?.latest_vitals || {}
      };

      // Extract latest twin summary (first one in the array, which should be the latest)
      const latestTwinSummary = assessmentInputData.twin_summary_versions && assessmentInputData.twin_summary_versions.length > 0
        ? assessmentInputData.twin_summary_versions[0]
        : null;

      // Build the request payload
      const requestPayload = {
        twin_id: twinId,
        patient_id: patient.id,
        visit_id: visitId,
        as_of_time_utc: now,
        created_at_override_utc: null,
        doctor_decision: {
          final_risk_tier: aiRecommendation.riskTier,
          ai_risk_tier: aiRecommendation.riskTier,
          risk_tier_override: false,
          reasoning_notes: reasoningNotes,
          doctor_id: loggedInPractitioner?.id || 'unknown',
          doctor_name: loggedInPractitioner?.name || 'Unknown Doctor',
          decision_timestamp: now
        },
        finalized_medications: finalizedMeds,
        finalized_procedures: finalizedProcs,
        visit_context: visitContext,
        patient_data_snapshot: patientDataSnapshot,
        // Add alarms, risks, and latest twin summary from Step 2 data
        alarm: assessmentInputData.alarm || [],
        risk_factor: assessmentInputData.risk_factor || [],
        latest_twin_summary: latestTwinSummary,
        config: {
          N_TREND_POINTS: 3,
          MAX_ACTION_INBOX_ITEMS: 10,
          REFILL_GRACE_DAYS: 3,
          FOLLOW_UP_DUE_HOUR_UTC: 17
        }
      };

      // Call Function 2 API
      const response = await fetch(`${API_BASE_URL}/analyze/finalize-decision`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(requestPayload),
      });

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.error?.message || `Failed to finalize decision: ${response.statusText}`);
      }

      const result = await response.json();
      const twinSummary = result.data;

      // Success - proceed to step 4
      setCurrentStep(4);
      setFlowStatus('completed');
      const activeMeds = medications.filter(m => isActiveStatus(m.status)).length;
      const activeProcs = procedures.filter(p => isActiveStatus(p.status)).length;
      
      // Calculate follow-up date (default: 7 days from now, or from twin summary if available)
      const calculateFollowUpDate = () => {
        try {
          // Try to get follow-up from twin summary encounter_digest.follow_up_register
          if (twinSummary?.summaryJson) {
            const encounterDigest = twinSummary.summaryJson.encounter_digest;
            if (encounterDigest && typeof encounterDigest === 'object') {
              const followUpRegister = (encounterDigest as any).follow_up_register;
              if (followUpRegister && Array.isArray(followUpRegister) && followUpRegister.length > 0) {
                const nextFollowUp = followUpRegister[0];
                if (nextFollowUp?.due_date) {
                  const followUpDate = new Date(nextFollowUp.due_date);
                  if (!isNaN(followUpDate.getTime())) {
                    return followUpDate.toLocaleDateString('en-US', { 
                      year: 'numeric', 
                      month: 'short', 
                      day: 'numeric' 
                    });
                  }
                }
              }
            }
          }
        } catch (e) {
          console.warn('Error parsing follow-up date from twin summary:', e);
        }
        
        // Default: 7 days from now based on risk tier
        // Higher risk = shorter follow-up interval
        const daysUntilFollowUp = aiRecommendation.riskTier === 'High' ? 3 : aiRecommendation.riskTier === 'Medium' ? 7 : 14;
        const followUpDate = new Date();
        followUpDate.setDate(followUpDate.getDate() + daysUntilFollowUp);
        return followUpDate.toLocaleDateString('en-US', { 
          year: 'numeric', 
          month: 'short', 
          day: 'numeric' 
        });
      };
      
      // Determine monitoring status (from twin summary or default to active)
      const getMonitoringStatus = () => {
        try {
          if (twinSummary?.summaryJson) {
            const actionInbox = twinSummary.summaryJson.action_inbox;
            // If there are active items in action_inbox, monitoring is active
            if (actionInbox && Array.isArray(actionInbox) && actionInbox.length > 0) {
              return 'Active';
            }
            // Check if there are any red flags or issues that require monitoring
            const riskReadyOutputs = twinSummary.summaryJson.risk_ready_outputs;
            if (riskReadyOutputs && typeof riskReadyOutputs === 'object') {
              const redFlags = (riskReadyOutputs as any).red_flags;
              if (redFlags && Array.isArray(redFlags) && redFlags.length > 0) {
                return 'Active';
              }
            }
          }
        } catch (e) {
          console.warn('Error parsing monitoring status from twin summary:', e);
        }
        // Default: Active for all finalized decisions
        return 'Active';
      };
      
      setDoctorDecision({
        approved: true,
        timestamp: new Date().toLocaleString(),
        riskTier: aiRecommendation.riskTier,
        planSummary: `${activeMeds} medication adjustment${activeMeds !== 1 ? 's' : ''}, ${activeProcs} procedure${activeProcs !== 1 ? 's' : ''}`,
        twinSummary: twinSummary, // Store the twin summary response
        followUpDate: calculateFollowUpDate(),
        monitoringStatus: getMonitoringStatus()
      });

      setFinalizing(false);
    } catch (error: any) {
      console.error('Error finalizing decision:', error);
      setError(error.message || 'Failed to finalize decision');
      setFinalizing(false);
      // Don't proceed to step 4 on error
    }
  };

  // Medication handlers
  const handleDownloadVisitReport = () => {
    if (!doctorDecision || !aiRecommendation) {
      console.error('Cannot generate report: Missing decision or AI recommendation data');
      return;
    }

    // TypeScript: After null check, we know these are non-null
    const aiRec = aiRecommendation;
    const decision = doctorDecision;

    const doc = new jsPDF();
    const pageWidth = doc.internal.pageSize.getWidth();
    const pageHeight = doc.internal.pageSize.getHeight();
    const margin = 20;
    const contentWidth = pageWidth - 2 * margin;
    let yPos = margin;

    // Helper function to add new page if needed
    const checkPageBreak = (requiredSpace: number) => {
      if (yPos + requiredSpace > pageHeight - margin) {
        doc.addPage();
        yPos = margin;
        return true;
      }
      return false;
    };

    // Helper function to add text with word wrap
    const addText = (text: string, x: number, y: number, options: { fontSize?: number; fontStyle?: string; color?: [number, number, number]; maxWidth?: number } = {}) => {
      const { fontSize = 10, fontStyle = 'normal', color = [0, 0, 0], maxWidth = contentWidth } = options;
      doc.setFontSize(fontSize);
      doc.setFont('helvetica', fontStyle);
      doc.setTextColor(color[0], color[1], color[2]);
      
      const lines = doc.splitTextToSize(text, maxWidth);
      doc.text(lines, x, y);
      return lines.length * fontSize * 0.4; // Return height used
    };

    // Header
    doc.setFillColor(59, 130, 246); // Blue
    doc.rect(0, 0, pageWidth, 40, 'F');
    doc.setTextColor(255, 255, 255);
    doc.setFontSize(20);
    doc.setFont('helvetica', 'bold');
    doc.text('Visit Report', margin, 25);
    
    doc.setFontSize(10);
    doc.setFont('helvetica', 'normal');
    doc.text(`Patient: ${patient.name} | ${patient.id}`, margin, 35);
    doc.text(`Generated: ${new Date().toLocaleString()}`, pageWidth - margin, 35, { align: 'right' });
    
    yPos = 50;
    doc.setTextColor(0, 0, 0);

    // Visit Information
    checkPageBreak(20);
    doc.setFontSize(14);
    doc.setFont('helvetica', 'bold');
    doc.text('Visit Information', margin, yPos);
    yPos += 10;

    doc.setFontSize(10);
    doc.setFont('helvetica', 'normal');
    if (visitTrigger) {
      yPos += addText(`Trigger Type: ${visitTrigger.type}`, margin, yPos, { maxWidth: contentWidth / 2 });
      yPos += addText(`Source: ${visitTrigger.source}`, margin + contentWidth / 2, yPos, { maxWidth: contentWidth / 2 });
      yPos += addText(`Timestamp: ${visitTrigger.timestamp}`, margin, yPos);
    }
    yPos += 15;

    // AI Assessment Section (Step 3)
    checkPageBreak(30);
    doc.setFontSize(14);
    doc.setFont('helvetica', 'bold');
    doc.text('AI Clinical Assessment', margin, yPos);
    yPos += 10;

    doc.setFontSize(10);
    doc.setFont('helvetica', 'normal');
    const riskTierDisplay = aiRec.riskTier === 'Critical' ? 'Critical Alert' :
                            aiRec.riskTier === 'High' ? 'High Alert' :
                            aiRec.riskTier === 'Medium' ? 'Moderate Alert' : 'Low Alert';
    yPos += addText(`Risk Tier: ${riskTierDisplay}`, margin, yPos, { fontSize: 11, fontStyle: 'bold' });
    yPos += 8;

    // Clinical Reasoning
    if (aiRec.reasoning && aiRec.reasoning.length > 0) {
      checkPageBreak(15);
      doc.setFontSize(11);
      doc.setFont('helvetica', 'bold');
      doc.text('Clinical Reasoning:', margin, yPos);
      yPos += 7;
      doc.setFontSize(10);
      doc.setFont('helvetica', 'normal');
      aiRec.reasoning.forEach((reason: string) => {
        checkPageBreak(10);
        yPos += addText(`• ${reason}`, margin + 5, yPos);
        yPos += 6;
      });
      yPos += 5;
    }

    // Differential Diagnosis
    if (aiRec.differentialDiagnosis && aiRec.differentialDiagnosis.length > 0) {
      checkPageBreak(20);
      doc.setFontSize(11);
      doc.setFont('helvetica', 'bold');
      doc.text('Differential Diagnosis:', margin, yPos);
      yPos += 10;

      aiRec.differentialDiagnosis.forEach((diagnosis: any, idx: number) => {
        checkPageBreak(40);
        const diagnosisName = diagnosis.diagnosisName || diagnosis.diagnosis_name || 'Diagnosis';
        const probabilityBin = diagnosis.probabilityBin || diagnosis.probability_bin || 'Low';
        const reasoning = diagnosis.reasoning || '';
        const supportingEvidence = diagnosis.supportingEvidence || diagnosis.supporting_evidence || [];

        doc.setFontSize(10);
        doc.setFont('helvetica', 'bold');
        yPos += addText(`${idx + 1}. ${diagnosisName}`, margin, yPos);
        yPos += 5;

        doc.setFontSize(9);
        doc.setFont('helvetica', 'normal');
        doc.setTextColor(100, 100, 100);
        yPos += addText(`Confidence: ${probabilityBin}`, margin + 5, yPos);
        doc.setTextColor(0, 0, 0);
        yPos += 6;

        if (reasoning) {
          checkPageBreak(15);
          doc.setFontSize(9);
          yPos += addText(`Reasoning: ${reasoning}`, margin + 5, yPos);
          yPos += 8;
        }

        if (supportingEvidence && supportingEvidence.length > 0) {
          checkPageBreak(10);
          doc.setFontSize(9);
          doc.text('Supporting Evidence:', margin + 5, yPos);
          yPos += 6;
          supportingEvidence.forEach((evidence: string) => {
            checkPageBreak(8);
            yPos += addText(`  • ${evidence}`, margin + 5, yPos, { fontSize: 9 });
            yPos += 5;
          });
        }
        yPos += 5;
      });
    }

    // Medications
    if (medications && medications.length > 0) {
      checkPageBreak(20);
      doc.setFontSize(11);
      doc.setFont('helvetica', 'bold');
      doc.text('Medication Recommendations:', margin, yPos);
      yPos += 10;

      medications.forEach((med: MedicationRecommendation, idx: number) => {
        checkPageBreak(25);
        doc.setFontSize(10);
        doc.setFont('helvetica', 'bold');
        yPos += addText(`${idx + 1}. ${med.medication}`, margin, yPos);
        yPos += 5;

        doc.setFontSize(9);
        doc.setFont('helvetica', 'normal');
        yPos += addText(`   Dose: ${med.dose} | Frequency: ${med.frequency}${med.duration ? ` | Duration: ${med.duration}` : ''}`, margin + 5, yPos);
        yPos += 5;
        yPos += addText(`   Status: ${med.status}`, margin + 5, yPos);
        yPos += 5;
        yPos += addText(`   Rationale: ${med.rationale}`, margin + 5, yPos);
        
        if (med.evidence && med.evidence.length > 0) {
          yPos += 5;
          doc.setFontSize(8);
          doc.text('   Evidence:', margin + 5, yPos);
          yPos += 5;
          med.evidence.forEach((ev: string) => {
            checkPageBreak(6);
            yPos += addText(`     • ${ev}`, margin + 5, yPos, { fontSize: 8 });
            yPos += 4;
          });
        }
        yPos += 8;
      });
    }

    // Procedures
    if (procedures && procedures.length > 0) {
      checkPageBreak(20);
      doc.setFontSize(11);
      doc.setFont('helvetica', 'bold');
      doc.text('Procedure Recommendations:', margin, yPos);
      yPos += 10;

      procedures.forEach((proc: ProcedureRecommendation, idx: number) => {
        checkPageBreak(25);
        doc.setFontSize(10);
        doc.setFont('helvetica', 'bold');
        yPos += addText(`${idx + 1}. ${proc.procedure}`, margin, yPos);
        yPos += 5;

        doc.setFontSize(9);
        doc.setFont('helvetica', 'normal');
        yPos += addText(`   Timing: ${proc.timing} | Status: ${proc.status}`, margin + 5, yPos);
        yPos += 5;
        yPos += addText(`   Rationale: ${proc.rationale}`, margin + 5, yPos);
        
        if (proc.evidence && proc.evidence.length > 0) {
          yPos += 5;
          doc.setFontSize(8);
          doc.text('   Evidence:', margin + 5, yPos);
          yPos += 5;
          proc.evidence.forEach((ev: string) => {
            checkPageBreak(6);
            yPos += addText(`     • ${ev}`, margin + 5, yPos, { fontSize: 8 });
            yPos += 4;
          });
        }
        yPos += 8;
      });
    }

    // Final Decision Section (Step 4)
    checkPageBreak(30);
    doc.setFontSize(14);
    doc.setFont('helvetica', 'bold');
    doc.text('Final Clinical Decision', margin, yPos);
    yPos += 10;

    doc.setFontSize(10);
    doc.setFont('helvetica', 'normal');
    const finalRiskTierDisplay = decision.riskTier === 'Critical' ? 'Critical Alert' :
                                  decision.riskTier === 'High' ? 'High Alert' :
                                  decision.riskTier === 'Medium' ? 'Moderate Alert' : 'Low Alert';
    yPos += addText(`Final Risk Tier: ${finalRiskTierDisplay}`, margin, yPos, { fontSize: 11, fontStyle: 'bold' });
    yPos += 8;

    yPos += addText(`Approved By: ${loggedInPractitioner?.name || decision.approvedBy || 'Unknown Doctor'}`, margin, yPos);
    yPos += 8;
    yPos += addText(`Completed At: ${decision.timestamp || new Date().toLocaleString()}`, margin, yPos);
    yPos += 8;

    if (decision.reasoningNotes) {
      checkPageBreak(15);
      doc.setFontSize(10);
      doc.setFont('helvetica', 'bold');
      doc.text('Clinical Reasoning Notes:', margin, yPos);
      yPos += 7;
      doc.setFont('helvetica', 'normal');
      yPos += addText(decision.reasoningNotes, margin, yPos);
      yPos += 10;
    }

    // Digital Twin Summary
    if (decision.twinSummary) {
      checkPageBreak(30);
      doc.setFontSize(11);
      doc.setFont('helvetica', 'bold');
      doc.text('Digital Twin Summary', margin, yPos);
      yPos += 10;

      doc.setFontSize(9);
      doc.setFont('helvetica', 'normal');
      if (decision.twinSummary.summaryVersion) {
        yPos += addText(`Summary Version: ${decision.twinSummary.summaryVersion}`, margin, yPos);
        yPos += 6;
      }
      if (decision.twinSummary.asOfTime) {
        const asOfTime = new Date(decision.twinSummary.asOfTime).toLocaleString();
        yPos += addText(`As of Time: ${asOfTime}`, margin, yPos);
        yPos += 8;
      }
      if (decision.twinSummary.summaryText) {
        checkPageBreak(20);
        doc.setFontSize(9);
        doc.setFont('helvetica', 'bold');
        doc.text('Clinical Summary:', margin, yPos);
        yPos += 7;
        doc.setFont('helvetica', 'normal');
        yPos += addText(decision.twinSummary.summaryText, margin, yPos);
        yPos += 10;
      }
    }

    // Visit Outcomes
    checkPageBreak(30);
    doc.setFontSize(11);
    doc.setFont('helvetica', 'bold');
    doc.text('Visit Outcomes', margin, yPos);
    yPos += 10;

    doc.setFontSize(9);
    doc.setFont('helvetica', 'normal');
    yPos += addText('✓ Decision Documented - Clinical decision saved to record', margin, yPos);
    yPos += 6;
    yPos += addText(`✓ Treatment Plan - ${decision.planSummary || 'Treatment plan recorded'}`, margin, yPos);
    yPos += 6;
    yPos += addText('✓ Twin Summary - Generated and saved', margin, yPos);
    yPos += 6;
    yPos += addText(`✓ Monitoring Status - ${decision.monitoringStatus || 'Active'}`, margin, yPos);
    if (decision.followUpDate) {
      yPos += 6;
      yPos += addText(`✓ Follow-up Scheduled - ${decision.followUpDate}`, margin, yPos);
    }

    // Footer on all pages
    const totalPages = (doc as any).internal?.getNumberOfPages() || 1;
    for (let i = 1; i <= totalPages; i++) {
      doc.setPage(i);
      doc.setFontSize(8);
      doc.setTextColor(100, 100, 100);
      doc.text(`Page ${i} of ${totalPages}`, pageWidth / 2, pageHeight - 10, { align: 'center' });
      doc.text('TwinCare - Digital Twin Healthcare Intelligence', margin, pageHeight - 10);
      doc.text(new Date().toLocaleDateString(), pageWidth - margin, pageHeight - 10, { align: 'right' });
    }

    // Download the PDF
    const fileName = `Visit_Report_${patient.name.replace(/\s+/g, '_')}_${new Date().toISOString().split('T')[0]}.pdf`;
    doc.save(fileName);
  };

  const steps = [
    { number: 1, label: 'Patient State', description: 'Review data' },
    { number: 2, label: 'Assessment', description: 'AI analysis' },
    { number: 3, label: 'Decision', description: 'Clinical judgment' },
    { number: 4, label: 'Finalized', description: 'Documented' }
  ];

  return (
    <div>
      {/* Visit Trigger / Intent */}
      {visitTrigger && (
        <div className="bg-gray-50 border border-gray-200 rounded-xl p-4 mb-6 flex items-center justify-between shadow-sm">
          <div className="flex items-center gap-3">
            <div className="text-xs text-gray-500 font-medium uppercase tracking-wide">Visit Trigger</div>
            <div className="flex items-center gap-2">
              <span className="px-3 py-1.5 bg-blue-100 text-blue-800 text-sm font-medium rounded-lg">
                {visitTrigger.type}
              </span>
              <span className="text-xs text-gray-500">•</span>
              <span className="text-xs text-gray-600">
                Source: <span className="font-medium">{visitTrigger.source}</span>
              </span>
              <span className="text-xs text-gray-500">•</span>
              <span className="text-xs text-gray-600">{visitTrigger.timestamp}</span>
            </div>
          </div>
        </div>
      )}

      {/* Progress Indicator: current step shows number in circle; completed show checkmark; "Step X of 4" kept */}
      <div className="bg-white rounded-xl border border-gray-200 shadow-sm p-6 md:p-8 mb-6">
        <div className="flex items-center justify-between mb-6">
          <div>
            <h3 className="font-semibold text-gray-900 mb-1">Clinical Workflow Progress</h3>
            <p className="text-sm text-gray-600">Step {currentStep} of 4</p>
          </div>
          <div>
            {flowStatus === 'not-started' && (
              <span className="px-3 py-1 bg-gray-100 text-gray-700 text-sm font-medium rounded-full">
                Not Started
              </span>
            )}
            {flowStatus === 'in-progress' && (
              <span className="px-3 py-1 bg-blue-100 text-blue-700 text-sm font-medium rounded-full flex items-center gap-1.5">
                <div className="w-2 h-2 bg-blue-500 rounded-full animate-pulse"></div>
                In Progress
              </span>
            )}
            {flowStatus === 'completed' && (
              <span className="px-3 py-1 bg-green-100 text-green-700 text-sm font-medium rounded-full flex items-center gap-1.5">
                <CheckCircle className="w-3.5 h-3.5" />
                Completed
              </span>
            )}
          </div>
        </div>

        {/* Step indicators: completed = checkmark; current = step number in circle; upcoming = gray circle */}
        <div className="flex items-center justify-between gap-2">
          {steps.map((step, idx) => (
            <div key={step.number} className="flex items-center flex-1">
              <div className="flex flex-col items-center">
                <div className={`w-10 h-10 rounded-full flex items-center justify-center mb-2 ${
                  currentStep > step.number ? 'bg-green-500' :
                  currentStep === step.number ? 'bg-blue-500' :
                  'bg-gray-200'
                }`}>
                  {currentStep > step.number ? (
                    <CheckCircle className="w-5 h-5 text-white" />
                  ) : currentStep === step.number ? (
                    <span className="text-sm font-medium text-white">{step.number}</span>
                  ) : (
                    <div className="w-2.5 h-2.5 bg-gray-400 rounded-full" aria-hidden />
                  )}
                </div>
                <div className={`text-xs text-center max-w-[120px] ${
                  currentStep === step.number ? 'font-medium text-gray-900' : 'text-gray-600'
                }`}>
                  <div>{step.label}</div>
                  <div className="text-gray-500 mt-0.5">{step.description}</div>
                </div>
              </div>
              {idx < steps.length - 1 && (
                <div className={`flex-1 h-0.5 mx-2 ${
                  currentStep > step.number ? 'bg-green-500' : 'bg-gray-200'
                }`}></div>
              )}
            </div>
          ))}
        </div>
      </div>

      {/* Step Content */}
      <div className="bg-white rounded-xl border border-gray-200 shadow-sm overflow-hidden">
        {/* Patient State */}
        {currentStep === 1 && (
          <div className="p-6 md:p-8">
            <div className="mb-8 pb-5 border-b border-gray-100">
              <h3 className="text-lg font-semibold text-gray-900 tracking-tight">Patient State</h3>
              <p className="text-sm text-gray-500 mt-2">Snapshot of current problems, medications, and latest vitals.</p>
            </div>
            
            <div className="space-y-5 mb-6">
              <div className="p-6 bg-gray-50/80 rounded-xl border border-gray-100">
                <div className="text-sm font-medium text-gray-700 mb-2">Key Clinical Indicators</div>
                <div className="grid grid-cols-2 gap-3">
                  <div className="text-sm">
                    <span className="text-gray-500">Conditions:</span>
                    <span className="ml-2 text-gray-900">{patient.conditions.length} active</span>
                  </div>
                  <div className="text-sm">
                    <span className="text-gray-500">Medications:</span>
                    <span className="ml-2 text-gray-900">{patient.medications.length} current</span>
                  </div>
                  {patient.vitals && (
                    <>
                      <div className="text-sm">
                        <span className="text-gray-500">BP:</span>
                        <span className="ml-2 text-gray-900">{patient.vitals.bloodPressure}</span>
                      </div>
                      <div className="text-sm">
                        <span className="text-gray-500">HR:</span>
                        <span className="ml-2 text-gray-900">{patient.vitals.heartRate}</span>
                      </div>
                    </>
                  )}
                </div>
              </div>

              <div className="p-6 bg-blue-50/90 border border-blue-100 rounded-xl">
                <div className="text-sm text-blue-900">
                  <div className="font-medium mb-2">Ready to proceed</div>
                  <div className="text-blue-800/90">Patient data is current and complete. You may proceed to AI analysis.</div>
                </div>
              </div>
            </div>

            {error && (
              <div className="mb-5 p-5 bg-red-50 border border-red-200 rounded-xl">
                <div className="text-sm text-red-900">
                  <div className="font-medium mb-1">Error</div>
                  <div className="text-red-800">{error}</div>
                </div>
              </div>
            )}

            <button
              onClick={handleRunAnalysis}
              disabled={loadingData}
              className="w-full px-6 py-3.5 bg-blue-600 text-white font-medium rounded-xl hover:bg-blue-700 active:scale-[0.99] transition-all flex items-center justify-center gap-2 disabled:bg-gray-400 disabled:cursor-not-allowed shadow-md shadow-blue-600/20"
            >
              {loadingData ? (
                <>
                  <Brain className="w-5 h-5 animate-pulse" />
                  Fetching Data...
                </>
              ) : (
                <>
                  <Brain className="w-5 h-5" />
                  Generate AI Assessment
                  <ArrowRight className="w-5 h-5" />
                </>
              )}
            </button>
          </div>
        )}

        {/* Data Fetched */}
        {currentStep === 2 && !aiRecommendation && (
          <div className="p-6 md:p-8">
            <div className="mb-8 pb-5 border-b border-gray-100">
              <div className="flex items-center gap-3 flex-wrap">
                <h3 className="text-lg font-semibold text-gray-900 tracking-tight">Data Fetched</h3>
                <span className="px-3 py-1 bg-emerald-100 text-emerald-700 text-xs font-medium rounded-full">
                  Ready
                </span>
              </div>
              <p className="text-sm text-gray-500 mt-2">Review the summary below and proceed to generate AI recommendations.</p>
            </div>

            {dataFetchSummary && (
              <div className="space-y-5 mb-6">
                {assessmentInputData?.patient_snapshot && (
                  <div className="p-6 bg-gray-50/80 rounded-xl border border-gray-100">
                    <div className="text-sm font-medium text-gray-700 mb-2">Patient Snapshot</div>
                    <div className="grid grid-cols-2 gap-3 text-sm">
                      <div>
                        <span className="text-gray-500">Conditions:</span>
                        <span className="ml-2 text-gray-900">{assessmentInputData.patient_snapshot.current_conditions?.length || 0}</span>
                      </div>
                      <div>
                        <span className="text-gray-500">Medications:</span>
                        <span className="ml-2 text-gray-900">{assessmentInputData.patient_snapshot.current_medications?.length || 0}</span>
                      </div>
                      {assessmentInputData.patient_snapshot.latest_vitals && (
                        <>
                          {assessmentInputData.patient_snapshot.latest_vitals.bloodPressure && (
                            <div>
                              <span className="text-gray-500">BP:</span>
                              <span className="ml-2 text-gray-900">{assessmentInputData.patient_snapshot.latest_vitals.bloodPressure}</span>
                            </div>
                          )}
                          {assessmentInputData.patient_snapshot.latest_vitals.heartRate && (
                            <div>
                              <span className="text-gray-500">HR:</span>
                              <span className="ml-2 text-gray-900">{assessmentInputData.patient_snapshot.latest_vitals.heartRate}</span>
                            </div>
                          )}
                        </>
                      )}
                    </div>
                  </div>
                )}

                {/* Risk Factors */}
                {(() => {
                  const risks = (openRisks && openRisks.length > 0 ? openRisks : assessmentInputData?.risk_factor) || [];
                  if (risks.length === 0) return null;
                  const timeSensitive = risks.filter((r: any) => (r.risk_factor_type || r.type) === 'TIME_SENSITIVE');
                  const timeInsensitive = risks.filter((r: any) => (r.risk_factor_type || r.type) === 'TIME_INSENSITIVE');
                  const other = risks.filter((r: any) => !['TIME_SENSITIVE', 'TIME_INSENSITIVE'].includes(r.risk_factor_type || r.type));
                  return (
                    <div className="rounded-xl border border-amber-100 bg-gradient-to-br from-amber-50/90 to-orange-50/60 overflow-hidden">
                      <div className="px-5 py-4 border-b border-amber-100/80 flex items-center gap-3">
                        <div className="p-2 rounded-lg bg-amber-100/80">
                          <ShieldAlert className="w-5 h-5 text-amber-700" />
                        </div>
                        <div>
                          <h4 className="text-sm font-semibold text-gray-900">Clinical Watchlist Indicators</h4>
                          <p className="text-xs text-gray-500">
                            {risks.length} active indicator{risks.length !== 1 ? 's' : ''}
                            {timeSensitive.length > 0 && ` · ${timeSensitive.length} care gaps`}
                          </p>
                        </div>
                      </div>
                      <div className="p-4 space-y-4">
                        {timeSensitive.length > 0 && (
                          <div className="border border-amber-200/60 rounded-lg overflow-hidden bg-white/50">
                            <button
                              type="button"
                              onClick={() => setRiskTimeSensitiveOpen(prev => !prev)}
                              className="w-full flex items-center gap-2 py-2.5 px-3 text-left hover:bg-amber-50/80 transition-colors"
                            >
                              <Clock className="w-4 h-4 text-amber-600 flex-shrink-0" />
                              <span className="text-xs font-medium uppercase tracking-wide text-amber-700">Care Gaps</span>
                              <span className="text-xs text-amber-600 ml-1">({timeSensitive.length})</span>
                              {riskTimeSensitiveOpen ? <ChevronUp className="w-4 h-4 text-amber-600 ml-auto" /> : <ChevronDown className="w-4 h-4 text-amber-600 ml-auto" />}
                            </button>
                            {riskTimeSensitiveOpen && (
                              <div className="grid gap-2 px-3 pb-3 pt-0">
                                {timeSensitive.map((risk: any, idx: number) => (
                                  <div
                                    key={risk.risk_factor_id || idx}
                                    className="flex items-center justify-between gap-3 py-2.5 px-3 rounded-lg bg-white/80 border border-amber-200/60 shadow-sm"
                                  >
                                    <span className="text-sm font-medium text-gray-900">
                                      {risk.description || '—'}
                                    </span>
                                    {risk.overdue_days != null && (
                                      <span className="text-xs font-medium text-amber-800 bg-amber-100 px-2 py-0.5 rounded flex-shrink-0">
                                        {risk.overdue_days}d overdue
                                      </span>
                                    )}
                                  </div>
                                ))}
                              </div>
                            )}
                          </div>
                        )}
                        {timeInsensitive.length > 0 && (
                          <div className="border border-gray-200 rounded-lg overflow-hidden bg-white/50">
                            <button
                              type="button"
                              onClick={() => setRiskTimeInsensitiveOpen(prev => !prev)}
                              className="w-full flex items-center gap-2 py-2.5 px-3 text-left hover:bg-gray-50 transition-colors"
                            >
                              <ShieldAlert className="w-4 h-4 text-gray-500 flex-shrink-0" />
                              <span className="text-xs font-medium uppercase tracking-wide text-gray-600">Baseline Indicators</span>
                              <span className="text-xs text-gray-500 ml-1">({timeInsensitive.length})</span>
                              {riskTimeInsensitiveOpen ? <ChevronUp className="w-4 h-4 text-gray-500 ml-auto" /> : <ChevronDown className="w-4 h-4 text-gray-500 ml-auto" />}
                            </button>
                            {riskTimeInsensitiveOpen && (
                              <div className="grid gap-2 px-3 pb-3 pt-0">
                                {timeInsensitive.map((risk: any, idx: number) => (
                                  <div
                                    key={risk.risk_factor_id || idx}
                                    className="flex items-center justify-between gap-3 py-2.5 px-3 rounded-lg bg-white/70 border border-gray-200 shadow-sm"
                                  >
                                    <span className="text-sm font-medium text-gray-800">
                                      {risk.description || '—'}
                                    </span>
                                  </div>
                                ))}
                              </div>
                            )}
                          </div>
                        )}
                        {other.length > 0 && (
                          <div className="grid gap-2">
                            {other.map((risk: any, idx: number) => (
                              <div
                                key={risk.risk_factor_id || idx}
                                className="flex items-center justify-between gap-3 py-2.5 px-3 rounded-lg bg-white/70 border border-gray-200 shadow-sm"
                              >
                                <span className="text-sm font-medium text-gray-800">
                                  {risk.description || '—'}
                                </span>
                              </div>
                            ))}
                          </div>
                        )}
                      </div>
                    </div>
                  );
                })()}

                {/* Current Summary Text */}
                {summaryText && (
                  <div className="p-6 bg-blue-50/90 border border-blue-100 rounded-xl">
                    <div className="text-sm font-medium text-gray-700 mb-3">Current Clinical Summary</div>
                    <div className="text-sm text-gray-700 max-h-60 overflow-y-auto break-words min-w-0">
                      <MarkdownText>{summaryText}</MarkdownText>
                    </div>
                  </div>
                )}
              </div>
            )}

            {error && (
              <div className="mb-5 p-5 bg-red-50 border border-red-200 rounded-xl">
                <div className="text-sm text-red-900">
                  <div className="font-medium mb-1">Error</div>
                  <div className="text-red-800">{error}</div>
                </div>
              </div>
            )}

            <button
              onClick={handleReviewAI}
              disabled={loadingAI || !assessmentInputData}
              className="w-full px-6 py-3.5 bg-blue-600 text-white font-medium rounded-xl hover:bg-blue-700 active:scale-[0.99] transition-all flex items-center justify-center gap-2 disabled:bg-gray-400 disabled:cursor-not-allowed shadow-md shadow-blue-600/20"
            >
              {loadingAI ? (
                <>
                  <Brain className="w-5 h-5 animate-pulse" />
                  Generating AI Recommendations...
                </>
              ) : (
                <>
                  <Brain className="w-5 h-5" />
                  Generate AI Recommendations
                  <ArrowRight className="w-5 h-5" />
                </>
              )}
            </button>
          </div>
        )}

        {/* AI Clinical Assessment (Results) */}
        {currentStep === 2 && aiRecommendation && (
          <div className="p-6 md:p-8">
            <div className="mb-8 pb-5 border-b border-gray-100">
              <div className="flex items-center gap-3 flex-wrap">
                <h3 className="text-lg font-semibold text-gray-900 tracking-tight">AI Clinical Assessment</h3>
                <span className="px-3 py-1 bg-purple-100 text-purple-700 text-xs font-medium rounded-full">
                  Assistive
                </span>
              </div>
              <p className="text-sm text-gray-500 mt-2">Review the AI-generated assessment and supporting evidence before making your decision.</p>
            </div>

            <div className="space-y-5 mb-6">
              <div className="p-6 bg-purple-50/90 border border-purple-100 rounded-xl">
                <div className="text-sm font-medium text-gray-700 mb-4">AI Assessment</div>
                <RiskBadge tier={aiRecommendation.riskTier} size="lg" />
              </div>

              <div className="p-6 bg-gray-50/80 rounded-xl border border-gray-100">
                <div className="text-sm font-medium text-gray-700 mb-3">Clinical Reasoning</div>
                <ul className="space-y-2">
                  {aiRecommendation.reasoning.map((reason: string, idx: number) => (
                    <li key={idx} className="flex items-start gap-2 text-sm text-gray-700">
                      <div className="w-1.5 h-1.5 bg-purple-500 rounded-full mt-1.5 flex-shrink-0"></div>
                      <MarkdownText className="flex-1">{reason}</MarkdownText>
                    </li>
                  ))}
                </ul>
              </div>

              <div className="p-6 bg-blue-50/90 border border-blue-100 rounded-xl">
                <div className="text-sm text-blue-900">
                  <div className="font-medium mb-2">AI model: ClinicalAI v3.2.1</div>
                  <div className="text-blue-800/90">Analysis timestamp: {new Date().toLocaleString()}</div>
                  {aiRecommendation?.confidence && (
                    <div className="text-blue-800/90 mt-1">Confidence: {aiRecommendation.confidence}</div>
                  )}
                </div>
              </div>
            </div>

            {error && (
              <div className="mb-5 p-5 bg-red-50 border border-red-200 rounded-xl">
                <div className="text-sm text-red-900">
                  <div className="font-medium mb-1">Error</div>
                  <div className="text-red-800">{error}</div>
                </div>
              </div>
            )}

            <button
              onClick={handleReviewAI}
              disabled={loadingAI}
              className="w-full px-6 py-3.5 bg-blue-600 text-white font-medium rounded-xl hover:bg-blue-700 active:scale-[0.99] transition-all flex items-center justify-center gap-2 disabled:bg-gray-400 disabled:cursor-not-allowed shadow-md shadow-blue-600/20"
            >
              {loadingAI ? (
                <>
                  <Brain className="w-5 h-5 animate-pulse" />
                  Generating AI Recommendations...
                </>
              ) : (
                <>
                  Proceed to Clinical Review
                  <ArrowRight className="w-5 h-5" />
                </>
              )}
            </button>
          </div>
        )}

        {/* Clinical Decision */}
        {currentStep === 3 && (
          <div className="p-6 md:p-8">
            <div className="mb-8 pb-5 border-b border-gray-100">
              <h3 className="text-lg font-semibold text-gray-900 tracking-tight">Clinical Decision</h3>
              <p className="text-sm text-gray-500 mt-2">Record your clinical judgment and reasoning. This becomes the authoritative visit record.</p>
            </div>

            <div className="space-y-8">
              {/* AI Proposed Plan */}
              <div className="p-6 md:p-7 bg-purple-50/90 border border-purple-100 rounded-xl">
                <div className="mb-4">
                  <h4 className="text-sm font-medium text-gray-700">AI Recommendations</h4>
                  <p className="text-xs text-gray-500 mt-1.5">Review and adjust based on your clinical judgment</p>
                </div>
                <div className="mt-5 p-4 bg-white/70 border border-purple-200 rounded-lg">
                  <p className="text-xs text-purple-800 font-medium flex items-center gap-2">
                    <AlertCircle className="w-3.5 h-3.5 flex-shrink-0" />
                    <span>These recommendations are assistive; clinician review is required.</span>
                  </p>
                </div>

                {/* Key Findings - At the top of AI Recommendations */}
                {aiRecommendation?.reasoningReferences && aiRecommendation.reasoningReferences.length > 0 && (
                  <div className="mb-5 mt-8">
                    <div className="p-6 bg-gray-50/80 border border-gray-100 rounded-xl">
                      <div className="text-sm font-medium text-gray-700 mb-3">Key Findings</div>
                      <p className="text-xs text-gray-600 mb-4">Hover over findings to see source details. Click to open the referenced data.</p>
                      <div className="flex flex-wrap gap-3">
                        {aiRecommendation.reasoningReferences.map((ref: any, idx: number) => (
                          <span 
                            key={idx}
                            className="px-3 py-2 bg-purple-100 text-purple-700 text-xs font-semibold rounded-lg border border-purple-200 cursor-help hover:bg-purple-200 transition-colors shadow-sm" 
                            title={`Source: ${ref.source || ref.type || 'Unknown'} • Type: ${ref.type || 'Unknown'}`}
                          >
                            {ref.label || ref.type || 'Evidence'}
                          </span>
                        ))}
                      </div>
                    </div>
                  </div>
                )}

                {/* Differential Diagnosis — sorted by priority (High → Medium → Low) */}
                {aiRecommendation?.differentialDiagnosis && aiRecommendation.differentialDiagnosis.length > 0 && (
                  <div className="mb-6 mt-6">
                    <div className="flex items-center gap-3 mb-5">
                      <div className="h-px flex-1 bg-gradient-to-r from-transparent via-purple-300 to-transparent"></div>
                      <div className="flex items-center gap-2">
                        <div className="w-2 h-2 bg-purple-600 rounded-full"></div>
                        <h5 className="text-base font-bold text-gray-900 px-2">Differential Diagnosis</h5>
                        <div className="w-2 h-2 bg-purple-600 rounded-full"></div>
                      </div>
                      <div className="h-px flex-1 bg-gradient-to-r from-transparent via-purple-300 to-transparent"></div>
                    </div>
                    <div className="grid grid-cols-1 gap-4">
                      {[...aiRecommendation.differentialDiagnosis]
                        .sort((a, b) => {
                          const order = (d: any) => {
                            const bin = (d.probabilityBin ?? d.probability_bin ?? '').toString().toLowerCase();
                            if (bin === 'high') return 0;
                            if (bin === 'medium') return 1;
                            return 2; // low or unknown
                          };
                          return order(a) - order(b);
                        })
                        .map((diagnosis, idx) => {
                        // Handle both camelCase and snake_case from API
                        const diagnosisName = diagnosis.diagnosisName || (diagnosis as any).diagnosis_name || 'Diagnosis';
                        const diagnosisCode = (diagnosis as any).diagnosis_code || '';
                        const standardDiagnosisName = (diagnosis as any).Standard_diagnosis_name || (diagnosis as any).standard_diagnosis_name || '';
                        const probabilityBin = diagnosis.probabilityBin || (diagnosis as any).probability_bin || 'Low';
                        const confidenceScore = (diagnosis as any).confidence_score || diagnosis.confidenceScore;
                        const reasoning = diagnosis.reasoning || '';
                        const supportingEvidence = diagnosis.supportingEvidence || (diagnosis as any).supporting_evidence || [];
                        const clinicalEvidenceSummary = (diagnosis as any).rag_results || (diagnosis as any).ragResults || '';
                        const SUMMARY_PREVIEW_LENGTH = 640;
                        const summaryPreview = clinicalEvidenceSummary.length > SUMMARY_PREVIEW_LENGTH
                          ? clinicalEvidenceSummary.slice(0, SUMMARY_PREVIEW_LENGTH).trim() + '…'
                          : clinicalEvidenceSummary;
                        
                        const isExpanded = expandedDiagnosis.has(idx);
                        return (
                        <div key={idx} className="bg-white border-2 border-gray-200 rounded-xl shadow-md hover:shadow-lg hover:border-purple-300 transition-all duration-200">
                          {/* Diagnosis Name Header - Clickable */}
                          <button
                            onClick={() => toggleDiagnosis(idx)}
                            className="w-full flex items-start justify-between p-5 hover:bg-gray-50/50 transition-colors rounded-t-xl"
                          >
                            <div className="flex-1 pr-4 text-left">
                              <div className="flex items-start gap-3">
                                <div className={`w-2.5 h-2.5 rounded-full mt-1.5 flex-shrink-0 ${
                                  probabilityBin === 'High' ? 'bg-red-500' :
                                  probabilityBin === 'Medium' ? 'bg-yellow-500' :
                                  'bg-blue-500'
                                }`}></div>
                                <div className="flex-1 min-w-0">
                                  <h6 className="text-lg font-bold text-gray-900 leading-tight mb-1">
                                    {diagnosisName}
                                  </h6>
                                  {standardDiagnosisName && (
                                    <div className="text-sm text-gray-600 mt-1 italic">
                                      {standardDiagnosisName}
                                    </div>
                                  )}
                                  {diagnosisCode && (
                                    <div className="text-xs text-gray-500 mt-1.5 font-mono">
                                      Standard Diagnosis Code: {diagnosisCode}
                                    </div>
                                  )}
                                </div>
                              </div>
                            </div>
                            <div className="flex flex-col items-end gap-2 flex-shrink-0 ml-3">
                              <div className="flex items-center gap-2">
                                <span className={`px-3 py-1.5 text-xs font-bold rounded-lg whitespace-nowrap shadow-sm ${
                                  probabilityBin === 'High' ? 'bg-red-100 text-red-800 border border-red-300' :
                                  probabilityBin === 'Medium' ? 'bg-yellow-100 text-yellow-800 border border-yellow-300' :
                                  'bg-blue-100 text-blue-800 border border-blue-300'
                                }`}>
                                  {probabilityBin === 'High' ? 'High Confidence' :
                                   probabilityBin === 'Medium' ? 'Moderate Confidence' :
                                   'Low Confidence'}
                                </span>
                                {isExpanded ? (
                                  <ChevronUp className="w-4 h-4 text-gray-500 flex-shrink-0" />
                                ) : (
                                  <ChevronDown className="w-4 h-4 text-gray-500 flex-shrink-0" />
                                )}
                              </div>
                              {confidenceScore !== undefined && confidenceScore !== null && (
                                <span className="text-xs text-gray-600 font-semibold">
                                  {(typeof confidenceScore === 'number' ? (confidenceScore * 100).toFixed(0) : confidenceScore)}%
                                </span>
                              )}
                            </div>
                          </button>

                          {/* Expandable Content — Clinical Reasoning, Supporting Evidence, Evidence-Based Summary (rag_results) */}
                          {isExpanded && (
                            <div className="px-5 pb-5 border-t border-gray-100">
                              {/* Clinical Reasoning — support [1], [2] citations when diagnosis has references */}
                              {reasoning && (
                                <div className="mt-5 mb-5">
                                  <div className="flex items-center gap-2 mb-3">
                                    <div className="w-1.5 h-1.5 bg-purple-600 rounded-full"></div>
                                    <div className="text-xs font-bold text-purple-700 uppercase tracking-wider">Clinical Reasoning</div>
                                  </div>
                                  <div className="bg-gradient-to-br from-purple-50 to-indigo-50 rounded-lg p-4 border border-purple-100">
                                    <div className="text-sm text-gray-800 leading-relaxed">
                                      {((diagnosis as any).references?.length > 0)
                                        ? <RagResultsWithCitations text={reasoning} references={(diagnosis as any).references} className="leading-relaxed" compact />
                                        : <MarkdownText>{reasoning}</MarkdownText>}
                                    </div>
                                  </div>
                                </div>
                              )}
                              
                              {/* Supporting Evidence */}
                              {supportingEvidence && supportingEvidence.length > 0 && (
                                <div className="pt-4 border-t border-gray-100">
                                  <div className="flex items-center gap-2 mb-3">
                                    <div className="w-1.5 h-1.5 bg-indigo-600 rounded-full"></div>
                                    <div className="text-xs font-bold text-indigo-700 uppercase tracking-wider">Supporting Evidence</div>
                                  </div>
                                  <ul className="space-y-2">
                                    {supportingEvidence.map((evidence: string, evIdx: number) => (
                                      <li key={evIdx} className="flex items-start gap-2.5 text-sm text-gray-700">
                                        <span className="text-indigo-600 font-bold mt-0.5 flex-shrink-0">•</span>
                                        <div className="flex-1 leading-relaxed min-w-0">
                                          <MarkdownText>{evidence}</MarkdownText>
                                        </div>
                                      </li>
                                    ))}
                                  </ul>
                                </div>
                              )}

                              {/* Evidence-Based Summary (rag_results) — only in expanded mode */}
                              {clinicalEvidenceSummary && (
                                <div className="pt-4 mt-4 border-t border-gray-100">
                                  <div className="flex items-center gap-2 mb-3 min-w-0">
                                    <div className="w-1.5 h-1.5 rounded-full bg-emerald-500 flex-shrink-0 shadow-sm" />
                                    <div className="text-xs font-bold text-emerald-700 uppercase tracking-wider min-w-0 break-words">Evidence-Based Summary</div>
                                  </div>
                                  <div className="rounded-xl p-4 bg-gradient-to-br from-emerald-50/90 to-teal-50/70 border border-emerald-100/80 shadow-sm">
                                    <div className="text-sm text-gray-700 leading-relaxed">
                                      <RagResultsWithCitations text={summaryPreview} references={(diagnosis as any).references} className="leading-relaxed" compact />
                                    </div>
                                    {clinicalEvidenceSummary.length > SUMMARY_PREVIEW_LENGTH && (
                                      <button
                                        type="button"
                                        onClick={(e) => {
                                          e.stopPropagation();
                                          const refs = (diagnosis as any).references ?? [];
                                          setEvidenceSummaryModal({ title: `${(diagnosisName || '').replace(/\*\*/g, '').trim()} — Evidence-Based Summary`, content: clinicalEvidenceSummary, references: refs });
                                        }}
                                        className="mt-3 inline-flex items-center gap-2 px-3.5 py-2 text-sm font-semibold text-emerald-700 bg-emerald-100/90 hover:bg-emerald-200/90 border border-emerald-200/80 rounded-xl transition-colors shadow-sm hover:shadow"
                                      >
                                        <FileText className="w-4 h-4" />
                                        View full summary
                                      </button>
                                    )}
                                  </div>
                                </div>
                              )}
                            </div>
                          )}
                        </div>
                        );
                      })}
                    </div>
                  </div>
                )}

                {/* Medications */}
                <div className="mb-6 mt-4">
                  <div className="flex items-center gap-2 mb-4">
                    <div className="h-px flex-1 bg-gradient-to-r from-transparent via-gray-300 to-transparent"></div>
                    <h5 className="text-sm font-bold text-gray-900 px-3">Medications</h5>
                    <div className="h-px flex-1 bg-gradient-to-r from-transparent via-gray-300 to-transparent"></div>
                  </div>
                  <p className="text-xs text-gray-500 mb-4 flex items-center gap-1.5 justify-center">
                    <AlertCircle className="w-3.5 h-3.5 text-gray-400" />
                    <span>Hover over evidence badges to view source details</span>
                  </p>
                  {medications.length === 0 ? (
                    <div className="p-6 bg-white/80 border-2 border-dashed border-gray-300 rounded-xl text-center">
                      <div className="text-sm text-gray-500 mb-1">No medication recommendations from AI</div>
                    </div>
                  ) : (
                    <div className="space-y-4">
                      {medications.map((med) => (
                      <div key={med.id} className="bg-white border-2 rounded-xl p-5 shadow-md mr-4 transition-all duration-200 border-gray-200 hover:border-gray-300 hover:shadow-lg">
                            <button
                              onClick={() => toggleMedication(med.id)}
                              className="w-full flex items-start justify-between mb-3 hover:bg-gray-50 p-2 -m-2 rounded transition-colors"
                            >
                              <div className="flex-1 pr-4 text-left">
                                <div className="flex items-center gap-3 mb-2 flex-wrap">
                                  <div className="font-bold text-base text-gray-900">
                                    {med.medication}
                                  </div>
                                  {(med as any).medicationCode && (
                                    <>
                                      <span className="text-gray-400">•</span>
                                      <div className="text-xs text-gray-500 font-mono">
                                        RxNorm Code: {(med as any).medicationCode}
                                      </div>
                                    </>
                                  )}
                                  <span className="text-gray-400">•</span>
                                  <div className="text-sm text-gray-700 font-medium">
                                    {med.dose} {med.frequency}
                                  </div>
                                  {med.duration && (
                                    <>
                                      <span className="text-gray-400">•</span>
                                      <div className="text-xs text-gray-500">({med.duration})</div>
                                    </>
                                  )}
                                  {(med as any).priority && (
                                    <>
                                      <span className="text-gray-400">•</span>
                                      <span className={`px-2 py-0.5 text-xs font-bold rounded ${
                                        (med as any).priority === 'High' ? 'bg-red-100 text-red-800' :
                                        (med as any).priority === 'Medium' ? 'bg-yellow-100 text-yellow-800' :
                                        'bg-blue-100 text-blue-800'
                                      }`}>
                                        {(med as any).priority} Priority
                                      </span>
                                    </>
                                  )}
                                </div>
                                {!expandedMedications.has(med.id) && (
                                  <div className="text-sm text-gray-700 leading-relaxed">
                                    <span className="font-semibold text-gray-900">Rationale:</span> {med.rationale.length > 100 ? med.rationale.substring(0, 100) + '...' : med.rationale}
                                  </div>
                                )}
                              </div>
                              <div className="flex flex-col items-end gap-2 ml-3 flex-shrink-0">
                                <div className="flex items-center gap-2">
                                  <span
                                    className={`px-3 py-1.5 text-xs font-bold rounded-lg shadow-sm ${getStatusBadgeClass(med.status)}`}
                                    title={`Status: ${med.status}`}
                                  >
                                    {med.status}
                                  </span>
                                  {expandedMedications.has(med.id) ? (
                                    <ChevronUp className="w-4 h-4 text-gray-500" />
                                  ) : (
                                    <ChevronDown className="w-4 h-4 text-gray-500" />
                                  )}
                                </div>
                              </div>
                            </button>
                            {expandedMedications.has(med.id) && (
                              <div className="mt-2">
                                <div className="text-sm text-gray-700 mb-3 leading-relaxed">
                                  <span className="font-semibold text-gray-900">Rationale:</span> {med.rationale}
                                </div>
                                {(med as any).contraindications && (med as any).contraindications.length > 0 && (
                                  <div className="mb-3">
                                    <div className="text-xs font-semibold text-red-700 mb-1">Contraindications:</div>
                                    <div className="flex flex-wrap gap-2">
                                      {(med as any).contraindications.map((contra: string, idx: number) => (
                                        <span key={idx} className="px-2 py-1 bg-red-50 text-red-700 text-xs font-medium rounded border border-red-200">
                                          {contra}
                                        </span>
                                      ))}
                                    </div>
                                  </div>
                                )}
                                {(med as any).monitoringRequired && (med as any).monitoringRequired.length > 0 && (
                                  <div className="mb-3">
                                    <div className="text-xs font-semibold text-blue-700 mb-1">Monitoring Required:</div>
                                    <div className="flex flex-wrap gap-2">
                                      {(med as any).monitoringRequired.map((monitor: string, idx: number) => (
                                        <span key={idx} className="px-2 py-1 bg-blue-50 text-blue-700 text-xs font-medium rounded border border-blue-200">
                                          {monitor}
                                        </span>
                                      ))}
                                    </div>
                                  </div>
                                )}
                                <div className="flex flex-wrap gap-2 mb-3">
                                  {med.evidence.map((ev, idx) => (
                                    <span
                                      key={idx}
                                      className="px-2.5 py-1 bg-purple-100 text-purple-700 text-xs font-medium rounded-md border border-purple-200 cursor-help hover:bg-purple-200 transition-colors shadow-sm"
                                      title={`Source: ${ev.includes('BP') || ev.includes('HR') ? 'Vitals' : ev.includes('mg/dL') ? 'Labs' : 'Medication'} • ${ev.includes('Jan') ? 'Manual Visit' : 'Background Monitoring'} • ${ev.match(/\(([^)]+)\)/)?.[1] || 'Active'}`}
                                    >
                                      {ev}
                                    </span>
                                  ))}
                                </div>
                              </div>
                            )}
                      </div>
                      ))}
                    </div>
                  )}
                </div>

                {/* Drug Interactions — among recommended medications only */}
                {medications.length > 0 && (
                  <div className="mt-6">
                    <div className="rounded-xl border-2 border-amber-200/80 bg-gradient-to-br from-amber-50/90 to-orange-50/70 shadow-sm overflow-hidden">
                      <div className="flex items-center gap-2 px-5 py-4 border-b border-amber-200/60">
                        <AlertCircle className="w-5 h-5 text-amber-600 flex-shrink-0" />
                        <div>
                          <h5 className="text-sm font-bold text-amber-900">Drug Interactions</h5>
                          <p className="text-xs text-amber-800/90 mt-0.5">
                            Interactions among the {medications.length} recommended medication{medications.length !== 1 ? 's' : ''}
                          </p>
                        </div>
                      </div>
                      <div className="p-5">
                        {drugInteractionsSection === 'loading' && (
                          <div className="flex items-center justify-center gap-3 py-8 text-amber-800">
                            <span className="inline-block w-5 h-5 border-2 border-amber-500 border-t-transparent rounded-full animate-spin" aria-hidden />
                            <span className="text-sm font-medium">Checking interactions…</span>
                          </div>
                        )}
                        {drugInteractionsSection === 'idle' && null}
                        {drugInteractionsSection && typeof drugInteractionsSection === 'object' && 'error' in drugInteractionsSection && (
                          <p className="text-sm text-amber-800/80 py-2">Unable to load interaction data.</p>
                        )}
                        {drugInteractionsSection && typeof drugInteractionsSection === 'object' && 'pairs' in drugInteractionsSection && (() => {
                          const { pairs } = drugInteractionsSection;
                          if (pairs.length === 0) {
                            return (
                              <p className="text-sm text-amber-900/90 py-2">
                                No interactions found among the {medications.length} recommended medication{medications.length !== 1 ? 's' : ''}.
                              </p>
                            );
                          }
                          return (
                            <div className="space-y-3">
                              {pairs.map((p, idx) => (
                                <div
                                  key={idx}
                                  className="rounded-lg border border-amber-200 bg-white/90 p-4 shadow-sm"
                                >
                                  <div className="flex flex-wrap items-center gap-2">
                                    <span className="inline-flex items-center px-2.5 py-1.5 text-sm font-semibold rounded-lg bg-amber-100 text-amber-900 border border-amber-200">
                                      {p.drugA}
                                    </span>
                                    <span className="text-amber-600 font-medium">↔</span>
                                    <span className="inline-flex items-center px-2.5 py-1.5 text-sm font-semibold rounded-lg bg-amber-100 text-amber-900 border border-amber-200">
                                      {p.drugB}
                                    </span>
                                  </div>
                                  {p.interactionTexts.length > 0 && (
                                    <ul className="mt-3 space-y-1.5 text-xs text-gray-700 pl-1">
                                      {p.interactionTexts.slice(0, 3).map((text, i) => (
                                        <li key={i} className="flex gap-2">
                                          <span className="text-amber-500 mt-0.5">•</span>
                                          <span className="flex-1 leading-relaxed">{text.length > 220 ? text.slice(0, 220).trim() + '…' : text}</span>
                                        </li>
                                      ))}
                                      {p.interactionTexts.length > 3 && (
                                        <li className="text-amber-700 font-medium">+{p.interactionTexts.length - 3} more</li>
                                      )}
                                    </ul>
                                  )}
                                </div>
                              ))}
                            </div>
                          );
                        })()}
                      </div>
                    </div>
                  </div>
                )}

                {/* Procedures/Orders */}
                <div className="mt-6 mb-8">
                  <div className="p-6 bg-gradient-to-br from-gray-50 to-gray-100/50 border-2 border-gray-200 rounded-xl shadow-sm">
                    <div className="flex items-center gap-2 mb-4">
                      <div className="h-px flex-1 bg-gradient-to-r from-transparent via-gray-300 to-transparent"></div>
                      <h5 className="text-sm font-bold text-gray-900 px-3">Procedures</h5>
                      <div className="h-px flex-1 bg-gradient-to-r from-transparent via-gray-300 to-transparent"></div>
                    </div>
                    <p className="text-xs text-gray-500 mb-4 flex items-center gap-1.5 justify-center">
                      <AlertCircle className="w-3.5 h-3.5 text-gray-400" />
                      <span>Hover over evidence badges to view source details</span>
                    </p>
                    {procedures.length === 0 ? (
                      <div className="p-6 bg-white/80 border-2 border-dashed border-gray-300 rounded-xl text-center">
                        <div className="text-sm text-gray-500 mb-1">No procedure recommendations from AI</div>
                      </div>
                    ) : (
                    <div className="space-y-4">
                      {procedures.map((proc) => (
                      <div key={proc.id} className="bg-white border-2 rounded-xl p-5 shadow-md mr-4 transition-all duration-200 border-gray-200 hover:border-gray-300 hover:shadow-lg">
                            <button
                              onClick={() => toggleProcedure(proc.id)}
                              className="w-full flex items-start justify-between mb-3 hover:bg-gray-50 p-2 -m-2 rounded transition-colors"
                            >
                              <div className="flex-1 pr-4 text-left">
                                <div className="flex items-center gap-3 mb-2 flex-wrap">
                                  <div className="font-bold text-base text-gray-900">
                                    {proc.procedure}
                                  </div>
                                  {proc.cptCode && (
                                    <>
                                      <span className="text-gray-400">•</span>
                                      <div className="text-xs text-gray-500 font-mono">
                                        Procedure Code (CPT): {proc.cptCode}
                                      </div>
                                    </>
                                  )}
                                  <span className="text-gray-400">•</span>
                                  <div className="text-sm text-gray-700 font-medium">
                                    {proc.timing}
                                  </div>
                                  {(proc as any).priority && (
                                    <>
                                      <span className="text-gray-400">•</span>
                                      <span className={`px-2 py-0.5 text-xs font-bold rounded ${
                                        (proc as any).priority === 'High' ? 'bg-red-100 text-red-800' :
                                        (proc as any).priority === 'Medium' ? 'bg-yellow-100 text-yellow-800' :
                                        'bg-blue-100 text-blue-800'
                                      }`}>
                                        {(proc as any).priority} Priority
                                      </span>
                                    </>
                                  )}
                                </div>
                                {!expandedProcedures.has(proc.id) && (
                                  <div className="text-sm text-gray-700 leading-relaxed">
                                    <span className="font-semibold text-gray-900">Rationale:</span> {proc.rationale.length > 100 ? proc.rationale.substring(0, 100) + '...' : proc.rationale}
                                  </div>
                                )}
                              </div>
                              <div className="flex flex-col items-end gap-2 ml-3 flex-shrink-0">
                                <div className="flex items-center gap-2">
                                  <span
                                    className={`px-3 py-1.5 text-xs font-bold rounded-lg shadow-sm ${getStatusBadgeClass(proc.status)}`}
                                    title={`Status: ${proc.status}`}
                                  >
                                    {proc.status}
                                  </span>
                                  {expandedProcedures.has(proc.id) ? (
                                    <ChevronUp className="w-4 h-4 text-gray-500" />
                                  ) : (
                                    <ChevronDown className="w-4 h-4 text-gray-500" />
                                  )}
                                </div>
                              </div>
                            </button>
                            {expandedProcedures.has(proc.id) && (
                              <div className="mt-2">
                                <div className="text-sm text-gray-700 mb-3 leading-relaxed">
                                  <span className="font-semibold text-gray-900">Rationale:</span> {proc.rationale}
                                </div>
                                <div className="flex flex-wrap gap-2 mb-3">
                                  {proc.evidence.map((ev, idx) => (
                                    <span
                                      key={idx}
                                      className="px-2.5 py-1 bg-purple-100 text-purple-700 text-xs font-medium rounded-md border border-purple-200 cursor-help hover:bg-purple-200 transition-colors shadow-sm"
                                      title={`Source: ${ev.includes('BP') || ev.includes('HR') ? 'Vitals' : ev.includes('mg/dL') ? 'Labs' : ev.includes('dose') ? 'Medication' : 'Procedure'} • ${ev.includes('Jan') ? 'Manual Visit' : 'Background Monitoring'} • ${ev.match(/\(([^)]+)\)/)?.[1] || 'Active'}`}
                                    >
                                      {ev}
                                    </span>
                                  ))}
                                </div>
                              </div>
                            )}
                      </div>
                      ))}
                    </div>
                  )}
                  </div>
                </div>
              </div>

              {/* AI Context Panel */}
              <div className="grid grid-cols-1 lg:grid-cols-2 gap-4 mt-4 items-start">
                {/* Left: Risk Assessment */}
                <div className="space-y-3">

                  {aiRecommendation?.riskAssessment && (
                    <div className="bg-gradient-to-br from-amber-50 to-amber-100/50 border-2 border-amber-200 rounded-xl shadow-md overflow-hidden">
                      <button
                        onClick={() => setExpandedRiskAssessment(!expandedRiskAssessment)}
                        className="w-full flex items-center justify-between px-5 py-4 hover:bg-amber-100/50 transition-colors"
                      >
                        <div className="text-sm font-bold text-amber-900">Risk Assessment</div>
                        <div className="flex items-center gap-2">
                          {aiRecommendation.riskAssessment.overall_risk && (
                            <span className={`px-3 py-1.5 text-xs font-bold rounded-lg ${
                              aiRecommendation.riskAssessment.overall_risk === 'High' ? 'bg-red-100 text-red-800 border border-red-300' :
                              aiRecommendation.riskAssessment.overall_risk === 'Medium' ? 'bg-yellow-100 text-yellow-800 border border-yellow-300' :
                              'bg-blue-100 text-blue-800 border border-blue-300'
                            }`}>
                              Overall Risk: {aiRecommendation.riskAssessment.overall_risk}
                            </span>
                          )}
                          {expandedRiskAssessment ? (
                            <ChevronUp className="w-4 h-4 text-amber-700 flex-shrink-0" />
                          ) : (
                            <ChevronDown className="w-4 h-4 text-amber-700 flex-shrink-0" />
                          )}
                        </div>
                      </button>
                      {expandedRiskAssessment && (
                        <div className="px-5 pb-5 pt-1 border-t border-amber-200/50">
                          {aiRecommendation?.riskAssessment.risk_factors_identified && aiRecommendation.riskAssessment.risk_factors_identified.length > 0 && (
                            <div className="mt-5 mb-5">
                              <div className="text-xs text-amber-800 font-semibold mb-3 uppercase tracking-wide">Clinical Watchlist Indicators</div>
                              <div className="flex flex-wrap gap-3">
                                {aiRecommendation.riskAssessment.risk_factors_identified.map((factor: any, idx: number) => (
                                  <span 
                                    key={idx} 
                                    className="inline-flex items-center px-3 py-1.5 bg-amber-100 text-amber-900 text-xs font-medium rounded-md border border-amber-300"
                                  >
                                    {typeof factor === 'string' ? factor : factor.factor || 'Unknown risk factor'}
                                  </span>
                                ))}
                              </div>
                            </div>
                          )}
                          {aiRecommendation?.riskAssessment.mitigation_strategies && aiRecommendation.riskAssessment.mitigation_strategies.length > 0 && (
                            <div className="pt-4 border-t border-amber-200/50">
                              <div className="text-xs text-amber-800 font-semibold mb-3 uppercase tracking-wide">Mitigation Strategies</div>
                              <ul className="space-y-2 text-xs text-amber-800">
                                {aiRecommendation.riskAssessment.mitigation_strategies.map((strategy: string, idx: number) => (
                                  <li key={idx} className="flex items-start gap-2.5">
                                    <div className="w-1.5 h-1.5 bg-amber-600 rounded-full mt-1.5 flex-shrink-0"></div>
                                    <div className="flex-1 leading-relaxed">{strategy}</div>
                                  </li>
                                ))}
                              </ul>
                            </div>
                          )}
                        </div>
                      )}
                    </div>
                  )}
                </div>

                {/* Right: Additional Recommendations */}
                {aiRecommendation?.additionalRecommendations && aiRecommendation.additionalRecommendations.length > 0 && (
                  <div className="bg-gradient-to-br from-blue-50 via-blue-100/70 to-blue-50 border-2 border-blue-200 rounded-xl shadow-sm overflow-hidden">
                    <button
                      onClick={() => setExpandedAdditionalRecs(!expandedAdditionalRecs)}
                      className="w-full flex items-center justify-between px-5 py-4 hover:bg-blue-100/50 transition-colors"
                    >
                      <div className="text-sm font-bold text-blue-900">Additional Recommendations</div>
                      {expandedAdditionalRecs ? (
                        <ChevronUp className="w-4 h-4 text-blue-700 flex-shrink-0" />
                      ) : (
                        <ChevronDown className="w-4 h-4 text-blue-700 flex-shrink-0" />
                      )}
                    </button>
                    {expandedAdditionalRecs && (
                      <div className="px-5 pb-5 pt-1 border-t border-blue-200/50">
                        <div className="mt-5 space-y-3">
                          {aiRecommendation.additionalRecommendations.map((rec: string, idx: number) => {
                            // Parse category if present (format: "Category: Recommendation text")
                            const parts = rec.split(':');
                            const category = parts.length > 1 ? parts[0].trim() : null;
                            const recommendation = parts.length > 1 ? parts.slice(1).join(':').trim() : rec;
                            
                            return (
                              <div key={idx} className="flex items-start gap-3 bg-white rounded-md p-3 border border-blue-200/60">
                                <div className="w-2 h-2 bg-blue-600 rounded-full mt-1.5 flex-shrink-0"></div>
                                <div className="flex-1">
                                  {category && (
                                    <span className="text-xs font-bold text-blue-700 uppercase tracking-wide mr-1.5">
                                      {category}:
                                    </span>
                                  )}
                                  <span className="text-xs text-gray-900 leading-relaxed">{recommendation}</span>
                                </div>
                              </div>
                            );
                          })}
                        </div>
                      </div>
                    )}
                  </div>
                )}
              </div>

              {/* Your Decision Section - Moved Above Checklist */}
              <div className="mt-8">
                <div className="p-6 md:p-7 bg-gradient-to-br from-blue-50 to-blue-100/50 border-2 border-blue-200 rounded-xl shadow-md">
                  <div className="flex items-center gap-4 mb-4">
                    <div className="p-2.5 bg-blue-200 rounded-lg">
                      <User className="w-5 h-5 text-blue-700" />
                    </div>
                    <span className="text-sm font-bold text-blue-900">Your Decision</span>
                  </div>

                  <div>
                    <label className="text-xs font-bold text-gray-700 mb-2 block">Reasoning Notes</label>
                    <p className="text-xs text-gray-600 mb-3 leading-relaxed">Summarize your clinical reasoning for this decision and any modifications to the proposed plan.</p>
                    <textarea 
                      className="w-full px-4 py-3 border-2 border-gray-300 rounded-lg text-sm resize-none focus:border-blue-500 focus:ring-2 focus:ring-blue-200 transition-colors" 
                      rows={4}
                      value={reasoningNotes}
                      onChange={(e) => setReasoningNotes(e.target.value)}
                      placeholder="Document your reasoning and any plan modifications..."
                    ></textarea>
                  </div>
                </div>
              </div>

              {/* Final Review Checklist */}
              <div className="p-6 md:p-7 bg-gradient-to-br from-blue-50 to-blue-100/50 border-2 border-blue-200 rounded-xl mb-6 mt-6 shadow-md">
                <div className="text-sm font-bold text-blue-900 mb-4">Final Review Checklist</div>
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  <div className="flex items-center gap-3 text-xs text-blue-800 font-medium py-1">
                    <CheckCircle className="w-4 h-4 text-blue-600 flex-shrink-0" />
                    <span>AI assessment reviewed</span>
                  </div>
                  <div className="flex items-center gap-3 text-xs text-blue-800 font-medium py-1">
                    <CheckCircle className="w-4 h-4 text-blue-600 flex-shrink-0" />
                    <span>Evidence reviewed</span>
                  </div>
                  <div className="flex items-center gap-3 text-xs text-blue-800 font-medium py-1">
                    <CheckCircle className="w-4 h-4 text-blue-600 flex-shrink-0" />
                    <span>Proposed plan reviewed</span>
                  </div>
                  <div className="flex items-center gap-3 text-xs text-blue-800 font-medium py-1">
                    {reasoningNotes.trim().length > 0 ? (
                      <CheckCircle className="w-4 h-4 text-blue-600 flex-shrink-0" />
                    ) : (
                      <Circle className="w-4 h-4 text-gray-400 flex-shrink-0" />
                    )}
                    <span>Reasoning notes completed</span>
                  </div>
                </div>
              </div>

              <div className="space-y-4 mt-6">
                {error && (
                  <div className="mb-5 p-5 bg-red-50 border border-red-200 rounded-xl">
                    <div className="text-sm text-red-900">
                      <div className="font-medium mb-1">Error</div>
                      <div className="text-red-800">{error}</div>
                    </div>
                  </div>
                )}
                <button
                  onClick={handleApproveDecision}
                  disabled={finalizing}
                  className="w-full px-6 py-4 bg-gradient-to-r from-green-600 to-green-700 text-white font-bold text-base rounded-xl hover:from-green-700 hover:to-green-800 active:from-green-800 active:to-green-900 transition-all duration-200 flex items-center justify-center gap-3 disabled:from-gray-300 disabled:to-gray-400 disabled:cursor-not-allowed shadow-lg hover:shadow-xl disabled:shadow-none"
                >
                  {finalizing ? (
                    <>
                      <div className="w-6 h-6 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                      Finalizing...
                    </>
                  ) : (
                    <>
                      <FileCheck className="w-6 h-6" />
                      Finalize Decision
                    </>
                  )}
                </button>
                <div className="text-xs text-center text-gray-600 font-medium mt-3">
                  This will finalize the clinical decision for this visit and update the patient record.
                </div>
                
                {/* Save as Draft button - commented out */}
                {/* <button
                  className="w-full px-4 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors text-sm"
                >
                  Save as Draft
                </button> */}
              </div>
            </div>
          </div>
        )}

        {/* Completed */}
        {currentStep === 4 && (
          <div className="p-6 md:p-8">
            <div className="mb-8 pb-5 border-b border-gray-100">
              <div className="flex items-center gap-3 flex-wrap">
                <h3 className="text-lg font-semibold text-gray-900 tracking-tight">Visit Completed</h3>
                <span className="px-3 py-1 bg-green-100 text-green-700 text-xs font-medium rounded-full">
                  Success
                </span>
              </div>
              <p className="text-sm text-gray-500 mt-2">
                Clinical decision has been finalized and saved to the patient record. Digital twin summary has been generated and stored.
              </p>
            </div>

            <div className="max-w-5xl mx-auto space-y-8">
              {/* Main Content Grid */}
              <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
                {/* Left Column: Decision Summary */}
                <div className="lg:col-span-2 space-y-6">
                  {/* Decision Summary Card */}
                  <div className="p-6 md:p-7 bg-green-50/90 border border-green-100 rounded-xl">
                    <div className="mb-5">
                      <h4 className="text-sm font-medium text-gray-700">Decision Summary</h4>
                    </div>
                    <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                      <div className="space-y-3">
                        <div className="text-xs font-semibold text-gray-500 uppercase tracking-wide">Final Risk Tier</div>
                        <div>
                          <RiskBadge tier={doctorDecision.riskTier} size="lg" />
                        </div>
                      </div>
                      <div className="space-y-3">
                        <div className="text-xs font-semibold text-gray-500 uppercase tracking-wide">Approved By</div>
                        <div className="flex items-center gap-3">
                          <div className="w-8 h-8 bg-blue-100 rounded-full flex items-center justify-center flex-shrink-0">
                            <span className="text-blue-600 font-semibold text-sm">
                              {loggedInPractitioner?.name 
                                ? loggedInPractitioner.name.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2)
                                : 'DR'}
                            </span>
                          </div>
                          <div className="text-xs font-semibold text-gray-900">
                            {loggedInPractitioner?.name || 'Unknown Doctor'}
                          </div>
                        </div>
                      </div>
                      <div className="space-y-3">
                        <div className="text-xs font-semibold text-gray-500 uppercase tracking-wide">Completed At</div>
                        <div className="flex items-center gap-2 text-xs text-gray-700">
                          <Clock className="w-3 h-3 text-gray-400 flex-shrink-0" />
                          <span>{doctorDecision?.timestamp}</span>
                        </div>
                      </div>
                    </div>
                  </div>

                  {/* Twin Summary Card */}
                  {doctorDecision.twinSummary && (
                    <div className="p-6 md:p-7 bg-blue-50/90 border border-blue-100 rounded-xl">
                      <div className="flex items-center justify-between mb-5">
                        <h4 className="text-sm font-medium text-gray-700">Digital Twin Summary</h4>
                        <span className="px-2.5 py-0.5 bg-blue-100 text-blue-700 text-xs font-medium rounded-full">
                          ✓ Saved to Database
                        </span>
                      </div>
                      
                      <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
                        {doctorDecision.twinSummary.summaryVersion && (
                          <div className="p-4 bg-gray-50/80 rounded-xl border border-gray-100">
                            <div className="text-xs font-medium text-gray-500 mb-2">Summary Version</div>
                            <div className="text-sm font-mono text-gray-900 break-all font-semibold">
                              {doctorDecision.twinSummary.summaryVersion}
                            </div>
                          </div>
                        )}
                        {doctorDecision.twinSummary.asOfTime && (
                          <div className="p-4 bg-gray-50/80 rounded-xl border border-gray-100">
                            <div className="text-xs font-medium text-gray-500 mb-2">As of Time</div>
                            <div className="text-sm text-gray-900 font-semibold">
                              {new Date(doctorDecision.twinSummary.asOfTime).toLocaleString('en-US', {
                                year: 'numeric',
                                month: 'long',
                                day: 'numeric',
                                hour: '2-digit',
                                minute: '2-digit'
                              })}
                            </div>
                          </div>
                        )}
                      </div>

                      {doctorDecision.twinSummary.summaryText && (
                        <div className="p-5 bg-blue-50/90 border border-blue-100 rounded-xl">
                          <div className="text-sm font-medium text-gray-700 mb-2">Clinical Summary</div>
                          <div className="text-sm text-gray-700 whitespace-pre-wrap leading-relaxed max-h-64 overflow-y-auto pr-2 custom-scrollbar">
                            {doctorDecision.twinSummary.summaryText}
                          </div>
                        </div>
                      )}
                    </div>
                  )}
                </div>

                {/* Right Column: Visit Outcome Summary */}
                <div className="lg:col-span-1">
                  <div className="p-6 md:p-7 bg-gray-50/80 border border-gray-100 rounded-xl sticky top-6">
                    <div className="mb-5">
                      <h4 className="text-sm font-medium text-gray-700">Visit Outcomes</h4>
                    </div>
                    <div className="space-y-4">
                      <div className="flex items-start gap-4 p-4 bg-green-50 rounded-xl border border-green-200">
                        <div className="w-8 h-8 bg-green-500 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5">
                          <CheckCircle className="w-4 h-4 text-white" />
                        </div>
                        <div className="flex-1 min-w-0">
                          <div className="text-xs font-semibold text-gray-900 mb-1.5">Decision Documented</div>
                          <div className="text-xs text-gray-600">Clinical decision saved to record</div>
                        </div>
                      </div>
                      
                      <div className="flex items-start gap-4 p-4 bg-blue-50 rounded-xl border border-blue-200">
                        <div className="w-8 h-8 bg-blue-500 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5">
                          <CheckCircle className="w-4 h-4 text-white" />
                        </div>
                        <div className="flex-1 min-w-0">
                          <div className="text-xs font-semibold text-gray-900 mb-1.5">Treatment Plan</div>
                          <div className="text-xs text-blue-700 font-medium">{doctorDecision.planSummary}</div>
                        </div>
                      </div>
                      
                      <div className="flex items-start gap-4 p-4 bg-indigo-50 rounded-xl border border-indigo-200">
                        <div className="w-8 h-8 bg-indigo-500 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5">
                          <FileText className="w-4 h-4 text-white" />
                        </div>
                        <div className="flex-1 min-w-0">
                          <div className="text-xs font-semibold text-gray-900 mb-1.5">Twin Summary</div>
                          <div className="text-xs text-gray-600">Generated and saved</div>
                        </div>
                      </div>
                      
                      <div className={`flex items-start gap-4 p-4 rounded-xl border ${
                        doctorDecision.monitoringStatus === 'Active' 
                          ? 'bg-green-50 border-green-200' 
                          : doctorDecision.monitoringStatus === 'Paused'
                          ? 'bg-yellow-50 border-yellow-200'
                          : 'bg-gray-50 border-gray-200'
                      }`}>
                        <div className={`w-8 h-8 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5 ${
                          doctorDecision.monitoringStatus === 'Active'
                            ? 'bg-green-500'
                            : doctorDecision.monitoringStatus === 'Paused'
                            ? 'bg-yellow-500'
                            : 'bg-gray-400'
                        }`}>
                          <CheckCircle className="w-4 h-4 text-white" />
                        </div>
                        <div className="flex-1 min-w-0">
                          <div className="text-xs font-semibold text-gray-900 mb-1.5">Monitoring Status</div>
                          <div className={`text-xs font-medium ${
                            doctorDecision.monitoringStatus === 'Active'
                              ? 'text-green-700'
                              : doctorDecision.monitoringStatus === 'Paused'
                              ? 'text-yellow-700'
                              : 'text-gray-600'
                          }`}>
                            {doctorDecision.monitoringStatus || 'Active'}
                          </div>
                        </div>
                      </div>
                      
                      {doctorDecision.followUpDate && (
                        <div className="flex items-start gap-4 p-4 bg-amber-50 rounded-xl border border-amber-200">
                          <div className="w-8 h-8 bg-amber-500 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5">
                            <Clock className="w-4 h-4 text-white" />
                          </div>
                          <div className="flex-1 min-w-0">
                            <div className="text-xs font-semibold text-gray-900 mb-1.5">Follow-up Scheduled</div>
                            <div className="text-xs text-amber-700 font-medium">{doctorDecision.followUpDate}</div>
                          </div>
                        </div>
                      )}
                    </div>
                  </div>
                </div>
              </div>

              {/* Action Buttons */}
              <div className="flex flex-col sm:flex-row gap-4 justify-center pt-8 mt-2 border-t border-gray-100">
                <button
                  onClick={() => {
                    setCurrentStep(1);
                    setFlowStatus('not-started');
                    setAnalysisRun(false);
                    setAiRecommendation(null);
                    setDoctorDecision(null);
                    setSummaryText(null);
                  }}
                  className="px-8 py-4 border-2 border-gray-200 text-gray-700 font-semibold rounded-xl hover:bg-gray-50 hover:border-gray-300 transition-all duration-200 shadow-sm"
                >
                  Start New Visit
                </button>
                <button
                  onClick={handleDownloadVisitReport}
                  disabled={!doctorDecision}
                  className="px-8 py-4 bg-blue-600 text-white font-semibold rounded-xl hover:bg-blue-700 transition-all duration-200 shadow-md hover:shadow-lg disabled:bg-gray-400 disabled:cursor-not-allowed flex items-center justify-center gap-2"
                >
                  <Download className="w-5 h-5" />
                  Download Visit Report
                </button>
              </div>
            </div>
          </div>
        )}
      </div>

      {/* Evidence-Based Summary modal (full text) */}
      {evidenceSummaryModal && (
        <div
          className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-md"
          onClick={() => setEvidenceSummaryModal(null)}
          role="dialog"
          aria-modal="true"
          aria-labelledby="evidence-summary-modal-title"
        >
          <div
            className="bg-white rounded-2xl max-w-2xl w-full max-h-[88vh] flex flex-col overflow-hidden border border-gray-200/80 shadow-[0_25px_50px_-12px_rgba(0,0,0,0.25)]"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="flex items-center justify-between gap-3 px-6 py-4 min-w-0 bg-gradient-to-r from-emerald-50 via-teal-50/90 to-cyan-50/80 border-b border-emerald-100/80">
              <h2 id="evidence-summary-modal-title" className="text-lg font-bold text-gray-900 min-w-0 break-words tracking-tight">
                {evidenceSummaryModal.title}
              </h2>
              <button
                type="button"
                onClick={() => setEvidenceSummaryModal(null)}
                className="p-2 rounded-xl text-gray-500 hover:text-gray-800 hover:bg-white/80 transition-colors"
                aria-label="Close"
              >
                <X className="w-5 h-5" />
              </button>
            </div>
            <div className="flex-1 overflow-y-auto overflow-x-hidden px-6 py-5 min-h-0 bg-gray-50/30">
              <div className="text-[15px] text-gray-800 leading-relaxed break-words min-w-0">
                <RagResultsWithCitations text={evidenceSummaryModal.content} references={evidenceSummaryModal.references} className="leading-relaxed break-words" compact />
              </div>
            </div>
            <div className="px-6 py-4 border-t border-gray-100 bg-white flex justify-end">
              <button
                type="button"
                onClick={() => setEvidenceSummaryModal(null)}
                className="px-5 py-2.5 bg-emerald-600 text-white font-semibold rounded-xl hover:bg-emerald-700 active:scale-[0.98] transition-all shadow-sm hover:shadow"
              >
                Close
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}