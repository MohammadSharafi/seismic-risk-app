import { Brain, FileText, TrendingUp, AlertCircle, ExternalLink } from 'lucide-react';
import { Patient } from '../App';
import { RiskBadge } from './RiskBadge';

interface AIAnalysisProps {
  patient: Patient;
  onReview: () => void;
}

export function AIAnalysis({ patient, onReview }: AIAnalysisProps) {
  return (
    <div className="p-8">
      <div className="mb-6">
        <div className="flex items-center gap-2 mb-2">
          <Brain className="w-6 h-6 text-blue-600" />
          <h1 className="text-2xl font-semibold text-gray-900">AI Analysis & Recommendations</h1>
        </div>
        <p className="text-gray-600">AI-generated clinical insights require physician validation</p>
      </div>

      {/* AI Label Badge */}
      <div className="mb-6 inline-flex items-center gap-2 px-4 py-2 bg-purple-50 border border-purple-200 rounded-lg">
        <Brain className="w-4 h-4 text-purple-600" />
        <span className="text-sm font-medium text-purple-900">AI Suggestion</span>
        <span className="text-xs text-purple-700">Requires clinical validation</span>
      </div>

      {/* Analysis Context */}
      <div className="bg-white rounded-lg border border-gray-200 p-6 mb-6">
        <h2 className="font-semibold text-gray-900 mb-4">Analysis Context</h2>
        
        <div className="grid grid-cols-3 gap-6">
          <div>
            <div className="text-sm text-gray-500 mb-1">Analysis Timestamp</div>
            <div className="text-gray-900">Jan 8, 2026 10:45 AM</div>
          </div>
          
          <div>
            <div className="text-sm text-gray-500 mb-1">Data Sources Used</div>
            <div className="text-gray-900">EHR, Lab Results, Vitals Monitor</div>
          </div>
          
          <div>
            <div className="text-sm text-gray-500 mb-1">AI Model Version</div>
            <div className="text-gray-900">ClinicalAI v3.2.1</div>
          </div>
        </div>
      </div>

      {/* AI Recommendation Card */}
      <div className="bg-white rounded-lg border-2 border-blue-200 p-6 mb-6">
        <div className="flex items-start justify-between mb-4">
          <h2 className="font-semibold text-gray-900">AI Recommendation</h2>
          <div className="px-3 py-1 bg-purple-100 text-purple-700 text-xs font-medium rounded-full">
            AI-Generated
          </div>
        </div>
        
        {/* Risk Tier */}
        <div className="mb-6">
          <div className="text-sm text-gray-500 mb-2">Recommended Risk Tier</div>
          <RiskBadge tier={patient.riskTier} size="lg" />
        </div>

        {/* Structured Reasons */}
        <div className="mb-6">
          <div className="text-sm font-medium text-gray-700 mb-3">Clinical Reasoning</div>
          <ul className="space-y-2">
            {patient.riskTier === 'High' && (
              <>
                <li className="flex items-start gap-2 text-sm text-gray-700">
                  <AlertCircle className="w-4 h-4 text-red-500 mt-0.5 flex-shrink-0" />
                  <span>Multiple high-risk comorbidities detected: {patient.conditions.slice(0, 2).join(', ')}</span>
                </li>
                <li className="flex items-start gap-2 text-sm text-gray-700">
                  <AlertCircle className="w-4 h-4 text-red-500 mt-0.5 flex-shrink-0" />
                  <span>Irregular vitals pattern: Blood pressure elevated above target range</span>
                </li>
                <li className="flex items-start gap-2 text-sm text-gray-700">
                  <AlertCircle className="w-4 h-4 text-red-500 mt-0.5 flex-shrink-0" />
                  <span>Medication interaction risk identified between current prescriptions</span>
                </li>
                <li className="flex items-start gap-2 text-sm text-gray-700">
                  <AlertCircle className="w-4 h-4 text-red-500 mt-0.5 flex-shrink-0" />
                  <span>Historical trend shows progression in condition severity over 6 months</span>
                </li>
              </>
            )}
            {patient.riskTier === 'Medium' && (
              <>
                <li className="flex items-start gap-2 text-sm text-gray-700">
                  <TrendingUp className="w-4 h-4 text-amber-500 mt-0.5 flex-shrink-0" />
                  <span>Stable comorbidities under current treatment regimen</span>
                </li>
                <li className="flex items-start gap-2 text-sm text-gray-700">
                  <TrendingUp className="w-4 h-4 text-amber-500 mt-0.5 flex-shrink-0" />
                  <span>Vitals within acceptable range but showing minor fluctuations</span>
                </li>
                <li className="flex items-start gap-2 text-sm text-gray-700">
                  <TrendingUp className="w-4 h-4 text-amber-500 mt-0.5 flex-shrink-0" />
                  <span>Recent lab results indicate need for closer monitoring</span>
                </li>
              </>
            )}
            {patient.riskTier === 'Low' && (
              <>
                <li className="flex items-start gap-2 text-sm text-gray-700">
                  <TrendingUp className="w-4 h-4 text-green-500 mt-0.5 flex-shrink-0" />
                  <span>All vitals within normal range and stable over past 30 days</span>
                </li>
                <li className="flex items-start gap-2 text-sm text-gray-700">
                  <TrendingUp className="w-4 h-4 text-green-500 mt-0.5 flex-shrink-0" />
                  <span>Medication adherence confirmed, no adverse effects reported</span>
                </li>
                <li className="flex items-start gap-2 text-sm text-gray-700">
                  <TrendingUp className="w-4 h-4 text-green-500 mt-0.5 flex-shrink-0" />
                  <span>Recent follow-up shows positive treatment response</span>
                </li>
              </>
            )}
          </ul>
        </div>

        {/* Evidence Section */}
        <div className="border-t border-gray-200 pt-4">
          <div className="text-sm font-medium text-gray-700 mb-3">Supporting Evidence</div>
          <div className="space-y-2">
            <div className="flex items-center justify-between p-3 bg-gray-50 rounded">
              <div className="flex items-center gap-3">
                <FileText className="w-4 h-4 text-gray-400" />
                <div>
                  <div className="text-sm text-gray-900">Last Visit Data</div>
                  <div className="text-xs text-gray-500">{patient.lastEvaluation} - Comprehensive assessment</div>
                </div>
              </div>
              <button className="text-blue-600 hover:text-blue-700 text-sm flex items-center gap-1">
                View <ExternalLink className="w-3 h-3" />
              </button>
            </div>

            {patient.vitals && (
              <div className="flex items-center justify-between p-3 bg-gray-50 rounded">
                <div className="flex items-center gap-3">
                  <FileText className="w-4 h-4 text-gray-400" />
                  <div>
                    <div className="text-sm text-gray-900">Latest Vitals</div>
                    <div className="text-xs text-gray-500">BP: {patient.vitals.bloodPressure}, HR: {patient.vitals.heartRate}</div>
                  </div>
                </div>
                <button className="text-blue-600 hover:text-blue-700 text-sm flex items-center gap-1">
                  View <ExternalLink className="w-3 h-3" />
                </button>
              </div>
            )}

            <div className="flex items-center justify-between p-3 bg-gray-50 rounded">
              <div className="flex items-center gap-3">
                <FileText className="w-4 h-4 text-gray-400" />
                <div>
                  <div className="text-sm text-gray-900">Medication Review</div>
                  <div className="text-xs text-gray-500">{patient.medications.length} active prescriptions</div>
                </div>
              </div>
              <button className="text-blue-600 hover:text-blue-700 text-sm flex items-center gap-1">
                View <ExternalLink className="w-3 h-3" />
              </button>
            </div>
          </div>
        </div>
      </div>

      {/* Explainability Panel */}
      <div className="bg-blue-50 rounded-lg border border-blue-200 p-6 mb-6">
        <div className="flex items-start gap-3">
          <div className="w-10 h-10 bg-blue-100 rounded-full flex items-center justify-center flex-shrink-0">
            <Brain className="w-5 h-5 text-blue-600" />
          </div>
          <div className="flex-1">
            <h3 className="font-semibold text-gray-900 mb-2">AI Reasoning Explanation</h3>
            <p className="text-sm text-gray-700 mb-3">
              The AI model analyzed {patient.conditions.length} documented conditions, {patient.medications.length} current medications, 
              and vital signs trends over the past 30 days. Key risk factors were weighted based on clinical guidelines and 
              historical patient outcomes in similar cohorts.
            </p>
            <div className="text-sm text-gray-700">
              <span className="font-medium">Primary factors considered:</span>
              <ul className="mt-2 space-y-1 ml-4">
                <li className="flex items-center gap-2">
                  <div className="w-1 h-1 bg-blue-500 rounded-full"></div>
                  Disease severity scores (NYHA, CHA2DS2-VASc)
                </li>
                <li className="flex items-center gap-2">
                  <div className="w-1 h-1 bg-blue-500 rounded-full"></div>
                  Medication compliance patterns
                </li>
                <li className="flex items-center gap-2">
                  <div className="w-1 h-1 bg-blue-500 rounded-full"></div>
                  Recent lab value trends (creatinine, HbA1c, BNP)
                </li>
                <li className="flex items-center gap-2">
                  <div className="w-1 h-1 bg-blue-500 rounded-full"></div>
                  Hospitalization risk prediction model
                </li>
              </ul>
            </div>
          </div>
        </div>
      </div>

      {/* Action Button */}
      <div className="flex justify-end gap-3">
        <button className="px-6 py-3 border border-gray-300 text-gray-700 font-medium rounded-lg hover:bg-gray-50 transition-colors">
          Request Additional Data
        </button>
        <button
          onClick={onReview}
          className="px-6 py-3 bg-blue-600 text-white font-medium rounded-lg hover:bg-blue-700 transition-colors"
        >
          Proceed to Clinical Review
        </button>
      </div>
    </div>
  );
}
