import { useState, useCallback, useEffect } from 'react';

export interface SavedPrompt {
  id: string;
  title: string;
  prompt: string;
  category?: string;
  createdAt: string;
}

const STORAGE_KEY = 'march-saved-prompts';

function loadFromStorage(): SavedPrompt[] {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return [];
    const parsed = JSON.parse(raw);
    return Array.isArray(parsed) ? parsed : [];
  } catch {
    return [];
  }
}

function saveToStorage(prompts: SavedPrompt[]) {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(prompts));
  } catch {
    // ignore
  }
}

export function useSavedPrompts() {
  const [prompts, setPrompts] = useState<SavedPrompt[]>([]);

  useEffect(() => {
    setPrompts(loadFromStorage());
  }, []);

  const save = useCallback((title: string, prompt: string, category?: string) => {
    const newPrompt: SavedPrompt = {
      id: `prompt-${Date.now()}-${Math.random().toString(36).slice(2, 9)}`,
      title: title.trim() || prompt.slice(0, 40) + (prompt.length > 40 ? '…' : ''),
      prompt: prompt.trim(),
      category,
      createdAt: new Date().toISOString(),
    };
    setPrompts((prev) => {
      const next = [newPrompt, ...prev];
      saveToStorage(next);
      return next;
    });
    return newPrompt.id;
  }, []);

  const remove = useCallback((id: string) => {
    setPrompts((prev) => {
      const next = prev.filter((p) => p.id !== id);
      saveToStorage(next);
      return next;
    });
  }, []);

  const update = useCallback((id: string, updates: Partial<Pick<SavedPrompt, 'title' | 'prompt' | 'category'>>) => {
    setPrompts((prev) => {
      const next = prev.map((p) =>
        p.id === id ? { ...p, ...updates } : p
      );
      saveToStorage(next);
      return next;
    });
  }, []);

  return { prompts, save, remove, update };
}
