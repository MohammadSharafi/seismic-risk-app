import { Shield, Lock, FileText, Brain, User, ChevronLeft } from 'lucide-react';
import { Patient } from '../App';

interface AuditEntry {
  id: string;
  timestamp: string;
  type: 'AI Output' | 'Doctor Edit' | 'Final Decision' | 'Background Evaluation';
  actor: string;
  modelVersion?: string;
  riskTier: 'Low' | 'Medium' | 'High';
  action: string;
  details: string;
  linkedReferences?: {
    type: 'visit' | 'analysis' | 'decision';
    label: string;
  }[];
  evaluationId?: string;
}

interface DecisionHistoryProps {
  patient: Patient;
  onBack: () => void;
}

export function DecisionHistory({ patient, onBack }: DecisionHistoryProps) {
  // Audit log will be fetched from API later
  const auditLog: AuditEntry[] = [];
  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white border-b border-gray-200 sticky top-0 z-10">
        <div className="px-8 py-6">
          <button
            onClick={onBack}
            className="text-sm text-blue-600 hover:text-blue-700 mb-4 flex items-center gap-1"
          >
            <ChevronLeft className="w-4 h-4" />
            Back to Patient Overview
          </button>
          <div className="flex items-start justify-between">
            <div>
              <h1 className="text-2xl font-semibold text-gray-900 mb-2">Clinical Audit Log</h1>
              <p className="text-gray-600">
                Immutable, read-only record of all AI outputs, doctor actions, and clinical decisions for compliance and transparency.
              </p>
            </div>
            <div className="text-right">
              <div className="text-sm text-gray-500 mb-1">Patient</div>
              <div className="font-semibold text-gray-900">{patient.name}</div>
              <div className="text-sm text-gray-600">{patient.twinId}</div>
            </div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="p-8 max-w-6xl mx-auto">
        {/* Audit Info Banner */}
        <div className="bg-blue-50 border border-blue-200 rounded-lg p-4 mb-6 flex items-start gap-3">
          <Shield className="w-5 h-5 text-blue-600 mt-0.5 flex-shrink-0" />
          <div className="text-sm text-blue-900">
            <div className="font-medium mb-1">Immutable Audit Trail</div>
            <div className="text-blue-800">
              All entries are read-only and permanently stored for compliance, quality assurance, and medico-legal purposes. 
              Each action is timestamped and attributed to the responsible party.
            </div>
          </div>
        </div>

        {/* Audit Statistics */}
        <div className="grid grid-cols-4 gap-4 mb-6">
          <div className="bg-white border border-gray-200 rounded-lg p-4">
            <div className="text-sm text-gray-500 mb-1">Total Entries</div>
            <div className="text-2xl font-semibold text-gray-900">{auditLog.length}</div>
          </div>
          
          <div className="bg-white border border-gray-200 rounded-lg p-4">
            <div className="text-sm text-gray-500 mb-1">AI Outputs</div>
            <div className="text-2xl font-semibold text-purple-600">
              {auditLog.filter(e => e.type === 'AI Output' || e.type === 'Background Evaluation').length}
            </div>
          </div>
          
          <div className="bg-white border border-gray-200 rounded-lg p-4">
            <div className="text-sm text-gray-500 mb-1">Doctor Edits</div>
            <div className="text-2xl font-semibold text-blue-600">
              {auditLog.filter(e => e.type === 'Doctor Edit').length}
            </div>
          </div>

          <div className="bg-white border border-gray-200 rounded-lg p-4">
            <div className="text-sm text-gray-500 mb-1">Final Decisions</div>
            <div className="text-2xl font-semibold text-green-600">
              {auditLog.filter(e => e.type === 'Final Decision').length}
            </div>
          </div>
        </div>

        {/* Audit Log Timeline */}
        <div className="bg-white rounded-lg border border-gray-200">
          <div className="px-6 py-4 border-b border-gray-200 bg-gray-50">
            <div className="flex items-center justify-between">
              <h2 className="font-semibold text-gray-900">Chronological Audit Log</h2>
              <div className="flex items-center gap-2 text-sm text-gray-600">
                <Lock className="w-4 h-4" />
                <span>Read-only</span>
              </div>
            </div>
          </div>

          <div className="divide-y divide-gray-200">
            {auditLog.map((entry, index) => (
              <div key={entry.id} className="p-6 hover:bg-gray-50 transition-colors">
                <div className="flex gap-4">
                  {/* Timeline Indicator */}
                  <div className="flex flex-col items-center">
                    <div className={`w-10 h-10 rounded-full flex items-center justify-center flex-shrink-0 ${
                      entry.type === 'AI Output' || entry.type === 'Background Evaluation' ? 'bg-purple-100' :
                      entry.type === 'Doctor Edit' ? 'bg-blue-100' :
                      'bg-green-100'
                    }`}>
                      {(entry.type === 'AI Output' || entry.type === 'Background Evaluation') && <Brain className="w-5 h-5 text-purple-600" />}
                      {entry.type === 'Doctor Edit' && <FileText className="w-5 h-5 text-blue-600" />}
                      {entry.type === 'Final Decision' && <User className="w-5 h-5 text-green-600" />}
                    </div>
                    {index < auditLog.length - 1 && (
                      <div className="w-0.5 flex-1 min-h-[40px] bg-gray-200 mt-2"></div>
                    )}
                  </div>

                  {/* Entry Content */}
                  <div className="flex-1">
                    <div className="flex items-start justify-between mb-2">
                      <div>
                        <div className="flex items-center gap-3 mb-1">
                          <span className={`px-2 py-1 text-xs font-medium rounded ${
                            entry.type === 'AI Output' ? 'bg-purple-100 text-purple-700' :
                            entry.type === 'Background Evaluation' ? 'bg-purple-100 text-purple-700' :
                            entry.type === 'Doctor Edit' ? 'bg-blue-100 text-blue-700' :
                            'bg-green-100 text-green-700'
                          }`}>
                            {entry.type}
                          </span>
                          <span className="font-medium text-gray-900">{entry.action}</span>
                        </div>
                        <div className="text-sm text-gray-600">
                          {entry.actor}
                          {entry.modelVersion && <span className="ml-2 text-gray-500">• {entry.modelVersion}</span>}
                        </div>
                      </div>
                      <div className="text-sm text-gray-500 flex items-center gap-1.5">
                        <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                        </svg>
                        {entry.timestamp}
                      </div>
                    </div>

                    <div className="bg-gray-50 rounded p-3 mb-3">
                      <div className="text-sm text-gray-700">{entry.details}</div>
                    </div>

                    <div className="flex items-center gap-4 mb-3">
                      <div className="flex items-center gap-2">
                        <span className="text-xs text-gray-500">Risk Tier:</span>
                        <span className={`px-2 py-0.5 text-xs font-medium rounded ${
                          entry.riskTier === 'High' ? 'bg-red-100 text-red-700' :
                          entry.riskTier === 'Medium' ? 'bg-amber-100 text-amber-700' :
                          'bg-green-100 text-green-700'
                        }`}>
                          {entry.riskTier}
                        </span>
                      </div>
                      {entry.evaluationId && (
                        <div className="flex items-center gap-2">
                          <span className="text-xs text-gray-500">Evaluation ID:</span>
                          <span className="text-xs font-mono text-gray-700">{entry.evaluationId}</span>
                        </div>
                      )}
                    </div>

                    {entry.linkedReferences && entry.linkedReferences.length > 0 && (
                      <div className="flex flex-wrap gap-2">
                        {entry.linkedReferences.map((ref, idx) => (
                          <button
                            key={idx}
                            className="text-xs text-blue-600 hover:text-blue-700 flex items-center gap-1 px-2 py-1 bg-blue-50 rounded hover:bg-blue-100 transition-colors"
                          >
                            <span className={`px-1.5 py-0.5 rounded text-xs font-medium ${
                              ref.type === 'visit' ? 'bg-blue-200 text-blue-800' :
                              ref.type === 'analysis' ? 'bg-purple-200 text-purple-800' :
                              'bg-green-200 text-green-800'
                            }`}>
                              {ref.type}
                            </span>
                            {ref.label}
                          </button>
                        ))}
                      </div>
                    )}
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Compliance Notice */}
        <div className="mt-6 p-4 bg-gray-50 border border-gray-200 rounded-lg">
          <div className="flex items-start gap-2 text-sm text-gray-700">
            <Lock className="w-4 h-4 mt-0.5 flex-shrink-0 text-gray-500" />
            <div>
              <span className="font-medium">Compliance & Data Integrity:</span> This audit log is maintained in accordance with 
              HIPAA, 21 CFR Part 11, and institutional clinical documentation requirements. All entries are cryptographically 
              signed and tamper-evident.
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}
