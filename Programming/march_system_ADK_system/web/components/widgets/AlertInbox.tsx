import React from 'react';
import { AlertCircle, Info } from 'lucide-react';

const FILTER_LABELS: Record<string, string> = {
  unacknowledged: 'Unacknowledged only',
  acknowledged: 'Acknowledged only',
  all: 'All alerts'
};

export function AlertInbox({ data }: { data: any }) {
  const alerts = Array.isArray(data?.alerts) ? data.alerts : [];
  const filterLabel = data?.filter && FILTER_LABELS[data.filter] ? FILTER_LABELS[data.filter] : null;
  const getAlertIcon = (severity: string) => {
    if (severity === 'high' || severity === 'moderate') {
      return <AlertCircle className="w-3 h-3 sm:w-4 sm:h-4" />;
    }
    return <Info className="w-3 h-3 sm:w-4 sm:h-4" />;
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
      <div className="bg-amber-500/15 dark:bg-amber-500/20 px-2 sm:px-4 py-1.5 sm:py-2 border-b border-amber-500/30 dark:border-amber-500/40 flex items-center justify-between gap-2 flex-wrap">
        <h3 className="text-[10px] sm:text-sm font-medium text-amber-800 dark:text-amber-200">
          Active Alerts{filterLabel ? ` (${filterLabel})` : ''}
        </h3>
        <span className="text-[9px] sm:text-xs text-amber-700 dark:text-amber-300 flex-shrink-0">{alerts.length} total</span>
      </div>
      <div className="divide-y divide-border bg-card">
        {alerts.map((alert: any, idx: number) => (
          <div key={idx} className="p-2 sm:p-4 hover:bg-accent/50">
            <div className="flex items-start gap-2 sm:gap-3">
              <div className={`mt-0.5 flex-shrink-0 rounded px-1.5 py-0.5 border ${getAlertColor(alert.severity)}`}>
                {getAlertIcon(alert.severity)}
              </div>
              <div className="flex-1 min-w-0">
                <div className="flex items-start justify-between gap-2 mb-1">
                  <span className="text-[10px] sm:text-sm font-medium text-foreground">{alert.title}</span>
                  <span className={`px-1.5 sm:px-2 py-0.5 rounded text-[9px] sm:text-xs font-medium border flex-shrink-0 ${getAlertColor(alert.severity)}`}>
                    {alert.severity}
                  </span>
                </div>
                <div className="text-[10px] sm:text-sm text-muted-foreground mb-1.5 sm:mb-2">{alert.description}</div>
                <div className="flex items-center gap-2 sm:gap-3 text-[9px] sm:text-xs text-muted-foreground flex-wrap">
                  <span className="font-mono">{alert.id}</span>
                  <span>•</span>
                  <span>{alert.timestamp}</span>
                  {alert.category && (
                    <>
                      <span>•</span>
                      <span>{alert.category}</span>
                    </>
                  )}
                </div>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}