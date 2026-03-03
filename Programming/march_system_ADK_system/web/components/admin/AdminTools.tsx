import React, { useState, useEffect, useMemo } from 'react';
import { getTools, type ToolDescriptor } from '../../api/adminApi';
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from '../ui/card';
import { Button } from '../ui/button';
import { Input } from '../ui/input';
import { RefreshCw, Loader2, ChevronDown, ChevronUp } from 'lucide-react';

export function AdminTools() {
  const [tools, setTools] = useState<ToolDescriptor[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [expandedName, setExpandedName] = useState<string | null>(null);
  const [search, setSearch] = useState('');

  const load = async () => {
    setLoading(true);
    setError(null);
    try {
      const list = await getTools();
      setTools(list);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to load tools');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    load();
  }, []);

  const filtered = useMemo(() => {
    if (!search.trim()) return tools;
    const q = search.trim().toLowerCase();
    return tools.filter(
      (t) =>
        t.name.toLowerCase().includes(q) ||
        (t.description ?? '').toLowerCase().includes(q)
    );
  }, [tools, search]);

  return (
    <div className="p-8">
      <div className="mb-6">
        <h1 className="text-2xl font-semibold text-stone-900 tracking-tight">Tools</h1>
        <p className="text-stone-600 text-sm mt-1">
          Registered tools available to the command engine. Search by name or description.
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
              <CardTitle className="text-base">Tool registry</CardTitle>
              <CardDescription>Discovery and admin; used by MCP and policy.</CardDescription>
            </div>
            <div className="flex items-center gap-2">
              <Input
                placeholder="Search tools…"
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                className="w-48"
              />
              <Button variant="outline" size="sm" onClick={load} disabled={loading}>
                {loading ? <Loader2 className="size-4 animate-spin" /> : <RefreshCw className="size-4" />}
                <span className="ml-1.5">Refresh</span>
              </Button>
            </div>
          </div>
        </CardHeader>
        <CardContent>
          {loading && tools.length === 0 ? (
            <div className="flex items-center gap-2 py-8 text-stone-500">
              <Loader2 className="size-5 animate-spin" />
              Loading…
            </div>
          ) : (
            <div className="space-y-2">
              {filtered.length === 0 ? (
                <p className="text-stone-500 py-6 text-center">
                  {tools.length === 0 ? 'No tools registered.' : 'No tools match the search.'}
                </p>
              ) : (
                filtered.map((t) => (
                    <div
                      key={t.name}
                      className="rounded-lg border border-stone-200/80 bg-stone-50/50 overflow-hidden"
                    >
                      <button
                        type="button"
                        className="w-full flex items-center justify-between gap-4 px-4 py-3 text-left hover:bg-stone-100/80 transition-colors"
                        onClick={() => setExpandedName(expandedName === t.name ? null : t.name)}
                      >
                        <div className="min-w-0">
                          <span className="font-medium text-stone-900 font-mono text-sm">{t.name}</span>
                          {t.description && (
                            <p className="text-stone-600 text-sm mt-0.5 truncate">{t.description}</p>
                          )}
                        </div>
                        {expandedName === t.name ? <ChevronUp className="size-4 text-stone-400 flex-shrink-0" /> : <ChevronDown className="size-4 text-stone-400 flex-shrink-0" />}
                      </button>
                      {expandedName === t.name && t.parametersSchema != null && (
                        <div className="px-4 pb-4 pt-0">
                          <pre className="text-xs bg-stone-900 text-stone-200 p-3 rounded-md overflow-x-auto">
                            {JSON.stringify(t.parametersSchema, null, 2)}
                          </pre>
                        </div>
                      )}
                    </div>
                  ))
              )}
              {search.trim() && filtered.length > 0 && (
                <p className="text-xs text-stone-500 pt-2">Showing {filtered.length} of {tools.length} tools.</p>
              )}
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
