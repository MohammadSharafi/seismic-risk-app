import { useState, useEffect } from 'react';
import { Search, Filter, AlertTriangle, Clock } from 'lucide-react';
import { Patient, RiskTier, Status } from '../App';
import { RiskBadge } from './RiskBadge';
import { StatusChip } from './StatusChip';

import { API_BASE_URL } from '../src/config';

// Map backend RiskTier to frontend RiskTier
const mapRiskTier = (tier: string): RiskTier => {
  if (!tier) return 'Medium';
  const upper = tier.toUpperCase();
  if (upper === 'HIGH' || upper === 'HIGH ALERT') return 'High';
  if (upper === 'CRITICAL' || upper === 'CRITICAL ALERT') return 'Critical';
  if (upper === 'MEDIUM' || upper === 'MODERATE' || upper === 'MODERATE ALERT') return 'Medium';
  if (upper === 'LOW' || upper === 'LOW ALERT') return 'Low';
  return 'Medium'; // Default
};

// Map alarm severity to RiskTier for display
const mapSeverityToTier = (severity: string): RiskTier | null => {
  if (!severity) return null;
  const upper = severity.toUpperCase();
  if (upper === 'CRITICAL') return 'Critical';
  if (upper === 'HIGH') return 'High';
  if (upper === 'MEDIUM' || upper === 'MODERATE') return 'Medium';
  if (upper === 'LOW') return 'Low';
  return null;
};

// Map backend Status to frontend Status
const mapStatus = (status: string): Status => {
  if (!status) return 'Monitoring';
  const upper = status.toUpperCase();
  if (upper === 'ACTIVE') return 'Monitoring';
  if (upper === 'INACTIVE') return 'Needs Review';
  if (upper === 'ARCHIVED') return 'Action Taken';
  return 'Monitoring'; // Default
};

interface Practitioner {
  id: string;
  name: string;
  email: string;
  specialty?: string;
  role?: string;
  phone?: string;
}

interface DoctorDashboardProps {
  onOpenPatient: (patient: Patient) => void;
  loggedInPractitioner?: Practitioner | null;
}

// Alarm data from API
interface Alarm {
  id: string;
  patient: Patient;
  summary: string;
  timeTriggered: string;
  acknowledged: boolean;
  severity?: string; // CRITICAL, HIGH, MEDIUM, LOW from API
}

export function DoctorDashboard({ onOpenPatient, loggedInPractitioner }: DoctorDashboardProps) {
  const [patients, setPatients] = useState<Patient[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [searchQuery, setSearchQuery] = useState('');
  const [filterCohort, setFilterCohort] = useState<string>('All');
  const [alarms, setAlarms] = useState<Alarm[]>([]);

  // Fetch patients from API
  useEffect(() => {
    const fetchPatients = async () => {
      try {
        setLoading(true);
        const response = await fetch(`${API_BASE_URL}/dashboard/patients?page=0&pageSize=100`, {
          headers: {
            'X-User-Id': 'doctor-001',
            'X-User-Role': 'DOCTOR',
          },
        });

        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`);
        }

        const result = await response.json();
        
        // Backend returns { data: { items: [...], totalItems: ... } }
        // or { success: true, data: { items: [...] } } depending on the endpoint
        const patientsData = result.data?.items || result.items || [];
        
        if (patientsData.length > 0 || result.data) {
          const mappedPatients: Patient[] = patientsData.map((p: any) => ({
            id: p.id,
            name: p.name || 'Unknown',
            age: p.age || 0,
            sex: p.sex || 'Unknown',
            twinId: p.twinId || `twin_${p.id}`,
            riskTier: mapRiskTier(p.riskTier || 'MEDIUM'),
            lastEvaluation: p.lastEvaluation || 'N/A',
            nextAction: p.nextAction || 'Continue monitoring',
            status: mapStatus(p.status || 'ACTIVE'),
            cohort: p.cohort || [],
            conditions: p.conditions || [],
            medications: p.medications || [],
          }));
          
          setPatients(mappedPatients);
          console.log(`✅ Loaded ${mappedPatients.length} patients`);
          return mappedPatients;
        } else {
          console.warn('No patients data in response:', result);
          setPatients([]);
          return [];
        }
      } catch (err) {
        console.error('Error fetching patients:', err);
        setError(err instanceof Error ? err.message : 'Failed to fetch patients');
        // Fallback to empty array on error
        setPatients([]);
        return [];
      } finally {
        setLoading(false);
      }
    };

    const formatTimeAgo = (timestamp: string | null | undefined): string => {
      if (!timestamp) return 'Unknown';
      
      try {
        let date: Date;
        
        // Handle BigQuery timestamp format (seconds since epoch as string)
        if (typeof timestamp === 'string' && /^\d+\.?\d*$/.test(timestamp)) {
          // It's a numeric string (seconds since epoch)
          const seconds = parseFloat(timestamp);
          date = new Date(seconds * 1000);
        } else {
          // Try to parse as ISO date string
          date = new Date(timestamp);
        }
        
        // Check if date is valid
        if (isNaN(date.getTime())) {
          return 'Unknown';
        }
        
        const now = new Date();
        const diffMs = now.getTime() - date.getTime();
        const diffMins = Math.floor(diffMs / 60000);
        const diffHours = Math.floor(diffMs / 3600000);
        const diffDays = Math.floor(diffMs / 86400000);
        
        if (diffMins < 1) {
          return 'Just now';
        } else if (diffMins < 60) {
          return diffMins === 1 ? '1 minute ago' : `${diffMins} minutes ago`;
        } else if (diffHours < 24) {
          return diffHours === 1 ? '1 hour ago' : `${diffHours} hours ago`;
        } else {
          return diffDays === 1 ? '1 day ago' : `${diffDays} days ago`;
        }
      } catch (e) {
        console.warn('Error formatting time:', timestamp, e);
        return 'Unknown';
      }
    };

    const fetchAlarms = async (patientsList: Patient[]) => {
      try {
        const response = await fetch(`${API_BASE_URL}/dashboard/alarms/open`, {
          headers: {
            'X-User-Id': 'doctor-001',
            'X-User-Role': 'DOCTOR',
          },
        });

        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`);
        }

        const result = await response.json();
        const alarmsData = result.data || [];
        
        console.log('📊 Raw alarms data from API:', alarmsData);
        console.log('📊 Patients list:', patientsList.map(p => ({ id: p.id, name: p.name })));
        
        // Map API alarms to frontend Alarm format
        // Need to match alarms with patients by patientId
        // IMPORTANT: Only show the most recent alarm per patient
        // Group alarms by patient and keep only the most recent one
        const alarmsByPatient = new Map<string, any>();
        
        alarmsData.forEach((alarm: any) => {
          const patientId = alarm.patientId || alarm.patient_id;
          if (!patientId) return;
          
          // Check if we already have an alarm for this patient
          const existing = alarmsByPatient.get(patientId);
          if (!existing) {
            alarmsByPatient.set(patientId, alarm);
          } else {
            // Compare timestamps - keep the most recent
            const existingTime = existing.createdAt || existing.created_at || existing.timeAgo || 0;
            const currentTime = alarm.createdAt || alarm.created_at || alarm.timeAgo || 0;
            
            // Convert to numbers for comparison
            const existingTimestamp = typeof existingTime === 'string' 
              ? new Date(existingTime).getTime() 
              : (typeof existingTime === 'number' ? existingTime : 0);
            const currentTimestamp = typeof currentTime === 'string' 
              ? new Date(currentTime).getTime() 
              : (typeof currentTime === 'number' ? currentTime : 0);
            
            if (currentTimestamp > existingTimestamp || (currentTimestamp === 0 && existingTimestamp === 0)) {
              alarmsByPatient.set(patientId, alarm);
            }
          }
        });
        
        // Map to Alarm objects (only one per patient)
        const mappedAlarms: Alarm[] = Array.from(alarmsByPatient.values())
          .map((alarm: any) => {
            console.log('🔍 Processing alarm:', { 
              alarmId: alarm.id, 
              patientId: alarm.patientId || alarm.patient_id, 
              message: alarm.message || alarm.alarmSummary
            });
            
            const patientId = alarm.patientId || alarm.patient_id;
            
            // Find patient by patientId - try exact match first
            let patient = patientsList.find(p => p.id === patientId);
            
            // If not found, try matching by twin_id
            if (!patient && alarm.twinId) {
              patient = patientsList.find(p => p.twinId === alarm.twinId);
            }
            
            if (!patient) {
              console.warn(`⚠️ No patient found for alarm:`, {
                alarmId: alarm.id,
                patientId: patientId,
                twinId: alarm.twinId,
                availablePatientIds: patientsList.map(p => p.id)
              });
              return null;
            }
            
            // Format time properly - handle both timeAgo string and createdAt
            let timeDisplay = 'Unknown';
            if (alarm.timeAgo) {
              // If timeAgo is already a formatted string, use it
              // Otherwise, if it's a timestamp string, format it
              if (/^\d+\.?\d*$/.test(alarm.timeAgo)) {
                timeDisplay = formatTimeAgo(alarm.timeAgo);
              } else {
                timeDisplay = alarm.timeAgo;
              }
            } else if (alarm.createdAt || alarm.created_at) {
              timeDisplay = formatTimeAgo(alarm.createdAt || alarm.created_at);
            }
            
            return {
              id: alarm.id || `alarm_${patientId}`,
              patient: patient,
              summary: alarm.message || alarm.alarmSummary || 'Alarm triggered',
              timeTriggered: timeDisplay,
              acknowledged: alarm.status === 'CLOSED' || alarm.status === 'ACKNOWLEDGED',
              severity: alarm.severity || null, // Store severity from API
            };
          })
          .filter((a: Alarm | null) => a !== null) as Alarm[];
        
        setAlarms(mappedAlarms);
        console.log(`✅ Loaded ${mappedAlarms.length} alarms from BigQuery (out of ${alarmsData.length} total)`);
      } catch (err) {
        console.error('Error fetching alarms:', err);
        // Don't set error state for alarms, just log it
        setAlarms([]);
      }
    };

    // Fetch patients first, then alarms
    fetchPatients().then((patientsList) => {
      fetchAlarms(patientsList);
    });
  }, []);

  // Get unique cohorts from patients for dynamic dropdown
  const availableCohorts = Array.from(
    new Set(patients.flatMap(p => p.cohort || []))
  ).sort();

  const filteredPatients = patients.filter(patient => {
    const matchesSearch = searchQuery === '' || 
                         patient.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
                         patient.id.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesCohort = filterCohort === 'All' || (patient.cohort && patient.cohort.includes(filterCohort));
    return matchesSearch && matchesCohort;
  });

  const filteredAlarms = alarms.filter(alarm => {
    // Only show CRITICAL and HIGH severity alarms
    const severity = alarm.severity?.toUpperCase();
    if (severity !== 'CRITICAL' && severity !== 'HIGH') {
      return false;
    }
    return true;
  });

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
          <p className="text-gray-600">Loading patients...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <AlertTriangle className="w-12 h-12 text-red-500 mx-auto mb-4" />
          <p className="text-red-600 mb-2">Error loading patients</p>
          <p className="text-sm text-gray-600">{error}</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Top Header Bar */}
      <header className="bg-white border-b border-gray-200 sticky top-0 z-10">
        <div className="max-w-7xl mx-auto px-8 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 bg-gradient-to-br from-blue-600 to-purple-600 rounded-lg flex items-center justify-center">
                <img src="/twincare-logo.svg" alt="TwinCare" className="w-7 h-7" />
              </div>
              <span className="text-xl font-semibold text-gray-900">TwinCare</span>
            </div>
            <div className="flex items-center gap-4">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 bg-blue-100 rounded-full flex items-center justify-center">
                  <span className="text-blue-600 font-semibold text-sm">
                    {loggedInPractitioner?.name 
                      ? loggedInPractitioner.name.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2)
                      : 'DR'}
                  </span>
                </div>
                <div className="text-right">
                  <div className="text-sm font-medium text-gray-900">
                    {loggedInPractitioner?.name || 'Dr. Unknown'}
                  </div>
                  <div className="text-xs text-gray-500">
                    {loggedInPractitioner?.specialty 
                      ? loggedInPractitioner.specialty.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase())
                      : loggedInPractitioner?.role 
                        ? loggedInPractitioner.role.replace(/_/g, ' ')
                        : 'Physician'}
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </header>

      <div className="max-w-7xl mx-auto p-8">
        {/* Dashboard Header */}
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-900 mb-2">Patient Dashboard</h1>
          <p className="text-gray-600">Manage and monitor Digital Twin patients</p>
        </div>

        {/* Active Alarms Section */}
        {filteredAlarms.length > 0 && (
          <div className="bg-red-50 border border-red-200 rounded-lg p-4 mb-6">
            <div className="flex items-center gap-2 mb-3">
              <span className="text-red-600 font-bold text-lg">▲</span>
              <h2 className="font-semibold text-red-900">Active Alarms</h2>
              <span className="px-2 py-1 bg-red-500 text-white text-xs font-medium rounded-full">
                {filteredAlarms.length}
              </span>
            </div>
            <div className="space-y-3">
              {filteredAlarms.map((alarm) => {
                // Map severity to tier for display
                const displayTier = mapSeverityToTier(alarm.severity || '');
                if (!displayTier || (displayTier !== 'Critical' && displayTier !== 'High')) {
                  return null; // Should not happen due to filter, but safety check
                }
                
                return (
                  <div key={alarm.id} className="bg-white rounded-lg p-4 border border-orange-200">
                    <div className="flex items-start justify-between">
                      <div className="flex-1">
                        <div className="flex items-center gap-3 mb-2">
                          <span className="font-medium text-gray-900">{alarm.patient.name}</span>
                          <RiskBadge tier={displayTier} />
                        </div>
                        <p className="text-sm text-gray-700 mb-2">{alarm.summary}</p>
                        <div className="flex items-center gap-1 text-sm text-gray-500">
                          <Clock className="w-4 h-4" />
                          <span>{alarm.timeTriggered}</span>
                        </div>
                      </div>
                      <div className="flex gap-2 ml-4">
                        <button
                          onClick={() => onOpenPatient(alarm.patient)}
                          className="px-4 py-2 text-sm bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
                        >
                          Review Patient
                        </button>
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        )}

        {/* Search and Filters */}
        <div className="mb-6 flex gap-4 items-center">
          <div className="flex-1 relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
            <input
              type="text"
              placeholder="Search by patient name or ID..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full pl-10 pr-4 py-2.5 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent bg-white"
            />
          </div>
          
          <div className="h-8 w-px bg-gray-300"></div>
          
          <div className="flex gap-3 items-center">
            <Filter className="w-5 h-5 text-gray-400" />
            <select
              value={filterCohort}
              onChange={(e) => setFilterCohort(e.target.value)}
              className="px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 bg-white"
            >
              <option value="All">All Cohorts</option>
              {availableCohorts.map(cohort => (
                <option key={cohort} value={cohort}>{cohort}</option>
              ))}
            </select>
          </div>
        </div>

        {/* Patient List Table */}
        <div className="bg-white rounded-lg border border-gray-200 overflow-hidden">
          <table className="w-full">
            <thead className="bg-gray-50 border-b border-gray-200">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Patient Name / ID
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Last Evaluation
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Next Recommended Action
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Status
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Action
                </th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200">
              {filteredPatients.length === 0 ? (
                <tr>
                  <td colSpan={5} className="px-6 py-8 text-center text-gray-500">
                    {searchQuery || filterCohort !== 'All' 
                      ? 'No patients match your filters' 
                      : 'No patients found'}
                  </td>
                </tr>
              ) : (
                filteredPatients.map((patient, index) => (
                  <tr key={patient.id} className="hover:bg-gray-50 transition-colors">
                    <td className="px-6 py-4">
                      <div className="font-medium text-gray-900">{patient.name}</div>
                      <div className="text-sm text-gray-500">
                        {patient.id.startsWith('P') ? patient.id : `P${String(index + 1).padStart(3, '0')}`}
                      </div>
                    </td>
                    <td className="px-6 py-4 text-sm text-gray-700">
                      {patient.lastEvaluation}
                    </td>
                    <td className="px-6 py-4 text-sm text-gray-700">
                      {patient.nextAction}
                    </td>
                    <td className="px-6 py-4">
                      <StatusChip status={patient.status} />
                    </td>
                    <td className="px-6 py-4">
                      <button
                        onClick={() => onOpenPatient(patient)}
                        className="px-4 py-2 bg-blue-600 text-white text-sm rounded-lg hover:bg-blue-700 transition-colors"
                      >
                        Review Patient
                      </button>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>

      </div>
    </div>
  );
}
