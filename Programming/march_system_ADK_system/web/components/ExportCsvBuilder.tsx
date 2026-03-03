import React, { useState, useEffect } from 'react';
import { X } from 'lucide-react';

interface ExportCsvBuilderProps {
  onExport: (dataset: string, range: string) => void;
  onClose: () => void;
}

const datasets = [
  { id: 'assessments', label: 'Assessments' },
  { id: 'vitals', label: 'Vitals' },
  { id: 'alerts', label: 'Alerts' },
  { id: 'risk', label: 'Risk' },
  { id: 'summary', label: 'Summary' },
];

const timeRanges = [
  { id: 'last_7_days', label: 'Last 7 days' },
  { id: 'last_14_days', label: 'Last 14 days' },
  { id: 'last_30_days', label: 'Last 30 days' },
  { id: 'last_6_months', label: 'Last 6 months' },
];

export function ExportCsvBuilder({ onExport, onClose }: ExportCsvBuilderProps) {
  const [dataset, setDataset] = useState('assessments');
  const [range, setRange] = useState('last_30_days');

  const handleExport = () => {
    onExport(dataset, range);
  };

  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape') {
        e.preventDefault();
        onClose();
      }
    };
    window.addEventListener('keydown', handleKeyDown, true);
    return () => window.removeEventListener('keydown', handleKeyDown, true);
  }, [onClose]);

  return (
    <>
      <div className="fixed inset-0 bg-black/10 z-40" onClick={onClose} />
      <div className="fixed bottom-20 sm:bottom-32 left-1/2 -translate-x-1/2 w-full max-w-lg bg-card border border-border rounded-xl sm:rounded-2xl shadow-2xl z-50 p-3 sm:p-6 mx-2">
        <div className="flex items-center justify-between mb-3 sm:mb-4">
          <div>
            <h2 className="text-[11px] sm:text-base font-semibold text-foreground">Export CSV</h2>
            <p className="text-[9px] sm:text-sm text-muted-foreground mt-0.5">Select dataset and time range</p>
          </div>
          <button onClick={onClose} className="p-1 sm:p-2 hover:bg-accent rounded-md sm:rounded-lg transition-colors">
            <X className="w-3.5 h-3.5 sm:w-4 sm:h-4 text-muted-foreground" />
          </button>
        </div>

        <div className="mb-3 sm:mb-4">
          <label className="block text-[10px] sm:text-sm font-medium text-foreground mb-2">Dataset</label>
          <div className="grid grid-cols-2 sm:grid-cols-3 gap-1.5 sm:gap-2">
            {datasets.map((d) => (
              <button
                key={d.id}
                onClick={() => setDataset(d.id)}
                className={`text-left px-2 sm:px-3 py-1.5 sm:py-2 rounded-md sm:rounded-lg text-[10px] sm:text-sm transition-all ${
                  dataset === d.id ? 'bg-primary/15 text-primary font-medium border border-primary/40' : 'bg-card border border-border text-foreground hover:bg-accent/50'
                }`}
              >
                {d.label}
              </button>
            ))}
          </div>
        </div>

        <div className="mb-4 sm:mb-5">
          <label className="block text-[10px] sm:text-sm font-medium text-foreground mb-2">Time range</label>
          <div className="space-y-1 sm:space-y-1.5">
            {timeRanges.map((r) => (
              <button
                key={r.id}
                onClick={() => setRange(r.id)}
                className={`w-full text-left px-2 sm:px-3 py-1.5 sm:py-2 rounded-md sm:rounded-lg text-[10px] sm:text-sm transition-all ${
                  range === r.id ? 'bg-primary/15 text-primary font-medium' : 'text-foreground hover:bg-accent/50'
                }`}
              >
                {r.label}
              </button>
            ))}
          </div>
        </div>

        <div className="flex items-center gap-2">
          <button
            onClick={handleExport}
            className="flex-1 px-3 sm:px-4 py-1.5 sm:py-2.5 rounded-md sm:rounded-lg font-medium text-[10px] sm:text-sm bg-primary text-primary-foreground hover:opacity-90 transition-colors"
          >
            Export CSV
          </button>
          <button
            onClick={onClose}
            className="px-3 sm:px-4 py-1.5 sm:py-2.5 rounded-md sm:rounded-lg font-medium text-[10px] sm:text-sm text-foreground hover:bg-accent transition-colors"
          >
            Cancel
          </button>
        </div>
      </div>
    </>
  );
}
