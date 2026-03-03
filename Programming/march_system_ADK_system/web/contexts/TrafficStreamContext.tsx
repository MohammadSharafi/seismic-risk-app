import React, { createContext, useCallback, useContext, useRef, useState } from 'react';
import { getTrafficInspectorMode, getTrafficStreamUrl, marchSseToTrafficEvent } from '../api/trafficInspectorApi';
import type {
  TrafficInspectorEvent,
  TrafficInspectorNode,
  TrafficInspectorEdge,
  TrafficStreamMessage,
} from '../types/trafficInspector';

const MAX_EVENTS = 1000;

const spanSeq = { next: 0 };

function normalizeEvent(payload: unknown): TrafficInspectorEvent {
  const p = payload && typeof payload === 'object' ? (payload as Record<string, unknown>) : {};
  const statusCode = typeof p.statusCode === 'number' ? p.statusCode : (p.statusCode != null ? Number(p.statusCode) : 200);
  const status = statusCode >= 200 && statusCode < 400 ? 'ok' : 'error';
  // Use only the backend's event id so GET /v1/admin/traffic/events/:id finds it. Never generate a random id.
  const id = typeof p.id === 'string' ? p.id : (p.traceId != null && p.spanId != null ? `trace:${p.traceId}:${p.spanId}` : '');
  return {
    id,
    traceId: typeof p.traceId === 'string' ? p.traceId : String(p.traceId ?? ''),
    spanId: typeof p.spanId === 'string' ? p.spanId : String(p.spanId ?? ''),
    timestamp: typeof p.timestamp === 'string' ? p.timestamp : new Date().toISOString(),
    source: typeof p.source === 'string' ? p.source : String(p.source ?? 'client'),
    destination: typeof p.destination === 'string' ? p.destination : String(p.destination ?? 'command-api'),
    protocol: (p.protocol === 'HTTP' || p.protocol === 'gRPC' || p.protocol === 'WS' || p.protocol === 'DB' || p.protocol === 'Queue' || p.protocol === 'Internal') ? p.protocol : 'HTTP',
    endpoint: p.endpoint != null ? String(p.endpoint) : undefined,
    method: p.method != null ? String(p.method) : undefined,
    statusCode,
    status: (p.status === 'ok' || p.status === 'error' || p.status === 'timeout') ? p.status : status,
    latencyMs: typeof p.latencyMs === 'number' ? p.latencyMs : (p.latencyMs != null ? Number(p.latencyMs) : 0),
    requestSizeBytes: p.requestSizeBytes != null ? Number(p.requestSizeBytes) : undefined,
    responseSizeBytes: p.responseSizeBytes != null ? Number(p.responseSizeBytes) : undefined,
  };
}

export interface TrafficStreamContextValue {
  events: TrafficInspectorEvent[];
  nodes: TrafficInspectorNode[];
  edges: TrafficInspectorEdge[];
  status: 'disconnected' | 'connecting' | 'connected' | 'error';
  error: string | null;
  paused: boolean;
  setPaused: (paused: boolean) => void;
  lastTopologyAt: string | null;
  connect: () => void;
  disconnect: () => void;
  clearEvents: () => void;
  /** Push March chat SSE event into the Request stream (March mode only). */
  pushMarchSseEvent: (payload: { event?: string; data?: Record<string, unknown>; id?: number }, runId: string) => void;
}

const TrafficStreamContext = createContext<TrafficStreamContextValue | null>(null);

export function TrafficStreamProvider({ children }: { children: React.ReactNode }) {
  const [events, setEvents] = useState<TrafficInspectorEvent[]>([]);
  const [nodes, setNodes] = useState<TrafficInspectorNode[]>([]);
  const [edges, setEdges] = useState<TrafficInspectorEdge[]>([]);
  const [status, setStatus] = useState<'disconnected' | 'connecting' | 'connected' | 'error'>('disconnected');
  const [error, setError] = useState<string | null>(null);
  const [paused, setPaused] = useState(false);
  const [lastTopologyAt, setLastTopologyAt] = useState<string | null>(null);
  const wsRef = useRef<WebSocket | null>(null);
  const pausedRef = useRef(false);
  const reconnectTimeoutRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const mountedRef = useRef(true);
  pausedRef.current = paused;

  const connect = useCallback(() => {
    if (wsRef.current != null) return; // already connected or connecting
    const mode = getTrafficInspectorMode();
    if (mode === 'march') {
      // March backend currently has no admin websocket stream; keep inspector active
      // in topology mode instead of showing a hard error.
      setStatus('connected');
      setError(null);
      return;
    }
    const url = getTrafficStreamUrl();
    if (!url) {
      setStatus('disconnected');
      setError('Traffic stream URL not configured. Set VITE_MARCH_API_URL or VITE_COMMAND_API_URL.');
      return;
    }
    if (reconnectTimeoutRef.current) {
      clearTimeout(reconnectTimeoutRef.current);
      reconnectTimeoutRef.current = null;
    }
    setStatus('connecting');
    setError(null);
    try {
      const ws = new WebSocket(url);
      wsRef.current = ws;
      ws.onopen = () => {
        setStatus('connected');
        setError(null);
      };
      ws.onclose = () => {
        if (wsRef.current === ws) {
          wsRef.current = null;
          setStatus('disconnected');
          setError(null);
          if (mountedRef.current && getTrafficStreamUrl()) {
            reconnectTimeoutRef.current = setTimeout(() => connect(), 3000);
          }
        }
      };
      ws.onerror = () => setError(null);
      ws.onmessage = (ev: MessageEvent) => {
        try {
          const msg = JSON.parse(ev.data) as TrafficStreamMessage;
          if (msg.type === 'event') {
            if (!pausedRef.current && msg.payload != null) {
              setEvents((prev) => [normalizeEvent(msg.payload), ...prev].slice(0, MAX_EVENTS));
            }
          } else if (msg.type === 'topology') {
            setNodes(msg.payload.nodes ?? []);
            setEdges(msg.payload.edges ?? []);
            setLastTopologyAt(msg.payload.updatedAt ?? new Date().toISOString());
          }
        } catch (_) {}
      };
    } catch (e) {
      setStatus('disconnected');
      setError(e instanceof Error ? e.message : 'Failed to connect');
      if (mountedRef.current && getTrafficStreamUrl()) {
        reconnectTimeoutRef.current = setTimeout(() => connect(), 3000);
      }
    }
  }, []);

  const disconnect = useCallback(() => {
    if (reconnectTimeoutRef.current) {
      clearTimeout(reconnectTimeoutRef.current);
      reconnectTimeoutRef.current = null;
    }
    if (wsRef.current) {
      wsRef.current.close();
      wsRef.current = null;
    }
    setStatus('disconnected');
    setError(null);
  }, []);

  const clearEvents = useCallback(() => setEvents([]), []);

  const pushMarchSseEvent = useCallback(
    (payload: { event?: string; data?: Record<string, unknown>; id?: number }, runId: string) => {
      if (getTrafficInspectorMode() !== 'march') return;
      if (pausedRef.current) return;
      const ev = marchSseToTrafficEvent(payload, runId, spanSeq);
      if (ev) {
        setEvents((prev) => [ev, ...prev].slice(0, MAX_EVENTS));
      }
    },
    []
  );

  React.useEffect(() => {
    mountedRef.current = true;
    return () => {
      mountedRef.current = false;
      disconnect();
    };
  }, [disconnect]);

  const value: TrafficStreamContextValue = {
    events,
    nodes,
    edges,
    status,
    error,
    paused,
    setPaused,
    lastTopologyAt,
    connect,
    disconnect,
    clearEvents,
    pushMarchSseEvent,
  };

  return (
    <TrafficStreamContext.Provider value={value}>
      {children}
    </TrafficStreamContext.Provider>
  );
}

export function useTrafficStream(): TrafficStreamContextValue {
  const ctx = useContext(TrafficStreamContext);
  if (!ctx) throw new Error('useTrafficStream must be used within TrafficStreamProvider');
  return ctx;
}

export function useTrafficStreamOptional(): TrafficStreamContextValue | null {
  return useContext(TrafficStreamContext);
}
