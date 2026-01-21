import { useState } from 'react';
import * as React from 'react';
import { Send, Link2, Calendar, Brain, User, X, ExternalLink, Settings, Type, Moon, Sun, Maximize2, Download, Trash2, Volume2, VolumeX, ChevronDown, ChevronUp, Activity, Pill, Clock, Database, Sparkles, RefreshCw } from 'lucide-react';
import { Patient } from '../App';
import { API_BASE_URL } from '../src/config';
import jsPDF from 'jspdf';
import 'jspdf-autotable';

interface Message {
  id: string;
  speaker: 'doctor' | 'ai';
  speakerName: string;
  speakerRole?: string;
  timestamp: string;
  content: string;
  messageType: 'text' | 'explanation' | 'data-reference' | 'suggestion';
  createdAt?: number; // For sorting
  references?: {
    type: 'vitals' | 'labs' | 'decision' | 'visit';
    label: string;
    visitId?: string;
  }[];
}

interface Practitioner {
  id: string;
  name: string;
  email: string;
  specialty?: string;
  role?: string;
}

interface ClinicalDiscussionProps {
  patient: Patient;
  visitId?: string;
  onClose?: () => void;
  onViewVisit?: (visitId: string) => void;
  loggedInPractitioner?: Practitioner | null;
}

interface ChatSettings {
  fontSize: 'small' | 'medium' | 'large';
  theme: 'light' | 'dark';
  messageDensity: 'compact' | 'normal' | 'comfortable';
  autoScroll: boolean;
  soundNotifications: boolean;
}

export function ClinicalDiscussion({ patient, visitId, onClose, onViewVisit, loggedInPractitioner }: ClinicalDiscussionProps) {
  // Messages will be fetched from API later
  const [messages, setMessages] = useState<Message[]>([]);
  const [newMessage, setNewMessage] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [sessionId, setSessionId] = useState<string | null>(null);
  const messagesEndRef = React.useRef<HTMLDivElement>(null);
  const [showSettings, setShowSettings] = useState(false);
  const [showPatientDetails, setShowPatientDetails] = useState(false);
  const [settings, setSettings] = useState<ChatSettings>({
    fontSize: 'medium',
    theme: 'light',
    messageDensity: 'normal',
    autoScroll: true,
    soundNotifications: false,
  });

  // Load settings from localStorage on mount
  React.useEffect(() => {
    const savedSettings = localStorage.getItem('clinicalDiscussionSettings');
    if (savedSettings) {
      try {
        const parsed = JSON.parse(savedSettings);
        setSettings(prev => ({ ...prev, ...parsed }));
      } catch (e) {
        console.error('Failed to load settings:', e);
      }
    }
  }, []);

  // Save settings to localStorage when they change
  React.useEffect(() => {
    localStorage.setItem('clinicalDiscussionSettings', JSON.stringify(settings));
  }, [settings]);

  // Play sound notification when new AI message arrives
  React.useEffect(() => {
    if (settings.soundNotifications && messages.length > 0) {
      const lastMessage = messages[messages.length - 1];
      if (lastMessage.speaker === 'ai' && lastMessage.content !== 'Thinking...') {
        // Create a simple beep sound using Web Audio API
        try {
          const audioContext = new (window.AudioContext || (window as any).webkitAudioContext)();
          const oscillator = audioContext.createOscillator();
          const gainNode = audioContext.createGain();
          
          oscillator.connect(gainNode);
          gainNode.connect(audioContext.destination);
          
          oscillator.frequency.value = 800; // Frequency in Hz
          oscillator.type = 'sine';
          
          gainNode.gain.setValueAtTime(0.3, audioContext.currentTime);
          gainNode.gain.exponentialRampToValueAtTime(0.01, audioContext.currentTime + 0.1);
          
          oscillator.start(audioContext.currentTime);
          oscillator.stop(audioContext.currentTime + 0.1);
        } catch (e) {
          console.log('Sound notification not available:', e);
        }
      }
    }
  }, [messages, settings.soundNotifications]);

  const currentVisitId = visitId || '';
  
  // Get headers for API calls (include practitioner email if available)
  const getApiHeaders = () => {
    const headers: HeadersInit = {
      'Content-Type': 'application/json',
    };
    
    // Add practitioner email header if available (for backend to look up practitioner)
    if (loggedInPractitioner?.email) {
      headers['X-User-Email'] = loggedInPractitioner.email;
    }
    if (loggedInPractitioner?.id) {
      headers['X-User-Id'] = loggedInPractitioner.id;
    }
    
    return headers;
  };

  // Function to load clinical notes from API
  // NOTE: Chat messages are NOT saved to BigQuery - messages are ephemeral
  // This function is kept for backward compatibility but returns empty array
  const loadClinicalNotes = React.useCallback(async () => {
    // Chat messages are ephemeral - not saved to BigQuery
    // Return empty array - messages only exist in current session
    setMessages([]);
  }, [patient.id, visitId]);

  // Function to initialize or restart chat session
  const initializeChatSession = React.useCallback(async (forceNew: boolean = false) => {
    try {
      setIsLoading(true);
      
      // Call the initialization endpoint with forceNew flag
      const response = await fetch(`${API_BASE_URL}/discussion/chat/initialize`, {
        method: 'POST',
        headers: getApiHeaders(),
        body: JSON.stringify({
          patientId: patient.id,
          visitId: currentVisitId,
          practitionerEmail: loggedInPractitioner?.email,
          forceNew: forceNew // Force new session if restarting
        }),
      });
      
      if (response.ok) {
        const result = await response.json();
        
        // Check if initialized is true and response exists
        if (result.data && result.data.initialized === true && result.data.response) {
          const initialAiResponse = result.data.response;
          
          // Show the initial AI message
          const initialMessage: Message = {
            id: `initial_${Date.now()}`,
            speaker: 'ai',
            speakerName: 'AI Clinical Assistant',
            speakerRole: 'AI Assistant',
            timestamp: new Date().toLocaleString('en-US', { 
              month: 'short', 
              day: 'numeric', 
              year: 'numeric',
              hour: 'numeric',
              minute: '2-digit',
              hour12: true
            }),
            content: initialAiResponse,
            messageType: 'text',
            createdAt: Date.now()
          };
          
          setMessages([initialMessage]);
          console.log(forceNew ? 'Chat session restarted with new session ID' : 'Chat session initialized with initial message');
        } else {
          // Session already exists, start with empty messages
          setMessages([]);
          console.log('Chat session already exists');
        }
      } else {
        const errorText = await response.text();
        console.error('Failed to initialize chat session:', response.statusText, errorText);
        setMessages([]);
      }
    } catch (error) {
      console.error('Failed to initialize chat session:', error);
      setMessages([]);
    } finally {
      setIsLoading(false);
    }
  }, [patient.id, currentVisitId, loggedInPractitioner?.email]);

  // Initialize chat session on mount
  React.useEffect(() => {
    initializeChatSession(false);
  }, [patient.id, currentVisitId]);

  // Auto-scroll to bottom when new messages are added (if enabled)
  React.useEffect(() => {
    if (settings.autoScroll) {
      messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
    }
  }, [messages, settings.autoScroll]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!newMessage.trim()) return;

    const messageToSend = newMessage;
    setNewMessage('');
    
    // Immediately show the user's message
    const userMessage: Message = {
      id: `user_${Date.now()}`,
      speaker: 'doctor',
      speakerName: loggedInPractitioner?.name 
        ? (loggedInPractitioner.name.startsWith('Dr.') ? loggedInPractitioner.name : `Dr. ${loggedInPractitioner.name}`)
        : 'You',
      speakerRole: loggedInPractitioner?.specialty,
      timestamp: new Date().toLocaleString('en-US', { 
        month: 'short', 
        day: 'numeric', 
        year: 'numeric',
        hour: 'numeric',
        minute: '2-digit',
        hour12: true
      }),
      content: messageToSend,
      messageType: 'text',
      createdAt: Date.now()
    };
    
    // Add user message immediately
    setMessages(prev => [...prev, userMessage]);
    
    // Show "waiting for answer" indicator
    const waitingMessageId = `waiting_${Date.now()}`;
    const waitingMessage: Message = {
      id: waitingMessageId,
      speaker: 'ai',
      speakerName: 'AI Clinical Assistant',
      speakerRole: 'AI Assistant',
      timestamp: '...',
      content: 'Thinking...',
      messageType: 'text',
      createdAt: Date.now() + 1
    };
    setMessages(prev => [...prev, waitingMessage]);
    setIsLoading(true);

    try {
      // Call backend API - this will save both the question and AI response
      const response = await fetch(`${API_BASE_URL}/discussion/chat`, {
        method: 'POST',
        headers: getApiHeaders(),
        body: JSON.stringify({
          patientId: patient.id,
          visitId: currentVisitId,
          message: messageToSend,
          practitionerEmail: loggedInPractitioner?.email, // Send email in request body
        }),
      });

      if (!response.ok) {
        const errorText = await response.text();
        throw new Error(`Failed to send message: ${response.statusText} - ${errorText}`);
      }

      const result = await response.json();
      
      // Update session ID if provided
      if (result.data?.sessionId) {
        setSessionId(result.data.sessionId);
      }

      // Remove waiting message
      setMessages(prev => prev.filter(msg => msg.id !== waitingMessageId));
      
      // Add AI response message (not saved to BigQuery - ephemeral chat)
      const aiResponseText = result.data?.response || result.response || result.data?.message || result.message;
      if (aiResponseText && aiResponseText.trim() && aiResponseText !== 'null') {
        const aiMessage: Message = {
          id: `ai_${Date.now()}`,
          speaker: 'ai',
          speakerName: 'AI Clinical Assistant',
          speakerRole: 'AI Assistant',
          timestamp: new Date().toLocaleString('en-US', { 
            month: 'short', 
            day: 'numeric', 
            year: 'numeric',
            hour: 'numeric',
            minute: '2-digit',
            hour12: true
          }),
          content: aiResponseText,
          messageType: 'explanation',
          createdAt: Date.now()
        };
        setMessages(prev => [...prev, aiMessage]);
      } else {
        // If no valid response, show error
        const errorMessage: Message = {
          id: `error_${Date.now()}`,
          speaker: 'ai',
          speakerName: 'System',
          timestamp: new Date().toLocaleString('en-US', { 
            month: 'short', 
            day: 'numeric', 
            year: 'numeric',
            hour: 'numeric',
            minute: '2-digit',
            hour12: true
          }),
          content: 'Sorry, the AI did not return a valid response. Please try again.',
          messageType: 'text',
          createdAt: Date.now()
        };
        setMessages(prev => [...prev, errorMessage]);
      }
    } catch (error) {
      console.error('Error sending message:', error);
      
      // Remove waiting message
      setMessages(prev => prev.filter(msg => msg.id !== waitingMessageId));
      
      // Show error message
      const errorMessage: Message = {
        id: `error_${Date.now()}`,
        speaker: 'ai',
        speakerName: 'System',
        timestamp: new Date().toLocaleString('en-US', { 
          month: 'short', 
          day: 'numeric', 
          year: 'numeric',
          hour: 'numeric',
          minute: '2-digit',
          hour12: true
        }),
        content: `Sorry, I encountered an error processing your request: ${error instanceof Error ? error.message : 'Unknown error'}. Please try again.`,
        messageType: 'text',
        createdAt: Date.now()
      };
      setMessages(prev => [...prev, errorMessage]);
    } finally {
      setIsLoading(false);
    }
  };

  // Apply theme
  const themeClass = settings.theme === 'dark' ? 'dark' : '';
  
  return (
    <div className={`${themeClass} ${onClose ? 'fixed inset-0 bg-gray-900 bg-opacity-50 flex items-center justify-center z-50 p-4' : 'h-full flex flex-col'}`}>
      <div className={`${onClose ? `${settings.theme === 'dark' ? 'bg-slate-900' : 'bg-white'} rounded-2xl w-full max-w-5xl h-full max-h-[95vh] shadow-2xl` : 'h-full'} flex flex-col overflow-hidden`}>
        {/* Enhanced Medical-Grade Header with Patient Details */}
        <div className={`${onClose ? 'px-4 sm:px-6 py-3 sm:py-4' : 'px-4 sm:px-6 py-3 sm:py-4'} border-b ${settings.theme === 'dark' ? 'border-slate-700 bg-slate-800' : 'border-slate-200 bg-gradient-to-br from-white via-slate-50/30 to-white'} flex-shrink-0`}>
          <div className="flex items-center justify-between mb-2">
            <div className="flex items-center gap-4 flex-1 min-w-0">
              <div className="flex items-center gap-4">
                <div className="w-14 h-14 rounded-full bg-gradient-to-br from-indigo-600 via-indigo-700 to-slate-700 flex items-center justify-center shadow-lg ring-2 ring-indigo-100">
                  <User className="w-7 h-7 text-white" />
                </div>
                <div className="flex-1">
                  <h1 className="text-xl font-bold text-slate-900 tracking-tight">{patient.name}</h1>
                  <div className="flex items-center gap-3 mt-1 flex-wrap">
                    <span className="text-sm text-slate-600 font-medium">{patient.age} years, {patient.sex}</span>
                    {currentVisitId && (
                      <>
                        <span className="text-slate-300">•</span>
                        <span className="text-xs text-slate-500 font-mono bg-slate-100 px-2 py-0.5 rounded border border-slate-200">{currentVisitId}</span>
                      </>
                    )}
                    {patient.twinId && (
                      <>
                        <span className="text-slate-300">•</span>
                        <span className="text-xs text-indigo-600 font-mono bg-indigo-50 px-2 py-0.5 rounded border border-indigo-200 flex items-center gap-1">
                          <Database className="w-3 h-3" />
                          {patient.twinId.substring(0, 20)}...
                        </span>
                      </>
                    )}
                  </div>
                </div>
              </div>
            </div>
            <div className="flex items-center gap-2">
              <button
                onClick={() => setShowPatientDetails(!showPatientDetails)}
                className="text-slate-500 hover:text-slate-700 hover:bg-slate-100 rounded-lg p-2 transition-all"
                title="Toggle patient details"
              >
                {showPatientDetails ? <ChevronUp className="w-5 h-5" /> : <ChevronDown className="w-5 h-5" />}
              </button>
              <button
                onClick={() => setShowSettings(!showSettings)}
                className="text-slate-500 hover:text-slate-700 hover:bg-slate-100 rounded-lg p-2 transition-all relative"
                title="Settings"
              >
                <Settings className="w-5 h-5" />
                {showSettings && (
                  <span className="absolute top-1 right-1 w-2 h-2 bg-indigo-600 rounded-full"></span>
                )}
              </button>
              {onClose && (
                <button onClick={onClose} className="text-slate-400 hover:text-slate-600 hover:bg-slate-100 rounded-lg p-2 transition-all">
                  <X className="w-5 h-5" />
                </button>
              )}
            </div>
          </div>

          {/* Expandable Patient Details */}
          {showPatientDetails && (
            <div className="mt-3 sm:mt-4 pt-3 sm:pt-4 border-t border-slate-200 grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3 sm:gap-4 animate-in slide-in-from-top-2 duration-200 max-h-[30vh] overflow-y-auto">
              {/* Vitals */}
              {patient.vitals && (
                <div className="bg-gradient-to-br from-blue-50 to-indigo-50 rounded-xl p-4 border border-blue-200/50 shadow-sm">
                  <div className="flex items-center gap-2 mb-3">
                    <div className="p-1.5 bg-blue-100 rounded-lg">
                      <Activity className="w-4 h-4 text-blue-700" />
                    </div>
                    <span className="text-xs font-semibold text-slate-700 uppercase tracking-wide">Vitals</span>
                  </div>
                  <div className="space-y-2 text-sm">
                    {patient.vitals.bloodPressure && (
                      <div className="flex justify-between items-center bg-white/60 rounded-lg px-3 py-2">
                        <span className="text-slate-600 font-medium">BP:</span>
                        <span className="font-semibold text-slate-900">{patient.vitals.bloodPressure}</span>
                      </div>
                    )}
                    {patient.vitals.heartRate && (
                      <div className="flex justify-between items-center bg-white/60 rounded-lg px-3 py-2">
                        <span className="text-slate-600 font-medium">HR:</span>
                        <span className="font-semibold text-slate-900">{patient.vitals.heartRate}</span>
                      </div>
                    )}
                    {patient.vitals.temperature && (
                      <div className="flex justify-between items-center bg-white/60 rounded-lg px-3 py-2">
                        <span className="text-slate-600 font-medium">Temp:</span>
                        <span className="font-semibold text-slate-900">{patient.vitals.temperature}</span>
                      </div>
                    )}
                  </div>
                </div>
              )}

              {/* Medications */}
              {patient.medications && patient.medications.length > 0 && (
                <div className="bg-gradient-to-br from-purple-50 to-indigo-50 rounded-xl p-4 border border-purple-200/50 shadow-sm">
                  <div className="flex items-center gap-2 mb-3">
                    <div className="p-1.5 bg-purple-100 rounded-lg">
                      <Pill className="w-4 h-4 text-purple-700" />
                    </div>
                    <span className="text-xs font-semibold text-slate-700 uppercase tracking-wide">Medications</span>
                  </div>
                  <div className="flex flex-wrap gap-2">
                    {patient.medications.slice(0, 3).map((med, idx) => (
                      <span key={idx} className="px-2.5 py-1 bg-white/80 text-purple-700 text-xs font-medium rounded-lg border border-purple-200/50">
                        {med}
                      </span>
                    ))}
                    {patient.medications.length > 3 && (
                      <span className="px-2.5 py-1 bg-slate-200/60 text-slate-600 text-xs font-medium rounded-lg">
                        +{patient.medications.length - 3} more
                      </span>
                    )}
                  </div>
                </div>
              )}

              {/* Status & Evaluation */}
              <div className="bg-gradient-to-br from-slate-50 to-gray-50 rounded-xl p-4 border border-slate-200/50 shadow-sm">
                <div className="flex items-center gap-2 mb-3">
                  <div className="p-1.5 bg-slate-100 rounded-lg">
                    <Clock className="w-4 h-4 text-slate-700" />
                  </div>
                  <span className="text-xs font-semibold text-slate-700 uppercase tracking-wide">Status</span>
                </div>
                <div className="space-y-2 text-sm">
                  <div className="flex justify-between items-center bg-white/60 rounded-lg px-3 py-2">
                    <span className="text-slate-600 font-medium">Status:</span>
                    <span className="font-semibold text-slate-900">{patient.status}</span>
                  </div>
                  {patient.lastEvaluation && (
                    <div className="flex justify-between items-center bg-white/60 rounded-lg px-3 py-2">
                      <span className="text-slate-600 font-medium">Last Eval:</span>
                      <span className="font-semibold text-slate-900 text-xs">{new Date(patient.lastEvaluation).toLocaleDateString()}</span>
                    </div>
                  )}
                  {patient.nextAction && (
                    <div className="flex justify-between items-center bg-white/60 rounded-lg px-3 py-2">
                      <span className="text-slate-600 font-medium">Next:</span>
                      <span className="font-semibold text-slate-900 text-xs truncate">{patient.nextAction}</span>
                    </div>
                  )}
                </div>
              </div>
            </div>
          )}
        </div>

        {/* Messages Container - Responsive height with settings applied */}
        <div 
          className={`overflow-y-auto flex-1 min-h-0 ${onClose ? 'px-4 sm:px-6 py-4 sm:py-6' : 'px-4 sm:px-6 py-4 sm:py-6'} ${settings.theme === 'dark' ? 'bg-slate-900' : 'bg-gradient-to-b from-slate-50/40 via-white to-slate-50/20'}`}
        >
          <div className={settings.messageDensity === 'compact' ? 'space-y-2' : settings.messageDensity === 'comfortable' ? 'space-y-6' : 'space-y-4'}>
          {messages.map((message) => {
            const isAI = message.speaker === 'ai';
            const isDoctor = !isAI;
            
            // Apply message density spacing
            const densitySpacing = settings.messageDensity === 'compact' ? 'mb-2' : 
                                  settings.messageDensity === 'comfortable' ? 'mb-6' : 'mb-4';
            
            return (
              <div 
                key={message.id} 
                className={`flex gap-3 ${densitySpacing} ${isDoctor ? 'flex-row-reverse' : ''}`}
              >
                {/* Avatar - Enhanced with better styling */}
                <div className={`w-11 h-11 rounded-full flex items-center justify-center flex-shrink-0 shadow-md ${
                  isAI 
                    ? 'bg-gradient-to-br from-indigo-500 via-indigo-600 to-indigo-700 ring-2 ring-indigo-100' 
                    : 'bg-gradient-to-br from-slate-500 via-slate-600 to-slate-700 ring-2 ring-slate-100'
                }`}>
                  {isAI ? (
                    <Brain className="w-5 h-5 text-white" />
                  ) : (
                    <User className="w-5 h-5 text-white" />
                  )}
                </div>

                {/* Message Content */}
                <div className={`flex-1 ${isDoctor ? 'flex flex-col items-end' : ''}`}>
                  <div className={`flex items-baseline gap-2 mb-2 ${isDoctor ? 'flex-row-reverse' : ''}`}>
                    <span className={`font-semibold text-sm ${isAI ? 'text-indigo-700' : 'text-slate-700'}`}>
                      {message.speakerName}
                    </span>
                    {message.speakerRole && (
                      <span className="text-xs text-gray-500 font-medium">{message.speakerRole}</span>
                    )}
                    <span className="text-xs text-gray-400">{message.timestamp}</span>
                  </div>

                  {/* Message Type Badge - only for AI */}
                  {isAI && message.messageType !== 'text' && (
                    <div className={`mb-2 ${isDoctor ? 'flex justify-end' : ''}`}>
                      <span className={`px-2 py-0.5 text-xs font-medium rounded ${
                        message.messageType === 'explanation' ? 'bg-indigo-100 text-indigo-700' :
                        message.messageType === 'data-reference' ? 'bg-slate-100 text-slate-700' :
                        'bg-amber-100 text-amber-700'
                      }`}>
                        {message.messageType === 'explanation' ? 'AI Explanation' :
                         message.messageType === 'data-reference' ? 'Data Reference' :
                         'AI Suggestion'}
                      </span>
                    </div>
                  )}
                  
                  <div className={`rounded-2xl p-4 border shadow-md max-w-[75%] transition-all hover:shadow-lg ${
                    isAI 
                      ? settings.theme === 'dark'
                        ? 'bg-slate-800 border-indigo-600/50 rounded-tl-none'
                        : 'bg-gradient-to-br from-white to-indigo-50/30 border-indigo-200/80 rounded-tl-none'
                      : settings.theme === 'dark'
                        ? 'bg-slate-800 border-slate-600/50 rounded-tr-none'
                        : 'bg-gradient-to-br from-white to-slate-50/30 border-slate-200/80 rounded-tr-none'
                  }`}>
                    {message.content === 'Thinking...' ? (
                      <div className="flex items-center gap-2 text-gray-600">
                        <div className="w-4 h-4 border-2 border-purple-600 border-t-transparent rounded-full animate-spin"></div>
                        <span>Waiting for AI response...</span>
                      </div>
                    ) : message.content && message.content !== '(No content)' ? (
                      <p 
                        className={`${settings.theme === 'dark' ? 'text-slate-100' : 'text-slate-800'} whitespace-pre-wrap break-words leading-relaxed font-normal`}
                        style={{
                          fontSize: settings.fontSize === 'small' ? '0.875rem' : settings.fontSize === 'large' ? '1rem' : '0.9375rem'
                        }}
                      >
                        {message.content}
                      </p>
                    ) : (
                      <p 
                        className={`${settings.theme === 'dark' ? 'text-slate-400' : 'text-slate-500'} italic`}
                        style={{
                          fontSize: settings.fontSize === 'small' ? '0.875rem' : settings.fontSize === 'large' ? '1rem' : '0.9375rem'
                        }}
                      >
                        (No content)
                      </p>
                    )}
                    
                    {message.references && message.references.length > 0 && (
                      <div className="mt-3 pt-3 border-t border-gray-300 space-y-2">
                        {message.references.map((ref, idx) => (
                          <button
                            key={idx}
                            className={`flex items-center gap-2 text-sm ${
                              isAI ? 'text-purple-700 hover:text-purple-800' : 'text-blue-600 hover:text-blue-700'
                            }`}
                          >
                            <Link2 className="w-3.5 h-3.5" />
                            <span className={`px-2 py-0.5 rounded text-xs ${
                              ref.type === 'vitals' ? 'bg-green-100 text-green-700' :
                              ref.type === 'labs' ? 'bg-purple-100 text-purple-700' :
                              ref.type === 'visit' ? 'bg-blue-100 text-blue-700' :
                              'bg-orange-100 text-orange-700'
                            }`}>
                              {ref.type}
                            </span>
                            {ref.label}
                          </button>
                        ))}
                      </div>
                    )}
                  </div>
                </div>
              </div>
            );
          })}
          </div>
          {/* Scroll anchor for auto-scroll */}
          <div ref={messagesEndRef} />
        </div>

        {/* Settings Panel */}
        {showSettings && (
          <div className="absolute right-4 top-20 bg-white rounded-2xl shadow-2xl border border-slate-200 p-5 w-80 z-50 animate-in slide-in-from-right-2 duration-200">
            <div className="flex items-center justify-between mb-4 pb-3 border-b border-slate-200">
              <div className="flex items-center gap-2">
                <div className="p-1.5 bg-indigo-100 rounded-lg">
                  <Settings className="w-4 h-4 text-indigo-700" />
                </div>
                <h3 className="text-lg font-bold text-slate-900">Chat Settings</h3>
              </div>
              <button onClick={() => setShowSettings(false)} className="text-slate-400 hover:text-slate-600 hover:bg-slate-100 rounded-lg p-1 transition-all">
                <X className="w-4 h-4" />
              </button>
            </div>
            
            <div className="space-y-5 max-h-[60vh] overflow-y-auto">
              {/* Font Size */}
              <div>
                <label className="flex items-center gap-2 text-sm font-semibold text-slate-700 mb-3">
                  <Type className="w-4 h-4 text-indigo-600" />
                  Font Size
                </label>
                <div className="flex gap-2">
                  {(['small', 'medium', 'large'] as const).map((size) => (
                    <button
                      key={size}
                      onClick={() => setSettings({...settings, fontSize: size})}
                      className={`flex-1 px-3 py-2.5 rounded-lg text-sm font-medium transition-all ${
                        settings.fontSize === size
                          ? 'bg-gradient-to-r from-indigo-600 to-indigo-700 text-white shadow-md'
                          : 'bg-slate-100 text-slate-700 hover:bg-slate-200'
                      }`}
                    >
                      {size.charAt(0).toUpperCase() + size.slice(1)}
                    </button>
                  ))}
                </div>
              </div>

              {/* Theme */}
              <div>
                <label className="flex items-center gap-2 text-sm font-semibold text-slate-700 mb-3">
                  {settings.theme === 'light' ? <Sun className="w-4 h-4 text-amber-600" /> : <Moon className="w-4 h-4 text-indigo-600" />}
                  Theme
                </label>
                <button
                  onClick={() => setSettings({...settings, theme: settings.theme === 'light' ? 'dark' : 'light'})}
                  className="w-full px-4 py-2.5 rounded-lg bg-slate-100 text-slate-700 hover:bg-slate-200 text-sm font-medium transition-all flex items-center justify-center gap-2"
                >
                  {settings.theme === 'light' ? <Moon className="w-4 h-4" /> : <Sun className="w-4 h-4" />}
                  Switch to {settings.theme === 'light' ? 'Dark' : 'Light'} Mode
                </button>
              </div>

              {/* Message Density */}
              <div>
                <label className="flex items-center gap-2 text-sm font-semibold text-slate-700 mb-3">
                  <Maximize2 className="w-4 h-4 text-indigo-600" />
                  Message Density
                </label>
                <div className="flex gap-2">
                  {(['compact', 'normal', 'comfortable'] as const).map((density) => (
                    <button
                      key={density}
                      onClick={() => setSettings({...settings, messageDensity: density})}
                      className={`flex-1 px-2 py-2 rounded-lg text-xs font-medium transition-all ${
                        settings.messageDensity === density
                          ? 'bg-gradient-to-r from-indigo-600 to-indigo-700 text-white shadow-md'
                          : 'bg-slate-100 text-slate-700 hover:bg-slate-200'
                      }`}
                    >
                      {density.charAt(0).toUpperCase() + density.slice(1)}
                    </button>
                  ))}
                </div>
              </div>

              {/* Toggles */}
              <div className="space-y-3 pt-2 border-t border-slate-200">
                <label className="flex items-center justify-between cursor-pointer group p-2 rounded-lg hover:bg-slate-50 transition-all">
                  <span className="text-sm font-medium text-slate-700 flex items-center gap-2">
                    <Sparkles className="w-4 h-4 text-indigo-600" />
                    Auto-scroll
                  </span>
                  <input
                    type="checkbox"
                    checked={settings.autoScroll}
                    onChange={(e) => setSettings({...settings, autoScroll: e.target.checked})}
                    className="w-5 h-5 text-indigo-600 rounded focus:ring-indigo-500 cursor-pointer"
                  />
                </label>
                <label className="flex items-center justify-between cursor-pointer group p-2 rounded-lg hover:bg-slate-50 transition-all">
                  <span className="text-sm font-medium text-slate-700 flex items-center gap-2">
                    {settings.soundNotifications ? <Volume2 className="w-4 h-4 text-indigo-600" /> : <VolumeX className="w-4 h-4 text-slate-400" />}
                    Sound Notifications
                  </span>
                  <input
                    type="checkbox"
                    checked={settings.soundNotifications}
                    onChange={(e) => setSettings({...settings, soundNotifications: e.target.checked})}
                    className="w-5 h-5 text-indigo-600 rounded focus:ring-indigo-500 cursor-pointer"
                  />
                </label>
              </div>

              {/* Session Management */}
              <div className="pt-2 border-t border-slate-200">
                <label className="text-sm font-semibold text-slate-700 mb-3 block flex items-center gap-2">
                  <RefreshCw className="w-4 h-4 text-indigo-600" />
                  Session Management
                </label>
                <button
                  onClick={async () => {
                    if (confirm('Are you sure you want to restart the chat session? This will create a new session, update it in the patient table, and resend all patient data to the AI.')) {
                      setIsLoading(true);
                      try {
                        // Clear current messages
                        setMessages([]);
                        
                        // Restart session (force new session)
                        await initializeChatSession(true);
                        
                        // Show success message
                        const successMessage: Message = {
                          id: `restart_success_${Date.now()}`,
                          speaker: 'ai',
                          speakerName: 'System',
                          speakerRole: 'System',
                          timestamp: new Date().toLocaleString('en-US', { 
                            month: 'short', 
                            day: 'numeric', 
                            year: 'numeric',
                            hour: 'numeric',
                            minute: '2-digit',
                            hour12: true
                          }),
                          content: '✅ Session restarted successfully. New session ID created and all patient data has been resent to the AI.',
                          messageType: 'text',
                          createdAt: Date.now()
                        };
                        
                        // Add success message after a brief delay to show after initial message
                        setTimeout(() => {
                          setMessages(prev => [...prev, successMessage]);
                        }, 500);
                      } catch (error) {
                        console.error('Failed to restart session:', error);
                        const errorMessage: Message = {
                          id: `restart_error_${Date.now()}`,
                          speaker: 'ai',
                          speakerName: 'System',
                          timestamp: new Date().toLocaleString('en-US', { 
                            month: 'short', 
                            day: 'numeric', 
                            year: 'numeric',
                            hour: 'numeric',
                            minute: '2-digit',
                            hour12: true
                          }),
                          content: `❌ Failed to restart session: ${error instanceof Error ? error.message : 'Unknown error'}`,
                          messageType: 'text',
                          createdAt: Date.now()
                        };
                        setMessages(prev => [...prev, errorMessage]);
                      } finally {
                        setIsLoading(false);
                      }
                    }
                  }}
                  className="w-full flex items-center justify-center gap-2 px-4 py-2.5 bg-gradient-to-r from-indigo-100 to-indigo-50 text-indigo-700 rounded-lg hover:from-indigo-200 hover:to-indigo-100 transition-all text-sm font-medium border border-indigo-200"
                >
                  <RefreshCw className="w-4 h-4" />
                  Restart Session
                </button>
                <p className="text-xs text-slate-500 mt-2 text-center">
                  Creates new session, updates BigQuery, and resends patient data
                </p>
              </div>

              {/* Actions */}
              <div className="pt-4 border-t border-slate-200 space-y-2">
                <button
                  onClick={() => {
                    // Create PDF document
                    const doc = new jsPDF();
                    const pageWidth = doc.internal.pageSize.getWidth();
                    const pageHeight = doc.internal.pageSize.getHeight();
                    let yPosition = 20;
                    
                    // Helper function to add a new page if needed
                    const checkPageBreak = (requiredHeight: number) => {
                      if (yPosition + requiredHeight > pageHeight - 20) {
                        doc.addPage();
                        yPosition = 20;
                        return true;
                      }
                      return false;
                    };
                    
                    // Helper function to parse and render markdown text (removes markdown syntax)
                    const addMarkdownText = (text: string, x: number, y: number, maxWidth: number, fontSize: number, startColor: number[] = [0, 0, 0]) => {
                      let currentY = y;
                      let currentX = x;
                      const lineHeight = fontSize * 0.45;
                      const maxX = x + maxWidth;
                      
                      // First, handle explicit line breaks
                      const paragraphs = text.split(' |NEWLINE| ');
                      
                      for (let paraIdx = 0; paraIdx < paragraphs.length; paraIdx++) {
                        let paragraph = paragraphs[paraIdx];
                        
                        // Parse markdown and create segments (markdown syntax will be removed)
                        const segments: Array<{text: string, bold: boolean, italic: boolean, code: boolean, color: number[]}> = [];
                        
                        // Parse markdown using a character-by-character approach to properly remove syntax
                        let i = 0;
                        let currentSegment = {text: '', bold: false, italic: false, code: false, color: startColor};
                        
                        while (i < paragraph.length) {
                          // Check for **bold** (must be at least 4 chars: **x**)
                          if (i + 3 < paragraph.length && paragraph[i] === '*' && paragraph[i + 1] === '*') {
                            const endIndex = paragraph.indexOf('**', i + 2);
                            if (endIndex !== -1) {
                              // Save current segment if it has text
                              if (currentSegment.text) {
                                segments.push({...currentSegment});
                                currentSegment = {text: '', bold: false, italic: false, code: false, color: startColor};
                              }
                              // Extract content (skip the ** delimiters)
                              const content = paragraph.substring(i + 2, endIndex);
                              segments.push({
                                text: content, // Content WITHOUT ** markers
                                bold: true,
                                italic: false,
                                code: false,
                                color: startColor
                              });
                              i = endIndex + 2; // Skip past the closing **
                              continue;
                            }
                          }
                          
                          // Check for `code` (must be at least 2 chars: `x`)
                          if (paragraph[i] === '`') {
                            const endIndex = paragraph.indexOf('`', i + 1);
                            if (endIndex !== -1) {
                              // Save current segment if it has text
                              if (currentSegment.text) {
                                segments.push({...currentSegment});
                                currentSegment = {text: '', bold: false, italic: false, code: false, color: startColor};
                              }
                              // Extract content (skip the ` delimiters)
                              const content = paragraph.substring(i + 1, endIndex);
                              segments.push({
                                text: content, // Content WITHOUT ` markers
                                bold: false,
                                italic: false,
                                code: true,
                                color: [99, 102, 241] // Indigo for code
                              });
                              i = endIndex + 1; // Skip past the closing `
                              continue;
                            }
                          }
                          
                          // Check for *italic* (single asterisk, not part of **)
                          if (paragraph[i] === '*' && 
                              (i === 0 || paragraph[i - 1] !== '*') && 
                              (i + 1 >= paragraph.length || paragraph[i + 1] !== '*')) {
                            const endIndex = paragraph.indexOf('*', i + 1);
                            // Make sure it's not part of **
                            if (endIndex !== -1 && 
                                (endIndex === paragraph.length - 1 || paragraph[endIndex + 1] !== '*') &&
                                (endIndex === i + 1 || paragraph[endIndex - 1] !== '*')) {
                              // Save current segment if it has text
                              if (currentSegment.text) {
                                segments.push({...currentSegment});
                                currentSegment = {text: '', bold: false, italic: false, code: false, color: startColor};
                              }
                              // Extract content (skip the * delimiters)
                              const content = paragraph.substring(i + 1, endIndex);
                              segments.push({
                                text: content, // Content WITHOUT * markers
                                bold: false,
                                italic: true,
                                code: false,
                                color: startColor
                              });
                              i = endIndex + 1; // Skip past the closing *
                              continue;
                            }
                          }
                          
                          // Regular character - add to current segment
                          currentSegment.text += paragraph[i];
                          i++;
                        }
                        
                        // Add remaining segment
                        if (currentSegment.text) {
                          segments.push({...currentSegment});
                        }
                        
                        // If no segments were created, add entire paragraph as normal text
                        if (segments.length === 0) {
                          segments.push({
                            text: paragraph,
                            bold: false,
                            italic: false,
                            code: false,
                            color: startColor
                          });
                        }
                        
                        // Render segments for this paragraph
                        doc.setFontSize(fontSize);
                        
                        // Reset to start of line for new paragraph (except first)
                        if (paraIdx > 0) {
                          currentY += lineHeight;
                          currentX = x;
                          
                          // Check page break
                          if (currentY + lineHeight > pageHeight - 20) {
                            doc.addPage();
                            currentY = 20;
                          }
                        }
                        
                        for (const segment of segments) {
                          if (!segment.text) continue;
                          
                          // Set font style
                          let fontStyle = 'normal';
                          if (segment.bold && segment.italic) {
                            fontStyle = 'bolditalic';
                          } else if (segment.bold) {
                            fontStyle = 'bold';
                          } else if (segment.italic) {
                            fontStyle = 'italic';
                          }
                          doc.setFont('helvetica', fontStyle);
                          
                          // Set color
                          doc.setTextColor(segment.color[0], segment.color[1], segment.color[2]);
                          
                          // Calculate available width
                          const availableWidth = maxX - currentX;
                          
                          // Split text to fit available width
                          const textLines = doc.splitTextToSize(segment.text, availableWidth);
                          
                          for (let lineIdx = 0; lineIdx < textLines.length; lineIdx++) {
                            const line = textLines[lineIdx];
                            const lineWidth = doc.getTextWidth(line);
                            
                            // Check if we need to wrap to next line
                            if (currentX + lineWidth > maxX && currentX > x) {
                              currentY += lineHeight;
                              currentX = x;
                              
                              // Check page break
                              if (currentY + lineHeight > pageHeight - 20) {
                                doc.addPage();
                                currentY = 20;
                              }
                            }
                            
                            doc.text(line, currentX, currentY);
                            currentX += lineWidth;
                            
                            // If there are more lines, move to next line
                            if (lineIdx < textLines.length - 1) {
                              currentY += lineHeight;
                              currentX = x;
                              
                              // Check page break
                              if (currentY + lineHeight > pageHeight - 20) {
                                doc.addPage();
                                currentY = 20;
                              }
                            }
                          }
                        }
                      }
                      
                      // Reset color and font
                      doc.setTextColor(0, 0, 0);
                      doc.setFont('helvetica', 'normal');
                      
                      return currentY - y;
                    };
                    
                    // Header Section - Pretty Medical Header
                    doc.setFillColor(99, 102, 241); // Indigo color
                    doc.rect(0, 0, pageWidth, 50, 'F');
                    
                    // Title
                    doc.setTextColor(255, 255, 255);
                    doc.setFontSize(20);
                    doc.setFont('helvetica', 'bold');
                    doc.text('Clinical Discussion Report', pageWidth / 2, 20, { align: 'center' });
                    
                    // Patient Information
                    doc.setFontSize(12);
                    doc.setFont('helvetica', 'normal');
                    doc.text(`Patient: ${patient.name}`, pageWidth / 2, 30, { align: 'center' });
                    doc.setFontSize(10);
                    doc.text(`${patient.age} years, ${patient.sex} • ${currentVisitId || 'N/A'}`, pageWidth / 2, 37, { align: 'center' });
                    
                    // Export Date/Time
                    const exportDateTime = new Date().toLocaleString('en-US', {
                      year: 'numeric',
                      month: 'long',
                      day: 'numeric',
                      hour: 'numeric',
                      minute: '2-digit',
                      hour12: true
                    });
                    doc.setFontSize(9);
                    doc.text(`Exported: ${exportDateTime}`, pageWidth / 2, 44, { align: 'center' });
                    
                    yPosition = 60;
                    
                    // Reset text color
                    doc.setTextColor(0, 0, 0);
                    
                    // Messages Section
                    doc.setFontSize(14);
                    doc.setFont('helvetica', 'bold');
                    doc.text('Conversation History', 14, yPosition);
                    yPosition += 10;
                    
                    // Draw separator line
                    doc.setDrawColor(200, 200, 200);
                    doc.line(14, yPosition, pageWidth - 14, yPosition);
                    yPosition += 8;
                    
                    // Process each message
                    messages.forEach((message, index) => {
                      checkPageBreak(40);
                      
                      const isAI = message.speaker === 'ai';
                      const isDoctor = !isAI;
                      
                      // Message Header
                      doc.setFontSize(11);
                      doc.setFont('helvetica', 'bold');
                      doc.setTextColor(isAI ? 99 : 51, isAI ? 102 : 51, isAI ? 241 : 51); // Indigo for AI, dark gray for doctor
                      doc.text(`${isAI ? 'AI Clinical Assistant' : message.speakerName}`, 14, yPosition);
                      
                      // Timestamp
                      doc.setFontSize(9);
                      doc.setFont('helvetica', 'normal');
                      doc.setTextColor(128, 128, 128);
                      doc.text(message.timestamp, pageWidth - 14, yPosition, { align: 'right' });
                      yPosition += 6;
                      
                      // Message Type Badge (for AI)
                      if (isAI && message.messageType !== 'text') {
                        doc.setFontSize(8);
                        doc.setFont('helvetica', 'italic');
                        doc.setTextColor(99, 102, 241);
                        doc.text(`[${message.messageType === 'explanation' ? 'AI Explanation' : message.messageType === 'data-reference' ? 'Data Reference' : 'AI Suggestion'}]`, 14, yPosition);
                        yPosition += 5;
                      }
                      
                      // Request/Response Label
                      doc.setFontSize(9);
                      doc.setFont('helvetica', 'bold');
                      doc.setTextColor(0, 0, 0);
                      if (isDoctor) {
                        doc.text('Request:', 14, yPosition);
                      } else {
                        doc.text('Response:', 14, yPosition);
                      }
                      yPosition += 5;
                      
                      // Message Content with Markdown Support
                      doc.setFontSize(10);
                      doc.setFont('helvetica', 'normal');
                      doc.setTextColor(0, 0, 0);
                      
                      // Handle line breaks - replace \n with marker
                      const content = (message.content || '(No content)').replace(/\n/g, ' |NEWLINE| ');
                      const contentHeight = addMarkdownText(
                        content,
                        14,
                        yPosition,
                        pageWidth - 28,
                        10,
                        [0, 0, 0]
                      );
                      
                      yPosition += Math.max(contentHeight, 10) + 8;
                      
                      // Add separator between messages
                      if (index < messages.length - 1) {
                        doc.setDrawColor(230, 230, 230);
                        doc.line(14, yPosition, pageWidth - 14, yPosition);
                        yPosition += 5;
                      }
                    });
                    
                    // Footer
                    const totalPages = doc.getNumberOfPages();
                    for (let i = 1; i <= totalPages; i++) {
                      doc.setPage(i);
                      doc.setFontSize(8);
                      doc.setTextColor(128, 128, 128);
                      doc.text(
                        `Page ${i} of ${totalPages} • TwinCare Clinical Discussion Report`,
                        pageWidth / 2,
                        pageHeight - 10,
                        { align: 'center' }
                      );
                    }
                    
                    // Save PDF
                    const fileName = `clinical-discussion-${patient.name.replace(/\s+/g, '-')}-${Date.now()}.pdf`;
                    doc.save(fileName);
                  }}
                  className="w-full flex items-center justify-center gap-2 px-4 py-2.5 bg-gradient-to-r from-indigo-100 to-indigo-50 text-indigo-700 rounded-lg hover:from-indigo-200 hover:to-indigo-100 transition-all text-sm font-medium border border-indigo-200"
                >
                  <Download className="w-4 h-4" />
                  Export as PDF
                </button>
                <button
                  onClick={() => {
                    if (confirm('Are you sure you want to clear all messages? This action cannot be undone.')) {
                      setMessages([]);
                    }
                  }}
                  className="w-full flex items-center justify-center gap-2 px-4 py-2.5 bg-gradient-to-r from-red-50 to-red-100 text-red-700 rounded-lg hover:from-red-100 hover:to-red-200 transition-all text-sm font-medium border border-red-200"
                >
                  <Trash2 className="w-4 h-4" />
                  Clear Chat
                </button>
              </div>
            </div>
          </div>
        )}

        {/* Input Area - Medical professional styling */}
        <div className={`border-t flex-shrink-0 ${settings.theme === 'dark' ? 'border-slate-700 bg-slate-800' : 'border-slate-200 bg-white'} ${onClose ? 'px-4 sm:px-6 py-3 sm:py-4' : 'px-4 sm:px-6 py-3 sm:py-4'}`}>
          <form onSubmit={handleSubmit} className="flex gap-2 sm:gap-3 items-end">
            <div className="flex-1 relative min-w-0">
              <input
                type="text"
                value={newMessage}
                onChange={(e) => setNewMessage(e.target.value)}
                placeholder="Ask about patient condition, request analysis, or discuss treatment options..."
                className={`w-full px-3 sm:px-4 py-2 sm:py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500/50 focus:border-indigo-500 text-xs sm:text-sm transition-all ${
                  settings.theme === 'dark' 
                    ? 'bg-slate-700 border-slate-600 text-slate-100 placeholder-slate-400 hover:border-slate-500' 
                    : 'bg-white border-slate-300 hover:border-slate-400'
                }`}
                disabled={isLoading}
              />
            </div>
            <button
              type="submit"
              disabled={isLoading || !newMessage.trim()}
              className="px-4 sm:px-5 py-2 sm:py-3 bg-indigo-600 text-white font-medium rounded-lg transition-all hover:bg-indigo-700 disabled:opacity-50 disabled:cursor-not-allowed disabled:bg-indigo-400 flex items-center gap-1 sm:gap-2 text-xs sm:text-sm shadow-sm hover:shadow-md flex-shrink-0"
            >
              {isLoading ? (
                <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
              ) : (
                <>
                  <Send className="w-4 h-4" />
                  <span className="hidden sm:inline">Send</span>
                </>
              )}
            </button>
          </form>
          <div className={`text-xs mt-2 sm:mt-3 text-center ${settings.theme === 'dark' ? 'text-slate-400' : 'text-slate-500'}`}>
            Messages are ephemeral and private • Not saved to patient record
          </div>
        </div>
      </div>
    </div>
  );
}
