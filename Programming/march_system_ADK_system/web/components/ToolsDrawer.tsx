import React, { useState } from 'react';
import { X, ChevronRight, ChevronUp, ChevronDown, FileText, Download, HelpCircle, Keyboard, Info, ArrowLeft } from 'lucide-react';
import { sidebar } from './sidebarStyles';
import { commandCategories } from '../data/commands';

export interface ExportItem {
  id: string;
  filename: string;
  time: string;
  size: string;
  type: string;
}

type CommandApiStatus = 'idle' | 'checking' | 'connected' | 'disconnected';

interface ToolsDrawerProps {
  open: boolean;
  onClose: () => void;
  asSidebar?: boolean;
  contextEnabled: boolean;
  onContextToggle: (enabled: boolean) => void;
  dataSources: {
    digitalTwin: boolean;
    assessments: boolean;
    alerts: boolean;
    plans: boolean;
    notes: boolean;
    labs: boolean;
  };
  onDataSourcesChange: (sources: any) => void;
  timeWindow: string;
  exportsList?: ExportItem[];
  commandApiEnabled?: boolean;
  commandApiStatus?: CommandApiStatus;
  onCheckCommandApi?: () => void;
}

const APP_VERSION = '1.0.0';

const KEYBOARD_SHORTCUTS = [
  { keys: 'Enter', description: 'Send message' },
  { keys: 'Shift + Enter', description: 'New line in composer' },
  { keys: 'Escape', description: 'Close sidebar, modals, or pickers' },
  { keys: '/', description: 'Open command palette' },
  { keys: '↑ / ↓', description: 'Navigate in command palette or pickers' },
  { keys: 'Enter', description: 'Select in palette or pickers' },
  { keys: 'Cmd/Ctrl + Enter', description: 'Confirm in Export builder' },
];

export function ToolsDrawer({
  open,
  onClose,
  asSidebar = false,
  contextEnabled,
  onContextToggle,
  dataSources,
  onDataSourcesChange,
  timeWindow,
  exportsList = [],
  commandApiEnabled = false,
  commandApiStatus = 'idle',
  onCheckCommandApi,
}: ToolsDrawerProps) {
  const [advancedExpanded, setAdvancedExpanded] = useState(false);
  const [activeSection, setActiveSection] = useState<'documentation' | 'keyboardShortcuts' | 'systemInfo' | null>(null);

  if (!open) return null;

  const pad = asSidebar ? sidebar.bodyPad : 'px-3 sm:px-5 py-2 sm:py-4';
  const padDiv = asSidebar ? 'mb-2' : 'border-b border-border';
  const sectionClass = asSidebar ? sidebar.sectionLabel : 'text-[10px] sm:text-xs font-medium text-muted-foreground uppercase tracking-wide mb-1.5 sm:mb-3';
  const rowClass = asSidebar ? sidebar.rowButton : 'w-full flex items-center justify-between py-1.5 sm:py-2.5 px-2 sm:px-3 rounded-md sm:rounded-lg hover:bg-accent transition-colors group';

  const panel = (
    <div
      className={
        asSidebar
          ? sidebar.root
          : 'fixed right-0 top-0 bottom-0 w-full sm:w-96 bg-card border-l border-border z-50 flex flex-col'
      }
    >
      <div className={asSidebar ? sidebar.header : 'border-b border-border px-3 sm:px-5 py-3 flex items-center justify-between bg-card flex-shrink-0'}>
        <div className="flex items-center gap-2 min-w-0">
          {activeSection && (
            <button
              type="button"
              onClick={() => setActiveSection(null)}
              className="flex items-center justify-center w-6 h-6 rounded text-muted-foreground hover:text-foreground hover:bg-accent transition-colors flex-shrink-0"
              aria-label="Back"
            >
              <ArrowLeft className="w-3 h-3" strokeWidth={2} strokeLinecap="round" strokeLinejoin="round" />
            </button>
          )}
          <h2 className={sidebar.title}>
            {activeSection === 'documentation' ? 'Documentation' : activeSection === 'keyboardShortcuts' ? 'Keyboard Shortcuts' : activeSection === 'systemInfo' ? 'System Information' : 'Tools'}
          </h2>
        </div>
        <button onClick={onClose} className={sidebar.closeButton} aria-label="Close sidebar">
          <X className="w-3 h-3" />
        </button>
      </div>

      <div className={`${sidebar.body} ${pad}`}>
        {activeSection === 'documentation' && (
          <div className="space-y-4">
            {/* Getting started - card */}
            <div className={`${sidebar.card} p-3 space-y-2`}>
              <h3 className="text-[10px] font-semibold text-muted-foreground uppercase tracking-wider">Getting started</h3>
              <p className="text-[12px] text-foreground leading-snug">
                Type in the composer to ask about a patient. Press <kbd className="inline-flex items-center px-1.5 py-0.5 rounded bg-muted text-foreground font-mono text-[11px] border border-border">/</kbd> to open the command palette and run clinical commands. Quick prompts above the input run common actions in one tap.
              </p>
            </div>

            {/* Commands - one card per category */}
            <div className="space-y-3">
              <h3 className="text-[10px] font-semibold text-muted-foreground uppercase tracking-wider px-0.5">Commands</h3>
              {Object.entries(commandCategories).map(([category, items]) => (
                <div key={category} className={`${sidebar.card} p-3`}>
                  <p className="text-[10px] font-medium text-foreground mb-2 border-b border-border pb-1.5">{category}</p>
                  <ul className="space-y-2">
                    {items.map((item) => {
                      const dash = item.indexOf(' - ');
                      const cmd = dash >= 0 ? item.slice(0, dash) : item;
                      const desc = dash >= 0 ? item.slice(dash + 3) : '';
                      return (
                        <li key={item} className="flex flex-col gap-0.5">
                          <code className="text-[11px] font-mono text-primary bg-secondary/50 border border-primary/30 rounded px-1.5 py-0.5 w-fit">
                            {cmd}
                          </code>
                          {desc && <span className="text-[11px] text-muted-foreground pl-0.5">{desc}</span>}
                        </li>
                      );
                    })}
                  </ul>
                </div>
              ))}
            </div>

            {/* Quick prompts - card */}
            <div className={`${sidebar.card} p-3 space-y-2`}>
              <h3 className="text-[10px] font-semibold text-muted-foreground uppercase tracking-wider">Quick prompts</h3>
              <p className="text-[12px] text-foreground leading-snug">
                Summary, Latest assessment, Risk factors, Alerts, Twin snapshot, Run simulation, Draft note, Draft plan, Export PDF.
              </p>
              <p className="text-[10px] text-muted-foreground">
                Use Settings to configure response density and Command API.
              </p>
            </div>
          </div>
        )}

        {activeSection === 'keyboardShortcuts' && (
          <div className="space-y-4">
            <p className="text-[11px] text-muted-foreground">Shortcuts apply when the relevant panel or input is focused.</p>
            <div className={`${sidebar.card} divide-y divide-border`}>
              {KEYBOARD_SHORTCUTS.map(({ keys, description }) => (
                <div key={keys + description} className="flex items-center justify-between gap-3 py-2.5 px-3">
                  <kbd className="text-[11px] font-mono text-foreground bg-muted border border-border px-2 py-1 rounded">{keys}</kbd>
                  <span className="text-[11px] text-muted-foreground text-right">{description}</span>
                </div>
              ))}
            </div>
          </div>
        )}

        {activeSection === 'systemInfo' && (
          <div className="space-y-2">
            <div className="rounded-md bg-card border border-border p-2 space-y-1">
              <div className="flex justify-between items-center">
                <span className="text-[10px] text-muted-foreground">App version</span>
                <span className="text-[10px] font-medium text-foreground">{APP_VERSION}</span>
              </div>
              <div className="flex justify-between items-center">
                <span className="text-[10px] text-muted-foreground">Environment</span>
                <span className="text-[10px] font-medium text-foreground">{typeof window !== 'undefined' && window.location?.hostname === 'localhost' ? 'Development' : 'Production'}</span>
              </div>
            </div>
            {commandApiEnabled && (
              <div className="rounded-md bg-card border border-border p-2">
                <div className="flex items-center justify-between gap-1.5 mb-1">
                  <span className="text-[10px] font-medium text-foreground">Command API</span>
                  <span className={`text-[9px] font-medium ${
                    commandApiStatus === 'connected' ? 'text-emerald-600' : commandApiStatus === 'checking' ? 'text-amber-600' : 'text-slate-500'
                  }`}>
                    {commandApiStatus === 'connected' ? 'Connected' : commandApiStatus === 'checking' ? 'Checking…' : commandApiStatus === 'disconnected' ? 'Unavailable' : 'Not checked'}
                  </span>
                </div>
                <p className="text-[9px] text-muted-foreground mb-1">
                  {commandApiStatus === 'connected' ? 'Backend is reachable. Commands will be sent to the API.' : 'Verify connection to run clinical commands.'}
                </p>
                {onCheckCommandApi && (
                  <button
                    type="button"
                    onClick={onCheckCommandApi}
                    disabled={commandApiStatus === 'checking'}
                    className="w-full py-1 rounded-md border border-border text-[10px] font-medium text-foreground hover:bg-accent disabled:opacity-50 transition-colors"
                  >
                    {commandApiStatus === 'checking' ? 'Checking…' : 'Verify connection'}
                  </button>
                )}
              </div>
            )}
            <div className="rounded-md bg-card border border-border p-2">
              <p className="text-[9px] text-muted-foreground uppercase tracking-wider mb-0.5">Browser</p>
              <p className="text-[10px] text-foreground break-all">
                {typeof navigator !== 'undefined' ? navigator.userAgent : '—'}
              </p>
            </div>
          </div>
        )}

        {!activeSection && (
          <>
            {/* RECENT EXPORTS */}
            <div className={padDiv}>
              <div className={sectionClass}>Recent exports</div>
              <div className="space-y-1 mb-1">
                {exportsList.length === 0 && (
                  <div className="py-1.5 text-muted-foreground text-[10px]">No exports yet. Use /export_pdf or /export_csv.</div>
                )}
                {exportsList.slice(0, 3).map((exp) => (
                  <div
                    key={exp.id}
                    className="flex items-center gap-2 p-2 rounded-md bg-card border border-border shadow-sm hover:shadow transition-shadow group"
                  >
                    <div className="flex-shrink-0 w-7 h-7 rounded-md bg-muted flex items-center justify-center">
                      <FileText className="w-3.5 h-3.5 text-foreground" strokeWidth={2} strokeLinecap="round" strokeLinejoin="round" />
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="text-[11px] font-semibold text-foreground truncate">{exp.filename}</div>
                      <div className="flex items-center gap-1 mt-0.5 flex-wrap">
                        <span className="inline-flex px-1 py-0.5 rounded text-[8px] font-medium bg-muted text-muted-foreground">{exp.type}</span>
                        <span className="text-[8px] text-muted-foreground">{exp.time}</span>
                      </div>
                    </div>
                    <button className="flex-shrink-0 p-1 hover:bg-accent rounded transition-colors opacity-70 group-hover:opacity-100" title="Download">
                      <Download className="w-3 h-3 text-muted-foreground" strokeWidth={2} strokeLinecap="round" strokeLinejoin="round" />
                    </button>
                  </div>
                ))}
              </div>
              <button className={`${rowClass} rounded-md py-1`}>
                <span className={`text-[11px] ${sidebar.rowLink}`}>View all exports</span>
                <ChevronRight className={`w-3 h-3 ${sidebar.rowLink}`} strokeWidth={2} strokeLinecap="round" strokeLinejoin="round" />
              </button>
            </div>

            {/* RESOURCES */}
            <div className={padDiv}>
              <div className={sectionClass}>Resources</div>
              <div className="space-y-0.5">
                <button
                  onClick={() => setActiveSection('documentation')}
                  className={`${rowClass} rounded-md py-1.5 px-2 bg-card border border-border shadow-sm hover:bg-accent/50 w-full`}
                >
                  <div className="flex items-center gap-2 min-w-0">
                    <div className="flex-shrink-0 w-6 h-6 rounded bg-muted flex items-center justify-center">
                      <HelpCircle className="w-3 h-3 text-foreground" strokeWidth={2} strokeLinecap="round" strokeLinejoin="round" />
                    </div>
                    <span className="text-[11px] font-medium text-foreground">Documentation</span>
                  </div>
                  <ChevronRight className="w-3 h-3 text-muted-foreground flex-shrink-0" strokeWidth={2} strokeLinecap="round" strokeLinejoin="round" />
                </button>
                <button
                  onClick={() => setActiveSection('keyboardShortcuts')}
                  className={`${rowClass} rounded-md py-1.5 px-2 bg-card border border-border shadow-sm hover:bg-accent/50 w-full`}
                >
                  <div className="flex items-center gap-2 min-w-0">
                    <div className="flex-shrink-0 w-6 h-6 rounded bg-muted flex items-center justify-center">
                      <Keyboard className="w-3 h-3 text-foreground" strokeWidth={2} strokeLinecap="round" strokeLinejoin="round" />
                    </div>
                    <span className="text-[11px] font-medium text-foreground">Keyboard Shortcuts</span>
                  </div>
                  <ChevronRight className="w-3 h-3 text-muted-foreground flex-shrink-0" strokeWidth={2} strokeLinecap="round" strokeLinejoin="round" />
                </button>
              </div>
            </div>

            {/* ADVANCED - System Information only */}
            <div>
              <button
                onClick={() => setAdvancedExpanded(!advancedExpanded)}
                className={`${rowClass} rounded-md py-1.5 px-2 bg-card border border-border shadow-sm hover:bg-accent/50 w-full`}
              >
                <span className="text-[11px] font-medium text-foreground">Advanced</span>
                {advancedExpanded ? (
                  <ChevronUp className="w-3 h-3 text-muted-foreground flex-shrink-0" strokeWidth={2} strokeLinecap="round" strokeLinejoin="round" />
                ) : (
                  <ChevronDown className="w-3 h-3 text-muted-foreground flex-shrink-0" strokeWidth={2} strokeLinecap="round" strokeLinejoin="round" />
                )}
              </button>
              {advancedExpanded && (
                <div className="mt-0.5 space-y-0.5">
                  <button
                    onClick={() => setActiveSection('systemInfo')}
                    className={`${rowClass} rounded-md py-1.5 px-2 bg-card border border-border shadow-sm hover:bg-accent/50 w-full`}
                  >
                    <div className="flex items-center gap-2 min-w-0">
                      <div className="flex-shrink-0 w-6 h-6 rounded bg-muted flex items-center justify-center">
                        <Info className="w-3 h-3 text-foreground" strokeWidth={2} strokeLinecap="round" strokeLinejoin="round" />
                      </div>
                      <span className="text-[11px] font-medium text-foreground">System Information</span>
                    </div>
                    <ChevronRight className="w-3 h-3 text-muted-foreground flex-shrink-0" strokeWidth={2} strokeLinecap="round" strokeLinejoin="round" />
                  </button>
                </div>
              )}
            </div>
          </>
        )}
      </div>
    </div>
  );

  if (asSidebar) return panel;

  return (
    <>
      <div className="fixed inset-0 bg-black/30 dark:bg-black/40 z-40" onClick={onClose} aria-hidden />
      {panel}
    </>
  );
}