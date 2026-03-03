import React from 'react';
import { Zap, TrendingDown, TrendingUp } from 'lucide-react';

export function TwinSimulation({ data }: { data: any }) {
  const baselineRisk = data?.baselineRisk ?? 0;
  const scenarioRisk = data?.scenarioRisk ?? 0;
  const delta = typeof data?.delta === 'number' ? data.delta : 0;
  const confidence = data?.confidence ?? 0;
  const completeness = data?.completeness ?? 0;
  const horizon = data?.horizon ?? '';
  const scenario = data?.scenario ?? '';
  const sources = data?.sources ?? 0;
  const timestamp = data?.timestamp ?? '';
  const runId = data?.runId ?? '';
  const kpiDeltas = Array.isArray(data?.kpiDeltas) ? data.kpiDeltas : [];
  const drivers = Array.isArray(data?.drivers) ? data.drivers : [];
  const assumptions = data?.assumptions ?? '';
  const getDeltaColor = (d: number) => {
    if (d < 0) return 'text-green-700';
    if (d > 0) return 'text-red-700';
    return 'text-gray-700';
  };

  const getDeltaIcon = (d: number) => {
    if (d < 0) return <TrendingDown className="w-3 h-3 sm:w-4 sm:h-4" />;
    if (d > 0) return <TrendingUp className="w-3 h-3 sm:w-4 sm:h-4" />;
    return null;
  };

  return (
    <div className="border border-teal-200 rounded-md sm:rounded-lg overflow-hidden bg-card my-2 sm:my-3">
      {/* Header with baseline vs scenario */}
      <div className="bg-gradient-to-r from-blue-50 to-blue-100 px-2 sm:px-4 py-1.5 sm:py-3 border-b border-teal-200">
        <div className="flex items-center justify-between gap-2 flex-wrap">
          <div className="flex items-center gap-1.5 sm:gap-2">
            <Zap className="w-3 h-3 sm:w-4 sm:h-4 text-teal-700" />
            <h3 className="text-[10px] sm:text-sm font-medium text-blue-900">Simulation Result</h3>
          </div>
            <div className="flex items-center gap-2 sm:gap-4 text-[9px] sm:text-sm">
            <div className="flex items-center gap-1 sm:gap-1.5">
              <span className="text-[9px] sm:text-xs text-teal-700">Confidence</span>
              <span className="font-medium text-blue-900 text-[9px] sm:text-sm">{confidence}%</span>
            </div>
            <div className="flex items-center gap-1 sm:gap-1.5">
              <span className="text-[9px] sm:text-xs text-teal-700">Completeness</span>
              <span className="font-medium text-blue-900 text-[9px] sm:text-sm">{completeness}%</span>
            </div>
          </div>
        </div>
      </div>

      <div className="p-2 sm:p-4 space-y-2 sm:space-y-4">
        {/* Primary comparison: Baseline vs Scenario */}
        <div className="grid grid-cols-3 gap-2 sm:gap-4 p-2 sm:p-3 bg-muted/60 rounded-md sm:rounded-lg border border-border">
          <div>
            <div className="text-[9px] sm:text-xs text-slate-500 text-foreground mb-0.5 sm:mb-1">Baseline Risk</div>
            <div className="text-base sm:text-2xl font-semibold text-gray-900">{baselineRisk}%</div>
            <div className="text-[9px] sm:text-xs text-slate-500 text-foreground mt-0.5">{horizon}</div>
          </div>
          <div className="flex items-center justify-center">
            <div className="text-center">
              <div className={`flex items-center gap-1 sm:gap-1.5 justify-center text-base sm:text-2xl font-bold ${getDeltaColor(delta)}`}>
                {getDeltaIcon(delta)}
                {delta > 0 ? '+' : ''}{delta}%
              </div>
              <div className="text-[9px] sm:text-xs text-slate-500 text-foreground mt-0.5 sm:mt-1">Delta</div>
            </div>
          </div>
          <div>
            <div className="text-[9px] sm:text-xs text-slate-500 text-foreground mb-0.5 sm:mb-1">Scenario Risk</div>
            <div className="text-base sm:text-2xl font-semibold text-teal-700">{scenarioRisk}%</div>
            <div className="text-[9px] sm:text-xs text-slate-500 text-foreground mt-0.5">{scenario}</div>
          </div>
        </div>

        {/* KPI Deltas */}
        {kpiDeltas.length > 0 && (
          <div className="space-y-1.5 sm:space-y-2">
            <div className="text-[9px] sm:text-xs font-medium text-slate-500 text-foreground uppercase tracking-wide">
              Key Performance Indicators
            </div>
            <div className="space-y-1.5 sm:space-y-2">
              {kpiDeltas.map((kpi: any, i: number) => (
                <div key={i} className="flex items-center justify-between p-1.5 sm:p-2.5 bg-muted rounded-md sm:rounded-lg border border-border gap-2">
                  <span className="text-[10px] sm:text-sm text-slate-700 text-foreground truncate">{kpi.name}</span>
                  <div className="flex items-center gap-1.5 sm:gap-3 flex-shrink-0">
                    <span className="text-[9px] sm:text-sm text-slate-500 text-foreground">{kpi.baseline}</span>
                    <span className="text-muted-foreground text-[10px] sm:text-sm">→</span>
                    <div className="flex items-center gap-1 sm:gap-1.5">
                      <span className={`text-[9px] sm:text-sm font-medium ${getDeltaColor(kpi.deltaValue)}`}>
                        {kpi.scenario}
                      </span>
                      {kpi.deltaValue !== 0 && (
                        <span className={`text-[8px] sm:text-xs ${getDeltaColor(kpi.deltaValue)}`}>
                          ({kpi.deltaValue > 0 ? '+' : ''}{kpi.deltaValue}%)
                        </span>
                      )}
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Top 3 drivers */}
        {drivers.length > 0 && (
          <div className="space-y-1.5 sm:space-y-2">
            <div className="text-[9px] sm:text-xs font-medium text-slate-500 text-foreground uppercase tracking-wide">
              Top Contributing Factors
            </div>
            <div className="space-y-1 sm:space-y-1.5">
              {drivers.map((driver: string, i: number) => (
                <div key={i} className="flex items-start gap-1.5 sm:gap-2 text-[10px] sm:text-sm text-slate-700 text-foreground">
                  <span className="text-muted-foreground mt-0.5">•</span>
                  <span>{driver}</span>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Assumptions */}
        {assumptions && (
          <div className="p-2 sm:p-3 bg-teal-50 rounded-md sm:rounded-lg border border-teal-200">
            <div className="text-[9px] sm:text-xs font-medium text-teal-700 uppercase tracking-wide mb-1 sm:mb-1.5">
              Key Assumptions
            </div>
            <div className="text-[10px] sm:text-sm text-blue-900">{assumptions}</div>
          </div>
        )}

        {/* Evidence footer */}
        <div className="pt-2 sm:pt-3 border-t border-border flex items-center justify-between text-[9px] sm:text-xs text-slate-500 text-foreground flex-wrap gap-1">
          <div className="flex items-center gap-2 sm:gap-3 flex-wrap">
            <span>{sources} sources</span>
            <span>•</span>
            <span>Generated {timestamp}</span>
          </div>
          {runId && <span className="font-mono text-slate-600 text-foreground text-[8px] sm:text-xs">{runId}</span>}
        </div>
      </div>
    </div>
  );
}
