import { useState } from 'react';
import { CheckCircle, AlertCircle, Save, FileCheck } from 'lucide-react';
import { Patient, RiskTier } from '../App';
import { RiskBadge } from './RiskBadge';

interface DoctorReviewProps {
  patient: Patient;
}

export function DoctorReview({ patient }: DoctorReviewProps) {
  const [acceptAI, setAcceptAI] = useState(false);
  const [finalRiskTier, setFinalRiskTier] = useState<RiskTier>(patient.riskTier);
  const [careRecommendation, setCareRecommendation] = useState('');
  const [doctorNotes, setDoctorNotes] = useState('');
  const [status, setStatus] = useState<'editing' | 'draft' | 'approved'>('editing');
  const [showConfirmModal, setShowConfirmModal] = useState(false);

  const handleSaveDraft = () => {
    setStatus('draft');
    setTimeout(() => setStatus('editing'), 2000);
  };

  const handleApprove = () => {
    setShowConfirmModal(true);
  };

  const confirmApproval = () => {
    setStatus('approved');
    setShowConfirmModal(false);
  };

  return (
    <div className="p-8">
      <div className="mb-6">
        <h1 className="text-2xl font-semibold text-gray-900 mb-2">Doctor Review & Validation</h1>
        <p className="text-gray-600">Human-in-the-loop clinical decision making</p>
      </div>

      {status === 'approved' && (
        <div className="mb-6 p-4 bg-green-50 border border-green-200 rounded-lg flex items-center gap-3">
          <CheckCircle className="w-5 h-5 text-green-600" />
          <div className="text-sm text-green-900">
            <span className="font-medium">Decision Approved & Saved</span> - This recommendation has been finalized and added to the patient record.
          </div>
        </div>
      )}

      {status === 'draft' && (
        <div className="mb-6 p-4 bg-blue-50 border border-blue-200 rounded-lg flex items-center gap-3">
          <Save className="w-5 h-5 text-blue-600" />
          <div className="text-sm text-blue-900">
            <span className="font-medium">Draft Saved</span> - You can continue editing or approve when ready.
          </div>
        </div>
      )}

      <div className="grid grid-cols-2 gap-6">
        {/* Left Panel - AI Recommendation (Read-only) */}
        <div>
          <div className="bg-purple-50 border border-purple-200 rounded-lg p-4 mb-4">
            <div className="flex items-center gap-2 mb-2">
              <div className="px-2 py-1 bg-purple-600 text-white text-xs font-medium rounded">
                AI SUGGESTION
              </div>
              <span className="text-xs text-purple-700">Read-only reference</span>
            </div>
          </div>

          <div className="bg-gray-50 rounded-lg border border-gray-300 p-6 pointer-events-none">
            <h3 className="font-semibold text-gray-900 mb-4">AI Recommendation</h3>
            
            <div className="mb-4">
              <div className="text-sm text-gray-500 mb-2">AI Suggested Risk Tier</div>
              <RiskBadge tier={patient.riskTier} size="lg" />
            </div>

            <div className="mb-4">
              <div className="text-sm text-gray-500 mb-2">AI Reasoning</div>
              <ul className="space-y-2">
                {patient.riskTier === 'High' && (
                  <>
                    <li className="flex items-start gap-2 text-sm text-gray-700">
                      <AlertCircle className="w-4 h-4 text-red-500 mt-0.5 flex-shrink-0" />
                      <span>Multiple high-risk comorbidities detected</span>
                    </li>
                    <li className="flex items-start gap-2 text-sm text-gray-700">
                      <AlertCircle className="w-4 h-4 text-red-500 mt-0.5 flex-shrink-0" />
                      <span>Elevated blood pressure above target</span>
                    </li>
                    <li className="flex items-start gap-2 text-sm text-gray-700">
                      <AlertCircle className="w-4 h-4 text-red-500 mt-0.5 flex-shrink-0" />
                      <span>Medication interaction risk identified</span>
                    </li>
                  </>
                )}
                {patient.riskTier === 'Medium' && (
                  <>
                    <li className="flex items-start gap-2 text-sm text-gray-700">
                      <AlertCircle className="w-4 h-4 text-amber-500 mt-0.5 flex-shrink-0" />
                      <span>Stable conditions under treatment</span>
                    </li>
                    <li className="flex items-start gap-2 text-sm text-gray-700">
                      <AlertCircle className="w-4 h-4 text-amber-500 mt-0.5 flex-shrink-0" />
                      <span>Minor vital fluctuations noted</span>
                    </li>
                  </>
                )}
                {patient.riskTier === 'Low' && (
                  <>
                    <li className="flex items-start gap-2 text-sm text-gray-700">
                      <CheckCircle className="w-4 h-4 text-green-500 mt-0.5 flex-shrink-0" />
                      <span>All vitals within normal range</span>
                    </li>
                    <li className="flex items-start gap-2 text-sm text-gray-700">
                      <CheckCircle className="w-4 h-4 text-green-500 mt-0.5 flex-shrink-0" />
                      <span>Good medication adherence</span>
                    </li>
                  </>
                )}
              </ul>
            </div>

            <div>
              <div className="text-sm text-gray-500 mb-2">AI Care Recommendation</div>
              <div className="text-sm text-gray-700 bg-white p-3 rounded border border-gray-200">
                {patient.riskTier === 'High' 
                  ? 'Immediate clinical review recommended. Consider medication adjustment and schedule follow-up within 1 week. Monitor vitals daily.'
                  : patient.riskTier === 'Medium'
                  ? 'Continue current treatment plan. Schedule follow-up in 2-4 weeks. Monitor for any symptom changes.'
                  : 'Continue current management. Routine follow-up in 3 months. Maintain current medication regimen.'}
              </div>
            </div>
          </div>
        </div>

        {/* Right Panel - Doctor Input (Editable) */}
        <div>
          <div className="bg-blue-50 border border-blue-200 rounded-lg p-4 mb-4">
            <div className="flex items-center gap-2 mb-2">
              <div className="px-2 py-1 bg-blue-600 text-white text-xs font-medium rounded">
                DOCTOR DECISION
              </div>
              <span className="text-xs text-blue-700">Your clinical judgment</span>
            </div>
          </div>

          <div className="bg-white rounded-lg border-2 border-blue-300 p-6">
            <h3 className="font-semibold text-gray-900 mb-4">Your Clinical Decision</h3>
            
            {/* Accept AI Toggle */}
            <div className="mb-6 p-4 bg-gray-50 rounded-lg border border-gray-200">
              <label className="flex items-start gap-3 cursor-pointer">
                <input
                  type="checkbox"
                  checked={acceptAI}
                  onChange={(e) => {
                    setAcceptAI(e.target.checked);
                    if (e.target.checked) {
                      setFinalRiskTier(patient.riskTier);
                    }
                  }}
                  className="mt-1 w-4 h-4 text-blue-600 rounded focus:ring-2 focus:ring-blue-500"
                  disabled={status === 'approved'}
                />
                <div>
                  <div className="text-sm font-medium text-gray-900">Accept AI recommendation as-is</div>
                  <div className="text-xs text-gray-600 mt-1">
                    Check this box if you agree with the AI analysis without modifications
                  </div>
                </div>
              </label>
            </div>

            {/* Final Risk Tier */}
            <div className="mb-4">
              <label className="text-sm font-medium text-gray-700 mb-2 block">
                Final Risk Tier <span className="text-red-500">*</span>
              </label>
              <select
                value={finalRiskTier}
                onChange={(e) => {
                  setFinalRiskTier(e.target.value as RiskTier);
                  setAcceptAI(false);
                }}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                disabled={acceptAI || status === 'approved'}
              >
                <option value="Low">Low Alert</option>
                <option value="Medium">Moderate Alert</option>
                <option value="High">High Alert</option>
                <option value="Critical">Critical Alert</option>
              </select>
              <div className="mt-2">
                <RiskBadge tier={finalRiskTier} size="md" />
              </div>
            </div>

            {/* Care Recommendation */}
            <div className="mb-4">
              <label className="text-sm font-medium text-gray-700 mb-2 block">
                Care Recommendation <span className="text-red-500">*</span>
              </label>
              <textarea
                value={careRecommendation}
                onChange={(e) => setCareRecommendation(e.target.value)}
                placeholder="Enter your clinical care plan and recommendations..."
                rows={4}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 resize-none"
                disabled={status === 'approved'}
              />
            </div>

            {/* Doctor Notes */}
            <div className="mb-6">
              <label className="text-sm font-medium text-gray-700 mb-2 block">
                Doctor Notes / Clinical Rationale
              </label>
              <textarea
                value={doctorNotes}
                onChange={(e) => setDoctorNotes(e.target.value)}
                placeholder="Document your clinical reasoning, any deviations from AI recommendation, or additional context..."
                rows={5}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 resize-none"
                disabled={status === 'approved'}
              />
              <div className="text-xs text-gray-500 mt-1">
                This will be included in the audit log
              </div>
            </div>

            {/* Action Buttons */}
            {status !== 'approved' && (
              <div className="flex gap-3">
                <button
                  onClick={handleSaveDraft}
                  className="flex-1 px-4 py-3 border border-gray-300 text-gray-700 font-medium rounded-lg hover:bg-gray-50 transition-colors flex items-center justify-center gap-2"
                >
                  <Save className="w-4 h-4" />
                  Save as Draft
                </button>
                <button
                  onClick={handleApprove}
                  className="flex-1 px-4 py-3 bg-green-600 text-white font-medium rounded-lg hover:bg-green-700 transition-colors flex items-center justify-center gap-2"
                >
                  <FileCheck className="w-4 h-4" />
                  Approve & Save Decision
                </button>
              </div>
            )}

            {status === 'approved' && (
              <div className="p-3 bg-green-50 border border-green-200 rounded-lg flex items-center gap-2 text-sm text-green-900">
                <CheckCircle className="w-4 h-4" />
                Decision approved on Jan 8, 2026 at 11:15 AM by Dr. Rebecca Smith
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Status Indicator */}
      <div className="mt-6 p-4 bg-gray-50 border border-gray-200 rounded-lg">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="text-sm text-gray-600">Decision Status:</div>
            <div>
              {status === 'editing' && (
                <span className="px-3 py-1 bg-gray-200 text-gray-700 text-sm font-medium rounded-full">
                  Draft / In Progress
                </span>
              )}
              {status === 'draft' && (
                <span className="px-3 py-1 bg-blue-100 text-blue-700 text-sm font-medium rounded-full">
                  Saved as Draft
                </span>
              )}
              {status === 'approved' && (
                <span className="px-3 py-1 bg-green-100 text-green-700 text-sm font-medium rounded-full">
                  ✓ Approved & Finalized
                </span>
              )}
            </div>
          </div>
          <div className="text-xs text-gray-500">
            Last modified: Just now
          </div>
        </div>
      </div>

      {/* Confirmation Modal */}
      {showConfirmModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 max-w-md w-full mx-4">
            <h3 className="font-semibold text-gray-900 mb-2">Confirm Clinical Decision</h3>
            <p className="text-sm text-gray-600 mb-4">
              You are about to finalize this clinical decision. Once approved, it will be added to the patient's 
              permanent record and audit log. This action cannot be undone.
            </p>
            <div className="mb-4 p-3 bg-amber-50 border border-amber-200 rounded text-sm text-amber-900">
              <strong>Risk Tier:</strong> {finalRiskTier}
            </div>
            <div className="flex gap-3">
              <button
                onClick={() => setShowConfirmModal(false)}
                className="flex-1 px-4 py-2 border border-gray-300 text-gray-700 font-medium rounded-lg hover:bg-gray-50"
              >
                Cancel
              </button>
              <button
                onClick={confirmApproval}
                className="flex-1 px-4 py-2 bg-green-600 text-white font-medium rounded-lg hover:bg-green-700"
              >
                Confirm & Approve
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
