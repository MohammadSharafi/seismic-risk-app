import React from 'react';
import type { TrafficInspectorEvent } from '../../types/trafficInspector';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '../ui/table';
import { cn } from '../ui/utils';

export interface TrafficInspectorRequestListProps {
  events: TrafficInspectorEvent[];
  selectedId: string | null;
  onSelect: (event: TrafficInspectorEvent) => void;
  filterHint?: string;
  /** When true, show "run a simulation" hint; when false, show "click Connect first" hint. */
  isStreamConnected?: boolean;
  /** Smaller row height */
  compact?: boolean;
  /** Max height of scrollable area (px) */
  maxHeight?: number;
}

function formatTs(iso: string): string {
  try {
    const d = new Date(iso);
    return d.toLocaleTimeString('en-GB', { hour12: false }) + '.' + String(d.getMilliseconds()).padStart(3, '0');
  } catch {
    return iso;
  }
}

function sizeDisplay(req?: number, res?: number): string {
  if (req != null && res != null) return `${req}+${res} B`;
  if (req != null) return `${req} B`;
  if (res != null) return `${res} B`;
  return '—';
}

export function TrafficInspectorRequestList({
  events,
  selectedId,
  onSelect,
  filterHint,
  isStreamConnected = false,
  compact = false,
  maxHeight = 320,
}: TrafficInspectorRequestListProps) {
  const flowByTraceId = React.useMemo(() => {
    const m = new Map<string, string>();
    for (const ev of events) {
      if (ev.flow && ev.traceId) m.set(ev.traceId, ev.flow);
    }
    return m;
  }, [events]);

  const emptyMessage = isStreamConnected
    ? 'Run a simulation (or any command) in the clinician UI to see events here.'
    : 'Click Connect above so the stream is Live, then run a simulation in the clinician UI. Events will appear here.';
  return (
    <div className="border border-stone-200 rounded-xl bg-white overflow-hidden shadow-sm" data-testid="traffic-inspector-request-list">
      <div className="px-3 py-2 border-b border-stone-200 bg-stone-50/80 text-xs text-stone-500 flex items-center gap-2">
        <span className="font-medium text-stone-600">Live stream</span>
        <span>·</span>
        <span>{events.length} event{events.length !== 1 ? 's' : ''}</span>
        {filterHint && (
          <>
            <span>·</span>
            <span className="truncate max-w-[200px]" title={filterHint}>Filter: {filterHint}</span>
          </>
        )}
      </div>
      <div className="overflow-auto" style={{ maxHeight: `${maxHeight}px` }}>
        <Table>
          <TableHeader>
            <TableRow className="border-stone-200 bg-stone-50/80">
              <TableHead className="text-stone-600 w-[70px]">Time</TableHead>
              <TableHead className="text-stone-600 w-[64px]">Method</TableHead>
              <TableHead className="text-stone-600">Source</TableHead>
              <TableHead className="text-stone-600">Dest</TableHead>
              <TableHead className="text-stone-600 min-w-[140px]">Endpoint</TableHead>
              <TableHead className="text-stone-600 w-[48px]">Flow</TableHead>
              <TableHead className="text-stone-600 w-[72px]">Tool</TableHead>
              <TableHead className="text-stone-600 w-[52px]">Patient</TableHead>
              <TableHead className="text-stone-600 w-[52px]">Status</TableHead>
              <TableHead className="text-stone-600 w-[60px]">Latency</TableHead>
              <TableHead className="text-stone-600 w-[90px]">Trace ID</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {events.length === 0 ? (
              <TableRow>
                <TableCell colSpan={11} className="text-stone-500 py-10 text-center text-sm">
                  {emptyMessage}
                </TableCell>
              </TableRow>
            ) : (
              events.map((ev) => (
                <TableRow
                  key={ev.id}
                  className={cn(
                    'cursor-pointer border-stone-100 transition-colors',
                    compact ? 'text-xs' : 'text-sm',
                    selectedId === ev.id ? 'bg-emerald-50 border-l-2 border-l-emerald-500' : 'hover:bg-stone-50'
                  )}
                  onClick={() => onSelect(ev)}
                >
                  <TableCell className={cn('font-mono text-stone-600', compact && 'py-1')}>{formatTs(ev.timestamp)}</TableCell>
                  <TableCell className={cn('font-medium text-stone-700', compact && 'py-1')}>
                    <span className={cn(
                      'inline-block px-1.5 py-0.5 rounded text-[10px] font-semibold',
                      (ev.method ?? '').toUpperCase() === 'GET' ? 'bg-sky-100 text-sky-800' : (ev.method ?? '').toUpperCase() === 'POST' ? 'bg-amber-100 text-amber-800' : 'bg-stone-100 text-stone-600'
                    )}>
                      {ev.method ?? '—'}
                    </span>
                  </TableCell>
                  <TableCell className={cn('font-medium text-stone-800 truncate max-w-[80px]', compact && 'py-1')} title={ev.source}>{ev.source}</TableCell>
                  <TableCell className={cn('font-medium text-stone-800 truncate max-w-[80px]', compact && 'py-1')} title={ev.destination}>{ev.destination}</TableCell>
                  <TableCell className={cn('text-stone-700 truncate max-w-[180px]', compact && 'py-1')} title={ev.endpoint}>
                    {ev.endpoint ?? '—'}
                  </TableCell>
                  <TableCell className={cn('font-medium text-stone-700', compact && 'py-1')}>
                    <span className={cn(
                      'inline-block px-1 py-0.5 rounded text-[10px]',
                      (ev.flow ?? flowByTraceId.get(ev.traceId ?? '')) === 'EEF' ? 'bg-stone-100 text-stone-700' : (ev.flow ?? flowByTraceId.get(ev.traceId ?? '')) === 'CARF' ? 'bg-blue-100 text-blue-800' : (ev.flow ?? flowByTraceId.get(ev.traceId ?? '')) === 'DCRF' ? 'bg-violet-100 text-violet-800' : 'bg-stone-50 text-stone-500'
                    )}>
                      {ev.flow ?? flowByTraceId.get(ev.traceId ?? '') ?? '—'}
                    </span>
                  </TableCell>
                  <TableCell className={cn('text-stone-600 truncate max-w-[72px]', compact && 'py-1')} title={ev.tool}>{ev.tool ?? '—'}</TableCell>
                  <TableCell className={cn('font-mono text-xs text-stone-600 truncate max-w-[52px]', compact && 'py-1')} title={ev.patientIdHash ? `…${ev.patientIdHash}` : undefined}>
                    {ev.patientIdHash ? `…${ev.patientIdHash}` : '—'}
                  </TableCell>
                  <TableCell className={compact ? 'py-1' : ''}>
                    <span
                      className={cn(
                        'text-xs font-medium px-1.5 py-0.5 rounded',
                        ev.status === 'ok' ? 'bg-emerald-100 text-emerald-800' : 'bg-red-100 text-red-800'
                      )}
                    >
                      {ev.statusCode ?? ev.status}
                    </span>
                  </TableCell>
                  <TableCell className={cn('text-stone-600 tabular-nums', compact && 'py-1')}>{ev.latencyMs} ms</TableCell>
                  <TableCell className={cn('font-mono text-xs text-stone-500 truncate max-w-[90px]', compact && 'py-1')} title={ev.traceId ?? ''}>
                    {ev.traceId ? (ev.traceId.length > 8 ? ev.traceId.slice(0, 8) + '…' : ev.traceId) : '—'}
                  </TableCell>
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>
      </div>
    </div>
  );
}
