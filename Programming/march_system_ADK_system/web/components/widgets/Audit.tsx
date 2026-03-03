import React from 'react';
import { CheckCircle2 } from 'lucide-react';

export function Audit({ data }: { data: any }) {
  return (
    <div className="border border-border rounded-md sm:rounded-lg overflow-hidden bg-accent/50 my-2 sm:my-3">
      <div className="bg-accent px-2 sm:px-4 py-1.5 sm:py-2 border-b border-border">
        <div className="flex items-center gap-1.5 sm:gap-2">
          <CheckCircle2 className="w-3 h-3 sm:w-4 sm:h-4 text-muted-foreground" />
          <h3 className="text-[10px] sm:text-sm font-medium text-foreground">Action Confirmed</h3>
        </div>
      </div>
      <div className="p-2 sm:p-4 space-y-2 sm:space-y-3 bg-card">
        <div className="text-[10px] sm:text-sm text-foreground">
          <span className="font-medium">{data.action}</span>
          {data.target && <span> — {data.target}</span>}
        </div>

        {data.details && (
          <div className="space-y-1.5 sm:space-y-2">
            {data.details.map((detail: any, i: number) => (
              <div key={i} className="flex items-start justify-between text-[10px] sm:text-sm gap-2">
                <span className="text-muted-foreground truncate">{detail.label}</span>
                <span className="font-medium text-foreground text-right flex-shrink-0">{detail.value}</span>
              </div>
            ))}
          </div>
        )}

        <div className="pt-1.5 sm:pt-2 border-t border-border flex items-center justify-between text-[9px] sm:text-xs text-muted-foreground gap-2 flex-wrap">
          <span>Logged by: {data.user}</span>
          <span className="flex-shrink-0">{data.timestamp}</span>
        </div>

        {data.auditId && (
          <div className="text-[9px] sm:text-xs text-muted-foreground font-mono">
            Audit ID: {data.auditId}
          </div>
        )}
      </div>
    </div>
  );
}