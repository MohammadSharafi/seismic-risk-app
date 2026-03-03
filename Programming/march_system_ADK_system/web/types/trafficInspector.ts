/**
 * Data model for the real-time network and service traffic inspector.
 * See docs/TRAFFIC-INSPECTOR-SPEC.md.
 */

export type NodeHealth = 'UP' | 'DOWN' | 'DEGRADED';

export interface TrafficInspectorNode {
  id: string;
  label: string;
  type: 'service' | 'api' | 'database' | 'queue' | 'agent';
  health: NodeHealth;
  /** Tier for layout (1=leftmost, 9=rightmost) */
  tier?: number;
  cpuPercent?: number;
  memoryUsedMB?: number;
  instanceCount?: number;
  queueDepth?: number;
}

export interface TrafficInspectorEdge {
  source: string;
  target: string;
  requestRatePerSec: number;
  avgLatencyMs: number;
  errorRate: number;
  activeRequestCount?: number;
  /** Contract/payload label (e.g. n23, n24, ExecutionPlan) */
  label?: string;
  /** Dashed for CARF/DCRF-only edges */
  dashed?: boolean;
}

/** Per-endpoint breakdown for an aggregated service-to-service edge */
export interface TrafficInspectorEdgeEndpoint {
  endpoint?: string;
  method?: string;
  requestRatePerSec: number;
  avgLatencyMs: number;
  p95LatencyMs?: number;
  errorRate: number;
  lastSampleAt?: string;
}

/** Single aggregated edge between two services (multiple endpoints bundled) */
export interface AggregatedTrafficEdge {
  source: string;
  target: string;
  requestRatePerSec: number;
  avgLatencyMs: number;
  p95LatencyMs?: number;
  errorRate: number;
  /** Endpoint-level breakdown when available (from stream or backend) */
  endpoints?: TrafficInspectorEdgeEndpoint[];
  /** Contract/payload label */
  label?: string;
  /** Dashed for optional flows (CARF/DCRF only) */
  dashed?: boolean;
}

export type EventProtocol = 'HTTP' | 'gRPC' | 'WS' | 'DB' | 'Queue' | 'Internal';

export type ExecutionFlow = 'EEF' | 'CARF' | 'DCRF';

export interface TrafficInspectorEvent {
  id: string;
  traceId: string;
  spanId: string;
  parentSpanId?: string;
  timestamp: string;
  source: string;
  destination: string;
  protocol: EventProtocol;
  endpoint?: string;
  method?: string;
  statusCode?: number;
  status: 'ok' | 'error' | 'timeout';
  latencyMs: number;
  requestSizeBytes?: number;
  responseSizeBytes?: number;
  /** EEF | CARF | DCRF */
  flow?: ExecutionFlow;
  /** Tool called (if applicable) */
  tool?: string;
  /** Last 8 chars of patient_id hash — never full PHI */
  patientIdHash?: string;
}

export interface TrafficInspectorEventDetail extends TrafficInspectorEvent {
  headers?: Record<string, string>;
  queryParams?: Record<string, string>;
  bodyPreview?: string;
  spans?: Array<{ spanId: string; name: string; durationMs: number; status: string }>;
}

export interface TrafficTopologyPayload {
  nodes: TrafficInspectorNode[];
  edges: TrafficInspectorEdge[];
  updatedAt?: string;
}

export type TrafficStreamMessage =
  | { type: 'event'; payload: TrafficInspectorEvent }
  | { type: 'topology'; payload: TrafficTopologyPayload };
