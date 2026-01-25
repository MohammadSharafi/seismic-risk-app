import { useState } from 'react';
import { ChevronDown, ChevronUp } from 'lucide-react';
import { Patient } from '../App';

interface ClinicalSummaryProps {
  patient: Patient;
  onViewFullSummary?: () => void;
}

interface DetailedCondition {
  name: string;
  status: 'Active' | 'Resolved';
  onsetDate: string;
  source?: string;
  tags?: ('Chronic' | 'High Impact')[];
}

interface DetailedMedication {
  name: string;
  dose: string;
  startDate: string;
  prescribingSource: string;
  status: 'Active' | 'Stopped';
  lastReviewed?: string;
}

interface VitalReading {
  type: 'Blood Pressure' | 'Heart Rate' | 'Temperature';
  value: string;
  unit: string;
  dateTime: string;
  status: 'Normal' | 'Elevated' | 'Critical';
}

export function ClinicalSummary({ patient, onViewFullSummary }: ClinicalSummaryProps) {
  const [expandedConditions, setExpandedConditions] = useState(false);
  const [expandedMedications, setExpandedMedications] = useState(false);
  const [expandedVitals, setExpandedVitals] = useState(false);

  // Use detailed conditions from BigQuery if available, otherwise fallback to simple list
  // Filter to only show Active conditions (exclude DRAFT/Resolved in summary view)
  const allConditions: DetailedCondition[] = patient.detailedConditions && patient.detailedConditions.length > 0
    ? patient.detailedConditions.map((cond: any) => {
        const clinicalStatus = cond.clinical_status?.toLowerCase() || '';
        const status = clinicalStatus.includes('draft')
          ? 'Resolved'
          : (clinicalStatus.includes('active') || clinicalStatus.includes('confirmed') ? 'Active' : 'Resolved');
        const tags: ('Chronic' | 'High Impact')[] = [];
        if (cond.severity && cond.severity.toLowerCase().includes('high')) {
          tags.push('High Impact');
        }
        if (cond.onset_date || (cond.recorded_date && new Date(cond.recorded_date).getFullYear() < new Date().getFullYear() - 1)) {
          tags.push('Chronic');
        }
        return {
          name: cond.condition_name || 'Unknown Condition',
          status: status as 'Active' | 'Resolved',
          onsetDate: cond.onset_date 
            ? new Date(cond.onset_date).toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric' })
            : cond.recorded_date 
              ? new Date(cond.recorded_date).toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric' })
              : 'Unknown',
          source: cond.source || undefined,
          tags: tags.length > 0 ? tags : undefined,
        };
      })
    : patient.conditions?.length > 0
      ? patient.conditions.map((name) => ({
          name,
          status: 'Active' as const,
          onsetDate: 'Unknown',
          source: 'Patient Data',
        }))
      : [];
  
  // Filter to only show Active conditions (exclude DRAFT/Resolved)
  const detailedConditions = allConditions.filter(cond => cond.status === 'Active');

  // Use detailed medications from BigQuery if available, otherwise fallback to simple list
  // Filter to only show Active medications (exclude DRAFT/Stopped in summary view)
  const allMedications: DetailedMedication[] = patient.detailedMedications && patient.detailedMedications.length > 0
    ? patient.detailedMedications.map((med: any) => {
        const medicationStatus = med.medication_status?.toLowerCase() || '';
        const status = medicationStatus.includes('draft')
          ? 'Stopped'
          : (medicationStatus.includes('active') || medicationStatus.includes('in-progress') ? 'Active' : 'Stopped');
        const dose = med.dose_text || 'Unknown';
        const startDate = med.start_date
          ? new Date(med.start_date).toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric' })
          : med.authored_on_date
            ? new Date(med.authored_on_date).toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric' })
            : 'Unknown';
        const prescribingSource = med.prescribing_practitioner || 'Unknown';
        const lastReviewed = med.last_reviewed
          ? new Date(med.last_reviewed).toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric' })
          : undefined;
        return {
          name: med.medication_name || 'Unknown Medication',
          dose: dose,
          startDate: startDate,
          prescribingSource: prescribingSource,
          status: status as 'Active' | 'Stopped',
          lastReviewed: lastReviewed,
        };
      })
    : patient.medications?.length > 0
      ? patient.medications.map((name) => ({
          name,
          dose: 'Unknown',
          startDate: 'Unknown',
          prescribingSource: 'Patient Data',
          status: 'Active' as const,
        }))
      : [];
  
  // Filter to only show Active medications (exclude DRAFT/Stopped)
  const activeMedications = allMedications.filter(med => med.status === 'Active');
  
  // Deduplicate medications by name and dose (keep the most recent one if duplicates exist)
  const detailedMedications = activeMedications.reduce((unique: DetailedMedication[], med: DetailedMedication) => {
    const existingIndex = unique.findIndex(
      m => m.name.toLowerCase() === med.name.toLowerCase() && m.dose === med.dose
    );
    if (existingIndex === -1) {
      unique.push(med);
    } else {
      // If duplicate found, keep the one with the most recent start date
      const existing = unique[existingIndex];
      const existingDate = new Date(existing.startDate);
      const newDate = new Date(med.startDate);
      if (!isNaN(newDate.getTime()) && (isNaN(existingDate.getTime()) || newDate > existingDate)) {
        unique[existingIndex] = med;
      }
    }
    return unique;
  }, []);

  // Vitals trend - populate from patient vitals data
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
        const match = bp.match(/(\d+)\/(\d+)/);
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

  return (
    <div>
      {/* Snapshot description */}
      <p className="text-sm text-gray-600 mb-4">Snapshot of current problems, medications, and latest vitals.</p>

      {/* Key Conditions Section */}
      <h3 className="font-medium text-gray-900 mb-3">Key Conditions</h3>
      <div className="space-y-2 mb-2">
        {detailedConditions.length === 0 ? (
          <p className="text-sm text-gray-500">No conditions found.</p>
        ) : (
          detailedConditions.slice(0, expandedConditions ? detailedConditions.length : 3).map((condition, idx) => (
          <div key={idx}>
            {!expandedConditions ? (
              // Collapsed view - simple
              <div className="flex items-start gap-2 text-sm text-gray-700">
                <div className="w-1.5 h-1.5 bg-purple-500 rounded-full mt-1.5 flex-shrink-0"></div>
                {condition.name}
              </div>
            ) : (
              // Expanded view - detailed
              <div className="p-3 bg-purple-50 border border-purple-100 rounded-lg">
                <div className="flex items-start justify-between mb-2">
                  <div className="font-medium text-gray-900 text-sm">{condition.name}</div>
                  <span className={`text-xs px-2 py-0.5 rounded font-medium ${
                    condition.status === 'Active' ? 'bg-green-100 text-green-700' : 'bg-gray-200 text-gray-600'
                  }`}>
                    {condition.status}
                  </span>
                </div>
                <div className="space-y-1 text-xs text-gray-600">
                  <div><span className="font-medium">Onset:</span> {condition.onsetDate}</div>
                  {condition.source && (
                    <div><span className="font-medium">Source:</span> {condition.source}</div>
                  )}
                </div>
                {condition.tags && condition.tags.length > 0 && (
                  <div className="flex gap-1 mt-2">
                    {condition.tags.map((tag, tagIdx) => (
                      <span key={tagIdx} className={`text-xs px-2 py-0.5 rounded ${
                        tag === 'High Impact' ? 'bg-red-100 text-red-700' : 'bg-purple-100 text-purple-700'
                      }`}>
                        {tag}
                      </span>
                    ))}
                  </div>
                )}
              </div>
            )}
          </div>
          ))
        )}
      </div>
      {detailedConditions.length > 3 && (
        <button
          onClick={() => setExpandedConditions(!expandedConditions)}
          className="text-sm text-blue-600 hover:text-blue-700 flex items-center gap-1 mb-4"
        >
          {expandedConditions ? (
            <>
              <ChevronUp className="w-4 h-4" />
              Collapse details
            </>
          ) : (
            <>
              <ChevronDown className="w-4 h-4" />
              View condition details
            </>
          )}
        </button>
      )}
      {/* Current Medications Section */}
      <h3 className="font-medium text-gray-900 mb-3 mt-4">Current Medications</h3>
      <div className="space-y-2 mb-2">
        {detailedMedications.length === 0 ? (
          <p className="text-sm text-gray-500">No medications found.</p>
        ) : (
          detailedMedications.map((med, idx) => (
          <div key={idx}>
            {!expandedMedications ? (
              // Collapsed view - simple
              <div className="flex items-start gap-2 text-sm text-gray-700">
                <div className="w-1.5 h-1.5 bg-blue-500 rounded-full mt-1.5 flex-shrink-0"></div>
                {med.name} {med.dose}
              </div>
            ) : (
              // Expanded view - detailed
              <div className="p-3 bg-blue-50 border border-blue-100 rounded-lg">
                <div className="flex items-start justify-between mb-2">
                  <div>
                    <div className="font-medium text-gray-900 text-sm">{med.name}</div>
                    <div className="text-xs text-gray-600">{med.dose}</div>
                  </div>
                  <span className={`text-xs px-2 py-0.5 rounded font-medium ${
                    med.status === 'Active' ? 'bg-green-100 text-green-700' : 'bg-gray-200 text-gray-600'
                  }`}>
                    {med.status}
                  </span>
                </div>
                <div className="space-y-1 text-xs text-gray-600">
                  <div><span className="font-medium">Started:</span> {med.startDate}</div>
                  <div><span className="font-medium">Prescribed by:</span> {med.prescribingSource}</div>
                  {med.lastReviewed && (
                    <div className="text-blue-700 mt-1">
                      <span className="font-medium">Last reviewed:</span> {med.lastReviewed}
                    </div>
                  )}
                </div>
              </div>
            )}
          </div>
          ))
        )}
      </div>
      {detailedMedications.length > 0 && (
        <button
          onClick={() => setExpandedMedications(!expandedMedications)}
          className="text-sm text-blue-600 hover:text-blue-700 flex items-center gap-1 mb-4"
        >
          {expandedMedications ? (
            <>
              <ChevronUp className="w-4 h-4" />
              Collapse details
            </>
          ) : (
            <>
              <ChevronDown className="w-4 h-4" />
              View medication details
            </>
          )}
        </button>
      )}

      {/* Latest Vitals Section */}
      {patient.vitals && (
        <>
          <h3 className="font-medium text-gray-900 mb-3 mt-4">Latest Vitals</h3>
          {!expandedVitals ? (
            // Collapsed view - latest reading only
            <div className="space-y-2 mb-2">
              <div className="p-2 bg-gray-50 rounded text-sm">
                <div className="text-gray-500 text-xs mb-1">Blood Pressure</div>
                <div className="font-medium text-gray-900">
                  {patient.vitals.bloodPressure?.toString().replace(/\s*mmHg\s*/gi, '') || 'N/A'}
                  {patient.vitals.bloodPressure && !patient.vitals.bloodPressure.toString().includes('mmHg') && ' mmHg'}
                </div>
              </div>
              <div className="p-2 bg-gray-50 rounded text-sm">
                <div className="text-gray-500 text-xs mb-1">Heart Rate</div>
                <div className="font-medium text-gray-900">
                  {patient.vitals.heartRate?.toString().replace(/\s*bpm\s*/gi, '') || 'N/A'}
                  {patient.vitals.heartRate && !patient.vitals.heartRate.toString().includes('bpm') && ' bpm'}
                </div>
              </div>
              <div className="p-2 bg-gray-50 rounded text-sm">
                <div className="text-gray-500 text-xs mb-1">Temperature</div>
                <div className="font-medium text-gray-900">{patient.vitals.temperature || 'N/A'}</div>
              </div>
            </div>
          ) : (
            // Expanded view - trend with last 3 readings
            <div className="space-y-4 mb-2">
              {/* Blood Pressure Trend */}
              <div className="p-3 bg-gray-50 border border-gray-200 rounded-lg">
                <div className="font-medium text-sm text-gray-900 mb-3">Blood Pressure Trend</div>
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
                          <span className={`text-xs px-2 py-0.5 rounded font-medium ${
                            vital.status === 'Normal' ? 'bg-green-100 text-green-700' :
                            vital.status === 'Elevated' ? 'bg-amber-100 text-amber-700' :
                            'bg-red-100 text-red-700'
                          }`}>
                            {vital.status}
                          </span>
                          <span className="text-xs text-gray-500 w-32 text-right">{vital.dateTime}</span>
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
              <div className="p-3 bg-gray-50 border border-gray-200 rounded-lg">
                <div className="font-medium text-sm text-gray-900 mb-3">Heart Rate Trend</div>
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
                          <span className={`text-xs px-2 py-0.5 rounded font-medium ${
                            vital.status === 'Normal' ? 'bg-green-100 text-green-700' :
                            vital.status === 'Elevated' ? 'bg-amber-100 text-amber-700' :
                            'bg-red-100 text-red-700'
                          }`}>
                            {vital.status}
                          </span>
                          <span className="text-xs text-gray-500 w-32 text-right">{vital.dateTime}</span>
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
              <div className="p-3 bg-gray-50 border border-gray-200 rounded-lg">
                <div className="font-medium text-sm text-gray-900 mb-3">Temperature Trend</div>
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
                          <span className={`text-xs px-2 py-0.5 rounded font-medium ${
                            vital.status === 'Normal' ? 'bg-green-100 text-green-700' :
                            vital.status === 'Elevated' ? 'bg-amber-100 text-amber-700' :
                            'bg-red-100 text-red-700'
                          }`}>
                            {vital.status}
                          </span>
                          <span className="text-xs text-gray-500 w-32 text-right">{vital.dateTime}</span>
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
          )}
          <button
            onClick={() => setExpandedVitals(!expandedVitals)}
            className="text-sm text-blue-600 hover:text-blue-700 flex items-center gap-1 mb-4"
          >
            {expandedVitals ? (
              <>
                <ChevronUp className="w-4 h-4" />
                Collapse trend
              </>
            ) : (
              <>
                <ChevronDown className="w-4 h-4" />
                View vitals trend
              </>
            )}
          </button>
        </>
      )}

      {/* Global "View Full Clinical Summary" Button */}
      <div className="mt-6 pt-4 border-t border-gray-200">
        <button
          className="w-full px-4 py-2 text-sm text-blue-600 hover:text-blue-700 border border-blue-200 rounded-lg hover:bg-blue-50 transition-colors font-medium"
          onClick={onViewFullSummary}
        >
          View Full Clinical Summary
        </button>
      </div>
    </div>
  );
}