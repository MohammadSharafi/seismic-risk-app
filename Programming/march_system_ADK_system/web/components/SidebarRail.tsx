import React, { useState, useRef } from 'react';
import { MessageSquare, Wrench, Settings, User, PanelLeft, PanelLeftClose } from 'lucide-react';

interface SidebarRailProps {
  sidebarOpen: boolean;
  onToggleSidebar: () => void;
  onThreadsClick: () => void;
  onToolsClick: () => void;
  onSettingsClick: () => void;
  activePanel: 'threads' | 'tools' | 'settings' | null;
}

const ICON_SIZE = 'w-[18px] h-[18px]';
const NAV_ITEMS = [
  { id: 'threads' as const, icon: MessageSquare, label: 'Chats' },
  { id: 'tools' as const, icon: Wrench, label: 'Tools' },
  { id: 'settings' as const, icon: Settings, label: 'Settings' },
] as const;

export function SidebarRail({
  sidebarOpen,
  onToggleSidebar,
  onThreadsClick,
  onToolsClick,
  onSettingsClick,
  activePanel,
}: SidebarRailProps) {
  const [tooltip, setTooltip] = useState<string | null>(null);
  const [tooltipTarget, setTooltipTarget] = useState<string | null>(null);
  const timeoutRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  const showTooltip = (label: string, target: string) => {
    if (timeoutRef.current) clearTimeout(timeoutRef.current);
    timeoutRef.current = setTimeout(() => {
      setTooltip(label);
      setTooltipTarget(target);
    }, 400);
  };

  const hideTooltip = () => {
    if (timeoutRef.current) clearTimeout(timeoutRef.current);
    timeoutRef.current = null;
    setTooltip(null);
    setTooltipTarget(null);
  };

  const handlers = {
    threads: onThreadsClick,
    tools: onToolsClick,
    settings: onSettingsClick,
  };

  return (
    <aside
      className="flex-shrink-0 w-14 flex flex-col items-stretch py-3 bg-sidebar border-r border-sidebar-border"
      aria-label="App navigation"
    >
      <div className="flex flex-col items-center gap-3 px-2 mb-4 flex-shrink-0">
        <div
          className="w-8 h-8 rounded-lg bg-primary flex items-center justify-center shadow-md"
          aria-hidden
        >
          <span className="text-xs font-bold text-primary-foreground tracking-tight">MH</span>
        </div>
        <div className="relative">
          <button
            type="button"
            onClick={onToggleSidebar}
            onMouseEnter={() => showTooltip(sidebarOpen ? 'Close sidebar' : 'Open sidebar', 'toggle')}
            onMouseLeave={hideTooltip}
            className={`
              flex items-center justify-center w-9 h-9 rounded-lg
              transition-all duration-200
              focus:outline-none focus-visible:ring-2 focus-visible:ring-primary focus-visible:ring-offset-2 focus-visible:ring-offset-background
              ${sidebarOpen ? 'text-sidebar-foreground bg-sidebar-accent hover:opacity-90' : 'text-muted-foreground hover:text-sidebar-foreground hover:bg-sidebar-accent'}
            `}
            aria-label={sidebarOpen ? 'Close sidebar' : 'Open sidebar'}
            aria-expanded={sidebarOpen}
          >
            {sidebarOpen ? (
              <PanelLeftClose className={ICON_SIZE} strokeWidth={2} strokeLinecap="round" strokeLinejoin="round" />
            ) : (
              <PanelLeft className={ICON_SIZE} strokeWidth={2} strokeLinecap="round" strokeLinejoin="round" />
            )}
          </button>
          {tooltip && tooltipTarget === 'toggle' && (
            <div
              className="absolute left-full top-1/2 -translate-y-1/2 ml-2 px-2 py-1 rounded-md bg-card text-foreground text-xs font-medium whitespace-nowrap z-[100] pointer-events-none border border-border shadow-lg"
              role="tooltip"
            >
              {tooltip}
            </div>
          )}
        </div>
      </div>

      {/* Nav */}
      <nav className="flex-1 flex flex-col items-center gap-2 min-h-0 px-2" aria-label="Primary">
        {NAV_ITEMS.map(({ id, icon: Icon, label }) => {
          const isActive = activePanel === id;
          return (
            <div key={id} className="relative group">
              <button
                type="button"
                onClick={handlers[id]}
                onMouseEnter={() => showTooltip(label, id)}
                onMouseLeave={hideTooltip}
                className={`
                  relative flex items-center justify-center w-9 h-9 rounded-lg
                  transition-all duration-200
                  focus:outline-none focus-visible:ring-2 focus-visible:ring-primary focus-visible:ring-offset-2 focus-visible:ring-offset-background
                  ${isActive ? 'text-primary-foreground bg-primary shadow-md' : 'text-muted-foreground hover:text-sidebar-foreground hover:bg-sidebar-accent'}
                `}
                aria-label={label}
                aria-current={isActive ? 'true' : undefined}
              >
                {isActive && (
                  <span className="absolute left-0 top-1/2 -translate-y-1/2 w-1 h-4 rounded-r-full bg-primary-foreground/80" aria-hidden />
                )}
                <Icon className={ICON_SIZE} strokeWidth={2} strokeLinecap="round" strokeLinejoin="round" />
              </button>
              {tooltip && tooltipTarget === id && (
                <div
                  className="absolute left-full top-1/2 -translate-y-1/2 ml-3 px-2.5 py-1.5 rounded-lg bg-card text-foreground text-xs font-medium whitespace-nowrap z-[100] pointer-events-none shadow-xl border border-border"
                  role="tooltip"
                >
                  {tooltip}
                </div>
              )}
            </div>
          );
        })}
      </nav>

      {/* User */}
      <div className="flex-shrink-0 pt-3 mt-auto border-t border-sidebar-border px-2">
        <button
          className="w-9 h-9 rounded-lg bg-sidebar-accent hover:opacity-90 flex items-center justify-center border border-sidebar-border transition-all"
          title="Account settings"
          aria-label="Account settings"
        >
          <User className="w-4 h-4 text-sidebar-foreground" strokeWidth={2} strokeLinecap="round" strokeLinejoin="round" />
        </button>
      </div>
    </aside>
  );
}

