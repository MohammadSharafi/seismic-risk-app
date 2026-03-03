import React, { useState, useEffect } from 'react';
import { X, ChevronRight } from 'lucide-react';

interface Option {
  id: string;
  label: string;
  description?: string;
}

interface QuickSelectionPaletteProps {
  title: string;
  subtitle: string;
  options: Option[];
  onSelect: (optionId: string) => void;
  onClose: () => void;
}

export function QuickSelectionPalette({ 
  title, 
  subtitle, 
  options, 
  onSelect, 
  onClose 
}: QuickSelectionPaletteProps) {
  const [selectedIndex, setSelectedIndex] = useState(0);

  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      // Check if user is typing in an input/textarea
      const activeElement = document.activeElement;
      if (activeElement && (activeElement.tagName === 'INPUT' || activeElement.tagName === 'TEXTAREA')) {
        return;
      }

      if (e.key === 'ArrowDown') {
        e.preventDefault();
        e.stopPropagation();
        setSelectedIndex(prev => (prev + 1) % options.length);
      } else if (e.key === 'ArrowUp') {
        e.preventDefault();
        e.stopPropagation();
        setSelectedIndex(prev => (prev - 1 + options.length) % options.length);
      } else if (e.key === 'Enter') {
        e.preventDefault();
        e.stopPropagation();
        if (options[selectedIndex]) {
          onSelect(options[selectedIndex].id);
        }
      } else if (e.key === 'Escape') {
        e.preventDefault();
        e.stopPropagation();
        onClose();
      }
    };

    window.addEventListener('keydown', handleKeyDown, true);
    return () => window.removeEventListener('keydown', handleKeyDown, true);
  }, [selectedIndex, options, onSelect, onClose]);

  return (
    <>
      {/* Backdrop */}
      <div 
        className="fixed inset-0 bg-black/10 z-40"
        onClick={onClose}
      />

      {/* Palette */}
      <div className="fixed bottom-12 sm:bottom-32 left-1/2 -translate-x-1/2 w-[calc(100%-1rem)] sm:w-full max-w-md bg-card border border-border rounded-lg sm:rounded-2xl shadow-2xl z-50 overflow-hidden">
        {/* Header */}
        <div className="px-2 sm:px-4 py-2 sm:py-3 border-b border-border bg-accent/50">
          <div className="flex items-center justify-between">
            <div className="min-w-0 flex-1">
              <h3 className="text-[10px] sm:text-sm font-semibold text-foreground truncate">{title}</h3>
              <p className="text-[9px] sm:text-xs text-muted-foreground mt-0.5 truncate">{subtitle}</p>
            </div>
            <button
              onClick={onClose}
              className="p-0.5 sm:p-1.5 hover:bg-accent rounded-md sm:rounded-lg transition-colors flex-shrink-0 ml-1.5 sm:ml-2"
            >
              <X className="w-3 h-3 sm:w-3.5 sm:h-3.5 text-muted-foreground" />
            </button>
          </div>
        </div>

        {/* Options */}
        <div className="max-h-56 sm:max-h-80 overflow-y-auto">
          {options.map((option, index) => (
            <button
              key={option.id}
              onClick={() => onSelect(option.id)}
              onMouseEnter={() => setSelectedIndex(index)}
              className={`
                w-full text-left px-2 sm:px-4 py-2 sm:py-3 transition-all border-b border-border last:border-0
                ${selectedIndex === index
                  ? 'bg-primary/15'
                  : 'hover:bg-accent/50'
                }
              `}
            >
              <div className="flex items-center justify-between gap-1.5 sm:gap-2">
                <div className="flex-1 min-w-0">
                  <div className={`
                    text-[10px] sm:text-sm font-medium truncate
                    ${selectedIndex === index ? 'text-primary' : 'text-foreground'}
                  `}>
                    {option.label}
                  </div>
                  {option.description && (
                    <div className="text-[9px] sm:text-xs text-muted-foreground mt-0.5 line-clamp-2">
                      {option.description}
                    </div>
                  )}
                </div>
                {selectedIndex === index && (
                  <ChevronRight className="w-3 h-3 sm:w-4 sm:h-4 text-primary flex-shrink-0" />
                )}
              </div>
            </button>
          ))}
        </div>

        {/* Footer hint */}
        <div className="px-2 sm:px-4 py-1 sm:py-2 bg-accent/50 border-t border-border">
          <p className="text-[9px] sm:text-xs text-muted-foreground text-center">
            Use ↑↓ to navigate • Enter to select • Esc to close
          </p>
        </div>
      </div>
    </>
  );
}

// Preset configurations for common use cases
export const DRAFT_NOTE_OPTIONS: Option[] = [
  { id: 'SOAP', label: 'SOAP', description: 'Subjective, Objective, Assessment, Plan' },
  { id: 'APSO', label: 'APSO', description: 'Assessment, Plan, Subjective, Objective' },
  { id: 'Brief', label: 'Brief', description: 'Condensed clinical summary' }
];

export const DRAFT_PLAN_OPTIONS: Option[] = [
  { id: 'standard', label: 'Standard care', description: 'Routine treatment plan' },
  { id: 'risk_mitigation', label: 'Risk mitigation', description: 'Focus on reducing identified risks' },
  { id: 'symptom_focused', label: 'Symptom-focused', description: 'Target specific symptoms' },
  { id: 'adherence_focused', label: 'Adherence-focused', description: 'Emphasis on treatment adherence' }
];

export const SIMULATION_PRESETS: Option[] = [
  { id: 'baseline', label: 'Baseline (no change)', description: 'Current trajectory without changes' },
  { id: 'increase_therapy', label: 'Increase therapy frequency', description: 'More frequent sessions' },
  { id: 'sleep_intervention', label: 'Add sleep intervention', description: 'Sleep-focused treatment addition' },
  { id: 'reduced_adherence', label: 'Reduced adherence scenario', description: 'Model poor medication adherence' }
];
