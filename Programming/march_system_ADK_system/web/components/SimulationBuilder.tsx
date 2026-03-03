import React, { useState, useEffect } from 'react';
import { X, Plus, Search, Pill, Stethoscope, FileText, FlaskConical, Calendar, Heart } from 'lucide-react';

interface SimulationBuilderProps {
  onGenerate: (command: string) => void;
  onClose: () => void;
}

type ChangeType = 'medication' | 'procedure' | 'prescription' | 'labs' | 'followup' | 'lifestyle';

interface ChangeItem {
  id: string;
  type: ChangeType;
  // Medication fields
  drugName?: string;
  action?: 'add' | 'modify' | 'stop';
  dose?: string;
  frequency?: string;
  route?: string;
  duration?: string;
  // Procedure fields
  procedureType?: string;
  timing?: string;
  // Prescription/Protocol fields
  protocolName?: string;
  parameters?: string;
  // Labs fields
  tests?: string[];
  labTiming?: string;
  // Follow-up fields
  followupIn?: string;
  // Shared
  notes?: string;
}

const guidanceTemplates = [
  { label: 'Add medication…', text: 'Add medication: ' },
  { label: 'Change dose…', text: 'Change dose: ' },
  { label: 'Stop medication…', text: 'Stop medication: ' },
  { label: 'Add procedure…', text: 'Add procedure: ' },
  { label: 'Add prescription…', text: 'Add prescription: ' },
  { label: 'Order labs…', text: 'Order labs: ' },
  { label: 'Change follow-up…', text: 'Change follow-up: next visit in ' }
];

const frequencyOptions = ['Daily', 'BID (twice daily)', 'TID (three times daily)', 'QID (four times daily)', 'Every other day', 'Weekly', 'As needed'];
const routeOptions = ['Oral', 'Subcutaneous', 'Intramuscular', 'Intravenous', 'Topical', 'Vaginal'];
const timingOptions = ['Today', 'Next visit', 'In 3 days', 'In 1 week', 'In 2 weeks', 'Custom date'];
const followupOptions = ['24 hours', '48 hours', '3 days', '1 week', '2 weeks', 'Custom'];
const commonTests = ['E2 (Estradiol)', 'P4 (Progesterone)', 'LH', 'FSH', 'HCG', 'AMH', 'TSH', 'Prolactin'];

const changeTypeConfig = {
  medication: { label: 'Medication change', icon: Pill, color: 'blue' },
  procedure: { label: 'Procedure', icon: Stethoscope, color: 'purple' },
  prescription: { label: 'Prescription / Protocol', icon: FileText, color: 'green' },
  labs: { label: 'Labs / Orders', icon: FlaskConical, color: 'orange' },
  followup: { label: 'Follow-up / Scheduling', icon: Calendar, color: 'pink' },
  lifestyle: { label: 'Lifestyle / Support', icon: Heart, color: 'teal' }
};

export function SimulationBuilder({ onGenerate, onClose }: SimulationBuilderProps) {
  const [freeTextDescription, setFreeTextDescription] = useState('');
  const [changeItems, setChangeItems] = useState<ChangeItem[]>([]);
  const [showTypeSelector, setShowTypeSelector] = useState(false);
  const [editingItemId, setEditingItemId] = useState<string | null>(null);
  const [timeHorizon, setTimeHorizon] = useState('14d');

  const canGenerate = freeTextDescription.trim() || changeItems.length > 0;

  const handleAddChange = (type: ChangeType) => {
    const newItem: ChangeItem = {
      id: `change-${Date.now()}`,
      type
    };
    
    // Set defaults based on type
    if (type === 'medication') {
      newItem.action = 'add';
      newItem.frequency = 'Daily';
      newItem.route = 'Oral';
    } else if (type === 'procedure') {
      newItem.timing = 'Next visit';
    } else if (type === 'labs') {
      newItem.tests = [];
      newItem.labTiming = 'Next visit';
    } else if (type === 'followup') {
      newItem.followupIn = '1 week';
    }
    
    setChangeItems([...changeItems, newItem]);
    setEditingItemId(newItem.id);
    setShowTypeSelector(false);
  };

  const removeChangeItem = (id: string) => {
    setChangeItems(changeItems.filter(item => item.id !== id));
    if (editingItemId === id) setEditingItemId(null);
  };

  const updateChangeItem = (id: string, updates: Partial<ChangeItem>) => {
    setChangeItems(changeItems.map(item => 
      item.id === id ? { ...item, ...updates } : item
    ));
  };

  const toggleTestSelection = (itemId: string, test: string) => {
    const item = changeItems.find(i => i.id === itemId);
    if (!item || !item.tests) return;
    
    const tests = item.tests.includes(test)
      ? item.tests.filter(t => t !== test)
      : [...item.tests, test];
    
    updateChangeItem(itemId, { tests });
  };

  const generateCommand = () => {
    const parts: string[] = [];
    
    // Add free text if present
    if (freeTextDescription.trim()) {
      parts.push(`description="${freeTextDescription}"`);
    }
    
    // Add structured changes
    if (changeItems.length > 0) {
      const changesStr = changeItems.map(item => {
        const fields: string[] = [`type=${item.type}`];
        
        if (item.type === 'medication') {
          if (item.drugName) fields.push(`drug="${item.drugName}"`);
          if (item.action) fields.push(`action=${item.action}`);
          if (item.dose) fields.push(`dose="${item.dose}"`);
          if (item.frequency) fields.push(`frequency="${item.frequency}"`);
          if (item.route) fields.push(`route="${item.route}"`);
          if (item.duration) fields.push(`duration="${item.duration}"`);
        } else if (item.type === 'procedure') {
          if (item.procedureType) fields.push(`procedure="${item.procedureType}"`);
          if (item.timing) fields.push(`timing="${item.timing}"`);
        } else if (item.type === 'prescription') {
          if (item.protocolName) fields.push(`name="${item.protocolName}"`);
          if (item.parameters) fields.push(`params="${item.parameters}"`);
        } else if (item.type === 'labs') {
          if (item.tests && item.tests.length > 0) fields.push(`tests=[${item.tests.join(',')}]`);
          if (item.labTiming) fields.push(`timing="${item.labTiming}"`);
        } else if (item.type === 'followup') {
          if (item.followupIn) fields.push(`followup="${item.followupIn}"`);
        }
        
        if (item.notes) fields.push(`notes="${item.notes}"`);
        
        return `{${fields.join(',')}}`;
      }).join(',');
      
      parts.push(`changes=[${changesStr}]`);
    }
    
    parts.push(`horizon=${timeHorizon}`);
    parts.push(`compare=current_plan`);
    
    return `/simulate ${parts.join(' ')}`;
  };

  const handleGenerate = () => {
    if (!canGenerate) return;
    const command = generateCommand();
    onGenerate(command);
  };

  // Global keyboard handler for Escape and Enter
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      // Always handle Escape to close
      if (e.key === 'Escape' || e.key === 'Esc') {
        e.preventDefault();
        e.stopPropagation();
        onClose();
        return;
      }

      // Handle Enter/Return key to generate
      const isEnter = e.key === 'Enter' || e.keyCode === 13;
      
      if (isEnter) {
        // Check if user is typing in an input/textarea
        const activeElement = document.activeElement;
        const isTyping = activeElement && (
          activeElement.tagName === 'INPUT' || 
          activeElement.tagName === 'TEXTAREA'
        );
        
        // If typing in textarea, allow Shift+Enter for new line, but handle plain Enter
        if (isTyping && activeElement.tagName === 'TEXTAREA' && e.shiftKey) {
          // Allow Shift+Enter for new line in textarea
          return;
        }
        
        // Handle Enter to generate (when not typing, or when typing in input/textarea without Shift)
        // Always prevent default and stop propagation for Enter
        e.preventDefault();
        e.stopPropagation();
        
        if (canGenerate) {
          handleGenerate();
        }
        return;
      }
    };

    // Use capture phase to ensure we catch the event early, before other handlers
    // This ensures SimulationBuilder gets the event before Composer
    document.addEventListener('keydown', handleKeyDown, true);
    return () => document.removeEventListener('keydown', handleKeyDown, true);
  }, [canGenerate, onClose, handleGenerate]);

  return (
    <div 
      className="absolute bottom-full left-0 right-0 mb-2 mx-2 sm:mx-0 bg-card border border-border rounded-xl shadow-xl overflow-hidden"
    >
      {/* Header */}
      <div className="bg-muted/50 px-2 sm:px-4 py-2 sm:py-3 border-b border-border">
        <div className="flex items-center justify-between">
          <h3 className="text-[10px] sm:text-sm font-medium text-foreground">Simulation Draft</h3>
          <button
            onClick={onClose}
            className="text-[9px] sm:text-xs text-muted-foreground hover:text-foreground"
          >
            ESC to close
          </button>
        </div>
      </div>

      <div className="max-h-[540px] overflow-y-auto">
        {/* SECTION 1: Describe the change */}
        <div className="p-2 sm:p-4 border-b border-border space-y-2 sm:space-y-3">
          <label className="text-[10px] sm:text-sm font-medium text-foreground">
            Describe the change
          </label>
          
          <input
            type="text"
            value={freeTextDescription}
            onChange={(e) => setFreeTextDescription(e.target.value)}
            placeholder='e.g., "Add letrozole 2.5mg daily" or "Change Gonal-F 225 → 300 IU"'
            className="w-full px-2 sm:px-3 py-1.5 sm:py-2 text-[11px] sm:text-sm bg-card text-foreground border border-border rounded-md sm:rounded-lg focus:outline-none focus:ring-2 focus:ring-primary placeholder:text-muted-foreground"
          />
          
          {/* Guidance templates */}
          <div className="flex flex-wrap gap-1 sm:gap-1.5">
            {guidanceTemplates.map((template) => (
              <button
                key={template.label}
                onClick={() => setFreeTextDescription(template.text)}
                className="px-1.5 sm:px-2 py-0.5 sm:py-1 text-[9px] sm:text-xs text-muted-foreground bg-accent hover:bg-accent/80 rounded transition-colors"
              >
                {template.label}
              </button>
            ))}
          </div>
        </div>

        {/* SECTION 2: Structured Change Builder */}
        <div className="p-2 sm:p-4 border-b border-border space-y-2 sm:space-y-3">
          <div className="flex items-center justify-between">
            <label className="text-[10px] sm:text-sm font-medium text-foreground">
              Structured changes
            </label>
            {changeItems.length > 0 && (
              <span className="text-[9px] sm:text-xs text-muted-foreground">{changeItems.length} change{changeItems.length !== 1 ? 's' : ''}</span>
            )}
          </div>

          {/* Change Items List */}
          {changeItems.length > 0 && (
            <div className="space-y-2">
              {changeItems.map((item) => {
                const config = changeTypeConfig[item.type];
                const Icon = config.icon;
                const isEditing = editingItemId === item.id;

                return (
                  <div
                    key={item.id}
                    className={`border rounded-lg transition-all ${
                      isEditing ? 'border-primary bg-primary/10' : 'border-border bg-card'
                    }`}
                  >
                    {/* Header */}
                    <div className="flex items-center justify-between px-2 sm:px-3 py-1.5 sm:py-2 border-b border-border">
                      <div className="flex items-center gap-1.5 sm:gap-2">
                        <Icon className={`w-3.5 h-3.5 sm:w-4 sm:h-4 text-primary`} />
                        <span className="text-[10px] sm:text-sm font-medium text-foreground">{config.label}</span>
                      </div>
                      <div className="flex items-center gap-0.5 sm:gap-1">
                        <button
                          onClick={() => setEditingItemId(isEditing ? null : item.id)}
                          className="text-[9px] sm:text-xs text-primary hover:text-primary/80 px-1.5 sm:px-2 py-0.5 sm:py-1"
                        >
                          {isEditing ? 'Collapse' : 'Edit'}
                        </button>
                        <button
                          onClick={() => removeChangeItem(item.id)}
                          className="p-0.5 sm:p-1 hover:bg-accent rounded"
                        >
                          <X className="w-3 h-3 sm:w-3.5 sm:h-3.5 text-muted-foreground" />
                        </button>
                      </div>
                    </div>

                    {/* Expanded Form */}
                    {isEditing && (
                      <div className="p-2 sm:p-3 space-y-2 sm:space-y-2.5">
                        {/* Medication fields */}
                        {item.type === 'medication' && (
                          <>
                            <div className="grid grid-cols-2 gap-1.5 sm:gap-2">
                              <div>
                                <label className="text-[9px] sm:text-xs text-muted-foreground block mb-0.5 sm:mb-1">Drug name</label>
                                <input
                                  type="text"
                                  value={item.drugName || ''}
                                  onChange={(e) => updateChangeItem(item.id, { drugName: e.target.value })}
                                  placeholder="e.g., Letrozole"
                                  className="w-full px-1.5 sm:px-2 py-1 sm:py-1.5 text-[10px] sm:text-sm bg-card text-foreground border border-border rounded focus:outline-none focus:ring-1 focus:ring-primary placeholder:text-muted-foreground"
                                />
                              </div>
                              <div>
                                <label className="text-[9px] sm:text-xs text-muted-foreground block mb-0.5 sm:mb-1">Action</label>
                                <select
                                  value={item.action || 'add'}
                                  onChange={(e) => updateChangeItem(item.id, { action: e.target.value as any })}
                                  className="w-full px-1.5 sm:px-2 py-1 sm:py-1.5 text-[10px] sm:text-sm bg-card text-foreground border border-border rounded focus:outline-none focus:ring-1 focus:ring-primary"
                                >
                                  <option value="add">Add</option>
                                  <option value="modify">Modify</option>
                                  <option value="stop">Stop</option>
                                </select>
                              </div>
                            </div>
                            
                            <div className="grid grid-cols-2 gap-1.5 sm:gap-2">
                              <div>
                                <label className="text-[9px] sm:text-xs text-muted-foreground block mb-0.5 sm:mb-1">Dose</label>
                                <input
                                  type="text"
                                  value={item.dose || ''}
                                  onChange={(e) => updateChangeItem(item.id, { dose: e.target.value })}
                                  placeholder="e.g., 2.5mg"
                                  className="w-full px-1.5 sm:px-2 py-1 sm:py-1.5 text-[10px] sm:text-sm bg-card text-foreground border border-border rounded focus:outline-none focus:ring-1 focus:ring-primary placeholder:text-muted-foreground"
                                />
                              </div>
                              <div>
                                <label className="text-[9px] sm:text-xs text-muted-foreground block mb-0.5 sm:mb-1">Frequency</label>
                                <select
                                  value={item.frequency || 'Daily'}
                                  onChange={(e) => updateChangeItem(item.id, { frequency: e.target.value })}
                                  className="w-full px-1.5 sm:px-2 py-1 sm:py-1.5 text-[10px] sm:text-sm bg-card text-foreground border border-border rounded focus:outline-none focus:ring-1 focus:ring-primary"
                                >
                                  {frequencyOptions.map(opt => (
                                    <option key={opt} value={opt}>{opt}</option>
                                  ))}
                                </select>
                              </div>
                            </div>

                            <div className="grid grid-cols-2 gap-1.5 sm:gap-2">
                              <div>
                                <label className="text-[9px] sm:text-xs text-muted-foreground block mb-0.5 sm:mb-1">Route</label>
                                <select
                                  value={item.route || 'Oral'}
                                  onChange={(e) => updateChangeItem(item.id, { route: e.target.value })}
                                  className="w-full px-1.5 sm:px-2 py-1 sm:py-1.5 text-[10px] sm:text-sm bg-card text-foreground border border-border rounded focus:outline-none focus:ring-1 focus:ring-primary"
                                >
                                  {routeOptions.map(opt => (
                                    <option key={opt} value={opt}>{opt}</option>
                                  ))}
                                </select>
                              </div>
                              <div>
                                <label className="text-[9px] sm:text-xs text-muted-foreground block mb-0.5 sm:mb-1">Duration (optional)</label>
                                <input
                                  type="text"
                                  value={item.duration || ''}
                                  onChange={(e) => updateChangeItem(item.id, { duration: e.target.value })}
                                  placeholder="e.g., 14 days"
                                  className="w-full px-1.5 sm:px-2 py-1 sm:py-1.5 text-[10px] sm:text-sm bg-card text-foreground border border-border rounded focus:outline-none focus:ring-1 focus:ring-primary placeholder:text-muted-foreground"
                                />
                              </div>
                            </div>
                          </>
                        )}

                        {/* Procedure fields */}
                        {item.type === 'procedure' && (
                          <>
                            <div>
                              <label className="text-[9px] sm:text-xs text-muted-foreground block mb-0.5 sm:mb-1">Procedure type</label>
                              <input
                                type="text"
                                value={item.procedureType || ''}
                                onChange={(e) => updateChangeItem(item.id, { procedureType: e.target.value })}
                                placeholder="e.g., Laser-assisted hatching"
                                className="w-full px-1.5 sm:px-2 py-1 sm:py-1.5 text-[10px] sm:text-sm bg-card text-foreground border border-border rounded focus:outline-none focus:ring-1 focus:ring-primary placeholder:text-muted-foreground"
                              />
                            </div>
                            <div>
                              <label className="text-[9px] sm:text-xs text-muted-foreground block mb-0.5 sm:mb-1">Timing</label>
                              <select
                                value={item.timing || 'Next visit'}
                                onChange={(e) => updateChangeItem(item.id, { timing: e.target.value })}
                                className="w-full px-1.5 sm:px-2 py-1 sm:py-1.5 text-[10px] sm:text-sm bg-card text-foreground border border-border rounded focus:outline-none focus:ring-1 focus:ring-primary"
                              >
                                {timingOptions.map(opt => (
                                  <option key={opt} value={opt}>{opt}</option>
                                ))}
                              </select>
                            </div>
                          </>
                        )}

                        {/* Prescription/Protocol fields */}
                        {item.type === 'prescription' && (
                          <>
                            <div>
                              <label className="text-[9px] sm:text-xs text-muted-foreground block mb-0.5 sm:mb-1">Protocol name</label>
                              <input
                                type="text"
                                value={item.protocolName || ''}
                                onChange={(e) => updateChangeItem(item.id, { protocolName: e.target.value })}
                                placeholder="e.g., Progesterone support protocol"
                                className="w-full px-1.5 sm:px-2 py-1 sm:py-1.5 text-[10px] sm:text-sm bg-card text-foreground border border-border rounded focus:outline-none focus:ring-1 focus:ring-primary placeholder:text-muted-foreground"
                              />
                            </div>
                            <div>
                              <label className="text-[9px] sm:text-xs text-muted-foreground block mb-0.5 sm:mb-1">Key parameters (optional)</label>
                              <input
                                type="text"
                                value={item.parameters || ''}
                                onChange={(e) => updateChangeItem(item.id, { parameters: e.target.value })}
                                placeholder="e.g., Start at retrieval, continue 12 weeks"
                                className="w-full px-1.5 sm:px-2 py-1 sm:py-1.5 text-[10px] sm:text-sm bg-card text-foreground border border-border rounded focus:outline-none focus:ring-1 focus:ring-primary placeholder:text-muted-foreground"
                              />
                            </div>
                          </>
                        )}

                        {/* Labs fields */}
                        {item.type === 'labs' && (
                          <>
                            <div>
                              <label className="text-[9px] sm:text-xs text-muted-foreground block mb-0.5 sm:mb-1">Tests</label>
                              <div className="flex flex-wrap gap-1 sm:gap-1.5 p-1.5 sm:p-2 border border-border rounded bg-accent">
                                {commonTests.map(test => (
                                  <button
                                    key={test}
                                    onClick={() => toggleTestSelection(item.id, test)}
                                    className={`px-1.5 sm:px-2 py-0.5 sm:py-1 text-[9px] sm:text-xs rounded transition-colors ${
                                      item.tests?.includes(test)
                                        ? 'bg-primary text-primary-foreground'
                                        : 'bg-card text-foreground hover:bg-accent border border-border'
                                    }`}
                                  >
                                    {test}
                                  </button>
                                ))}
                              </div>
                            </div>
                            <div>
                              <label className="text-[9px] sm:text-xs text-muted-foreground block mb-0.5 sm:mb-1">Timing</label>
                              <select
                                value={item.labTiming || 'Next visit'}
                                onChange={(e) => updateChangeItem(item.id, { labTiming: e.target.value })}
                                className="w-full px-1.5 sm:px-2 py-1 sm:py-1.5 text-[10px] sm:text-sm bg-card text-foreground border border-border rounded focus:outline-none focus:ring-1 focus:ring-primary"
                              >
                                {timingOptions.map(opt => (
                                  <option key={opt} value={opt}>{opt}</option>
                                ))}
                              </select>
                            </div>
                          </>
                        )}

                        {/* Follow-up fields */}
                        {item.type === 'followup' && (
                          <div>
                            <label className="text-[9px] sm:text-xs text-muted-foreground block mb-0.5 sm:mb-1">Next follow-up in</label>
                            <select
                              value={item.followupIn || '1 week'}
                              onChange={(e) => updateChangeItem(item.id, { followupIn: e.target.value })}
                              className="w-full px-1.5 sm:px-2 py-1 sm:py-1.5 text-[10px] sm:text-sm bg-card text-foreground border border-border rounded focus:outline-none focus:ring-1 focus:ring-primary"
                            >
                              {followupOptions.map(opt => (
                                <option key={opt} value={opt}>{opt}</option>
                              ))}
                            </select>
                          </div>
                        )}

                        {/* Notes (all types) */}
                        <div>
                          <label className="text-[9px] sm:text-xs text-muted-foreground block mb-0.5 sm:mb-1">Notes (optional)</label>
                          <input
                            type="text"
                            value={item.notes || ''}
                            onChange={(e) => updateChangeItem(item.id, { notes: e.target.value })}
                            placeholder="Additional context..."
                            className="w-full px-1.5 sm:px-2 py-1 sm:py-1.5 text-[10px] sm:text-sm bg-card text-foreground border border-border rounded focus:outline-none focus:ring-1 focus:ring-primary placeholder:text-muted-foreground"
                          />
                        </div>
                      </div>
                    )}
                  </div>
                );
              })}
            </div>
          )}

          {/* Add change button */}
          <div className="relative">
            <button
              onClick={() => setShowTypeSelector(!showTypeSelector)}
              className="w-full flex items-center justify-center gap-1.5 sm:gap-2 px-2 sm:px-3 py-1.5 sm:py-2 border border-dashed border-border rounded-md sm:rounded-lg text-[10px] sm:text-sm text-muted-foreground hover:border-primary/50 hover:bg-accent/50 transition-colors"
            >
              <Plus className="w-3.5 h-3.5 sm:w-4 sm:h-4" />
              Add change
            </button>

            {/* Type selector dropdown */}
            {showTypeSelector && (
              <div className="absolute top-full left-0 right-0 mt-1 bg-card border border-border rounded-md sm:rounded-lg shadow-lg z-10">
                {Object.entries(changeTypeConfig).map(([type, config]) => {
                  const Icon = config.icon;
                  return (
                    <button
                      key={type}
                      onClick={() => handleAddChange(type as ChangeType)}
                      className="w-full flex items-center gap-2 sm:gap-3 px-2 sm:px-3 py-1.5 sm:py-2 text-left text-foreground hover:bg-accent transition-colors first:rounded-t-md sm:first:rounded-t-lg last:rounded-b-md sm:last:rounded-b-lg"
                    >
                      <Icon className={`w-3.5 h-3.5 sm:w-4 sm:h-4 text-primary`} />
                      <span className="text-[10px] sm:text-sm">{config.label}</span>
                    </button>
                  );
                })}
              </div>
            )}
          </div>
        </div>

        {/* SECTION 3: Run settings */}
        <div className="p-2 sm:p-4 space-y-2 sm:space-y-3">
          <label className="text-[10px] sm:text-sm font-medium text-foreground">
            Run settings
          </label>
          
          <div className="grid grid-cols-3 gap-1.5 sm:gap-2">
            {['7d', '14d', '30d'].map((horizon) => (
              <button
                key={horizon}
                onClick={() => setTimeHorizon(horizon)}
                className={`px-2 sm:px-3 py-1.5 sm:py-2 rounded-md sm:rounded-lg border text-[10px] sm:text-sm transition-all ${
                  timeHorizon === horizon
                    ? 'bg-primary/15 border-primary text-primary font-medium'
                    : 'bg-card border-border text-foreground hover:border-primary/40'
                }`}
              >
                {horizon === '7d' ? '7 days' : horizon === '14d' ? '14 days' : '30 days'}
              </button>
            ))}
          </div>

          <div className="flex items-center justify-between text-[9px] sm:text-xs text-muted-foreground pt-1 flex-wrap gap-1">
            <span>Compare to: <span className="font-medium text-foreground">Current plan</span></span>
            <span>Output: <span className="font-medium text-foreground">Delta-first</span></span>
          </div>
        </div>

        {/* Command preview */}
        <div className="px-2 sm:px-4 pb-2 sm:pb-4">
          <div className="p-2 sm:p-2.5 bg-accent border border-border rounded-md sm:rounded-lg">
            <div className="text-[9px] sm:text-xs text-muted-foreground mb-1">Command preview</div>
            <div className="font-mono text-[9px] sm:text-xs text-foreground break-all">
              {generateCommand()}
            </div>
          </div>
        </div>
      </div>

      {/* Footer */}
      <div className="bg-accent/50 px-2 sm:px-4 py-2 sm:py-3 border-t border-border flex items-center justify-between gap-2 flex-wrap">
        <div className="text-[9px] sm:text-xs text-muted-foreground">
          {canGenerate ? (
            <>Press <kbd className="px-1 sm:px-1.5 py-0.5 bg-card border border-border rounded text-foreground font-mono text-[8px] sm:text-xs">Enter</kbd> to run</>
          ) : (
            'Add a description or structured change to continue'
          )}
        </div>
        <button
          onClick={handleGenerate}
          disabled={!canGenerate}
          className={`px-3 sm:px-4 py-1 sm:py-1.5 rounded-md sm:rounded-lg text-[10px] sm:text-sm font-medium transition-all ${
            canGenerate
              ? 'bg-primary text-primary-foreground hover:opacity-90'
              : 'bg-muted text-muted-foreground cursor-not-allowed'
          }`}
        >
          Generate
        </button>
      </div>
    </div>
  );
}
