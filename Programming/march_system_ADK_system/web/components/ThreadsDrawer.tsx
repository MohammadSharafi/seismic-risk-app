import React, { useState, useMemo, useEffect } from 'react';
import { X, Plus, Search, MessageSquare, FolderOpen, Trash2, ChevronRight, ChevronDown, User, FileText, Clock } from 'lucide-react';
import type { ThreadItem } from '../services/threadService';
import { sidebar } from './sidebarStyles';

function formatRelativeTime(ts: string): string {
  try {
    const d = new Date(ts);
    if (Number.isNaN(d.getTime())) return ts;
    const now = new Date();
    const diffMs = now.getTime() - d.getTime();
    const diffM = Math.floor(diffMs / 60000);
    const diffH = Math.floor(diffMs / 3600000);
    const diffD = Math.floor(diffMs / 86400000);
    if (diffM < 1) return 'Just now';
    if (diffM < 60) return `${diffM}m ago`;
    if (diffH < 24) return `${diffH}h ago`;
    if (diffD < 7) return `${diffD}d ago`;
    return formatThreadDate(ts);
  } catch {
    return ts;
  }
}

export interface PatientOption {
  name: string;
  mrn: string;
  status?: string;
  risk?: string;
  /** Optional flag for \"recent\" patients when available */
  recent?: boolean;
}

interface ThreadsDrawerProps {
  open: boolean;
  onClose: () => void;
  /** When true, render as in-flow sidebar (no overlay); when false, render as overlay drawer */
  asSidebar?: boolean;
  threadsByPatient: { patientLabel: string; threads: ThreadItem[] }[];
  currentThreadId: string;
  /** The thread currently open (shown at top of drawer) */
  currentThread: ThreadItem | undefined;
  currentPatient: PatientOption | null;
  onSelectThread: (threadId: string) => void;
  onCreateThread: () => void;
  /** Create a brand new thread explicitly for the chosen patient */
  onCreateThreadForPatient: (patient: PatientOption) => void;
  /** Open patient picker to choose patient for a new thread (e.g. modal) */
  onOpenPatientPickerForNewThread?: () => void;
  onDeleteThread: (threadId: string) => void;
}

function formatThreadDate(ts: string): string {
  try {
    const d = new Date(ts);
    if (Number.isNaN(d.getTime())) return ts;
    const now = new Date();
    const isToday = d.toDateString() === now.toDateString();
    if (isToday) return d.toLocaleTimeString(undefined, { hour: '2-digit', minute: '2-digit' });
    return d.toLocaleDateString(undefined, {
      month: 'short',
      day: 'numeric',
      year: d.getFullYear() !== now.getFullYear() ? 'numeric' : undefined,
      hour: '2-digit',
      minute: '2-digit',
    });
  } catch {
    return ts;
  }
}

export function ThreadsDrawer({
  open,
  onClose,
  asSidebar = false,
  threadsByPatient,
  currentThreadId,
  currentThread,
  currentPatient,
  onSelectThread,
  onCreateThread,
  onCreateThreadForPatient,
  onOpenPatientPickerForNewThread,
  onDeleteThread,
}: ThreadsDrawerProps) {
  const [search, setSearch] = useState('');
  const [deleteConfirmId, setDeleteConfirmId] = useState<string | null>(null);

  const filteredGroups = useMemo(() => {
    const q = search.trim().toLowerCase();
    if (!q)
      return threadsByPatient.map((g) => ({ ...g, threads: g.threads }));
    return threadsByPatient
      .map((g) => ({ ...g, threads: g.threads.filter((t) => t.title.toLowerCase().includes(q)) }))
      .filter((g) => g.threads.length > 0);
  }, [threadsByPatient, search]);

  const totalThreads = filteredGroups.reduce((n, g) => n + g.threads.length, 0);

  const [threadsLimitByGroup, setThreadsLimitByGroup] = useState<Record<string, number>>({});
  const [expandedPatients, setExpandedPatients] = useState<Record<string, boolean>>({});

  const [newThreadMode, setNewThreadMode] = useState<'idle' | 'confirm' | 'choose'>('idle');

  // Default expand the group that contains the current thread
  useEffect(() => {
    if (!threadsByPatient.length || !currentThreadId) return;
    const group = threadsByPatient.find((g) => g.threads.some((t) => t.id === currentThreadId));
    if (group)
      setExpandedPatients((prev) => (prev[group.patientLabel] ? prev : { ...prev, [group.patientLabel]: true }));
  }, [currentThreadId, threadsByPatient]);

  useEffect(() => {
    if (!open) {
      setNewThreadMode('idle');
    }
  }, [open]);

  useEffect(() => {
    if (newThreadMode === 'choose' && currentThreadId) {
      setNewThreadMode('idle');
    }
  }, [currentThreadId, newThreadMode]);

  const handleSelectThread = (e: React.MouseEvent<HTMLButtonElement>) => {
    const threadId = (e.currentTarget as HTMLButtonElement).getAttribute('data-thread-id');
    if (threadId) {
      onSelectThread(threadId);
    }
  };

  const handleDelete = (e: React.MouseEvent, threadId: string) => {
    e.stopPropagation();
    if (deleteConfirmId === threadId) {
      onDeleteThread(threadId);
      setDeleteConfirmId(null);
      return;
    }
    setDeleteConfirmId(threadId);
    setTimeout(() => setDeleteConfirmId(null), 2000);
  };

  if (!open) return null;

  const panel = (
    <div
      data-testid="threads-drawer"
      className={
        asSidebar
          ? sidebar.root
          : `fixed left-14 top-0 bottom-0 w-[256px] max-w-[85vw] z-50 ${sidebar.root}`
      }
    >
      <div className={sidebar.header}>
        <h2 className={sidebar.title}>Chats</h2>
        <button
          onClick={onClose}
          className={sidebar.closeButton}
          aria-label="Close sidebar"
          title="Close sidebar"
        >
          <X className="w-3 h-3" strokeWidth={2} strokeLinecap="round" strokeLinejoin="round" />
        </button>
      </div>

      <div className="flex-shrink-0 p-1.5">
        <button
          type="button"
          data-testid="thread-new"
          onClick={(e) => {
            e.preventDefault();
            e.stopPropagation();
            if (currentPatient) {
              setNewThreadMode('confirm');
            } else if (onOpenPatientPickerForNewThread) {
              onOpenPatientPickerForNewThread();
            } else {
              setNewThreadMode('choose');
            }
          }}
          className={sidebar.primaryButton}
        >
          <Plus className="w-3 h-3" strokeWidth={2.5} strokeLinecap="round" strokeLinejoin="round" />
          New chat
        </button>
      </div>

      {newThreadMode === 'confirm' && currentPatient && (
        <div className="flex-shrink-0 px-2 pb-1">
          <div className="rounded-md bg-secondary/50 border border-primary/30 shadow-sm px-2 py-1.5 text-[10px] text-foreground flex items-center justify-between gap-1.5">
            <span className="truncate">New chat for {currentPatient.name}?</span>
            <div className="flex gap-2 flex-shrink-0">
              <button
                type="button"
                onClick={() => { onCreateThread(); setNewThreadMode('idle'); }}
                className="px-1.5 py-0.5 rounded bg-primary text-primary-foreground text-[10px] font-medium hover:opacity-90"
              >
                Start
              </button>
              <button
                type="button"
                onClick={() => { setNewThreadMode('choose'); onOpenPatientPickerForNewThread?.(); }}
                className="px-1.5 py-0.5 rounded text-[10px] text-foreground hover:bg-accent"
              >
                Other
              </button>
            </div>
          </div>
        </div>
      )}
      {newThreadMode === 'choose' && onOpenPatientPickerForNewThread && (
        <div className="flex-shrink-0 px-2 pb-1">
          <button
            type="button"
            onClick={onOpenPatientPickerForNewThread}
            className="w-full px-2 py-1.5 rounded-md text-[11px] text-foreground bg-muted border border-border hover:bg-accent transition-colors"
          >
            Choose patient for new chat
          </button>
        </div>
      )}

      <div className="flex-shrink-0 px-2 pb-1.5">
        <div className="relative">
          <Search className="absolute left-2 top-1/2 -translate-y-1/2 w-3 h-3 text-muted-foreground pointer-events-none" strokeWidth={2} strokeLinecap="round" strokeLinejoin="round" />
          <input
            type="text"
            placeholder="Search by patient, MRN, or subject..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className={sidebar.input}
          />
        </div>
      </div>

      {currentThread && (
        <div className="flex-shrink-0 px-2 pb-1.5">
          <p className={sidebar.sectionLabel}>Active patient</p>
          <div className="rounded-md bg-secondary/50 border border-primary/30 px-2 py-1.5 flex items-start gap-1.5 shadow-sm">
            <div className="flex-shrink-0 w-7 h-7 rounded-md bg-teal-600 flex items-center justify-center">
              <User className="w-3.5 h-3.5 text-white" strokeWidth={2} strokeLinecap="round" strokeLinejoin="round" />
            </div>
            <div className="min-w-0 flex-1">
              <p className="text-[11px] font-semibold text-foreground truncate">
                {currentPatient?.name || currentThread.patientName?.trim() || 'No patient'}
              </p>
              <p className="text-[9px] text-muted-foreground truncate">
                {currentPatient?.mrn ? `MRN-${currentPatient.mrn}` : currentThread.patientId ? `MRN-${currentThread.patientId}` : ''}
              </p>
              <p className="text-[10px] text-foreground mt-0.5 truncate">{currentThread.title}</p>
              <div className="flex items-center gap-1 mt-0.5 flex-wrap">
                <span className="inline-flex px-1 py-0.5 rounded text-[8px] font-medium bg-emerald-100 text-emerald-800">Progress Note</span>
                <span className="flex items-center gap-0.5 text-[8px] text-muted-foreground">
                  <Clock className="w-2 h-2" strokeWidth={2} strokeLinecap="round" strokeLinejoin="round" />
                  {formatRelativeTime(currentThread.timestamp)}
                </span>
              </div>
            </div>
          </div>
        </div>
      )}

        <div className={`${sidebar.body} ${sidebar.bodyPad} pb-2`}>
        {totalThreads === 0 && (
          <div className="flex flex-col items-center justify-center py-6 px-2 text-center">
            <div className="w-7 h-7 rounded-md bg-muted flex items-center justify-center mb-1.5">
              <MessageSquare className="w-3.5 h-3.5 text-muted-foreground" strokeWidth={1.5} strokeLinecap="round" strokeLinejoin="round" />
            </div>
            <p className="text-[11px] font-medium text-muted-foreground">No chats yet</p>
            <p className="text-[9px] text-muted-foreground mt-0.5 max-w-[140px]">Start a new chat above to begin.</p>
          </div>
        )}
        {totalThreads > 0 && (
          <div className="space-y-1">
            <p className={sidebar.sectionLabel}>All patients</p>
            {filteredGroups.map(({ patientLabel, threads }, groupIndex) => {
              const limit = threadsLimitByGroup[patientLabel] ?? 20;
              const visibleThreads = threads.slice(0, limit);
              const hasMore = threads.length > visibleThreads.length;
              const remaining = threads.length - visibleThreads.length;
              const mrn = threads[0]?.patientId ? (threads[0].patientId.startsWith('MRN-') ? threads[0].patientId : `MRN-${threads[0].patientId}`) : '';
              const isExpanded = expandedPatients[patientLabel] ?? false;
              const toggleExpanded = () => setExpandedPatients((prev) => ({ ...prev, [patientLabel]: !prev[patientLabel] }));
              const hasActiveThread = threads.some((t) => t.id === currentThreadId);
              const showStatusDot = groupIndex === 1;

              return (
                <section key={patientLabel} className="space-y-1">
                  <div
                    className={`rounded-md overflow-hidden border shadow-sm transition-colors ${
                      isExpanded && hasActiveThread
                        ? 'bg-card border-primary/30'
                        : 'bg-card border-border hover:bg-accent/50'
                    }`}
                  >
                    <button
                      type="button"
                      onClick={toggleExpanded}
                      className="w-full flex items-center gap-2 px-2 py-1.5 text-left transition-colors"
                    >
                      <div
                        className={`flex-shrink-0 w-7 h-7 rounded-md flex items-center justify-center ${
                          isExpanded && hasActiveThread ? 'bg-primary' : 'bg-muted'
                        }`}
                      >
                        <FolderOpen
                          className={`w-3.5 h-3.5 ${isExpanded && hasActiveThread ? 'text-primary-foreground' : 'text-foreground'}`}
                          strokeWidth={2}
                          strokeLinecap="round"
                          strokeLinejoin="round"
                        />
                      </div>
                      <div className="min-w-0 flex-1">
                        <p className="text-[11px] font-semibold text-foreground truncate flex items-center gap-1">
                          {patientLabel}
                          {showStatusDot && (
                            <span className="w-1 h-1 rounded-full bg-emerald-500 flex-shrink-0" aria-hidden />
                          )}
                        </p>
                        <p className="text-[9px] text-muted-foreground truncate">
                          {mrn ? `${mrn} · ${threads.length} note${threads.length !== 1 ? 's' : ''}` : `${threads.length} note${threads.length !== 1 ? 's' : ''}`}
                        </p>
                      </div>
                      {isExpanded ? (
                        <ChevronDown className="w-3 h-3 text-muted-foreground flex-shrink-0" strokeWidth={2} strokeLinecap="round" strokeLinejoin="round" />
                      ) : (
                        <ChevronRight className="w-3 h-3 text-muted-foreground flex-shrink-0" strokeWidth={2} strokeLinecap="round" strokeLinejoin="round" />
                      )}
                    </button>

                    {isExpanded && (
                      <div className="border-t border-border ml-2 pl-2 pr-1 py-1 space-y-0.5">
                        {visibleThreads.map((thread, noteIndex) => {
                          const isSelected = thread.id === currentThreadId;
                          const showDeleteConfirm = deleteConfirmId === thread.id;
                          const noteTag = noteIndex === 0 ? 'Progress Note' : noteIndex === 1 ? 'Follow-up' : 'Initial Consultation';
                          return (
                            <div
                              key={thread.id}
                              className={`group relative flex items-stretch rounded-md transition-colors ${
                                isSelected
                                  ? 'bg-secondary/50 border border-primary/30 shadow-sm'
                                  : 'bg-card border border-border hover:bg-accent/50'
                              }`}
                            >
                              {isSelected && (
                                <span className={`absolute left-0 top-1 bottom-1 w-0.5 rounded-full ${sidebar.selectionBar}`} aria-hidden />
                              )}
                              <button
                                type="button"
                                data-thread-id={thread.id}
                                onClick={handleSelectThread}
                                className="flex-1 min-w-0 text-left pl-1.5 pr-1 py-1 rounded-md flex items-center gap-1.5 focus:outline-none focus-visible:ring-2 focus-visible:ring-teal-400 focus-visible:ring-inset"
                              >
                                <div
                                  className={`flex-shrink-0 w-6 h-6 rounded flex items-center justify-center ${
                                    isSelected ? 'bg-primary' : 'bg-muted'
                                  }`}
                                >
                                  <FileText
                                    className={`w-3 h-3 ${isSelected ? 'text-primary-foreground' : 'text-foreground'}`}
                                    strokeWidth={2}
                                    strokeLinecap="round"
                                    strokeLinejoin="round"
                                  />
                                </div>
                                <div className="min-w-0 flex-1">
                                  <p className="text-[10px] font-medium text-foreground truncate">{thread.title}</p>
                                  <div className="flex items-center gap-1 mt-0.5 flex-wrap">
                                    <span
                                      className={`inline-flex px-1 py-0.5 rounded text-[7px] font-medium ${
                                        isSelected ? 'bg-emerald-100 dark:bg-emerald-900/30 text-emerald-800 dark:text-emerald-200' : 'bg-muted text-muted-foreground'
                                      }`}
                                    >
                                      {noteTag}
                                    </span>
                                    <span className="flex items-center gap-0.5 text-[7px] text-muted-foreground">
                                      <Clock className="w-1.5 h-1.5" strokeWidth={2} strokeLinecap="round" strokeLinejoin="round" />
                                      {formatRelativeTime(thread.timestamp)}
                                    </span>
                                  </div>
                                </div>
                              </button>
                              <button
                                type="button"
                                onClick={(e) => handleDelete(e, thread.id)}
                                className={`flex-shrink-0 flex items-center justify-center w-5 h-5 rounded mr-0.5 transition-colors focus:outline-none focus-visible:ring-2 focus-visible:ring-red-400 focus-visible:ring-inset ${
                                  showDeleteConfirm ? 'text-red-600 bg-red-50 dark:bg-red-900/20' : 'text-muted-foreground hover:text-red-600 hover:bg-red-50 dark:hover:bg-red-900/20 opacity-0 group-hover:opacity-100'
                                }`}
                                title={showDeleteConfirm ? 'Click again to delete' : 'Delete chat'}
                                aria-label="Delete chat"
                              >
                                <Trash2 className="w-2 h-2" strokeWidth={2} strokeLinecap="round" strokeLinejoin="round" />
                              </button>
                            </div>
                          );
                        })}
                        {hasMore && (
                          <button
                            type="button"
                            onClick={(e) => { e.stopPropagation(); setThreadsLimitByGroup((prev) => ({ ...prev, [patientLabel]: limit + 20 })); }}
                            className="w-full text-[8px] text-muted-foreground hover:text-foreground py-0.5 px-1 text-left rounded hover:bg-accent/50 transition-colors"
                          >
                            + {remaining} more
                          </button>
                        )}
                      </div>
                    )}
                  </div>
                </section>
              );
            })}
          </div>
        )}
      </div>
    </div>
  );

  if (asSidebar) {
    return panel;
  }

  return (
    <>
      <div
        className="fixed left-14 top-0 right-0 bottom-0 bg-black/30 dark:bg-black/40 z-40 transition-opacity"
        onClick={onClose}
        aria-hidden
      />
      {panel}
    </>
  );
}
