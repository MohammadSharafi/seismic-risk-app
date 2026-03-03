import React from 'react';
import { TrendingUp, TrendingDown } from 'lucide-react';

export function RiskDrivers({ data }: { data: any }) {
  const drivers = Array.isArray(data?.drivers) ? data.drivers : [];
  return (
    <div className="border border-orange-200 rounded-md sm:rounded-lg overflow-hidden bg-orange-50 my-2 sm:my-3">
      <div className="bg-orange-100 px-2 sm:px-4 py-1.5 sm:py-2 border-b border-orange-200">
        <h3 className="text-[10px] sm:text-sm font-medium text-orange-900">Risk Drivers</h3>
      </div>
      <div className="p-2 sm:p-4 space-y-2 sm:space-y-3 bg-card">
        {drivers.map((driver: any, idx: number) => (
          <div key={idx} className="p-2 sm:p-3 bg-slate-50 bg-muted/60 rounded-md sm:rounded-lg">
            <div className="flex items-start justify-between mb-1.5 sm:mb-2 gap-2">
              <div className="flex-1 min-w-0">
                <div className="text-[10px] sm:text-sm font-medium text-gray-900">{driver.name ?? ''}</div>
                <div className="text-[9px] sm:text-xs text-slate-500 text-foreground mt-0.5 sm:mt-1">{driver.description ?? ''}</div>
              </div>
              <div className="ml-2 sm:ml-3 flex items-center gap-1 flex-shrink-0">
                {driver.trend === 'up' ? (
                  <TrendingUp className="w-3 h-3 sm:w-4 sm:h-4 text-red-500" />
                ) : (
                  <TrendingDown className="w-3 h-3 sm:w-4 sm:h-4 text-green-500" />
                )}
                <span className="text-[10px] sm:text-sm font-medium text-gray-900">{driver.contribution ?? 0}%</span>
              </div>
            </div>
            {driver.values && (
              <div className="flex items-center gap-1.5 sm:gap-2 text-[9px] sm:text-xs text-slate-500 text-foreground flex-wrap">
                <span>Current: {driver.values.current}</span>
                <span>•</span>
                <span>Baseline: {driver.values.baseline}</span>
              </div>
            )}
          </div>
        ))}
      </div>
    </div>
  );
}