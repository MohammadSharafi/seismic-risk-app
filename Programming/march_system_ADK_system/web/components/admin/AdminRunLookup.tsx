import React, { useState } from 'react';
import { adminApiBase, getRunStatus, type RunStatusItem } from '../../api/adminApi';
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from '../ui/card';
import { Button } from '../ui/button';
import { Input } from '../ui/input';
import { Search, Loader2, ExternalLink } from 'lucide-react';

function formatDate(s: string | null): string {
  if (!s) return '—';
  try {
    return new Date(s).toLocaleString();
  } catch {
    return s;
  }
}

export function AdminRunLookup() {
  const [runId, setRunId] = useState('');
  const [run, setRun] = useState<RunStatusItem | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const lookup = async () => {
    const id = runId.trim();
    if (!id) return;
    setLoading(true);
    setError(null);
    setRun(null);
    try {
      const data = await getRunStatus(id);
      setRun(data);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Lookup failed');
    } finally {
      setLoading(false);
    }
  };

  const base = adminApiBase();
  const streamFullUrl = run?.streamUrl && base ? `${base}${run.streamUrl}` : null;

  return (
    <div className="p-8">
      <div className="mb-6">
        <h1 className="text-2xl font-semibold text-stone-900 tracking-tight">Run lookup</h1>
        <p className="text-stone-600 text-sm mt-1">
          Look up a command run by run ID (from 202 response or audit).
        </p>
      </div>

      <Card className="border-stone-200/80 bg-white mb-6">
        <CardHeader className="pb-4">
          <CardTitle className="text-base">Lookup by run ID</CardTitle>
          <CardDescription>Enter the run ID and click Search.</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="flex gap-2">
            <Input
              placeholder="e.g. run_abc123"
              value={runId}
              onChange={(e) => setRunId(e.target.value)}
              onKeyDown={(e) => e.key === 'Enter' && lookup()}
              className="font-mono"
            />
            <Button onClick={lookup} disabled={loading || !runId.trim()} className="bg-amber-600 hover:bg-amber-700">
              {loading ? <Loader2 className="size-4 animate-spin" /> : <Search className="size-4" />}
              <span className="ml-1.5">Search</span>
            </Button>
          </div>
        </CardContent>
      </Card>

      {error && (
        <div className="mb-4 p-3 rounded-lg bg-red-50 border border-red-200 text-red-800 text-sm">
          {error}
        </div>
      )}

      {run && (
        <Card className="border-stone-200/80 bg-white">
          <CardHeader className="pb-4">
            <CardTitle className="text-base">Run details</CardTitle>
            <CardDescription>Run ID: {run.runId}</CardDescription>
          </CardHeader>
          <CardContent>
            <dl className="grid gap-3 sm:grid-cols-2">
              <div>
                <dt className="text-xs font-medium text-stone-500 uppercase tracking-wider">Status</dt>
                <dd>
                  <span className={`text-sm font-medium px-1.5 py-0.5 rounded ${
                    run.status === 'COMPLETED' ? 'bg-green-100 text-green-800' :
                    run.status === 'RUNNING' ? 'bg-amber-100 text-amber-800' :
                    run.status === 'PENDING' ? 'bg-stone-100 text-stone-700' : 'bg-stone-100'
                  }`}>
                    {run.status}
                  </span>
                </dd>
              </div>
              <div>
                <dt className="text-xs font-medium text-stone-500 uppercase tracking-wider">Command</dt>
                <dd className="text-sm text-stone-900 font-mono">{run.command ?? '—'}</dd>
              </div>
              <div>
                <dt className="text-xs font-medium text-stone-500 uppercase tracking-wider">Tenant</dt>
                <dd className="text-sm text-stone-700">{run.tenantId ?? '—'}</dd>
              </div>
              <div>
                <dt className="text-xs font-medium text-stone-500 uppercase tracking-wider">Patient</dt>
                <dd className="text-sm text-stone-700">{run.patientId ?? '—'}</dd>
              </div>
              <div>
                <dt className="text-xs font-medium text-stone-500 uppercase tracking-wider">Created</dt>
                <dd className="text-sm text-stone-600">{formatDate(run.createdAt)}</dd>
              </div>
              <div>
                <dt className="text-xs font-medium text-stone-500 uppercase tracking-wider">Completed</dt>
                <dd className="text-sm text-stone-600">{formatDate(run.completedAt)}</dd>
              </div>
            </dl>
            {streamFullUrl && (
              <div className="mt-4 pt-4 border-t border-stone-200">
                <dt className="text-xs font-medium text-stone-500 uppercase tracking-wider mb-1">Stream URL</dt>
                <dd className="flex items-center gap-2">
                  <a
                    href={streamFullUrl}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="text-sm text-amber-600 hover:underline font-mono truncate max-w-md"
                  >
                    {streamFullUrl}
                  </a>
                  <a href={streamFullUrl} target="_blank" rel="noopener noreferrer" aria-label="Open stream">
                    <ExternalLink className="size-4 text-stone-400" />
                  </a>
                </dd>
              </div>
            )}
          </CardContent>
        </Card>
      )}
    </div>
  );
}
