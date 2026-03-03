import React, { useState, useRef, useEffect } from 'react';
import { Header } from './components/Header';
import { SidebarRail } from './components/SidebarRail';
import { Transcript } from './components/Transcript';
import { Composer } from './components/Composer';
import { ThreadsDrawer } from './components/ThreadsDrawer';
import { ToolsDrawer } from './components/ToolsDrawer';
import { SettingsModal } from './components/SettingsModal';
import { PatientPickerModal } from './components/PatientPickerModal';
import { CommandPalette } from './components/CommandPalette';
import { ExportBuilder } from './components/ExportBuilder';
import { ExportCsvBuilder } from './components/ExportCsvBuilder';
import { ReviseNoteModal } from './components/ReviseNoteModal';
import { AssessmentTrendBuilder } from './components/AssessmentTrendBuilder';
import { PromptGallery } from './components/PromptGallery';
import { QuickSelectionPalette, DRAFT_NOTE_OPTIONS, DRAFT_PLAN_OPTIONS, SIMULATION_PRESETS } from './components/QuickSelectionPalette';
import { ThemeProvider } from './context/ThemeContext';
import { Toaster } from './components/ui/sonner';
import { toast } from 'sonner';
import { mockMessages, addMockMessage } from './data/mockData';
import { isBackendCommand, UI_ONLY_BASE_COMMANDS } from './data/commands';
import { isCommandApiEnabled, checkCommandApiHealth, submitCommand, openCommandStream, fetchAssessments, fetchAlerts, fetchRedFlags, fetchExports, fetchSimulations, fetchVisits, type EntityListItem } from './api/commandApi';
import { useThreads } from './hooks/useThreads';
import { useSavedPrompts } from './hooks/useSavedPrompts';
import { useTrafficStreamOptional } from './contexts/TrafficStreamContext';
import type { MessageWithDate } from './services/threadService';

export default function App() {
  const thread = useThreads();
  const savedPrompts = useSavedPrompts();
  const trafficStream = useTrafficStreamOptional();
  /** Which left sidebar panel is open: conversations, tools, or settings. null = sidebar closed */
  const [sidebarPanel, setSidebarPanel] = useState<'threads' | 'tools' | 'settings' | null>(null);
  const [patientPickerOpen, setPatientPickerOpen] = useState(false);
  const [patientPickerForNewThread, setPatientPickerForNewThread] = useState(false);
  const [exportsList, setExportsList] = useState<Array<{ id: string; filename: string; time: string; size: string; type: string }>>([]);
  const [inputValue, setInputValue] = useState('');
  const [currentPatient, setCurrentPatient] = useState<{
    name: string;
    mrn: string;
    status: string;
    risk: string;
  }>({ name: '', mrn: '', status: '', risk: '' });
  const [settings, setSettings] = useState({
    density: 'standard',
    evidenceFooters: true,
    defaultTimeWindow: 'last_14_days',
    modelVersion: false,
    keyboardShortcuts: true
  });
  const [contextEnabled, setContextEnabled] = useState(true);
  const [commandApiStatus, setCommandApiStatus] = useState<'idle' | 'checking' | 'connected' | 'disconnected'>('idle');
  const [commandLoading, setCommandLoading] = useState(false);
  const [pendingCommand, setPendingCommand] = useState<string | null>(null);
  const [showThinking, setShowThinking] = useState(true);
  const [thinkingLive, setThinkingLive] = useState(false);
  const [dataSources, setDataSources] = useState({
    digitalTwin: true,
    assessments: true,
    alerts: true,
    plans: true,
    notes: true,
    labs: true
  });
  
  const [exportBuilderOpen, setExportBuilderOpen] = useState(false);
  const [exportCsvBuilderOpen, setExportCsvBuilderOpen] = useState(false);
  const [reviseNoteOpen, setReviseNoteOpen] = useState(false);
  const [assessmentTrendBuilderOpen, setAssessmentTrendBuilderOpen] = useState(false);
  const [draftNoteOptionsOpen, setDraftNoteOptionsOpen] = useState(false);
  const [draftPlanOptionsOpen, setDraftPlanOptionsOpen] = useState(false);
  const [simulationPresetsOpen, setSimulationPresetsOpen] = useState(false);
  const [promptGalleryOpen, setPromptGalleryOpen] = useState(false);
  const [alertsOptionsOpen, setAlertsOptionsOpen] = useState(false);
  const [summaryOptionsOpen, setSummaryOptionsOpen] = useState(false);
  /** All entity lists from backend (no hardcoded data when API enabled). */
  const [assessmentsFromApi, setAssessmentsFromApi] = useState<EntityListItem[]>([]);
  const [alertsFromApi, setAlertsFromApi] = useState<EntityListItem[]>([]);
  const [redFlagsFromApi, setRedFlagsFromApi] = useState<EntityListItem[]>([]);
  const [exportsFromApi, setExportsFromApi] = useState<EntityListItem[]>([]);
  const [simulationsFromApi, setSimulationsFromApi] = useState<EntityListItem[]>([]);
  const [visitsFromApi, setVisitsFromApi] = useState<EntityListItem[]>([]);
  const [entityFetchError, setEntityFetchError] = useState<string | null>(null);

  const transcriptRef = useRef<HTMLDivElement>(null);
  const messagesRef = useRef<MessageWithDate[]>([]);

  useEffect(() => {
    messagesRef.current = thread.messages;
  }, [thread.messages]);

  // Fetch all entity lists from backend when patient is set and Command API is enabled (no hardcoded data)
  useEffect(() => {
    if (!isCommandApiEnabled() || !currentPatient.mrn?.trim()) {
      setAssessmentsFromApi([]);
      setAlertsFromApi([]);
      setRedFlagsFromApi([]);
      setExportsFromApi([]);
      setSimulationsFromApi([]);
      setVisitsFromApi([]);
      setEntityFetchError(null);
      return;
    }
    const tenantId = 'default';
    const patientId = currentPatient.mrn.trim();
    setEntityFetchError(null);
    let cancelled = false;
    Promise.all([
      fetchAssessments(tenantId, patientId),
      fetchAlerts(tenantId, patientId),
      fetchRedFlags(tenantId, patientId),
      fetchExports(tenantId, patientId),
      fetchSimulations(tenantId, patientId),
      fetchVisits(tenantId, patientId),
    ])
      .then(([assessments, alerts, redFlags, exports, simulations, visits]) => {
        if (!cancelled) {
          setAssessmentsFromApi(assessments);
          setAlertsFromApi(alerts);
          setRedFlagsFromApi(redFlags);
          setExportsFromApi(exports);
          setSimulationsFromApi(simulations);
          setVisitsFromApi(visits);
        }
      })
      .catch((err) => {
        if (!cancelled) {
          const msg = err instanceof Error ? err.message : 'Failed to load data from the API.';
          setEntityFetchError(msg);
          setAssessmentsFromApi([]);
          setAlertsFromApi([]);
          setRedFlagsFromApi([]);
          setExportsFromApi([]);
          setSimulationsFromApi([]);
          setVisitsFromApi([]);
        }
      });
    return () => { cancelled = true; };
  }, [currentPatient.mrn]);

  // Keep currentPatient in sync with the selected conversation so sending a command always has the right patient.
  // Fixes "Select a patient first" when user selects a thread that already has a patient (or after reload).
  useEffect(() => {
    const t = thread.currentThread;
    if (!t) return;
    const mrn = t.patientId?.trim() ?? '';
    const name = (t.patientName?.trim() ?? '').replace(/^No patient selected$/i, '');
    if (!mrn && !name) return;
    setCurrentPatient((prev) => {
      const sameMrn = prev.mrn === mrn;
      if (sameMrn && prev.mrn) return prev; // preserve status/risk from picker when same patient
      return {
        name: name || prev.name,
        mrn,
        status: sameMrn ? prev.status : '',
        risk: sameMrn ? prev.risk : '',
      };
    });
  }, [thread.currentThreadId, thread.currentThread?.id, thread.currentThread?.patientId, thread.currentThread?.patientName]);

  useEffect(() => {
    if (transcriptRef.current) {
      transcriptRef.current.scrollTop = transcriptRef.current.scrollHeight;
    }
  }, [thread.messages]);

  const handleCreateThread = () => {
    thread.createThread({ patientName: currentPatient.name?.trim() || undefined, patientId: currentPatient.mrn || undefined });
    setInputValue('');
  };

  const handleCreateThreadForPatient = (patient: any) => {
    if (!patient?.name) return;
    setCurrentPatient({
      name: patient.name,
      mrn: patient.mrn,
      status: patient.status ?? '',
      risk: patient.risk ?? '',
    });
    thread.createThread({ patientName: patient.name, patientId: patient.mrn });
    setInputValue('');
  };

  const handleSelectThread = (threadId: string) => {
    if (threadId === thread.currentThreadId) return; // already on this conversation; avoid clearing input
    thread.selectThread(threadId);
    setInputValue('');
  };

  // Command API health: check on mount and when settings open; re-check every 60s
  const runHealthCheck = React.useCallback(() => {
    if (!isCommandApiEnabled()) return;
    setCommandApiStatus((s) => (s === 'idle' ? 'checking' : s));
    checkCommandApiHealth()
      .then((r) => setCommandApiStatus(r.ok ? 'connected' : 'disconnected'))
      .catch(() => setCommandApiStatus('disconnected'));
  }, []);
  useEffect(() => {
    if (!isCommandApiEnabled()) return;
    runHealthCheck();
  }, [runHealthCheck]);
  useEffect(() => {
    if (!isCommandApiEnabled() || sidebarPanel !== 'settings') return;
    runHealthCheck();
  }, [sidebarPanel, runHealthCheck]);
  useEffect(() => {
    if (!isCommandApiEnabled()) return;
    const t = setInterval(runHealthCheck, 60_000);
    return () => clearInterval(t);
  }, [runHealthCheck]);

  // Global keyboard shortcuts
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      // Escape key closes open modals/drawers
      if (e.key === 'Escape') {
        if (sidebarPanel !== null) {
          setSidebarPanel(null);
          e.preventDefault();
        } else if (patientPickerOpen) {
          setPatientPickerOpen(false);
          e.preventDefault();
        } else if (exportBuilderOpen) {
          setExportBuilderOpen(false);
        } else if (exportCsvBuilderOpen) {
          setExportCsvBuilderOpen(false);
        } else if (reviseNoteOpen) {
          setReviseNoteOpen(false);
        } else if (assessmentTrendBuilderOpen) {
          setAssessmentTrendBuilderOpen(false);
          e.preventDefault();
        } else if (draftNoteOptionsOpen) {
          setDraftNoteOptionsOpen(false);
          e.preventDefault();
        } else if (draftPlanOptionsOpen) {
          setDraftPlanOptionsOpen(false);
          e.preventDefault();
        } else if (simulationPresetsOpen) {
          setSimulationPresetsOpen(false);
          e.preventDefault();
        } else if (alertsOptionsOpen) {
          setAlertsOptionsOpen(false);
          e.preventDefault();
        } else if (summaryOptionsOpen) {
          setSummaryOptionsOpen(false);
          e.preventDefault();
        }
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [sidebarPanel, patientPickerOpen, exportBuilderOpen, exportCsvBuilderOpen, reviseNoteOpen, assessmentTrendBuilderOpen, draftNoteOptionsOpen, draftPlanOptionsOpen, simulationPresetsOpen, alertsOptionsOpen, summaryOptionsOpen]);

  const updateAssistantMessage = React.useCallback(
    (threadId: string, messageId: string, updater: (m: MessageWithDate) => MessageWithDate) => {
      const next = messagesRef.current.map((m) => (m.id === messageId ? updater(m) : m));
      messagesRef.current = next;
      thread.setThreadMessages(threadId, next);
    },
    [thread]
  );

  const formatThinkingLine = React.useCallback(
    (payload: { event?: string; data?: Record<string, unknown> }) => {
      const eventName = payload.event ?? 'thinking';
      const data = payload.data ?? {};
      const messageText =
        typeof data.message === 'string' && data.message.trim().length > 0
          ? data.message.trim()
          : typeof data.event === 'string' && data.event.trim().length > 0
            ? data.event.trim()
            : null;
      if (messageText) return `${eventName}: ${messageText}`;
      return `${eventName}: ${JSON.stringify(data)}`;
    },
    []
  );

  const handleSendMessage = (message: string, options?: Record<string, unknown>) => {
    if (!message.trim()) return;

    const trimmed = message.trim();
    const baseCommand = trimmed.toLowerCase().split(/\s+/)[0];
    const normalizedBase = baseCommand.startsWith('/') ? baseCommand : '/' + baseCommand;
    const threadId = thread.currentThreadId;

    // UI-only commands: handle locally, do not send to backend
    if (UI_ONLY_BASE_COMMANDS.has(normalizedBase)) {
      if (normalizedBase === '/clear') {
        thread.setThreadMessages(threadId, []);
        return;
      }
      if (normalizedBase === '/new_thread') {
        handleCreateThread();
        return;
      }
      if (normalizedBase === '/help' || normalizedBase === '/shortcuts') {
        thread.addMessage(threadId, {
          id: `msg-${Date.now()}`,
          role: 'user',
          content: message,
          timestamp: new Date()
        } as MessageWithDate);
        thread.addMessage(threadId, {
          id: `msg-${Date.now()}-help`,
          role: 'assistant',
          answer: normalizedBase === '/help' ? 'Type / for commands. Summary, Alerts, Risk factors, and more are in the quick prompts. Use Settings to configure the Command API.' : 'Keyboard shortcuts: Enter to send, Escape to close modals.',
          timestamp: new Date()
        } as MessageWithDate);
        setInputValue('');
        return;
      }
    }

    const userMsg: MessageWithDate = {
      id: `msg-${Date.now()}`,
      role: 'user',
      content: message,
      timestamp: new Date()
    };
    const isFirstMessageInThread = thread.messages.length === 0;
    thread.addMessage(threadId, userMsg);
    if (isFirstMessageInThread) thread.renameThreadFromFirstMessage(threadId, trimmed);
    setInputValue('');

    const isCommand = trimmed.toLowerCase().startsWith('/');
    const isBackendStyleCommand = isCommand && isBackendCommand(normalizedBase);
    const useRealApi = isCommandApiEnabled() && (!isCommand || isBackendStyleCommand);

    if (useRealApi) {
      const tenantId = 'default';
      const patientId = currentPatient.mrn?.trim() || '';
      setCommandLoading(true);
      setPendingCommand(message.trim());
      setThinkingLive(false);
      submitCommand(message.trim(), tenantId, patientId, options)
        .then(({ runId, streamUrl }) => {
          const assistantId = `msg-${Date.now()}-assistant`;
          thread.addMessage(threadId, {
            id: assistantId,
            role: 'assistant',
            answer: '',
            thinkingText: '',
            isStreaming: true,
            streamPhase: 'thinking',
            evidence: { runId, generated: new Date().toLocaleString() },
            timestamp: new Date(),
          } as MessageWithDate);

          const closeStream = openCommandStream(runId, streamUrl, {
            onSseEvent: (payload) => {
              trafficStream?.pushMarchSseEvent?.(
                { event: payload?.event, data: payload?.data as Record<string, unknown>, id: payload?.id },
                runId
              );
              const eventName = payload?.event ?? '';
              if (payload?.channel === 'thinking' && eventName) {
                setThinkingLive(true);
                const line = formatThinkingLine({
                  event: eventName,
                  data: payload.data ?? {},
                });
                updateAssistantMessage(threadId, assistantId, (m) => ({
                  ...m,
                  thinkingText: `${String((m as any).thinkingText ?? '')}${String((m as any).thinkingText ? '\n' : '')}${line}`,
                  isStreaming: true,
                  streamPhase: 'thinking',
                }));
                return;
              }
              if (payload?.channel === 'final' && eventName === 'stream.token') {
                setThinkingLive(false);
                const token = String((payload?.data as Record<string, unknown> | undefined)?.token ?? '').trim();
                if (!token) return;
                updateAssistantMessage(threadId, assistantId, (m) => ({
                  ...m,
                  answer: `${String(m.answer ?? '')}${m.answer ? ' ' : ''}${token}`,
                  isStreaming: true,
                  streamPhase: 'final',
                }));
                return;
              }
              if (payload?.channel === 'final' && eventName === 'stream.end') {
                setThinkingLive(false);
              }
            },
            onWidget: (widget) => {
              updateAssistantMessage(threadId, assistantId, (m) => ({
                ...m,
                answer:
                  widget.type === 'W_SUMMARY_CLINICAL' && !String(m.answer ?? '').trim()
                    ? String((widget.data as Record<string, unknown>)?.summary ?? '')
                    : m.answer,
                widget: { type: widget.type, data: widget.data },
                isStreaming: true,
              }));
              // Feed exports into Tools drawer
              if (widget.type === 'W_EXPORT_LIST' && widget.data?.exports) {
                const list = Array.isArray(widget.data.exports) ? widget.data.exports : [];
                setExportsList(prev => {
                  const byId = new Map(prev.map(e => [e.id, e]));
                  list.forEach((e: { exportId?: string; filename?: string; timestamp?: string; type?: string; size?: string }) => {
                    const id = (e.exportId || e.filename || '').toString();
                    if (id) byId.set(id, {
                      id,
                      filename: (e.filename ?? id).toString(),
                      time: (e.timestamp ?? '').toString(),
                      size: (e.size ?? '—').toString(),
                      type: (e.type ?? 'pdf').toString()
                    });
                  });
                  return Array.from(byId.values());
                });
              }
              if (widget.type === 'W_FILE_PDF' && widget.data) {
                const d = widget.data as { exportId?: string; filename?: string; timestamp?: string };
                const id = (d.exportId || d.filename || `exp-${Date.now()}`).toString();
                setExportsList(prev => [...prev.filter(e => e.id !== id), {
                  id,
                  filename: (d.filename ?? id).toString(),
                  time: (d.timestamp ?? new Date().toLocaleString()).toString(),
                  size: '—',
                  type: 'pdf'
                }]);
              }
            },
            onError: (errorMessage: string) => {
              setThinkingLive(false);
              setCommandLoading(false);
              setPendingCommand(null);
              closeStream();
              updateAssistantMessage(threadId, assistantId, (m) => ({
                ...m,
                answer: (() => {
                  const existing = String(m.answer ?? '').trim();
                  const fallback = errorMessage || 'Stream error. The connection may have been interrupted.';
                  return existing ? `${existing}\n\n${fallback}` : fallback;
                })(),
                isStreaming: false,
                streamPhase: undefined,
                retryCommand: message.trim(),
              }));
            },
            onDone: () => {
              setThinkingLive(false);
              closeStream();
              setCommandLoading(false);
              setPendingCommand(null);
              updateAssistantMessage(threadId, assistantId, (m) => ({
                ...m,
                isStreaming: false,
                streamPhase: undefined,
                answer: m.answer || (m.widget?.type === 'W_SUMMARY_CLINICAL'
                  ? String((m.widget.data as Record<string, unknown>)?.summary ?? '')
                  : ''),
              }));
            }
          });
        })
        .catch((err: unknown) => {
          setThinkingLive(false);
          setCommandLoading(false);
          setPendingCommand(null);
          const errorMessage = err instanceof Error ? err.message : 'Command failed.';
          const response: MessageWithDate = {
            id: `msg-${Date.now()}`,
            role: 'assistant',
            answer: errorMessage,
            evidence: undefined,
            widget: undefined,
            timestamp: new Date(),
            retryCommand: message.trim()
          };
          thread.addMessage(threadId, response);
        });
      return;
    }

    // Mock path: no API URL or not a command
    setTimeout(() => {
      const response = addMockMessage(message) as MessageWithDate;
      thread.addMessage(threadId, response);
    }, 500);
  };

  const handleInputChange = (value: string) => {
    setInputValue(value);
  };

  const handlePromptFromGallery = (promptText: string) => {
    // Route command-style prompts through quick prompt handling where applicable
    const labelMap: Record<string, string> = {
      '/summary': 'Summary',
      '/alerts': 'Alerts',
      '/risk_profile': 'Risk factors',
      '/twin_snapshot': 'Twin snapshot',
      '/simulate': 'Run simulation',
      '/draft_note': 'Draft note',
      '/draft_plan': 'Draft plan',
      '/export_pdf': 'Export PDF',
    };
    const trimmed = promptText.trim();
    const label = labelMap[trimmed.split(/\s+/)[0]];
    if (label) {
      handleQuickPrompt(label);
    } else {
      handleSendMessage(trimmed);
    }
  };

  const handleQuickPrompt = (promptLabel: string) => {
    // Handle chips that need Level-2 palettes
    if (promptLabel === 'Export PDF') {
      setExportBuilderOpen(true);
      return;
    }
    
    if (promptLabel === 'Draft note') {
      setDraftNoteOptionsOpen(true);
      return;
    }
    
    if (promptLabel === 'Draft plan') {
      setDraftPlanOptionsOpen(true);
      return;
    }
    
    if (promptLabel === 'Run simulation') {
      setSimulationPresetsOpen(true);
      return;
    }
    
    if (promptLabel === 'Alerts') {
      setAlertsOptionsOpen(true);
      return;
    }
    
    if (promptLabel === 'Summary') {
      setSummaryOptionsOpen(true);
      return;
    }
    
    // Map quick prompt labels to their commands for auto-send chips
    const commandMap: Record<string, string> = {
      'Latest assessment': '/latest_assessment',
      'Risk factors': '/risk_profile',
      'Twin snapshot': '/twin_snapshot'
    };
    
    const command = commandMap[promptLabel];
    if (command) {
      handleSendMessage(command);
    } else {
      handleSendMessage(promptLabel);
    }
  };
  
  // Level-2 selection handlers
  const handleExport = (sections: string[], range: string) => {
    const sectionsStr = sections.join(',');
    handleSendMessage(`/export_pdf sections=[${sectionsStr}] range=${range}`);
    setExportBuilderOpen(false);
  };

  const handleExportCsv = (dataset: string, range: string) => {
    handleSendMessage(`/export_csv dataset=${dataset} range=${range}`);
    setExportCsvBuilderOpen(false);
  };

  const handleReviseNote = (instruction: string) => {
    const escaped = instruction.replace(/\\/g, '\\\\').replace(/"/g, '\\"');
    handleSendMessage(`/revise_note "${escaped}"`);
    setReviseNoteOpen(false);
  };

  const handleAssessmentTrend = (metric: string, range: string) => {
    handleSendMessage(`/assessment_trend ${metric} range=${range}`);
    setAssessmentTrendBuilderOpen(false);
  };

  const handleDraftNoteSelect = (format: string) => {
    handleSendMessage(`/draft_note format=${format}`);
    setDraftNoteOptionsOpen(false);
  };
  
  const handleDraftPlanSelect = (focus: string) => {
    handleSendMessage(`/draft_plan focus=${focus}`);
    setDraftPlanOptionsOpen(false);
  };
  
  const handleSimulationPresetSelect = (preset: string) => {
    handleSendMessage(`/simulate preset=${preset}`);
    setSimulationPresetsOpen(false);
  };
  
  const handleSimulationGenerate = (command: string) => {
    handleSendMessage(command);
    setSimulationPresetsOpen(false);
  };

  const handlePatientChange = (patient: any) => {
    setCurrentPatient(patient);

    // Find an existing conversation for this patient (most recent), or create one
    if (patient?.name) {
      const byPatient = thread.threads
        .filter(
          (t) =>
            (t.patientId && t.patientId === patient.mrn) ||
            (!t.patientId && t.patientName && t.patientName === patient.name)
        )
        .sort((a, b) => new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime());

      const existing = byPatient[0];

      if (existing) {
        // Jump straight into that patient's latest conversation (only clear input if switching thread)
        thread.updateThreadPatient(existing.id, { name: patient.name, mrn: patient.mrn });
        if (existing.id !== thread.currentThreadId) {
          thread.selectThread(existing.id);
          setInputValue('');
        }
      } else {
        // Start a fresh conversation for this patient
        thread.createThread({ patientName: patient.name, patientId: patient.mrn });
        setInputValue('');
      }
    }

    setPatientPickerOpen(false);
  };

  const sidebarOpen = sidebarPanel !== null;

  // Chat is only allowed when the current conversation is tied to a real patient (no placeholder).
  const currentThread = thread.currentThread;
  const hasPatientOnThread =
    currentThread &&
    (!!currentThread.patientId ||
      (!!currentThread.patientName &&
        currentThread.patientName.trim() !== 'No patient selected'));
  const canChat = !!hasPatientOnThread;

  const handleSavePromptFromMessage = (title: string, prompt: string) => {
    const alreadySaved = savedPrompts.prompts.some((p) => p.prompt === prompt.trim());
    if (alreadySaved) return;
    savedPrompts.save(title, prompt);
    toast.success('Added to saved prompts');
  };

  const handleRemoveSavedFromMessage = (promptText: string) => {
    const found = savedPrompts.prompts.find((p) => p.prompt === promptText);
    if (found) {
      savedPrompts.remove(found.id);
      toast.success('Removed from saved prompts');
    }
  };

  return (
    <ThemeProvider>
      <Toaster position="bottom-center" />
      <div className="h-screen flex bg-background overflow-hidden">
      <SidebarRail
        sidebarOpen={sidebarOpen}
        onToggleSidebar={() => setSidebarPanel((p) => (p === null ? 'threads' : null))}
        onThreadsClick={() => setSidebarPanel('threads')}
        onToolsClick={() => setSidebarPanel('tools')}
        onSettingsClick={() => setSidebarPanel('settings')}
        activePanel={sidebarPanel}
      />

      {sidebarPanel === 'threads' && (
        <ThreadsDrawer
          open
          onClose={() => setSidebarPanel(null)}
          asSidebar
          threadsByPatient={thread.threadsByPatient}
          currentThreadId={thread.currentThreadId}
          currentThread={thread.currentThread}
          currentPatient={currentPatient.name?.trim() ? { name: currentPatient.name, mrn: currentPatient.mrn, status: currentPatient.status, risk: currentPatient.risk } : null}
          onSelectThread={handleSelectThread}
          onCreateThread={handleCreateThread}
          onCreateThreadForPatient={handleCreateThreadForPatient}
          onOpenPatientPickerForNewThread={() => {
            setPatientPickerForNewThread(true);
            setPatientPickerOpen(true);
          }}
          onDeleteThread={thread.deleteThread}
        />
      )}

      {sidebarPanel === 'tools' && (
        <ToolsDrawer
          open
          onClose={() => setSidebarPanel(null)}
          asSidebar
          contextEnabled={contextEnabled}
          onContextToggle={setContextEnabled}
          dataSources={dataSources}
          onDataSourcesChange={setDataSources}
          timeWindow={settings.defaultTimeWindow}
          exportsList={exportsList}
          commandApiEnabled={isCommandApiEnabled()}
          commandApiStatus={commandApiStatus}
          onCheckCommandApi={runHealthCheck}
        />
      )}

      {sidebarPanel === 'settings' && (
        <SettingsModal
          open
          onClose={() => setSidebarPanel(null)}
          asSidebar
          settings={settings}
          onSettingsChange={setSettings}
          commandApiEnabled={isCommandApiEnabled()}
          commandApiStatus={commandApiStatus}
          onCheckCommandApi={runHealthCheck}
        />
      )}

      <div className="flex-1 flex flex-col min-w-0 bg-background">
        <Header
          commandApiEnabled={isCommandApiEnabled()}
          commandApiStatus={commandApiStatus}
          patientName={currentPatient.name}
          patientMrn={currentPatient.mrn}
        />

        <div className="mx-auto w-full max-w-3xl px-4 sm:px-8 pt-3">
          <div className="flex items-center justify-between rounded-lg border border-border bg-card px-3 py-2 text-xs">
            <div className="flex items-center gap-2">
              <span className={`inline-block h-2 w-2 rounded-full ${thinkingLive ? 'bg-emerald-500 animate-pulse' : 'bg-slate-300'}`} />
              <span className="text-muted-foreground">
                {thinkingLive ? 'Thinking stream is live' : 'Thinking stream idle'}
              </span>
            </div>
            <label className="flex items-center gap-2 text-muted-foreground">
              <input
                type="checkbox"
                checked={showThinking}
                onChange={(e) => setShowThinking(e.target.checked)}
              />
              Show thinking
            </label>
          </div>
        </div>

        <Transcript
        key={thread.currentThreadId}
        ref={transcriptRef}
        messages={thread.messages}
        density={settings.density}
        showEvidence={settings.evidenceFooters}
        showThinking={showThinking}
        isCommandLoading={commandLoading}
        pendingCommand={pendingCommand}
        onRetryCommand={handleSendMessage}
        onSavePrompt={handleSavePromptFromMessage}
        onRemoveSavedPrompt={handleRemoveSavedFromMessage}
        isPromptSaved={(prompt) => savedPrompts.prompts.some((p) => p.prompt === prompt)}
      />

        {entityFetchError && (
          <div className="mx-auto max-w-4xl px-3 py-2 flex items-center justify-between gap-2 bg-amber-50 dark:bg-amber-950/30 border border-amber-200 dark:border-amber-800 rounded-lg text-sm text-amber-800 dark:text-amber-200">
            <span>{entityFetchError}</span>
            <button
              type="button"
              onClick={() => setEntityFetchError(null)}
              className="shrink-0 px-2 py-1 rounded hover:bg-amber-100 dark:hover:bg-amber-900/50 text-amber-700 dark:text-amber-300 font-medium"
              aria-label="Dismiss"
            >
              Dismiss
            </button>
          </div>
        )}

      <Composer
        value={inputValue}
        onChange={handleInputChange}
        onSend={handleSendMessage}
        onQuickPrompt={handleQuickPrompt}
        simulationBuilderOpen={simulationPresetsOpen}
        onSimulationGenerate={handleSimulationGenerate}
        onSimulationBuilderClose={() => setSimulationPresetsOpen(false)}
        commandLoading={commandLoading}
        canChat={canChat}
        assessmentsFromApi={assessmentsFromApi}
        alertsFromApi={alertsFromApi}
        redFlagsFromApi={redFlagsFromApi}
        exportsFromApi={exportsFromApi}
        simulationsFromApi={simulationsFromApi}
        visitsFromApi={visitsFromApi}
        onOpenSelectPatient={() => {
          setPatientPickerForNewThread(false);
          setPatientPickerOpen(true);
        }}
        onOpenExportBuilder={() => setExportBuilderOpen(true)}
        onOpenExportCsvBuilder={() => setExportCsvBuilderOpen(true)}
        onOpenReviseNoteModal={() => setReviseNoteOpen(true)}
        onOpenAssessmentTrendBuilder={() => setAssessmentTrendBuilderOpen(true)}
        onOpenPromptGallery={() => setPromptGalleryOpen(true)}
      />
      </div>

      <PatientPickerModal
        open={patientPickerOpen}
        onClose={() => {
          setPatientPickerOpen(false);
          setPatientPickerForNewThread(false);
        }}
        onSelectPatient={(patient) => {
          if (patientPickerForNewThread) {
            handleCreateThreadForPatient(patient);
            setPatientPickerForNewThread(false);
            setPatientPickerOpen(false);
          } else {
            handlePatientChange(patient);
          }
        }}
      />

      
      {/* Level-2 Palettes */}
      {exportBuilderOpen && (
        <ExportBuilder
          onExport={handleExport}
          onClose={() => setExportBuilderOpen(false)}
        />
      )}

      {exportCsvBuilderOpen && (
        <ExportCsvBuilder
          onExport={handleExportCsv}
          onClose={() => setExportCsvBuilderOpen(false)}
        />
      )}

      {reviseNoteOpen && (
        <ReviseNoteModal
          onSubmit={handleReviseNote}
          onClose={() => setReviseNoteOpen(false)}
        />
      )}

      {assessmentTrendBuilderOpen && (
        <AssessmentTrendBuilder
          onSubmit={handleAssessmentTrend}
          onClose={() => setAssessmentTrendBuilderOpen(false)}
        />
      )}
      
      {draftNoteOptionsOpen && (
        <QuickSelectionPalette
          title="Draft note"
          subtitle="Select note format"
          options={DRAFT_NOTE_OPTIONS}
          onSelect={handleDraftNoteSelect}
          onClose={() => setDraftNoteOptionsOpen(false)}
        />
      )}
      
      {draftPlanOptionsOpen && (
        <QuickSelectionPalette
          title="Draft plan"
          subtitle="Select plan focus"
          options={DRAFT_PLAN_OPTIONS}
          onSelect={handleDraftPlanSelect}
          onClose={() => setDraftPlanOptionsOpen(false)}
        />
      )}
      
      {alertsOptionsOpen && (
        <QuickSelectionPalette
          title="Alerts"
          subtitle="Filter by acknowledgment status"
          options={[
            { id: 'unacknowledged', label: 'Unacknowledged only' },
            { id: 'acknowledged', label: 'Acknowledged only' },
            { id: 'all', label: 'All alerts' }
          ]}
          onSelect={(id) => {
            const options = id === 'acknowledged' ? { acknowledged: true } : id === 'all' ? { showAll: true } : undefined;
            handleSendMessage('/alerts', options);
            setAlertsOptionsOpen(false);
          }}
          onClose={() => setAlertsOptionsOpen(false)}
        />
      )}
      
      {summaryOptionsOpen && (
        <QuickSelectionPalette
          title="Summary"
          subtitle="Time window for patient context"
          options={[
            { id: 'last_7_days', label: 'Last 7 days' },
            { id: 'last_24_hours', label: 'Last 24 hours' }
          ]}
          onSelect={(id) => {
            const options = id === 'last_24_hours' ? { window: 'last_24_hours' } : undefined;
            handleSendMessage('/summary', options);
            setSummaryOptionsOpen(false);
          }}
          onClose={() => setSummaryOptionsOpen(false)}
        />
      )}

      {promptGalleryOpen && (
        <PromptGallery
          open={promptGalleryOpen}
          onClose={() => setPromptGalleryOpen(false)}
          savedPrompts={savedPrompts.prompts}
          onUsePrompt={handlePromptFromGallery}
          onSavePrompt={(title, prompt, category) => savedPrompts.save(title, prompt, category)}
          onRemoveSaved={savedPrompts.remove}
          isSaved={(promptText) => savedPrompts.prompts.some((p) => p.prompt === promptText)}
        />
      )}
      
      </div>
    </ThemeProvider>
  );
}