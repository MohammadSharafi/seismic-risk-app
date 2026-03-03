import type { TrafficInspectorEdge, TrafficInspectorNode } from '../types/trafficInspector';

/** Node IDs matching backend topology health and Pedshia architecture. */
export const MARCH_NODE_IDS = {
  client: 'client',
  api: 'march-api',
  guardrail: 'guardrail',
  audit: 'audit',
  interpreter: 'interpreter',
  planner: 'planner',
  contextSummarizer: 'context-summarizer',
  orchestrator: 'orchestrator',
  multiAgentPlatform: 'multi-agent-platform',
  tools: 'tool-executor',
  mcp: 'mcp-server',
  rag: 'rag',
  sqlDb: 'sql-query-db',
  contextRepo: 'patient-context-repo',
  sessionStore: 'session-store',
  responseHub: 'response-hub',
  sse: 'sse-stream',
  postgres: 'postgres',
  dynamodb: 'dynamodb',
  redis: 'redis',
} as const;

export type NodeHealthMap = Partial<Record<string, 'UP' | 'DOWN' | 'DEGRADED'>>;

/** Build Pedshia topology with exact node list and edges. Health from API or fallback. */
export function buildMarchTopology(healthMap?: NodeHealthMap): {
  nodes: TrafficInspectorNode[];
  edges: TrafficInspectorEdge[];
} {
  const h = (id: string): TrafficInspectorNode['health'] =>
    healthMap?.[id] ?? 'UP';

  const node = (
    id: string,
    label: string,
    type: TrafficInspectorNode['type'],
    health: TrafficInspectorNode['health'],
    tier?: number
  ): TrafficInspectorNode => ({ id, label, type, health, ...(tier != null && { tier }) });

  const edge = (
    source: string,
    target: string,
    label: string,
    rps: number,
    latencyMs: number,
    errorRate: number,
    dashed?: boolean
  ): TrafficInspectorEdge => ({
    source,
    target,
    requestRatePerSec: rps,
    avgLatencyMs: latencyMs,
    errorRate,
    label,
    dashed,
  });

  const ids = MARCH_NODE_IDS;

  const nodes: TrafficInspectorNode[] = [
    node(ids.client, 'Client UI', 'service', h(ids.client), 1),
    node(ids.api, 'March API', 'api', h(ids.api), 2),
    node(ids.guardrail, 'Guardrail', 'service', h(ids.guardrail), 3),
    node(ids.audit, 'Audit', 'service', h(ids.audit), 3),
    node(ids.interpreter, 'Interpreter', 'service', h(ids.interpreter), 4),
    node(ids.planner, 'Planner', 'service', h(ids.planner), 4),
    node(ids.contextSummarizer, 'Context Summarizer', 'service', h(ids.contextSummarizer), 4),
    node(ids.orchestrator, 'Orchestrator', 'service', h(ids.orchestrator), 5),
    node(ids.multiAgentPlatform, 'Multi-Agent Platform', 'agent', h(ids.multiAgentPlatform), 5),
    node(ids.tools, 'Tool Executor', 'service', h(ids.tools), 6),
    node(ids.mcp, 'MCP Server (internal)', 'api', h(ids.mcp), 6),
    node(ids.rag, 'RAG', 'service', h(ids.rag), 6),
    node(ids.sqlDb, 'SQL / Query DB', 'database', h(ids.sqlDb), 6),
    node(ids.contextRepo, 'Patient Context Repo', 'service', h(ids.contextRepo), 7),
    node(ids.sessionStore, 'Session / Conversation Store', 'service', h(ids.sessionStore), 7),
    node(ids.responseHub, 'Response Hub', 'service', h(ids.responseHub), 8),
    node(ids.sse, 'SSE Stream', 'service', h(ids.sse), 8),
    node(ids.postgres, 'Postgres', 'database', h(ids.postgres), 9),
    node(ids.dynamodb, 'DynamoDB', 'database', h(ids.dynamodb), 9),
    node(ids.redis, 'Redis', 'database', h(ids.redis), 9),
  ];

  const edges: TrafficInspectorEdge[] = [
    edge(ids.client, ids.api, 'HTTP POST /chat', 1, 20, 0),
    edge(ids.api, ids.guardrail, 'Input message', 1, 10, 0),
    edge(ids.guardrail, ids.audit, 'Audit entry', 1, 5, 0),
    edge(ids.guardrail, ids.interpreter, 'n23 sanitized payload', 1, 20, 0),
    edge(ids.interpreter, ids.contextSummarizer, 'Patient context request', 0.6, 15, 0, true),
    edge(ids.contextSummarizer, ids.contextRepo, 'Query', 0.6, 12, 0),
    edge(ids.contextRepo, ids.dynamodb, 'Load / Save', 0.6, 12, 0),
    edge(ids.contextSummarizer, ids.interpreter, 'Patient history summary', 0.6, 10, 0),
    edge(ids.interpreter, ids.planner, 'PlanningContext', 1, 25, 0),
    edge(ids.planner, ids.orchestrator, 'ExecutionPlan', 1, 5, 0),
    edge(ids.planner, ids.multiAgentPlatform, 'Clinical recommendation request', 0.2, 80, 0, true),
    edge(ids.orchestrator, ids.tools, 'Step execution', 1, 35, 0),
    edge(ids.tools, ids.mcp, 'Tool call', 0.4, 90, 0),
    edge(ids.tools, ids.rag, 'Evidence query', 0.2, 80, 0),
    edge(ids.tools, ids.sqlDb, 'Data query', 0.8, 18, 0),
    edge(ids.mcp, ids.tools, 'ToolResult', 0.4, 5, 0),
    edge(ids.rag, ids.tools, 'Evidence results', 0.2, 5, 0),
    edge(ids.sqlDb, ids.tools, 'Query results', 0.8, 5, 0),
    edge(ids.orchestrator, ids.responseHub, 'tool_called / tool_result events', 1, 2, 0),
    edge(ids.planner, ids.responseHub, 'planner.status_update events', 1, 2, 0),
    edge(ids.responseHub, ids.sse, 'Thinking stream events', 1, 2, 0),
    edge(ids.planner, ids.api, 'Final response', 1, 5, 0),
    edge(ids.api, ids.guardrail, 'Output message', 1, 5, 0),
    edge(ids.guardrail, ids.api, 'n25 sanitized output', 1, 5, 0),
    edge(ids.api, ids.sse, 'Final tokens (channel: final)', 1, 2, 0),
    edge(ids.sse, ids.client, 'Dual-stream SSE', 1, 8, 0),
    edge(ids.sessionStore, ids.postgres, 'Read / Write', 0.8, 15, 0),
    edge(ids.planner, ids.sessionStore, 'Load history', 0.8, 12, 0),
    edge(ids.redis, ids.sessionStore, 'Hot cache', 0.5, 2, 0),
  ];

  return { nodes, edges };
}
