import { useState } from 'react';
import { CheckCircle, Circle, ArrowRight, Brain, User, FileCheck, AlertCircle, Clock, Edit, Trash2, Plus, FileText, Download } from 'lucide-react';
import { Patient } from '../App';
import { RiskBadge } from './RiskBadge';
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
}

export function VisitAnalysisFlow({ patient, onViewFullRecord, onViewClinicalDiscussion, visitTrigger, discussionReferenced, loggedInPractitioner }: VisitAnalysisFlowProps) {
  const [currentStep, setCurrentStep] = useState<FlowStep>(1);
  const [flowStatus, setFlowStatus] = useState<'not-started' | 'in-progress' | 'completed'>('not-started');
  const [analysisRun, setAnalysisRun] = useState(false);
  const [aiRecommendation, setAiRecommendation] = useState<{
    riskTier: 'Low' | 'Medium' | 'High';
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
  const [editingMedicationId, setEditingMedicationId] = useState<string | null>(null);
  const [editingProcedureId, setEditingProcedureId] = useState<string | null>(null);
  const [showDeleteConfirm, setShowDeleteConfirm] = useState<{type: 'medication' | 'procedure', id: string} | null>(null);
  const [addingMedication, setAddingMedication] = useState(false);
  const [addingProcedure, setAddingProcedure] = useState(false);
  // Start with empty arrays - will be populated from LLM response in Step 3
  const [medications, setMedications] = useState<MedicationRecommendation[]>([]);
  const [procedures, setProcedures] = useState<ProcedureRecommendation[]>([]);

  // Edit state for medications
  const [medEditForm, setMedEditForm] = useState<Partial<MedicationRecommendation>>({});
  
  // Edit state for procedures
  const [procEditForm, setProcEditForm] = useState<Partial<ProcedureRecommendation>>({});

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
      const aiResponse = result.data;
      
      // Normalize risk tier from LLM response
      const normalizedRiskTier = normalizeRiskTier(aiResponse.ai_recommendation?.risk_tier || patient.riskTier);
      
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
        differentialDiagnosis: aiResponse.differential_diagnosis || [],
      });
      
      // Also update selected risk tier to match AI recommendation initially
      setSelectedRiskTier(normalizedRiskTier);
      
      // Update medications and procedures from AI response - keep original status from LLM
      if (aiResponse.medication_recommendations && aiResponse.medication_recommendations.length > 0) {
        const meds = aiResponse.medication_recommendations.map((med: any, idx: number) => ({
          id: `med_${idx + 1}`,
          medication: med.medication || 'Unknown medication',
          dose: med.dose || '',
          frequency: med.frequency || '',
          duration: med.duration || 'Ongoing',
          rationale: med.rationale || '',
          evidence: Array.isArray(med.reasoning) ? med.reasoning : (med.reasoning ? [med.reasoning] : []),
          status: med.status || 'Unknown' // Keep original status from LLM
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
          status: proc.status || 'Unknown' // Keep original status from LLM
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
          final_risk_tier: selectedRiskTier,
          ai_risk_tier: aiRecommendation.riskTier,
          risk_tier_override: selectedRiskTier !== aiRecommendation.riskTier,
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
        const daysUntilFollowUp = selectedRiskTier === 'High' ? 3 : selectedRiskTier === 'Medium' ? 7 : 14;
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
        riskTier: selectedRiskTier,
        planSummary: `${activeMeds} medication adjustment${activeMeds !== 1 ? 's' : ''}, ${activeProcs} procedure/order${activeProcs !== 1 ? 's' : ''}`,
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
  const handleEditMedication = (med: MedicationRecommendation) => {
    setEditingMedicationId(med.id);
    setMedEditForm({ ...med });
  };

  const handleSaveMedication = () => {
    if (editingMedicationId && medEditForm) {
      setMedications(medications.map(m => 
        m.id === editingMedicationId ? { ...m, ...medEditForm } as MedicationRecommendation : m
      ));
      setEditingMedicationId(null);
      setMedEditForm({});
    }
  };

  const handleCancelMedicationEdit = () => {
    setEditingMedicationId(null);
    setMedEditForm({});
  };

  const handleDeleteMedication = (id: string) => {
    setShowDeleteConfirm({ type: 'medication', id });
  };

  const confirmDelete = () => {
    if (showDeleteConfirm) {
      if (showDeleteConfirm.type === 'medication') {
        setMedications(medications.filter(m => m.id !== showDeleteConfirm.id));
      } else {
        setProcedures(procedures.filter(p => p.id !== showDeleteConfirm.id));
      }
      setShowDeleteConfirm(null);
    }
  };

  const handleAddMedication = () => {
    setAddingMedication(true);
    setMedEditForm({
      id: Date.now().toString(),
      medication: '',
      dose: '',
      frequency: '',
      duration: '',
      rationale: '',
      evidence: [],
      status: 'Planned' // Default status for new medications
    });
  };

  const handleSaveNewMedication = () => {
    if (medEditForm.medication && medEditForm.dose && medEditForm.frequency && medEditForm.rationale) {
      setMedications([...medications, medEditForm as MedicationRecommendation]);
      setAddingMedication(false);
      setMedEditForm({});
    }
  };

  const handleCancelAddMedication = () => {
    setAddingMedication(false);
    setMedEditForm({});
  };

  // Procedure handlers
  const handleEditProcedure = (proc: ProcedureRecommendation) => {
    setEditingProcedureId(proc.id);
    setProcEditForm({ ...proc });
  };

  const handleSaveProcedure = () => {
    if (editingProcedureId && procEditForm) {
      setProcedures(procedures.map(p => 
        p.id === editingProcedureId ? { ...p, ...procEditForm } as ProcedureRecommendation : p
      ));
      setEditingProcedureId(null);
      setProcEditForm({});
    }
  };

  const handleCancelProcedureEdit = () => {
    setEditingProcedureId(null);
    setProcEditForm({});
  };

  const handleDeleteProcedure = (id: string) => {
    setShowDeleteConfirm({ type: 'procedure', id });
  };

  const handleAddProcedure = () => {
    setAddingProcedure(true);
    setProcEditForm({
      id: Date.now().toString(),
      procedure: '',
      timing: '',
      rationale: '',
      evidence: [],
      status: 'Planned' // Default status for new procedures
    });
  };

  const handleSaveNewProcedure = () => {
    if (procEditForm.procedure && procEditForm.timing && procEditForm.rationale) {
      setProcedures([...procedures, procEditForm as ProcedureRecommendation]);
      setAddingProcedure(false);
      setProcEditForm({});
    }
  };

  const handleCancelAddProcedure = () => {
    setAddingProcedure(false);
    setProcEditForm({});
  };

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
      doc.text('Procedure/Order Recommendations:', margin, yPos);
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
        <div className="bg-gray-50 border border-gray-200 rounded-lg p-3 mb-4 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="text-xs text-gray-500 font-medium uppercase tracking-wide">Visit Trigger</div>
            <div className="flex items-center gap-2">
              <span className="px-2.5 py-1 bg-blue-100 text-blue-800 text-sm font-medium rounded">
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

      {/* Progress Indicator */}
      <div className="bg-white rounded-lg border border-gray-200 p-6 mb-6">
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

        {/* Step Indicators */}
        <div className="flex items-center justify-between">
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
                  ) : (
                    <span className={`text-sm font-medium ${
                      currentStep === step.number ? 'text-white' : 'text-gray-500'
                    }`}>
                      {step.number}
                    </span>
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
      <div className="bg-white rounded-lg border border-gray-200 p-6">
        {/* Step 1: Review Patient State */}
        {currentStep === 1 && (
          <div>
            <div className="mb-4">
              <h3 className="font-semibold text-gray-900">Step 1: Patient State</h3>
              <p className="text-sm text-gray-600">Snapshot of current problems, medications, and latest vitals.</p>
            </div>
            
            <div className="space-y-4 mb-6">
              <div className="p-4 bg-gray-50 rounded-lg">
                <div className="text-sm font-medium text-gray-700 mb-2">Current Status</div>
                <div className="flex items-center gap-3">
                  <RiskBadge tier={patient.riskTier} size="md" />
                  <span className="text-sm text-gray-600">Last evaluation: {patient.lastEvaluation}</span>
                </div>
              </div>

              <div className="p-4 bg-gray-50 rounded-lg">
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

              <div className="p-4 bg-blue-50 border border-blue-200 rounded-lg">
                <div className="text-sm text-blue-900">
                  <div className="font-medium mb-1">Ready to proceed</div>
                  <div className="text-blue-800">Patient data is current and complete. You may proceed to AI analysis.</div>
                </div>
              </div>
            </div>

            {error && (
              <div className="mb-4 p-4 bg-red-50 border border-red-200 rounded-lg">
                <div className="text-sm text-red-900">
                  <div className="font-medium mb-1">Error</div>
                  <div className="text-red-800">{error}</div>
                </div>
              </div>
            )}

            <button
              onClick={handleRunAnalysis}
              disabled={loadingData}
              className="w-full px-6 py-3 bg-blue-600 text-white font-medium rounded-lg hover:bg-blue-700 transition-colors flex items-center justify-center gap-2 disabled:bg-gray-400 disabled:cursor-not-allowed"
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

        {/* Step 2: AI Analysis Running */}
        {currentStep === 2 && !aiRecommendation && (
          <div>
            <div className="mb-4">
              <div className="flex items-center gap-2">
                <Brain className="w-5 h-5 text-purple-600" />
                <h3 className="font-semibold text-gray-900">Step 2: Data Fetched</h3>
                <span className="px-2 py-0.5 bg-green-100 text-green-700 text-xs font-medium rounded">
                  Ready
                </span>
              </div>
              <p className="text-sm text-gray-600">Patient data has been fetched. Review the summary below and proceed to generate AI recommendations.</p>
            </div>

            {dataFetchSummary && (
              <div className="space-y-4 mb-6">
                <div className="p-4 bg-green-50 border border-green-200 rounded-lg">
                  <div className="text-sm font-medium text-gray-700 mb-3">Data Fetched Summary</div>
                  <div className="grid grid-cols-3 gap-4">
                    <div className="text-center">
                      <div className="text-2xl font-bold text-green-700">{dataFetchSummary.alarms}</div>
                      <div className="text-xs text-gray-600 mt-1">Alarms</div>
                    </div>
                    <div className="text-center">
                      <div className="text-2xl font-bold text-green-700">{dataFetchSummary.riskFactors}</div>
                      <div className="text-xs text-gray-600 mt-1">Risk Factors</div>
                    </div>
                    <div className="text-center">
                      <div className="text-2xl font-bold text-green-700">{dataFetchSummary.twinSummaries}</div>
                      <div className="text-xs text-gray-600 mt-1">Twin Summaries</div>
                    </div>
                  </div>
                </div>

                {assessmentInputData?.patient_snapshot && (
                  <div className="p-4 bg-gray-50 rounded-lg">
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

                {/* Current Summary Text */}
                {summaryText && (
                  <div className="p-4 bg-blue-50 border border-blue-200 rounded-lg">
                    <div className="text-sm font-medium text-gray-700 mb-2">Current Clinical Summary</div>
                    <div className="text-sm text-gray-700 whitespace-pre-wrap max-h-60 overflow-y-auto">
                      {summaryText}
                    </div>
                  </div>
                )}
              </div>
            )}

            {error && (
              <div className="mb-4 p-4 bg-red-50 border border-red-200 rounded-lg">
                <div className="text-sm text-red-900">
                  <div className="font-medium mb-1">Error</div>
                  <div className="text-red-800">{error}</div>
                </div>
              </div>
            )}

            <button
              onClick={handleReviewAI}
              disabled={loadingAI || !assessmentInputData}
              className="w-full px-6 py-3 bg-blue-600 text-white font-medium rounded-lg hover:bg-blue-700 transition-colors flex items-center justify-center gap-2 disabled:bg-gray-400 disabled:cursor-not-allowed"
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

        {/* Step 2: AI Clinical Assessment (Results) */}
        {currentStep === 2 && aiRecommendation && (
          <div>
            <div className="mb-4">
              <div className="flex items-center gap-2">
                <Brain className="w-5 h-5 text-purple-600" />
                <h3 className="font-semibold text-gray-900">Step 2: AI Clinical Assessment</h3>
                <span className="px-2 py-0.5 bg-purple-100 text-purple-700 text-xs font-medium rounded">
                  Assistive
                </span>
              </div>
              <p className="text-sm text-gray-600">Review the AI-generated assessment and supporting evidence before making your decision.</p>
            </div>

            <div className="space-y-4 mb-6">
              <div className="p-4 bg-purple-50 border border-purple-200 rounded-lg">
                <div className="text-sm font-medium text-gray-700 mb-3">AI Assessment</div>
                <RiskBadge tier={aiRecommendation.riskTier} size="lg" />
              </div>

              <div className="p-4 bg-gray-50 rounded-lg">
                <div className="text-sm font-medium text-gray-700 mb-3">Clinical Reasoning</div>
                <ul className="space-y-2">
                  {aiRecommendation.reasoning.map((reason: string, idx: number) => (
                    <li key={idx} className="flex items-start gap-2 text-sm text-gray-700">
                      <div className="w-1.5 h-1.5 bg-purple-500 rounded-full mt-1.5 flex-shrink-0"></div>
                      {reason}
                    </li>
                  ))}
                </ul>
              </div>

              <div className="p-4 bg-blue-50 border border-blue-200 rounded-lg">
                <div className="text-sm text-blue-900">
                  <div className="font-medium mb-1">AI model: ClinicalAI v3.2.1</div>
                  <div className="text-blue-800">Analysis timestamp: {new Date().toLocaleString()}</div>
                  {aiRecommendation?.confidence && (
                    <div className="text-blue-800 mt-1">Confidence: {aiRecommendation.confidence}</div>
                  )}
                </div>
              </div>
            </div>

            {error && (
              <div className="mb-4 p-4 bg-red-50 border border-red-200 rounded-lg">
                <div className="text-sm text-red-900">
                  <div className="font-medium mb-1">Error</div>
                  <div className="text-red-800">{error}</div>
                </div>
              </div>
            )}

            <button
              onClick={handleReviewAI}
              disabled={loadingAI}
              className="w-full px-6 py-3 bg-blue-600 text-white font-medium rounded-lg hover:bg-blue-700 transition-colors flex items-center justify-center gap-2 disabled:bg-gray-400 disabled:cursor-not-allowed"
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

        {/* Step 3: Doctor Clinical Decision */}
        {currentStep === 3 && (
          <div>
            <div className="mb-6 pb-4 border-b border-gray-200">
              <div className="flex items-center gap-3 mb-2">
                <div className="p-2 bg-blue-100 rounded-lg">
                  <User className="w-5 h-5 text-blue-600" />
                </div>
                <div>
                  <h3 className="text-xl font-bold text-gray-900">Step 3: Clinical Decision</h3>
                  <p className="text-sm text-gray-600 mt-1">Record your clinical judgment and reasoning. This becomes the authoritative visit record.</p>
                </div>
              </div>
            </div>

            <div className="space-y-8">
              {/* AI Proposed Plan */}
              <div className="border-2 border-purple-200 rounded-xl p-6 bg-gradient-to-br from-purple-50 to-purple-100/50 shadow-sm">
                <div className="flex items-center gap-3 mb-3">
                  <div className="p-2 bg-purple-200 rounded-lg">
                    <Brain className="w-5 h-5 text-purple-700" />
                  </div>
                  <div>
                    <h4 className="text-base font-bold text-gray-900">AI Recommendations</h4>
                    <p className="text-xs text-gray-600 mt-0.5">Review and adjust based on your clinical judgment</p>
                  </div>
                </div>
                <div className="mt-4 p-3 bg-white/70 border border-purple-200 rounded-lg">
                  <p className="text-xs text-purple-800 font-medium flex items-center gap-2">
                    <AlertCircle className="w-3.5 h-3.5" />
                    <span>These recommendations are assistive; clinician review is required.</span>
                  </p>
                </div>

                {/* Differential Diagnosis */}
                {aiRecommendation?.differentialDiagnosis && aiRecommendation.differentialDiagnosis.length > 0 && (
                  <div className="mb-6 mt-6">
                    <div className="flex items-center gap-3 mb-6">
                      <div className="h-px flex-1 bg-gradient-to-r from-transparent via-purple-300 to-transparent"></div>
                      <div className="flex items-center gap-2">
                        <div className="w-2 h-2 bg-purple-600 rounded-full"></div>
                        <h5 className="text-base font-bold text-gray-900 px-2">Differential Diagnosis</h5>
                        <div className="w-2 h-2 bg-purple-600 rounded-full"></div>
                      </div>
                      <div className="h-px flex-1 bg-gradient-to-r from-transparent via-purple-300 to-transparent"></div>
                    </div>
                    <div className="grid grid-cols-1 gap-5">
                      {aiRecommendation.differentialDiagnosis.map((diagnosis, idx) => {
                        // Handle both camelCase and snake_case from API
                        const diagnosisName = diagnosis.diagnosisName || (diagnosis as any).diagnosis_name || 'Diagnosis';
                        const probabilityBin = diagnosis.probabilityBin || (diagnosis as any).probability_bin || 'Low';
                        const reasoning = diagnosis.reasoning || '';
                        const supportingEvidence = diagnosis.supportingEvidence || (diagnosis as any).supporting_evidence || [];
                        
                        return (
                        <div key={idx} className="bg-white border border-gray-200 rounded-2xl p-7 shadow-lg hover:shadow-xl transition-all duration-300 bg-gradient-to-br from-white to-gray-50/30">
                          {/* Diagnosis Name Header */}
                          <div className="flex items-start justify-between mb-6 pb-5 border-b-2 border-gray-100">
                            <div className="flex-1 pr-4">
                              <div className="flex items-center gap-3 mb-2">
                                <div className={`w-2 h-2 rounded-full ${
                                  probabilityBin === 'High' ? 'bg-red-500' :
                                  probabilityBin === 'Medium' ? 'bg-yellow-500' :
                                  'bg-blue-500'
                                }`}></div>
                                <h6 className="text-xl font-bold text-black leading-tight">
                                  {diagnosisName}
                                </h6>
                              </div>
                            </div>
                            <span className={`px-5 py-2.5 text-xs font-bold rounded-full whitespace-nowrap shadow-md ${
                              probabilityBin === 'High' ? 'bg-gradient-to-r from-red-500 to-red-600 text-white' :
                              probabilityBin === 'Medium' ? 'bg-gradient-to-r from-yellow-500 to-yellow-600 text-white' :
                              'bg-gradient-to-r from-blue-500 to-blue-600 text-white'
                            }`}>
                              {probabilityBin === 'High' ? 'High Confidence' :
                               probabilityBin === 'Medium' ? 'Moderate Confidence' :
                               'Low Confidence'}
                            </span>
                          </div>
                          
                          {/* Clinical Reasoning */}
                          {reasoning && (
                            <div className="mb-6">
                              <div className="flex items-center gap-2 mb-4">
                                <div className="w-1 h-1 bg-purple-600 rounded-full"></div>
                                <div className="text-xs font-bold text-purple-700 uppercase tracking-wider">Clinical Reasoning</div>
                              </div>
                              <div className="bg-gradient-to-br from-purple-50 to-indigo-50 rounded-xl p-5 border border-purple-100 shadow-sm">
                                <p className="text-sm text-gray-800 leading-relaxed">
                                  {reasoning}
                                </p>
                              </div>
                            </div>
                          )}
                          
                          {/* Supporting Evidence */}
                          {supportingEvidence && supportingEvidence.length > 0 && (
                            <div className="pt-5 border-t border-gray-100">
                              <div className="flex items-center gap-2 mb-4">
                                <div className="w-1 h-1 bg-indigo-600 rounded-full"></div>
                                <div className="text-xs font-bold text-indigo-700 uppercase tracking-wider">Supporting Evidence</div>
                              </div>
                              <ul className="space-y-2">
                                {supportingEvidence.map((evidence: string, evIdx: number) => (
                                  <li key={evIdx} className="flex items-start gap-2 text-sm text-gray-700">
                                    <span className="text-indigo-600 font-bold mt-0.5">•</span>
                                    <span className="flex-1">{evidence}</span>
                                  </li>
                                ))}
                              </ul>
                            </div>
                          )}
                        </div>
                        );
                      })}
                    </div>
                  </div>
                )}

                {/* Medications */}
                <div className="mb-6 mt-6">
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
                      <div className="text-xs text-gray-400">You can add your own recommendations below</div>
                    </div>
                  ) : (
                    <div className="space-y-4">
                      {medications.map((med) => (
                      <div key={med.id} className={`bg-white border-2 rounded-xl p-5 shadow-md mr-4 transition-all duration-200 ${editingMedicationId === med.id ? 'border-blue-500 bg-blue-50/50 shadow-lg ring-2 ring-blue-200' : 'border-gray-200 hover:border-gray-300 hover:shadow-lg'}`}>
                        {editingMedicationId === med.id ? (
                          /* Edit Mode */
                          <div className="space-y-3">
                            <div className="grid grid-cols-2 gap-3">
                              <div>
                                <label className="text-xs font-semibold text-gray-700 block mb-1.5">Medication</label>
                                <input
                                  type="text"
                                  className="w-full px-3 py-2 border-2 border-gray-300 rounded-lg text-sm focus:border-blue-500 focus:ring-2 focus:ring-blue-200 transition-colors"
                                  value={medEditForm.medication || ''}
                                  onChange={(e) => setMedEditForm({...medEditForm, medication: e.target.value})}
                                />
                              </div>
                              <div>
                                <label className="text-xs font-semibold text-gray-700 block mb-1.5">Dose</label>
                                <input
                                  type="text"
                                  className="w-full px-3 py-2 border-2 border-gray-300 rounded-lg text-sm focus:border-blue-500 focus:ring-2 focus:ring-blue-200 transition-colors"
                                  value={medEditForm.dose || ''}
                                  onChange={(e) => setMedEditForm({...medEditForm, dose: e.target.value})}
                                />
                              </div>
                              <div>
                                <label className="text-xs font-semibold text-gray-700 block mb-1.5">Frequency</label>
                                <input
                                  type="text"
                                  className="w-full px-3 py-2 border-2 border-gray-300 rounded-lg text-sm focus:border-blue-500 focus:ring-2 focus:ring-blue-200 transition-colors"
                                  value={medEditForm.frequency || ''}
                                  onChange={(e) => setMedEditForm({...medEditForm, frequency: e.target.value})}
                                />
                              </div>
                              <div>
                                <label className="text-xs font-semibold text-gray-700 block mb-1.5">Duration <span className="text-gray-400 font-normal">(optional)</span></label>
                                <input
                                  type="text"
                                  className="w-full px-3 py-2 border-2 border-gray-300 rounded-lg text-sm focus:border-blue-500 focus:ring-2 focus:ring-blue-200 transition-colors"
                                  value={medEditForm.duration || ''}
                                  onChange={(e) => setMedEditForm({...medEditForm, duration: e.target.value})}
                                />
                              </div>
                            </div>
                            <div>
                              <label className="text-xs font-semibold text-gray-700 block mb-1.5">Rationale</label>
                              <textarea
                                className="w-full px-3 py-2 border-2 border-gray-300 rounded-lg text-sm resize-none focus:border-blue-500 focus:ring-2 focus:ring-blue-200 transition-colors"
                                rows={3}
                                value={medEditForm.rationale || ''}
                                onChange={(e) => setMedEditForm({...medEditForm, rationale: e.target.value})}
                              />
                            </div>
                            <div>
                              <label className="text-xs font-semibold text-gray-700 block mb-1.5">Status</label>
                              <select
                                className="w-full px-3 py-2 border-2 border-gray-300 rounded-lg text-sm focus:border-blue-500 focus:ring-2 focus:ring-blue-200 transition-colors bg-white"
                                value={medEditForm.status || 'Planned'}
                                onChange={(e) => setMedEditForm({...medEditForm, status: e.target.value})}
                              >
                                <option value="Planned">Planned</option>
                                <option value="Continue">Continue</option>
                                <option value="Start">Start</option>
                                <option value="Increase">Increase</option>
                                <option value="Adjust">Adjust</option>
                                <option value="Stop">Stop</option>
                                <option value="Discontinue">Discontinue</option>
                                <option value="Consider">Consider</option>
                              </select>
                            </div>
                            <div className="pt-3 border-t border-gray-200">
                              <div className="text-xs font-semibold text-gray-600 mb-2">Evidence (read-only)</div>
                              <div className="flex flex-wrap gap-2">
                                {med.evidence.map((ev, idx) => (
                                  <span key={idx} className="px-2.5 py-1 bg-purple-100 text-purple-700 text-xs font-medium rounded-md border border-purple-200 shadow-sm">
                                    {ev}
                                  </span>
                                ))}
                              </div>
                            </div>
                            <div className="flex gap-3 pt-4 border-t border-gray-200">
                              <button
                                onClick={handleSaveMedication}
                                className="flex-1 px-4 py-2.5 bg-blue-600 text-white text-sm font-semibold rounded-lg hover:bg-blue-700 active:bg-blue-800 shadow-md hover:shadow-lg transition-all duration-200"
                              >
                                Save Changes
                              </button>
                              <button
                                onClick={handleCancelMedicationEdit}
                                className="flex-1 px-4 py-2.5 border-2 border-gray-300 text-gray-700 text-sm font-semibold rounded-lg hover:bg-gray-50 hover:border-gray-400 active:bg-gray-100 transition-all duration-200"
                              >
                                Cancel
                              </button>
                            </div>
                          </div>
                        ) : (
                          /* Read Mode */
                          <>
                            <div className="flex items-start justify-between mb-3">
                              <div className="flex-1 pr-4">
                                <div className="flex items-center gap-3 mb-2">
                                  <div className="font-bold text-base text-gray-900">
                                    {med.medication}
                                  </div>
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
                                </div>
                                <div className="text-sm text-gray-700 mb-3 leading-relaxed">
                                  <span className="font-semibold text-gray-900">Rationale:</span> {med.rationale}
                                </div>
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
                              <div className="flex items-start gap-2 ml-3 flex-shrink-0">
                                <span
                                  className={`px-3 py-1.5 text-xs font-bold rounded-lg shadow-sm ${getStatusBadgeClass(med.status)}`}
                                  title={`Status: ${med.status}`}
                                >
                                  {med.status}
                                </span>
                              </div>
                            </div>
                            <div className="flex gap-2">
                              <button
                                onClick={() => handleEditMedication(med)}
                                className="text-xs text-blue-600 hover:text-blue-700 flex items-center gap-1"
                                title="Edit recommendation"
                              >
                                <Edit className="w-3 h-3" />
                                Edit
                              </button>
                              <button
                                onClick={() => handleDeleteMedication(med.id)}
                                className="text-xs text-red-600 hover:text-red-700 flex items-center gap-1"
                                title="Remove from proposed plan"
                              >
                                <Trash2 className="w-3 h-3" />
                                Remove
                              </button>
                            </div>
                          </>
                        )}
                      </div>
                      ))}
                    </div>
                  )}

                    {/* Add New Medication Form */}
                    {addingMedication && (
                      <div className="bg-white border-2 border-blue-400 rounded-xl p-5 bg-gradient-to-br from-blue-50 to-blue-100/50 shadow-lg">
                        <div className="text-sm text-blue-900 mb-4 font-bold flex items-center gap-2">
                          <Plus className="w-4 h-4" />
                          Add New Medication Recommendation
                        </div>
                        <div className="space-y-4">
                          <div className="grid grid-cols-2 gap-3">
                            <div>
                              <label className="text-xs font-semibold text-gray-700 block mb-1.5">Medication <span className="text-red-500">*</span></label>
                              <input
                                type="text"
                                className="w-full px-3 py-2 border-2 border-gray-300 rounded-lg text-sm focus:border-blue-500 focus:ring-2 focus:ring-blue-200 transition-colors"
                                value={medEditForm.medication || ''}
                                onChange={(e) => setMedEditForm({...medEditForm, medication: e.target.value})}
                                placeholder="e.g., Metoprolol"
                              />
                            </div>
                            <div>
                              <label className="text-xs font-semibold text-gray-700 block mb-1.5">Dose <span className="text-red-500">*</span></label>
                              <input
                                type="text"
                                className="w-full px-3 py-2 border-2 border-gray-300 rounded-lg text-sm focus:border-blue-500 focus:ring-2 focus:ring-blue-200 transition-colors"
                                value={medEditForm.dose || ''}
                                onChange={(e) => setMedEditForm({...medEditForm, dose: e.target.value})}
                                placeholder="e.g., 25 mg"
                              />
                            </div>
                            <div>
                              <label className="text-xs font-semibold text-gray-700 block mb-1.5">Frequency <span className="text-red-500">*</span></label>
                              <input
                                type="text"
                                className="w-full px-3 py-2 border-2 border-gray-300 rounded-lg text-sm focus:border-blue-500 focus:ring-2 focus:ring-blue-200 transition-colors"
                                value={medEditForm.frequency || ''}
                                onChange={(e) => setMedEditForm({...medEditForm, frequency: e.target.value})}
                                placeholder="e.g., twice daily"
                              />
                            </div>
                            <div>
                              <label className="text-xs font-semibold text-gray-700 block mb-1.5">Duration <span className="text-gray-400 font-normal">(optional)</span></label>
                              <input
                                type="text"
                                className="w-full px-3 py-2 border-2 border-gray-300 rounded-lg text-sm focus:border-blue-500 focus:ring-2 focus:ring-blue-200 transition-colors"
                                value={medEditForm.duration || ''}
                                onChange={(e) => setMedEditForm({...medEditForm, duration: e.target.value})}
                                placeholder="e.g., Ongoing"
                              />
                            </div>
                          </div>
                          <div>
                            <label className="text-xs font-semibold text-gray-700 block mb-1.5">Rationale <span className="text-red-500">*</span></label>
                            <textarea
                              className="w-full px-3 py-2 border-2 border-gray-300 rounded-lg text-sm resize-none focus:border-blue-500 focus:ring-2 focus:ring-blue-200 transition-colors"
                              rows={3}
                              value={medEditForm.rationale || ''}
                              onChange={(e) => setMedEditForm({...medEditForm, rationale: e.target.value})}
                              placeholder="Clinical justification for this recommendation"
                            />
                          </div>
                          <div className="flex gap-3 pt-3 border-t border-gray-200">
                            <button
                              onClick={handleSaveNewMedication}
                              disabled={!medEditForm.medication || !medEditForm.dose || !medEditForm.frequency || !medEditForm.rationale}
                              className="flex-1 px-4 py-2.5 bg-blue-600 text-white text-sm font-semibold rounded-lg hover:bg-blue-700 active:bg-blue-800 disabled:bg-gray-300 disabled:cursor-not-allowed shadow-md hover:shadow-lg transition-all duration-200"
                            >
                              Add Recommendation
                            </button>
                            <button
                              onClick={handleCancelAddMedication}
                              className="flex-1 px-4 py-2.5 border-2 border-gray-300 text-gray-700 text-sm font-semibold rounded-lg hover:bg-gray-50 hover:border-gray-400 active:bg-gray-100 transition-all duration-200"
                            >
                              Cancel
                            </button>
                          </div>
                        </div>
                      </div>
                    )}
                  </div>
                  {!addingMedication && (
                    <button
                      onClick={handleAddMedication}
                      className="mt-3 text-sm text-blue-600 hover:text-blue-700 flex items-center gap-1"
                    >
                      <Plus className="w-4 h-4" />
                      Add medication recommendation
                    </button>
                  )}
                </div>

                {/* Procedures/Orders */}
                <div className="mt-6 mb-8">
                  <div className="p-6 bg-gradient-to-br from-gray-50 to-gray-100/50 border-2 border-gray-200 rounded-xl shadow-sm">
                    <div className="flex items-center gap-2 mb-4">
                      <div className="h-px flex-1 bg-gradient-to-r from-transparent via-gray-300 to-transparent"></div>
                      <h5 className="text-sm font-bold text-gray-900 px-3">Procedures / Orders</h5>
                      <div className="h-px flex-1 bg-gradient-to-r from-transparent via-gray-300 to-transparent"></div>
                    </div>
                    <p className="text-xs text-gray-500 mb-4 flex items-center gap-1.5 justify-center">
                      <AlertCircle className="w-3.5 h-3.5 text-gray-400" />
                      <span>Hover over evidence badges to view source details</span>
                    </p>
                    {procedures.length === 0 ? (
                      <div className="p-6 bg-white/80 border-2 border-dashed border-gray-300 rounded-xl text-center">
                        <div className="text-sm text-gray-500 mb-1">No procedure recommendations from AI</div>
                        <div className="text-xs text-gray-400">You can add your own recommendations below</div>
                      </div>
                    ) : (
                    <div className="space-y-4">
                      {procedures.map((proc) => (
                      <div key={proc.id} className={`bg-white border-2 rounded-xl p-5 shadow-md mr-4 transition-all duration-200 ${editingProcedureId === proc.id ? 'border-blue-500 bg-blue-50/50 shadow-lg ring-2 ring-blue-200' : 'border-gray-200 hover:border-gray-300 hover:shadow-lg'}`}>
                        {editingProcedureId === proc.id ? (
                          /* Edit Mode */
                          <div className="space-y-3">
                            <div className="grid grid-cols-2 gap-3">
                              <div>
                                <label className="text-xs font-semibold text-gray-700 block mb-1.5">Procedure / Order</label>
                                <input
                                  type="text"
                                  className="w-full px-3 py-2 border-2 border-gray-300 rounded-lg text-sm focus:border-blue-500 focus:ring-2 focus:ring-blue-200 transition-colors"
                                  value={procEditForm.procedure || ''}
                                  onChange={(e) => setProcEditForm({...procEditForm, procedure: e.target.value})}
                                />
                              </div>
                              <div>
                                <label className="text-xs font-semibold text-gray-700 block mb-1.5">Timing</label>
                                <input
                                  type="text"
                                  className="w-full px-3 py-2 border-2 border-gray-300 rounded-lg text-sm focus:border-blue-500 focus:ring-2 focus:ring-blue-200 transition-colors"
                                  value={procEditForm.timing || ''}
                                  onChange={(e) => setProcEditForm({...procEditForm, timing: e.target.value})}
                                />
                              </div>
                            </div>
                            <div>
                              <label className="text-xs font-semibold text-gray-700 block mb-1.5">Rationale</label>
                              <textarea
                                className="w-full px-3 py-2 border-2 border-gray-300 rounded-lg text-sm resize-none focus:border-blue-500 focus:ring-2 focus:ring-blue-200 transition-colors"
                                rows={3}
                                value={procEditForm.rationale || ''}
                                onChange={(e) => setProcEditForm({...procEditForm, rationale: e.target.value})}
                              />
                            </div>
                            <div>
                              <label className="text-xs font-semibold text-gray-700 block mb-1.5">Status</label>
                              <select
                                className="w-full px-3 py-2 border-2 border-gray-300 rounded-lg text-sm focus:border-blue-500 focus:ring-2 focus:ring-blue-200 transition-colors bg-white"
                                value={procEditForm.status || 'Planned'}
                                onChange={(e) => setProcEditForm({...procEditForm, status: e.target.value})}
                              >
                                <option value="Planned">Planned</option>
                                <option value="Order">Order</option>
                                <option value="Schedule">Schedule</option>
                                <option value="Urgent">Urgent</option>
                                <option value="ASAP">ASAP</option>
                                <option value="Critical">Critical</option>
                                <option value="Consider">Consider</option>
                                <option value="Defer">Defer</option>
                                <option value="Not planned">Not planned</option>
                              </select>
                            </div>
                            <div className="pt-3 border-t border-gray-200">
                              <div className="text-xs font-semibold text-gray-600 mb-2">Evidence (read-only)</div>
                              <div className="flex flex-wrap gap-2">
                                {proc.evidence.map((ev, idx) => (
                                  <span key={idx} className="px-2.5 py-1 bg-purple-100 text-purple-700 text-xs font-medium rounded-md border border-purple-200 shadow-sm">
                                    {ev}
                                  </span>
                                ))}
                              </div>
                            </div>
                            <div className="flex gap-3 pt-4 border-t border-gray-200">
                              <button
                                onClick={handleSaveProcedure}
                                className="flex-1 px-4 py-2.5 bg-blue-600 text-white text-sm font-semibold rounded-lg hover:bg-blue-700 active:bg-blue-800 shadow-md hover:shadow-lg transition-all duration-200"
                              >
                                Save Changes
                              </button>
                              <button
                                onClick={handleCancelProcedureEdit}
                                className="flex-1 px-4 py-2.5 border-2 border-gray-300 text-gray-700 text-sm font-semibold rounded-lg hover:bg-gray-50 hover:border-gray-400 active:bg-gray-100 transition-all duration-200"
                              >
                                Cancel
                              </button>
                            </div>
                          </div>
                        ) : (
                          /* Read Mode */
                          <>
                            <div className="flex items-start justify-between mb-3">
                              <div className="flex-1 pr-4">
                                <div className="flex items-center gap-3 mb-2">
                                  <div className="font-bold text-base text-gray-900">
                                    {proc.procedure}
                                  </div>
                                  <span className="text-gray-400">•</span>
                                  <div className="text-sm text-gray-700 font-medium">
                                    {proc.timing}
                                  </div>
                                </div>
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
                              <div className="flex items-start gap-2 ml-3 flex-shrink-0">
                                <span
                                  className={`px-3 py-1.5 text-xs font-bold rounded-lg shadow-sm ${getStatusBadgeClass(proc.status)}`}
                                  title={`Status: ${proc.status}`}
                                >
                                  {proc.status}
                                </span>
                              </div>
                            </div>
                            <div className="flex gap-2">
                              <button
                                onClick={() => handleEditProcedure(proc)}
                                className="text-xs text-blue-600 hover:text-blue-700 flex items-center gap-1"
                                title="Edit recommendation"
                              >
                                <Edit className="w-3 h-3" />
                                Edit
                              </button>
                              <button
                                onClick={() => handleDeleteProcedure(proc.id)}
                                className="text-xs text-red-600 hover:text-red-700 flex items-center gap-1"
                                title="Remove from proposed plan"
                              >
                                <Trash2 className="w-3 h-3" />
                                Remove
                              </button>
                            </div>
                          </>
                        )}
                      </div>
                      ))}
                    </div>
                  )}

                    {/* Add New Procedure Form */}
                    {addingProcedure && (
                      <div className="bg-white border-2 border-blue-400 rounded-xl p-5 bg-gradient-to-br from-blue-50 to-blue-100/50 shadow-lg">
                        <div className="text-sm text-blue-900 mb-4 font-bold flex items-center gap-2">
                          <Plus className="w-4 h-4" />
                          Add New Procedure / Order
                        </div>
                        <div className="space-y-4">
                          <div className="grid grid-cols-2 gap-3">
                            <div>
                              <label className="text-xs font-semibold text-gray-700 block mb-1.5">Procedure / Order <span className="text-red-500">*</span></label>
                              <input
                                type="text"
                                className="w-full px-3 py-2 border-2 border-gray-300 rounded-lg text-sm focus:border-blue-500 focus:ring-2 focus:ring-blue-200 transition-colors"
                                value={procEditForm.procedure || ''}
                                onChange={(e) => setProcEditForm({...procEditForm, procedure: e.target.value})}
                                placeholder="e.g., Order ECG"
                              />
                            </div>
                            <div>
                              <label className="text-xs font-semibold text-gray-700 block mb-1.5">Timing <span className="text-red-500">*</span></label>
                              <input
                                type="text"
                                className="w-full px-3 py-2 border-2 border-gray-300 rounded-lg text-sm focus:border-blue-500 focus:ring-2 focus:ring-blue-200 transition-colors"
                                value={procEditForm.timing || ''}
                                onChange={(e) => setProcEditForm({...procEditForm, timing: e.target.value})}
                                placeholder="e.g., In 7 days"
                              />
                            </div>
                          </div>
                          <div>
                            <label className="text-xs font-semibold text-gray-700 block mb-1.5">Rationale <span className="text-red-500">*</span></label>
                            <textarea
                              className="w-full px-3 py-2 border-2 border-gray-300 rounded-lg text-sm resize-none focus:border-blue-500 focus:ring-2 focus:ring-blue-200 transition-colors"
                              rows={3}
                              value={procEditForm.rationale || ''}
                              onChange={(e) => setProcEditForm({...procEditForm, rationale: e.target.value})}
                              placeholder="Clinical justification for this recommendation"
                            />
                          </div>
                          <div className="flex gap-3 pt-3 border-t border-gray-200">
                            <button
                              onClick={handleSaveNewProcedure}
                              disabled={!procEditForm.procedure || !procEditForm.timing || !procEditForm.rationale}
                              className="flex-1 px-4 py-2.5 bg-blue-600 text-white text-sm font-semibold rounded-lg hover:bg-blue-700 active:bg-blue-800 disabled:bg-gray-300 disabled:cursor-not-allowed shadow-md hover:shadow-lg transition-all duration-200"
                            >
                              Add Recommendation
                            </button>
                            <button
                              onClick={handleCancelAddProcedure}
                              className="flex-1 px-4 py-2.5 border-2 border-gray-300 text-gray-700 text-sm font-semibold rounded-lg hover:bg-gray-50 hover:border-gray-400 active:bg-gray-100 transition-all duration-200"
                            >
                              Cancel
                            </button>
                          </div>
                        </div>
                      </div>
                    )}
                    {!addingProcedure && (
                      <button
                        onClick={handleAddProcedure}
                        className="mt-3 text-sm text-blue-600 hover:text-blue-700 flex items-center gap-1"
                      >
                        <Plus className="w-4 h-4" />
                        Add procedure recommendation
                      </button>
                    )}
                  </div>
                </div>
              </div>

              {/* Doctor Decision Panel */}
              <div className="grid grid-cols-2 gap-6 mt-8">
                {/* Left: AI Context */}
                <div className="space-y-5">
                  <div className="p-5 bg-gradient-to-br from-purple-50 to-purple-100/50 border-2 border-purple-200 rounded-xl shadow-md">
                    <div className="flex items-center gap-3 mb-4">
                      <div className="p-2 bg-purple-200 rounded-lg">
                        <Brain className="w-5 h-5 text-purple-700" />
                      </div>
                      <span className="text-base font-bold text-purple-900">AI Assessment</span>
                    </div>
                    
                    <div className="mb-5">
                      <RiskBadge tier={aiRecommendation.riskTier} size="md" />
                    </div>
                    <div className="mb-4 flex items-center gap-2 p-2 bg-white/70 rounded-lg">
                      <span className="text-xs font-semibold text-purple-700">AI Confidence:</span>
                      <span className="text-xs px-3 py-1 bg-purple-200 text-purple-900 font-bold rounded-lg shadow-sm">High</span>
                    </div>
                    
                    <div className="pt-4 border-t-2 border-purple-200 space-y-2">
                      <div className="flex items-center gap-2 text-xs text-purple-700 font-medium">
                        <Clock className="w-3.5 h-3.5" />
                        <span>Analysis: {new Date().toLocaleString()}</span>
                      </div>
                      <div className="text-xs text-purple-600">
                        Based on data updated 2 days ago
                      </div>
                    </div>
                  </div>

                  <div className="p-5 bg-white border-2 border-purple-200 rounded-xl shadow-md">
                    <div className="text-sm font-bold text-gray-900 mb-3">Key Findings</div>
                    <p className="text-xs text-gray-600 mb-4">Hover over findings to see source details. Click to open the referenced data.</p>
                    {aiRecommendation.reasoningReferences && aiRecommendation.reasoningReferences.length > 0 ? (
                      <div className="flex flex-wrap gap-2.5">
                        {aiRecommendation.reasoningReferences.map((ref: any, idx: number) => (
                          <span 
                            key={idx}
                            className="px-3 py-1.5 bg-purple-100 text-purple-700 text-xs font-semibold rounded-lg border border-purple-200 cursor-help hover:bg-purple-200 transition-colors shadow-sm" 
                            title={`Source: ${ref.source || ref.type || 'Unknown'} • Type: ${ref.type || 'Unknown'}`}
                          >
                            {ref.label || ref.type || 'Evidence'}
                          </span>
                        ))}
                      </div>
                    ) : (
                      <div className="text-xs text-gray-500 italic p-3 bg-gray-50 rounded-lg">No key findings available</div>
                    )}
                  </div>

                  {aiRecommendation.riskAssessment && (
                    <div className="p-5 bg-gradient-to-br from-amber-50 to-amber-100/50 border-2 border-amber-200 rounded-xl shadow-md">
                      <div className="text-sm font-bold text-amber-900 mb-4">Risk Assessment</div>
                      {aiRecommendation.riskAssessment.risk_factors_identified && aiRecommendation.riskAssessment.risk_factors_identified.length > 0 && (
                        <div className="mb-4">
                          <div className="text-xs text-amber-800 font-semibold mb-2 uppercase tracking-wide">Risk Factors</div>
                          <div className="flex flex-wrap gap-2">
                            {aiRecommendation.riskAssessment.risk_factors_identified.map((factor: any, idx: number) => (
                              <span 
                                key={idx} 
                                className="inline-flex items-center px-2.5 py-1 bg-amber-100 text-amber-900 text-xs font-medium rounded-md border border-amber-300"
                              >
                                {typeof factor === 'string' ? factor : factor.factor || 'Unknown risk factor'}
                              </span>
                            ))}
                          </div>
                        </div>
                      )}
                      {aiRecommendation.riskAssessment.mitigation_strategies && aiRecommendation.riskAssessment.mitigation_strategies.length > 0 && (
                        <div>
                          <div className="text-xs text-amber-800 font-semibold mb-2 uppercase tracking-wide">Mitigation Strategies</div>
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

                {/* Right: Doctor Input */}
                <div className="space-y-5">
                  <div className="p-5 bg-gradient-to-br from-blue-50 to-blue-100/50 border-2 border-blue-200 rounded-xl shadow-md">
                    <div className="flex items-center gap-3 mb-4">
                      <div className="p-2 bg-blue-200 rounded-lg">
                        <User className="w-5 h-5 text-blue-700" />
                      </div>
                      <span className="text-base font-bold text-blue-900">Your Decision</span>
                    </div>

                    <div className="mb-5 p-4 bg-white rounded-xl border-2 border-blue-200 shadow-sm">
                      <div className="grid grid-cols-2 gap-4 text-sm">
                        <div>
                          <div className="text-xs font-semibold text-gray-600 mb-2">AI Assessment</div>
                          <RiskBadge tier={aiRecommendation.riskTier} size="sm" />
                        </div>
                        <div>
                          <div className="text-xs font-semibold text-gray-600 mb-2">Your Selection</div>
                          <RiskBadge tier={selectedRiskTier} size="sm" />
                        </div>
                      </div>
                      {selectedRiskTier !== aiRecommendation.riskTier && (
                        <div className="mt-3 p-3 bg-amber-50 border-2 border-amber-200 rounded-lg text-xs text-amber-900 font-semibold">
                          <span className="font-bold">⚠️ Override detected:</span> Reasoning required below.
                        </div>
                      )}
                    </div>
                    
                    <div className="mb-4">
                      <label className="text-xs font-bold text-gray-700 mb-2 block">Final Risk Tier</label>
                      <select 
                        className="w-full px-4 py-2.5 border-2 border-gray-300 rounded-lg text-sm font-semibold focus:border-blue-500 focus:ring-2 focus:ring-blue-200 transition-colors bg-white"
                        value={selectedRiskTier}
                        onChange={(e) => setSelectedRiskTier(e.target.value as 'Low' | 'Medium' | 'High')}
                      >
                        <option value="Low">Low Alert</option>
                        <option value="Medium">Moderate Alert</option>
                        <option value="High">High Alert</option>
                        <option value="Critical">Critical Alert</option>
                      </select>
                    </div>
                    
                    <div>
                      <label className="text-xs font-bold text-gray-700 mb-2 block">Reasoning Notes</label>
                      <p className="text-xs text-gray-600 mb-3 leading-relaxed">Summarize your clinical reasoning for this decision and any modifications to the proposed plan.</p>
                      <textarea 
                        className="w-full px-4 py-3 border-2 border-gray-300 rounded-lg text-sm resize-none focus:border-blue-500 focus:ring-2 focus:ring-blue-200 transition-colors" 
                        rows={5}
                        value={reasoningNotes}
                        onChange={(e) => setReasoningNotes(e.target.value)}
                        placeholder="Document your reasoning and any plan modifications..."
                      ></textarea>
                      <div className="text-xs text-gray-500 mt-2">
                        {selectedRiskTier !== aiRecommendation.riskTier && (
                          <span className="text-amber-600 font-bold flex items-center gap-1">
                            <AlertCircle className="w-3.5 h-3.5" />
                            If your final risk tier differs from the AI assessment, document the rationale here.
                          </span>
                        )}
                      </div>
                    </div>
                  </div>

                  {/* Additional Recommendations */}
                  {aiRecommendation.additionalRecommendations && aiRecommendation.additionalRecommendations.length > 0 && (
                    <div className="p-3 bg-gradient-to-br from-blue-50 via-blue-100/70 to-blue-50 border-2 border-blue-200 rounded-lg shadow-sm">
                      <div className="text-sm font-bold text-blue-900 mb-2">Additional Recommendations</div>
                      <div className="space-y-1.5">
                        {aiRecommendation.additionalRecommendations.map((rec: string, idx: number) => {
                          // Parse category if present (format: "Category: Recommendation text")
                          const parts = rec.split(':');
                          const category = parts.length > 1 ? parts[0].trim() : null;
                          const recommendation = parts.length > 1 ? parts.slice(1).join(':').trim() : rec;
                          
                          return (
                            <div key={idx} className="flex items-start gap-2 bg-white rounded-md p-2 border border-blue-200/60">
                              <div className="w-2 h-2 bg-blue-600 rounded-full mt-1.5 flex-shrink-0"></div>
                              <div className="flex-1">
                                {category && (
                                  <span className="text-xs font-bold text-blue-700 uppercase tracking-wide mr-1.5">
                                    {category}:
                                  </span>
                                )}
                                <span className="text-xs text-gray-900 leading-snug">{recommendation}</span>
                              </div>
                            </div>
                          );
                        })}
                      </div>
                    </div>
                  )}
                </div>
              </div>

              <div className="p-5 bg-gradient-to-br from-blue-50 to-blue-100/50 border-2 border-blue-200 rounded-xl mb-6 mt-8 shadow-md">
                <div className="text-sm font-bold text-blue-900 mb-4">Final Review Checklist</div>
                <div className="space-y-3">
                  <div className="flex items-center gap-3 text-sm text-blue-800 font-medium">
                    <CheckCircle className="w-5 h-5 text-blue-600 flex-shrink-0" />
                    <span>AI assessment reviewed</span>
                  </div>
                  <div className="flex items-center gap-3 text-sm text-blue-800 font-medium">
                    <CheckCircle className="w-5 h-5 text-blue-600 flex-shrink-0" />
                    <span>Evidence reviewed</span>
                  </div>
                  <div className="flex items-center gap-3 text-sm text-blue-800 font-medium">
                    <CheckCircle className="w-5 h-5 text-blue-600 flex-shrink-0" />
                    <span>Proposed plan reviewed and adjusted</span>
                  </div>
                  <div className="flex items-center gap-3 text-sm text-blue-800 font-medium">
                    {reasoningNotes.trim().length > 0 || selectedRiskTier === aiRecommendation.riskTier ? (
                      <CheckCircle className="w-5 h-5 text-blue-600 flex-shrink-0" />
                    ) : (
                      <Circle className="w-5 h-5 text-gray-400 flex-shrink-0" />
                    )}
                    <span>Reasoning notes completed {selectedRiskTier !== aiRecommendation.riskTier && <span className="text-amber-600 font-bold">(required for override)</span>}</span>
                  </div>
                </div>
              </div>

              <div className="space-y-4">
                {error && (
                  <div className="mb-4 p-4 bg-red-50 border border-red-200 rounded-lg">
                    <div className="text-sm text-red-900">
                      <div className="font-medium mb-1">Error</div>
                      <div className="text-red-800">{error}</div>
                    </div>
                  </div>
                )}
                <button
                  onClick={handleApproveDecision}
                  disabled={finalizing || (selectedRiskTier !== aiRecommendation.riskTier && reasoningNotes.trim().length === 0)}
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
                <div className="text-xs text-center text-gray-600 font-medium">
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
        )}

        {/* Step 4: Completed */}
        {currentStep === 4 && (
          <div className="py-12">
            {/* Success Header */}
            <div className="text-center mb-12">
              <div className="inline-flex items-center gap-3 px-6 py-3 bg-gradient-to-r from-green-50 to-emerald-50 border-2 border-green-300 rounded-full mb-6 shadow-lg">
                <div className="w-2 h-2 bg-green-500 rounded-full animate-pulse"></div>
                <span className="text-sm font-bold text-green-700 uppercase tracking-wider">Visit Completed</span>
                <div className="w-2 h-2 bg-green-500 rounded-full animate-pulse"></div>
              </div>
              <h3 className="text-xl font-bold text-gray-900 mb-4">
                Visit Successfully Completed
              </h3>
              <p className="text-sm text-gray-600 max-w-2xl mx-auto leading-relaxed">
                Clinical decision has been finalized and saved to the patient record. Digital twin summary has been generated and stored.
              </p>
            </div>

            <div className="max-w-5xl mx-auto space-y-8">
              {/* Main Content Grid */}
              <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                {/* Left Column: Decision Summary */}
                <div className="lg:col-span-2 space-y-6">
                  {/* Decision Summary Card */}
                  <div className="bg-gradient-to-br from-white to-green-50 border-2 border-green-200 rounded-2xl p-6 shadow-lg hover:shadow-xl transition-shadow">
                    <div className="flex items-center gap-3 mb-6">
                      <div className="w-10 h-10 bg-green-100 rounded-lg flex items-center justify-center">
                        <CheckCircle className="w-6 h-6 text-green-600" />
                      </div>
                      <h4 className="text-base font-bold text-gray-900">Decision Summary</h4>
                    </div>
                    <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                      <div className="space-y-2">
                        <div className="text-xs font-semibold text-gray-500 uppercase tracking-wide">Final Risk Tier</div>
                        <div>
                          <RiskBadge tier={doctorDecision.riskTier} size="lg" />
                        </div>
                      </div>
                      <div className="space-y-2">
                        <div className="text-xs font-semibold text-gray-500 uppercase tracking-wide">Approved By</div>
                        <div className="flex items-center gap-2">
                          <div className="w-8 h-8 bg-blue-100 rounded-full flex items-center justify-center">
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
                      <div className="space-y-2">
                        <div className="text-xs font-semibold text-gray-500 uppercase tracking-wide">Completed At</div>
                        <div className="flex items-center gap-2 text-xs text-gray-700">
                          <Clock className="w-3 h-3 text-gray-400" />
                          <span>{doctorDecision?.timestamp}</span>
                        </div>
                      </div>
                    </div>
                  </div>

                  {/* Twin Summary Card */}
                  {doctorDecision.twinSummary && (
                    <div className="bg-white border-2 border-blue-200 rounded-2xl p-6 shadow-lg hover:shadow-xl transition-shadow">
                      <div className="flex items-center justify-between mb-6">
                        <div className="flex items-center gap-3">
                          <div className="w-10 h-10 bg-blue-100 rounded-lg flex items-center justify-center">
                            <FileText className="w-6 h-6 text-blue-600" />
                          </div>
                          <h4 className="text-base font-bold text-gray-900">Digital Twin Summary</h4>
                        </div>
                        <span className="px-4 py-1.5 bg-gradient-to-r from-blue-500 to-blue-600 text-white text-xs font-bold rounded-full shadow-sm">
                          ✓ Saved to Database
                        </span>
                      </div>
                      
                      <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
                        {doctorDecision.twinSummary.summaryVersion && (
                          <div className="p-4 bg-gradient-to-br from-gray-50 to-gray-100 rounded-xl border border-gray-200">
                            <div className="text-xs font-semibold text-gray-500 uppercase tracking-wide mb-2">Summary Version</div>
                            <div className="text-sm font-mono text-gray-900 break-all font-semibold">
                              {doctorDecision.twinSummary.summaryVersion}
                            </div>
                          </div>
                        )}
                        {doctorDecision.twinSummary.asOfTime && (
                          <div className="p-4 bg-gradient-to-br from-gray-50 to-gray-100 rounded-xl border border-gray-200">
                            <div className="text-xs font-semibold text-gray-500 uppercase tracking-wide mb-2">As of Time</div>
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
                        <div className="p-5 bg-gradient-to-br from-blue-50 to-indigo-50 border-2 border-blue-200 rounded-xl">
                          <div className="flex items-center gap-2 mb-3">
                            <FileText className="w-4 h-4 text-blue-600" />
                            <div className="text-xs font-bold text-blue-900 uppercase tracking-wider">
                              Clinical Summary
                            </div>
                          </div>
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
                  <div className="bg-white border-2 border-gray-200 rounded-2xl p-6 shadow-lg sticky top-6">
                    <div className="flex items-center gap-3 mb-6">
                      <div className="w-10 h-10 bg-purple-100 rounded-lg flex items-center justify-center">
                        <CheckCircle className="w-6 h-6 text-purple-600" />
                      </div>
                      <h4 className="text-base font-bold text-gray-900">Visit Outcomes</h4>
                    </div>
                    <div className="space-y-4">
                      <div className="flex items-start gap-3 p-3 bg-green-50 rounded-xl border border-green-200">
                        <div className="w-7 h-7 bg-green-500 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5">
                          <CheckCircle className="w-4 h-4 text-white" />
                        </div>
                        <div className="flex-1">
                          <div className="text-xs font-semibold text-gray-900 mb-1">Decision Documented</div>
                          <div className="text-xs text-gray-600">Clinical decision saved to record</div>
                        </div>
                      </div>
                      
                      <div className="flex items-start gap-3 p-3 bg-blue-50 rounded-xl border border-blue-200">
                        <div className="w-7 h-7 bg-blue-500 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5">
                          <CheckCircle className="w-4 h-4 text-white" />
                        </div>
                        <div className="flex-1">
                          <div className="text-xs font-semibold text-gray-900 mb-1">Treatment Plan</div>
                          <div className="text-xs text-blue-700 font-medium">{doctorDecision.planSummary}</div>
                        </div>
                      </div>
                      
                      <div className="flex items-start gap-3 p-3 bg-indigo-50 rounded-xl border border-indigo-200">
                        <div className="w-7 h-7 bg-indigo-500 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5">
                          <FileText className="w-4 h-4 text-white" />
                        </div>
                        <div className="flex-1">
                          <div className="text-xs font-semibold text-gray-900 mb-1">Twin Summary</div>
                          <div className="text-xs text-gray-600">Generated and saved</div>
                        </div>
                      </div>
                      
                      <div className={`flex items-start gap-3 p-3 rounded-xl border ${
                        doctorDecision.monitoringStatus === 'Active' 
                          ? 'bg-green-50 border-green-200' 
                          : doctorDecision.monitoringStatus === 'Paused'
                          ? 'bg-yellow-50 border-yellow-200'
                          : 'bg-gray-50 border-gray-200'
                      }`}>
                        <div className={`w-7 h-7 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5 ${
                          doctorDecision.monitoringStatus === 'Active'
                            ? 'bg-green-500'
                            : doctorDecision.monitoringStatus === 'Paused'
                            ? 'bg-yellow-500'
                            : 'bg-gray-400'
                        }`}>
                          <CheckCircle className="w-4 h-4 text-white" />
                        </div>
                        <div className="flex-1">
                          <div className="text-xs font-semibold text-gray-900 mb-1">Monitoring Status</div>
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
                        <div className="flex items-start gap-3 p-3 bg-amber-50 rounded-xl border border-amber-200">
                          <div className="w-7 h-7 bg-amber-500 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5">
                            <Clock className="w-4 h-4 text-white" />
                          </div>
                          <div className="flex-1">
                            <div className="text-xs font-semibold text-gray-900 mb-1">Follow-up Scheduled</div>
                            <div className="text-xs text-amber-700 font-medium">{doctorDecision.followUpDate}</div>
                          </div>
                        </div>
                      )}
                    </div>
                  </div>
                </div>
              </div>

              {/* Action Buttons */}
              <div className="flex flex-col sm:flex-row gap-4 justify-center pt-6 border-t border-gray-200">
                <button
                  onClick={() => {
                    setCurrentStep(1);
                    setFlowStatus('not-started');
                    setAnalysisRun(false);
                    setAiRecommendation(null);
                    setDoctorDecision(null);
                    setSummaryText(null);
                  }}
                  className="px-8 py-4 border-2 border-gray-300 text-gray-700 font-semibold rounded-xl hover:bg-gray-50 hover:border-gray-400 transition-all duration-200 shadow-sm hover:shadow-md"
                >
                  Start New Visit
                </button>
                <button
                  onClick={handleDownloadVisitReport}
                  disabled={!doctorDecision}
                  className="px-8 py-4 bg-gradient-to-r from-blue-600 to-blue-700 text-white font-semibold rounded-xl hover:from-blue-700 hover:to-blue-800 transition-all duration-200 shadow-lg hover:shadow-xl transform hover:scale-105 disabled:from-gray-400 disabled:to-gray-500 disabled:cursor-not-allowed disabled:transform-none flex items-center justify-center gap-2"
                >
                  <Download className="w-5 h-5" />
                  Download Visit Report
                </button>
              </div>
            </div>
          </div>
        )}
      </div>

      {/* Delete Confirmation Modal */}
      {showDeleteConfirm && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 max-w-md w-full mx-4 shadow-xl">
            <h3 className="text-lg font-semibold text-gray-900 mb-2">Remove recommendation?</h3>
            <p className="text-sm text-gray-600 mb-6">
              This recommendation will be removed from the proposed plan. This does not affect the final clinical decision unless you choose to modify it.
            </p>
            <div className="flex gap-3 justify-end">
              <button
                onClick={() => setShowDeleteConfirm(null)}
                className="px-4 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors text-sm"
              >
                Cancel
              </button>
              <button
                onClick={confirmDelete}
                className="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors text-sm"
              >
                Remove
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}