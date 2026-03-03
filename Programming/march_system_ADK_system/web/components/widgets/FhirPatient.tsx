import React from 'react';
import { User, AlertCircle, CheckCircle2 } from 'lucide-react';

interface FhirPatientData {
  patientId: string;
  tenantId?: string;
  configured?: boolean;
  found?: boolean;
  message?: string;
  fhirId?: string;
  resourceType?: string;
  name?: string;
  birthDate?: string;
  gender?: string;
}

export function FhirPatient({ data }: { data: FhirPatientData }) {
  if (!data) return null;
  const configured = data.configured === true;
  const found = data.found === true;

  return (
    <div className="border border-border rounded-md sm:rounded-lg overflow-hidden bg-accent/50 my-2 sm:my-3">
      <div className="bg-accent px-2 sm:px-4 py-1.5 sm:py-2 border-b border-border">
        <div className="flex items-center gap-1.5 sm:gap-2">
          <User className="w-3 h-3 sm:w-4 sm:h-4 text-muted-foreground" />
          <h3 className="text-[10px] sm:text-sm font-medium text-foreground">FHIR Patient</h3>
        </div>
      </div>
      <div className="p-2 sm:p-4 space-y-2 sm:space-y-3 bg-card">
        {!configured && (
          <div className="flex items-start gap-2 text-[10px] sm:text-sm text-amber-600 dark:text-amber-400">
            <AlertCircle className="w-4 h-4 flex-shrink-0 mt-0.5" />
            <span>{data.message ?? 'FHIR server not configured.'}</span>
          </div>
        )}
        {configured && !found && (
          <div className="flex items-start gap-2 text-[10px] sm:text-sm text-muted-foreground">
            <AlertCircle className="w-4 h-4 flex-shrink-0 mt-0.5" />
            <span>{data.message ?? 'Patient not found or FHIR request failed.'}</span>
          </div>
        )}
        {configured && found && (
          <div className="space-y-2 sm:space-y-3">
            <div className="flex items-center gap-2 text-green-600 dark:text-green-400 text-[10px] sm:text-sm">
              <CheckCircle2 className="w-4 h-4 flex-shrink-0" />
              <span>Patient loaded from FHIR</span>
            </div>
            <dl className="grid gap-1.5 sm:gap-2 text-[10px] sm:text-sm">
              {data.name != null && (
                <div className="flex justify-between gap-2">
                  <dt className="text-muted-foreground">Name</dt>
                  <dd className="font-medium text-foreground">{data.name}</dd>
                </div>
              )}
              {data.fhirId != null && (
                <div className="flex justify-between gap-2">
                  <dt className="text-muted-foreground">FHIR ID</dt>
                  <dd className="font-mono text-foreground">{data.fhirId}</dd>
                </div>
              )}
              {data.birthDate != null && (
                <div className="flex justify-between gap-2">
                  <dt className="text-muted-foreground">Birth date</dt>
                  <dd className="text-foreground">{data.birthDate}</dd>
                </div>
              )}
              {data.gender != null && (
                <div className="flex justify-between gap-2">
                  <dt className="text-muted-foreground">Gender</dt>
                  <dd className="text-foreground">{data.gender}</dd>
                </div>
              )}
              <div className="flex justify-between gap-2 pt-1 border-t border-border">
                <dt className="text-muted-foreground">Patient ID</dt>
                <dd className="font-mono text-foreground">{data.patientId}</dd>
              </div>
            </dl>
          </div>
        )}
      </div>
    </div>
  );
}
