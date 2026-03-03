export interface StoredRule {
  id: number;
  command: string;
  allowedRoles: string;
  tenantId: string | null;
  createdAt: string | null;
  updatedAt: string | null;
}

export interface StoredRunStatus {
  runId: string;
  status: string;
  command: string | null;
  tenantId: string | null;
  patientId: string | null;
  createdAt: string | null;
  completedAt: string | null;
  streamUrl: string | null;
}

export interface StoredCommandAudit {
  id: number;
  runId: string | null;
  tenantId: string | null;
  patientId: string | null;
  command: string | null;
  toolName: string | null;
  status: string | null;
  createdAt: string | null;
}

export interface StoredStepAudit {
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

const KEY_RULES = 'march_admin_rules_v1';
const KEY_RUNS = 'march_admin_runs_v1';
const KEY_CMD_AUDIT = 'march_admin_command_audit_v1';
const KEY_STEP_AUDIT = 'march_admin_step_audit_v1';

const MAX_RUNS = 500;
const MAX_COMMAND_AUDIT = 1000;
const MAX_STEP_AUDIT = 2000;

function canUseStorage(): boolean {
  return typeof window !== 'undefined' && !!window.localStorage;
}

function readJson<T>(key: string, fallback: T): T {
  if (!canUseStorage()) return fallback;
  try {
    const raw = window.localStorage.getItem(key);
    if (!raw) return fallback;
    return JSON.parse(raw) as T;
  } catch {
    return fallback;
  }
}

function writeJson<T>(key: string, value: T): void {
  if (!canUseStorage()) return;
  try {
    window.localStorage.setItem(key, JSON.stringify(value));
  } catch {
    // Ignore storage failures in constrained environments.
  }
}

function nowIso(): string {
  return new Date().toISOString();
}

function nextNumericId(items: Array<{ id: number }>): number {
  return (items.reduce((m, x) => Math.max(m, x.id), 0) || 0) + 1;
}

export function getStoredRules(): StoredRule[] {
  return readJson<StoredRule[]>(KEY_RULES, []);
}

export function putStoredRules(rules: StoredRule[]): void {
  writeJson(KEY_RULES, rules);
}

export function createStoredRule(input: {
  command: string;
  allowedRoles: string;
  tenantId?: string | null;
}): StoredRule {
  const rules = getStoredRules();
  const created: StoredRule = {
    id: nextNumericId(rules),
    command: input.command.trim(),
    allowedRoles: (input.allowedRoles ?? '').trim(),
    tenantId: input.tenantId ?? null,
    createdAt: nowIso(),
    updatedAt: nowIso(),
  };
  putStoredRules([created, ...rules]);
  return created;
}

export function updateStoredRule(id: number, allowedRoles: string): StoredRule {
  const rules = getStoredRules();
  let updated: StoredRule | null = null;
  const next = rules.map((r) => {
    if (r.id !== id) return r;
    updated = { ...r, allowedRoles: allowedRoles.trim(), updatedAt: nowIso() };
    return updated;
  });
  putStoredRules(next);
  if (!updated) {
    throw new Error(`Rule ${id} not found`);
  }
  return updated;
}

export function deleteStoredRule(id: number): void {
  const rules = getStoredRules();
  putStoredRules(rules.filter((r) => r.id !== id));
}

export function getStoredRuns(): StoredRunStatus[] {
  return readJson<StoredRunStatus[]>(KEY_RUNS, []);
}

export function putStoredRuns(runs: StoredRunStatus[]): void {
  writeJson(KEY_RUNS, runs.slice(0, MAX_RUNS));
}

export function upsertStoredRun(run: StoredRunStatus): void {
  const runs = getStoredRuns();
  const filtered = runs.filter((r) => r.runId !== run.runId);
  putStoredRuns([run, ...filtered]);
}

export function getStoredRun(runId: string): StoredRunStatus | null {
  const runs = getStoredRuns();
  return runs.find((r) => r.runId === runId) ?? null;
}

export function recordRunSubmitted(input: {
  runId: string;
  command: string;
  tenantId?: string | null;
  patientId?: string | null;
  streamUrl?: string | null;
}): void {
  upsertStoredRun({
    runId: input.runId,
    status: 'RUNNING',
    command: input.command,
    tenantId: input.tenantId ?? null,
    patientId: input.patientId ?? null,
    createdAt: nowIso(),
    completedAt: null,
    streamUrl: input.streamUrl ?? null,
  });
}

export function recordRunCompleted(runId: string, status: string = 'COMPLETED'): void {
  const existing = getStoredRun(runId);
  if (!existing) return;
  upsertStoredRun({
    ...existing,
    status,
    completedAt: nowIso(),
  });
}

export function recordRunFailed(runId: string): void {
  const existing = getStoredRun(runId);
  if (!existing) return;
  upsertStoredRun({
    ...existing,
    status: 'FAILED',
    completedAt: nowIso(),
  });
}

export function getStoredCommandAudit(): StoredCommandAudit[] {
  return readJson<StoredCommandAudit[]>(KEY_CMD_AUDIT, []);
}

export function appendStoredCommandAudit(input: Omit<StoredCommandAudit, 'id' | 'createdAt'>): void {
  const items = getStoredCommandAudit();
  const next: StoredCommandAudit = {
    id: nextNumericId(items),
    createdAt: nowIso(),
    ...input,
  };
  writeJson(KEY_CMD_AUDIT, [next, ...items].slice(0, MAX_COMMAND_AUDIT));
}

export function getStoredStepAudit(): StoredStepAudit[] {
  return readJson<StoredStepAudit[]>(KEY_STEP_AUDIT, []);
}

export function appendStoredStepAudit(input: Omit<StoredStepAudit, 'id' | 'createdAt'>): void {
  const items = getStoredStepAudit();
  const next: StoredStepAudit = {
    id: nextNumericId(items),
    createdAt: nowIso(),
    ...input,
  };
  writeJson(KEY_STEP_AUDIT, [next, ...items].slice(0, MAX_STEP_AUDIT));
}
