import React, { forwardRef } from 'react';
import { Loader2, MessageSquare } from 'lucide-react';
import { Message } from './Message';

interface TranscriptProps {
  messages: any[];
  density: string;
  showEvidence: boolean;
  showThinking?: boolean;
  isCommandLoading?: boolean;
  pendingCommand?: string | null;
  onRetryCommand?: (command: string) => void;
  onSavePrompt?: (title: string, prompt: string) => void;
  onRemoveSavedPrompt?: (prompt: string) => void;
  isPromptSaved?: (prompt: string) => boolean;
}

export const Transcript = forwardRef<HTMLDivElement, TranscriptProps>(
  ({ messages, density, showEvidence, showThinking = true, isCommandLoading, pendingCommand, onRetryCommand, onSavePrompt, onRemoveSavedPrompt, isPromptSaved }, ref) => {
    return (
      <div
        ref={ref}
        data-testid="transcript"
        className="flex-1 overflow-y-auto px-4 sm:px-8 py-6 sm:py-8"
      >
        <div className="max-w-3xl mx-auto space-y-6">
          {messages.length === 0 && (
            <div className="flex flex-col items-center justify-center h-64 text-center">
              <MessageSquare className="w-16 h-16 mb-4 text-slate-300 dark:text-slate-600" />
              <p className="text-slate-500 dark:text-slate-100 text-lg font-medium">No messages yet</p>
              <p className="text-slate-400 dark:text-slate-500 text-sm mt-2">Start by selecting a patient and asking a question</p>
            </div>
          )}
          {messages.map((message) => (
            <Message
              key={message.id}
              message={message}
              density={density}
              showEvidence={showEvidence}
              showThinking={showThinking}
              onRetryCommand={message.retryCommand ? onRetryCommand : undefined}
              onSavePrompt={onSavePrompt}
              onRemoveSavedPrompt={onRemoveSavedPrompt}
              isPromptSaved={isPromptSaved}
            />
          ))}
          {isCommandLoading && (
            <div
              data-testid="message-loading"
              className="flex items-start gap-3"
            >
              <div className="flex-shrink-0 w-8 h-8 rounded-full bg-gradient-to-br from-teal-400 to-teal-600 flex items-center justify-center shadow-sm">
                <span className="animate-spin text-white">⟳</span>
              </div>
              <div className="flex-1 pt-1">
                <p className="text-sm text-slate-600 dark:text-slate-100 font-medium">
                  Running command{pendingCommand ? ` "${pendingCommand.split(/\s+/)[0]}"` : ''}…
                </p>
              </div>
            </div>
          )}
        </div>
      </div>
    );
  }
);

Transcript.displayName = 'Transcript';
