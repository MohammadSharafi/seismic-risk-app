import React from 'react';
import { getBezierPath, type EdgeProps, Position } from '@xyflow/react';

const SLOW_LATENCY_MS = 300;

export function edgeColor(errorRate: number, avgLatencyMs: number): string {
  if (errorRate >= 0.05) return '#dc2626';
  if (avgLatencyMs >= SLOW_LATENCY_MS) return '#ca8a04';
  return '#16a34a';
}

export function edgeStrokeWidth(rps: number): number {
  if (rps <= 0) return 1.5;
  return Math.min(6, Math.max(1.5, Math.log2(rps + 1) * 1.2));
}

export interface TrafficEdgeData {
  requestRatePerSec: number;
  avgLatencyMs: number;
  p95LatencyMs?: number;
  errorRate: number;
  /** Label level: 0 = none, 1 = compact (RPS + p95), 2 = full */
  labelLevel: 0 | 1 | 2;
  edgeId: string;
  /** Contract label (e.g. n23, ExecutionPlan) */
  label?: string;
  /** Dashed for CARF/DCRF-only edges */
  dashed?: boolean;
  /** Highlight: active in selected request, inactive, or error */
  highlight?: 'active' | 'inactive' | 'error' | 'none';
}

export function TrafficInspectorCustomEdge({
  id,
  sourceX,
  sourceY,
  targetX,
  targetY,
  sourcePosition,
  targetPosition,
  data,
  selected,
}: EdgeProps<unknown, TrafficEdgeData>) {
  const [path, labelX, labelY] = getBezierPath({
    sourceX,
    sourceY,
    sourcePosition: sourcePosition ?? Position.Right,
    targetX,
    targetY,
    targetPosition: targetPosition ?? Position.Left,
    curvature: 0.2,
  });

  const rps = data?.requestRatePerSec ?? 0;
  const avgMs = data?.avgLatencyMs ?? 0;
  const p95Ms = data?.p95LatencyMs;
  const errRate = data?.errorRate ?? 0;
  const labelLevel = data?.labelLevel ?? 0;
  const dashed = data?.dashed ?? false;
  const highlight = data?.highlight ?? 'none';

  let color = edgeColor(errRate, avgMs);
  if (highlight === 'active') color = '#16a34a';
  if (highlight === 'error') color = '#dc2626';
  if (highlight === 'inactive') color = '#94a3b8';

  const strokeWidth = edgeStrokeWidth(rps);
  const useSolidStroke = highlight === 'active' || highlight === 'error';

  const label =
    labelLevel === 1
      ? `${rps.toFixed(1)}/s · ${(p95Ms ?? avgMs).toFixed(0)}ms`
      : labelLevel === 2
        ? `${rps.toFixed(1)}/s · ${avgMs.toFixed(0)}ms · ${(errRate * 100).toFixed(1)}% err`
        : null;

  return (
    <>
      <defs>
        <marker
          id={`arrow-${id}`}
          markerWidth="10"
          markerHeight="10"
          refX="9"
          refY="3"
          orient="auto"
          markerUnits="strokeWidth"
        >
          <path d="M0,0 L0,6 L9,3 z" fill={color} />
        </marker>
      </defs>
      {/* Invisible wider path for hit area */}
      <path
        d={path}
        fill="none"
        stroke="transparent"
        strokeWidth={20}
        className="react-flow__edge-interaction"
      />
      {/* Main edge: curved, thickness by traffic, color by health */}
      <path
        d={path}
        fill="none"
        stroke={color}
        strokeWidth={selected ? strokeWidth + 1.5 : strokeWidth}
        strokeLinecap="round"
        strokeDasharray={useSolidStroke ? undefined : dashed ? '6 4' : rps > 0 ? '8 6' : undefined}
        style={
          rps > 0 && !useSolidStroke
            ? {
                animation: 'traffic-edge-dash 0.8s linear infinite',
              }
            : undefined
        }
        markerEnd={`url(#arrow-${id})`}
      />
      {selected && (
        <path
          d={path}
          fill="none"
          stroke="rgba(59, 130, 246, 0.4)"
          strokeWidth={strokeWidth + 8}
          strokeLinecap="round"
          className="pointer-events-none"
        />
      )}
      {label && (
        <g transform={`translate(${labelX}, ${labelY})`}>
          <rect
            x={-36}
            y={-8}
            width={72}
            height={16}
            rx={4}
            fill="rgba(255,255,255,0.95)"
            stroke="#e5e7eb"
            strokeWidth={1}
          />
          <text
            textAnchor="middle"
            dominantBaseline="middle"
            className="text-[10px] fill-stone-600 font-medium"
          >
            {label}
          </text>
        </g>
      )}
    </>
  );
}
