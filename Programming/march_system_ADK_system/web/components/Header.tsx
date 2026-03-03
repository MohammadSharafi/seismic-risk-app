import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import { Shield, HelpCircle, Sun, Moon, Monitor } from 'lucide-react';
import { useTheme } from '../context/ThemeContext';

type CommandApiStatus = 'idle' | 'checking' | 'connected' | 'disconnected';

interface HeaderProps {
  commandApiEnabled?: boolean;
  commandApiStatus?: CommandApiStatus;
  patientName?: string;
  patientMrn?: string;
}

export function Header({
  commandApiEnabled = false,
  commandApiStatus = 'idle',
  patientName = '',
  patientMrn = '',
}: HeaderProps) {
  const showAdmin = true;
  const { theme, setTheme } = useTheme();
  const [themeMenuOpen, setThemeMenuOpen] = useState(false);

  return (
    <header className="h-16 border-b border-border bg-card px-4 sm:px-6 flex items-center justify-between gap-6 shadow-sm">
      {/* Logo & Branding */}
      <div className="flex-shrink-0 min-w-0 flex items-center gap-3">
        <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-gradient-to-br from-teal-600 to-teal-700 shadow-md">
          <span className="text-white font-bold text-sm">H</span>
        </div>
        <div className="flex flex-col gap-0">
          <div className="text-sm font-bold text-foreground truncate">Clinical Agent</div>
          <span className="text-[10px] text-muted-foreground tracking-wide uppercase font-medium">
            Patient Insights
          </span>
        </div>
      </div>

      {/* Patient Info - Only show if patient selected */}
      {patientName && (
        <div className="hidden md:flex items-center gap-3 px-4 py-2 rounded-lg bg-muted border border-border">
          <div className="h-8 w-8 rounded-full bg-gradient-to-br from-blue-500 to-blue-600 flex items-center justify-center text-white text-xs font-bold">
            {patientName.charAt(0).toUpperCase()}
          </div>
          <div className="flex flex-col gap-0">
            <span className="text-xs font-semibold text-foreground">{patientName}</span>
            <span className="text-[10px] text-muted-foreground">MRN: {patientMrn}</span>
          </div>
        </div>
      )}

      {/* Right Side Actions */}
      <div className="flex-shrink-0 flex items-center gap-2 sm:gap-3">
        {commandApiEnabled && (
          <div
            className={`flex items-center gap-1.5 px-2.5 py-1.5 rounded-lg border text-[10px] sm:text-xs font-medium transition-all ${
              commandApiStatus === 'connected'
                ? 'bg-green-50 dark:bg-green-900/20 border-green-300 dark:border-green-700 text-green-700 dark:text-green-300'
                : commandApiStatus === 'checking'
                  ? 'bg-amber-50 dark:bg-amber-900/20 border-amber-300 dark:border-amber-700 text-amber-700 dark:text-amber-300'
                  : 'bg-red-50 dark:bg-red-900/20 border-red-300 dark:border-red-700 text-red-700 dark:text-red-300'
            }`}
            title={
              commandApiStatus === 'connected'
                ? 'Command API connected and healthy'
                : commandApiStatus === 'checking'
                  ? 'Verifying Command API connection…'
                  : 'Command API unavailable'
            }
          >
            <span
              className={`inline-block w-2 h-2 rounded-full flex-shrink-0 ${
                commandApiStatus === 'connected'
                  ? 'bg-green-500'
                  : commandApiStatus === 'checking'
                    ? 'bg-amber-400 animate-pulse'
                    : 'bg-red-500'
              }`}
            />
            <span className="hidden sm:inline font-medium">
              {commandApiStatus === 'connected' ? 'API Ready' : commandApiStatus === 'checking' ? 'Checking…' : 'API Offline'}
            </span>
          </div>
        )}

        <Link
          to="/admin"
          className="flex items-center gap-1.5 px-3 py-2 rounded-lg border border-border bg-muted hover:bg-accent text-foreground text-xs font-semibold transition-all"
          title="Admin dashboard"
        >
          <Shield className="w-3.5 h-3.5" />
          <span className="hidden sm:inline">Admin</span>
        </Link>

        {/* Theme Switcher */}
        <div className="relative">
          <button
            onClick={() => setThemeMenuOpen(!themeMenuOpen)}
            className="flex items-center justify-center p-1.5 rounded-lg hover:bg-accent text-muted-foreground hover:text-foreground transition-all"
            title="Change theme"
          >
            {theme === 'system' ? (
              <Monitor className="w-4 h-4" />
            ) : (
              <>
                <Sun className="w-4 h-4 absolute dark:opacity-0 opacity-100 transition-opacity" />
                <Moon className="w-4 h-4 absolute opacity-0 dark:opacity-100 transition-opacity" />
              </>
            )}
          </button>
          
          {themeMenuOpen && (
            <>
              <div 
                className="fixed inset-0 z-40"
                onClick={() => setThemeMenuOpen(false)}
              />
              <div className="absolute right-0 mt-2 w-44 bg-card rounded-lg border border-border shadow-xl z-50 overflow-hidden">
                <button
                  onClick={() => {
                    setTheme('light');
                    setThemeMenuOpen(false);
                  }}
                  className={`w-full text-left px-4 py-3 text-sm flex items-center gap-3 transition-all first:rounded-t-lg ${
                    theme === 'light' 
                      ? 'bg-teal-50 dark:bg-teal-900/30 text-teal-700 dark:text-teal-300 font-semibold border-r-3 border-teal-500' 
                      : 'text-foreground hover:bg-accent'
                  }`}
                >
                  <Sun className="w-4 h-4" />
                  <span>Light</span>
                </button>
                <button
                  onClick={() => {
                    setTheme('dark');
                    setThemeMenuOpen(false);
                  }}
                  className={`w-full text-left px-4 py-3 text-sm flex items-center gap-3 transition-all ${
                    theme === 'dark' 
                      ? 'bg-teal-50 dark:bg-teal-900/30 text-teal-700 dark:text-teal-300 font-semibold border-r-3 border-teal-500' 
                      : 'text-foreground hover:bg-accent'
                  }`}
                >
                  <Moon className="w-4 h-4" />
                  <span>Dark</span>
                </button>
                <button
                  onClick={() => {
                    setTheme('system');
                    setThemeMenuOpen(false);
                  }}
                  className={`w-full text-left px-4 py-3 text-sm flex items-center gap-3 transition-all last:rounded-b-lg ${
                    theme === 'system' 
                      ? 'bg-teal-50 dark:bg-teal-900/30 text-teal-700 dark:text-teal-300 font-semibold border-r-3 border-teal-500' 
                      : 'text-foreground hover:bg-accent'
                  }`}
                >
                  <Monitor className="w-4 h-4" />
                  <span>System</span>
                </button>
              </div>
            </>
          )}
        </div>

        <button
          className="flex items-center justify-center p-1.5 rounded-lg hover:bg-accent text-muted-foreground hover:text-foreground transition-all"
          title="Help"
        >
          <HelpCircle className="w-4 h-4" />
        </button>
      </div>
    </header>
  );
}