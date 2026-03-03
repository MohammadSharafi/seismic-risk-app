import React, { useState, useEffect, useRef } from 'react';
import {
  Calendar, Search, ChevronRight, FileText,
  CheckCircle, AlertCircle, Beaker, Clock, Bell,
  Activity, Download, Microscope, AlertTriangle
} from 'lucide-react';

export interface EntityItem {
  id: string;
  date: string;
  time?: string;
  type: string;
  title?: string;
  summary: string;
  chips: string[];
  severity?: 'low' | 'medium' | 'high' | 'critical';
}

type EntityType = 'visit' | 'alert' | 'assessment' | 'export' | 'simulation' | 'redflag';

function emptyMessageForType(entityType: EntityType, hasFilters: boolean): string {
  if (hasFilters) return 'Try adjusting your search or filter';
  const messages: Record<EntityType, string> = {
    visit: 'No visits found for this patient.',
    alert: 'No alerts found for this patient.',
    assessment: 'No assessments found for this patient.',
    export: 'No exports found for this patient.',
    simulation: 'No simulations found for this patient.',
    redflag: 'No red flags found for this patient.',
  };
  return messages[entityType] ?? 'No items found for this patient.';
}

interface EntityPickerPaletteProps {
  entityType: EntityType;
  title: string;
  items: EntityItem[];
  onSelect: (item: EntityItem) => void;
  onClose: () => void;
}

export function EntityPickerPalette({
  entityType,
  title,
  items,
  onSelect,
  onClose
}: EntityPickerPaletteProps) {
  const [searchQuery, setSearchQuery] = useState('');
  const [timeFilter, setTimeFilter] = useState<'7days' | '30days' | 'all'>('30days');
  const [selectedIndex, setSelectedIndex] = useState(0);
  const pickerRef = useRef<HTMLDivElement>(null);
  const selectedRef = useRef<HTMLDivElement>(null);

  // Filter items based on search and time filter
  const filteredItems = items.filter(item => {
    // Time filter
    const itemDate = new Date(item.date);
    const now = new Date('Jan 23, 2026'); // Using current date from context
    const daysDiff = Math.floor((now.getTime() - itemDate.getTime()) / (1000 * 60 * 60 * 24));
    
    if (timeFilter === '7days' && daysDiff > 7) return false;
    if (timeFilter === '30days' && daysDiff > 30) return false;

    // Search filter
    if (!searchQuery) return true;
    const search = searchQuery.toLowerCase();
    return (
      item.id.toLowerCase().includes(search) ||
      item.date.toLowerCase().includes(search) ||
      item.type.toLowerCase().includes(search) ||
      (item.title && item.title.toLowerCase().includes(search)) ||
      item.summary.toLowerCase().includes(search)
    );
  });

  // Keyboard navigation
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      // Only handle if EntityPicker is visible
      if (!pickerRef.current) return;
      
      // Check if user is typing in the search input
      const activeElement = document.activeElement;
      if (activeElement && activeElement.tagName === 'INPUT' && activeElement.closest('.max-w-4xl')) {
        // Allow arrow keys to work in search, but handle Enter/Escape
        if (e.key === 'ArrowDown' || e.key === 'ArrowUp') {
          // Move focus to first item when arrow keys pressed in search
          if (filteredItems.length > 0) {
            e.preventDefault();
            e.stopPropagation();
            setSelectedIndex(0);
            // Focus will move to the selected item
          }
          return;
        }
      }

      if (e.key === 'ArrowDown') {
        e.preventDefault();
        e.stopPropagation();
        setSelectedIndex(prev => Math.min(prev + 1, filteredItems.length - 1));
      } else if (e.key === 'ArrowUp') {
        e.preventDefault();
        e.stopPropagation();
        setSelectedIndex(prev => Math.max(prev - 1, 0));
      } else if (e.key === 'Enter') {
        e.preventDefault();
        e.stopPropagation();
        if (filteredItems[selectedIndex]) {
          onSelect(filteredItems[selectedIndex]);
        }
      } else if (e.key === 'Escape') {
        e.preventDefault();
        e.stopPropagation();
        onClose();
      }
    };

    window.addEventListener('keydown', handleKeyDown, true);
    return () => window.removeEventListener('keydown', handleKeyDown, true);
  }, [selectedIndex, filteredItems, onSelect, onClose]);

  // Scroll selected item into view
  useEffect(() => {
    if (selectedRef.current) {
      selectedRef.current.scrollIntoView({ block: 'nearest', behavior: 'smooth' });
    }
  }, [selectedIndex]);

  // Reset selection when filter changes
  useEffect(() => {
    setSelectedIndex(0);
  }, [searchQuery, timeFilter]);

  const getEntityIcon = () => {
    switch (entityType) {
      case 'visit': return Calendar;
      case 'alert': return Bell;
      case 'assessment': return Activity;
      case 'export': return Download;
      case 'simulation': return Microscope;
      case 'redflag': return AlertTriangle;
      default: return FileText;
    }
  };

  const getTypeIcon = (type: string) => {
    if (entityType === 'visit') {
      if (type.includes('monitoring')) return <Beaker className="w-3 h-3 sm:w-4 sm:h-4" />;
      if (type.includes('Consult')) return <FileText className="w-3 h-3 sm:w-4 sm:h-4" />;
      if (type.includes('Procedure') || type.includes('Retrieval')) return <AlertCircle className="w-3 h-3 sm:w-4 sm:h-4" />;
      return <Calendar className="w-3 h-3 sm:w-4 sm:h-4" />;
    }
    if (entityType === 'alert') return <Bell className="w-3 h-3 sm:w-4 sm:h-4" />;
    if (entityType === 'assessment') return <Activity className="w-3 h-3 sm:w-4 sm:h-4" />;
    if (entityType === 'export') return <Download className="w-3 h-3 sm:w-4 sm:h-4" />;
    if (entityType === 'simulation') return <Microscope className="w-3 h-3 sm:w-4 sm:h-4" />;
    if (entityType === 'redflag') return <AlertTriangle className="w-3 h-3 sm:w-4 sm:h-4" />;
    return <FileText className="w-3 h-3 sm:w-4 sm:h-4" />;
  };

  const getChipColor = (chip: string) => {
    if (chip === 'High priority' || chip === 'Critical') return 'bg-red-50 text-red-700 border-red-200';
    if (chip === 'Completed' || chip === 'Resolved') return 'bg-green-50 text-green-700 border-green-200';
    if (chip === 'Has labs' || chip === 'Ready') return 'bg-teal-50 text-teal-700 border-teal-200';
    if (chip === 'Has note' || chip === 'Pending') return 'bg-purple-50 text-purple-700 border-purple-200';
    if (chip === 'Acknowledged') return 'bg-amber-50 text-amber-700 border-amber-200';
    return 'bg-gray-50 text-gray-700 border-gray-200';
  };

  const getSeverityColor = (severity?: 'low' | 'medium' | 'high' | 'critical') => {
    if (!severity) return '';
    switch (severity) {
      case 'critical': return 'border-l-4 border-red-500';
      case 'high': return 'border-l-4 border-orange-500';
      case 'medium': return 'border-l-4 border-amber-500';
      case 'low': return 'border-l-4 border-teal-500';
      default: return '';
    }
  };

  const EntityIcon = getEntityIcon();

  return (
    <div className="absolute bottom-full left-0 right-0 mb-2 mx-2 sm:mx-4">
      <div 
        ref={pickerRef}
        className="max-w-4xl mx-auto bg-white rounded-xl sm:rounded-2xl shadow-2xl border border-gray-200 overflow-hidden"
      >
        {/* Header */}
        <div className="bg-gradient-to-b from-gray-50 to-white border-b border-gray-200 px-2 sm:px-4 py-2 sm:py-3">
          <div className="flex items-center justify-between mb-2 sm:mb-3 gap-2 flex-wrap">
            <div className="flex items-center gap-1.5 sm:gap-2">
              <EntityIcon className="w-3 h-3 sm:w-4 sm:h-4 text-gray-400" />
              <span className="text-[10px] sm:text-sm font-medium text-gray-700">{title}</span>
              <span className="text-[9px] sm:text-xs text-gray-400">
                {filteredItems.length} {filteredItems.length === 1 ? 'item' : 'items'}
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

          {/* Search and filter */}
          <div className="flex items-center gap-1.5 sm:gap-2 flex-wrap">
            <div className="flex-1 relative min-w-0">
              <Search className="absolute left-2 sm:left-3 top-1/2 -translate-y-1/2 w-3.5 h-3.5 sm:w-4 sm:h-4 text-gray-400" />
              <input
                type="text"
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                placeholder="Search by ID, date, or keyword..."
                className="w-full pl-8 sm:pl-9 pr-2 sm:pr-3 py-1.5 sm:py-2 bg-white border border-gray-300 rounded-md sm:rounded-lg text-[11px] sm:text-sm focus:outline-none focus:ring-2 focus:ring-teal-500 focus:border-transparent"
              />
            </div>
            
            <div className="flex items-center gap-1">
              <button
                onClick={() => setTimeFilter('7days')}
                className={`px-2 sm:px-3 py-1.5 sm:py-2 text-[9px] sm:text-xs font-medium rounded-md sm:rounded-lg transition-all ${
                  timeFilter === '7days'
                    ? 'bg-teal-100 text-teal-700 border border-teal-200'
                    : 'bg-gray-50 text-gray-600 border border-gray-200 hover:bg-gray-100'
                }`}
              >
                Last 7 days
              </button>
              <button
                onClick={() => setTimeFilter('30days')}
                className={`px-2 sm:px-3 py-1.5 sm:py-2 text-[9px] sm:text-xs font-medium rounded-md sm:rounded-lg transition-all ${
                  timeFilter === '30days'
                    ? 'bg-teal-100 text-teal-700 border border-teal-200'
                    : 'bg-gray-50 text-gray-600 border border-gray-200 hover:bg-gray-100'
                }`}
              >
                Last 30 days
              </button>
              <button
                onClick={() => setTimeFilter('all')}
                className={`px-2 sm:px-3 py-1.5 sm:py-2 text-[9px] sm:text-xs font-medium rounded-md sm:rounded-lg transition-all ${
                  timeFilter === 'all'
                    ? 'bg-teal-100 text-teal-700 border border-teal-200'
                    : 'bg-gray-50 text-gray-600 border border-gray-200 hover:bg-gray-100'
                }`}
              >
                All
              </button>
            </div>
          </div>
        </div>

        {/* Item list */}
        <div className="overflow-y-auto" style={{ maxHeight: '50vh' }}>
          {filteredItems.length === 0 ? (
            <div className="p-4 sm:p-8 text-center">
              <div className="text-gray-400 mb-2">
                <EntityIcon className="w-6 h-6 sm:w-8 sm:h-8 mx-auto" />
              </div>
              <p className="text-[11px] sm:text-base text-gray-600">
                {emptyMessageForType(entityType, !!(searchQuery.trim() || (timeFilter !== 'all' && items.length > 0)))}
              </p>
              {(searchQuery.trim() || timeFilter !== 'all') && items.length > 0 && (
                <p className="text-[10px] sm:text-sm text-gray-400 mt-1">Try adjusting your search or filter</p>
              )}
            </div>
          ) : (
            <div className="px-1 sm:px-2 py-1 sm:py-2 space-y-0.5 sm:space-y-1">
              {filteredItems.map((item, index) => {
                const isSelected = index === selectedIndex;
                
                return (
                  <div
                    key={item.id}
                    ref={isSelected ? selectedRef : null}
                    onClick={() => onSelect(item)}
                    className={`px-2 sm:px-3 py-2 sm:py-3 rounded-md sm:rounded-lg cursor-pointer transition-all duration-150 ${
                      isSelected
                        ? 'bg-teal-50 border border-teal-200 shadow-sm'
                        : 'hover:bg-gray-50 border border-transparent'
                    } ${getSeverityColor(item.severity)}`}
                  >
                    <div className="flex items-start gap-2 sm:gap-3">
                      {/* Icon */}
                      <div className={`mt-0.5 flex-shrink-0 ${isSelected ? 'text-teal-600' : 'text-gray-400'}`}>
                        {getTypeIcon(item.type)}
                      </div>

                      {/* Content */}
                      <div className="flex-1 min-w-0">
                        {/* ID and date/time */}
                        <div className="flex items-center gap-1.5 sm:gap-2 mb-0.5 sm:mb-1 flex-wrap">
                          <code className={`text-[10px] sm:text-sm font-mono font-medium ${
                            isSelected ? 'text-teal-700' : 'text-gray-900'
                          }`}>
                            {item.id}
                          </code>
                          <span className="text-[9px] sm:text-xs text-gray-500 hidden sm:inline">—</span>
                          <div className="flex items-center gap-1 sm:gap-1.5 text-[9px] sm:text-xs text-gray-600">
                            <Clock className="w-2.5 h-2.5 sm:w-3 sm:h-3" />
                            <span>{item.date}{item.time ? ` — ${item.time}` : ''}</span>
                          </div>
                          <span className="text-[9px] sm:text-xs px-1.5 sm:px-2 py-0.5 bg-gray-100 text-gray-700 rounded-full font-medium">
                            {item.type}
                          </span>
                        </div>

                        {/* Title (if exists) */}
                        {item.title && (
                          <p className="text-[10px] sm:text-sm font-medium text-gray-900 mb-0.5 sm:mb-1">
                            {item.title}
                          </p>
                        )}

                        {/* Summary */}
                        <p className="text-[10px] sm:text-sm text-gray-700 mb-1.5 sm:mb-2 line-clamp-2">
                          {item.summary}
                        </p>

                        {/* Chips */}
                        {item.chips.length > 0 && (
                          <div className="flex items-center gap-1 sm:gap-1.5 flex-wrap">
                            {item.chips.map((chip) => (
                              <span
                                key={chip}
                                className={`text-[9px] sm:text-xs px-1.5 sm:px-2 py-0.5 rounded border font-medium ${getChipColor(chip)}`}
                              >
                                {chip}
                              </span>
                            ))}
                          </div>
                        )}
                      </div>

                      {/* Arrow indicator */}
                      {isSelected && (
                        <ChevronRight className="w-4 h-4 sm:w-5 sm:h-5 text-teal-500 flex-shrink-0 mt-1 sm:mt-2" />
                      )}
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
