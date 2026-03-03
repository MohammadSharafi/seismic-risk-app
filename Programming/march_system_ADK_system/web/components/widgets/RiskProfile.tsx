import React from 'react';

export function RiskProfile({ data }: { data: any }) {
  const overall = data?.overall ?? '—';
  const categories = Array.isArray(data?.categories) ? data.categories : [];
  const getRiskColor = (level: string) => {
    switch (level.toLowerCase()) {
      case 'high': return 'bg-red-500/15 dark:bg-red-500/20 text-red-700 dark:text-red-300 border-red-300 dark:border-red-600';
      case 'moderate': return 'bg-amber-500/15 dark:bg-amber-500/20 text-amber-700 dark:text-amber-300 border-amber-300 dark:border-amber-600';
      case 'low': return 'bg-green-500/15 dark:bg-green-500/20 text-green-700 dark:text-green-300 border-green-300 dark:border-green-600';
      default: return 'bg-muted text-muted-foreground border-border';
    }
  };

  return (
    <div className="border border-rose-500/30 dark:border-rose-500/40 rounded-md sm:rounded-lg overflow-hidden bg-rose-500/10 dark:bg-rose-500/10 my-2 sm:my-3">
      <div className="bg-rose-500/15 dark:bg-rose-500/20 px-2 sm:px-4 py-1.5 sm:py-2 border-b border-rose-500/30 dark:border-rose-500/40">
        <h3 className="text-[10px] sm:text-sm font-medium text-rose-800 dark:text-rose-200">Risk Profile</h3>
      </div>
      <div className="p-2 sm:p-4 bg-card">
        <div className="flex items-center justify-between mb-2 sm:mb-4 gap-2">
          <span className="text-[10px] sm:text-sm text-muted-foreground">Overall Risk Level</span>
          <span className={`px-2 sm:px-3 py-0.5 sm:py-1 rounded-full text-[9px] sm:text-sm font-medium border flex-shrink-0 ${getRiskColor(overall)}`}>
            {overall}
          </span>
        </div>
        <div className="space-y-2 sm:space-y-3">
          {categories.map((cat: any, idx: number) => (
            <div key={idx} className="flex items-center justify-between py-1.5 sm:py-2 border-b border-border last:border-0 gap-2">
              <div className="flex-1 min-w-0">
                <div className="text-[10px] sm:text-sm font-medium text-foreground">{cat.name}</div>
                <div className="text-[9px] sm:text-xs text-muted-foreground">{cat.description}</div>
              </div>
              <span className={`ml-2 sm:ml-4 px-1.5 sm:px-2 py-0.5 sm:py-1 rounded text-[9px] sm:text-xs font-medium border flex-shrink-0 ${getRiskColor(cat.level)}`}>
                {cat.level}
              </span>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}