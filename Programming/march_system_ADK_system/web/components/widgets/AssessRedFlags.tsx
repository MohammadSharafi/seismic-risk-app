import React from 'react';
import { AlertTriangle } from 'lucide-react';

export function AssessRedFlags({ data }: { data: any }) {
  const flags = Array.isArray(data?.flags) ? data.flags : [];
  return (
    <div className="border border-purple-500/30 dark:border-purple-500/40 rounded-md sm:rounded-lg overflow-hidden bg-purple-500/10 dark:bg-purple-500/10 my-2 sm:my-3">
      <div className="bg-purple-500/15 dark:bg-purple-500/20 px-2 sm:px-4 py-1.5 sm:py-2 border-b border-purple-500/30 dark:border-purple-500/40">
        <div className="flex items-center gap-1.5 sm:gap-2">
          <AlertTriangle className="w-3 h-3 sm:w-4 sm:h-4 text-purple-600 dark:text-purple-400" />
          <h3 className="text-[10px] sm:text-sm font-medium text-purple-800 dark:text-purple-200">Red Flags Requiring Attention</h3>
        </div>
      </div>
      <div className="p-2 sm:p-4 space-y-2 sm:space-y-3 bg-card">
        {flags.map((flag: any, idx: number) => (
          <div key={idx} className="p-2 sm:p-3 bg-purple-500/10 dark:bg-purple-500/10 rounded-md sm:rounded-lg border border-purple-500/30 dark:border-purple-500/40">
            <div className="flex items-start justify-between mb-1.5 sm:mb-2 gap-2">
              <div className="flex-1 min-w-0">
                <div className="text-[10px] sm:text-sm font-medium text-foreground">{flag.title}</div>
                <div className="text-[9px] sm:text-xs text-muted-foreground mt-0.5 sm:mt-1">{flag.description}</div>
              </div>
              {flag.requiresAck && (
                <span className="ml-1.5 sm:ml-2 px-1.5 sm:px-2 py-0.5 bg-red-500/15 dark:bg-red-500/20 text-red-700 dark:text-red-300 rounded text-[9px] sm:text-xs font-medium whitespace-nowrap flex-shrink-0">
                  Acknowledgement Required
                </span>
              )}
            </div>
            <div className="flex items-center gap-1.5 sm:gap-2 text-[9px] sm:text-xs text-muted-foreground flex-wrap">
              <span className="font-mono">{flag.id}</span>
              <span>•</span>
              <span>{flag.timestamp}</span>
              {flag.metric && (
                <>
                  <span>•</span>
                  <span>{flag.metric}</span>
                </>
              )}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}