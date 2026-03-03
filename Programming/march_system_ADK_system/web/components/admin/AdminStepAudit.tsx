import React, { useState, useEffect, useMemo } from 'react';
import { getStepAudit, type StepAuditItem } from '../../api/adminApi';
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

function toCsv(items: StepAuditItem[]): string {
  const header = 'Time,Flow,Step,Path,Run ID,Tenant,Patient,Details';
  const rows = items.map((a) =>
    [formatDate(a.createdAt), a.flow ?? '', a.step ?? '', a.path ?? '', a.runId ?? '', a.tenantId ?? '', a.patientId ?? '', a.details ?? '']
      .map((c) => `"${String(c).replace(/"/g, '""')}"`)
      .join(',')
  );
  return [header, ...rows].join('\n');
}

export function AdminStepAudit() {
  const [items, setItems] = useState<StepAuditItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [filterFlow, setFilterFlow] = useState('');
  const [filterStep, setFilterStep] = useState('');
  const [filterSearch, setFilterSearch] = useState('');
  const [limit, setLimit] = useState(500);

  const load = async () => {
    setLoading(true);
    setError(null);
    try {
      const list = await getStepAudit();
      setItems(list);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to load step audit');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    load();
  }, []);

  const filtered = useMemo(() => {
    let list = items;
    if (filterFlow.trim()) {
      const f = filterFlow.trim().toLowerCase();
      list = list.filter((a) => (a.flow ?? '').toLowerCase().includes(f));
    }
    if (filterStep.trim()) {
      const s = filterStep.trim().toLowerCase();
      list = list.filter((a) => (a.step ?? '').toLowerCase().includes(s));
    }
    if (filterSearch.trim()) {
      const q = filterSearch.trim().toLowerCase();
      list = list.filter(
        (a) =>
          (a.runId ?? '').toLowerCase().includes(q) ||
          (a.path ?? '').toLowerCase().includes(q) ||
          (a.details ?? '').toLowerCase().includes(q)
      );
    }
    return list.slice(0, limit);
  }, [items, filterFlow, filterStep, filterSearch, limit]);

  const exportCsv = () => {
    const csv = toCsv(filtered);
    const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
    const a = document.createElement('a');
    a.href = URL.createObjectURL(blob);
    a.download = `step-audit-${new Date().toISOString().slice(0, 10)}.csv`;
    a.click();
    URL.revokeObjectURL(a.href);
  };

  return (
    <div className="p-8">
      <div className="mb-6">
        <h1 className="text-2xl font-semibold text-stone-900 tracking-tight">Step audit</h1>
        <p className="text-stone-600 text-sm mt-1">
          Recent step entries (top 500). Filter by flow, step, or search. Export to CSV.
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
              <CardTitle className="text-base">Step audit log</CardTitle>
              <CardDescription>Flow, step, path, and details for tracing and compliance.</CardDescription>
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
              placeholder="Search run ID, path, details…"
              value={filterSearch}
              onChange={(e) => setFilterSearch(e.target.value)}
              className="max-w-xs"
            />
            <Input
              placeholder="Flow"
              value={filterFlow}
              onChange={(e) => setFilterFlow(e.target.value)}
              className="w-28"
            />
            <Input
              placeholder="Step"
              value={filterStep}
              onChange={(e) => setFilterStep(e.target.value)}
              className="w-32"
            />
            <select
              value={limit}
              onChange={(e) => setLimit(Number(e.target.value))}
              className="rounded-md border border-stone-300 bg-white px-3 py-1.5 text-sm"
            >
              <option value={100}>Show 100</option>
              <option value={200}>Show 200</option>
              <option value={500}>Show 500</option>
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
                    <TableHead className="text-stone-600">Flow</TableHead>
                    <TableHead className="text-stone-600">Step</TableHead>
                    <TableHead className="text-stone-600">Path</TableHead>
                    <TableHead className="text-stone-600">Run ID</TableHead>
                    <TableHead className="text-stone-600">Details</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {filtered.length === 0 ? (
                    <TableRow>
                      <TableCell colSpan={6} className="text-stone-500 py-8 text-center">
                        {items.length === 0 ? 'No step audit entries yet.' : 'No rows match the filters.'}
                      </TableCell>
                    </TableRow>
                  ) : (
                    filtered.map((a) => (
                      <TableRow key={a.id} className="border-stone-100">
                        <TableCell className="text-stone-600 text-xs whitespace-nowrap">{formatDate(a.createdAt)}</TableCell>
                        <TableCell className="text-stone-800">{a.flow ?? '—'}</TableCell>
                        <TableCell className="text-stone-700">{a.step ?? '—'}</TableCell>
                        <TableCell className="text-stone-600 font-mono text-xs max-w-[10rem] truncate" title={a.path ?? ''}>{a.path ?? '—'}</TableCell>
                        <TableCell className="font-mono text-xs text-stone-600 truncate max-w-[6rem]" title={a.runId ?? ''}>{a.runId ?? '—'}</TableCell>
                        <TableCell className="text-stone-600 text-xs max-w-[12rem] truncate" title={a.details ?? ''}>{a.details ?? '—'}</TableCell>
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
