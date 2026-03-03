/**
 * Thread and message persistence in localStorage for the clinician UI.
 */

const STORAGE_KEY = 'clinician_threads';

export interface ThreadItem {
  id: string;
  title: string;
  timestamp: string;
}

export interface StoredMessage {
  id: string;
  role: 'user' | 'assistant';
  content?: string;
  answer?: string;
  evidence?: Record<string, unknown>;
  suggestions?: string;
  widget?: { type: string; data: Record<string, unknown> };
  timestamp: string; // ISO string
}

export interface ThreadState {
  currentThreadId: string;
  threads: ThreadItem[];
  messagesByThread: Record<string, StoredMessage[]>;
}

function toStored(m: { timestamp: Date }): { timestamp: string } {
  return { ...m, timestamp: (m.timestamp as Date).toISOString() };
}

function fromStored(m: StoredMessage): StoredMessage & { timestamp: Date } {
  return { ...m, timestamp: new Date(m.timestamp) };
}

export function loadThreadState(): ThreadState {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return getDefaultState();
    const parsed = JSON.parse(raw) as ThreadState;
    if (!parsed.threads || !parsed.messagesByThread) return getDefaultState();
    return {
      currentThreadId: parsed.currentThreadId || `t-${Date.now()}`,
      threads: parsed.threads,
      messagesByThread: parsed.messagesByThread,
    };
  } catch {
    return getDefaultState();
  }
}

function getDefaultState(): ThreadState {
  const id = `t-${Date.now()}`;
  return {
    currentThreadId: id,
    threads: [{ id, title: 'New thread', timestamp: new Date().toLocaleString() }],
    messagesByThread: { [id]: [] },
  };
}

export function saveThreadState(state: ThreadState): void {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
  } catch {
    // ignore quota or other errors
  }
}

export function serializeMessages(messages: Array<{ timestamp: Date; [k: string]: unknown }>): StoredMessage[] {
  return messages.map((m) => ({
    ...m,
    timestamp: (m.timestamp as Date).toISOString(),
  })) as StoredMessage[];
}

export function deserializeMessages(messages: StoredMessage[]): Array<StoredMessage & { timestamp: Date }> {
  return messages.map(fromStored);
}
