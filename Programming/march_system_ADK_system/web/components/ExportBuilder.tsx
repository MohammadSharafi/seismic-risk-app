import React, { useState, useEffect } from 'react';
import { Check, X } from 'lucide-react';

interface ExportBuilderProps {
  onExport: (sections: string[], range: string) => void;
  onClose: () => void;
}

const sections = [
  { id: 'summary', label: 'Summary' },
  { id: 'assessments', label: 'Assessments' },
  { id: 'risk', label: 'Risk' },
  { id: 'alerts', label: 'Alerts' },
  { id: 'twin', label: 'Digital Twin' },
  { id: 'plan', label: 'Treatment Plan' },
  { id: 'note', label: 'Clinical Note' }
];

const timeRanges = [
  { id: 'last_7_days', label: 'Last 7 days' },
  { id: 'last_14_days', label: 'Last 14 days' },
  { id: 'last_30_days', label: 'Last 30 days' },
  { id: 'custom', label: 'Custom range' }
];

export function ExportBuilder({ onExport, onClose }: ExportBuilderProps) {
  const [selectedSections, setSelectedSections] = useState<string[]>(['summary', 'assessments', 'risk', 'plan']);
  const [selectedRange, setSelectedRange] = useState('last_14_days');
  const [showCustom, setShowCustom] = useState(false);

  const toggleSection = (sectionId: string) => {
    setSelectedSections(prev =>
      prev.includes(sectionId)
        ? prev.filter(id => id !== sectionId)
        : [...prev, sectionId]
    );
  };

  const handleRangeSelect = (rangeId: string) => {
    setSelectedRange(rangeId);
    if (rangeId === 'custom') {
      setShowCustom(true);
    } else {
      setShowCustom(false);
    }
  };

  const handleExport = () => {
    onExport(selectedSections, selectedRange);
  };

  // Keyboard shortcuts
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape') {
        e.preventDefault();
        e.stopPropagation();
        onClose();
      } else if (e.key === 'Enter' && (e.metaKey || e.ctrlKey) && selectedSections.length > 0) {
        e.preventDefault();
        e.stopPropagation();
        handleExport();
      }
    };

    window.addEventListener('keydown', handleKeyDown, true);
    return () => window.removeEventListener('keydown', handleKeyDown, true);
  }, [selectedSections, selectedRange, onClose, onExport]);

  return (
    <>
      {/* Backdrop */}
      <div 
        className="fixed inset-0 bg-black/10 z-40"
        onClick={onClose}
      />

      {/* Modal */}
      <div className="fixed bottom-20 sm:bottom-32 left-1/2 -translate-x-1/2 w-full max-w-xl bg-card border border-border rounded-xl sm:rounded-2xl shadow-2xl z-50 p-3 sm:p-6 mx-2 sm:mx-0">
        {/* Header */}
        <div className="flex items-center justify-between mb-3 sm:mb-6">
          <div>
            <h2 className="text-[11px] sm:text-base font-semibold text-foreground">Export PDF</h2>
            <p className="text-[9px] sm:text-sm text-muted-foreground mt-0.5">Select sections and time range</p>
          </div>
          <button
            onClick={onClose}
            className="p-1 sm:p-2 hover:bg-accent rounded-md sm:rounded-lg transition-colors"
          >
            <X className="w-3.5 h-3.5 sm:w-4 sm:h-4 text-muted-foreground" />
          </button>
        </div>

        {/* Sections */}
        <div className="mb-3 sm:mb-6">
          <label className="block text-[10px] sm:text-sm font-medium text-foreground mb-2 sm:mb-3">
            Sections
          </label>
          <div className="grid grid-cols-2 gap-1.5 sm:gap-2">
            {sections.map(section => (
              <button
                key={section.id}
                onClick={() => toggleSection(section.id)}
                className={`
                  flex items-center gap-1.5 sm:gap-2 px-2 sm:px-3 py-1.5 sm:py-2 rounded-md sm:rounded-lg border transition-all
                  ${selectedSections.includes(section.id)
                    ? 'bg-primary/15 border-primary/40 text-primary'
                    : 'bg-card border-border text-foreground hover:bg-accent/50'
                  }
                `}
              >
                <div className={`
                  w-3.5 h-3.5 sm:w-4 sm:h-4 rounded border flex items-center justify-center flex-shrink-0
                  ${selectedSections.includes(section.id)
                    ? 'bg-primary border-primary'
                    : 'border-border'
                  }
                `}>
                  {selectedSections.includes(section.id) && (
                    <Check className="w-2.5 h-2.5 sm:w-3 sm:h-3 text-white" />
                  )}
                </div>
                <span className="text-[10px] sm:text-sm">{section.label}</span>
              </button>
            ))}
          </div>
        </div>

        {/* Time Range */}
        <div className="mb-3 sm:mb-6">
          <label className="block text-[10px] sm:text-sm font-medium text-foreground mb-2 sm:mb-3">
            Time Range
          </label>
          <div className="space-y-1 sm:space-y-1.5">
            {timeRanges.map(range => (
              <button
                key={range.id}
                onClick={() => handleRangeSelect(range.id)}
                className={`
                  w-full text-left px-2 sm:px-3 py-1.5 sm:py-2 rounded-md sm:rounded-lg transition-all text-[10px] sm:text-sm
                  ${selectedRange === range.id
                    ? 'bg-primary/15 text-primary font-medium'
                    : 'text-foreground hover:bg-accent/50'
                  }
                `}
              >
                {range.label}
              </button>
            ))}
          </div>

          {showCustom && (
            <div className="mt-2 sm:mt-3 p-2 sm:p-3 bg-accent/50 rounded-md sm:rounded-lg">
              <div className="grid grid-cols-2 gap-2 sm:gap-3">
                <div>
                  <label className="block text-[9px] sm:text-xs text-muted-foreground mb-1">From</label>
                  <input
                    type="date"
                    className="w-full px-2 py-1 sm:py-1.5 text-[10px] sm:text-sm bg-card text-foreground border border-border rounded-md sm:rounded-lg"
                  />
                </div>
                <div>
                  <label className="block text-[9px] sm:text-xs text-muted-foreground mb-1">To</label>
                  <input
                    type="date"
                    className="w-full px-2 py-1 sm:py-1.5 text-[10px] sm:text-sm bg-card text-foreground border border-border rounded-md sm:rounded-lg"
                  />
                </div>
              </div>
            </div>
          )}
        </div>

        {/* Actions */}
        <div className="flex items-center gap-1.5 sm:gap-2">
          <button
            onClick={handleExport}
            disabled={selectedSections.length === 0}
            className={`
              flex-1 px-3 sm:px-4 py-1.5 sm:py-2.5 rounded-md sm:rounded-lg font-medium text-[10px] sm:text-sm transition-all
              ${selectedSections.length > 0
                ? 'bg-primary text-primary-foreground hover:opacity-90'
                : 'bg-muted text-muted-foreground cursor-not-allowed'
              }
            `}
          >
            Generate PDF ({selectedSections.length} section{selectedSections.length !== 1 ? 's' : ''})
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
