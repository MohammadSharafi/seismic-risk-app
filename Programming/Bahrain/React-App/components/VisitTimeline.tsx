import { useState, useEffect } from 'react';
import { Calendar, ChevronRight } from 'lucide-react';
import { Patient } from '../App';
import { API_BASE_URL } from '../src/config';

interface Visit {
  visit_id: string;
  visit_date: string;
  visit_type: string;
  trigger_source: string;
  visit_status: string;
  ai_analysis?: {
    risk_tier: 'Low' | 'Medium' | 'High';
    reasoning?: string[];
    timestamp?: string;
  };
  doctor_decision?: {
    final_risk_tier: 'Low' | 'Medium' | 'High';
    doctor_name?: string;
    reasoning_notes?: string;
    decision_timestamp?: string;
  };
  plan_summary?: string;
}

interface VisitTimelineProps {
  patient: Patient;
  onViewFullTimeline?: () => void;
}

export function VisitTimeline({ patient, onViewFullTimeline }: VisitTimelineProps) {
  const [visits, setVisits] = useState<Visit[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchVisitHistory = async () => {
      try {
        setLoading(true);
        setError(null);
        const response = await fetch(`${API_BASE_URL}/analyze/visit-history/${patient.id}`, {
          headers: {
            'X-User-Id': 'doctor-001',
            'X-User-Role': 'DOCTOR'
          }
        });
        
        if (!response.ok) {
          const errorText = await response.text();
          let errorMessage = `Failed to fetch visit history: ${response.statusText}`;
          try {
            const errorJson = JSON.parse(errorText);
            if (errorJson.message) {
              errorMessage = errorJson.message;
            }
          } catch {
            // If not JSON, use the text as is
            if (errorText) {
              errorMessage = errorText;
            }
          }
          throw new Error(errorMessage);
        }
        
        const result = await response.json();
        if (result.data) {
          setVisits(result.data);
          if (result.data.length === 0) {
            // No error, just no visits yet
            setError(null);
          }
        } else {
          setVisits([]);
        }
      } catch (err: any) {
        console.error('Error fetching visit history:', err);
        // Don't show error if it's just that there are no visits
        if (err.message && err.message.includes('Table') && err.message.includes('not found')) {
          setError('Visit history table not yet created. Visits will appear here after the first visit is completed.');
        } else {
          setError(err.message || 'Failed to load visit history. Please ensure the backend is running and the visits table exists.');
        }
        setVisits([]);
      } finally {
        setLoading(false);
      }
    };

    fetchVisitHistory();
  }, [patient.id]);

  // Helper function to get visit type badge text
  const getVisitTypeBadge = (visitType: string, triggerSource: string) => {
    const type = (visitType || triggerSource || '').toLowerCase();
    if (type.includes('manual')) return 'Manual';
    if (type.includes('background')) return 'Background';
    if (type.includes('follow')) return 'Follow-up';
    return visitType || 'Manual';
  };

  return (
    <div>
      <div className="mb-4">
        <h2 className="text-base font-medium text-gray-900">Recent visits and clinical encounters timeline</h2>
      </div>

      {loading && (
        <div className="bg-white rounded-lg border border-gray-200 p-8 text-center">
          <div className="text-sm text-gray-600">Loading visit history...</div>
        </div>
      )}

      {error && (
        <div className="bg-amber-50 border border-amber-200 rounded-lg p-4 text-amber-800 mb-4">
          <div className="text-sm">{error}</div>
        </div>
      )}

      {!loading && !error && visits.length > 0 && (
        <>
          <div className="space-y-2 mb-4">
            {visits.map((visit) => {
              const visitDate = visit.visit_date ? new Date(visit.visit_date).toLocaleDateString('en-US', {
                year: 'numeric',
                month: 'short',
                day: 'numeric'
              }) : 'Unknown date';
              
              const visitTypeBadge = getVisitTypeBadge(visit.visit_type || '', visit.trigger_source || '');
              const visitStatus = visit.visit_status || 'Completed';
              
              return (
                <div 
                  key={visit.visit_id} 
                  className="bg-white rounded-lg border border-gray-200 px-4 py-3 flex items-center justify-between hover:bg-gray-50 transition-colors cursor-pointer"
                >
                  <div className="flex items-center gap-3">
                    <span className="text-sm text-gray-900">{visitDate}</span>
                    
                    <span className="px-2 py-0.5 text-xs font-medium rounded bg-blue-100 text-blue-700">
                      {visitTypeBadge}
                    </span>
                    
                    <span className="text-sm text-gray-600">{visitStatus}</span>
                  </div>
                  
                  <ChevronRight className="w-4 h-4 text-gray-400" />
                </div>
              );
            })}
          </div>

          {/* View Full Timeline Button */}
          <button 
            onClick={onViewFullTimeline}
            className="w-full py-2.5 px-4 bg-white border border-gray-300 rounded-lg text-sm font-medium text-gray-700 hover:bg-gray-50 transition-colors"
          >
            View Full Timeline
          </button>
        </>
      )}

      {/* Empty State */}
      {!loading && !error && visits.length === 0 && (
        <div className="bg-white rounded-lg border border-gray-200 p-12 text-center">
          <Calendar className="w-12 h-12 text-gray-400 mx-auto mb-3" />
          <h3 className="font-medium text-gray-900 mb-1">No Visits Recorded</h3>
          <p className="text-sm text-gray-600">Visit history will appear here once evaluations are completed</p>
        </div>
      )}
    </div>
  );
}
