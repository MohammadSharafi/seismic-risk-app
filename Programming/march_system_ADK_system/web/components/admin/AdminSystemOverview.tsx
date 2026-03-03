import React, { useState, useEffect, useRef, useCallback } from 'react';
import { Link } from 'react-router-dom';
import {
  getHealth,
  getActuatorHealth,
  getTools,
  listRules,
  getCommandAudit,
} from '../../api/adminApi';
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from '../ui/card';
import { Button } from '../ui/button';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '../ui/tabs';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '../ui/table';
import { RefreshCw, Loader2, Shield, ScrollText, ListOrdered, Wrench, Search, Activity, Layers, ExternalLink } from 'lucide-react';
import mermaid from 'mermaid';
import { SystemOverviewFlow } from './SystemOverviewFlow';

mermaid.initialize({ startOnLoad: false, theme: 'neutral' });

export interface SystemSection {
  id: string;
  name: string;
  status: 'up' | 'down' | 'disabled' | 'unknown';
  workload: string;
  details: string;
}

export interface OverviewStats {
  rulesCount: number;
  commandRunsCount: number;
  toolsCount: number;
  lastRefreshed: Date | null;
}

function useSystemSections(): { sections: SystemSection[]; loading: boolean; error: string | null; refresh: () => void } {
  const [sections, setSections] = useState<SystemSection[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const load = async () => {
    setLoading(true);
    setError(null);
    try {
      const [health, actuator, tools] = await Promise.all([
        getHealth().catch(() => null),
        getActuatorHealth(),
        getTools().catch(() => []),
      ]);

      const list: SystemSection[] = [];
      const cmdUp = health?.status === 'up' || health?.commandApi === true;

      list.push({
        id: 'command-api',
        name: 'Command API',
        status: cmdUp ? 'up' : 'down',
        workload: '—',
        details: cmdUp ? 'Accepting requests' : 'Unreachable',
      });

      const dbStatus = actuator?.components?.db?.status ?? (actuator ? 'UP' : null);
      list.push({
        id: 'database',
        name: 'Database',
        status: dbStatus === 'UP' ? 'up' : actuator ? 'down' : 'unknown',
        workload: '—',
        details: dbStatus ? (dbStatus === 'UP' ? 'Connected' : 'Disconnected') : 'Actuator not available',
      });

      const mcpStatus = actuator?.components?.mcp?.status ?? (actuator?.components?.mcp ? 'DOWN' : null);
      const mcpDetail = actuator?.components?.mcp?.details?.mcp ?? '';
      list.push({
        id: 'mcp',
        name: 'MCP / Agents',
        status: mcpStatus === 'UP' ? 'up' : mcpDetail === 'disabled' ? 'disabled' : actuator ? 'down' : 'unknown',
        workload: '—',
        details: mcpDetail === 'disabled' ? 'Not configured' : mcpStatus === 'UP' ? 'Reachable' : mcpDetail || '—',
      });

      list.push({ id: 'rag', name: 'RAG', status: 'disabled', workload: '—', details: 'Not configured (NoOp)' });
      list.push({
        id: 'commander',
        name: 'Commander',
        status: cmdUp ? 'up' : 'down',
        workload: 'Rule-based',
        details: 'In-process; AI Commander not configured',
      });

      const toolsCount = Array.isArray(tools) ? tools.length : 0;
      list.push({
        id: 'orchestrator',
        name: 'Orchestrator',
        status: cmdUp ? 'up' : 'down',
        workload: `${toolsCount} tools`,
        details: 'Plan execution, tool registry',
      });
      list.push({
        id: 'memory',
        name: 'Memory (T/P blobs)',
        status: cmdUp ? 'up' : 'down',
        workload: '—',
        details: 'Turn context + decision blobs',
      });
      list.push({
        id: 'audit',
        name: 'Audit',
        status: cmdUp ? 'up' : 'down',
        workload: '—',
        details: 'Command + step audit logs',
      });

      setSections(list);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to load system status');
      setSections([]);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    load();
  }, []);
  return { sections, loading, error, refresh: load };
}

function useOverviewStats(refreshTrigger: number): { stats: OverviewStats; loading: boolean; refresh: () => void } {
  const [stats, setStats] = useState<OverviewStats>({
    rulesCount: 0,
    commandRunsCount: 0,
    toolsCount: 0,
    lastRefreshed: null,
  });
  const [loading, setLoading] = useState(true);

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const [rules, commandAudit, tools] = await Promise.all([
        listRules().catch(() => []),
        getCommandAudit().catch(() => []),
        getTools().catch(() => []),
      ]);
      setStats({
        rulesCount: Array.isArray(rules) ? rules.length : 0,
        commandRunsCount: Array.isArray(commandAudit) ? commandAudit.length : 0,
        toolsCount: Array.isArray(tools) ? tools.length : 0,
        lastRefreshed: new Date(),
      });
    } catch {
      setStats((s) => ({ ...s, lastRefreshed: new Date() }));
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    load();
  }, [load, refreshTrigger]);
  return { stats, loading, refresh: load };
}

function buildMermaidDiagram(sections: SystemSection[]): string {
  const nodeId = (id: string) => id.replace(/-/g, '_');
  const lines: string[] = ['flowchart LR', '  subgraph backend[Backend]'];
  const backendIds = ['command-api', 'commander', 'orchestrator', 'memory', 'audit'];
  sections.filter((s) => backendIds.includes(s.id)).forEach((s) => {
    const n = nodeId(s.id);
    const statusLabel = s.status === 'up' ? 'UP' : s.status === 'down' ? 'DOWN' : s.status === 'disabled' ? 'OFF' : '?';
    lines.push(`    ${n}["${s.name} ${statusLabel}"]`);
  });
  lines.push('  end', '  subgraph deps[Dependencies]');
  const depIds = ['database', 'mcp', 'rag'];
  sections.filter((s) => depIds.includes(s.id)).forEach((s) => {
    const n = nodeId(s.id);
    const statusLabel = s.status === 'up' ? 'UP' : s.status === 'down' ? 'DOWN' : s.status === 'disabled' ? 'OFF' : '?';
    lines.push(`    ${n}["${s.name} ${statusLabel}"]`);
  });
  lines.push('  end');
  const c = nodeId('command-api');
  const cmd = nodeId('commander');
  const orch = nodeId('orchestrator');
  const mem = nodeId('memory');
  const aud = nodeId('audit');
  const db = nodeId('database');
  const mcp = nodeId('mcp');
  const rag = nodeId('rag');
  lines.push(`  ${c} --> ${cmd}`);
  lines.push(`  ${cmd} --> ${orch}`);
  lines.push(`  ${cmd} <--> ${mem}`);
  lines.push(`  ${orch} --> ${mem}`);
  lines.push(`  ${orch} --> ${aud}`);
  lines.push(`  ${orch} --> ${mcp}`);
  lines.push(`  ${mem} --> ${db}`);
  lines.push(`  ${aud} --> ${db}`);
  lines.push(`  ${orch} -.-> ${rag}`);
  sections.forEach((s) => {
    const n = nodeId(s.id);
    const color = s.status === 'up' ? '#22c55e' : s.status === 'down' ? '#ef4444' : s.status === 'disabled' ? '#94a3b8' : '#eab308';
    lines.push(`  style ${n} fill:${color}`);
  });
  return lines.join('\n');
}

function buildDataFlowDiagram(): string {
  return `flowchart LR
  subgraph flow[Request flow]
    A[Client] --> B[Command API]
    B --> C[Commander]
    C --> D[Plan]
    D --> E[Orchestrator]
    E --> F[Agents]
    F --> G[UI]
  end
  subgraph state[State]
    H[(Memory)]
    I[(Audit)]
  end
  C <--> H
  E --> H
  E --> I
  H --> J[(DB)]
  I --> J`;
}

const ADMIN_QUICK_LINKS = [
  { path: '/admin/rules', label: 'Command rules', icon: Shield },
  { path: '/admin/command-audit', label: 'Command audit', icon: ScrollText },
  { path: '/admin/step-audit', label: 'Step audit', icon: ListOrdered },
  { path: '/admin/tools', label: 'Tools', icon: Wrench },
  { path: '/admin/run-lookup', label: 'Run lookup', icon: Search },
  { path: '/admin/status', label: 'System status', icon: Activity },
  { path: '/admin/capabilities', label: 'Capabilities', icon: Layers },
] as const;

function sectionAdminLink(sectionId: string): string | null {
  const map: Record<string, string> = {
    'command-api': '/admin/status',
    database: '/admin/status',
    mcp: '/admin/status',
    audit: '/admin/command-audit',
    orchestrator: '/admin/tools',
  };
  return map[sectionId] ?? null;
}

export function AdminSystemOverview() {
  const { sections, loading, error, refresh } = useSystemSections();
  const [refreshTrigger, setRefreshTrigger] = useState(0);
  const { stats, loading: statsLoading, refresh: refreshStats } = useOverviewStats(refreshTrigger);
  const [selectedSection, setSelectedSection] = useState<SystemSection | null>(null);
  const mermaidRef = useRef<HTMLDivElement>(null);
  const flowRef = useRef<HTMLDivElement>(null);
  const [mermaidError, setMermaidError] = useState<string | null>(null);
  const [flowError, setFlowError] = useState<string | null>(null);

  const doRefresh = useCallback(() => {
    refresh();
    refreshStats();
    setRefreshTrigger((t) => t + 1);
  }, [refresh, refreshStats]);

  useEffect(() => {
    if (sections.length === 0 || !mermaidRef.current) return;
    const container = mermaidRef.current;
    const diagram = buildMermaidDiagram(sections);
    setMermaidError(null);
    container.innerHTML = '';
    let cancelled = false;
    const id = `mermaid-sys-${Date.now()}-${Math.random().toString(36).slice(2, 9)}`;
    mermaid
      .render(id, diagram)
      .then(({ svg }) => {
        if (cancelled || !container) return;
        container.innerHTML = svg;
        container.className = 'min-h-[160px] flex items-center justify-center bg-stone-50 rounded-lg p-4 [&_svg]:max-w-full [&_svg]:h-auto';
      })
      .catch((e) => {
        if (cancelled) return;
        setMermaidError(e instanceof Error ? e.message : 'Mermaid failed');
        if (container) {
          container.textContent = diagram;
          container.className = 'min-h-[160px] p-4 bg-stone-50 rounded-lg font-mono text-xs text-stone-600 whitespace-pre-wrap';
        }
      });
    return () => { cancelled = true; };
  }, [sections]);

  useEffect(() => {
    if (!flowRef.current) return;
    const container = flowRef.current;
    const diagram = buildDataFlowDiagram();
    setFlowError(null);
    container.innerHTML = '';
    let cancelled = false;
    const id = `mermaid-flow-${Date.now()}-${Math.random().toString(36).slice(2, 9)}`;
    mermaid
      .render(id, diagram)
      .then(({ svg }) => {
        if (cancelled || !container) return;
        container.innerHTML = svg;
        container.className = 'min-h-[140px] flex items-center justify-center bg-stone-50 rounded-lg p-4 [&_svg]:max-w-full [&_svg]:h-auto';
      })
      .catch((e) => {
        if (cancelled) return;
        setFlowError(e instanceof Error ? e.message : 'Diagram failed');
        if (container) {
          container.textContent = diagram;
          container.className = 'min-h-[140px] p-4 bg-stone-50 rounded-lg font-mono text-xs text-stone-600 whitespace-pre-wrap';
        }
      });
    return () => { cancelled = true; };
  }, []);

  const apiUp = sections.find((s) => s.id === 'command-api')?.status === 'up';
  const dbUp = sections.find((s) => s.id === 'database')?.status === 'up';

  return (
    <div className="p-8">
      <div className="mb-6 flex flex-wrap items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-semibold text-stone-900 tracking-tight">System overview</h1>
          <p className="text-stone-600 text-sm mt-1">
            Check status, connections, and all components in one place.
          </p>
        </div>
        <Button variant="outline" size="sm" onClick={doRefresh} disabled={loading}>
          {loading ? <Loader2 className="size-4 animate-spin" /> : <RefreshCw className="size-4" />}
          <span className="ml-1.5">Refresh all</span>
        </Button>
      </div>

      {error && (
        <div className="mb-4 p-3 rounded-lg bg-red-50 border border-red-200 text-red-800 text-sm">
          {error}
        </div>
      )}

      <Tabs defaultValue="overview" className="space-y-4">
        <TabsList className="bg-stone-100">
          <TabsTrigger value="overview">Overview</TabsTrigger>
          <TabsTrigger value="architecture">Architecture</TabsTrigger>
          <TabsTrigger value="components">Components</TabsTrigger>
        </TabsList>

        <TabsContent value="overview" className="space-y-6">
          <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-5">
            <Card className="border-stone-200/80 bg-white">
              <CardHeader className="pb-2">
                <CardTitle className="text-sm font-medium text-stone-600">Command API</CardTitle>
              </CardHeader>
              <CardContent>
                <span className={`text-lg font-semibold ${apiUp ? 'text-green-600' : 'text-red-600'}`}>
                  {apiUp ? 'UP' : 'DOWN'}
                </span>
                {stats.lastRefreshed && (
                  <p className="text-xs text-stone-500 mt-1">Checked at {stats.lastRefreshed.toLocaleTimeString()}</p>
                )}
              </CardContent>
            </Card>
            <Card className="border-stone-200/80 bg-white">
              <CardHeader className="pb-2">
                <CardTitle className="text-sm font-medium text-stone-600">Database</CardTitle>
              </CardHeader>
              <CardContent>
                <span className={`text-lg font-semibold ${dbUp ? 'text-green-600' : 'text-amber-600'}`}>
                  {dbUp ? 'UP' : 'Unknown'}
                </span>
              </CardContent>
            </Card>
            <Card className="border-stone-200/80 bg-white">
              <CardHeader className="pb-2">
                <CardTitle className="text-sm font-medium text-stone-600">Rules</CardTitle>
              </CardHeader>
              <CardContent>
                {statsLoading ? (
                  <Loader2 className="size-5 animate-spin text-stone-400" />
                ) : (
                  <span className="text-lg font-semibold text-stone-900">{stats.rulesCount}</span>
                )}
                <p className="text-xs text-stone-500 mt-1">Command-role rules</p>
              </CardContent>
            </Card>
            <Card className="border-stone-200/80 bg-white">
              <CardHeader className="pb-2">
                <CardTitle className="text-sm font-medium text-stone-600">Tools</CardTitle>
              </CardHeader>
              <CardContent>
                {statsLoading ? (
                  <Loader2 className="size-5 animate-spin text-stone-400" />
                ) : (
                  <span className="text-lg font-semibold text-stone-900">{stats.toolsCount}</span>
                )}
                <p className="text-xs text-stone-500 mt-1">Registered</p>
              </CardContent>
            </Card>
            <Card className="border-stone-200/80 bg-white">
              <CardHeader className="pb-2">
                <CardTitle className="text-sm font-medium text-stone-600">Command runs</CardTitle>
              </CardHeader>
              <CardContent>
                {statsLoading ? (
                  <Loader2 className="size-5 animate-spin text-stone-400" />
                ) : (
                  <span className="text-lg font-semibold text-stone-900">{stats.commandRunsCount}</span>
                )}
                <p className="text-xs text-stone-500 mt-1">Audit entries</p>
              </CardContent>
            </Card>
          </div>
          <Card className="border-stone-200/80 bg-white">
            <CardHeader className="pb-2">
              <CardTitle className="text-base">Check everything</CardTitle>
              <CardDescription>Quick links to every admin area.</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="grid gap-2 sm:grid-cols-2 lg:grid-cols-4">
                {ADMIN_QUICK_LINKS.map(({ path, label, icon: Icon }) => (
                  <Link key={path} to={path}>
                    <div className="flex items-center gap-2 rounded-lg border border-stone-200/80 bg-stone-50/50 px-4 py-3 text-sm font-medium text-stone-700 hover:border-amber-300 hover:bg-amber-50/50 transition-colors">
                      <Icon className="size-4 text-amber-600" />
                      {label}
                      <ExternalLink className="size-3.5 ml-auto text-stone-400" />
                    </div>
                  </Link>
                ))}
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="architecture" className="space-y-6">
          <Card className="border-stone-200/80 bg-white">
            <CardHeader className="pb-2">
              <CardTitle className="text-base">Interactive diagram</CardTitle>
              <CardDescription>Click a node to see details. Pan and zoom to explore.</CardDescription>
            </CardHeader>
            <CardContent>
              {loading && sections.length === 0 ? (
                <div className="flex items-center gap-2 py-12 text-stone-500">
                  <Loader2 className="size-5 animate-spin" />
                  Loading…
                </div>
              ) : (
                <div className="flex gap-4 flex-col lg:flex-row">
                  <div className="flex-1 min-w-0">
                    <SystemOverviewFlow
                      sections={sections}
                      onNodeSelect={setSelectedSection}
                      selectedId={selectedSection?.id ?? null}
                    />
                  </div>
                  {selectedSection && (
                    <Card className="w-full lg:w-72 flex-shrink-0 border-amber-200 bg-amber-50/30">
                      <CardHeader className="pb-2">
                        <CardTitle className="text-sm">{selectedSection.name}</CardTitle>
                        <CardDescription>Component details</CardDescription>
                      </CardHeader>
                      <CardContent className="space-y-2 text-sm">
                        <div>
                          <span className="text-stone-500">Status:</span>{' '}
                          <span className={`font-medium ${
                            selectedSection.status === 'up' ? 'text-green-700' :
                            selectedSection.status === 'down' ? 'text-red-700' :
                            selectedSection.status === 'disabled' ? 'text-stone-600' : 'text-amber-700'
                          }`}>
                            {selectedSection.status.toUpperCase()}
                          </span>
                        </div>
                        <div><span className="text-stone-500">Workload:</span> {selectedSection.workload}</div>
                        <div><span className="text-stone-500">Details:</span> {selectedSection.details}</div>
                        {sectionAdminLink(selectedSection.id) && (
                          <Link to={sectionAdminLink(selectedSection.id)!}>
                            <Button variant="outline" size="sm" className="mt-2">
                              Open in admin <ExternalLink className="size-3 ml-1" />
                            </Button>
                          </Link>
                        )}
                      </CardContent>
                    </Card>
                  )}
                </div>
              )}
            </CardContent>
          </Card>
          <Card className="border-stone-200/80 bg-white">
            <CardHeader className="pb-2">
              <CardTitle className="text-base">Data flow (Mermaid)</CardTitle>
              <CardDescription>Request path: Client → API → Commander → Orchestrator → Agents; Memory & Audit → DB.</CardDescription>
            </CardHeader>
            <CardContent>
              <div ref={flowRef} className="min-h-[140px] flex items-center justify-center bg-stone-50 rounded-lg p-4" />
              {flowError && <p className="text-sm text-amber-700 mt-2">Diagram: {flowError}</p>}
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="components" className="space-y-4">
          <Card className="border-stone-200/80 bg-white">
            <CardHeader className="pb-4">
              <CardTitle className="text-base">All sections: status and workload</CardTitle>
              <CardDescription>Every component. Use Actions to open the relevant admin page.</CardDescription>
            </CardHeader>
            <CardContent>
              <Table>
                <TableHeader>
                  <TableRow className="border-stone-200">
                    <TableHead className="text-stone-600">Section</TableHead>
                    <TableHead className="text-stone-600">Status</TableHead>
                    <TableHead className="text-stone-600">Workload</TableHead>
                    <TableHead className="text-stone-600">Details</TableHead>
                    <TableHead className="text-stone-600 text-right">Actions</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {sections.length === 0 && !loading ? (
                    <TableRow>
                      <TableCell colSpan={5} className="text-stone-500 py-8 text-center">
                        No data. Check API connection and refresh.
                      </TableCell>
                    </TableRow>
                  ) : (
                    sections.map((s) => (
                      <TableRow key={s.id} className="border-stone-100">
                        <TableCell className="font-medium text-stone-900">{s.name}</TableCell>
                        <TableCell>
                          <span
                            className={`text-xs font-medium px-1.5 py-0.5 rounded ${
                              s.status === 'up' ? 'bg-green-100 text-green-800' :
                              s.status === 'down' ? 'bg-red-100 text-red-800' :
                              s.status === 'disabled' ? 'bg-stone-100 text-stone-600' : 'bg-amber-100 text-amber-800'
                            }`}
                          >
                            {s.status.toUpperCase()}
                          </span>
                        </TableCell>
                        <TableCell className="text-stone-700">{s.workload}</TableCell>
                        <TableCell className="text-stone-600 text-sm">{s.details}</TableCell>
                        <TableCell className="text-right">
                          {sectionAdminLink(s.id) ? (
                            <Link to={sectionAdminLink(s.id)!}>
                              <Button variant="ghost" size="sm" className="text-amber-700 hover:text-amber-800">
                                Check <ExternalLink className="size-3 ml-1 inline" />
                              </Button>
                            </Link>
                          ) : (
                            <span className="text-stone-400 text-xs">—</span>
                          )}
                        </TableCell>
                      </TableRow>
                    ))
                  )}
                </TableBody>
              </Table>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  );
}
