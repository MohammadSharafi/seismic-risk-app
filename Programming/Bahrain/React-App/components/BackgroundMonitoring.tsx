import { useState, useEffect } from 'react';
import { FileText, Clock, CheckCircle } from 'lucide-react';
import { Patient } from '../App';
import { API_BASE_URL } from '../src/config';

interface BackgroundMonitoringProps {
  patient: Patient;
}

interface HeartbeatStatus {
  is_active: boolean;
  last_check: string;
  current_state: 'Stable' | 'Alert' | 'Critical' | 'Unknown';
  next_evaluation: string;
  last_data_sync: string;
  status_message: string;
  last_run_time?: string;
  last_run_status?: string;
  twins_evaluated?: number;
  alarms_generated?: number;
}

export function BackgroundMonitoring({ patient }: BackgroundMonitoringProps) {
  const [status, setStatus] = useState<HeartbeatStatus | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchHeartbeatStatus = async () => {
      try {
        setLoading(true);
        setError(null);
        const response = await fetch(`${API_BASE_URL}/heartbeat/status/${patient.id}`, {
          headers: {
            'X-User-Id': 'doctor-001',
            'X-User-Role': 'DOCTOR'
          }
        });
        
        if (!response.ok) {
          throw new Error(`Failed to fetch heartbeat status: ${response.statusText}`);
        }
        
        const result = await response.json();
        if (result.data) {
          setStatus(result.data);
        } else {
          setStatus(null);
        }
      } catch (err: any) {
        console.error('Error fetching heartbeat status:', err);
        setError(err.message || 'Failed to load heartbeat status');
        setStatus(null);
      } finally {
        setLoading(false);
      }
    };

    fetchHeartbeatStatus();
    
    // Refresh every 30 seconds
    const interval = setInterval(fetchHeartbeatStatus, 30000);
    return () => clearInterval(interval);
  }, [patient.id]);

  const formatDateTime = (dateTime: string | undefined) => {
    if (!dateTime) return 'N/A';
    try {
      return new Date(dateTime).toLocaleString('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
        hour: 'numeric',
        minute: '2-digit',
        hour12: true
      });
    } catch {
      return dateTime;
    }
  };

  const getStateColor = (state: string | undefined) => {
    switch (state) {
      case 'Stable':
        return 'bg-green-100 text-green-700';
      case 'Alert':
        return 'bg-yellow-100 text-yellow-700';
      case 'Critical':
        return 'bg-red-100 text-red-700';
      default:
        return 'bg-gray-100 text-gray-700';
    }
  };

  if (loading) {
    return (
      <div className="p-4">
        <div className="text-center py-8">
          <div className="text-gray-600">Loading monitoring status...</div>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="p-4">
        <div className="bg-amber-50 border border-amber-200 rounded-lg p-4 text-amber-800">
          <div className="text-sm">{error}</div>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-4">
      {/* Header */}
      <div className="mb-4">
        <div className="flex items-center gap-2 mb-1">
          <FileText className="w-5 h-5 text-gray-600" />
          <h2 className="text-lg font-semibold text-gray-900">Background Monitoring</h2>
        </div>
        <p className="text-sm text-gray-600">Automated monitoring status and escalation history</p>
      </div>

      {/* Monitoring Status Card */}
      <div className="bg-white rounded-lg border border-gray-200 p-4">
        <div className="text-sm font-medium text-gray-900 mb-3">Monitoring Status</div>
        <div className="space-y-3">
          <div className="flex items-center justify-between">
            <span className="text-sm text-gray-600">Last Check:</span>
            <span className="text-sm text-gray-900 font-medium">
              {formatDateTime(status?.last_check || status?.last_run_time)}
            </span>
          </div>
          <div className="flex items-center justify-between">
            <span className="text-sm text-gray-600">Current State:</span>
            <span className={`px-2 py-1 text-xs font-medium rounded ${getStateColor(status?.current_state)}`}>
              {status?.current_state || 'Unknown'}
            </span>
          </div>
        </div>
      </div>

      {/* Active Status Indicator */}
      {status?.is_active && (
        <div className="bg-green-50 rounded-lg border border-green-200 p-4">
          <div className="flex items-center gap-2">
            <div className="w-2 h-2 bg-green-500 rounded-full"></div>
            <span className="text-sm font-medium text-green-900">Active</span>
          </div>
          <p className="text-xs text-green-800 mt-1">Background monitoring enabled</p>
        </div>
      )}

      {/* Next Evaluation */}
      {status?.next_evaluation && (
        <div className="bg-white rounded-lg border border-gray-200 p-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <Clock className="w-4 h-4 text-gray-400" />
              <span className="text-sm text-gray-600">Next Evaluation</span>
            </div>
            <span className="text-sm text-gray-900 font-medium">
              {formatDateTime(status.next_evaluation)}
            </span>
          </div>
        </div>
      )}

      {/* Last Data Sync */}
      {status?.last_data_sync && (
        <div className="bg-white rounded-lg border border-gray-200 p-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <Clock className="w-4 h-4 text-gray-400" />
              <span className="text-sm text-gray-600">Last Data Sync</span>
            </div>
            <span className="text-sm text-gray-900 font-medium">
              {formatDateTime(status.last_data_sync)}
            </span>
          </div>
        </div>
      )}

      {/* Status Message */}
      <div className="bg-blue-50 rounded-lg border border-blue-200 p-4">
        <div className="text-sm text-blue-900">
          <span className="font-medium">Status: </span>
          <span>{status?.status_message || 'No new data detected'}</span>
        </div>
        {status?.last_run_status && status.last_run_status !== 'NOT_RUN' && (
          <div className="text-xs text-blue-700 mt-2">
            Last run: {status.last_run_status === 'SUCCESS' ? '✓ Success' : 
                      status.last_run_status === 'FAILED' ? '✗ Failed' : 
                      status.last_run_status === 'RUNNING' ? '⟳ Running' : status.last_run_status}
            {status.twins_evaluated !== undefined && status.twins_evaluated > 0 && (
              <span className="ml-2">
                ({status.twins_evaluated} twin{status.twins_evaluated !== 1 ? 's' : ''} evaluated
                {status.alarms_generated !== undefined && status.alarms_generated > 0 && 
                  `, ${status.alarms_generated} alarm${status.alarms_generated !== 1 ? 's' : ''} generated`})
              </span>
            )}
          </div>
        )}
      </div>
    </div>
  );
}
