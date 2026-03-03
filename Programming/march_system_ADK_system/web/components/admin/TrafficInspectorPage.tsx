import React, { useState, useCallback, useEffect, useMemo, useRef } from 'react';
import { Button } from '../ui/button';
import { Pause, Play, Trash2, AlertCircle, Activity, Tag, Send, Radio, Download, RefreshCw, ChevronDown } from 'lucide-react';
import { useTrafficStream } from '../../contexts/TrafficStreamContext';
import { TrafficInspectorGraph } from './TrafficInspectorGraph';
import type { TrafficGraphFilters } from './TrafficInspectorGraph';
import { TrafficInspectorRequestList } from './TrafficInspectorRequestList';
import { TrafficInspectorDetailPanel } from './TrafficInspectorDetailPanel';
import { TrafficInspectorEdgeDetailsPanel } from './TrafficInspectorEdgeDetailsPanel';
import { submitCommand, openCommandStream } from '../../api/commandApi';
import { getEventDetail, getEventDetailByTraceId, getFallbackTopology, getTrafficInspectorMode, getTrafficStreamStatus, sendTestCommand } from '../../api/trafficInspectorApi';
import type {
  TrafficInspectorEvent,
  TrafficInspectorEventDetail,
  TrafficInspectorNode,
  TrafficInspectorEdge,
  AggregatedTrafficEdge,
  TrafficInspectorEdgeEndpoint,
} from '../../types/trafficInspector';

const EVENT_LIMIT_OPTIONS = [100, 250, 500, 1000] as const;
type SortOrder = 'newest' | 'oldest';

export function TrafficInspectorPage() {
  const [filter, setFilter] = useState('');
  const [selectedEvent, setSelectedEvent] = useState<TrafficInspectorEvent | TrafficInspectorEventDetail | null>(null);
  const [selectedEdge, setSelectedEdge] = useState<AggregatedTrafficEdge | null>(null);
  const [graphFilters, setGraphFilters] = useState<TrafficGraphFilters>({
    errorsOnly: false,
    trafficOnly: false,
    showLabels: false,
  });
  const [detailLoading, setDetailLoading] = useState(false);
  const [testRequestSending, setTestRequestSending] = useState(false);
  const [testRequestMessage, setTestRequestMessage] = useState<string | null>(null);
  const [backendClientCount, setBackendClientCount] = useState<number | null>(null);
  const [fallbackTopology, setFallbackTopology] = useState<{
    nodes: TrafficInspectorNode[];
    edges: TrafficInspectorEdge[];
  } | null>(null);
  const [topologyRefreshing, setTopologyRefreshing] = useState(false);
  const [sortOrder, setSortOrder] = useState<SortOrder>('newest');
  const [eventLimit, setEventLimit] = useState(500);
  const [autoScroll, setAutoScroll] = useState(true);
  const [quickFilter, setQuickFilter] = useState<'all' | 'errors' | 'success' | 'slow' | 'post'>('all');
  const [methodFilter, setMethodFilter] = useState<string>('all');
  const [compactList, setCompactList] = useState(false);
  const [showOptions, setShowOptions] = useState(false);
  const listContainerRef = useRef<HTMLDivElement | null>(null);
  const trafficMode = getTrafficInspectorMode();

  const {
    events,
    nodes,
    edges,
    status,
    error,
    paused,
    setPaused,
    lastTopologyAt,
    connect,
    clearEvents,
    pushMarchSseEvent,
  } = useTrafficStream();

  // Connect when this page mounts; do not disconnect on unmount so clinician traffic still shows when we come back.
  useEffect(() => {
    connect();
  }, [connect]);

  // Poll backend to see how many clients it has (so we can warn if we think we're Live but backend says 0).
  useEffect(() => {
    if (status !== 'connected') return;
    const tick = () => {
      getTrafficStreamStatus().then((s) => s != null && setBackendClientCount(s.connectedClients));
    };
    tick();
    const id = setInterval(tick, 3000);
    return () => clearInterval(id);
  }, [status]);

  // When stream has no topology, load fallback from existing health/tools API so the graph still shows something.
  useEffect(() => {
    if (nodes.length > 0) return;
    getFallbackTopology().then((t) => setFallbackTopology(t));
  }, [nodes.length]);

  // Poll topology health every 10s so node status (UP/DOWN/DEGRADED) stays current.
  // Run immediately on mount so March mode gets topology without waiting for the first interval.
  useEffect(() => {
    const refresh = () => getFallbackTopology().then((t) => setFallbackTopology(t));
    refresh();
    const id = setInterval(refresh, 10000);
    return () => clearInterval(id);
  }, []);

  const displayNodes = nodes.length > 0 ? nodes : fallbackTopology?.nodes ?? [];
  const displayEdges = edges.length > 0 ? edges : fallbackTopology?.edges ?? [];

  const { selectedEdgeWithEndpoints, edgeEventsForPanel } = useMemo(() => {
    if (!selectedEdge) return { selectedEdgeWithEndpoints: null as AggregatedTrafficEdge | null, edgeEventsForPanel: [] as TrafficInspectorEvent[] };
    const match = events.filter(
      (e) => e.source === selectedEdge.source && e.destination === selectedEdge.target
    );
    const edgeEventsForPanel = match.slice(-10);
    if (match.length === 0) return { selectedEdgeWithEndpoints: selectedEdge, edgeEventsForPanel: [] };
    const byEndpoint = new Map<string, { rps: number; latencies: number[]; errors: number }>();
    for (const e of match) {
      const key = `${e.method ?? '?'}\t${e.endpoint ?? ''}`;
      const cur = byEndpoint.get(key) ?? { rps: 0, latencies: [], errors: 0 };
      cur.rps += 1;
      cur.latencies.push(e.latencyMs);
      if (e.status === 'error' || (e.statusCode != null && e.statusCode >= 400)) cur.errors += 1;
      byEndpoint.set(key, cur);
    }
    const endpoints: TrafficInspectorEdgeEndpoint[] = Array.from(byEndpoint.entries()).map(
      ([key, v]) => {
        const [method, endpoint] = key.split('\t');
        const n = v.latencies.length;
        const avg = n ? v.latencies.reduce((a, b) => a + b, 0) / n : 0;
        const sorted = [...v.latencies].sort((a, b) => a - b);
        const p95 = sorted.length ? sorted[Math.ceil(sorted.length * 0.95) - 1] : undefined;
        return {
          method: method !== '?' ? method : undefined,
          endpoint: endpoint || undefined,
          requestRatePerSec: v.rps,
          avgLatencyMs: avg,
          p95LatencyMs: p95,
          errorRate: v.rps > 0 ? v.errors / v.rps : 0,
        };
      }
    );
    return { selectedEdgeWithEndpoints: { ...selectedEdge, endpoints }, edgeEventsForPanel };
  }, [selectedEdge, events]);

  const handleSelectEvent = useCallback((event: TrafficInspectorEvent) => {
    setSelectedEvent(event);
    setDetailLoading(true);
    const tryFetch = (): Promise<TrafficInspectorEventDetail | null> => {
      // Prefer lookup by event id (backend cache key). Skip if id is a fallback (e.g. "trace:...:...").
      if (event.id && !event.id.startsWith('trace:')) {
        return getEventDetail(event.id);
      }
      return Promise.resolve(null);
    };
    tryFetch()
      .then((detail) => {
        if (detail) {
          setSelectedEvent(detail);
          return;
        }
        // Fallback: fetch by traceId so we still get detail when id was evicted or missing
        if (event.traceId) {
          return getEventDetailByTraceId(event.traceId).then((byTrace) => {
            if (byTrace) setSelectedEvent(byTrace);
            else setSelectedEvent(event);
          });
        }
        setSelectedEvent(event);
      })
      .finally(() => setDetailLoading(false));
  }, []);

  const handleCopyTraceId = useCallback((traceId: string) => {
    navigator.clipboard.writeText(traceId);
  }, []);

  const handleSendTestRequest = useCallback(async () => {
    setTestRequestMessage(null);
    setTestRequestSending(true);
    try {
      if (trafficMode === 'march' && pushMarchSseEvent) {
        const { runId, streamUrl } = await submitCommand(
          '/summary window=last_7_days',
          'default',
          'p-dev-001'
        );
        if (!runId || !streamUrl) {
          setTestRequestMessage('Missing runId or streamUrl');
          return;
        }
        const closeStream = openCommandStream(runId, streamUrl, {
          onSseEvent: (payload) => {
            pushMarchSseEvent(
              { event: payload?.event, data: payload?.data as Record<string, unknown>, id: payload?.id },
              runId
            );
          },
          onWidget: () => {},
          onError: (msg) => setTestRequestMessage(msg),
          onDone: () => {},
        });
        setTestRequestMessage('Test request sent. Events should appear in the stream.');
        setTimeout(() => {
          closeStream();
          setTestRequestMessage(null);
        }, 3000);
      } else {
        const result = await sendTestCommand();
        if (result.ok) {
          setTestRequestMessage('Request sent. If the stream is Live, an event should appear above within a second.');
          setTimeout(() => setTestRequestMessage(null), 5000);
        } else {
          setTestRequestMessage(result.message ?? 'Failed');
        }
      }
    } catch (e) {
      setTestRequestMessage(e instanceof Error ? e.message : 'Request failed');
    } finally {
      setTestRequestSending(false);
    }
  }, [trafficMode, pushMarchSseEvent]);

  // Apply quick filter, method filter, text filter, sort, and limit
  const filteredEvents = React.useMemo(() => {
    let list = events;
    if (quickFilter !== 'all') {
      list = list.filter((ev) => {
        const code = ev.statusCode ?? (ev.status === 'error' ? 500 : 200);
        if (quickFilter === 'errors') return code >= 400;
        if (quickFilter === 'success') return code >= 200 && code < 300;
        if (quickFilter === 'slow') return ev.latencyMs > 200;
        if (quickFilter === 'post') return (ev.method ?? '').toUpperCase() === 'POST';
        return true;
      });
    }
    if (methodFilter !== 'all') {
      list = list.filter((ev) => (ev.method ?? '').toUpperCase() === methodFilter.toUpperCase());
    }
    if (filter.trim()) {
      const lower = filter.toLowerCase();
      list = list.filter((ev) => {
        if (lower.includes('latency') && (lower.includes('300') || lower.includes('>'))) {
          const match = /latency\s*>\s*(\d+)/i.exec(filter);
          const threshold = match ? Number(match[1]) : 300;
          if (ev.latencyMs <= threshold) return false;
        }
        if (lower.includes('status') && (lower.includes('500') || lower.includes('>='))) {
          const code = ev.statusCode ?? (ev.status === 'error' ? 500 : 200);
          if (code < 500) return false;
        }
        if (lower.includes('source=')) {
          const m = /source\s*=\s*(\S+)/i.exec(filter);
          if (m && !ev.source.toLowerCase().includes(m[1].toLowerCase())) return false;
        }
        if (lower.includes('destination=') || lower.includes('dest=')) {
          const m = /(?:destination|dest)\s*=\s*(\S+)/i.exec(filter);
          if (m && !ev.destination.toLowerCase().includes(m[1].toLowerCase())) return false;
        }
        if (lower.includes('traceid=') || lower.includes('trace_id=')) {
          const m = /traceid\s*=\s*(\S+)/i.exec(filter.replace(/_/g, ''));
          if (m && !ev.traceId.toLowerCase().includes(m[1].toLowerCase())) return false;
        }
        return true;
      });
    }
    const sorted = sortOrder === 'oldest' ? [...list].reverse() : [...list];
    return sorted.slice(0, eventLimit);
  }, [events, filter, quickFilter, methodFilter, sortOrder, eventLimit]);

  const stats = useMemo(() => {
    const err = events.filter((e) => (e.statusCode ?? 200) >= 400).length;
    const avgLat = events.length
      ? Math.round(events.reduce((a, e) => a + e.latencyMs, 0) / events.length)
      : 0;
    return { total: events.length, errors: err, avgLatencyMs: avgLat };
  }, [events]);

  const handleExportEvents = useCallback(() => {
    const blob = new Blob([JSON.stringify(filteredEvents, null, 2)], { type: 'application/json' });
    const a = document.createElement('a');
    a.href = URL.createObjectURL(blob);
    a.download = `traffic-events-${new Date().toISOString().slice(0, 19).replace(/:/g, '-')}.json`;
    a.click();
    URL.revokeObjectURL(a.href);
  }, [filteredEvents]);

  const handleRefreshTopology = useCallback(() => {
    setTopologyRefreshing(true);
    getFallbackTopology()
      .then((t) => setFallbackTopology(t))
      .finally(() => setTopologyRefreshing(false));
  }, []);

  return (
    <div className="min-h-screen bg-gradient-to-b from-stone-50 to-white p-6 md:p-8 relative z-0">
      <header className="mb-6">
        <div className="flex flex-wrap items-start justify-between gap-4">
          <div>
            <h1 className="text-2xl md:text-3xl font-bold text-stone-900 tracking-tight flex items-center gap-2">
              <Radio className="size-7 text-emerald-600" />
              Traffic Inspector
            </h1>
            <p className="text-stone-600 text-sm mt-1.5 max-w-xl">
              {trafficMode === 'march'
                ? 'March-native topology. Run a command in the main chat, then view step-by-step API flow here.'
                : 'Live topology and request stream. Connect to backend websocket traffic for real-time metrics.'}
            </p>
          </div>
        </div>
      </header>

      {error && (
        <div className="mb-4 p-4 rounded-xl bg-amber-50 border border-amber-200 text-amber-900 text-sm flex items-center justify-between gap-3 relative z-10 shadow-sm">
          <span>{error}</span>
          <Button variant="outline" size="sm" onClick={connect} className="shrink-0">
            Reconnect
          </Button>
        </div>
      )}

      {trafficMode !== 'march' && status === 'connected' && backendClientCount === 0 && (
        <div className="mb-4 p-4 rounded-xl bg-red-50 border border-red-200 text-red-900 text-sm relative z-10 shadow-sm">
          <strong>Backend reports 0 connected clients.</strong> Restart the backend and refresh this page so it reconnects.
        </div>
      )}

      {/* Stats bar */}
      <div className="mb-4 flex flex-wrap items-center gap-4 rounded-xl bg-white border border-stone-200 px-4 py-3 shadow-sm">
        <span
          data-testid="traffic-inspector-status"
          className={`inline-flex items-center gap-2 rounded-full px-3 py-1.5 text-xs font-semibold ${
            status === 'connected' ? 'bg-emerald-100 text-emerald-800' : status === 'connecting' ? 'bg-amber-100 text-amber-800' : 'bg-stone-100 text-stone-600'
          }`}
        >
          <span className={`w-2 h-2 rounded-full animate-pulse ${status === 'connected' ? 'bg-emerald-500' : 'bg-stone-400'}`} />
          {status === 'connected' ? 'Live' : status === 'connecting' ? 'Connecting…' : status === 'error' ? 'Error' : 'Disconnected'}
        </span>
        <span className="text-sm text-stone-600 tabular-nums">
          <strong className="text-stone-900">{stats.total}</strong> events
        </span>
        {stats.errors > 0 && (
          <span className="text-sm text-red-600 tabular-nums">
            <strong>{stats.errors}</strong> errors
          </span>
        )}
        <span className="text-sm text-stone-600 tabular-nums">
          Avg <strong className="text-stone-900">{stats.avgLatencyMs}</strong> ms
        </span>
        {status === 'connected' && backendClientCount != null && (
          <span className="text-xs text-stone-500">
            Backend: {backendClientCount} client{backendClientCount !== 1 ? 's' : ''} connected
          </span>
        )}
      </div>

      {/* Main controls */}
      <div className="mb-4 flex flex-wrap items-center gap-2" data-testid="traffic-inspector-controls">
        {status === 'disconnected' && !error && (
          <Button variant="default" size="sm" onClick={connect} data-testid="traffic-inspector-connect" className="bg-emerald-600 hover:bg-emerald-700">
            Connect
          </Button>
        )}
        <Button variant="outline" size="sm" onClick={() => setPaused(!paused)} disabled={status !== 'connected'} data-testid="traffic-inspector-pause-resume">
          {paused ? <Play className="size-4" /> : <Pause className="size-4" />}
          <span className="ml-1.5">{paused ? 'Resume' : 'Pause'}</span>
        </Button>
        <Button variant="outline" size="sm" onClick={clearEvents} data-testid="traffic-inspector-clear">
          <Trash2 className="size-4" />
          <span className="ml-1.5">Clear</span>
        </Button>
        <Button
          variant="outline"
          size="sm"
          onClick={handleSendTestRequest}
          disabled={status !== 'connected' || testRequestSending}
          title={trafficMode === 'march' ? 'Run a March test request through /api/v1/chat endpoints' : 'POST /v1/commands; event should appear in stream'}
          data-testid="traffic-inspector-send-test"
        >
          <Send className="size-4" />
          <span className="ml-1.5">{testRequestSending ? 'Sending…' : 'Send test request'}</span>
        </Button>
        <Button variant="outline" size="sm" onClick={handleExportEvents} disabled={filteredEvents.length === 0}>
          <Download className="size-4" />
          <span className="ml-1.5">Export JSON</span>
        </Button>
        <Button
          variant="outline"
          size="sm"
          onClick={handleRefreshTopology}
          disabled={topologyRefreshing}
          title="Reload topology from backend"
        >
          <RefreshCw className={`size-4 ${topologyRefreshing ? 'animate-spin' : ''}`} />
          <span className="ml-1.5">{topologyRefreshing ? 'Refreshing…' : 'Refresh topology'}</span>
        </Button>
        <button
          type="button"
          onClick={() => setShowOptions((o) => !o)}
          className="inline-flex items-center gap-1 rounded-md border border-stone-200 px-2.5 py-1.5 text-xs text-stone-600 hover:bg-stone-50"
        >
          Options <ChevronDown className={`size-3.5 transition-transform ${showOptions ? 'rotate-180' : ''}`} />
        </button>
        {testRequestMessage && (
          <span className="text-xs text-stone-600 max-w-[240px]">{testRequestMessage}</span>
        )}
      </div>

      {/* Options panel */}
      {showOptions && (
        <div className="mb-4 p-4 rounded-xl border border-stone-200 bg-white shadow-sm space-y-3">
          <div className="flex flex-wrap items-center gap-4">
            <div>
              <label className="block text-xs font-medium text-stone-500 mb-1">Sort</label>
              <select
                value={sortOrder}
                onChange={(e) => setSortOrder(e.target.value as SortOrder)}
                className="rounded-md border border-stone-200 px-2.5 py-1.5 text-sm"
              >
                <option value="newest">Newest first</option>
                <option value="oldest">Oldest first</option>
              </select>
            </div>
            <div>
              <label className="block text-xs font-medium text-stone-500 mb-1">Show</label>
              <select
                value={eventLimit}
                onChange={(e) => setEventLimit(Number(e.target.value))}
                className="rounded-md border border-stone-200 px-2.5 py-1.5 text-sm"
              >
                {EVENT_LIMIT_OPTIONS.map((n) => (
                  <option key={n} value={n}>{n} events</option>
                ))}
              </select>
            </div>
            <div>
              <label className="block text-xs font-medium text-stone-500 mb-1">Method</label>
              <select
                value={methodFilter}
                onChange={(e) => setMethodFilter(e.target.value)}
                className="rounded-md border border-stone-200 px-2.5 py-1.5 text-sm"
              >
                <option value="all">All</option>
                <option value="GET">GET</option>
                <option value="POST">POST</option>
                <option value="PUT">PUT</option>
                <option value="PATCH">PATCH</option>
                <option value="DELETE">DELETE</option>
              </select>
            </div>
            <label className="inline-flex items-center gap-2 cursor-pointer">
              <input type="checkbox" checked={autoScroll} onChange={(e) => setAutoScroll(e.target.checked)} className="rounded border-stone-300" />
              <span className="text-sm text-stone-600">Auto-scroll to latest</span>
            </label>
            <label className="inline-flex items-center gap-2 cursor-pointer">
              <input type="checkbox" checked={compactList} onChange={(e) => setCompactList(e.target.checked)} className="rounded border-stone-300" />
              <span className="text-sm text-stone-600">Compact list</span>
            </label>
          </div>
        </div>
      )}

      {/* Quick filters */}
      <div className="mb-3 flex flex-wrap items-center gap-2">
        <span className="text-xs font-medium text-stone-500">Quick filter:</span>
        {(['all', 'errors', 'success', 'slow', 'post'] as const).map((q) => (
          <button
            key={q}
            type="button"
            onClick={() => setQuickFilter(q)}
            className={`rounded-full px-3 py-1 text-xs font-medium transition-colors ${
              quickFilter === q
                ? 'bg-stone-900 text-white'
                : 'bg-stone-100 text-stone-600 hover:bg-stone-200'
            }`}
          >
            {q === 'all' ? 'All' : q === 'errors' ? 'Errors' : q === 'success' ? '2xx' : q === 'slow' ? 'Slow >200ms' : 'POST only'}
          </button>
        ))}
      </div>

      {/* Text filter */}
      <div className="mb-4">
        <input
          type="text"
          data-testid="traffic-inspector-filter"
          className="w-full max-w-xl rounded-lg border border-stone-200 px-3 py-2 text-sm placeholder:text-stone-400 focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-500"
          placeholder="Advanced: latency > 300, status >= 500, source=client, destination=command-api"
          value={filter}
          onChange={(e) => setFilter(e.target.value)}
        />
      </div>

      <div className="mb-6">
        <div className="flex flex-wrap items-center justify-between gap-3 mb-2">
          <h2 className="text-sm font-semibold text-stone-700">Topology</h2>
          <div className="flex flex-wrap items-center gap-2 text-xs">
            <label className="inline-flex items-center gap-1.5 cursor-pointer">
              <input
                type="checkbox"
                data-testid="traffic-inspector-filter-errors"
                checked={graphFilters.errorsOnly}
                onChange={(e) => setGraphFilters((f) => ({ ...f, errorsOnly: e.target.checked }))}
                className="rounded border-stone-300"
              />
              <AlertCircle className="size-3.5 text-amber-600" />
              Errors only
            </label>
            <label className="inline-flex items-center gap-1.5 cursor-pointer">
              <input
                type="checkbox"
                data-testid="traffic-inspector-filter-traffic"
                checked={graphFilters.trafficOnly}
                onChange={(e) => setGraphFilters((f) => ({ ...f, trafficOnly: e.target.checked }))}
                className="rounded border-stone-300"
              />
              <Activity className="size-3.5 text-stone-500" />
              Traffic only
            </label>
            <label className="inline-flex items-center gap-1.5 cursor-pointer">
              <input
                type="checkbox"
                data-testid="traffic-inspector-filter-labels"
                checked={graphFilters.showLabels}
                onChange={(e) => setGraphFilters((f) => ({ ...f, showLabels: e.target.checked }))}
                className="rounded border-stone-300"
              />
              <Tag className="size-3.5 text-stone-500" />
              Labels (zoom for detail)
            </label>
          </div>
        </div>
        {displayNodes.length === 0 ? (
          <div className="h-[720px] rounded-lg border border-stone-200 bg-stone-50 flex items-center justify-center text-stone-500 text-sm" data-testid="traffic-inspector-topology-loading">
            Loading topology… (using health API when stream is not available)
          </div>
        ) : (
          <>
            {nodes.length === 0 && fallbackTopology && (
              <p className="text-xs text-stone-500 mb-2">
                {trafficMode === 'march'
                  ? 'Showing canonical March architecture topology.'
                  : 'Showing static topology from health API. Connect to the traffic stream for live metrics.'}
              </p>
            )}
            <div data-testid="traffic-inspector-graph">
            <TrafficInspectorGraph
              nodes={displayNodes}
              edges={displayEdges}
              filters={graphFilters}
              onEdgeSelect={setSelectedEdge}
              selectedEdge={selectedEdge}
              selectedTraceId={selectedEvent?.traceId ?? null}
              events={events}
            />
            </div>
          </>
        )}
      </div>

      <div className="grid gap-6 lg:grid-cols-[1fr_340px]">
        <div className="space-y-3">
          <h2 className="text-sm font-semibold text-stone-700 flex items-center justify-between">
            <span>Request stream</span>
            <span className="text-xs font-normal text-stone-500 tabular-nums">
              Showing {filteredEvents.length} of {events.length}
            </span>
          </h2>
          <div ref={listContainerRef}>
            <TrafficInspectorRequestList
              events={filteredEvents}
              selectedId={selectedEvent?.id ?? null}
              onSelect={handleSelectEvent}
              filterHint={filter ? filter.slice(0, 40) + (filter.length > 40 ? '…' : '') : undefined}
              isStreamConnected={status === 'connected'}
              compact={compactList}
              maxHeight={400}
            />
          </div>
        </div>
        <div className="space-y-4">
          <div>
            <h2 className="text-sm font-semibold text-stone-700 mb-2">Edge details</h2>
            <TrafficInspectorEdgeDetailsPanel
              edge={selectedEdgeWithEndpoints}
              sourceLabel={displayNodes.find((n) => n.id === selectedEdge?.source)?.label}
              targetLabel={displayNodes.find((n) => n.id === selectedEdge?.target)?.label}
              edgeEvents={edgeEventsForPanel}
            />
          </div>
          <div>
            <h2 className="text-sm font-semibold text-stone-700 mb-2">Request details</h2>
            {detailLoading ? (
              <div className="py-8 text-center text-stone-500 text-sm">Loading…</div>
            ) : (
              <TrafficInspectorDetailPanel
                event={selectedEvent}
                allEvents={events}
                onCopyTraceId={handleCopyTraceId}
              />
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
