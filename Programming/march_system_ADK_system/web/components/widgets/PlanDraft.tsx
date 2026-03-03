import React from 'react';
import { FileText } from 'lucide-react';

export function PlanDraft({ data }: { data: any }) {
  const title = data?.title ?? 'Plan';
  const patientName = data?.patientName ?? '';
  const date = data?.date ?? '';
  const sections = Array.isArray(data?.sections) ? data.sections : [];
  const medications = Array.isArray(data?.medications) ? data.medications : [];
  const followUp = data?.followUp ?? '';
  return (
    <div className="border border-green-500/30 dark:border-green-500/40 rounded-md sm:rounded-lg overflow-hidden bg-green-500/10 dark:bg-green-500/10 my-2 sm:my-3">
      <div className="bg-green-500/15 dark:bg-green-500/20 px-2 sm:px-4 py-1.5 sm:py-2 border-b border-green-500/30 dark:border-green-500/40">
        <div className="flex items-center gap-1.5 sm:gap-2">
          <FileText className="w-3 h-3 sm:w-4 sm:h-4 text-green-600 dark:text-green-400" />
          <h3 className="text-[10px] sm:text-sm font-medium text-green-800 dark:text-green-200">Treatment Plan Draft</h3>
        </div>
      </div>
      <div className="p-2 sm:p-4 space-y-2 sm:space-y-4 bg-card">
        <div className="flex items-center justify-between pb-2 sm:pb-3 border-b border-border gap-2">
          <div className="flex-1 min-w-0">
            <div className="text-[10px] sm:text-sm font-medium text-foreground">{title}</div>
            <div className="text-[9px] sm:text-xs text-muted-foreground mt-0.5 sm:mt-1">{patientName} — {date}</div>
          </div>
          <span className="px-1.5 sm:px-2 py-0.5 sm:py-1 bg-amber-500/15 dark:bg-amber-500/20 text-amber-700 dark:text-amber-300 border border-amber-500/40 rounded text-[9px] sm:text-xs font-medium flex-shrink-0">
            Draft
          </span>
        </div>

        {sections.map((section: any, idx: number) => (
          <div key={idx}>
            <div className="text-[10px] sm:text-sm font-medium text-foreground mb-1.5 sm:mb-2">{section.title ?? ''}</div>
            <div className="text-[10px] sm:text-sm text-muted-foreground space-y-1 sm:space-y-1.5">
              {(Array.isArray(section.items) ? section.items : []).map((item: string, i: number) => (
                <div key={i} className="flex items-start gap-1.5 sm:gap-2">
                  <span className="text-muted-foreground mt-0.5">•</span>
                  <span>{item}</span>
                </div>
              ))}
            </div>
          </div>
        ))}

        {medications.length > 0 && (
          <div className="pt-2 sm:pt-3 border-t border-border">
            <div className="text-[10px] sm:text-sm font-medium text-foreground mb-1.5 sm:mb-2">Medications</div>
            <div className="space-y-1.5 sm:space-y-2">
              {medications.map((med: any, i: number) => (
                <div key={i} className="p-1.5 sm:p-2 bg-accent/50 rounded-md sm:rounded text-[10px] sm:text-sm">
                  <div className="font-medium text-foreground">{med?.name ?? ''}</div>
                  <div className="text-muted-foreground">{(med?.dosage ?? '')}{(med?.dosage && med?.frequency) ? ' — ' : ''}{med?.frequency ?? ''}</div>
                </div>
              ))}
            </div>
          </div>
        )}

        {followUp && (
          <div className="pt-2 sm:pt-3 border-t border-border">
            <div className="text-[10px] sm:text-sm font-medium text-foreground mb-1.5 sm:mb-2">Follow-up</div>
            <div className="text-[10px] sm:text-sm text-muted-foreground">{followUp}</div>
          </div>
        )}
      </div>
    </div>
  );
}