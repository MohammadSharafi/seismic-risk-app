import React, { useState, useEffect, useRef } from 'react';
import { X } from 'lucide-react';

interface ReviseNoteModalProps {
  onSubmit: (instruction: string) => void;
  onClose: () => void;
}

export function ReviseNoteModal({ onSubmit, onClose }: ReviseNoteModalProps) {
  const [instruction, setInstruction] = useState('');
  const textareaRef = useRef<HTMLTextAreaElement>(null);

  useEffect(() => {
    textareaRef.current?.focus();
  }, []);

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

  const handleSubmit = () => {
    const trimmed = instruction.trim();
    if (!trimmed) return;
    onSubmit(trimmed);
  };

  return (
    <>
      <div className="fixed inset-0 bg-black/10 z-40" onClick={onClose} />
      <div className="fixed bottom-20 sm:bottom-32 left-1/2 -translate-x-1/2 w-full max-w-lg bg-card border border-border rounded-xl sm:rounded-2xl shadow-2xl z-50 p-3 sm:p-6 mx-2">
        <div className="flex items-center justify-between mb-3 sm:mb-4">
          <div>
            <h2 className="text-[11px] sm:text-base font-semibold text-foreground">Revise note</h2>
            <p className="text-[9px] sm:text-sm text-muted-foreground mt-0.5">Describe the revision (quotes added automatically)</p>
          </div>
          <button onClick={onClose} className="p-1 sm:p-2 hover:bg-accent rounded-md sm:rounded-lg transition-colors">
            <X className="w-3.5 h-3.5 sm:w-4 sm:h-4 text-muted-foreground" />
          </button>
        </div>

        <textarea
          ref={textareaRef}
          value={instruction}
          onChange={(e) => setInstruction(e.target.value)}
          placeholder="e.g. add medication section, include last lab values"
          className="w-full px-2 sm:px-3 py-2 sm:py-3 text-[11px] sm:text-sm bg-card text-foreground border border-border rounded-md sm:rounded-lg focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent resize-none placeholder:text-muted-foreground"
          rows={3}
        />

        <div className="flex items-center gap-2 mt-3 sm:mt-4">
          <button
            onClick={handleSubmit}
            disabled={!instruction.trim()}
            className="flex-1 px-3 sm:px-4 py-1.5 sm:py-2.5 rounded-md sm:rounded-lg font-medium text-[10px] sm:text-sm bg-primary text-primary-foreground hover:opacity-90 disabled:bg-muted disabled:text-muted-foreground disabled:cursor-not-allowed transition-colors"
          >
            Send revision
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
