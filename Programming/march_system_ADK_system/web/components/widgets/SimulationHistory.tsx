import React from 'react';
import { History } from 'lucide-react';

export function SimulationHistory({ data }: { data: any }) {
  return (
    <div className="border border-slate-200 border-border rounded-md sm:rounded-lg overflow-hidden bg-card my-2 sm:my-3">
      <div className="bg-slate-50 bg-muted/60 px-2 sm:px-4 py-1.5 sm:py-2 border-b border-slate-200 border-border">
        <div className="flex items-center gap-1.5 sm:gap-2">
          <History className="w-3 h-3 sm:w-4 sm:h-4 text-gray-700" />
          <h3 className="text-[10px] sm:text-sm font-medium text-gray-900">Recent Simulations</h3>
        </div>
      </div>
      <div className="overflow-x-auto">
        <table className="w-full">
          <thead className="bg-slate-50 bg-muted/60 border-b border-slate-200 border-border">
            <tr>
              <th className="px-2 sm:px-4 py-1.5 sm:py-2 text-left text-[9px] sm:text-xs font-medium text-slate-500 text-foreground uppercase tracking-wide">
                SIM-ID
              </th>
              <th className="px-2 sm:px-4 py-1.5 sm:py-2 text-left text-[9px] sm:text-xs font-medium text-slate-500 text-foreground uppercase tracking-wide">
                Scenario
              </th>
              <th className="px-2 sm:px-4 py-1.5 sm:py-2 text-left text-[9px] sm:text-xs font-medium text-slate-500 text-foreground uppercase tracking-wide">
                Horizon
              </th>
              <th className="px-2 sm:px-4 py-1.5 sm:py-2 text-left text-[9px] sm:text-xs font-medium text-slate-500 text-foreground uppercase tracking-wide">
                Key Delta
              </th>
              <th className="px-2 sm:px-4 py-1.5 sm:py-2 text-left text-[9px] sm:text-xs font-medium text-slate-500 text-foreground uppercase tracking-wide">
                Timestamp
              </th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-200 divide-border">
            {data.simulations.map((sim: any) => (
              <tr key={sim.id} className="hover:bg-slate-50 hover:bg-accent/50">
                <td className="px-2 sm:px-4 py-2 sm:py-3 text-[10px] sm:text-sm font-mono text-gray-900">
                  {sim.id}
                </td>
                <td className="px-2 sm:px-4 py-2 sm:py-3 text-[10px] sm:text-sm text-slate-700 text-foreground">
                  {sim.scenario}
                </td>
                <td className="px-2 sm:px-4 py-2 sm:py-3 text-[10px] sm:text-sm text-slate-700 text-foreground">
                  {sim.horizon}
                </td>
                <td className="px-2 sm:px-4 py-2 sm:py-3">
                  <span className={`text-[10px] sm:text-sm font-medium ${
                    sim.delta.startsWith('-') ? 'text-green-700' : 
                    sim.delta.startsWith('+') ? 'text-red-700' : 
                    'text-gray-700'
                  }`}>
                    {sim.delta}
                  </span>
                </td>
                <td className="px-2 sm:px-4 py-2 sm:py-3 text-[10px] sm:text-sm text-slate-500 text-foreground">
                  {sim.timestamp}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
