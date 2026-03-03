import React, { useState, useEffect } from 'react';
import { X, Search } from 'lucide-react';
import { isCommandApiEnabled, fetchPatients } from '../api/commandApi';
import type { PatientListItem } from '../api/commandApi';

/** Display shape: API patient + optional recent flag (all from API are non-recent for now). */
type PatientRow = PatientListItem & { recent?: boolean };

interface PatientPickerModalProps {
  open: boolean;
  onClose: () => void;
  onSelectPatient: (patient: { name: string; mrn: string; status: string; risk: string }) => void;
}

export function PatientPickerModal({ open, onClose, onSelectPatient }: PatientPickerModalProps) {
  const [searchTerm, setSearchTerm] = useState('');
  const [patients, setPatients] = useState<PatientRow[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!open) return;
    setError(null);
    if (isCommandApiEnabled()) {
      setLoading(true);
      fetchPatients('default')
        .then((list) => setPatients(list.map((p) => ({ ...p, recent: false }))))
        .catch(() => setError('Failed to load patients from the API. Is March API running (for example at http://localhost:8000)?'))
        .finally(() => setLoading(false));
    } else {
      setPatients([]);
    }
  }, [open]);

  if (!open) return null;

  const filteredPatients = patients.filter(
    (patient) =>
      patient.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      patient.mrn.includes(searchTerm)
  );

  const handleSelect = (patient: any) => {
    onSelectPatient(patient);
    onClose();
  };

  return (
    <>
      <div
        className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center"
        onClick={onClose}
      >
        <div
          data-testid="patient-picker-modal"
          className="bg-card rounded-lg sm:rounded-xl w-full max-w-2xl mx-2 sm:mx-4 max-h-[90vh] sm:max-h-[80vh] flex flex-col border border-border"
          onClick={(e) => e.stopPropagation()}
        >
          <div className="border-b border-border px-3 sm:px-6 py-2 sm:py-4 flex items-center justify-between">
            <h2 className="text-sm sm:text-lg font-medium text-foreground">Select Patient</h2>
            <button onClick={onClose} className="text-muted-foreground hover:text-slate-600 dark:hover:text-slate-400 p-0.5 sm:p-1">
              <X className="w-4 h-4 sm:w-5 sm:h-5" />
            </button>
          </div>

          <div className="px-3 sm:px-6 py-2 sm:py-4 border-b border-border">
            <div className="relative">
              <Search className="absolute left-2 sm:left-3 top-1/2 -translate-y-1/2 w-3.5 h-3.5 sm:w-5 sm:h-5 text-muted-foreground" />
              <input
                type="text"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                placeholder="Search by name or MRN..."
                className="w-full pl-8 sm:pl-10 pr-2 sm:pr-4 py-1.5 sm:py-2 text-[11px] sm:text-base border border-border bg-card text-foreground placeholder:text-muted-foreground rounded-md sm:rounded-lg focus:outline-none focus:ring-2 focus:ring-teal-500"
              />
            </div>
          </div>

          <div className="flex-1 overflow-y-auto">
            {loading && (
              <div className="px-3 sm:px-6 py-6 sm:py-8 text-center text-muted-foreground text-sm">
                Loading patients…
              </div>
            )}
            {!loading && error && (
              <div className="px-3 sm:px-6 py-6 sm:py-8 text-center text-red-600 dark:text-red-400 text-sm">
                {error}
              </div>
            )}
            {!loading && !error && filteredPatients.length === 0 && (
              <div className="px-3 sm:px-6 py-6 sm:py-8 text-center text-muted-foreground text-sm">
                {isCommandApiEnabled()
                  ? 'No patients in the database. Ensure the backend is running and seeded.'
                  : 'Set VITE_MARCH_API_URL to the backend URL (e.g. http://localhost:8000) to load patients from the API.'}
              </div>
            )}
            {!loading && filteredPatients.filter(p => p.recent).length > 0 && (
              <div>
                <div className="px-3 sm:px-6 py-1.5 sm:py-2 text-[10px] sm:text-xs font-medium text-muted-foreground uppercase tracking-wide bg-muted border-b border-border">
                  Recent Patients
                </div>
                {filteredPatients
                  .filter((p) => p.recent)
                  .map((patient) => (
                    <button
                      key={patient.mrn}
                      data-testid={`patient-row-${patient.mrn}`}
                      onClick={() => handleSelect(patient)}
                      className="w-full px-3 sm:px-6 py-2 sm:py-4 text-left hover:bg-accent border-b border-border flex items-center justify-between gap-1.5 sm:gap-4 transition-colors"
                    >
                      <div className="flex-1 min-w-0">
                        <div className="text-[11px] sm:text-base font-medium text-foreground mb-0.5 sm:mb-1 truncate">
                          {patient.name}
                        </div>
                        <div className="flex items-center gap-1.5 sm:gap-3 text-[9px] sm:text-sm text-muted-foreground flex-wrap">
                          <span>MRN {patient.mrn}</span>
                          <span className="hidden sm:inline">•</span>
                          <span className="truncate">{patient.status}</span>
                        </div>
                      </div>
                      <span
                        className={`px-1.5 sm:px-3 py-0.5 sm:py-1 rounded-full text-[9px] sm:text-xs font-semibold flex-shrink-0 ${
                          patient.risk === 'High'
                            ? 'bg-red-50 dark:bg-red-950 text-red-700 dark:text-red-200 border border-red-300 dark:border-red-700'
                            : patient.risk === 'Moderate'
                            ? 'bg-amber-50 dark:bg-amber-950 text-amber-800 dark:text-amber-200 border border-amber-300 dark:border-amber-700'
                            : 'bg-emerald-50 dark:bg-emerald-950 text-emerald-700 dark:text-emerald-200 border border-emerald-300 dark:border-emerald-700'
                        }`}
                      >
                        {patient.risk} Risk
                      </span>
                    </button>
                  ))}
              </div>
            )}

            {!loading && filteredPatients.filter(p => !p.recent).length > 0 && (
              <div>
                <div className="px-3 sm:px-6 py-1.5 sm:py-2 text-[10px] sm:text-xs font-medium text-muted-foreground uppercase tracking-wide bg-muted border-b border-border">
                  All Patients
                </div>
                {filteredPatients
                  .filter((p) => !p.recent)
                  .map((patient) => (
                    <button
                      key={patient.mrn}
                      data-testid={`patient-row-${patient.mrn}`}
                      onClick={() => handleSelect(patient)}
                      className="w-full px-3 sm:px-6 py-2 sm:py-4 text-left hover:bg-accent border-b border-border flex items-center justify-between gap-1.5 sm:gap-4 transition-colors"
                    >
                      <div className="flex-1 min-w-0">
                        <div className="text-[11px] sm:text-base font-medium text-foreground mb-0.5 sm:mb-1 truncate">
                          {patient.name}
                        </div>
                        <div className="flex items-center gap-1.5 sm:gap-3 text-[9px] sm:text-sm text-muted-foreground flex-wrap">
                          <span>MRN {patient.mrn}</span>
                          <span className="hidden sm:inline">•</span>
                          <span className="truncate">{patient.status}</span>
                        </div>
                      </div>
                      <span
                        className={`px-1.5 sm:px-3 py-0.5 sm:py-1 rounded-full text-[9px] sm:text-xs font-semibold flex-shrink-0 ${
                          patient.risk === 'High'
                            ? 'bg-red-50 dark:bg-red-950 text-red-700 dark:text-red-200 border border-red-300 dark:border-red-700'
                            : patient.risk === 'Moderate'
                            ? 'bg-amber-50 dark:bg-amber-950 text-amber-800 dark:text-amber-200 border border-amber-300 dark:border-amber-700'
                            : 'bg-emerald-50 dark:bg-emerald-950 text-emerald-700 dark:text-emerald-200 border border-emerald-300 dark:border-emerald-700'
                        }`}
                      >
                        {patient.risk} Risk
                      </span>
                    </button>
                  ))}
              </div>
            )}
          </div>
        </div>
      </div>
    </>
  );
}