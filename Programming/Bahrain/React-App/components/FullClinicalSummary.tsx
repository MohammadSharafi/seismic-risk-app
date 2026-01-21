import { ArrowLeft, Calendar, AlertCircle, Pill, Activity, FileText, Clock } from 'lucide-react';
import { Patient } from '../App';
import { RiskBadge } from './RiskBadge';

interface FullClinicalSummaryProps {
  patient: Patient;
  onBack: () => void;
}

interface DetailedCondition {
  name: string;
  status: 'Active' | 'Resolved';
  severity?: string;
  onsetDate: string;
  source?: string;
}

interface DetailedMedication {
  name: string;
  dose: string;
  frequency: string;
  startDate: string;
  status: 'Active' | 'Stopped';
  prescribingSource: string;
  endDate?: string;
}

interface VitalReading {
  type: string;
  value: string;
  unit: string;
  dateTime: string;
  status: 'Normal' | 'Elevated' | 'Critical';
}

interface ClinicalNote {
  content: string;
  timestamp: string;
  author: string;
  visitType: string;
}

export function FullClinicalSummary({ patient, onBack }: FullClinicalSummaryProps) {
  // Use detailed conditions from BigQuery
  const allConditions: DetailedCondition[] = patient.detailedConditions && patient.detailedConditions.length > 0
    ? patient.detailedConditions.map((cond: any) => {
        const clinicalStatus = cond.clinical_status?.toLowerCase() || '';
        // DRAFT status should be treated as historical/resolved
        const status = clinicalStatus.includes('draft') 
          ? 'Resolved'
          : (clinicalStatus.includes('active') || clinicalStatus.includes('confirmed') ? 'Active' : 'Resolved');
        const onsetDate = cond.onset_date 
          ? new Date(cond.onset_date).toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric' })
          : cond.recorded_date 
            ? new Date(cond.recorded_date).toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric' })
            : 'Unknown';
        const severityText = cond.severity 
          ? `${cond.severity}${cond.verification_status ? ` (${cond.verification_status})` : ''}`
          : cond.verification_status || '';
        return {
          name: cond.condition_name || 'Unknown Condition',
          status: status as 'Active' | 'Resolved',
          severity: severityText,
          onsetDate: onsetDate,
          source: cond.source || undefined
        };
      })
    : [];

  // Separate active and historical conditions
  const conditions = allConditions.filter(c => c.status === 'Active');
  const historicalConditions = allConditions.filter(c => c.status === 'Resolved');

  // Use detailed medications from BigQuery
  const allMedications: DetailedMedication[] = patient.detailedMedications && patient.detailedMedications.length > 0
    ? patient.detailedMedications.map((med: any) => {
        const medicationStatus = med.medication_status?.toLowerCase() || '';
        // DRAFT status should be treated as historical/stopped
        const status = medicationStatus.includes('draft')
          ? 'Stopped'
          : (medicationStatus.includes('active') || medicationStatus.includes('in-progress') ? 'Active' : 'Stopped');
        const startDate = med.start_date
          ? new Date(med.start_date).toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric' })
          : med.authored_on_date
            ? new Date(med.authored_on_date).toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric' })
            : 'Unknown';
        const endDateStr = med.end_date
          ? new Date(med.end_date).toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric' })
          : undefined;
        const frequency = med.frequency_text 
          ? med.frequency_text.replace(/_/g, ' ').toLowerCase()
          : 'unknown';
        return {
          name: med.medication_name || 'Unknown Medication',
          dose: med.dose_text || 'Unknown',
          frequency: frequency,
          startDate: startDate,
          status: status as 'Active' | 'Stopped',
          prescribingSource: med.prescribing_practitioner || 'Unknown',
          endDate: endDateStr
        };
      })
    : [];

  // Separate current and historical medications (DRAFT items go to historical)
  // Current: Active medications with no end_date OR with future end_date
  const currentMedications = allMedications.filter(med => 
    med.status === 'Active' && (!med.endDate || (med.endDate && new Date(med.endDate) >= new Date()))
  );
  // Historical: Stopped medications OR Active medications with past end_date
  const historicalMedications = allMedications.filter(med => 
    med.status === 'Stopped' || (med.endDate && new Date(med.endDate) < new Date())
  );

  // Vitals trend data - populate from patient vitals
  const vitalsTrend: VitalReading[] = patient.vitals ? [
    // Blood Pressure
    {
      type: 'Blood Pressure',
      value: patient.vitals.bloodPressure || 'N/A',
      unit: 'mmHg',
      dateTime: 'Latest',
      status: (() => {
        const bp = patient.vitals.bloodPressure;
        if (!bp || bp === 'N/A') return 'Normal';
        // Parse BP (format: "120/80" or "120/80 mmHg")
        const match = bp.toString().match(/(\d+)\/(\d+)/);
        if (match) {
          const systolic = parseInt(match[1]);
          const diastolic = parseInt(match[2]);
          if (systolic >= 140 || diastolic >= 90) return 'Critical';
          if (systolic >= 130 || diastolic >= 80) return 'Elevated';
        }
        return 'Normal';
      })() as 'Normal' | 'Elevated' | 'Critical',
    },
    // Heart Rate
    {
      type: 'Heart Rate',
      value: patient.vitals.heartRate || 'N/A',
      unit: 'bpm',
      dateTime: 'Latest',
      status: (() => {
        const hr = patient.vitals.heartRate;
        if (!hr || hr === 'N/A') return 'Normal';
        const hrNum = parseInt(hr.toString().replace(/[^\d]/g, ''));
        if (hrNum >= 100 || hrNum < 60) return 'Elevated';
        return 'Normal';
      })() as 'Normal' | 'Elevated' | 'Critical',
    },
    // Temperature
    {
      type: 'Temperature',
      value: patient.vitals.temperature || 'N/A',
      unit: '°F',
      dateTime: 'Latest',
      status: (() => {
        const temp = patient.vitals.temperature;
        if (!temp || temp === 'N/A') return 'Normal';
        const tempNum = parseFloat(temp.toString().replace(/[^\d.]/g, ''));
        if (tempNum >= 100.4) return 'Elevated';
        if (tempNum < 97) return 'Elevated';
        return 'Normal';
      })() as 'Normal' | 'Elevated' | 'Critical',
    },
  ] : [];
  
  // Helper function to get status for latest readings
  const getBloodPressureStatus = () => {
    const bp = patient.vitals?.bloodPressure;
    if (!bp || bp === 'N/A') return { status: 'Normal', color: 'green' };
    const match = bp.toString().match(/(\d+)\/(\d+)/);
    if (match) {
      const systolic = parseInt(match[1]);
      const diastolic = parseInt(match[2]);
      if (systolic >= 140 || diastolic >= 90) return { status: 'Critical', color: 'red' };
      if (systolic >= 130 || diastolic >= 80) return { status: 'Elevated', color: 'amber' };
    }
    return { status: 'Normal', color: 'green' };
  };
  
  const getHeartRateStatus = () => {
    const hr = patient.vitals?.heartRate;
    if (!hr || hr === 'N/A') return { status: 'Normal', color: 'green' };
    const hrNum = parseInt(hr.toString().replace(/[^\d]/g, ''));
    if (hrNum >= 100 || hrNum < 60) return { status: 'Elevated', color: 'amber' };
    return { status: 'Normal', color: 'green' };
  };
  
  const getTemperatureStatus = () => {
    const temp = patient.vitals?.temperature;
    if (!temp || temp === 'N/A') return { status: 'Normal', color: 'green' };
    const tempNum = parseFloat(temp.toString().replace(/[^\d.]/g, ''));
    if (tempNum >= 100.4 || tempNum < 97) return { status: 'Elevated', color: 'amber' };
    return { status: 'Normal', color: 'green' };
  };
  
  const bpStatus = getBloodPressureStatus();
  const hrStatus = getHeartRateStatus();
  const tempStatus = getTemperatureStatus();

  // Clinical notes - will be fetched from encounters/API later
  const clinicalNotes: ClinicalNote[] = [];

  // Get last updated time from clinical summary or use current time
  const lastUpdated = patient.clinicalSummary?.created_at 
    ? new Date(patient.clinicalSummary.created_at).toLocaleString('en-US', {
        year: 'numeric',
        month: 'numeric',
        day: 'numeric',
        hour: 'numeric',
        minute: '2-digit',
        second: '2-digit'
      })
    : new Date().toLocaleString('en-US', {
        year: 'numeric',
        month: 'numeric',
        day: 'numeric',
        hour: 'numeric',
        minute: '2-digit',
        second: '2-digit'
      });

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Sticky Header */}
      <div className="sticky top-0 z-10 bg-white border-b border-gray-200 shadow-sm">
        <div className="max-w-7xl mx-auto px-6 py-4">
          <div className="flex items-center justify-between mb-3">
            <button
              onClick={onBack}
              className="flex items-center gap-2 text-gray-600 hover:text-gray-900 transition-colors"
            >
              <ArrowLeft className="w-5 h-5" />
              <span className="text-sm font-medium">Back to Patient Overview</span>
            </button>
            <span className="px-3 py-1 bg-blue-50 text-blue-700 text-xs font-medium rounded-full border border-blue-200">
              Clinical Summary (Read-only)
            </span>
          </div>
          
          <div className="flex items-start justify-between">
            <div>
              <h1 className="text-2xl font-semibold text-gray-900 mb-1">
                {patient.name}
              </h1>
              <div className="flex items-center gap-4 text-sm text-gray-600">
                <span>{patient.age} years old</span>
                <span>•</span>
                <span>{patient.id}</span>
              </div>
            </div>
            <div className="text-right">
              <RiskBadge tier={patient.riskTier} size="lg" />
              <div className="flex items-center gap-1 text-xs text-gray-500 mt-2">
                <Clock className="w-3 h-3" />
                <span>Last updated: {lastUpdated}</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Main Content */}
      <div className="max-w-7xl mx-auto px-6 py-8">
        {/* Conditions Section */}
        <section className="mb-8">
          <div className="bg-white rounded-lg border border-gray-200 overflow-hidden">
            <div className="px-6 py-4 bg-purple-50 border-b border-purple-100">
              <div className="flex items-center gap-2">
                <AlertCircle className="w-5 h-5 text-purple-600" />
                <h2 className="text-lg font-semibold text-gray-900">Conditions</h2>
              </div>
            </div>
            <div className="p-6">
              <div className="space-y-4">
                {allConditions.length === 0 ? (
                  <p className="text-sm text-gray-500">No conditions found.</p>
                ) : (
                  allConditions.map((condition, idx) => (
                    <div 
                      key={idx} 
                      className={`p-4 rounded-lg border ${
                        condition.status === 'Active' 
                          ? 'bg-purple-50 border-purple-200' 
                          : 'bg-gray-50 border-gray-200'
                      }`}
                    >
                      <div className="flex items-start justify-between mb-3">
                        <div className="flex-1">
                          <div className={`font-medium mb-1 ${condition.status === 'Active' ? 'text-gray-900' : 'text-gray-700'}`}>
                            {condition.name}
                          </div>
                          {condition.severity && (
                            <div className="text-sm text-gray-600">{condition.severity}</div>
                          )}
                        </div>
                        <span className={`px-3 py-1 rounded-full text-xs font-medium ${
                          condition.status === 'Active' 
                            ? 'bg-green-100 text-green-700' 
                            : 'bg-gray-200 text-gray-600'
                        }`}>
                          {condition.status}
                        </span>
                      </div>
                      <div className={`grid gap-4 text-sm ${condition.source ? 'grid-cols-2' : 'grid-cols-1'}`}>
                        <div>
                          <span className="text-gray-500">Onset:</span>
                          <span className="ml-2 text-gray-900">{condition.onsetDate}</span>
                        </div>
                        {condition.source && (
                          <div>
                            <span className="text-gray-500">Source:</span>
                            <span className="ml-2 text-gray-900">{condition.source}</span>
                          </div>
                        )}
                      </div>
                    </div>
                  ))
                )}
              </div>
            </div>
          </div>
        </section>

        {/* Medications Section */}
        <section className="mb-8">
          <div className="bg-white rounded-lg border border-gray-200 overflow-hidden">
            <div className="px-6 py-4 bg-blue-50 border-b border-blue-100">
              <div className="flex items-center gap-2">
                <Pill className="w-5 h-5 text-blue-600" />
                <h2 className="text-lg font-semibold text-gray-900">Medications</h2>
              </div>
            </div>
            <div className="p-6">
              {/* Current Medications */}
              <div className="mb-6">
                <h3 className="text-sm font-semibold text-gray-700 mb-3 uppercase tracking-wide">
                  Current Medications
                </h3>
                {currentMedications.length === 0 ? (
                  <p className="text-sm text-gray-500">No active medications found.</p>
                ) : (
                  <div className="space-y-3">
                    {currentMedications.map((med, idx) => (
                    <div key={idx} className="p-4 bg-blue-50 border border-blue-200 rounded-lg">
                      <div className="flex items-start justify-between mb-3">
                        <div className="flex-1">
                          <div className="font-medium text-gray-900 mb-1">{med.name}</div>
                          <div className="text-sm text-gray-600">
                            {med.dose} {med.frequency}
                          </div>
                        </div>
                        <span className="px-3 py-1 bg-green-100 text-green-700 rounded-full text-xs font-medium">
                          {med.status}
                        </span>
                      </div>
                      <div className="grid grid-cols-2 gap-4 text-sm">
                        <div>
                          <span className="text-gray-500">Started:</span>
                          <span className="ml-2 text-gray-900">{med.startDate}</span>
                        </div>
                        <div>
                          <span className="text-gray-500">Prescribed by:</span>
                          <span className="ml-2 text-gray-900">{med.prescribingSource}</span>
                        </div>
                      </div>
                    </div>
                    ))}
                  </div>
                )}
              </div>

              {/* Historical Medications */}
              <div>
                <h3 className="text-sm font-semibold text-gray-700 mb-3 uppercase tracking-wide">
                  Historical Medications
                </h3>
                {historicalMedications.length === 0 ? (
                  <p className="text-sm text-gray-500">No historical medications found.</p>
                ) : (
                  <div className="space-y-3">
                    {historicalMedications.map((med, idx) => (
                    <div key={idx} className="p-4 bg-gray-50 border border-gray-200 rounded-lg">
                      <div className="flex items-start justify-between mb-3">
                        <div className="flex-1">
                          <div className="font-medium text-gray-700 mb-1">{med.name}</div>
                          <div className="text-sm text-gray-600">
                            {med.dose} {med.frequency}
                          </div>
                        </div>
                        <span className="px-3 py-1 bg-gray-200 text-gray-600 rounded-full text-xs font-medium">
                          {med.status}
                        </span>
                      </div>
                      <div className="grid grid-cols-3 gap-4 text-sm">
                        <div>
                          <span className="text-gray-500">Started:</span>
                          <span className="ml-2 text-gray-900">{med.startDate}</span>
                        </div>
                        <div>
                          <span className="text-gray-500">Stopped:</span>
                          <span className="ml-2 text-gray-900">{med.endDate}</span>
                        </div>
                        <div>
                          <span className="text-gray-500">Prescribed by:</span>
                          <span className="ml-2 text-gray-900">{med.prescribingSource}</span>
                        </div>
                      </div>
                    </div>
                    ))}
                  </div>
                )}
              </div>
            </div>
          </div>
        </section>

        {/* Vitals & Trends Section */}
        <section className="mb-8">
          <div className="bg-white rounded-lg border border-gray-200 overflow-hidden">
            <div className="px-6 py-4 bg-green-50 border-b border-green-100">
              <div className="flex items-center gap-2">
                <Activity className="w-5 h-5 text-green-600" />
                <h2 className="text-lg font-semibold text-gray-900">Vitals & Trends</h2>
              </div>
            </div>
            <div className="p-6">
              {/* Latest Vitals */}
              <div className="mb-6">
                <h3 className="text-sm font-semibold text-gray-700 mb-3 uppercase tracking-wide">
                  Latest Readings
                </h3>
                <div className="grid grid-cols-3 gap-4">
                  {patient.vitals ? (
                    <>
                      <div className="p-4 bg-gray-50 rounded-lg border border-gray-200">
                        <div className="text-xs text-gray-500 mb-1">Blood Pressure</div>
                        <div className="text-xl font-semibold text-gray-900 mb-1">
                          {patient.vitals.bloodPressure?.toString().replace(/\s*mmHg\s*/gi, '') || 'N/A'}
                          {patient.vitals.bloodPressure && !patient.vitals.bloodPressure.toString().includes('mmHg') && (
                            <span className="text-sm text-gray-500"> mmHg</span>
                          )}
                        </div>
                        <div className="flex items-center gap-1">
                          <span className={`px-2 py-0.5 rounded text-xs font-medium ${
                            bpStatus.color === 'red' ? 'bg-red-100 text-red-700' :
                            bpStatus.color === 'amber' ? 'bg-amber-100 text-amber-700' :
                            'bg-green-100 text-green-700'
                          }`}>
                            {bpStatus.status}
                          </span>
                          <span className="text-xs text-gray-500">{new Date().toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric' })}</span>
                        </div>
                      </div>
                      <div className="p-4 bg-gray-50 rounded-lg border border-gray-200">
                        <div className="text-xs text-gray-500 mb-1">Heart Rate</div>
                        <div className="text-xl font-semibold text-gray-900 mb-1">
                          {patient.vitals.heartRate?.toString().replace(/\s*bpm\s*/gi, '') || 'N/A'}
                          {patient.vitals.heartRate && !patient.vitals.heartRate.toString().includes('bpm') && (
                            <span className="text-sm text-gray-500"> bpm</span>
                          )}
                        </div>
                        <div className="flex items-center gap-1">
                          <span className={`px-2 py-0.5 rounded text-xs font-medium ${
                            hrStatus.color === 'red' ? 'bg-red-100 text-red-700' :
                            hrStatus.color === 'amber' ? 'bg-amber-100 text-amber-700' :
                            'bg-green-100 text-green-700'
                          }`}>
                            {hrStatus.status}
                          </span>
                          <span className="text-xs text-gray-500">{new Date().toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric' })}</span>
                        </div>
                      </div>
                      <div className="p-4 bg-gray-50 rounded-lg border border-gray-200">
                        <div className="text-xs text-gray-500 mb-1">Temperature</div>
                        <div className="text-xl font-semibold text-gray-900 mb-1">
                          {patient.vitals.temperature || 'N/A'} {patient.vitals.temperature && <span className="text-sm text-gray-500">°F</span>}
                        </div>
                        <div className="flex items-center gap-1">
                          <span className={`px-2 py-0.5 rounded text-xs font-medium ${
                            tempStatus.color === 'red' ? 'bg-red-100 text-red-700' :
                            tempStatus.color === 'amber' ? 'bg-amber-100 text-amber-700' :
                            'bg-green-100 text-green-700'
                          }`}>
                            {tempStatus.status}
                          </span>
                          <span className="text-xs text-gray-500">{new Date().toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric' })}</span>
                        </div>
                      </div>
                    </>
                  ) : (
                    <div className="col-span-3 p-4 bg-gray-50 rounded-lg border border-gray-200 text-center">
                      <p className="text-sm text-gray-500">No vitals data available</p>
                    </div>
                  )}
                </div>
              </div>

              {/* Historical Trends */}
              <div>
                <h3 className="text-sm font-semibold text-gray-700 mb-3 uppercase tracking-wide">
                  Historical Trends (Last 5 Readings)
                </h3>
                <div className="space-y-4">
                  {/* Blood Pressure Trend */}
                  <div className="p-4 bg-gray-50 rounded-lg border border-gray-200">
                    <div className="text-sm font-medium text-gray-900 mb-3">Blood Pressure</div>
                    <div className="space-y-2">
                      {vitalsTrend.filter(v => v.type === 'Blood Pressure').length > 0 ? (
                        vitalsTrend.filter(v => v.type === 'Blood Pressure').map((vital, idx) => {
                          // Remove unit from value if it's already there
                          const cleanValue = vital.value?.toString().replace(/\s*mmHg\s*/gi, '').trim() || 'N/A';
                          const showUnit = !vital.value?.toString().includes('mmHg');
                          return (
                          <div key={idx} className="flex items-center justify-between text-sm py-2 border-b border-gray-200 last:border-0">
                            <div className="flex items-center gap-3">
                              <span className="font-medium text-gray-900 w-24">{cleanValue}</span>
                              {showUnit && <span className="text-gray-500">{vital.unit}</span>}
                            </div>
                            <div className="flex items-center gap-3">
                              <span className={`px-2 py-0.5 rounded text-xs font-medium ${
                                vital.status === 'Normal' ? 'bg-green-100 text-green-700' :
                                vital.status === 'Elevated' ? 'bg-amber-100 text-amber-700' :
                                'bg-red-100 text-red-700'
                              }`}>
                                {vital.status}
                              </span>
                              <span className="text-gray-500 w-32 text-right">{vital.dateTime}</span>
                            </div>
                          </div>
                          );
                        })
                      ) : (
                        <p className="text-sm text-gray-500 py-2">No blood pressure readings available</p>
                      )}
                    </div>
                  </div>

                  {/* Heart Rate Trend */}
                  <div className="p-4 bg-gray-50 rounded-lg border border-gray-200">
                    <div className="text-sm font-medium text-gray-900 mb-3">Heart Rate</div>
                    <div className="space-y-2">
                      {vitalsTrend.filter(v => v.type === 'Heart Rate').length > 0 ? (
                        vitalsTrend.filter(v => v.type === 'Heart Rate').map((vital, idx) => {
                          // Remove unit from value if it's already there
                          const cleanValue = vital.value?.toString().replace(/\s*bpm\s*/gi, '').trim() || 'N/A';
                          const showUnit = !vital.value?.toString().includes('bpm');
                          return (
                          <div key={idx} className="flex items-center justify-between text-sm py-2 border-b border-gray-200 last:border-0">
                            <div className="flex items-center gap-3">
                              <span className="font-medium text-gray-900 w-24">{cleanValue}</span>
                              {showUnit && <span className="text-gray-500">{vital.unit}</span>}
                            </div>
                            <div className="flex items-center gap-3">
                              <span className={`px-2 py-0.5 rounded text-xs font-medium ${
                                vital.status === 'Normal' ? 'bg-green-100 text-green-700' :
                                vital.status === 'Elevated' ? 'bg-amber-100 text-amber-700' :
                                'bg-red-100 text-red-700'
                              }`}>
                                {vital.status}
                              </span>
                              <span className="text-gray-500 w-32 text-right">{vital.dateTime}</span>
                            </div>
                          </div>
                          );
                        })
                      ) : (
                        <p className="text-sm text-gray-500 py-2">No heart rate readings available</p>
                      )}
                    </div>
                  </div>

                  {/* Temperature Trend */}
                  <div className="p-4 bg-gray-50 rounded-lg border border-gray-200">
                    <div className="text-sm font-medium text-gray-900 mb-3">Temperature</div>
                    <div className="space-y-2">
                      {vitalsTrend.filter(v => v.type === 'Temperature').length > 0 ? (
                        vitalsTrend.filter(v => v.type === 'Temperature').map((vital, idx) => {
                          // Remove unit from value if it's already there
                          const cleanValue = vital.value?.toString().replace(/\s*°F\s*/gi, '').trim() || 'N/A';
                          const showUnit = !vital.value?.toString().includes('°F');
                          return (
                          <div key={idx} className="flex items-center justify-between text-sm py-2 border-b border-gray-200 last:border-0">
                            <div className="flex items-center gap-3">
                              <span className="font-medium text-gray-900 w-24">{cleanValue}</span>
                              {showUnit && vital.unit && <span className="text-gray-500">{vital.unit}</span>}
                            </div>
                            <div className="flex items-center gap-3">
                              <span className={`px-2 py-0.5 rounded text-xs font-medium ${
                                vital.status === 'Normal' ? 'bg-green-100 text-green-700' :
                                vital.status === 'Elevated' ? 'bg-amber-100 text-amber-700' :
                                'bg-red-100 text-red-700'
                              }`}>
                                {vital.status}
                              </span>
                              <span className="text-gray-500 w-32 text-right">{vital.dateTime}</span>
                            </div>
                          </div>
                          );
                        })
                      ) : (
                        <p className="text-sm text-gray-500 py-2">No temperature readings available</p>
                      )}
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* Clinical Notes Section */}
        <section className="mb-8">
          <div className="bg-white rounded-lg border border-gray-200 overflow-hidden">
            <div className="px-6 py-4 bg-amber-50 border-b border-amber-100">
              <div className="flex items-center gap-2">
                <FileText className="w-5 h-5 text-amber-600" />
                <h2 className="text-lg font-semibold text-gray-900">Clinical Notes</h2>
                <span className="text-xs text-gray-500">(From Previous Visits)</span>
              </div>
            </div>
            <div className="p-6">
              <div className="space-y-4">
                {clinicalNotes.map((note, idx) => (
                  <div key={idx} className="p-4 bg-gray-50 border border-gray-200 rounded-lg">
                    <div className="flex items-start justify-between mb-3">
                      <div className="flex items-center gap-2">
                        <Calendar className="w-4 h-4 text-gray-500" />
                        <span className="text-sm font-medium text-gray-900">{note.timestamp}</span>
                      </div>
                      <span className="px-2 py-0.5 bg-blue-100 text-blue-700 rounded text-xs font-medium">
                        {note.visitType}
                      </span>
                    </div>
                    <p className="text-sm text-gray-700 mb-3 leading-relaxed">
                      {note.content}
                    </p>
                    <div className="text-xs text-gray-500">
                      <span className="font-medium">Documented by:</span> {note.author}
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </section>

        {/* Data Freshness & Provenance */}
        <section>
          <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
            <div className="flex items-start gap-3">
              <Clock className="w-5 h-5 text-blue-600 flex-shrink-0 mt-0.5" />
              <div>
                <div className="text-sm font-medium text-blue-900 mb-1">Data Freshness & Provenance</div>
                  <div className="text-sm text-blue-800 space-y-1">
                  <div>Last data update: {lastUpdated}</div>
                  <div>Source systems: Digital Twin Engine, EHR Sync, Background Monitoring</div>
                  <div className="mt-2 text-xs text-blue-700 italic">
                    This summary reflects the most recent available patient data. Clinical decisions should incorporate current patient context and examination findings.
                  </div>
                </div>
              </div>
            </div>
          </div>
        </section>
      </div>
    </div>
  );
}
