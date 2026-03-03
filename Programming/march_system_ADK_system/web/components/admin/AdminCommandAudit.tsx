import React, { useState, useEffect, useMemo } from 'react';
import { getCommandAudit, type CommandAuditItem } from '../../api/adminApi';
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from '../ui/card';
import { Button } from '../ui/button';
import { Input } from '../ui/input';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '../ui/table';
import { RefreshCw, Loader2, Download } from 'lucide-react';

function formatDate(s: string | null): string {
  if (!s) return '—';
  try {
    const d = new Date(s);
    return d.toLocaleString();
  } catch {
    return s;
  }
}

function toCsv(items: CommandAuditItem[]): string {
  const header = 'Time,Run ID,Command,Tool,Status,Tenant,Patient';
  const rows = items.map((a) =>
    [formatDate(a.createdAt), a.runId ?? '', a.command ?? '', a.toolName ?? '', a.status ?? '', a.tenantId ?? '', a.patientId ?? '']
      .map((c) => `"${String(c).replace(/"/g, '""')}"`)
      .join(',')
  );
  return [header, ...rows].join('\n');
}

export function AdminCommandAudit() {
  const [items, setItems] = useState<CommandAuditItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [filterTenant, setFilterTenant] = useState('');
  const [filterPatient, setFilterPatient] = useState('');
  const [filterStatus, setFilterStatus] = useState('');
  const [filterSearch, setFilterSearch] = useState('');
  const [limit, setLimit] = useState(200);

  const load = async () => {
    setLoading(true);
    setError(null);
    try {
      const list = await getCommandAudit();
      setItems(list);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to load audit');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    load();
  }, []);

  const filtered = useMemo(() => {
    let list = items;
    if (filterTenant.trim()) {
      const t = filterTenant.trim().toLowerCase();
      list = list.filter((a) => (a.tenantId ?? '').toLowerCase().includes(t));
    }
    if (filterPatient.trim()) {
      const p = filterPatient.trim().toLowerCase();
      list = list.filter((a) => (a.patientId ?? '').toLowerCase().includes(p));
    }
    if (filterStatus.trim()) {
      const s = filterStatus.trim().toLowerCase();
      list = list.filter((a) => (a.status ?? '').toLowerCase().includes(s));
    }
    if (filterSearch.trim()) {
      const q = filterSearch.trim().toLowerCase();
      list = list.filter(
        (a) =>
          (a.runId ?? '').toLowerCase().includes(q) ||
          (a.command ?? '').toLowerCase().includes(q) ||
          (a.toolName ?? '').toLowerCase().includes(q)
      );
    }
    return list.slice(0, limit);
  }, [items, filterTenant, filterPatient, filterStatus, filterSearch, limit]);

  const exportCsv = () => {
    const csv = toCsv(filtered);
    const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
    const a = document.createElement('a');
    a.href = URL.createObjectURL(blob);
    a.download = `command-audit-${new Date().toISOString().slice(0, 10)}.csv`;
    a.click();
    URL.revokeObjectURL(a.href);
  };

  return (
    <div className="p-8">
      <div className="mb-6">
        <h1 className="text-2xl font-semibold text-stone-900 tracking-tight">Command audit</h1>
        <p className="text-stone-600 text-sm mt-1">
          Recent command runs (top 200). Filter by tenant, patient, status, or search. Export to CSV.
        </p>
      </div>

      {error && (
        <div className="mb-4 p-3 rounded-lg bg-red-50 border border-red-200 text-red-800 text-sm">
          {error}
        </div>
      )}

      <Card className="border-stone-200/80 bg-white">
        <CardHeader className="pb-4">
          <div className="flex flex-wrap items-center justify-between gap-4">
            <div>
              <CardTitle className="text-base">Command audit log</CardTitle>
              <CardDescription>Every command run writes here; access restricted to admin/auditor when JWT is enabled.</CardDescription>
            </div>
            <div className="flex items-center gap-2">
              <Button variant="outline" size="sm" onClick={exportCsv} disabled={filtered.length === 0}>
                <Download className="size-4" />
                <span className="ml-1.5">Export CSV</span>
              </Button>
              <Button variant="outline" size="sm" onClick={load} disabled={loading}>
                {loading ? <Loader2 className="size-4 animate-spin" /> : <RefreshCw className="size-4" />}
                <span className="ml-1.5">Refresh</span>
              </Button>
            </div>
          </div>
        </CardHeader>
        <CardContent>
          <div className="flex flex-wrap gap-3 mb-4">
            <Input
              placeholder="Search run ID, command, tool…"
              value={filterSearch}
              onChange={(e) => setFilterSearch(e.target.value)}
              className="max-w-xs"
            />
            <Input
              placeholder="Tenant"
              value={filterTenant}
              onChange={(e) => setFilterTenant(e.target.value)}
              className="w-28"
            />
            <Input
              placeholder="Patient"
              value={filterPatient}
              onChange={(e) => setFilterPatient(e.target.value)}
              className="w-28"
            />
            <Input
              placeholder="Status"
              value={filterStatus}
              onChange={(e) => setFilterStatus(e.target.value)}
              className="w-36"
            />
            <select
              value={limit}
              onChange={(e) => setLimit(Number(e.target.value))}
              className="rounded-md border border-stone-300 bg-white px-3 py-1.5 text-sm"
            >
              <option value={50}>Show 50</option>
              <option value={100}>Show 100</option>
              <option value={200}>Show 200</option>
            </select>
          </div>
          {loading && items.length === 0 ? (
            <div className="flex items-center gap-2 py-8 text-stone-500">
              <Loader2 className="size-5 animate-spin" />
              Loading…
            </div>
          ) : (
            <div className="overflow-x-auto">
              <Table>
                <TableHeader>
                  <TableRow className="border-stone-200">
                    <TableHead className="text-stone-600">Time</TableHead>
                    <TableHead className="text-stone-600">Run ID</TableHead>
                    <TableHead className="text-stone-600">Command</TableHead>
                    <TableHead className="text-stone-600">Tool</TableHead>
                    <TableHead className="text-stone-600">Status</TableHead>
                    <TableHead className="text-stone-600">Tenant</TableHead>
                    <TableHead className="text-stone-600">Patient</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {filtered.length === 0 ? (
                    <TableRow>
                      <TableCell colSpan={7} className="text-stone-500 py-8 text-center">
                        {items.length === 0 ? 'No command audit entries yet.' : 'No rows match the filters.'}
                      </TableCell>
                    </TableRow>
                  ) : (
                    filtered.map((a) => (
                      <TableRow key={a.id} className="border-stone-100">
                        <TableCell className="text-stone-600 text-xs whitespace-nowrap">{formatDate(a.createdAt)}</TableCell>
                        <TableCell className="font-mono text-xs text-stone-700 truncate max-w-[8rem]" title={a.runId ?? ''}>{a.runId ?? '—'}</TableCell>
                        <TableCell className="text-stone-900">{a.command ?? '—'}</TableCell>
                        <TableCell className="text-stone-700">{a.toolName ?? '—'}</TableCell>
                        <TableCell>
                          <span className={`text-xs px-1.5 py-0.5 rounded ${a.status === 'command_complete' ? 'bg-green-100 text-green-800' : a.status === 'command_denied' ? 'bg-red-100 text-red-800' : 'bg-stone-100 text-stone-700'}`}>
                            {a.status ?? '—'}
                          </span>
                        </TableCell>
                        <TableCell className="text-stone-600">{a.tenantId ?? '—'}</TableCell>
                        <TableCell className="text-stone-600">{a.patientId ?? '—'}</TableCell>
                      </TableRow>
                    ))
                  )}
                </TableBody>
              </Table>
              {filtered.length > 0 && (
                <p className="text-xs text-stone-500 mt-2">Showing {filtered.length} of {items.length} entries.</p>
              )}
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
