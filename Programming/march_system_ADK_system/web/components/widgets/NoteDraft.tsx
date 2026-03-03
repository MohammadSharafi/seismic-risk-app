import React from 'react';
import { FileText } from 'lucide-react';

export function NoteDraft({ data }: { data: any }) {
  const type = data?.type ?? 'Note';
  const patientName = data?.patientName ?? '';
  const date = data?.date ?? '';
  const sections = Array.isArray(data?.sections) ? data.sections : [];
  const noteId = data?.noteId ?? '';
  return (
    <div className="border border-primary/30 dark:border-primary/40 rounded-md sm:rounded-lg overflow-hidden bg-primary/5 dark:bg-primary/5 my-2 sm:my-3">
      <div className="bg-primary/10 dark:bg-primary/15 px-2 sm:px-4 py-1.5 sm:py-2 border-b border-primary/30 dark:border-primary/40">
        <div className="flex items-center gap-1.5 sm:gap-2">
          <FileText className="w-3 h-3 sm:w-4 sm:h-4 text-primary" />
          <h3 className="text-[10px] sm:text-sm font-medium text-primary">Clinical Note Draft</h3>
        </div>
      </div>
      <div className="p-2 sm:p-4 space-y-2 sm:space-y-3 bg-card">
        <div className="flex items-center justify-between pb-2 sm:pb-3 border-b border-border gap-2">
          <div className="flex-1 min-w-0">
            <div className="text-[10px] sm:text-sm font-medium text-foreground">{type}</div>
            <div className="text-[9px] sm:text-xs text-slate-500 text-muted-foreground mt-0.5 sm:mt-1">{patientName} — {date}</div>
          </div>
          <span className="px-1.5 sm:px-2 py-0.5 sm:py-1 bg-amber-500/15 dark:bg-amber-500/20 text-amber-700 dark:text-amber-300 border border-amber-500/40 rounded text-[9px] sm:text-xs font-medium flex-shrink-0">
            Draft
          </span>
        </div>

        <div className="prose prose-sm max-w-none">
          {sections.map((section: any, idx: number) => (
            <div key={idx} className="mb-2 sm:mb-3">
              <div className="text-[10px] sm:text-sm font-medium text-foreground uppercase tracking-wide mb-0.5 sm:mb-1">
                {section.heading}
              </div>
              <div className="text-[10px] sm:text-sm text-foreground whitespace-pre-wrap">
                {section.content}
              </div>
            </div>
          ))}
        </div>

        {noteId && (
          <div className="pt-2 sm:pt-3 border-t border-border text-[9px] sm:text-xs text-slate-500 text-muted-foreground">
            Note ID: {noteId}
          </div>
        )}
      </div>
    </div>
  );
}