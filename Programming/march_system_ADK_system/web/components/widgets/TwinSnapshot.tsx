import React from 'react';
import { Activity } from 'lucide-react';

export function TwinSnapshot({ data }: { data: any }) {
  const confidence = data?.confidence ?? 0;
  const completeness = data?.completeness ?? 0;
  const metrics = Array.isArray(data?.metrics) ? data.metrics : [];
  const state = Array.isArray(data?.state) ? data.state : [];
  const lastUpdated = data?.lastUpdated ?? '';
  return (
    <div className="border border-sky-500/30 dark:border-sky-500/40 rounded-md sm:rounded-lg overflow-hidden bg-sky-500/10 dark:bg-sky-500/10 my-2 sm:my-3">
      <div className="bg-sky-500/15 dark:bg-sky-500/20 px-2 sm:px-4 py-1.5 sm:py-2 border-b border-sky-500/30 dark:border-sky-500/40">
        <div className="flex items-center gap-1.5 sm:gap-2">
          <Activity className="w-3 h-3 sm:w-4 sm:h-4 text-sky-600 dark:text-sky-400" />
          <h3 className="text-[10px] sm:text-sm font-medium text-sky-800 dark:text-sky-200">Digital Twin Snapshot</h3>
        </div>
      </div>
      <div className="p-2 sm:p-4 space-y-2 sm:space-y-4 bg-card">
        <div className="flex items-center justify-between gap-2 flex-wrap">
          <span className="text-[10px] sm:text-sm text-muted-foreground">Twin Quality</span>
          <div className="flex items-center gap-2 sm:gap-3">
            <span className="text-[9px] sm:text-sm text-foreground">Confidence: <span className="font-medium">{confidence}%</span></span>
            <span className="text-[9px] sm:text-sm text-foreground">Completeness: <span className="font-medium">{completeness}%</span></span>
          </div>
        </div>

        <div className="grid grid-cols-2 gap-2 sm:gap-3">
          {metrics.map((metric: any, idx: number) => (
            <div key={idx} className="p-2 sm:p-3 bg-accent/50 rounded-md sm:rounded-lg">
              <div className="text-[9px] sm:text-xs text-muted-foreground mb-0.5 sm:mb-1">{metric.name}</div>
              <div className="text-sm sm:text-lg font-medium text-foreground">{metric.value}</div>
              {metric.unit && (
                <div className="text-[9px] sm:text-xs text-muted-foreground">{metric.unit}</div>
              )}
            </div>
          ))}
        </div>

        {state.length > 0 && (
          <div className="pt-2 sm:pt-3 border-t border-border">
            <div className="text-[9px] sm:text-xs font-medium text-muted-foreground uppercase tracking-wide mb-1.5 sm:mb-2">
              Current State
            </div>
            <div className="space-y-1.5 sm:space-y-2">
              {state.map((item: any, i: number) => (
                <div key={i} className="flex items-center justify-between text-[10px] sm:text-sm gap-2">
                  <span className="text-muted-foreground truncate">{item.name}</span>
                  <span className="font-medium text-foreground flex-shrink-0">{item.value}</span>
                </div>
              ))}
            </div>
          </div>
        )}

        {lastUpdated && (
          <div className="pt-1.5 sm:pt-2 text-[9px] sm:text-xs text-muted-foreground">
            Last updated: {lastUpdated}
          </div>
        )}
      </div>
    </div>
  );
}