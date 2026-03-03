import React, { useMemo, useEffect, useCallback, useState } from 'react';
import {
  ReactFlow,
  Background,
  Controls,
  MiniMap,
  useNodesState,
  useEdgesState,
  useReactFlow,
  Handle,
  Position,
  type Node,
  type Edge,
  type NodeProps,
  Panel,
} from '@xyflow/react';
import '@xyflow/react/dist/style.css';
import type {
  TrafficInspectorNode,
  TrafficInspectorEdge,
  AggregatedTrafficEdge,
} from '../../types/trafficInspector';
import { getLayoutedElements } from '../../utils/trafficGraphLayout';
import {
  TrafficInspectorCustomEdge,
  edgeColor,
  edgeStrokeWidth,
  type TrafficEdgeData,
} from './TrafficInspectorCustomEdge';

const HEALTH_COLOR: Record<string, string> = {
  UP: '#16a34a',
  DOWN: '#dc2626',
  DEGRADED: '#ca8a04',
};

/** Aggregate raw edges into one edge per (source, target) with summed/avg metrics */
function aggregateEdges(
  edges: TrafficInspectorEdge[],
  nodeIds: Set<string>
): AggregatedTrafficEdge[] {
  const byKey = new Map<string, TrafficInspectorEdge[]>();
  for (const e of edges) {
    if (!nodeIds.has(e.source) || !nodeIds.has(e.target)) continue;
    const key = `${e.source}\t${e.target}`;
    const list = byKey.get(key) ?? [];
    list.push(e);
    byKey.set(key, list);
  }
  return Array.from(byKey.entries()).map(([key, list]) => {
    const [source, target] = key.split('\t');
    const first = list[0];
    const totalRps = list.reduce((s, x) => s + x.requestRatePerSec, 0);
    const totalLatency = list.reduce((s, x) => s + x.avgLatencyMs * x.requestRatePerSec, 0);
    const totalErr = list.reduce((s, x) => s + x.errorRate * x.requestRatePerSec, 0);
    const latencies = list.map((x) => x.avgLatencyMs).sort((a, b) => a - b);
    const p95 = latencies.length
      ? latencies[Math.min(latencies.length - 1, Math.ceil(latencies.length * 0.95) - 1)]
      : undefined;
    return {
      source,
      target,
      requestRatePerSec: totalRps,
      avgLatencyMs: totalRps > 0 ? totalLatency / totalRps : 0,
      p95LatencyMs: p95,
      errorRate: totalRps > 0 ? totalErr / totalRps : 0,
      label: first?.label,
      dashed: first?.dashed,
    };
  });
}

function TrafficNode({ data }: NodeProps<{ node: TrafficInspectorNode }>) {
  const n = data.node;
  const color = HEALTH_COLOR[n.health] ?? '#94a3b8';
  return (
    <div
      className="relative px-3 py-2 rounded-lg border-2 shadow-sm min-w-[120px] text-center"
      style={{ borderColor: color, backgroundColor: `${color}12` }}
    >
      <Handle type="target" position={Position.Left} className="!w-2 !h-2 !border-2 !border-stone-400 !bg-white" />
      <div className="font-semibold text-stone-900 text-xs">{n.label}</div>
      <div className="text-[10px] font-medium mt-0.5" style={{ color }}>
        {n.health}
      </div>
      {(n.cpuPercent != null || n.memoryUsedMB != null) && (
        <div className="text-[10px] text-stone-500 mt-1">
          {n.cpuPercent != null && `${n.cpuPercent.toFixed(0)}% CPU`}
          {n.cpuPercent != null && n.memoryUsedMB != null && ' · '}
          {n.memoryUsedMB != null && `${n.memoryUsedMB} MB`}
        </div>
      )}
      <Handle type="source" position={Position.Right} className="!w-2 !h-2 !border-2 !border-stone-400 !bg-white" />
    </div>
  );
}

const nodeTypes = { traffic: TrafficNode };
const edgeTypes = { traffic: TrafficInspectorCustomEdge };

/** Calls fitView after layout so the full diagram is visible; must be a child of ReactFlow. */
function FitViewOnLayout() {
  const { fitView } = useReactFlow();
  useEffect(() => {
    const id = requestAnimationFrame(() => {
      fitView({ padding: 0.2, maxZoom: 1, duration: 200 });
    });
    return () => cancelAnimationFrame(id);
  }, [fitView]);
  return null;
}

export interface TrafficGraphFilters {
  errorsOnly: boolean;
  trafficOnly: boolean;
  showLabels: boolean;
}

export interface TrafficInspectorGraphProps {
  nodes: TrafficInspectorNode[];
  edges: TrafficInspectorEdge[];
  filters?: TrafficGraphFilters;
  onEdgeSelect?: (edge: AggregatedTrafficEdge | null) => void;
  selectedEdge?: AggregatedTrafficEdge | null;
  /** When set, highlight edges that were active for this trace */
  selectedTraceId?: string | null;
  /** Events for computing active edges when selectedTraceId is set */
  events?: Array<{ traceId?: string; source: string; destination: string; status?: string }>;
}

const defaultFilters: TrafficGraphFilters = {
  errorsOnly: false,
  trafficOnly: false,
  showLabels: false,
};

export function TrafficInspectorGraph({
  nodes,
  edges,
  filters = defaultFilters,
  onEdgeSelect,
  selectedEdge,
  selectedTraceId,
  events = [],
}: TrafficInspectorGraphProps) {
  const nodeMap = useMemo(() => new Map(nodes.map((n) => [n.id, n])), [nodes]);
  const nodeIds = useMemo(() => new Set(nodes.map((n) => n.id)), [nodes]);

  const aggregated = useMemo(() => aggregateEdges(edges, nodeIds), [edges, nodeIds]);

  const filteredAggregated = useMemo(() => {
    let list = aggregated;
    if (filters.errorsOnly) list = list.filter((e) => e.errorRate >= 0.01);
    if (filters.trafficOnly) list = list.filter((e) => e.requestRatePerSec > 0);
    return list;
  }, [aggregated, filters.errorsOnly, filters.trafficOnly]);

  const [zoom, setZoom] = useState(1);
  const labelLevel: 0 | 1 | 2 = useMemo(() => {
    if (!filters.showLabels) return 0;
    if (zoom >= 0.9) return 2;
    if (zoom >= 0.5) return 1;
    return 0;
  }, [zoom, filters.showLabels]);

  const flowNodes: Node<{ node: TrafficInspectorNode }>[] = useMemo(
    () =>
      nodes.map((n) => ({
        id: n.id,
        type: 'traffic',
        position: { x: 0, y: 0 },
        data: { node: n },
        sourcePosition: Position.Right,
        targetPosition: Position.Left,
      })),
    [nodes]
  );

  const edgesForLayout = useMemo(
    () =>
      filteredAggregated.map((e) => ({
        id: `agg-${e.source}-${e.target}`,
        source: e.source,
        target: e.target,
      })),
    [filteredAggregated]
  );

  const layoutNodes = useMemo(() => {
    return getLayoutedElements(flowNodes, edgesForLayout, 'LR');
  }, [flowNodes, edgesForLayout]);

  const activeEdgeKeys = useMemo(() => {
    if (!selectedTraceId || !events.length) return new Set<string>();
    const keys = new Set<string>();
    for (const ev of events) {
      if (ev.traceId === selectedTraceId && ev.source && ev.destination) {
        keys.add(`${ev.source}\t${ev.destination}`);
      }
    }
    return keys;
  }, [selectedTraceId, events]);

  const layoutEdges: Edge<TrafficEdgeData>[] = useMemo(() => {
    const selId =
      selectedEdge != null ? `agg-${selectedEdge.source}-${selectedEdge.target}` : null;
    return filteredAggregated.map((e) => {
      const id = `agg-${e.source}-${e.target}`;
      const edgeKey = `${e.source}\t${e.target}`;
      const isActive = activeEdgeKeys.has(edgeKey);
      const hasError = events.some(
        (ev) =>
          ev.traceId === selectedTraceId &&
          ev.source === e.source &&
          ev.destination === e.target &&
          ev.status === 'error'
      );
      let highlight: 'active' | 'inactive' | 'error' | 'none' = 'none';
      if (selectedTraceId) {
        if (hasError) highlight = 'error';
        else if (isActive) highlight = 'active';
        else highlight = 'inactive';
      }
      return {
        id,
        source: e.source,
        target: e.target,
        type: 'traffic',
        selected: id === selId,
        data: {
          requestRatePerSec: e.requestRatePerSec,
          avgLatencyMs: e.avgLatencyMs,
          p95LatencyMs: e.p95LatencyMs,
          errorRate: e.errorRate,
          labelLevel,
          edgeId: id,
          label: e.label,
          dashed: e.dashed,
          highlight,
        },
      };
    });
  }, [filteredAggregated, labelLevel, selectedEdge, activeEdgeKeys, selectedTraceId, events]);

  const [flowNodesState, setFlowNodes, onNodesChange] = useNodesState(layoutNodes);
  const [flowEdgesState, setFlowEdges, onEdgesChange] = useEdgesState(layoutEdges);

  useEffect(() => {
    setFlowNodes(layoutNodes);
    setFlowEdges(layoutEdges);
  }, [layoutNodes, layoutEdges, setFlowNodes, setFlowEdges]);

  const onEdgeClick = useCallback(
    (_: React.MouseEvent, edge: Edge) => {
      const agg = filteredAggregated.find(
        (e) => `agg-${e.source}-${e.target}` === edge.id
      );
      onEdgeSelect?.(agg ?? null);
    },
    [filteredAggregated, onEdgeSelect]
  );

  const onPaneClick = useCallback(() => {
    onEdgeSelect?.(null);
  }, [onEdgeSelect]);

  return (
    <div className="traffic-inspector-graph w-full h-[720px] rounded-lg border border-stone-200 bg-stone-50/80 relative overflow-hidden">
      <ReactFlow
        nodes={flowNodesState}
        edges={flowEdgesState}
        onNodesChange={onNodesChange}
        onEdgesChange={onEdgesChange}
        onEdgeClick={onEdgeClick}
        onPaneClick={onPaneClick}
        onViewportChange={(arg) => {
          const viewport = arg?.viewport ?? arg;
          if (viewport != null && typeof viewport.zoom === 'number') setZoom(viewport.zoom);
        }}
        nodeTypes={nodeTypes}
        edgeTypes={edgeTypes}
        panOnDrag={true}
        zoomOnScroll={true}
        zoomOnPinch={true}
        zoomOnDoubleClick={true}
        nodesDraggable={false}
        nodesConnectable={false}
        elementsSelectable={true}
        selectionOnDrag={false}
        fitView
        fitViewOptions={{ padding: 0.2, maxZoom: 1 }}
        minZoom={0.15}
        maxZoom={1.5}
        defaultEdgeOptions={{ type: 'traffic' }}
      >
        <Background gap={16} size={1} color="#e5e7eb" />
        <Controls />
        <FitViewOnLayout key={`fit-${layoutNodes.length}-${layoutEdges.length}`} />
        <MiniMap
          nodeColor={(n) =>
            HEALTH_COLOR[(n.data as { node: TrafficInspectorNode }).node.health] ?? '#94a3b8'
          }
        />
        <Panel position="top-left" className="text-xs text-stone-500 bg-white/95 rounded-md px-2.5 py-1.5 shadow border border-stone-200">
          <span className="font-medium text-stone-600">Legend:</span> Green = healthy · Amber = slow · Red = errors · Thickness = traffic
        </Panel>
      </ReactFlow>
    </div>
  );
}
