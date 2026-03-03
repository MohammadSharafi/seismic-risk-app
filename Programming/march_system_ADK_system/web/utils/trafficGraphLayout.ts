/**
 * Dagre-based layout for traffic topology: layered DAG with large spacing.
 * When nodes have tier, uses tier-based left-to-right layout (tier 1 leftmost).
 */
import dagre from 'dagre';
import type { Node, Edge } from '@xyflow/react';
import type { TrafficInspectorNode } from '../types/trafficInspector';

const NODE_WIDTH = 140;
const NODE_HEIGHT = 56;
const RANK_SEP = 120;
const NODE_SEP = 100;
const TIER_GAP = 180;
const NODE_GAP = 80;

export function getLayoutedElements<T extends { id: string; data?: { node?: TrafficInspectorNode } }>(
  nodes: Node<T>[],
  edges: Edge[],
  direction: 'TB' | 'BT' | 'LR' | 'RL' = 'LR'
): Node<T>[] {
  const hasTier = nodes.some(
    (n) => (n.data as { node?: TrafficInspectorNode } | undefined)?.node?.tier != null
  );

  if (hasTier) {
    return layoutByTier(nodes);
  }

  const g = new dagre.graphlib.Graph().setDefaultEdgeLabel(() => ({}));
  g.setGraph({
    rankdir: direction,
    ranksep: RANK_SEP,
    nodesep: NODE_SEP,
    edgesep: 20,
    marginx: 40,
    marginy: 40,
  });

  nodes.forEach((node) => {
    g.setNode(node.id, { width: NODE_WIDTH, height: NODE_HEIGHT });
  });

  edges.forEach((edge) => {
    g.setEdge(edge.source, edge.target);
  });

  dagre.layout(g);

  return nodes.map((node) => {
    const n = g.node(node.id);
    if (!n) return node;
    return {
      ...node,
      position: { x: n.x - NODE_WIDTH / 2, y: n.y - NODE_HEIGHT / 2 },
    };
  });
}

function layoutByTier<T extends { id: string; data?: { node?: TrafficInspectorNode } }>(
  nodes: Node<T>[]
): Node<T>[] {
  const byTier = new Map<number, Node<T>[]>();
  for (const n of nodes) {
    const tier = (n.data as { node?: TrafficInspectorNode } | undefined)?.node?.tier ?? 1;
    const list = byTier.get(tier) ?? [];
    list.push(n);
    byTier.set(tier, list);
  }
  const tiers = Array.from(byTier.keys()).sort((a, b) => a - b);

  const result: Node<T>[] = [];
  for (const tier of tiers) {
    const tierNodes = byTier.get(tier) ?? [];
    const x = (tier - 1) * TIER_GAP + 40;
    tierNodes.forEach((node, i) => {
      const y = i * (NODE_HEIGHT + NODE_GAP) + 40;
      result.push({
        ...node,
        position: { x, y: y - NODE_HEIGHT / 2 },
      });
    });
  }
  return result;
}
