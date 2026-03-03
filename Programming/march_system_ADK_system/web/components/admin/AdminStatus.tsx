import React, { useState, useEffect } from 'react';
import { getHealth, type HealthResponse } from '../../api/adminApi';
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from '../ui/card';
import { Button } from '../ui/button';
import { RefreshCw, Loader2, CheckCircle, XCircle } from 'lucide-react';

export function AdminStatus() {
  const [health, setHealth] = useState<HealthResponse | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const load = async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await getHealth();
      setHealth(data);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Health check failed');
      setHealth(null);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    load();
  }, []);

  const up = health?.status === 'up' || health?.commandApi === true;

  return (
    <div className="p-8">
      <div className="mb-6">
        <h1 className="text-2xl font-semibold text-stone-900 tracking-tight">System status</h1>
        <p className="text-stone-600 text-sm mt-1">
          Command API health and availability.
        </p>
      </div>

      {error && (
        <div className="mb-4 p-3 rounded-lg bg-red-50 border border-red-200 text-red-800 text-sm">
          {error}
        </div>
      )}

      <Card className="border-stone-200/80 bg-white">
        <CardHeader className="pb-4">
          <div className="flex items-center justify-between">
            <div>
              <CardTitle className="text-base">Command API</CardTitle>
              <CardDescription>Liveness and readiness.</CardDescription>
            </div>
            <Button variant="outline" size="sm" onClick={load} disabled={loading}>
              {loading ? <Loader2 className="size-4 animate-spin" /> : <RefreshCw className="size-4" />}
              <span className="ml-1.5">Refresh</span>
            </Button>
          </div>
        </CardHeader>
        <CardContent>
          {loading && !health ? (
            <div className="flex items-center gap-2 py-6 text-stone-500">
              <Loader2 className="size-5 animate-spin" />
              Checking…
            </div>
          ) : (
            <div className="flex items-center gap-3 py-2">
              {up ? (
                <CheckCircle className="size-6 text-green-600" />
              ) : (
                <XCircle className="size-6 text-red-600" />
              )}
              <div>
                <span className={`font-medium ${up ? 'text-green-800' : 'text-red-800'}`}>
                  {up ? 'Up' : 'Down or unknown'}
                </span>
                {health && (
                  <pre className="text-xs text-stone-500 mt-1 bg-stone-50 p-2 rounded overflow-x-auto">
                    {JSON.stringify(health, null, 2)}
                  </pre>
                )}
              </div>
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
