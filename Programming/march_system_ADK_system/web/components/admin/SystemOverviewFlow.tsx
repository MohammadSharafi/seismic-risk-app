import React, { useCallback, useMemo } from 'react';
import {
  ReactFlow,
  Background,
  Controls,
  MiniMap,
  useNodesState,
  useEdgesState,
  Handle,
  Position,
  type Node,
  type Edge,
  type NodeProps,
  Panel,
} from '@xyflow/react';
import '@xyflow/react/dist/style.css';
import type { SystemSection } from './AdminSystemOverview';

const statusColor = (status: SystemSection['status']) =>
  status === 'up' ? '#22c55e' : status === 'down' ? '#ef4444' : status === 'disabled' ? '#94a3b8' : '#eab308';

const EDGE_STYLE = { stroke: '#475569', strokeWidth: 2 };
const EDGE_STYLE_OPTIONAL = { stroke: '#94a3b8', strokeWidth: 1.5, strokeDasharray: '5 5' };

function SectionNode({ data, selected }: NodeProps<{ section: SystemSection }>) {
  const s = data.section;
  const color = statusColor(s.status);
  const label = s.status === 'up' ? 'UP' : s.status === 'down' ? 'DOWN' : s.status === 'disabled' ? 'OFF' : '?';
  return (
    <div
      className={`relative px-4 py-2 rounded-lg border-2 shadow-sm min-w-[120px] text-center ${
        selected ? 'ring-2 ring-amber-400 ring-offset-2' : ''
      }`}
      style={{ borderColor: color, backgroundColor: `${color}18` }}
    >
      <Handle type="target" position={Position.Left} className="!w-2 !h-2 !border-2 !border-stone-400 !bg-white" />
      <div className="font-semibold text-stone-900 text-sm">{s.name}</div>
      <div className="text-xs font-medium mt-0.5" style={{ color }}>
        {label}
      </div>
      <Handle type="source" position={Position.Right} className="!w-2 !h-2 !border-2 !border-stone-400 !bg-white" />
    </div>
  );
}

const nodeTypes = { section: SectionNode };

const FLOW_EDGES: { source: string; target: string; label: string }[] = [
  { source: 'command-api', target: 'commander', label: 'request' },
  { source: 'commander', target: 'orchestrator', label: 'plan' },
  { source: 'commander', target: 'memory', label: 'context' },
  { source: 'memory', target: 'commander', label: '' },
  { source: 'orchestrator', target: 'memory', label: 'write' },
  { source: 'orchestrator', target: 'audit', label: 'logs' },
  { source: 'orchestrator', target: 'mcp', label: 'tools' },
  { source: 'memory', target: 'database', label: 'persist' },
  { source: 'audit', target: 'database', label: 'persist' },
  { source: 'orchestrator', target: 'rag', label: 'optional' },
];

const LAYOUT: Record<string, { x: number; y: number }> = {
  'command-api': { x: 0, y: 80 },
  commander: { x: 180, y: 40 },
  orchestrator: { x: 380, y: 80 },
  memory: { x: 180, y: 160 },
  audit: { x: 380, y: 160 },
  database: { x: 580, y: 40 },
  mcp: { x: 580, y: 120 },
  rag: { x: 580, y: 200 },
};

export function SystemOverviewFlow({
  sections,
  onNodeSelect,
  selectedId,
}: {
  sections: SystemSection[];
  onNodeSelect: (section: SystemSection | null) => void;
  selectedId: string | null;
}) {
  const sectionMap = useMemo(() => new Map(sections.map((s) => [s.id, s])), [sections]);

  const initialNodes: Node<{ section: SystemSection }>[] = useMemo(
    () =>
      sections.map((s) => {
        const pos = LAYOUT[s.id] ?? { x: 0, y: 0 };
        return {
          id: s.id,
          type: 'section',
          position: pos,
          data: { section: s },
          sourcePosition: 'right',
          targetPosition: 'left',
        };
      }),
    [sections]
  );

  const initialEdges: Edge[] = useMemo(
    () =>
      FLOW_EDGES.filter((e) => sectionMap.has(e.source) && sectionMap.has(e.target)).map((e, i) => ({
        id: `e-${e.source}-${e.target}-${i}`,
        source: e.source,
        target: e.target,
        label: e.label ? e.label : undefined,
        labelBgPadding: [4, 2] as [number, number],
        labelBgBorderRadius: 4,
        labelBgStyle: { fill: '#f1f5f9' },
        labelStyle: { fontSize: 10, fill: '#475569' },
        style: e.label === 'optional' ? EDGE_STYLE_OPTIONAL : EDGE_STYLE,
        type: 'smoothstep',
      })),
    [sectionMap]
  );

  const [nodes, setNodes, onNodesChange] = useNodesState(initialNodes);
  const [edges, setEdges, onEdgesChange] = useEdgesState(initialEdges);

  React.useEffect(() => {
    setNodes(
      sections.map((s) => {
        const pos = LAYOUT[s.id] ?? { x: 0, y: 0 };
        return {
          id: s.id,
          type: 'section',
          position: pos,
          data: { section: s },
          sourcePosition: 'right',
          targetPosition: 'left',
        };
      })
    );
    setEdges(
      FLOW_EDGES.filter((e) => sectionMap.has(e.source) && sectionMap.has(e.target)).map((e, i) => ({
        id: `e-${e.source}-${e.target}-${i}`,
        source: e.source,
        target: e.target,
        label: e.label ? e.label : undefined,
        labelBgPadding: [4, 2] as [number, number],
        labelBgBorderRadius: 4,
        labelBgStyle: { fill: '#f1f5f9' },
        labelStyle: { fontSize: 10, fill: '#475569' },
        style: e.label === 'optional' ? EDGE_STYLE_OPTIONAL : EDGE_STYLE,
        type: 'smoothstep',
      }))
    );
  }, [sections, sectionMap, setNodes, setEdges]);

  const onNodeClick = useCallback(
    (_: React.MouseEvent, node: Node<{ section: SystemSection }>) => {
      onNodeSelect(node.data.section);
    },
    [onNodeSelect]
  );

  const onPaneClick = useCallback(() => {
    onNodeSelect(null);
  }, [onNodeSelect]);

  return (
    <div className="w-full h-[420px] rounded-lg border border-stone-200 bg-stone-50">
      <ReactFlow
        nodes={nodes}
        edges={edges}
        onNodesChange={onNodesChange}
        onEdgesChange={onEdgesChange}
        onNodeClick={onNodeClick}
        onPaneClick={onPaneClick}
        nodeTypes={nodeTypes}
        fitView
        fitViewOptions={{ padding: 0.2 }}
        minZoom={0.3}
        maxZoom={1.5}
        defaultEdgeOptions={{
          type: 'smoothstep',
          animated: false,
          style: EDGE_STYLE,
          labelBgPadding: [4, 2],
          labelBgBorderRadius: 4,
        }}
      >
        <Background gap={12} size={1} color="#e5e7eb" />
        <Controls showInteractive={false} />
        <MiniMap nodeColor={(n) => statusColor((n.data as { section: SystemSection }).section.status)} />
        <Panel position="top-left" className="text-xs text-stone-500 bg-white/90 rounded px-2 py-1 shadow">
          Click a node for details • Drag to pan • Scroll to zoom
        </Panel>
      </ReactFlow>
    </div>
  );
}
