import React, { useState, useEffect, useRef } from 'react';
import { 
  User, Activity, AlertTriangle, Bell, Microscope, 
  FileText, ClipboardList, Download, HelpCircle, 
  Settings, Trash2, MessageSquarePlus, Eye, EyeOff,
  Calendar, Layers, ChevronRight, Keyboard
} from 'lucide-react';
import { BACKEND_BASE_COMMANDS, UI_ONLY_BASE_COMMANDS } from '../data/commands';

export interface Command {
  name: string;
  description: string;
  example: string;
  parameters: Array<{ name: string; required: boolean }>;
  category: string;
  requiresEntitySelection?: {
    entityType: 'visit' | 'alert' | 'assessment' | 'export' | 'simulation' | 'redflag';
    pickerTitle: string;
  };
  requiresOptionSelection?: {
    optionType: 'window' | 'context' | 'mode';
    pickerTitle: string;
  };
  /** When set, option value is sent as param=value (e.g. range=last_30_days) */
  optionParamName?: string;
  requiresBuilder?: boolean; // For commands that open a builder UI
}

const ALL_PALETTE_COMMANDS: Command[] = [
  // Summary & Context (backend)
  { name: '/summary', description: 'Clinical summary for current patient', example: '/summary', parameters: [{ name: 'window', required: false }], category: 'Summary' },
  
  // Assessments
  { name: '/latest_assessment', description: 'Get latest assessment', example: '/latest_assessment', parameters: [], category: 'Assessments' },
  { 
    name: '/assessment_detail', 
    description: 'View assessment details (choose assessment)', 
    example: '/assessment_detail ASS-1024', 
    parameters: [{ name: 'ASSESSMENT_ID', required: true }], 
    category: 'Assessments',
    requiresEntitySelection: {
      entityType: 'assessment',
      pickerTitle: 'Select an Assessment'
    }
  },
  { name: '/assessment_trend', description: 'Show assessment trends (pick metric & range)', example: '/assessment_trend FSH range=last_30_days', parameters: [], category: 'Assessments', requiresBuilder: true },
  { name: '/redflags', description: 'Show red flags', example: '/redflags', parameters: [], category: 'Assessments' },
  { 
    name: '/ack_redflag', 
    description: 'Acknowledge red flag', 
    example: '/ack_redflag FLAG-101', 
    parameters: [{ name: 'FLAG_ID', required: true }], 
    category: 'Assessments',
    requiresEntitySelection: {
      entityType: 'redflag',
      pickerTitle: 'Select a Red Flag to Acknowledge'
    }
  },
  // Risk
  { name: '/risk_profile', description: 'Show risk profile', example: '/risk_profile', parameters: [], category: 'Risk' },
  { name: '/risk_drivers', description: 'Show risk drivers', example: '/risk_drivers', parameters: [], category: 'Risk' },
  { name: '/risk_mitigation', description: 'Suggest risk mitigation', example: '/risk_mitigation', parameters: [], category: 'Risk' },
  {
    name: '/risk_compare',
    description: 'Compare risk over time',
    example: '/risk_compare range=last_6_months',
    parameters: [{ name: 'range', required: false }],
    category: 'Risk',
    requiresOptionSelection: { optionType: 'window', pickerTitle: 'Select time range' },
    optionParamName: 'range',
  },
  
  // Alerts
  { name: '/alerts', description: 'List all alerts', example: '/alerts', parameters: [], category: 'Alerts' },
  { 
    name: '/alert_detail', 
    description: 'View alert details', 
    example: '/alert_detail ALT-5678', 
    parameters: [{ name: 'ALERT_ID', required: true }], 
    category: 'Alerts',
    requiresEntitySelection: {
      entityType: 'alert',
      pickerTitle: 'Select an Alert'
    }
  },
  { name: '/create_alert', description: 'Create new alert', example: '/create_alert', parameters: [], category: 'Alerts' },
  { 
    name: '/resolve_alert', 
    description: 'Resolve an alert', 
    example: '/resolve_alert ALT-5678', 
    parameters: [{ name: 'ALERT_ID', required: true }], 
    category: 'Alerts',
    requiresEntitySelection: {
      entityType: 'alert',
      pickerTitle: 'Select an Alert to Resolve'
    }
  },
  { 
    name: '/escalate', 
    description: 'Escalate an alert', 
    example: '/escalate ALT-5678', 
    parameters: [{ name: 'ALERT_ID', required: true }], 
    category: 'Alerts',
    requiresEntitySelection: {
      entityType: 'alert',
      pickerTitle: 'Select an Alert to Escalate'
    }
  },
  
  // Digital Twin
  { name: '/twin_snapshot', description: 'Get digital twin snapshot', example: '/twin_snapshot', parameters: [], category: 'Digital Twin' },
  { name: '/simulate', description: 'Run simulation', example: '/simulate', parameters: [], category: 'Digital Twin', requiresBuilder: true },
  { 
    name: '/simulation_result', 
    description: 'Get simulation results', 
    example: '/simulation_result SIM-9876', 
    parameters: [{ name: 'SIM_ID', required: true }], 
    category: 'Digital Twin',
    requiresEntitySelection: {
      entityType: 'simulation',
      pickerTitle: 'Select a Simulation'
    }
  },
  
  // Plans
  { name: '/draft_plan', description: 'Draft treatment plan', example: '/draft_plan', parameters: [], category: 'Plans' },
  { name: '/update_plan', description: 'Update treatment plan', example: '/update_plan', parameters: [], category: 'Plans' },
  { name: '/save_plan', description: 'Save treatment plan', example: '/save_plan', parameters: [], category: 'Plans' },
  { name: '/plan_diff', description: 'Show plan changes', example: '/plan_diff', parameters: [], category: 'Plans' },
  
  // Notes
  { name: '/draft_note', description: 'Draft clinical note', example: '/draft_note', parameters: [], category: 'Notes' },
  { name: '/revise_note', description: 'Revise clinical note (type instruction in modal)', example: '/revise_note "add medication section"', parameters: [], category: 'Notes', requiresBuilder: true },
  
  // Exports
  { name: '/export_pdf', description: 'Export to PDF (pick sections & range)', example: '/export_pdf sections=[summary,risk] range=last_7_days', parameters: [], category: 'Exports', requiresBuilder: true },
  { name: '/export_csv', description: 'Export to CSV (pick dataset & range)', example: '/export_csv dataset=assessments range=last_30_days', parameters: [], category: 'Exports', requiresBuilder: true },
  { name: '/list_exports', description: 'List all exports', example: '/list_exports', parameters: [], category: 'Exports' },
  { 
    name: '/download_export', 
    description: 'Download export file', 
    example: '/download_export EXP-1024', 
    parameters: [{ name: 'EXPORT_ID', required: true }], 
    category: 'Exports',
    requiresEntitySelection: {
      entityType: 'export',
      pickerTitle: 'Select an Export to Download'
    }
  },
  
  // Utility (UI-only, not sent to backend)
  { name: '/help', description: 'Show help information', example: '/help', parameters: [], category: 'Utility' },
  { name: '/shortcuts', description: 'Show keyboard shortcuts', example: '/shortcuts', parameters: [], category: 'Utility' },
  { name: '/clear', description: 'Clear current thread', example: '/clear', parameters: [], category: 'Utility' },
  { name: '/new_thread', description: 'Start new conversation thread', example: '/new_thread', parameters: [], category: 'Utility' },
];

// Only show commands that are supported by backend or handled in UI
function isPaletteCommand(cmd: Command): boolean {
  const base = cmd.name.toLowerCase();
  return BACKEND_BASE_COMMANDS.has(base) || UI_ONLY_BASE_COMMANDS.has(base);
}

const commands: Command[] = ALL_PALETTE_COMMANDS.filter(isPaletteCommand);

const categoryIcons: Record<string, React.ElementType> = {
  'Summary': FileText,
  'Assessments': Activity,
  'Risk': AlertTriangle,
  'Alerts': Bell,
  'Digital Twin': Microscope,
  'Plans': FileText,
  'Notes': ClipboardList,
  'Exports': Download,
  'Utility': HelpCircle,
};

interface CommandPaletteProps {
  filterText: string;
  onSelect: (command: Command) => void;
  onClose: () => void;
}

export function CommandPalette({ filterText, onSelect, onClose }: CommandPaletteProps) {
  const [selectedIndex, setSelectedIndex] = useState(0);
  const paletteRef = useRef<HTMLDivElement>(null);
  const selectedRef = useRef<HTMLDivElement>(null);

  // Filter commands
  const filteredCommands = commands.filter(cmd => {
    if (!filterText || filterText === '/') return true;
    const search = filterText.toLowerCase();
    return cmd.name.toLowerCase().includes(search) || 
           cmd.description.toLowerCase().includes(search);
  });

  // Group by category
  const groupedCommands = filteredCommands.reduce((acc, cmd) => {
    if (!acc[cmd.category]) acc[cmd.category] = [];
    acc[cmd.category].push(cmd);
    return acc;
  }, {} as Record<string, Command[]>);

  const categories = Object.keys(groupedCommands);
  const flatCommands = filteredCommands;

  // Keyboard navigation
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      // Only handle if CommandPalette is visible
      if (!paletteRef.current) return;
      
      // Check if user is typing in an input/textarea
      const activeElement = document.activeElement;
      if (activeElement && (activeElement.tagName === 'INPUT' || activeElement.tagName === 'TEXTAREA')) {
        // Allow arrow keys and enter only if it's not the main composer textarea
        if (activeElement.closest('.relative.max-w-4xl')) {
          // This is the composer textarea, let it handle its own events
          if (e.key === 'ArrowDown' || e.key === 'ArrowUp' || e.key === 'Enter') {
            return;
          }
        }
      }

      if (e.key === 'ArrowDown') {
        e.preventDefault();
        e.stopPropagation();
        setSelectedIndex(prev => (prev + 1) % flatCommands.length);
      } else if (e.key === 'ArrowUp') {
        e.preventDefault();
        e.stopPropagation();
        setSelectedIndex(prev => (prev - 1 + flatCommands.length) % flatCommands.length);
      } else if (e.key === 'Enter') {
        e.preventDefault();
        e.stopPropagation();
        if (flatCommands[selectedIndex]) {
          onSelect(flatCommands[selectedIndex]);
        }
      } else if (e.key === 'Escape') {
        e.preventDefault();
        e.stopPropagation();
        onClose();
      }
    };

    window.addEventListener('keydown', handleKeyDown, true);
    return () => window.removeEventListener('keydown', handleKeyDown, true);
  }, [selectedIndex, flatCommands, onSelect, onClose]);

  // Scroll selected item into view
  useEffect(() => {
    if (selectedRef.current) {
      selectedRef.current.scrollIntoView({ block: 'nearest', behavior: 'smooth' });
    }
  }, [selectedIndex]);

  // Reset selection when filter changes
  useEffect(() => {
    setSelectedIndex(0);
  }, [filterText]);

  if (flatCommands.length === 0) {
    return (
      <div className="absolute bottom-full left-0 right-0 mb-2 mx-2 sm:mx-4">
        <div className="max-w-4xl mx-auto bg-white rounded-xl sm:rounded-2xl shadow-xl border border-gray-200 p-4 sm:p-8 text-center">
          <div className="text-gray-400 mb-2">
            <HelpCircle className="w-6 h-6 sm:w-8 sm:h-8 mx-auto" />
          </div>
          <p className="text-[11px] sm:text-base text-gray-600">No commands match "{filterText}"</p>
          <p className="text-[10px] sm:text-sm text-gray-400 mt-1">Try a different search term</p>
        </div>
      </div>
    );
  }

  let currentIndex = 0;

  return (
    <div className="absolute bottom-full left-0 right-0 mb-2 mx-2 sm:mx-4">
      <div 
        ref={paletteRef}
        className="max-w-4xl mx-auto bg-white rounded-xl sm:rounded-2xl shadow-2xl border border-gray-200 overflow-hidden"
        style={{ maxHeight: '60vh' }}
      >
        <div className="overflow-y-auto" style={{ maxHeight: '60vh' }}>
          {/* Header */}
          <div className="sticky top-0 bg-gradient-to-b from-gray-50 to-white border-b border-gray-200 px-2 sm:px-4 py-2 sm:py-3 z-10">
            <div className="flex items-center justify-between gap-2 flex-wrap">
              <div className="flex items-center gap-1.5 sm:gap-2">
                <Keyboard className="w-3 h-3 sm:w-4 sm:h-4 text-gray-400" />
                <span className="text-[10px] sm:text-sm font-medium text-gray-700">Commands</span>
                <span className="text-[9px] sm:text-xs text-gray-400">
                  {flatCommands.length} {flatCommands.length === 1 ? 'command' : 'commands'}
                </span>
              </div>
              <div className="flex items-center gap-1.5 sm:gap-3 text-[9px] sm:text-xs text-gray-400 flex-wrap">
                <span className="flex items-center gap-0.5 sm:gap-1">
                  <kbd className="px-1 sm:px-1.5 py-0.5 bg-gray-100 rounded text-[8px] sm:text-xs font-mono">↑↓</kbd> 
                  <span className="hidden sm:inline">Navigate</span>
                </span>
                <span className="flex items-center gap-0.5 sm:gap-1">
                  <kbd className="px-1 sm:px-1.5 py-0.5 bg-gray-100 rounded text-[8px] sm:text-xs font-mono">↵</kbd> 
                  <span className="hidden sm:inline">Select</span>
                </span>
                <span className="flex items-center gap-0.5 sm:gap-1">
                  <kbd className="px-1 sm:px-1.5 py-0.5 bg-gray-100 rounded text-[8px] sm:text-xs font-mono">Esc</kbd> 
                  <span className="hidden sm:inline">Close</span>
                </span>
              </div>
            </div>
          </div>

          {/* Command groups */}
          <div className="px-1 sm:px-2 py-1 sm:py-2">
            {categories.map(category => {
              const categoryCommands = groupedCommands[category];
              const CategoryIcon = categoryIcons[category] || HelpCircle;
              
              return (
                <div key={category} className="mb-2 sm:mb-4 last:mb-0">
                  {/* Category header */}
                  <div className="px-2 sm:px-3 py-1.5 sm:py-2 flex items-center gap-1.5 sm:gap-2 sticky top-[45px] sm:top-[57px] bg-white/95 backdrop-blur-sm z-[5]">
                    <CategoryIcon className="w-3 h-3 sm:w-3.5 sm:h-3.5 text-gray-400" />
                    <span className="text-[9px] sm:text-xs font-semibold text-gray-500 uppercase tracking-wide">
                      {category}
                    </span>
                    <span className="text-[9px] sm:text-xs text-gray-400">
                      ({categoryCommands.length})
                    </span>
                  </div>

                  {/* Commands in category */}
                  <div className="space-y-0.5">
                    {categoryCommands.map(cmd => {
                      const cmdIndex = currentIndex++;
                      const isSelected = cmdIndex === selectedIndex;
                      const highlightedName = highlightMatch(cmd.name, filterText);

                      return (
                        <div
                          key={cmd.name}
                          ref={isSelected ? selectedRef : null}
                          onClick={() => onSelect(cmd)}
                          className={`px-2 sm:px-3 py-2 sm:py-2.5 rounded-md sm:rounded-lg cursor-pointer transition-all duration-150 ${
                            isSelected 
                              ? 'bg-teal-50 border border-teal-200 shadow-sm' 
                              : 'hover:bg-gray-50 border border-transparent'
                          }`}
                        >
                          <div className="flex items-start justify-between gap-2 sm:gap-3">
                            <div className="flex-1 min-w-0">
                              {/* Command name */}
                              <div className="flex items-center gap-1.5 sm:gap-2 mb-0.5 sm:mb-1 flex-wrap">
                                <code 
                                  className={`text-[10px] sm:text-sm font-mono font-medium ${
                                    isSelected ? 'text-teal-700' : 'text-gray-900'
                                  }`}
                                  dangerouslySetInnerHTML={{ __html: highlightedName }}
                                />
                                {cmd.parameters.filter(p => p.required).length > 0 && (
                                  <div className="flex items-center gap-0.5 sm:gap-1 flex-wrap">
                                    {cmd.parameters.filter(p => p.required).map(param => (
                                      <span 
                                        key={param.name}
                                        className="text-[8px] sm:text-xs px-1 sm:px-1.5 py-0.5 bg-orange-50 text-orange-600 rounded border border-orange-200 font-mono"
                                      >
                                        {param.name}
                                      </span>
                                    ))}
                                  </div>
                                )}
                              </div>

                              {/* Description */}
                              <p className="text-[10px] sm:text-sm text-gray-600 mb-0.5 sm:mb-1">
                                {cmd.description}
                              </p>

                              {/* Example */}
                              <div className="flex items-center gap-1 sm:gap-1.5 flex-wrap">
                                <span className="text-[9px] sm:text-xs text-gray-400">Example:</span>
                                <code className="text-[9px] sm:text-xs font-mono text-gray-500 bg-gray-50 px-1 sm:px-1.5 py-0.5 rounded">
                                  {cmd.example}
                                </code>
                              </div>
                            </div>

                            {/* Category badge */}
                            {isSelected && (
                              <ChevronRight className="w-3.5 h-3.5 sm:w-4 sm:h-4 text-teal-500 flex-shrink-0 mt-0.5" />
                            )}
                          </div>
                        </div>
                      );
                    })}
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      </div>
    </div>
  );
}

function highlightMatch(text: string, search: string): string {
  if (!search || search === '/') return text;
  
  const index = text.toLowerCase().indexOf(search.toLowerCase());
  if (index === -1) return text;
  
  const before = text.slice(0, index);
  const match = text.slice(index, index + search.length);
  const after = text.slice(index + search.length);
  
  return `${before}<mark class="bg-yellow-200 text-gray-900 px-0.5 rounded">${match}</mark>${after}`;
}