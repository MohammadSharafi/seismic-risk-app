import React from 'react';

export function AssessDetail({ data }: { data: any }) {
  return (
    <div className="border border-purple-200 rounded-md sm:rounded-lg overflow-hidden bg-purple-50 my-2 sm:my-3">
      <div className="bg-purple-100 px-2 sm:px-4 py-1.5 sm:py-2 border-b border-purple-200">
        <h3 className="text-[10px] sm:text-sm font-medium text-purple-900">Assessment Detail</h3>
      </div>
      <div className="p-2 sm:p-4 space-y-2 sm:space-y-4 bg-card">
        <div className="flex items-center justify-between pb-2 sm:pb-3 border-b border-border gap-2">
          <div className="flex-1 min-w-0">
            <div className="text-[9px] sm:text-xs font-mono text-slate-500 text-muted-foreground mb-0.5 sm:mb-1">{data.id}</div>
            <div className="text-sm sm:text-lg font-bold text-foreground">{data.title}</div>
          </div>
          <div className="text-right flex-shrink-0">
            <div className="text-base sm:text-2xl font-bold text-foreground">{data.score}/100</div>
            <div className="text-[9px] sm:text-xs text-slate-500 text-muted-foreground">{data.timestamp}</div>
          </div>
        </div>

        {data.dimensions.map((dim: any, idx: number) => (
          <div key={idx} className="space-y-1.5 sm:space-y-2">
            <div className="flex items-center justify-between gap-2">
              <span className="text-[10px] sm:text-sm font-medium text-gray-900 truncate">{dim.name}</span>
              <span className="text-[10px] sm:text-sm font-medium text-gray-900 flex-shrink-0">{dim.score}/100</span>
            </div>
            <div className="w-full bg-slate-200 bg-muted rounded-full h-1.5 sm:h-2">
              <div
                className={`h-1.5 sm:h-2 rounded-full ${
                  dim.score >= 80 ? 'bg-green-500' :
                  dim.score >= 60 ? 'bg-amber-500' :
                  'bg-red-500'
                }`}
                style={{ width: `${dim.score}%` }}
              />
            </div>
            {dim.notes && (
              <div className="text-[9px] sm:text-xs text-muted-foreground">{dim.notes}</div>
            )}
          </div>
        ))}

        {data.summary && (
          <div className="pt-2 sm:pt-3 border-t border-border">
            <div className="text-[9px] sm:text-xs font-medium text-slate-500 text-muted-foreground uppercase tracking-wide mb-1.5 sm:mb-2">
              Summary
            </div>
            <div className="text-[10px] sm:text-sm text-foreground">{data.summary}</div>
          </div>
        )}
      </div>
    </div>
  );
}