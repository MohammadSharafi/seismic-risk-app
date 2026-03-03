import React from 'react';
import { TrendingUp, TrendingDown, Minus } from 'lucide-react';

export function AssessOverview({ data }: { data: any }) {
  const id = data?.id ?? '';
  const timestamp = data?.timestamp ?? '';
  const overallScore = typeof data?.overallScore === 'number' ? data.overallScore : 0;
  const status = data?.status ?? '';
  const trend = data?.trend ?? '';
  const trendValue = typeof data?.trendValue === 'number' ? data.trendValue : 0;
  const metrics = Array.isArray(data?.metrics) ? data.metrics : [];
  const getTrendIcon = (t: string) => {
    if (t === 'up') return <TrendingUp className="w-3 h-3 sm:w-4 sm:h-4 text-green-600 dark:text-green-400" />;
    if (t === 'down') return <TrendingDown className="w-3 h-3 sm:w-4 sm:h-4 text-red-600 dark:text-red-400" />;
    return <Minus className="w-3 h-3 sm:w-4 sm:h-4 text-muted-foreground" />;
  };

  const getScoreColor = (score: number) => {
    if (score >= 80) return 'text-green-600 dark:text-green-400';
    if (score >= 60) return 'text-amber-600 dark:text-amber-400';
    return 'text-red-600 dark:text-red-400';
  };

  return (
    <div className="border border-purple-500/30 dark:border-purple-500/40 rounded-md sm:rounded-lg overflow-hidden bg-purple-500/10 dark:bg-purple-500/10 my-2 sm:my-3">
      <div className="bg-purple-500/15 dark:bg-purple-500/20 px-2 sm:px-4 py-1.5 sm:py-2 border-b border-purple-500/30 dark:border-purple-500/40">
        <h3 className="text-[10px] sm:text-sm font-medium text-purple-800 dark:text-purple-200">Assessment Overview</h3>
      </div>
      <div className="p-2 sm:p-4 bg-card">
        <div className="mb-2 sm:mb-4 pb-2 sm:pb-4 border-b border-border">
          <div className="flex items-baseline justify-between mb-1 gap-2">
            <span className="text-[9px] sm:text-xs font-mono text-muted-foreground truncate">{id}</span>
            <span className="text-[9px] sm:text-xs text-muted-foreground flex-shrink-0">{timestamp}</span>
          </div>
          <div className="flex items-end justify-between gap-2">
            <div>
              <div className="text-base sm:text-2xl font-bold text-foreground">{overallScore}/100</div>
              <div className="text-[10px] sm:text-sm text-muted-foreground">{status}</div>
            </div>
            <div className="flex items-center gap-1">
              {getTrendIcon(trend)}
              <span className={`text-[10px] sm:text-sm font-medium ${trendValue > 0 ? 'text-green-600 dark:text-green-400' : trendValue < 0 ? 'text-red-600 dark:text-red-400' : 'text-muted-foreground'}`}>
                {trendValue > 0 ? '+' : ''}{trendValue}
              </span>
            </div>
          </div>
        </div>

        <div className="space-y-2 sm:space-y-3">
          {metrics.map((metric: any, idx: number) => (
            <div key={idx} className="flex items-center justify-between py-1.5 sm:py-2 gap-2">
              <div className="flex-1 min-w-0">
                <div className="text-[10px] sm:text-sm font-medium text-foreground truncate">{metric.name}</div>
              </div>
              <div className="flex items-center gap-2 sm:gap-3 flex-shrink-0">
                <span className={`text-[10px] sm:text-sm font-medium ${getScoreColor(metric.score ?? 0)}`}>
                  {metric.score ?? 0}/100
                </span>
                {metric.trend && (
                  <div className="flex items-center gap-0.5">
                    {getTrendIcon(metric.trend)}
                  </div>
                )}
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}