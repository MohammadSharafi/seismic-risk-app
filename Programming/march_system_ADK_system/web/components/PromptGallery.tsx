import React, { useState, useEffect } from 'react';
import { X, Bookmark, Copy, Sparkles, Trash2 } from 'lucide-react';
import { toast } from 'sonner';
import { SUGGESTED_PROMPTS, PROMPT_CATEGORIES, CATEGORY_COLORS } from '../data/suggestedPrompts';
import type { SavedPrompt } from '../hooks/useSavedPrompts';

type TabId = 'suggested' | 'yours';

interface PromptGalleryProps {
  open: boolean;
  onClose: () => void;
  savedPrompts: SavedPrompt[];
  onUsePrompt: (prompt: string) => void;
  onSavePrompt: (title: string, prompt: string, category?: string) => void;
  onRemoveSaved: (id: string) => void;
  isSaved: (promptText: string) => boolean;
}

export function PromptGallery({
  open,
  onClose,
  savedPrompts,
  onUsePrompt,
  onSavePrompt,
  onRemoveSaved,
  isSaved,
}: PromptGalleryProps) {
  const [activeTab, setActiveTab] = useState<TabId>('suggested');
  const [categoryFilter, setCategoryFilter] = useState<string>('All');

  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape') onClose();
    };
    if (open) {
      window.addEventListener('keydown', handleKeyDown);
      return () => window.removeEventListener('keydown', handleKeyDown);
    }
  }, [open, onClose]);

  const handleCopy = (prompt: string) => {
    navigator.clipboard.writeText(prompt);
    toast.success('Copied to clipboard');
  };

  const suggestedFiltered =
    categoryFilter === 'All'
      ? SUGGESTED_PROMPTS
      : SUGGESTED_PROMPTS.filter((p) => p.category === categoryFilter);
  const savedFiltered =
    categoryFilter === 'All'
      ? savedPrompts
      : savedPrompts.filter((p) => (p.category ?? '') === categoryFilter);

  if (!open) return null;

  return (
    <>
      <div
        className="fixed inset-0 bg-black/50 backdrop-blur-sm z-40"
        onClick={onClose}
        aria-hidden
      />
      <div
        role="dialog"
        aria-modal="true"
        aria-labelledby="prompt-gallery-title"
        className="fixed left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 w-[calc(100%-2rem)] max-w-2xl max-h-[80vh] bg-card border border-border rounded-2xl shadow-xl shadow-black/10 dark:shadow-black/30 z-50 overflow-hidden flex flex-col"
      >
        {/* Header */}
        <div className="flex items-center justify-between px-5 py-4 border-b border-border shrink-0 bg-gradient-to-b from-muted/30 to-transparent">
          <div>
            <h2 id="prompt-gallery-title" className="text-lg font-semibold text-foreground flex items-center gap-2">
              {activeTab === 'suggested' ? (
                <>
                  <Sparkles className="w-5 h-5 text-primary" aria-hidden />
                  Suggested prompts
                </>
              ) : (
                <>
                  <Bookmark className="w-5 h-5 text-primary fill-primary/30" aria-hidden />
                  Your prompts
                </>
              )}
            </h2>
            <p className="text-xs text-muted-foreground mt-0.5">
              {activeTab === 'suggested'
                ? 'Click a prompt to use it, or save your favorites for quick access'
                : 'Prompts you’ve saved from messages and suggestions'}
            </p>
          </div>
          <button
            type="button"
            onClick={onClose}
            className="p-2.5 rounded-xl hover:bg-accent text-muted-foreground hover:text-foreground transition-colors"
            aria-label="Close"
          >
            <X className="w-5 h-5" strokeWidth={2} />
          </button>
        </div>

        {/* Tabs */}
        <div className="flex gap-1 px-5 pt-3 shrink-0">
          <button
            type="button"
            onClick={() => setActiveTab('suggested')}
            className={`flex items-center gap-2 px-4 py-2.5 rounded-xl text-sm font-medium transition-all ${
              activeTab === 'suggested'
                ? 'bg-primary/15 text-primary dark:bg-primary/25 shadow-sm'
                : 'text-muted-foreground hover:text-foreground hover:bg-accent/60'
            }`}
          >
            <Sparkles className={`w-4 h-4 ${activeTab === 'suggested' ? 'text-primary' : ''}`} />
            Suggested
          </button>
          <button
            type="button"
            onClick={() => setActiveTab('yours')}
            className={`flex items-center gap-2 px-4 py-2.5 rounded-xl text-sm font-medium transition-all ${
              activeTab === 'yours'
                ? 'bg-primary/15 text-primary dark:bg-primary/25 shadow-sm'
                : 'text-muted-foreground hover:text-foreground hover:bg-accent/60'
            }`}
          >
            <Bookmark className={`w-4 h-4 ${activeTab === 'yours' ? 'text-primary' : ''}`} />
            Your prompts
          </button>
        </div>

        {/* Category filter + count */}
        <div className="flex items-center gap-3 px-5 py-3 shrink-0 border-b border-border/60">
          <label htmlFor="prompt-category-filter" className="text-xs font-medium text-muted-foreground shrink-0">
            Category
          </label>
          <select
            id="prompt-category-filter"
            value={categoryFilter}
            onChange={(e) => setCategoryFilter(e.target.value)}
            className="text-sm bg-card text-foreground hover:bg-accent/50 border border-border rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-primary/50 cursor-pointer flex-1 max-w-[200px]"
          >
            {PROMPT_CATEGORIES.map((c) => (
              <option key={c} value={c}>
                {c}
              </option>
            ))}
          </select>
          <span className="text-xs text-muted-foreground shrink-0">
            {activeTab === 'suggested' ? suggestedFiltered.length : savedFiltered.length} prompt{(activeTab === 'suggested' ? suggestedFiltered.length : savedFiltered.length) !== 1 ? 's' : ''}
          </span>
        </div>

        {/* Prompt cards grid */}
        <div className="flex-1 overflow-y-auto p-4">
          <div className="grid gap-2.5 sm:grid-cols-2">
            {activeTab === 'suggested' &&
              suggestedFiltered.map((p) => (
                <PromptCard
                  key={p.id}
                  id={p.id}
                  title={p.title}
                  prompt={p.prompt}
                  description={p.description}
                  category={p.category}
                  saved={isSaved(p.prompt)}
                  onUse={() => {
                    onUsePrompt(p.prompt);
                    onClose();
                  }}
                  onCopy={() => handleCopy(p.prompt)}
                  onSave={() => onSavePrompt(p.title, p.prompt, p.category)}
                  onRemove={() => {
                    const sp = savedPrompts.find((s) => s.prompt === p.prompt);
                    if (sp) onRemoveSaved(sp.id);
                  }}
                  isSuggested
                />
              ))}
            {activeTab === 'yours' &&
              (savedFiltered.length === 0 ? (
                <div className="col-span-2 py-16 px-6 text-center">
                  <div className="inline-flex items-center justify-center w-16 h-16 rounded-2xl bg-gradient-to-br from-primary/15 to-primary/5 mb-5">
                    <Bookmark className="w-8 h-8 text-primary" strokeWidth={1.5} />
                  </div>
                  <h3 className="text-sm font-semibold text-foreground">No saved prompts yet</h3>
                  <p className="text-xs text-muted-foreground mt-2 max-w-xs mx-auto leading-relaxed">
                    Save prompts from the Suggested tab, or use the bookmark icon when you hover over your messages to add them here.
                  </p>
                </div>
              ) : (
                savedFiltered.map((p) => (
                  <PromptCard
                    key={p.id}
                    id={p.id}
                    title={p.title}
                    prompt={p.prompt}
                    saved
                    onUse={() => {
                      onUsePrompt(p.prompt);
                      onClose();
                    }}
                    onCopy={() => handleCopy(p.prompt)}
                    onRemove={() => onRemoveSaved(p.id)}
                    isSuggested={false}
                    category={p.category}
                  />
                ))
              ))}
          </div>
        </div>

        {/* Footer hint */}
        <div className="px-5 py-2.5 border-t border-border/60 shrink-0 bg-muted/20">
          <p className="text-[11px] text-muted-foreground">
            Click a prompt to use it • Copy to clipboard • <kbd className="px-1.5 py-0.5 rounded-md bg-muted/80 font-mono text-[10px] text-foreground/70">Esc</kbd> to close
          </p>
        </div>
      </div>
    </>
  );
}

interface PromptCardProps {
  id: string;
  title: string;
  prompt: string;
  description?: string;
  category?: string;
  saved: boolean;
  onUse: () => void;
  onCopy: () => void;
  onSave?: () => void;
  onRemove?: () => void;
  isSuggested: boolean;
}

function PromptCard({
  id,
  title,
  prompt,
  description,
  category,
  saved,
  onUse,
  onCopy,
  onSave,
  onRemove,
  isSuggested,
}: PromptCardProps) {
  const isCommand = prompt.startsWith('/');
  return (
    <div
      data-testid={`prompt-card-${id}`}
      className="group p-4 rounded-xl border border-border bg-card hover:bg-primary/[0.04] hover:border-primary/40 hover:shadow-md transition-all duration-200 cursor-pointer"
      onClick={onUse}
      onKeyDown={(e) => {
        if (e.key === 'Enter' || e.key === ' ') {
          e.preventDefault();
          onUse();
        }
      }}
      role="button"
      tabIndex={0}
    >
      <div className="flex items-start justify-between gap-3">
        <div className="min-w-0 flex-1">
          <div className="flex items-center gap-2 flex-wrap">
            <h3 className="text-sm font-medium text-foreground">{title}</h3>
            {category && category !== 'All' && (() => {
              const styles = CATEGORY_COLORS[category] ?? { bg: 'bg-muted/80', text: 'text-muted-foreground' };
              return (
                <span className={`text-[10px] px-2 py-0.5 rounded-md font-medium ${styles.bg} ${styles.text}`}>
                  {category}
                </span>
              );
            })()}
          </div>
          {description && (
            <p className="text-xs text-muted-foreground mt-1 line-clamp-2">
              {description}
            </p>
          )}
          {isCommand && (
            <code className="inline-block mt-1.5 text-[11px] text-primary/90 font-mono bg-primary/10 px-2 py-0.5 rounded-md">
              {prompt}
            </code>
          )}
        </div>
        <div className="flex items-center gap-0.5 shrink-0 opacity-80 group-hover:opacity-100 transition-opacity" onClick={(e) => e.stopPropagation()}>
          <button
            type="button"
            onClick={onCopy}
            className="p-2 rounded-lg hover:bg-primary/10 text-muted-foreground hover:text-primary transition-colors"
            title="Copy to clipboard"
            aria-label="Copy to clipboard"
          >
            <Copy className="w-4 h-4" strokeWidth={2} />
          </button>
          {isSuggested ? (
            saved ? (
              <button
                type="button"
                onClick={(e) => {
                  e.preventDefault();
                  onRemove?.();
                }}
                className="p-2 rounded-lg hover:bg-rose-500/10 text-primary hover:text-rose-600 dark:hover:text-rose-400 transition-colors"
                title="Remove from Your prompts"
                aria-label="Remove from saved"
              >
                <Bookmark className="w-4 h-4 fill-current" strokeWidth={2} />
              </button>
            ) : (
              <button
                type="button"
                onClick={(e) => {
                  e.preventDefault();
                  onSave?.();
                }}
                className="p-2 rounded-lg hover:bg-primary/10 text-muted-foreground hover:text-primary transition-colors"
                title="Add to Your prompts"
                aria-label="Save prompt"
              >
                <Bookmark className="w-4 h-4" strokeWidth={2} />
              </button>
            )
          ) : (
            <button
              type="button"
              onClick={(e) => {
                e.preventDefault();
                onRemove?.();
              }}
              className="p-2 rounded-lg hover:bg-rose-500/10 text-muted-foreground hover:text-rose-600 dark:hover:text-rose-400 transition-colors"
              title="Remove from Your prompts"
              aria-label="Remove"
            >
              <Trash2 className="w-4 h-4" strokeWidth={2} />
            </button>
          )}
        </div>
      </div>
    </div>
  );
}
