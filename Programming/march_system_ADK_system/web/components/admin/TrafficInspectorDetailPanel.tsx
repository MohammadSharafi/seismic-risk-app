import React, { useMemo } from 'react';
import { Card, CardHeader, CardTitle, CardContent } from '../ui/card';
import { Button } from '../ui/button';
import { Copy } from 'lucide-react';
import type { TrafficInspectorEvent, TrafficInspectorEventDetail } from '../../types/trafficInspector';

export interface TrafficInspectorDetailPanelProps {
  event: TrafficInspectorEvent | TrafficInspectorEventDetail | null;
  allEvents?: TrafficInspectorEvent[];
  onCopyTraceId?: (traceId: string) => void;
}

export function TrafficInspectorDetailPanel({
  event,
  allEvents = [],
  onCopyTraceId,
}: TrafficInspectorDetailPanelProps) {
  if (!event) {
    return (
      <Card className="border-stone-200/80 bg-stone-50/50" data-testid="traffic-inspector-request-details-empty">
        <CardContent className="py-8 text-center text-stone-500 text-sm">
          Select a request to inspect details and trace timeline.
        </CardContent>
      </Card>
    );
  }

  const detail = event as TrafficInspectorEventDetail;
  const traceTimelineSpans = useMemo(() => {
    if (!event?.traceId || !allEvents.length) return detail.spans ?? [];
    const related = allEvents.filter((e) => e.traceId === event.traceId);
    if (related.length <= 1) return detail.spans ?? [];
    const sorted = [...related].sort(
      (a, b) => new Date(a.timestamp).getTime() - new Date(b.timestamp).getTime()
    );
    return sorted.map((e) => ({
      spanId: e.spanId,
      name: `${e.source} → ${e.destination}${e.endpoint ? ` (${e.endpoint})` : ''}`,
      durationMs: e.latencyMs,
      status: e.status,
    }));
  }, [event?.traceId, allEvents, detail.spans]);
  const hasSpans = traceTimelineSpans.length > 0;

  return (
    <Card className="border-stone-200/80 bg-white shadow-sm rounded-xl overflow-hidden">
      <CardHeader className="pb-2 bg-stone-50/50">
        <CardTitle className="text-sm font-semibold">Request details</CardTitle>
        <div className="flex items-center gap-2 flex-wrap">
          <span className="text-xs text-stone-500">
            {event.source} → {event.destination}
          </span>
          <span className="text-xs text-stone-400">·</span>
          <span className="text-xs font-mono text-stone-600">{event.traceId}</span>
          {onCopyTraceId && (
            <Button
              variant="ghost"
              size="sm"
              className="h-6 px-1.5 text-stone-500"
              onClick={() => onCopyTraceId(event.traceId)}
            >
              <Copy className="size-3.5" />
            </Button>
          )}
        </div>
      </CardHeader>
      <CardContent className="space-y-3 text-sm">
        <div className="grid grid-cols-2 gap-x-4 gap-y-1 text-xs">
          <div className="text-stone-500">Protocol</div>
          <div className="font-medium">{event.protocol}</div>
          <div className="text-stone-500">Endpoint</div>
          <div className="font-medium break-all">{event.endpoint ?? '—'}</div>
          <div className="text-stone-500">Method</div>
          <div className="font-medium">{event.method ?? '—'}</div>
          <div className="text-stone-500">Status</div>
          <div className="font-medium">{event.statusCode ?? event.status}</div>
          <div className="text-stone-500">Latency</div>
          <div className="font-medium">{event.latencyMs} ms</div>
        </div>
        {detail.headers && Object.keys(detail.headers).length > 0 && (
          <div>
            <div className="text-xs font-medium text-stone-600 mb-1">Headers</div>
            <pre className="text-xs bg-stone-100 rounded p-2 overflow-auto max-h-24">
              {JSON.stringify(detail.headers, null, 2)}
            </pre>
          </div>
        )}
        {detail.bodyPreview && (
          <div>
            <div className="text-xs font-medium text-stone-600 mb-1">Body preview</div>
            <pre className="text-xs bg-stone-100 rounded p-2 overflow-auto max-h-24 whitespace-pre-wrap">
              {detail.bodyPreview}
            </pre>
          </div>
        )}
        {hasSpans && (
          <div>
            <div className="text-xs font-medium text-stone-600 mb-1">
              Trace timeline — step by step
            </div>
            <ul className="space-y-1 text-xs">
              {traceTimelineSpans.map((s) => (
                <li key={s.spanId} className="flex justify-between gap-2">
                  <span className="truncate text-stone-700">{s.name}</span>
                  <span className="text-stone-500 shrink-0">{s.durationMs} ms</span>
                </li>
              ))}
            </ul>
          </div>
        )}
      </CardContent>
    </Card>
  );
}
