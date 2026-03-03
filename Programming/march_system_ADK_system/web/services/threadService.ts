/**
 * Thread & patient-aware conversation service.
 * Single source of truth for threads and messages; persistence in localStorage.
 */

const STORAGE_KEY = 'clinician_threads';
const SCHEMA_VERSION = 2;

// ----- Types -----

export interface ThreadItem {
  id: string;
  title: string;
  timestamp: string;
  patientId?: string;
  patientName?: string;
}

export interface StoredMessage {
  id: string;
  role: 'user' | 'assistant';
  content?: string;
  answer?: string;
  thinkingText?: string;
  isStreaming?: boolean;
  streamPhase?: 'thinking' | 'final';
  evidence?: Record<string, unknown>;
  suggestions?: string;
  widget?: { type: string; data: Record<string, unknown> };
  retryCommand?: string;
  timestamp: string;
}

export type MessageWithDate = StoredMessage & { timestamp: Date };

export interface ThreadState {
  version: number;
  currentThreadId: string;
  threads: ThreadItem[];
  messagesByThread: Record<string, StoredMessage[]>;
}

export interface PatientInfo {
  name: string;
  mrn: string;
}

// ----- Persistence -----

function getDefaultState(): ThreadState {
  return {
    version: SCHEMA_VERSION,
    currentThreadId: '',
    threads: [],
    messagesByThread: {},
  };
}

export function formatThreadTitle(patientLabel: string, date: Date): string {
  const createdLabel = date.toLocaleString(undefined, {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  });
  return `${patientLabel || 'No patient selected'} – ${createdLabel}`;
}

function migrate(state: ThreadState): ThreadState {
  // Normalize legacy "empty" default thread (no patient, no messages) to a truly empty state
  if (
    state.threads &&
    state.threads.length === 1
  ) {
    const only = state.threads[0];
    const msgs = state.messagesByThread?.[only.id] ?? [];
    const noPatient =
      !only.patientId &&
      (!only.patientName || only.patientName === 'No patient selected');
    const noMessages = !Array.isArray(msgs) || msgs.length === 0;
    const isPlaceholder =
      only.title === 'New conversation' &&
      noPatient &&
      noMessages;
    if (isPlaceholder) {
      return getDefaultState();
    }
  }

  if (state.version === SCHEMA_VERSION) return state;
  return getDefaultState();
}

export function load(): ThreadState {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return getDefaultState();
    const parsed = JSON.parse(raw) as ThreadState;
    if (!parsed.threads || !parsed.messagesByThread) return getDefaultState();
    const state: ThreadState = {
      version: parsed.version ?? 1,
      currentThreadId: parsed.currentThreadId || parsed.threads[0]?.id || `thread-${Date.now()}`,
      threads: parsed.threads,
      messagesByThread: parsed.messagesByThread,
    };
    return migrate(state);
  } catch {
    return getDefaultState();
  }
}

export function save(state: ThreadState): void {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
  } catch {
    // ignore quota
  }
}

// ----- Message serialization -----

export function serializeMessages(messages: MessageWithDate[]): StoredMessage[] {
  return messages.map((m) => ({
    ...m,
    timestamp: (m.timestamp as Date).toISOString(),
  })) as StoredMessage[];
}

export function deserializeMessages(messages: StoredMessage[]): MessageWithDate[] {
  return messages.map((m) => ({ ...m, timestamp: new Date(m.timestamp) }));
}

// ----- Pure state transitions -----

export function createThread(
  state: ThreadState,
  opts: { patientName?: string; patientId?: string } = {}
): ThreadState {
  const id = `thread-${Date.now()}`;
  const now = new Date();
  const thread: ThreadItem = {
    id,
    title: 'New conversation',
    timestamp: now.toISOString(),
    patientId: opts.patientId,
    patientName: opts.patientName?.trim() || undefined,
  };
  return {
    ...state,
    version: SCHEMA_VERSION,
    threads: [...state.threads, thread],
    messagesByThread: { ...state.messagesByThread, [id]: [] },
    currentThreadId: id,
  };
}

export function selectThread(state: ThreadState, threadId: string): ThreadState {
  if (state.currentThreadId === threadId) return state;
  const exists = state.threads.some((t) => t.id === threadId);
  if (!exists) return state;
  return { ...state, currentThreadId: threadId };
}

export function addMessage(state: ThreadState, threadId: string, msg: MessageWithDate): ThreadState {
  const list = deserializeMessages(state.messagesByThread[threadId] ?? []);
  const next = [...list, msg];
  return {
    ...state,
    messagesByThread: { ...state.messagesByThread, [threadId]: serializeMessages(next) },
  };
}

export function setThreadMessages(state: ThreadState, threadId: string, messages: MessageWithDate[]): ThreadState {
  return {
    ...state,
    messagesByThread: { ...state.messagesByThread, [threadId]: serializeMessages(messages) },
  };
}

export function deleteThread(state: ThreadState, threadId: string): ThreadState {
  const threads = state.threads.filter((t) => t.id !== threadId);
  if (threads.length === 0) return getDefaultState();
  const next: ThreadState = {
    ...state,
    threads,
    messagesByThread: { ...state.messagesByThread },
    currentThreadId: state.currentThreadId === threadId ? threads[0].id : state.currentThreadId,
  };
  delete next.messagesByThread[threadId];
  return next;
}

export function renameThread(state: ThreadState, threadId: string, title: string): ThreadState {
  return {
    ...state,
    threads: state.threads.map((t) => (t.id === threadId ? { ...t, title } : t)),
  };
}

/** Command or phrase -> short label for thread title */
const CONTEXT_LABELS: Record<string, string> = {
  '/summary': 'Summary',
  '/latest_assessment': 'Latest assessment',
  '/risk_profile': 'Risk factors',
  '/risk_drivers': 'Risk drivers',
  '/risk_mitigation': 'Risk mitigation',
  '/risk_compare': 'Risk compare',
  '/alerts': 'Alerts',
  '/twin_snapshot': 'Twin snapshot',
  '/draft_note': 'Draft note',
  '/draft_plan': 'Draft plan',
  '/simulate': 'Simulation',
  '/export_pdf': 'Export PDF',
  '/export_csv': 'Export CSV',
  '/revise_note': 'Revise note',
  '/assessment_trend': 'Assessment trend',
  '/redflags': 'Red flags',
  '/fhir_patient': 'FHIR patient',
};

export function renameThreadFromFirstMessage(state: ThreadState, threadId: string, firstUserContent: string): ThreadState {
  const trimmed = firstUserContent.trim();
  if (!trimmed) return state;
  const lower = trimmed.toLowerCase();
  const base = lower.split(/\s+/)[0];
  const label = CONTEXT_LABELS[base] ?? CONTEXT_LABELS[base.startsWith('/') ? base : '/' + base];
  const raw = trimmed.slice(0, 48).replace(/\n/g, ' ').trim() || 'Conversation';
  const title = label || (trimmed.length > 48 ? raw + '…' : raw);
  return renameThread(state, threadId, title);
}

export function updateThreadPatient(
  state: ThreadState,
  threadId: string,
  patient: { name: string; mrn?: string }
): ThreadState {
  const thread = state.threads.find((t) => t.id === threadId);
  if (!thread) return state;
  const created = new Date(thread.timestamp);
  const title = formatThreadTitle(patient.name, created);
  return {
    ...state,
    threads: state.threads.map((t) =>
      t.id === threadId ? { ...t, title, patientName: patient.name, patientId: patient.mrn } : t
    ),
  };
}

// ----- Helpers -----

export function getMessagesForThread(state: ThreadState, threadId: string): MessageWithDate[] {
  return deserializeMessages(state.messagesByThread[threadId] ?? []);
}

export function getCurrentThread(state: ThreadState): ThreadItem | undefined {
  return state.threads.find((t) => t.id === state.currentThreadId);
}

/** Threads visible in list (exclude generic "New thread" placeholder from old schema) */
export function getVisibleThreads(state: ThreadState): ThreadItem[] {
  return state.threads
    .filter((t) => t.title !== 'New thread')
    .sort((a, b) => new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime());
}

/** Group threads by patient label for UI */
export function getThreadsByPatient(state: ThreadState): { patientLabel: string; threads: ThreadItem[] }[] {
  const byPatient = new Map<string, ThreadItem[]>();
  for (const t of getVisibleThreads(state)) {
    const key = t.patientName?.trim() || 'No patient selected';
    if (!byPatient.has(key)) byPatient.set(key, []);
    byPatient.get(key)!.push(t);
  }
  return Array.from(byPatient.entries()).map(([patientLabel, threads]) => ({ patientLabel, threads }));
}
