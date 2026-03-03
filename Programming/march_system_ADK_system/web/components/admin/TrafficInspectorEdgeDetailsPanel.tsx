import React from 'react';
import { Card, CardHeader, CardTitle, CardContent } from '../ui/card';
import type {
  AggregatedTrafficEdge,
  TrafficInspectorEdgeEndpoint,
  TrafficInspectorEvent,
} from '../../types/trafficInspector';
import { edgeColor } from './TrafficInspectorCustomEdge';

export interface TrafficInspectorEdgeDetailsPanelProps {
  edge: AggregatedTrafficEdge | null;
  sourceLabel?: string;
  targetLabel?: string;
  /** Events for this edge (source/dest match) to show last 10 requests and latency percentiles */
  edgeEvents?: TrafficInspectorEvent[];
}

function percentile(sorted: number[], p: number): number {
  if (sorted.length === 0) return 0;
  const idx = Math.ceil(sorted.length * (p / 100)) - 1;
  return sorted[Math.max(0, idx)];
}

export function TrafficInspectorEdgeDetailsPanel({
  edge,
  sourceLabel,
  targetLabel,
  edgeEvents = [],
}: TrafficInspectorEdgeDetailsPanelProps) {
  if (!edge) {
    return (
      <Card className="border-stone-200/80 bg-stone-50/50" data-testid="traffic-inspector-edge-details-empty">
        <CardContent className="py-6 text-center text-stone-500 text-sm">
          Click an edge on the topology to see edge name, contract, last 10 requests, latency percentiles, error rate, and payload size.
        </CardContent>
      </Card>
    );
  }

  const color = edgeColor(edge.errorRate, edge.avgLatencyMs);
  const last10 = edgeEvents.slice(-10);
  const latencies = last10.map((e) => e.latencyMs).filter((n) => n >= 0);
  const sorted = [...latencies].sort((a, b) => a - b);
  const p50 = percentile(sorted, 50);
  const p95 = percentile(sorted, 95);
  const p99 = percentile(sorted, 99);
  const errors1h = edgeEvents.filter((e) => e.status === 'error' || (e.statusCode != null && e.statusCode >= 400)).length;
  const errRate1h = edgeEvents.length > 0 ? (errors1h / edgeEvents.length) * 100 : 0;
  const avgPayload =
    edgeEvents.length > 0
      ? Math.round(
          edgeEvents.reduce(
            (s, e) => s + (e.requestSizeBytes ?? 0) + (e.responseSizeBytes ?? 0),
            0
          ) / edgeEvents.length
        )
      : 0;

  return (
    <Card className="border-stone-200/80 bg-white">
      <CardHeader className="pb-2">
        <CardTitle className="text-sm flex items-center gap-2">
          <span
            className="inline-block w-2 h-2 rounded-full shrink-0"
            style={{ backgroundColor: color }}
          />
          Edge details
        </CardTitle>
        <div className="text-xs text-stone-600 mt-1">
          {sourceLabel ?? edge.source} → {targetLabel ?? edge.target}
        </div>
        {edge.label && (
          <div className="text-xs text-stone-500 mt-0.5">
            Contract: <span className="font-medium text-stone-700">{edge.label}</span>
          </div>
        )}
      </CardHeader>
      <CardContent className="space-y-4 text-sm">
        <div className="grid grid-cols-2 gap-x-4 gap-y-2 text-xs">
          <div className="text-stone-500">Aggregated RPS</div>
          <div className="font-medium tabular-nums">{edge.requestRatePerSec.toFixed(2)}/s</div>
          <div className="text-stone-500">Avg latency</div>
          <div className="font-medium tabular-nums">{edge.avgLatencyMs.toFixed(0)} ms</div>
          <div className="text-stone-500">P50 latency</div>
          <div className="font-medium tabular-nums">{p50.toFixed(0)} ms</div>
          <div className="text-stone-500">P95 latency</div>
          <div className="font-medium tabular-nums">{p95.toFixed(0)} ms</div>
          <div className="text-stone-500">P99 latency</div>
          <div className="font-medium tabular-nums">{p99.toFixed(0)} ms</div>
          <div className="text-stone-500">Error rate (sample)</div>
          <div className="font-medium tabular-nums">{errRate1h.toFixed(2)}%</div>
          <div className="text-stone-500">Avg payload size</div>
          <div className="font-medium tabular-nums">{avgPayload} B</div>
        </div>

        {last10.length > 0 && (
          <div>
            <div className="text-xs font-medium text-stone-600 mb-2">Last 10 requests</div>
            <ul className="space-y-1.5 border border-stone-200 rounded-md divide-y divide-stone-100 overflow-hidden">
              {last10.map((ev, i) => (
                <li key={ev.id ?? i} className="px-3 py-1.5 text-xs bg-stone-50/50 flex justify-between gap-2">
                  <span className="text-stone-600 truncate">{ev.endpoint ?? ev.method ?? '—'}</span>
                  <span className="tabular-nums text-stone-800 shrink-0">
                    {ev.latencyMs} ms
                    {ev.status === 'error' && <span className="text-red-600 ml-1">err</span>}
                  </span>
                </li>
              ))}
            </ul>
          </div>
        )}

        {edge.endpoints && edge.endpoints.length > 0 && (
          <div>
            <div className="text-xs font-medium text-stone-600 mb-2">Endpoints breakdown</div>
            <ul className="space-y-2 border border-stone-200 rounded-md divide-y divide-stone-100 overflow-hidden">
              {edge.endpoints.map((ep: TrafficInspectorEdgeEndpoint, i: number) => (
                <li key={i} className="px-3 py-2 text-xs bg-stone-50/50">
                  <div className="flex justify-between gap-2">
                    <span className="text-stone-600">
                      {ep.method ?? '—'} {ep.endpoint ?? `Endpoint ${i + 1}`}
                    </span>
                    <span className="tabular-nums text-stone-800">
                      {ep.requestRatePerSec.toFixed(1)}/s · {ep.avgLatencyMs.toFixed(0)}ms
                      {ep.errorRate > 0 && (
                        <span className="text-red-600 ml-1">{(ep.errorRate * 100).toFixed(1)}% err</span>
                      )}
                    </span>
                  </div>
                </li>
              ))}
            </ul>
          </div>
        )}

        {(!edge.endpoints || edge.endpoints.length === 0) && (
          <p className="text-xs text-stone-400 italic">
            Endpoint-level breakdown will appear when the backend sends per-endpoint metrics or when derived from the request stream.
          </p>
        )}
      </CardContent>
    </Card>
  );
}
