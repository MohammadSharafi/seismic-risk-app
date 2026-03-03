/**
 * Command API client: submit command, stream widget events via SSE.
 * When VITE_COMMAND_API_URL is unset or empty, caller should use mock flow.
 */

import {
  appendStoredCommandAudit,
  appendStoredStepAudit,
  getStoredRun,
  recordRunCompleted,
  recordRunFailed,
  recordRunSubmitted,
} from './adminState';

const getBase = (): string => {
  const url = (import.meta.env.VITE_MARCH_API_URL ?? import.meta.env.VITE_COMMAND_API_URL ?? '').toString().trim().replace(/\/$/, '');
  if (!url) return '';
  const stage = (import.meta.env.VITE_MARCH_API_STAGE ?? '').toString().trim();
  if (stage) return `${url}/${stage.replace(/^\/+|\/+$/g, '')}`;
  return url;
};
const getPatientsBase = (): string =>
  ((import.meta.env.VITE_PATIENTS_API_URL ?? '').toString().trim().replace(/\/$/, '')) || getBase();
const getApiKey = (): string => (import.meta.env.VITE_COMMAND_API_KEY ?? '').trim();
const getBearer = (): string => (import.meta.env.VITE_COMMAND_API_BEARER ?? '').trim();
const getMode = (): 'march' | 'command' | 'auto' => {
  const raw = (import.meta.env.VITE_API_MODE ?? 'auto').toString().trim().toLowerCase();
  if (raw === 'march' || raw === 'command') return raw;
  return 'auto';
};

const pendingLegacyStreams = new Map<
  string,
  {
    command: string;
    tenantId: string;
    patientId: string;
    options?: Record<string, unknown>;
  }
>();

function isMarchMode(): boolean {
  const mode = getMode();
  if (mode === 'march') return true;
  if (mode === 'command') return false;
  // Auto: prefer March endpoints in this repo, fall back to command API only when explicitly requested.
  return true;
}

function jsonHeaders(): Record<string, string> {
  const h: Record<string, string> = { 'Content-Type': 'application/json' };
  const apiKey = getApiKey();
  if (apiKey) h['X-API-Key'] = apiKey;
  const bearer = getBearer();
  if (bearer) h.Authorization = `Bearer ${bearer}`;
  return h;
}

function eventSourceUrlWithAuth(url: string): string {
  const apiKey = getApiKey();
  const bearer = getBearer();
  if (!apiKey && !bearer) return url;
  const full = new URL(url, window.location.origin);
  if (apiKey) full.searchParams.set('api_key', apiKey);
  if (bearer) full.searchParams.set('access_token', bearer);
  return full.toString();
}

async function readSseEvents(
  response: Response,
  onEvent: (payload: {
    channel?: string;
    event?: string;
    data?: Record<string, unknown>;
    type?: string;
    done?: boolean;
  }) => void
): Promise<void> {
  if (!response.body) return;
  const reader = response.body.getReader();
  const decoder = new TextDecoder();
  let buffer = '';

  while (true) {
    const { done, value } = await reader.read();
    if (done) break;
    buffer += decoder.decode(value, { stream: true });
    const parts = buffer.split('\n\n');
    buffer = parts.pop() ?? '';
    for (const chunk of parts) {
      const dataLines = chunk
        .split('\n')
        .filter((line) => line.startsWith('data:'))
        .map((line) => line.slice(5).trim());
      const raw = dataLines.join('');
      if (!raw) continue;
      try {
        onEvent(
          JSON.parse(raw) as {
            channel?: string;
            event?: string;
            data?: Record<string, unknown>;
            type?: string;
            done?: boolean;
          }
        );
      } catch {
        // Ignore keep-alive / non-JSON chunks.
      }
    }
  }
}

export function isCommandApiEnabled(): boolean {
  return getBase().length > 0;
}

/** Base URL for the Command API (e.g. for building download links). */
export function commandApiBase(): string {
  return getBase();
}

/** Build full URL for export file download. Use when Command API is enabled. */
export function getExportDownloadUrl(exportId: string): string {
  return getBase() + '/api/exports/' + encodeURIComponent(exportId);
}

export interface PatientListItem {
  mrn: string;
  name: string;
  status: string;
  risk: string;
}

/** Entity list item from GET /v1/{assessments|alerts|redflags|exports|simulations|visits} (backend → DB). No hardcoded data when API is used. */
export interface EntityListItem {
  id: string;
  date: string;
  time?: string;
  type: string;
  title?: string | null;
  summary: string;
  chips: string[];
}

/** @deprecated use EntityListItem */
export type AssessmentListItem = EntityListItem;

async function fetchEntityList(
  path: string,
  tenantId: string,
  patientId: string
): Promise<EntityListItem[]> {
  const base = getBase();
  if (!base || !patientId?.trim()) return [];
  if (isMarchMode()) {
    return fetchEntityListViaMarch(path, patientId.trim());
  }

  const headers: Record<string, string> = {};
  const apiKey = getApiKey();
  if (apiKey) headers['X-API-Key'] = apiKey;
  const params = new URLSearchParams({ tenantId: tenantId || 'default', patientId: patientId.trim() });
  const res = await fetch(`${base}${path}?${params}`, {
    method: 'GET',
    headers: Object.keys(headers).length ? headers : undefined,
  });
  if (!res.ok) {
    const text = await res.text();
    throw new Error(text && text.length < 200 ? text : `Failed to load (${res.status})`);
  }
  const body = (await res.json()) as EntityListItem[];
  return Array.isArray(body) ? body : [];
}

export async function fetchAssessments(tenantId: string, patientId: string): Promise<EntityListItem[]> {
  return fetchEntityList('/v1/assessments', tenantId, patientId);
}

export async function fetchAlerts(tenantId: string, patientId: string): Promise<EntityListItem[]> {
  return fetchEntityList('/v1/alerts', tenantId, patientId);
}

export async function fetchRedFlags(tenantId: string, patientId: string): Promise<EntityListItem[]> {
  return fetchEntityList('/v1/redflags', tenantId, patientId);
}

export async function fetchExports(tenantId: string, patientId: string): Promise<EntityListItem[]> {
  return fetchEntityList('/v1/exports', tenantId, patientId);
}

export async function fetchSimulations(tenantId: string, patientId: string): Promise<EntityListItem[]> {
  return fetchEntityList('/v1/simulations', tenantId, patientId);
}

export async function fetchVisits(tenantId: string, patientId: string): Promise<EntityListItem[]> {
  return fetchEntityList('/v1/visits', tenantId, patientId);
}

/**
 * GET /v1/patients?tenantId=... — list patients for the UI. Uses same auth as submitCommand.
 * When Command API is disabled or request fails, caller should fall back to demo data.
 */
export async function fetchPatients(tenantId: string = 'default'): Promise<PatientListItem[]> {
  const base = getPatientsBase();
  if (!base) return [];
  if (isMarchMode() || (import.meta.env.VITE_PATIENTS_API_URL ?? '').toString().trim().length > 0) {
    const fromApi = await fetchPatientsFromAwsApi(base, tenantId);
    if (fromApi.length > 0) return fromApi;
    // Optional local-only fallback when explicitly set.
    return defaultMarchPatients();
  }
  const headers: Record<string, string> = {};
  const apiKey = getApiKey();
  if (apiKey) headers['X-API-Key'] = apiKey;
  const res = await fetch(`${base}/v1/patients?tenantId=${encodeURIComponent(tenantId)}`, {
    method: 'GET',
    headers: Object.keys(headers).length ? headers : undefined,
  });
  if (!res.ok) return [];
  const body = (await res.json()) as PatientListItem[];
  return Array.isArray(body) ? body : [];
}

function defaultMarchPatients(): PatientListItem[] {
  const raw = (import.meta.env.VITE_MARCH_DEFAULT_PATIENTS ?? '').toString().trim();
  if (!raw) return [];
  const parsed = raw
    .split(';')
    .map((entry) => entry.trim())
    .filter(Boolean)
    .map((entry) => {
      const [mrn, name] = entry.split(':');
      return {
        mrn: (mrn ?? '').trim(),
        name: (name ?? mrn ?? '').trim(),
      };
    })
    .filter((p) => p.mrn.length > 0)
    .map((p) => ({
      mrn: p.mrn,
      name: p.name,
      status: 'Active',
      risk: 'Moderate',
    }));
  return parsed;
}

function normalizePatientRows(value: unknown): PatientListItem[] {
  const rows = extractPatientCandidates(value)
    .map((item) => toPatientListItem(item))
    .filter((item): item is PatientListItem => !!item);
  const deduped = new Map<string, PatientListItem>();
  for (const row of rows) {
    if (!deduped.has(row.mrn)) deduped.set(row.mrn, row);
  }
  return Array.from(deduped.values());
}

function extractPatientCandidates(value: unknown): Record<string, unknown>[] {
  if (Array.isArray(value)) {
    return value.filter((v): v is Record<string, unknown> => !!v && typeof v === 'object');
  }
  if (!value || typeof value !== 'object') return [];
  const obj = value as Record<string, unknown>;
  if (obj.resourceType === 'Bundle' && Array.isArray(obj.entry)) {
    return obj.entry
      .map((entry) => (entry && typeof entry === 'object' ? (entry as Record<string, unknown>).resource : null))
      .filter((v): v is Record<string, unknown> => !!v && typeof v === 'object');
  }
  const keys = ['patients', 'data', 'items', 'results', 'entries'];
  for (const key of keys) {
    const candidate = obj[key];
    if (Array.isArray(candidate)) {
      return candidate.filter((v): v is Record<string, unknown> => !!v && typeof v === 'object');
    }
    if (candidate && typeof candidate === 'object') {
      const nested = candidate as Record<string, unknown>;
      for (const nestedKey of keys) {
        const nestedCandidate = nested[nestedKey];
        if (Array.isArray(nestedCandidate)) {
          return nestedCandidate.filter((v): v is Record<string, unknown> => !!v && typeof v === 'object');
        }
      }
    }
  }
  return [obj];
}

function toPatientListItem(value: Record<string, unknown>): PatientListItem | null {
  const identifier = Array.isArray(value.identifier) ? value.identifier : [];
  const identifierMrn = identifier
    .map((it) => (it && typeof it === 'object' ? String((it as Record<string, unknown>).value ?? '').trim() : ''))
    .find((it) => it.length > 0);
  const mrn = [
    value.mrn,
    value.medical_record_number,
    value.medicalRecordNumber,
    value.patient_id,
    value.patientId,
    value.id,
    identifierMrn,
  ]
    .map((it) => String(it ?? '').trim())
    .find((it) => it.length > 0);
  if (!mrn) return null;

  const nameField = value.name;
  let name = '';
  if (typeof nameField === 'string') {
    name = nameField.trim();
  } else if (Array.isArray(nameField) && nameField.length > 0) {
    const first = nameField[0];
    if (typeof first === 'string') name = first.trim();
    if (first && typeof first === 'object') {
      const firstObj = first as Record<string, unknown>;
      const given = Array.isArray(firstObj.given) ? firstObj.given.map((g) => String(g)).join(' ') : String(firstObj.given ?? '').trim();
      const family = String(firstObj.family ?? '').trim();
      name = `${given} ${family}`.trim();
      if (!name) name = String(firstObj.text ?? '').trim();
    }
  } else if (nameField && typeof nameField === 'object') {
    const nameObj = nameField as Record<string, unknown>;
    const given = Array.isArray(nameObj.given) ? nameObj.given.map((g) => String(g)).join(' ') : String(nameObj.given ?? '').trim();
    const family = String(nameObj.family ?? '').trim();
    name = `${given} ${family}`.trim();
    if (!name) name = String(nameObj.text ?? '').trim();
  }
  if (!name) {
    name = String(value.full_name ?? value.fullName ?? value.display ?? `Patient ${mrn}`).trim();
  }

  const status = String(value.status ?? (value.active === false ? 'Inactive' : 'Active')).trim() || 'Active';
  const risk = String(value.risk ?? value.risk_level ?? value.riskLevel ?? 'Unknown').trim() || 'Unknown';
  return { mrn, name, status, risk };
}

async function fetchPatientsFromAwsApi(base: string, tenantId: string): Promise<PatientListItem[]> {
  const headers: Record<string, string> = {};
  const apiKey = getApiKey();
  if (apiKey) headers['X-API-Key'] = apiKey;
  const bearer = getBearer();
  if (bearer) headers.Authorization = `Bearer ${bearer}`;

  const t = encodeURIComponent((tenantId || 'default').trim());
  const endpointOverrides = (import.meta.env.VITE_PATIENTS_API_PATHS ?? '')
    .toString()
    .split(',')
    .map((s) => s.trim())
    .filter(Boolean);
  const endpoints = endpointOverrides.length > 0
    ? endpointOverrides
    : [
        `/v1/patients?tenantId=${t}`,
        `/api/v1/patients?tenantId=${t}`,
        `/patients?tenantId=${t}`,
        `/api/patients?tenantId=${t}`,
        `/fhir/Patient?_count=200`,
      ];

  for (const endpoint of endpoints) {
    const url = endpoint.startsWith('http') ? endpoint : `${base}${endpoint.startsWith('/') ? endpoint : `/${endpoint}`}`;
    try {
      const res = await fetch(url, {
        method: 'GET',
        headers: Object.keys(headers).length ? headers : undefined,
      });
      if (!res.ok) continue;
      const body = (await res.json()) as unknown;
      const patients = normalizePatientRows(body);
      if (patients.length > 0) return patients;
    } catch {
      // Try the next endpoint.
    }
  }
  return [];
}

export interface HealthResult {
  ok: boolean;
  status?: string;
}

/**
 * GET /v1/health to check if the Command API is reachable. No API key required.
 * Use for "Command API connected" indicator when VITE_COMMAND_API_URL is set.
 */
export async function checkCommandApiHealth(): Promise<HealthResult> {
  const base = getBase();
  if (!base) return { ok: false };
  try {
    const healthPaths = isMarchMode() ? ['/health', '/v1/health'] : ['/v1/health', '/health'];
    for (const p of healthPaths) {
      const res = await fetch(`${base}${p}`, { method: 'GET' });
      if (!res.ok) continue;
      const body = (await res.json()) as { status?: string };
      return { ok: true, status: body.status ?? 'up' };
    }
    return { ok: false };
  } catch {
    return { ok: false };
  }
}

export interface SubmitResponse {
  runId: string;
  streamUrl: string;
}

export async function submitCommand(
  command: string,
  tenantId: string,
  patientId: string,
  options?: Record<string, unknown>
): Promise<SubmitResponse> {
  const base = getBase();
  if (!base) throw new Error('Command API URL not configured');
  if (isMarchMode()) {
    const runId = `conv-${Date.now()}-${Math.random().toString(36).slice(2, 8)}`;
    const body = {
      message: command,
      patient_id: patientId?.trim() || null,
      conversation_id: runId,
      tenant_id: tenantId || 'default',
      options: options ?? null,
    };
    const res = await fetch(`${base}/api/v1/chat/message`, {
      method: 'POST',
      headers: jsonHeaders(),
      body: JSON.stringify(body),
    });
    if (res.status === 404) {
      pendingLegacyStreams.set(runId, {
        command,
        tenantId: tenantId || 'default',
        patientId: patientId?.trim() || '',
        options,
      });
      const streamUrl = 'legacy-post:/chat';
      recordRunSubmitted({
        runId,
        command,
        tenantId: tenantId || 'default',
        patientId: patientId?.trim() || null,
        streamUrl,
      });
      appendStoredCommandAudit({
        runId,
        tenantId: tenantId || 'default',
        patientId: patientId?.trim() || null,
        command,
        toolName: 'chat',
        status: 'command_submitted',
      });
      return {
        runId,
        streamUrl,
      };
    }
    if (!res.ok) {
      const text = await res.text();
      throw new Error(`March API ${res.status}: ${text || res.statusText}`);
    }
    const payload = (await res.json()) as { conversation_id?: string };
    const conversationId = payload.conversation_id || runId;
    const qs = new URLSearchParams({ conversation_id: conversationId });
    if (patientId?.trim()) qs.set('patient_id', patientId.trim());
    const streamUrl = `/api/v1/chat/stream?${qs.toString()}`;
    recordRunSubmitted({
      runId: conversationId,
      command,
      tenantId: tenantId || 'default',
      patientId: patientId?.trim() || null,
      streamUrl,
    });
    appendStoredCommandAudit({
      runId: conversationId,
      tenantId: tenantId || 'default',
      patientId: patientId?.trim() || null,
      command,
      toolName: 'api.v1.chat.message',
      status: 'command_submitted',
    });
    return {
      runId: conversationId,
      streamUrl,
    };
  }

  const res = await fetch(`${base}/v1/commands`, {
    method: 'POST',
    headers: jsonHeaders(),
    body: JSON.stringify({ command, tenantId, patientId, options: options ?? null }),
  });
  if (!res.ok) {
    const text = await res.text();
    if (res.status === 401) {
      throw new Error('Invalid or missing API key. Set VITE_COMMAND_API_KEY if the backend requires auth.');
    }
    if (res.status === 429) {
      const retryAfter = res.headers.get('Retry-After');
      const msg = retryAfter
        ? `Too many requests. Try again in ${retryAfter} seconds.`
        : 'Too many requests. Try again later.';
      throw new Error(msg);
    }
    if (res.status === 403) {
      const msg = text && text.length < 200 ? text : 'This feature is not enabled.';
      appendStoredCommandAudit({
        runId: null,
        tenantId: tenantId || 'default',
        patientId: patientId?.trim() || null,
        command,
        toolName: null,
        status: 'command_denied',
      });
      throw new Error(msg);
    }
    throw new Error(`Command API ${res.status}: ${text || res.statusText}`);
  }
  const body = (await res.json()) as SubmitResponse;
  if (!body.runId || !body.streamUrl) throw new Error('Invalid Command API response');
  recordRunSubmitted({
    runId: body.runId,
    command,
    tenantId: tenantId || 'default',
    patientId: patientId?.trim() || null,
    streamUrl: body.streamUrl,
  });
  appendStoredCommandAudit({
    runId: body.runId,
    tenantId: tenantId || 'default',
    patientId: patientId?.trim() || null,
    command,
    toolName: 'v1.commands',
    status: 'command_submitted',
  });
  return body;
}

export interface WidgetEvent {
  type: string;
  data: Record<string, unknown>;
}

export interface StreamCallbacks {
  onWidget: (widget: WidgetEvent) => void;
  onSseEvent?: (event: {
    channel?: string;
    event?: string;
    data?: Record<string, unknown>;
    type?: string;
    done?: boolean;
  }) => void;
  onError?: (message: string) => void;
  onDone?: () => void;
}

/**
 * Open SSE stream for a runId. streamUrl is the path from the submit response (e.g. /v1/commands/stream?runId=...).
 * Calls onWidget for each "widget" event, onError for "error" events, onDone when stream ends.
 */
export function openCommandStream(
  runId: string,
  streamUrl: string,
  callbacks: StreamCallbacks
): () => void {
  const base = getBase();
  if (streamUrl.startsWith('legacy-post:/chat')) {
    const pending = pendingLegacyStreams.get(runId);
    if (!pending) {
      callbacks.onError?.('Missing legacy stream payload.');
      callbacks.onDone?.();
      return () => {};
    }
    pendingLegacyStreams.delete(runId);

    const controller = new AbortController();
    let closed = false;
    let doneSent = false;
    let synthesizedSent = false;
    let finalText = '';
    let latestMetadata: Record<string, unknown> | undefined;

    void (async () => {
      try {
        const resp = await fetch(`${base}/chat`, {
          method: 'POST',
          headers: jsonHeaders(),
          signal: controller.signal,
          body: JSON.stringify({
            message: pending.command,
            patient_id: pending.patientId || null,
            conversation_id: runId,
            tenant_id: pending.tenantId || 'default',
            options: pending.options ?? null,
          }),
        });
        if (!resp.ok || !resp.body) {
          const text = await resp.text();
          callbacks.onError?.(`March API ${resp.status}: ${text || resp.statusText}`);
          callbacks.onDone?.();
          return;
        }

        await readSseEvents(resp, (payload) => {
          if (closed) return;
          callbacks.onSseEvent?.(payload);
          if (payload.type && payload.data) {
            callbacks.onWidget({ type: payload.type, data: payload.data });
            synthesizedSent = true;
            return;
          }
          const eventName = payload.event ?? '';
          const data = payload.data ?? {};
          if (eventName === 'stream.token') {
            const token = String((data as { token?: unknown }).token ?? '').trim();
            if (token) finalText = `${finalText}${finalText ? ' ' : ''}${token}`;
            return;
          }
          if (eventName) {
            const run = getStoredRun(runId);
            appendStoredStepAudit({
              flow: 'SSE',
              step: eventName,
              runId,
              tenantId: run?.tenantId ?? null,
              patientId: run?.patientId ?? null,
              path: streamUrl,
              details: JSON.stringify(data).slice(0, 500),
            });
          }
          if (eventName === 'response.metadata') {
            latestMetadata = data;
            return;
          }
          if (eventName === 'stream.error') {
            const run = getStoredRun(runId);
            recordRunFailed(runId);
            appendStoredCommandAudit({
              runId,
              tenantId: run?.tenantId ?? null,
              patientId: run?.patientId ?? null,
              command: run?.command ?? null,
              toolName: 'sse.stream',
              status: 'command_failed',
            });
            callbacks.onError?.(String((data as { message?: unknown }).message ?? 'Stream error'));
            return;
          }
          if (eventName === 'stream.end' && !doneSent) {
            if (!synthesizedSent && finalText.trim()) {
              callbacks.onWidget({
                type: 'W_SUMMARY_CLINICAL',
                data: {
                  summary: finalText.trim(),
                  keyPoints: [],
                  runId,
                  ...(latestMetadata ? { metadata: latestMetadata } : {}),
                },
              });
            }
            const run = getStoredRun(runId);
            recordRunCompleted(runId);
            appendStoredCommandAudit({
              runId,
              tenantId: run?.tenantId ?? null,
              patientId: run?.patientId ?? null,
              command: run?.command ?? null,
              toolName: 'sse.stream',
              status: 'command_complete',
            });
            doneSent = true;
            callbacks.onDone?.();
          }
        });
      } catch (error) {
        if (closed) return;
        const message =
          error instanceof Error ? error.message : 'Connection lost. Check your network or try again.';
        callbacks.onError?.(message);
        if (!doneSent) callbacks.onDone?.();
      }
    })();

    return () => {
      if (closed) return;
      closed = true;
      controller.abort();
    };
  }
  const rawUrl = streamUrl.startsWith('http') ? streamUrl : `${base}${streamUrl}`;
  const url = eventSourceUrlWithAuth(rawUrl);
  const es = new EventSource(url);
  let closed = false;
  let doneSent = false;
  let synthesizedSent = false;
  let finalText = '';
  let latestMetadata: Record<string, unknown> | undefined;

  es.addEventListener('widget', (e: MessageEvent) => {
    try {
      const payload = JSON.parse(e.data ?? '{}') as { type?: string; data?: Record<string, unknown> };
      callbacks.onWidget({
        type: payload.type ?? 'W_UNKNOWN',
        data: payload.data ?? {},
      });
    } catch {
      callbacks.onError?.('Invalid widget payload');
    }
  });

  es.onmessage = (e: MessageEvent) => {
    if (!e?.data) return;
    try {
      const payload = JSON.parse(e.data) as {
        channel?: string;
        event?: string;
        data?: Record<string, unknown>;
        type?: string;
        done?: boolean;
      };
      callbacks.onSseEvent?.(payload);

      if (payload.type && payload.data) {
        callbacks.onWidget({ type: payload.type, data: payload.data });
        synthesizedSent = true;
        return;
      }

      const eventName = payload.event ?? '';
      const data = payload.data ?? {};
      if (eventName === 'stream.token') {
        const token = String((data as { token?: unknown }).token ?? '').trim();
        if (token) finalText = `${finalText}${finalText ? ' ' : ''}${token}`;
        return;
      }
      if (eventName) {
        const run = getStoredRun(runId);
        appendStoredStepAudit({
          flow: 'SSE',
          step: eventName,
          runId,
          tenantId: run?.tenantId ?? null,
          patientId: run?.patientId ?? null,
          path: streamUrl,
          details: JSON.stringify(data).slice(0, 500),
        });
      }
      if (eventName === 'response.metadata') {
        latestMetadata = data;
        return;
      }
      if (eventName === 'stream.error') {
        const run = getStoredRun(runId);
        recordRunFailed(runId);
        appendStoredCommandAudit({
          runId,
          tenantId: run?.tenantId ?? null,
          patientId: run?.patientId ?? null,
          command: run?.command ?? null,
          toolName: 'sse.stream',
          status: 'command_failed',
        });
        callbacks.onError?.(String((data as { message?: unknown }).message ?? 'Stream error'));
        return;
      }
      if (eventName === 'stream.end') {
        if (!synthesizedSent && finalText.trim()) {
          callbacks.onWidget({
            type: 'W_SUMMARY_CLINICAL',
            data: {
              summary: finalText.trim(),
              keyPoints: [],
              runId,
              ...(latestMetadata ? { metadata: latestMetadata } : {}),
            },
          });
          synthesizedSent = true;
        }
        if (!doneSent) {
          const run = getStoredRun(runId);
          recordRunCompleted(runId);
          appendStoredCommandAudit({
            runId,
            tenantId: run?.tenantId ?? null,
            patientId: run?.patientId ?? null,
            command: run?.command ?? null,
            toolName: 'sse.stream',
            status: 'command_complete',
          });
          doneSent = true;
          callbacks.onDone?.();
        }
        if (!closed) {
          closed = true;
          es.close();
        }
      }
    } catch {
      // Ignore non-JSON keep-alive messages.
    }
  };

  es.addEventListener('error', (e: MessageEvent) => {
    if (closed) return;
    callbacks.onError?.(typeof e.data === 'string' ? e.data : 'Stream error');
  });

  es.onerror = () => {
    if (closed) return;
    closed = true;
    es.close();
    if (!doneSent) {
      const run = getStoredRun(runId);
      recordRunFailed(runId);
      appendStoredCommandAudit({
        runId,
        tenantId: run?.tenantId ?? null,
        patientId: run?.patientId ?? null,
        command: run?.command ?? null,
        toolName: 'sse.stream',
        status: 'command_failed',
      });
      callbacks.onError?.('Connection lost. Check your network or try again.');
      callbacks.onDone?.();
      doneSent = true;
    }
  };

  return () => {
    if (closed) return;
    closed = true;
    es.close();
  };
}

async function fetchEntityListViaMarch(path: string, patientId: string): Promise<EntityListItem[]> {
  const commandByPath: Record<string, string> = {
    '/v1/assessments': '/latest_assessment',
    '/v1/alerts': '/alerts limit=10',
    '/v1/redflags': '/redflags',
    '/v1/exports': '/list_exports',
    '/v1/simulations': '/simulation_result',
    '/v1/visits': '/summary window=last_30_days',
  };
  const message = commandByPath[path];
  if (!message) return [];
  const text = await runMarchTextQuery(message, patientId);
  return textToEntityItems(text, path);
}

async function runMarchTextQuery(message: string, patientId: string): Promise<string> {
  const base = getBase();
  if (!base) return '';
  const conversationId = `entity-${Date.now()}-${Math.random().toString(36).slice(2, 8)}`;
  const postResp = await fetch(`${base}/api/v1/chat/message`, {
    method: 'POST',
    headers: jsonHeaders(),
    body: JSON.stringify({
      message,
      patient_id: patientId || null,
      conversation_id: conversationId,
    }),
  });
  if (postResp.status === 404) {
    const legacyResp = await fetch(`${base}/chat`, {
      method: 'POST',
      headers: jsonHeaders(),
      body: JSON.stringify({
        message,
        patient_id: patientId || null,
        conversation_id: conversationId,
      }),
    });
    if (!legacyResp.ok || !legacyResp.body) return '';
    let answer = '';
    let hadError = false;
    await readSseEvents(legacyResp, (payload) => {
      if (payload.event === 'stream.token') {
        const token = String((payload.data as { token?: unknown })?.token ?? '').trim();
        if (token) answer = `${answer}${answer ? ' ' : ''}${token}`;
      } else if (payload.event === 'stream.error') {
        hadError = true;
      }
    });
    return hadError ? '' : answer.trim();
  }
  if (!postResp.ok) return '';

  const qs = new URLSearchParams({ conversation_id: conversationId });
  if (patientId) qs.set('patient_id', patientId);
  const streamResp = await fetch(`${base}/api/v1/chat/stream?${qs.toString()}`, {
    method: 'GET',
    headers: (() => {
      const h: Record<string, string> = {};
      const apiKey = getApiKey();
      if (apiKey) h['X-API-Key'] = apiKey;
      const bearer = getBearer();
      if (bearer) h.Authorization = `Bearer ${bearer}`;
      return h;
    })(),
  });
  if (!streamResp.ok || !streamResp.body) return '';

  let answer = '';
  let hadError = false;
  await readSseEvents(streamResp, (payload) => {
    if (payload.event === 'stream.token') {
      const token = String((payload.data as { token?: unknown })?.token ?? '').trim();
      if (token) answer = `${answer}${answer ? ' ' : ''}${token}`;
    } else if (payload.event === 'stream.error') {
      hadError = true;
    }
  });
  return hadError ? '' : answer.trim();
}

function textToEntityItems(text: string, path: string): EntityListItem[] {
  if (!text.trim()) return [];
  const typeMap: Record<string, string> = {
    '/v1/assessments': 'assessment',
    '/v1/alerts': 'alert',
    '/v1/redflags': 'redflag',
    '/v1/exports': 'export',
    '/v1/simulations': 'simulation',
    '/v1/visits': 'visit',
  };
  const entityType = typeMap[path] ?? 'item';
  const lines = text
    .split('\n')
    .map((l) => l.replace(/^\s*[-*•]\s*/, '').trim())
    .filter(Boolean)
    .slice(0, 12);
  const source = lines.length > 0 ? lines : [text.trim()];
  const now = new Date();
  const date = now.toLocaleDateString();
  const time = now.toLocaleTimeString();
  return source.map((summary, idx) => ({
    id: `${entityType}-${idx + 1}`,
    date,
    time,
    type: entityType,
    title: `${entityType.toUpperCase()} ${idx + 1}`,
    summary,
    chips: ['live', entityType],
  }));
}
