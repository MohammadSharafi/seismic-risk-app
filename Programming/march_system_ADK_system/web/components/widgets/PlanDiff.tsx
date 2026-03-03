import React from 'react';
import { GitCompare } from 'lucide-react';

export function PlanDiff({ data }: { data: any }) {
  return (
    <div className="border border-emerald-500/30 dark:border-emerald-500/40 rounded-md sm:rounded-lg overflow-hidden bg-emerald-500/10 dark:bg-emerald-500/10 my-2 sm:my-3">
      <div className="bg-emerald-500/15 dark:bg-emerald-500/20 px-2 sm:px-4 py-1.5 sm:py-2 border-b border-emerald-500/30 dark:border-emerald-500/40">
        <div className="flex items-center gap-1.5 sm:gap-2">
          <GitCompare className="w-3 h-3 sm:w-4 sm:h-4 text-emerald-600 dark:text-emerald-400" />
          <h3 className="text-[10px] sm:text-sm font-medium text-emerald-800 dark:text-emerald-200">Plan Comparison</h3>
        </div>
      </div>
      <div className="p-2 sm:p-4 space-y-2 sm:space-y-3 bg-card">
        <div className="flex items-center justify-between text-[9px] sm:text-xs text-muted-foreground gap-2 flex-wrap">
          <span>Comparing: {data.versions.previous} vs {data.versions.current}</span>
          <span className="flex-shrink-0">{data.changesCount} changes</span>
        </div>

        {data.changes.map((change: any, idx: number) => (
          <div key={idx} className="border-l-2 pl-2 sm:pl-3 py-1.5 sm:py-2" style={{
            borderColor: change.type === 'added' ? '#22c55e' :
                        change.type === 'removed' ? '#ef4444' :
                        '#f59e0b'
          }}>
            <div className="flex items-start justify-between mb-1 gap-2">
              <span className="text-[10px] sm:text-sm font-medium text-foreground truncate">{change.section}</span>
              <span className={`px-1.5 sm:px-2 py-0.5 rounded text-[9px] sm:text-xs font-medium flex-shrink-0 ${
                change.type === 'added' ? 'bg-green-500/15 dark:bg-green-500/20 text-green-700 dark:text-green-300' :
                change.type === 'removed' ? 'bg-red-500/15 dark:bg-red-500/20 text-red-700 dark:text-red-300' :
                'bg-amber-500/15 dark:bg-amber-500/20 text-amber-700 dark:text-amber-300'
              }`}>
                {change.type}
              </span>
            </div>
            {change.previous && (
              <div className="text-[10px] sm:text-sm text-red-600 dark:text-red-400 line-through mb-0.5 sm:mb-1">{change.previous}</div>
            )}
            {change.current && (
              <div className="text-[10px] sm:text-sm text-green-600 dark:text-green-400">{change.current}</div>
            )}
            {change.description && (
              <div className="text-[9px] sm:text-xs text-muted-foreground mt-0.5 sm:mt-1">{change.description}</div>
            )}
          </div>
        ))}
      </div>
    </div>
  );
}