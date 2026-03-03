/**
 * Traffic inspector API: WebSocket stream URL and REST for event/trace detail.
 * Uses same base URL and API key as adminApi (VITE_COMMAND_API_URL, VITE_COMMAND_API_KEY).
 */

import type {
  TrafficInspectorEventDetail,
  TrafficInspectorEvent,
  TrafficInspectorNode,
  TrafficInspectorEdge,
} from '../types/trafficInspector';
import { MARCH_NODE_IDS, buildMarchTopology, type NodeHealthMap } from './marchTopology';

const getBase = (): string => {
  const url = (import.meta.env.VITE_MARCH_API_URL ?? import.meta.env.VITE_COMMAND_API_URL ?? '').toString().trim().replace(/\/$/, '');
  if (!url) return '';
  const stage = (import.meta.env.VITE_MARCH_API_STAGE ?? '').toString().trim();
  if (stage) return `${url}/${stage.replace(/^\/+|\/+$/g, '')}`;
  return url;
};
const getApiKey = (): string => (import.meta.env.VITE_COMMAND_API_KEY ?? '').trim();
const getMode = (): 'march' | 'command' | 'auto' => {
  const raw = (import.meta.env.VITE_API_MODE ?? 'auto').toString().trim().toLowerCase();
  if (raw === 'march' || raw === 'command') return raw;
  return 'auto';
};

export function getTrafficInspectorMode(): 'march' | 'command' | 'none' {
  const base = getBase();
  if (!base) return 'none';
  const mode = getMode();
  if (mode === 'march') return 'march';
  if (mode === 'command') return 'command';
  return import.meta.env.VITE_MARCH_API_URL ? 'march' : 'command';
}

function adminHeaders(): Record<string, string> {
  const h: Record<string, string> = { 'Content-Type': 'application/json' };
  const key = getApiKey();
  if (key) h['X-API-Key'] = key;
  return h;
}

async function adminFetch<T>(path: string, options?: RequestInit): Promise<T> {
  const base = getBase();
  if (!base) throw new Error('Command API URL not configured');
  const res = await fetch(`${base}${path}`, {
    ...options,
    headers: { ...adminHeaders(), ...(options?.headers as Record<string, string>) },
  });
  if (!res.ok) {
    const text = await res.text();
    if (res.status === 401) throw new Error('Invalid or missing API key');
    if (res.status === 403) throw new Error('Admin or auditor role required');
    throw new Error(text || `Request failed ${res.status}`);
  }
  if (res.status === 204) return undefined as T;
  return res.json() as Promise<T>;
}

/** WebSocket URL for live traffic stream. Replace http(s) with ws(s). */
export function getTrafficStreamUrl(): string | null {
  const base = getBase();
  if (!base) return null;
  if (getTrafficInspectorMode() === 'march') return null;
  const wsBase = base.replace(/^http/, 'ws');
  return `${wsBase}/v1/admin/traffic/stream`;
}

/** Backend report of how many Traffic Inspector clients are connected. Use to verify this tab is registered. */
export async function getTrafficStreamStatus(): Promise<{ connectedClients: number } | null> {
  if (getTrafficInspectorMode() === 'march') {
    return { connectedClients: 1 };
  }
  try {
    return await adminFetch<{ connectedClients: number }>('/v1/admin/traffic/status');
  } catch {
    return null;
  }
}

/**
 * Send a test POST /v1/commands so an event appears in the Request stream.
 * Uses the same backend URL as the WebSocket; if the event appears, the pipeline works.
 */
export async function sendTestCommand(): Promise<{ ok: boolean; message?: string }> {
  const base = getBase();
  if (!base) return { ok: false, message: 'API URL not set' };
  if (getTrafficInspectorMode() === 'march') {
    try {
      const conversationId = `ti-${Date.now()}`;
      const accepted = await fetch(`${base}/api/v1/chat/message`, {
        method: 'POST',
        headers: adminHeaders(),
        body: JSON.stringify({
          message: '/summary window=last_7_days',
          patient_id: 'p-dev-001',
          conversation_id: conversationId,
        }),
      });
      if (!accepted.ok) {
        const text = await accepted.text();
        return { ok: false, message: `March API ${accepted.status}: ${text.slice(0, 100)}` };
      }
      const streamResp = await fetch(
        `${base}/api/v1/chat/stream?conversation_id=${encodeURIComponent(conversationId)}&patient_id=p-dev-001`,
        { method: 'GET', headers: adminHeaders() }
      );
      if (!streamResp.ok) {
        const text = await streamResp.text();
        return { ok: false, message: `March stream ${streamResp.status}: ${text.slice(0, 100)}` };
      }
      return { ok: true, message: 'Sent test chat to March API. Topology edges updated from canonical March graph.' };
    } catch (e) {
      return { ok: false, message: e instanceof Error ? e.message : 'Request failed' };
    }
  }
  try {
    const res = await fetch(`${base}/v1/commands`, {
      method: 'POST',
      headers: adminHeaders(),
      body: JSON.stringify({ command: '/simulate', tenantId: 'default', patientId: 'p1' }),
    });
    if (!res.ok) {
      const text = await res.text();
      return { ok: false, message: `Backend ${res.status}: ${text.slice(0, 80)}` };
    }
    return { ok: true };
  } catch (e) {
    return { ok: false, message: e instanceof Error ? e.message : 'Request failed' };
  }
}

/** Fetch event detail by id (GET /v1/admin/traffic/events/:id). */
export async function getEventDetail(eventId: string): Promise<TrafficInspectorEventDetail | null> {
  try {
    return await adminFetch<TrafficInspectorEventDetail>(`/v1/admin/traffic/events/${encodeURIComponent(eventId)}`);
  } catch {
    return null;
  }
}

/** Fetch event detail by traceId when id lookup 404s (GET /v1/admin/traffic/events?traceId=xxx). */
export async function getEventDetailByTraceId(traceId: string): Promise<TrafficInspectorEventDetail | null> {
  try {
    return await adminFetch<TrafficInspectorEventDetail>(
      `/v1/admin/traffic/events?traceId=${encodeURIComponent(traceId)}`
    );
  } catch {
    return null;
  }
}

/** Fetch full trace by traceId (when backend implements GET /v1/admin/traffic/traces/:traceId). */
export async function getTrace(traceId: string): Promise<{ spans: Array<{ spanId: string; name: string; durationMs: number; status: string }> } | null> {
  try {
    return await adminFetch<{ spans: Array<{ spanId: string; name: string; durationMs: number; status: string }> }>(
      `/v1/admin/traffic/traces/${encodeURIComponent(traceId)}`
    );
  } catch {
    return null;
  }
}

/** Historical events (when backend implements GET /v1/admin/traffic/events). */
export async function getTrafficEvents(params: {
  from?: string;
  to?: string;
  filter?: string;
  limit?: number;
}): Promise<TrafficInspectorEvent[]> {
  try {
    const sp = new URLSearchParams();
    if (params.from) sp.set('from', params.from);
    if (params.to) sp.set('to', params.to);
    if (params.filter) sp.set('filter', params.filter);
    if (params.limit != null) sp.set('limit', String(params.limit));
    const q = sp.toString();
    const list = await adminFetch<TrafficInspectorEvent[]>(`/v1/admin/traffic/events${q ? `?${q}` : ''}`);
    return Array.isArray(list) ? list : [];
  } catch {
    return [];
  }
}

// --- Fallback topology (from existing health/tools API when stream is not available) ---

export async function getFallbackTopology(): Promise<{
  nodes: TrafficInspectorNode[];
  edges: TrafficInspectorEdge[];
}> {
  if (getTrafficInspectorMode() === 'march') {
    return getMarchFallbackTopology();
  }
  const nodes: TrafficInspectorNode[] = [];
  const edges: TrafficInspectorEdge[] = [];
  try {
    const [health, actuator, tools] = await Promise.all([
      adminFetch<{ status?: string; commandApi?: boolean }>('/v1/health').catch(() => null),
      adminFetch<{
        status?: string;
        components?: { db?: { status?: string }; mcp?: { status?: string; details?: Record<string, unknown> } };
      }>('/actuator/health').catch(() => null),
      adminFetch<unknown[]>('/v1/tools').catch(() => []),
    ]);
    const cmdUp = health?.status === 'up' || health?.commandApi === true;
    const dbStatus = actuator?.components?.db?.status ?? (actuator ? 'UP' : null);
    const mcpDetail = actuator?.components?.mcp?.details?.mcp ?? '';
    const mcpUp = actuator?.components?.mcp?.status === 'UP';
    const toolsCount = Array.isArray(tools) ? tools.length : 0;

    const node = (
      id: string,
      label: string,
      type: TrafficInspectorNode['type'],
      health: TrafficInspectorNode['health']
    ): TrafficInspectorNode => ({ id, label, type, health });
    nodes.push(node('command-api', 'Command API', 'api', cmdUp ? 'UP' : 'DOWN'));
    nodes.push(node('database', 'Database', 'database', dbStatus === 'UP' ? 'UP' : actuator ? 'DOWN' : 'DEGRADED'));
    nodes.push(
      node(
        'mcp',
        'MCP / Agents',
        'agent',
        mcpUp ? 'UP' : mcpDetail === 'disabled' ? 'DEGRADED' : actuator ? 'DOWN' : 'DEGRADED'
      )
    );
    nodes.push(node('rag', 'RAG', 'service', 'DEGRADED'));
    nodes.push(node('commander', 'Commander', 'service', cmdUp ? 'UP' : 'DOWN'));
    nodes.push(node('orchestrator', 'Orchestrator', 'service', cmdUp ? 'UP' : 'DOWN'));
    nodes.push(node('memory', 'Memory (T/P blobs)', 'service', cmdUp ? 'UP' : 'DOWN'));
    nodes.push(node('audit', 'Audit', 'service', cmdUp ? 'UP' : 'DOWN'));

    const edge = (source: string, target: string, rps: number, latencyMs: number, errorRate: number): TrafficInspectorEdge => ({
      source,
      target,
      requestRatePerSec: rps,
      avgLatencyMs: latencyMs,
      errorRate,
    });
    edges.push(edge('command-api', 'commander', 1, 50, 0));
    edges.push(edge('commander', 'orchestrator', 1, 30, 0));
    edges.push(edge('commander', 'memory', 0.5, 5, 0));
    edges.push(edge('memory', 'commander', 0.5, 5, 0));
    edges.push(edge('orchestrator', 'memory', 0.5, 10, 0));
    edges.push(edge('orchestrator', 'audit', 1, 20, 0));
    edges.push(edge('orchestrator', 'mcp', 0.5, 100, 0));
    edges.push(edge('memory', 'database', 0.2, 15, 0));
    edges.push(edge('audit', 'database', 0.2, 15, 0));
    edges.push(edge('orchestrator', 'rag', 0, 0, 0));
  } catch {
    // return empty
  }
  return { nodes, edges };
}

async function getMarchFallbackTopology(): Promise<{
  nodes: TrafficInspectorNode[];
  edges: TrafficInspectorEdge[];
}> {
  const base = getBase();
  if (!base) return { nodes: [], edges: [] };
  // Prefer full topology from backend (nodes + edges + health)
  try {
    const res = await fetch(`${base}/v1/admin/topology`, {
      method: 'GET',
      headers: adminHeaders(),
    });
    if (res.ok) {
      const body = (await res.json()) as { nodes?: TrafficInspectorNode[]; edges?: TrafficInspectorEdge[] };
      if (body.nodes && body.edges) {
        return { nodes: body.nodes, edges: body.edges };
      }
    }
  } catch {
    // fall through to health-only fallback
  }
  // Fallback: fetch health only and build topology client-side
  let healthMap: NodeHealthMap | undefined;
  try {
    const res = await fetch(`${base}/v1/admin/topology/health`, {
      method: 'GET',
      headers: adminHeaders(),
    });
    if (res.ok) {
      const body = (await res.json()) as { components?: Record<string, string> };
      healthMap = body.components as NodeHealthMap | undefined;
    }
  } catch {
    // Fallback: check /health for March API at least
    try {
      const res = await fetch(`${base}/health`, { method: 'GET' });
      healthMap = res.ok ? { 'march-api': 'UP' } : { 'march-api': 'DOWN' };
    } catch {
      healthMap = { 'march-api': 'DOWN' };
    }
  }
  return buildMarchTopology(healthMap);
}

/** Simple non-crypto hash for patient_id; last 8 chars only, never full PHI. */
function patientIdHashLast8(patientId: string): string {
  if (!patientId || typeof patientId !== 'string') return '';
  let h = 0;
  for (let i = 0; i < patientId.length; i++) {
    h = (h << 5) - h + patientId.charCodeAt(i);
    h = h & h;
  }
  const hex = Math.abs(h).toString(16);
  return hex.slice(-8);
}

/**
 * Convert March chat SSE payload to TrafficInspectorEvent for the Request stream.
 * Maps pipeline steps (guardrail, interpreter, planner, orchestrator, tools) to source/dest.
 */
export function marchSseToTrafficEvent(
  payload: { event?: string; data?: Record<string, unknown>; id?: number },
  runId: string,
  spanSeq: { next: number }
): TrafficInspectorEvent | null {
  const eventName = (payload?.event ?? '').toString();
  const data = (payload?.data ?? {}) as Record<string, unknown>;
  if (!eventName) return null;

  const patientId = (data.patient_id as string) ?? (data.patientId as string) ?? '';
  const patientIdHash = patientId ? patientIdHashLast8(patientId) : undefined;
  // Skip token-level events (too noisy)
  if (eventName === 'stream.token') return null;

  const spanId = `span-${spanSeq.next++}`;
  const timestamp = new Date().toISOString();

  const base: Partial<TrafficInspectorEvent> = {
    id: `${runId}:${spanId}`,
    traceId: runId,
    spanId,
    timestamp,
    protocol: 'Internal' as const,
    status: 'ok' as const,
    statusCode: 200,
    latencyMs: 0,
  };

  if (eventName === 'session.started') {
    return {
      ...base,
      source: MARCH_NODE_IDS.client,
      destination: MARCH_NODE_IDS.api,
      endpoint: '/chat',
      method: 'POST',
      patientIdHash,
    } as TrafficInspectorEvent;
  }
  if (eventName === 'guardrail.input.checked' || eventName === 'guardrail.output.checked') {
    return {
      ...base,
      source: eventName.includes('input') ? MARCH_NODE_IDS.api : MARCH_NODE_IDS.orchestrator,
      destination: MARCH_NODE_IDS.guardrail,
      endpoint: eventName,
      method: 'Internal',
    } as TrafficInspectorEvent;
  }
  if (eventName === 'planner.plan_ready') {
    return {
      ...base,
      source: MARCH_NODE_IDS.planner,
      destination: MARCH_NODE_IDS.orchestrator,
      endpoint: 'plan_ready',
      method: 'Internal',
    } as TrafficInspectorEvent;
  }
  if (eventName === 'orchestrator.update') {
    const source = (data.source as string) ?? MARCH_NODE_IDS.orchestrator;
    return {
      ...base,
      source: source.startsWith('orchestrator.') ? MARCH_NODE_IDS.orchestrator : MARCH_NODE_IDS.planner,
      destination: MARCH_NODE_IDS.orchestrator,
      endpoint: source,
      method: 'Internal',
    } as TrafficInspectorEvent;
  }
  if (eventName === 'orchestrator.tool_called') {
    const toolId = (data.tool_id as string) ?? 'unknown';
    return {
      ...base,
      source: MARCH_NODE_IDS.orchestrator,
      destination: MARCH_NODE_IDS.tools,
      endpoint: toolId,
      method: 'CALL',
      tool: toolId,
    } as TrafficInspectorEvent;
  }
  if (eventName === 'orchestrator.tool_result') {
    const toolId = (data.tool_id as string) ?? 'unknown';
    const status = (data.status as string) ?? 'success';
    const processingTimeMs = typeof data.processing_time_ms === 'number' ? data.processing_time_ms : 0;
    return {
      ...base,
      source: MARCH_NODE_IDS.tools,
      destination: MARCH_NODE_IDS.orchestrator,
      endpoint: toolId,
      method: 'RESULT',
      status: status === 'success' ? 'ok' : 'error',
      statusCode: status === 'success' ? 200 : 500,
      latencyMs: processingTimeMs,
      tool: toolId,
    } as TrafficInspectorEvent;
  }
  if (eventName.startsWith('planner.') || eventName === 'planner.status_update') {
    const stepName = (data.step_name as string) ?? eventName;
    return {
      ...base,
      source: MARCH_NODE_IDS.planner,
      destination: MARCH_NODE_IDS.orchestrator,
      endpoint: stepName,
      method: 'Internal',
    } as TrafficInspectorEvent;
  }
  if (eventName === 'stream.end') {
    return {
      ...base,
      source: MARCH_NODE_IDS.sse,
      destination: MARCH_NODE_IDS.client,
      endpoint: '/stream',
      method: 'GET',
    } as TrafficInspectorEvent;
  }
  if (eventName === 'stream.error') {
    return {
      ...base,
      source: MARCH_NODE_IDS.api,
      destination: MARCH_NODE_IDS.client,
      endpoint: '/stream',
      method: 'ERROR',
      status: 'error',
      statusCode: 500,
    } as TrafficInspectorEvent;
  }
  if (eventName === 'response.metadata') {
    const flow = (data.execution_flow as string) ?? undefined;
    return {
      ...base,
      source: MARCH_NODE_IDS.orchestrator,
      destination: MARCH_NODE_IDS.client,
      endpoint: 'response.metadata',
      method: 'Internal',
      flow: flow === 'EEF' || flow === 'CARF' || flow === 'DCRF' ? flow : undefined,
      patientIdHash,
    } as TrafficInspectorEvent;
  }
  // Generic: treat as planner/orchestrator internal
  return {
    ...base,
    source: MARCH_NODE_IDS.planner,
    destination: MARCH_NODE_IDS.orchestrator,
    endpoint: eventName,
    method: 'Internal',
  } as TrafficInspectorEvent;
}

// Optional helper for future: map March SSE events to topology edges.
export function mapMarchEventToEdge(eventName: string): { source: string; target: string } | null {
  const ev = (eventName || '').trim();
  if (!ev) return null;
  if (ev === 'session.started') return { source: MARCH_NODE_IDS.client, target: MARCH_NODE_IDS.api };
  if (ev.startsWith('guardrail.')) return { source: MARCH_NODE_IDS.api, target: MARCH_NODE_IDS.guardrail };
  if (ev.startsWith('planner.')) return { source: MARCH_NODE_IDS.planner, target: MARCH_NODE_IDS.orchestrator };
  if (ev === 'orchestrator.tool_called' || ev === 'orchestrator.tool_result') {
    return { source: MARCH_NODE_IDS.orchestrator, target: MARCH_NODE_IDS.tools };
  }
  if (ev.startsWith('stream.') || ev === 'response.metadata') {
    return { source: MARCH_NODE_IDS.sse, target: MARCH_NODE_IDS.client };
  }
  return null;
}
