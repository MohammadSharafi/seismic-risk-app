import { useState, useEffect, useCallback } from 'react';
import {
  load,
  save,
  createThread as createThreadReducer,
  selectThread as selectThreadReducer,
  addMessage as addMessageReducer,
  setThreadMessages as setThreadMessagesReducer,
  deleteThread as deleteThreadReducer,
  renameThread as renameThreadReducer,
  renameThreadFromFirstMessage as renameThreadFromFirstMessageReducer,
  updateThreadPatient as updateThreadPatientReducer,
  getMessagesForThread,
  getVisibleThreads,
  getThreadsByPatient,
  getCurrentThread,
  type ThreadState,
  type ThreadItem,
  type MessageWithDate,
  type PatientInfo,
} from '../services/threadService';

export interface UseThreadsReturn {
  // State
  threads: ThreadItem[];
  visibleThreads: ThreadItem[];
  threadsByPatient: { patientLabel: string; threads: ThreadItem[] }[];
  currentThreadId: string;
  currentThread: ThreadItem | undefined;
  messages: MessageWithDate[];

  // Actions
  createThread: (opts?: { patientName?: string; patientId?: string }) => void;
  selectThread: (threadId: string) => void;
  addMessage: (threadId: string, msg: MessageWithDate) => void;
  setThreadMessages: (threadId: string, messages: MessageWithDate[]) => void;
  deleteThread: (threadId: string) => void;
  renameThread: (threadId: string, title: string) => void;
  renameThreadFromFirstMessage: (threadId: string, firstUserContent: string) => void;
  updateThreadPatient: (threadId: string, patient: PatientInfo) => void;
}

export function useThreads(): UseThreadsReturn {
  const [state, setState] = useState<ThreadState>(load);

  useEffect(() => {
    save(state);
  }, [state]);

  const createThread = useCallback((opts?: { patientName?: string; patientId?: string }) => {
    setState((s) => createThreadReducer(s, opts ?? {}));
  }, []);

  const selectThread = useCallback((threadId: string) => {
    setState((s) => selectThreadReducer(s, threadId));
  }, []);

  const addMessage = useCallback((threadId: string, msg: MessageWithDate) => {
    setState((s) => addMessageReducer(s, threadId, msg));
  }, []);

  const setThreadMessages = useCallback((threadId: string, messages: MessageWithDate[]) => {
    setState((s) => setThreadMessagesReducer(s, threadId, messages));
  }, []);

  const deleteThread = useCallback((threadId: string) => {
    setState((s) => deleteThreadReducer(s, threadId));
  }, []);

  const renameThread = useCallback((threadId: string, title: string) => {
    setState((s) => renameThreadReducer(s, threadId, title));
  }, []);

  const renameThreadFromFirstMessage = useCallback((threadId: string, firstUserContent: string) => {
    setState((s) => renameThreadFromFirstMessageReducer(s, threadId, firstUserContent));
  }, []);

  const updateThreadPatient = useCallback((threadId: string, patient: PatientInfo) => {
    setState((s) => updateThreadPatientReducer(s, threadId, patient));
  }, []);

  const messages = getMessagesForThread(state, state.currentThreadId);
  const visibleThreads = getVisibleThreads(state);
  const threadsByPatient = getThreadsByPatient(state);
  const currentThread = getCurrentThread(state);

  return {
    threads: state.threads,
    visibleThreads,
    threadsByPatient,
    currentThreadId: state.currentThreadId,
    currentThread,
    messages,
    createThread,
    selectThread,
    addMessage,
    setThreadMessages,
    deleteThread,
    renameThread,
    renameThreadFromFirstMessage,
    updateThreadPatient,
  };
}
