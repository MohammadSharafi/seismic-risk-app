import React, { useState, useEffect } from 'react';
import { getCapabilities, type CapabilityItem } from '../../api/adminApi';
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from '../ui/card';
import { Button } from '../ui/button';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '../ui/table';
import { RefreshCw, Loader2 } from 'lucide-react';

const CATEGORIES = ['DATA_DAN', 'AGENT_OR_SIMULATION'] as const;

export function AdminCapabilities() {
  const [items, setItems] = useState<CapabilityItem[]>([]);
  const [category, setCategory] = useState<string>('');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const load = async () => {
    setLoading(true);
    setError(null);
    try {
      const list = await getCapabilities(category || undefined);
      setItems(list);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to load capabilities');
      setItems([]);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    load();
  }, [category]);

  return (
    <div className="p-8">
      <div className="mb-6">
        <h1 className="text-2xl font-semibold text-stone-900 tracking-tight">Capabilities</h1>
        <p className="text-stone-600 text-sm mt-1">
          Catalog of commands and URLs by category (data vs agent/simulation).
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
              <CardTitle className="text-base">Capability catalog</CardTitle>
              <CardDescription>Track which commands are data-only vs LLM/simulation.</CardDescription>
            </div>
            <div className="flex items-center gap-2">
              <select
                value={category}
                onChange={(e) => setCategory(e.target.value)}
                className="rounded-md border border-stone-300 bg-white px-3 py-1.5 text-sm text-stone-700"
              >
                <option value="">All</option>
                {CATEGORIES.map((c) => (
                  <option key={c} value={c}>{c}</option>
                ))}
              </select>
              <Button variant="outline" size="sm" onClick={load} disabled={loading}>
                {loading ? <Loader2 className="size-4 animate-spin" /> : <RefreshCw className="size-4" />}
                <span className="ml-1.5">Refresh</span>
              </Button>
            </div>
          </div>
        </CardHeader>
        <CardContent>
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
                    <TableHead className="text-stone-600">Slug</TableHead>
                    <TableHead className="text-stone-600">Type</TableHead>
                    <TableHead className="text-stone-600">Category</TableHead>
                    <TableHead className="text-stone-600">Tool</TableHead>
                    <TableHead className="text-stone-600">Description</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {items.length === 0 ? (
                    <TableRow>
                      <TableCell colSpan={5} className="text-stone-500 py-8 text-center">
                        No capabilities. Seed the catalog or check API.
                      </TableCell>
                    </TableRow>
                  ) : (
                    items.map((c) => (
                      <TableRow key={c.slug} className="border-stone-100">
                        <TableCell className="font-mono text-sm text-stone-900">{c.slug}</TableCell>
                        <TableCell className="text-stone-700">{c.type}</TableCell>
                        <TableCell>
                          <span className={`text-xs px-1.5 py-0.5 rounded ${
                            c.category === 'AGENT_OR_SIMULATION' ? 'bg-amber-100 text-amber-800' : 'bg-stone-100 text-stone-700'
                          }`}>
                            {c.category}
                          </span>
                        </TableCell>
                        <TableCell className="font-mono text-xs text-stone-600">{c.toolName ?? '—'}</TableCell>
                        <TableCell className="text-stone-600 text-sm max-w-xs truncate" title={c.description ?? ''}>{c.description ?? '—'}</TableCell>
                      </TableRow>
                    ))
                  )}
                </TableBody>
              </Table>
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
