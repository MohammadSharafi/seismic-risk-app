/**
 * Admin API client: command-role rules CRUD, audit logs, tools list.
 * Uses same base URL and API key as commandApi (VITE_COMMAND_API_URL, VITE_COMMAND_API_KEY).
 */

import { BACKEND_BASE_COMMANDS } from '../data/commands';
import {
  appendStoredCommandAudit,
  appendStoredStepAudit,
  createStoredRule,
  deleteStoredRule,
  getStoredCommandAudit,
  getStoredRules,
  getStoredRun,
  getStoredStepAudit,
  updateStoredRule,
} from './adminState';

const getBase = (): string => {
  const url = (import.meta.env.VITE_MARCH_API_URL ?? import.meta.env.VITE_COMMAND_API_URL ?? '').toString().trim().replace(/\/$/, '');
  if (!url) return '';
  const stage = (import.meta.env.VITE_MARCH_API_STAGE ?? '').toString().trim();
  if (stage) return `${url}/${stage.replace(/^\/+|\/+$/g, '')}`;
  return url;
};
const getApiKey = (): string => (import.meta.env.VITE_COMMAND_API_KEY ?? '').trim();
const getBearer = (): string => (import.meta.env.VITE_COMMAND_API_BEARER ?? '').trim();
const getMode = (): 'march' | 'command' | 'auto' => {
  const raw = (import.meta.env.VITE_API_MODE ?? 'auto').toString().trim().toLowerCase();
  if (raw === 'march' || raw === 'command') return raw;
  return 'auto';
};

function isMarchMode(): boolean {
  const mode = getMode();
  if (mode === 'march') return true;
  if (mode === 'command') return false;
  return !!import.meta.env.VITE_MARCH_API_URL;
}

export function adminApiBase(): string {
  return getBase();
}

function adminHeaders(): Record<string, string> {
  const h: Record<string, string> = { 'Content-Type': 'application/json' };
  const key = getApiKey();
  if (key) h['X-API-Key'] = key;
  const bearer = getBearer();
  if (bearer) h.Authorization = `Bearer ${bearer}`;
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

// --- Command-role rules ---

export interface RuleItem {
  id: number;
  command: string;
  allowedRoles: string;
  tenantId: string | null;
  createdAt: string | null;
  updatedAt: string | null;
}

export async function listRules(): Promise<RuleItem[]> {
  if (isMarchMode()) {
    return getStoredRules();
  }
  const list = await adminFetch<RuleItem[]>('/v1/admin/command-role-rules');
  return Array.isArray(list) ? list : [];
}

export async function createRule(body: { command: string; allowedRoles: string; tenantId?: string | null }): Promise<RuleItem> {
  if (isMarchMode()) {
    const created = createStoredRule({
      command: body.command,
      allowedRoles: body.allowedRoles ?? '',
      tenantId: body.tenantId ?? null,
    });
    appendStoredCommandAudit({
      runId: null,
      tenantId: body.tenantId ?? null,
      patientId: null,
      command: body.command,
      toolName: 'admin.rule.create',
      status: 'admin_rule_created',
    });
    appendStoredStepAudit({
      flow: 'ADMIN',
      step: 'CREATE_RULE',
      runId: null,
      tenantId: body.tenantId ?? null,
      patientId: null,
      path: '/admin/rules',
      details: `Created rule ${created.command}`,
    });
    return created;
  }
  return adminFetch<RuleItem>('/v1/admin/command-role-rules', {
    method: 'POST',
    body: JSON.stringify({
      command: body.command,
      allowedRoles: body.allowedRoles ?? '',
      tenantId: body.tenantId ?? null,
    }),
  });
}

export async function updateRule(id: number, allowedRoles: string): Promise<RuleItem> {
  if (isMarchMode()) {
    const updated = updateStoredRule(id, allowedRoles);
    appendStoredCommandAudit({
      runId: null,
      tenantId: updated.tenantId,
      patientId: null,
      command: updated.command,
      toolName: 'admin.rule.update',
      status: 'admin_rule_updated',
    });
    appendStoredStepAudit({
      flow: 'ADMIN',
      step: 'UPDATE_RULE',
      runId: null,
      tenantId: updated.tenantId,
      patientId: null,
      path: '/admin/rules',
      details: `Updated rule ${updated.command}`,
    });
    return updated;
  }
  return adminFetch<RuleItem>(`/v1/admin/command-role-rules/${id}`, {
    method: 'PUT',
    body: JSON.stringify({ allowedRoles }),
  });
}

export async function deleteRule(id: number): Promise<void> {
  if (isMarchMode()) {
    deleteStoredRule(id);
    appendStoredCommandAudit({
      runId: null,
      tenantId: null,
      patientId: null,
      command: `rule:${id}`,
      toolName: 'admin.rule.delete',
      status: 'admin_rule_deleted',
    });
    appendStoredStepAudit({
      flow: 'ADMIN',
      step: 'DELETE_RULE',
      runId: null,
      tenantId: null,
      patientId: null,
      path: '/admin/rules',
      details: `Deleted rule ${id}`,
    });
    return;
  }
  await adminFetch<void>(`/v1/admin/command-role-rules/${id}`, { method: 'DELETE' });
}

// --- Audit logs ---

export interface CommandAuditItem {
  id: number;
  runId: string | null;
  tenantId: string | null;
  patientId: string | null;
  command: string | null;
  toolName: string | null;
  status: string | null;
  createdAt: string | null;
}

export interface StepAuditItem {
  id: number;
  flow: string | null;
  step: string | null;
  runId: string | null;
  tenantId: string | null;
  patientId: string | null;
  path: string | null;
  details: string | null;
  createdAt: string | null;
}

export async function getCommandAudit(): Promise<CommandAuditItem[]> {
  if (isMarchMode()) {
    return getStoredCommandAudit();
  }
  const list = await adminFetch<CommandAuditItem[]>('/v1/audit/command');
  return Array.isArray(list) ? list : [];
}

export async function getStepAudit(): Promise<StepAuditItem[]> {
  if (isMarchMode()) {
    return getStoredStepAudit();
  }
  const list = await adminFetch<StepAuditItem[]>('/v1/audit/steps');
  return Array.isArray(list) ? list : [];
}

// --- Tools ---

export interface ToolDescriptor {
  name: string;
  description: string;
  parametersSchema: unknown;
}

export async function getTools(): Promise<ToolDescriptor[]> {
  if (isMarchMode()) {
    return Array.from(BACKEND_BASE_COMMANDS).map((cmd) => ({
      name: cmd.replace(/^\//, ''),
      description: `Mapped March command ${cmd}`,
      parametersSchema: { type: 'object', additionalProperties: true },
    }));
  }
  const list = await adminFetch<ToolDescriptor[]>('/v1/tools');
  return Array.isArray(list) ? list : [];
}

// --- Run lookup ---

export interface RunStatusItem {
  runId: string;
  status: string;
  command: string | null;
  tenantId: string | null;
  patientId: string | null;
  createdAt: string | null;
  completedAt: string | null;
  streamUrl: string | null;
}

export async function getRunStatus(runId: string): Promise<RunStatusItem> {
  if (isMarchMode()) {
    const found = getStoredRun(runId);
    if (found) return found;
    throw new Error(`Run ${runId} not found`);
  }
  return adminFetch<RunStatusItem>(`/v1/commands/runs/${encodeURIComponent(runId)}`);
}

// --- System health ---

export interface HealthResponse {
  status?: string;
  commandApi?: boolean;
}

export async function getHealth(): Promise<HealthResponse> {
  if (isMarchMode()) {
    const base = getBase();
    if (!base) return { status: 'down', commandApi: false };
    try {
      const res = await fetch(`${base}/health`, { method: 'GET', headers: adminHeaders() });
      if (!res.ok) return { status: 'down', commandApi: false };
      const body = (await res.json()) as { status?: string };
      return { status: body.status ?? 'up', commandApi: true };
    } catch {
      return { status: 'down', commandApi: false };
    }
  }
  return adminFetch<HealthResponse>('/v1/health');
}

/** Full Spring Boot actuator health (db, mcp, disk). May 404/403 if actuator not exposed. */
export interface ActuatorHealthResponse {
  status?: 'UP' | 'DOWN';
  components?: {
    db?: { status?: string; details?: Record<string, unknown> };
    diskSpace?: { status?: string };
    mcp?: { status?: string; details?: Record<string, unknown> };
    ping?: { status?: string };
  };
}

export async function getActuatorHealth(): Promise<ActuatorHealthResponse | null> {
  if (isMarchMode()) {
    const health = await getHealth();
    const up = (health.status ?? '').toLowerCase() === 'ok' || (health.status ?? '').toLowerCase() === 'up';
    return {
      status: up ? 'UP' : 'DOWN',
      components: {
        db: { status: up ? 'UP' : 'DOWN' },
        mcp: { status: 'DOWN', details: { mcp: 'not-exposed' } },
        ping: { status: up ? 'UP' : 'DOWN' },
      },
    };
  }
  try {
    return await adminFetch<ActuatorHealthResponse>('/actuator/health');
  } catch {
    return null;
  }
}

// --- Capabilities ---

export interface CapabilityItem {
  slug: string;
  type: string;
  category: string;
  description: string | null;
  toolName: string | null;
  method: string | null;
}

export async function getCapabilities(category?: string): Promise<CapabilityItem[]> {
  if (isMarchMode()) {
    const items: CapabilityItem[] = Array.from(BACKEND_BASE_COMMANDS).map((cmd) => {
      const slug = cmd.replace(/^\//, '');
      const isAgent = /simulate|draft|plan|note|revise|risk_compare|risk_mitigation/i.test(slug);
      return {
        slug,
        type: isAgent ? 'agent' : 'data',
        category: isAgent ? 'AGENT_OR_SIMULATION' : 'DATA_DAN',
        description: `March capability for ${cmd}`,
        toolName: slug,
        method: 'SSE',
      };
    });
    return category ? items.filter((x) => x.category === category) : items;
  }
  const q = category ? `?category=${encodeURIComponent(category)}` : '';
  const list = await adminFetch<CapabilityItem[]>(`/v1/capabilities${q}`);
  return Array.isArray(list) ? list : [];
}

export function isAdminApiAvailable(): boolean {
  return getBase().length > 0;
}
