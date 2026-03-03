import React, { useState, useRef, useEffect } from 'react';
import { Send, UserPlus, Sparkles } from 'lucide-react';
import { SimulationBuilder } from './SimulationBuilder';
// Entity lists come from backend via props (no hardcoded data when Command API enabled)

/** Entity list from backend (backend → DB). All pickers use these; no hardcoded lists. */
export type EntityListFromApi = { id: string; date: string; time?: string; type: string; title?: string | null; summary: string; chips: string[] };

interface ComposerProps {
  value: string;
  onChange: (value: string) => void;
  onSend: (message: string) => void;
  onQuickPrompt: (prompt: string) => void;
  simulationBuilderOpen?: boolean;
  onSimulationGenerate?: (command: string) => void;
  onSimulationBuilderClose?: () => void;
  commandLoading?: boolean;
  /** When false, composer is disabled until user selects a patient and has an open conversation for that patient */
  canChat?: boolean;
  /** All entity lists from backend (GET /v1/assessments, /v1/alerts, etc.). No hardcoded data. */
  assessmentsFromApi?: EntityListFromApi[];
  alertsFromApi?: EntityListFromApi[];
  redFlagsFromApi?: EntityListFromApi[];
  exportsFromApi?: EntityListFromApi[];
  simulationsFromApi?: EntityListFromApi[];
  visitsFromApi?: EntityListFromApi[];
  /** Called when user clicks "Select patient" in the disabled state */
  onOpenSelectPatient?: () => void;
  onOpenExportBuilder?: () => void;
  onOpenExportCsvBuilder?: () => void;
  onOpenReviseNoteModal?: () => void;
  onOpenAssessmentTrendBuilder?: () => void;
  onOpenPromptGallery?: () => void;
}

export function Composer({
  value,
  onChange,
  onSend,
  onQuickPrompt,
  simulationBuilderOpen,
  onSimulationGenerate,
  onSimulationBuilderClose,
  commandLoading = false,
  canChat = true,
  assessmentsFromApi = [],
  alertsFromApi = [],
  redFlagsFromApi = [],
  exportsFromApi = [],
  simulationsFromApi = [],
  visitsFromApi = [],
  onOpenSelectPatient,
  onOpenExportBuilder,
  onOpenExportCsvBuilder,
  onOpenReviseNoteModal,
  onOpenAssessmentTrendBuilder,
  onOpenPromptGallery,
}: ComposerProps) {
  const textareaRef = useRef<HTMLTextAreaElement>(null);

  const handleKeyDown = (e: React.KeyboardEvent) => {
    // Don't handle Enter if SimulationBuilder is open - let it handle Enter
    if (simulationBuilderOpen && e.key === 'Enter') return;

    // Handle plain Enter to send message
    if (e.key === 'Enter' && !e.shiftKey && !e.metaKey && !e.ctrlKey && !simulationBuilderOpen) {
      e.preventDefault();
      onSend(value);
    }
  };

  // Auto-resize textarea
  useEffect(() => {
    if (textareaRef.current) {
      textareaRef.current.style.height = 'auto';
      const scrollHeight = textareaRef.current.scrollHeight;
      const minHeight = 48;
      const maxHeight = 200;
      const newHeight = Math.min(Math.max(scrollHeight, minHeight), maxHeight);
      textareaRef.current.style.height = `${newHeight}px`;
      textareaRef.current.style.overflowY = scrollHeight > maxHeight ? 'auto' : 'hidden';
    }
  }, [value]);

  const handleChange = (newValue: string) => {
    // Typing "/" opens the prompt gallery (replacing the old command palette)
    if (newValue === '/' && onOpenPromptGallery) {
      onOpenPromptGallery();
      onChange('');
      return;
    }
    onChange(newValue);
  };

  if (!canChat) {
    return (
      <div className="relative max-w-4xl mx-auto bg-card rounded-xl border border-border px-3 sm:px-4 py-4 sm:py-6 mb-3 shadow-sm">
        <div className="flex flex-col items-center justify-center text-center py-2">
          <p className="text-sm text-muted-foreground mb-3">
            Select a patient and start a conversation to chat. Chats are per patient.
          </p>
          {onOpenSelectPatient && (
            <button
              type="button"
              onClick={onOpenSelectPatient}
              className="inline-flex items-center gap-2 px-4 py-2 rounded-lg bg-primary text-primary-foreground text-sm font-medium hover:opacity-90 transition-opacity"
            >
              <UserPlus className="w-4 h-4" />
              Select patient
            </button>
          )}
        </div>
      </div>
    );
  }

  return (
    <div className="relative w-full max-w-3xl mx-auto px-4 sm:px-6 mb-8">
      {/* Simulation Builder (opened from Prompt Gallery) */}
      {simulationBuilderOpen && onSimulationGenerate && onSimulationBuilderClose && (
        <SimulationBuilder
          onGenerate={onSimulationGenerate}
          onClose={onSimulationBuilderClose}
        />
      )}

      {/* Input bar - medical prompt style */}
      <div className="relative rounded-2xl bg-white dark:bg-card border border-sky-300/60 dark:border-border shadow-sm transition-all duration-200 focus-within:border-sky-400/80 dark:focus-within:border-primary/50 focus-within:ring-2 focus-within:ring-sky-400/10 dark:focus-within:ring-primary/10">
        <div className="flex items-center gap-2 px-4 py-3">
          <textarea
            data-testid="composer-input"
            ref={textareaRef}
            value={value}
            onChange={(e) => handleChange(e.target.value)}
            onKeyDown={handleKeyDown}
            placeholder="Type your medical question, clinical note, or AI prompt..."
            aria-label="Message input"
            className="flex-1 min-w-0 py-1 bg-transparent border-0 resize-none focus:outline-none focus:ring-0 placeholder:text-[#8D93A3] dark:placeholder:text-muted-foreground text-[15px] leading-relaxed text-foreground"
            rows={1}
            style={{ 
              minHeight: '48px', 
              maxHeight: '200px',
              overflowY: 'auto',
              lineHeight: '1.6'
            }}
          />
          <div className="flex items-center gap-1 flex-shrink-0">
            {onOpenPromptGallery && (
              <button
                type="button"
                data-testid="prompts-button"
                onClick={onOpenPromptGallery}
                className="p-2.5 rounded-lg text-[#808080] dark:text-muted-foreground hover:bg-sky-50 dark:hover:bg-accent hover:text-sky-600 dark:hover:text-primary transition-colors"
                title="Suggested prompts (or type /)"
                aria-label="Suggested prompts"
              >
                <Sparkles className="w-5 h-5" />
              </button>
            )}
            <button
              onClick={() => onSend(value)}
              disabled={!value.trim() || commandLoading}
              className={`p-2.5 rounded-lg transition-colors ${
                value.trim() && !commandLoading
                  ? 'text-primary hover:bg-primary/10'
                  : 'text-[#8D93A3] dark:text-muted-foreground cursor-not-allowed'
              }`}
              title={!value.trim() ? 'Enter a message to send' : 'Send (Enter)'}
              aria-label="Send message"
            >
              <Send className="w-5 h-5" strokeWidth={2} />
            </button>
          </div>
        </div>
      </div>

      
    </div>
  );
}