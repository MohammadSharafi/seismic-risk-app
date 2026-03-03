import React from 'react';
import { AlertCircle, Info } from 'lucide-react';

export function AlertDetail({ data }: { data: any }) {
  const getAlertIcon = (severity: string) => {
    if (severity === 'high' || severity === 'moderate') {
      return <AlertCircle className="w-3.5 h-3.5 sm:w-5 sm:h-5" />;
    }
    return <Info className="w-3.5 h-3.5 sm:w-5 sm:h-5" />;
  };

  const getAlertColor = (severity: string) => {
    switch (severity.toLowerCase()) {
      case 'high': return 'bg-red-500/15 dark:bg-red-500/20 border-red-300 dark:border-red-600 text-red-700 dark:text-red-300';
      case 'moderate': return 'bg-amber-500/15 dark:bg-amber-500/20 border-amber-300 dark:border-amber-600 text-amber-700 dark:text-amber-300';
      default: return 'bg-primary/15 dark:bg-primary/20 border-primary/40 dark:border-primary/50 text-primary';
    }
  };

  return (
    <div className="border border-amber-500/30 dark:border-amber-500/40 rounded-md sm:rounded-lg overflow-hidden bg-amber-500/10 dark:bg-amber-500/10 my-2 sm:my-3">
      <div className="bg-amber-500/15 dark:bg-amber-500/20 px-2 sm:px-4 py-1.5 sm:py-2 border-b border-amber-500/30 dark:border-amber-500/40">
        <h3 className="text-[10px] sm:text-sm font-medium text-amber-800 dark:text-amber-200">Alert Detail</h3>
      </div>
      <div className="p-2 sm:p-4 space-y-2 sm:space-y-4 bg-card">
        <div className="flex items-start gap-2 sm:gap-3">
          <div className={`flex-shrink-0 rounded px-1.5 py-0.5 border ${getAlertColor(data.severity)}`}>
            {getAlertIcon(data.severity)}
          </div>
          <div className="flex-1 min-w-0">
            <div className="flex items-start justify-between gap-2 mb-1.5 sm:mb-2">
              <h4 className="text-[10px] sm:text-sm font-medium text-foreground">{data.title}</h4>
              <span className={`px-1.5 sm:px-2 py-0.5 rounded text-[9px] sm:text-xs font-medium border flex-shrink-0 ${getAlertColor(data.severity)}`}>
                {data.severity}
              </span>
            </div>
            <div className="text-[10px] sm:text-sm text-muted-foreground mb-2 sm:mb-3">{data.description}</div>
            <div className="flex flex-wrap gap-1.5 sm:gap-2 text-[9px] sm:text-xs text-muted-foreground">
              <span className="font-mono">{data.id}</span>
              <span>•</span>
              <span>{data.timestamp}</span>
              <span>•</span>
              <span>{data.category}</span>
            </div>
          </div>
        </div>

        {data.context && (
          <div className="pt-2 sm:pt-3 border-t border-border">
            <div className="text-[9px] sm:text-xs font-medium text-muted-foreground uppercase tracking-wide mb-1.5 sm:mb-2">
              Context
            </div>
            <div className="text-[10px] sm:text-sm text-muted-foreground space-y-1">
              {data.context.map((item: string, i: number) => (
                <div key={i}>• {item}</div>
              ))}
            </div>
          </div>
        )}

        {data.recommendations && (
          <div className="pt-2 sm:pt-3 border-t border-border">
            <div className="text-[9px] sm:text-xs font-medium text-muted-foreground uppercase tracking-wide mb-1.5 sm:mb-2">
              Recommendations
            </div>
            <div className="text-[10px] sm:text-sm text-muted-foreground space-y-1">
              {data.recommendations.map((item: string, i: number) => (
                <div key={i}>• {item}</div>
              ))}
            </div>
          </div>
        )}
      </div>
    </div>
  );
}