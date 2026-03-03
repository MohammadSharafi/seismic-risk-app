import { useState, useEffect, useCallback, useRef } from 'react';
import { getTrafficInspectorMode, getTrafficStreamUrl } from '../api/trafficInspectorApi';
import type {
  TrafficInspectorEvent,
  TrafficInspectorNode,
  TrafficInspectorEdge,
  TrafficStreamMessage,
} from '../types/trafficInspector';

const MAX_EVENTS = 1000;

/** Normalize backend event payload so the UI always has the expected shape. */
function normalizeEvent(payload: unknown): TrafficInspectorEvent {
  const p = payload && typeof payload === 'object' ? (payload as Record<string, unknown>) : {};
  const statusCode = typeof p.statusCode === 'number' ? p.statusCode : (p.statusCode != null ? Number(p.statusCode) : 200);
  const status = statusCode >= 200 && statusCode < 400 ? 'ok' : 'error';
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

export interface TrafficInspectorStreamState {
  events: TrafficInspectorEvent[];
  nodes: TrafficInspectorNode[];
  edges: TrafficInspectorEdge[];
  status: 'disconnected' | 'connecting' | 'connected' | 'error';
  error: string | null;
  paused: boolean;
  lastTopologyAt: string | null;
}

export function useTrafficInspectorStream(filter?: string) {
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
    const mode = getTrafficInspectorMode();
    if (mode === 'march') {
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
          // Auto-reconnect so events show up if backend was down when page opened
          if (mountedRef.current && getTrafficStreamUrl()) {
            reconnectTimeoutRef.current = setTimeout(() => connect(), 3000);
          }
        }
      };
      ws.onerror = () => {
        setError(null);
      };
      ws.onmessage = (ev) => {
        try {
          const msg = JSON.parse(ev.data) as TrafficStreamMessage;
          if (msg.type === 'event') {
            if (!pausedRef.current && msg.payload != null) {
              setEvents((prev) => {
                const next = [normalizeEvent(msg.payload), ...prev].slice(0, MAX_EVENTS);
                return next;
              });
            }
          } else if (msg.type === 'topology') {
            setNodes(msg.payload.nodes ?? []);
            setEdges(msg.payload.edges ?? []);
            setLastTopologyAt(msg.payload.updatedAt ?? new Date().toISOString());
          }
        } catch (_) {
          // ignore parse errors
        }
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

  useEffect(() => {
    mountedRef.current = true;
    connect();
    return () => {
      mountedRef.current = false;
      disconnect();
    };
  }, [connect, disconnect]);

  const clearEvents = useCallback(() => setEvents([]), []);

  return {
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
  };
}
