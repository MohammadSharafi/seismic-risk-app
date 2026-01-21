import { Activity, Calendar, Clock } from 'lucide-react';
import { Patient } from '../App';
import { RiskBadge } from './RiskBadge';

interface PatientOverviewProps {
  patient: Patient;
  onRunAnalysis: () => void;
}

export function PatientOverview({ patient, onRunAnalysis }: PatientOverviewProps) {
  return (
    <div className="p-8">
      <div className="mb-6">
        <h1 className="text-2xl font-semibold text-gray-900 mb-2">Patient Digital Twin Overview</h1>
        <p className="text-gray-600">High-level snapshot of current patient state</p>
      </div>

      {/* Current Status Card */}
      <div className="bg-white rounded-lg border border-gray-200 p-6 mb-6">
        <h2 className="font-semibold text-gray-900 mb-4">Current Status</h2>
        
        <div className="grid grid-cols-3 gap-6">
          <div>
            <div className="text-sm text-gray-500 mb-2">Current Risk Tier</div>
            <RiskBadge tier={patient.riskTier} size="lg" />
          </div>
          
          <div>
            <div className="text-sm text-gray-500 mb-2">Last Updated</div>
            <div className="flex items-center gap-2 text-gray-900">
              <Calendar className="w-4 h-4 text-gray-400" />
              <span>{patient.lastEvaluation}</span>
            </div>
          </div>
          
          <div>
            <div className="text-sm text-gray-500 mb-2">Data Freshness</div>
            <div className="flex items-center gap-2">
              <div className="flex items-center gap-1.5">
                <div className="w-2 h-2 bg-green-500 rounded-full animate-pulse"></div>
                <span className="text-sm text-gray-900">Current</span>
              </div>
              <span className="text-xs text-gray-500">(Updated today)</span>
            </div>
          </div>
        </div>
      </div>

      {/* Clinical Summary */}
      <div className="bg-white rounded-lg border border-gray-200 p-6 mb-6">
        <h2 className="font-semibold text-gray-900 mb-4">Clinical Summary</h2>
        
        <div className="space-y-4">
          {/* Key Conditions */}
          <div>
            <div className="text-sm font-medium text-gray-700 mb-2">Key Conditions</div>
            <div className="flex flex-wrap gap-2">
              {patient.conditions.map((condition, idx) => (
                <span key={idx} className="px-3 py-1.5 bg-purple-50 text-purple-900 text-sm rounded border border-purple-100">
                  {condition}
                </span>
              ))}
            </div>
          </div>

          {/* Current Medications */}
          <div>
            <div className="text-sm font-medium text-gray-700 mb-2">Current Medications</div>
            <div className="grid grid-cols-2 gap-2">
              {patient.medications.map((med, idx) => (
                <div key={idx} className="flex items-center gap-2 text-sm text-gray-700">
                  <div className="w-1.5 h-1.5 bg-blue-500 rounded-full"></div>
                  {med}
                </div>
              ))}
            </div>
          </div>

          {/* Latest Vitals */}
          {patient.vitals && (
            <div>
              <div className="text-sm font-medium text-gray-700 mb-3">Latest Vitals</div>
              <div className="grid grid-cols-3 gap-4">
                <div className="p-3 bg-gray-50 rounded">
                  <div className="flex items-center gap-2 mb-1">
                    <Activity className="w-4 h-4 text-gray-400" />
                    <span className="text-xs text-gray-500">Blood Pressure</span>
                  </div>
                  <div className="font-medium text-gray-900">{patient.vitals.bloodPressure}</div>
                  <div className="text-xs text-gray-500 mt-0.5">mmHg</div>
                </div>
                
                <div className="p-3 bg-gray-50 rounded">
                  <div className="flex items-center gap-2 mb-1">
                    <Activity className="w-4 h-4 text-gray-400" />
                    <span className="text-xs text-gray-500">Heart Rate</span>
                  </div>
                  <div className="font-medium text-gray-900">{patient.vitals.heartRate}</div>
                  <div className="text-xs text-gray-500 mt-0.5">bpm</div>
                </div>
                
                <div className="p-3 bg-gray-50 rounded">
                  <div className="flex items-center gap-2 mb-1">
                    <Activity className="w-4 h-4 text-gray-400" />
                    <span className="text-xs text-gray-500">Temperature</span>
                  </div>
                  <div className="font-medium text-gray-900">{patient.vitals.temperature}</div>
                </div>
              </div>
            </div>
          )}
        </div>
      </div>

      {/* Action Button */}
      <div className="bg-gradient-to-r from-blue-50 to-indigo-50 rounded-lg border border-blue-200 p-6">
        <div className="flex items-center justify-between">
          <div>
            <h3 className="font-semibold text-gray-900 mb-1">AI-Powered Clinical Analysis</h3>
            <p className="text-sm text-gray-600">Generate intelligent recommendations based on current patient data</p>
          </div>
          <button
            onClick={onRunAnalysis}
            className="px-6 py-3 bg-blue-600 text-white font-medium rounded-lg hover:bg-blue-700 transition-colors flex items-center gap-2"
          >
            <Clock className="w-5 h-5" />
            Run New Analysis
          </button>
        </div>
      </div>
    </div>
  );
}
