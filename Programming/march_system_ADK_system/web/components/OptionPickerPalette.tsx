import React, { useState, useEffect, useRef } from 'react';
import { ChevronRight, Calendar, Eye, Sliders } from 'lucide-react';

export interface Option {
  value: string;
  label: string;
  description?: string;
  icon?: React.ReactNode;
}

interface OptionPickerPaletteProps {
  title: string;
  options: Option[];
  onSelect: (option: Option) => void;
  onClose: () => void;
  showCustomDatePicker?: boolean;
  onCustomDateSubmit?: (startDate: string, endDate: string) => void;
}

export function OptionPickerPalette({
  title,
  options,
  onSelect,
  onClose,
  showCustomDatePicker = false,
  onCustomDateSubmit
}: OptionPickerPaletteProps) {
  const [selectedIndex, setSelectedIndex] = useState(0);
  const [showCustom, setShowCustom] = useState(false);
  const [startDate, setStartDate] = useState('2026-01-01');
  const [endDate, setEndDate] = useState('2026-01-23');
  const paletteRef = useRef<HTMLDivElement>(null);
  const selectedRef = useRef<HTMLDivElement>(null);

  const handleOptionSelect = (option: Option) => {
    // Check if this is the custom option
    if (showCustomDatePicker && option.value === 'custom') {
      setShowCustom(true);
    } else {
      onSelect(option);
    }
  };

  // Keyboard navigation
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      // Only handle if OptionPicker is visible
      if (!paletteRef.current) return;
      
      if (showCustom) {
        // In custom date mode, only handle Escape
        if (e.key === 'Escape') {
          e.preventDefault();
          e.stopPropagation();
          setShowCustom(false);
        }
        return;
      }

      // Check if user is typing in an input
      const activeElement = document.activeElement;
      if (activeElement && activeElement.tagName === 'INPUT' && activeElement.type !== 'date') {
        // Allow normal typing in inputs
        return;
      }

      if (e.key === 'ArrowDown') {
        e.preventDefault();
        e.stopPropagation();
        setSelectedIndex(prev => Math.min(prev + 1, options.length - 1));
      } else if (e.key === 'ArrowUp') {
        e.preventDefault();
        e.stopPropagation();
        setSelectedIndex(prev => Math.max(prev - 1, 0));
      } else if (e.key === 'Enter') {
        e.preventDefault();
        e.stopPropagation();
        if (options[selectedIndex]) {
          handleOptionSelect(options[selectedIndex]);
        }
      } else if (e.key === 'Escape') {
        e.preventDefault();
        e.stopPropagation();
        onClose();
      }
    };

    window.addEventListener('keydown', handleKeyDown, true);
    return () => window.removeEventListener('keydown', handleKeyDown, true);
  }, [selectedIndex, options, handleOptionSelect, onClose, showCustom, showCustomDatePicker]);

  // Scroll selected item into view
  useEffect(() => {
    if (selectedRef.current) {
      selectedRef.current.scrollIntoView({ block: 'nearest', behavior: 'smooth' });
    }
  }, [selectedIndex]);

  const handleCustomDateSubmit = () => {
    if (onCustomDateSubmit) {
      onCustomDateSubmit(startDate, endDate);
    }
    setShowCustom(false);
  };

  if (showCustom) {
    return (
      <div className="absolute bottom-full left-0 right-0 mb-2 mx-2 sm:mx-4">
        <div 
          ref={paletteRef}
          className="max-w-2xl mx-auto bg-card rounded-xl sm:rounded-2xl shadow-2xl border border-border overflow-hidden"
        >
          {/* Header */}
          <div className="bg-accent/50 border-b border-border px-2 sm:px-4 py-2 sm:py-3">
            <div className="flex items-center gap-1.5 sm:gap-2">
              <Calendar className="w-3 h-3 sm:w-4 sm:h-4 text-muted-foreground" />
              <span className="text-[10px] sm:text-sm font-medium text-foreground">Custom Time Window</span>
            </div>
          </div>

          {/* Custom date form */}
          <div className="p-2 sm:p-4 space-y-3 sm:space-y-4">
            <div>
              <label className="block text-[10px] sm:text-sm font-medium text-foreground mb-1 sm:mb-1.5">
                Start Date
              </label>
              <input
                type="date"
                value={startDate}
                onChange={(e) => setStartDate(e.target.value)}
                className="w-full px-2 sm:px-3 py-1.5 sm:py-2 bg-card text-foreground border border-border rounded-md sm:rounded-lg text-[11px] sm:text-sm focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent"
              />
            </div>
            <div>
              <label className="block text-[10px] sm:text-sm font-medium text-foreground mb-1 sm:mb-1.5">
                End Date
              </label>
              <input
                type="date"
                value={endDate}
                onChange={(e) => setEndDate(e.target.value)}
                className="w-full px-2 sm:px-3 py-1.5 sm:py-2 bg-card text-foreground border border-border rounded-md sm:rounded-lg text-[11px] sm:text-sm focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent"
              />
            </div>
            <div className="flex gap-1.5 sm:gap-2 pt-1.5 sm:pt-2">
              <button
                onClick={handleCustomDateSubmit}
                className="flex-1 px-3 sm:px-4 py-1.5 sm:py-2 bg-primary text-primary-foreground hover:opacity-90 rounded-md sm:rounded-lg text-[10px] sm:text-sm font-medium transition-colors"
              >
                Apply Custom Range
              </button>
              <button
                onClick={() => setShowCustom(false)}
                className="px-3 sm:px-4 py-1.5 sm:py-2 bg-accent hover:bg-accent/80 text-foreground rounded-md sm:rounded-lg text-[10px] sm:text-sm font-medium transition-colors"
              >
                Back
              </button>
            </div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="absolute bottom-full left-0 right-0 mb-2 mx-2 sm:mx-4">
      <div 
        ref={paletteRef}
        className="max-w-2xl mx-auto bg-card rounded-xl sm:rounded-2xl shadow-2xl border border-border overflow-hidden"
      >
        {/* Header */}
        <div className="bg-accent/50 border-b border-border px-2 sm:px-4 py-2 sm:py-3">
          <div className="flex items-center justify-between gap-2 flex-wrap">
            <div className="flex items-center gap-1.5 sm:gap-2">
              <Sliders className="w-3 h-3 sm:w-4 sm:h-4 text-muted-foreground" />
              <span className="text-[10px] sm:text-sm font-medium text-foreground">{title}</span>
              <span className="text-[9px] sm:text-xs text-muted-foreground">
                {options.length} {options.length === 1 ? 'option' : 'options'}
              </span>
            </div>
            <div className="flex items-center gap-1.5 sm:gap-3 text-[9px] sm:text-xs text-muted-foreground flex-wrap">
              <span className="flex items-center gap-0.5 sm:gap-1">
                <kbd className="px-1 sm:px-1.5 py-0.5 bg-accent rounded text-[8px] sm:text-xs font-mono text-foreground">↑↓</kbd> 
                <span className="hidden sm:inline">Navigate</span>
              </span>
              <span className="flex items-center gap-0.5 sm:gap-1">
                <kbd className="px-1 sm:px-1.5 py-0.5 bg-accent rounded text-[8px] sm:text-xs font-mono text-foreground">↵</kbd> 
                <span className="hidden sm:inline">Select</span>
              </span>
              <span className="flex items-center gap-0.5 sm:gap-1">
                <kbd className="px-1 sm:px-1.5 py-0.5 bg-accent rounded text-[8px] sm:text-xs font-mono text-foreground">Esc</kbd> 
                <span className="hidden sm:inline">Close</span>
              </span>
            </div>
          </div>
        </div>

        {/* Options list */}
        <div className="px-1 sm:px-2 py-1 sm:py-2 space-y-0.5 sm:space-y-1">
          {options.map((option, index) => {
            const isSelected = index === selectedIndex;
            
            return (
              <div
                key={option.value}
                ref={isSelected ? selectedRef : null}
                onClick={() => handleOptionSelect(option)}
                className={`px-2 sm:px-4 py-2 sm:py-3 rounded-md sm:rounded-lg cursor-pointer transition-all duration-150 ${
                  isSelected
                    ? 'bg-primary/15 border border-primary/40 shadow-sm'
                    : 'hover:bg-accent/50 border border-transparent'
                }`}
              >
                <div className="flex items-center justify-between gap-2 sm:gap-3">
                  {/* Option content */}
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-1.5 sm:gap-2">
                      {option.icon && (
                        <div className={`flex-shrink-0 ${isSelected ? 'text-primary' : 'text-muted-foreground'}`}>
                          {option.icon}
                        </div>
                      )}
                      <div className="min-w-0">
                        <div className={`text-[10px] sm:text-sm font-medium ${
                          isSelected ? 'text-primary' : 'text-foreground'
                        }`}>
                          {option.label}
                        </div>
                        {option.description && (
                          <div className="text-[9px] sm:text-xs text-muted-foreground mt-0.5">
                            {option.description}
                          </div>
                        )}
                      </div>
                    </div>
                  </div>

                  {/* Arrow indicator */}
                  {isSelected && (
                    <ChevronRight className="w-4 h-4 sm:w-5 sm:h-5 text-primary flex-shrink-0" />
                  )}
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
}
