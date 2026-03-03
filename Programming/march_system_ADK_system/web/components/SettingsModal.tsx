import React from 'react';
import { X, RefreshCw, CheckCircle, XCircle } from 'lucide-react';
import { sidebar } from './sidebarStyles';

type CommandApiStatus = 'idle' | 'checking' | 'connected' | 'disconnected';

interface SettingsModalProps {
  open: boolean;
  onClose: () => void;
  /** When true, render as inline sidebar panel (no overlay) */
  asSidebar?: boolean;
  settings: {
    density: string;
    evidenceFooters: boolean;
    defaultTimeWindow: string;
    modelVersion: boolean;
    keyboardShortcuts: boolean;
  };
  onSettingsChange: (settings: any) => void;
  commandApiEnabled?: boolean;
  commandApiStatus?: CommandApiStatus;
  onCheckCommandApi?: () => void;
}

export function SettingsModal({ open, onClose, asSidebar = false, settings, onSettingsChange, commandApiEnabled = false, commandApiStatus = 'idle', onCheckCommandApi }: SettingsModalProps) {
  if (!open) return null;

  const updateSetting = (key: string, value: any) => {
    onSettingsChange({ ...settings, [key]: value });
  };

  const densityLabels: Record<string, string> = { compact: 'Compact', standard: 'Standard', detailed: 'Detailed' };

  const content = (
    <div
      className={
        asSidebar
          ? sidebar.root
          : 'bg-card rounded-lg sm:rounded-xl w-full max-w-md mx-2 sm:mx-4 max-h-[90vh] sm:max-h-[85vh] overflow-y-auto border border-border'
      }
    >
      <div className={asSidebar ? sidebar.header : 'border-b border-border flex items-center justify-between flex-shrink-0 sticky top-0 z-10 px-3 sm:px-6 py-2 sm:py-4 bg-card'}>
        <h2 className={sidebar.title}>Settings</h2>
        <button onClick={onClose} className={sidebar.closeButton} aria-label="Close">
          <X className="w-3 h-3" />
        </button>
      </div>

      <div className={`${sidebar.body} ${asSidebar ? sidebar.bodyPad : 'px-3 sm:px-6 py-3 sm:py-6'} space-y-3`}>
            {/* NOTE FORMAT */}
            <div>
              <p className={sidebar.sectionLabel}>Note format</p>
              <div className="flex gap-1">
                {(['compact', 'standard', 'detailed'] as const).map((density) => (
                  <button
                    key={density}
                    onClick={() => updateSetting('density', density)}
                    className={`flex-1 px-2 py-1 rounded-md border transition-colors text-[10px] font-medium ${
                      settings.density === density ? sidebar.pillSolidSelected : sidebar.pillDefault
                    }`}
                  >
                    {densityLabels[density]}
                  </button>
                ))}
              </div>
            </div>

            {/* CLINICAL PREFERENCES - one white card */}
            <div>
              <p className={sidebar.sectionLabel}>Clinical preferences</p>
              <div className={`${sidebar.card} divide-y divide-border`}>
                <div className="flex items-center justify-between gap-1.5 px-2 py-1.5">
                  <div className="flex-1 min-w-0">
                    <div className="text-[10px] font-medium text-foreground">Show Evidence Footers</div>
                    <div className="text-[8px] text-muted-foreground">Display sources and confidence metrics</div>
                  </div>
                  <button
                    onClick={() => updateSetting('evidenceFooters', !settings.evidenceFooters)}
                    className={`relative w-9 h-4 rounded-full transition-colors flex-shrink-0 ${
                      settings.evidenceFooters ? sidebar.toggleOn : sidebar.toggleOff
                    }`}
                  >
                    <span className={`absolute top-0.5 left-0.5 w-3.5 h-3.5 bg-white rounded-full transition-transform ${settings.evidenceFooters ? 'translate-x-5' : 'translate-x-0'}`} />
                  </button>
                </div>
                <div className="flex items-center justify-between gap-1.5 px-2 py-1.5">
                  <div className="flex-1 min-w-0">
                    <div className="text-[10px] font-medium text-foreground">Show Model Version</div>
                    <div className="text-[8px] text-muted-foreground">Display AI model version in responses</div>
                  </div>
                  <button
                    onClick={() => updateSetting('modelVersion', !settings.modelVersion)}
                    className={`relative w-9 h-4 rounded-full transition-colors flex-shrink-0 ${settings.modelVersion ? sidebar.toggleOn : sidebar.toggleOff}`}
                  >
                    <span className={`absolute top-0.5 left-0.5 w-3.5 h-3.5 bg-white rounded-full transition-transform ${settings.modelVersion ? 'translate-x-5' : 'translate-x-0'}`} />
                  </button>
                </div>
                <div className="flex items-center justify-between gap-1.5 px-2 py-1.5">
                  <div className="flex-1 min-w-0">
                    <div className="text-[10px] font-medium text-foreground">Keyboard Shortcuts</div>
                    <div className="text-[8px] text-muted-foreground">Enable keyboard shortcuts</div>
                  </div>
                  <button
                    onClick={() => updateSetting('keyboardShortcuts', !settings.keyboardShortcuts)}
                    className={`relative w-9 h-4 rounded-full transition-colors flex-shrink-0 ${settings.keyboardShortcuts ? sidebar.toggleOn : sidebar.toggleOff}`}
                  >
                    <span className={`absolute top-0.5 left-0.5 w-3.5 h-3.5 bg-white rounded-full transition-transform ${settings.keyboardShortcuts ? 'translate-x-5' : 'translate-x-0'}`} />
                  </button>
                </div>
              </div>
            </div>

            {/* DATA RETENTION POLICY */}
            <div>
              <p className={sidebar.sectionLabel}>Data retention policy</p>
              <select
                value={settings.defaultTimeWindow}
                onChange={(e) => updateSetting('defaultTimeWindow', e.target.value)}
                className="w-full px-2 py-1 border border-border rounded-md focus:outline-none focus:ring-2 focus:ring-primary text-[10px] bg-card text-foreground"
              >
                <option value="last_7_days">Last 7 days</option>
                <option value="last_14_days">Last 14 days</option>
                <option value="last_30_days">Last 30 days</option>
                <option value="last_6_months">Last 6 months</option>
                <option value="all">All time</option>
              </select>
              <p className="text-[8px] text-muted-foreground mt-0.5">Time window for data shown in context.</p>
            </div>

            {/* SYSTEM STATUS */}
            {commandApiEnabled && (
              <div>
                <p className={sidebar.sectionLabel}>System status</p>
                <div className={`${sidebar.card} px-2 py-1.5 flex items-center gap-2`}>
                  <div className={`flex-shrink-0 w-6 h-6 rounded-full flex items-center justify-center ${
                    commandApiStatus === 'connected' ? 'bg-emerald-100 dark:bg-emerald-900/30' : commandApiStatus === 'checking' ? 'bg-amber-100 dark:bg-amber-900/30' : 'bg-muted'
                  }`}>
                    {commandApiStatus === 'connected' ? (
                      <CheckCircle className="w-3.5 h-3.5 text-emerald-600" strokeWidth={2} strokeLinecap="round" strokeLinejoin="round" />
                    ) : commandApiStatus === 'disconnected' ? (
                      <XCircle className="w-3.5 h-3.5 text-muted-foreground" strokeWidth={2} strokeLinecap="round" strokeLinejoin="round" />
                    ) : (
                      <RefreshCw className={`w-3.5 h-3.5 text-amber-600 ${commandApiStatus === 'checking' ? 'animate-spin' : ''}`} strokeWidth={2} strokeLinecap="round" strokeLinejoin="round" />
                    )}
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="text-[10px] font-semibold text-foreground">
                      {commandApiStatus === 'connected' && 'Connected'}
                      {commandApiStatus === 'checking' && 'Checking…'}
                      {commandApiStatus === 'disconnected' && 'Unavailable'}
                      {commandApiStatus === 'idle' && 'Not checked'}
                    </div>
                    <div className="text-[8px] text-muted-foreground">
                      {commandApiStatus === 'connected' && 'System operational'}
                      {commandApiStatus === 'checking' && 'Verifying connection…'}
                      {commandApiStatus === 'disconnected' && 'Backend unavailable'}
                      {commandApiStatus === 'idle' && 'Check connection status'}
                    </div>
                  </div>
                  {onCheckCommandApi && (
                    <button
                      onClick={onCheckCommandApi}
                      disabled={commandApiStatus === 'checking'}
                      className="flex-shrink-0 text-[10px] font-medium text-primary hover:opacity-90 disabled:opacity-50 flex items-center gap-0.5"
                    >
                      <RefreshCw className={`w-2.5 h-2.5 ${commandApiStatus === 'checking' ? 'animate-spin' : ''}`} />
                      Verify
                    </button>
                  )}
                </div>
              </div>
            )}
      </div>

      <div className={`border-t border-border flex-shrink-0 ${asSidebar ? 'px-2 py-1.5' : 'px-3 sm:px-6 py-3 sm:py-4'}`}>
        <button onClick={onClose} className={sidebar.doneButton}>
          Done
        </button>
      </div>
    </div>
  );

  if (asSidebar) return content;

  return (
    <>
      <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center" onClick={onClose}>
        <div onClick={(e) => e.stopPropagation()}>
          {content}
        </div>
      </div>
    </>
  );
}