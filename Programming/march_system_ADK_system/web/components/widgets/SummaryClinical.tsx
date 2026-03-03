import React from 'react';

const WINDOW_LABELS: Record<string, string> = {
  last_7_days: 'Last 7 days',
  last_24_hours: 'Last 24 hours'
};

export function SummaryClinical({ data }: { data: any }) {
  const hasSections = Array.isArray(data?.sections) && data.sections.length > 0;
  const windowLabel = data?.window && WINDOW_LABELS[data.window] ? WINDOW_LABELS[data.window] : null;
  return (
    <div className="border border-border rounded-md sm:rounded-lg overflow-hidden bg-secondary/50 my-2 sm:my-3">
      <div className="bg-secondary px-2 sm:px-4 py-1.5 sm:py-2 border-b border-border">
        <h3 className="text-[10px] sm:text-sm font-medium text-foreground">
          Clinical Summary{windowLabel ? ` (${windowLabel})` : ''}
        </h3>
      </div>
      <div className="p-2 sm:p-4 space-y-2 sm:space-y-4 bg-card">
        {hasSections ? (
          data.sections.map((section: any, idx: number) => (
            <div key={idx}>
              <div className="text-[10px] sm:text-sm font-medium text-foreground mb-1.5 sm:mb-2">{section.title}</div>
              <div className="text-[10px] sm:text-sm text-muted-foreground space-y-1">
                {section.items?.map((item: string, i: number) => (
                  <div key={i} className="flex items-start gap-1.5 sm:gap-2">
                    <span className="text-muted-foreground mt-0.5 sm:mt-1">•</span>
                    <span>{item}</span>
                  </div>
                ))}
              </div>
            </div>
          ))
        ) : (
          <p className="text-[10px] sm:text-sm text-muted-foreground">{data?.summary ?? 'No summary data.'}</p>
        )}
      </div>
    </div>
  );
}