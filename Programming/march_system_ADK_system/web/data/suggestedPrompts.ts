/**
 * Suggested prompts for the Prompt Gallery (Copilot-style).
 * Shown in the "Suggested" tab; users can save these to "Your prompts".
 */
export interface SuggestedPrompt {
  id: string;
  title: string;
  prompt: string;
  category: string;
  description?: string;
  /** Label for attribution, e.g. "Suggested" */
  attribution?: string;
}

export const SUGGESTED_PROMPTS: SuggestedPrompt[] = [
  {
    id: 'suggest-summary',
    title: 'Patient summary',
    category: 'Patient / Context',
    prompt: '/summary',
    description: 'Get clinical summary for the current patient',
    attribution: 'Suggested',
  },
  {
    id: 'suggest-upcoming',
    title: 'Upcoming care items',
    category: 'Patient / Context',
    prompt: 'Show me upcoming care items and deadlines for this patient',
    description: 'Find pending tasks and time-sensitive items',
    attribution: 'Suggested',
  },
  {
    id: 'suggest-alerts',
    title: 'Active alerts',
    category: 'Alerts',
    prompt: '/alerts',
    description: 'List all active alerts requiring attention',
    attribution: 'Suggested',
  },
  {
    id: 'suggest-risk',
    title: 'Risk profile',
    category: 'Risk',
    prompt: '/risk_profile',
    description: 'Current risk level and factors',
    attribution: 'Suggested',
  },
  {
    id: 'suggest-risk-compare',
    title: 'Compare risk over time',
    category: 'Risk',
    prompt: '/risk_compare range=last_6_months',
    description: 'How risk has changed over the past 6 months',
    attribution: 'Suggested',
  },
  {
    id: 'suggest-simulate',
    title: 'Run simulation',
    category: 'Digital Twin',
    prompt: '/simulate',
    description: 'Run a what-if simulation',
    attribution: 'Suggested',
  },
  {
    id: 'suggest-draft-note',
    title: 'Draft clinical note',
    category: 'Notes',
    prompt: '/draft_note',
    description: 'Generate a clinical note draft',
    attribution: 'Suggested',
  },
  {
    id: 'suggest-draft-plan',
    title: 'Draft treatment plan',
    category: 'Plans',
    prompt: '/draft_plan',
    description: 'Generate a treatment plan draft',
    attribution: 'Suggested',
  },
  {
    id: 'suggest-redflags',
    title: 'Red flags',
    category: 'Assessments',
    prompt: '/redflags',
    description: 'Show red flags requiring attention',
    attribution: 'Suggested',
  },
  {
    id: 'suggest-twin',
    title: 'Twin snapshot',
    category: 'Digital Twin',
    prompt: '/twin_snapshot',
    description: 'Current digital twin state',
    attribution: 'Suggested',
  },
  {
    id: 'suggest-latest-assessment',
    title: 'Latest assessment',
    category: 'Assessments',
    prompt: '/latest_assessment',
    description: 'Get the most recent assessment',
    attribution: 'Suggested',
  },
  {
    id: 'suggest-export-pdf',
    title: 'Export PDF',
    category: 'Exports',
    prompt: '/export_pdf',
    description: 'Export data as PDF',
    attribution: 'Suggested',
  },
  // --- All remaining backend commands ---
  { id: 'suggest-risk-drivers', title: 'Risk drivers', category: 'Risk', prompt: '/risk_drivers', description: 'Key risk drivers', attribution: 'Suggested' },
  { id: 'suggest-risk-mitigation', title: 'Risk mitigation', category: 'Risk', prompt: '/risk_mitigation', description: 'Mitigation strategies', attribution: 'Suggested' },
  { id: 'suggest-fhir-patient', title: 'Load FHIR patient', category: 'Patient / Context', prompt: '/fhir_patient', description: 'Load patient from FHIR server', attribution: 'Suggested' },
  { id: 'suggest-assessment-detail', title: 'Assessment detail', category: 'Assessments', prompt: '/assessment_detail', description: 'Show detailed assessment (use with ID)', attribution: 'Suggested' },
  { id: 'suggest-assessment-trend', title: 'Assessment trend', category: 'Assessments', prompt: '/assessment_trend', description: 'Show metric trend over time', attribution: 'Suggested' },
  { id: 'suggest-ack-redflag', title: 'Acknowledge red flag', category: 'Assessments', prompt: '/ack_redflag', description: 'Acknowledge a red flag (use with ID)', attribution: 'Suggested' },
  { id: 'suggest-alert-detail', title: 'Alert detail', category: 'Alerts', prompt: '/alert_detail', description: 'Show alert details (use with ID)', attribution: 'Suggested' },
  { id: 'suggest-create-alert', title: 'Create alert', category: 'Alerts', prompt: '/create_alert', description: 'Create a new alert', attribution: 'Suggested' },
  { id: 'suggest-resolve-alert', title: 'Resolve alert', category: 'Alerts', prompt: '/resolve_alert', description: 'Resolve an alert (use with ID)', attribution: 'Suggested' },
  { id: 'suggest-escalate', title: 'Escalate alert', category: 'Alerts', prompt: '/escalate', description: 'Escalate an alert (use with ID)', attribution: 'Suggested' },
  { id: 'suggest-simulation-result', title: 'Simulation result', category: 'Digital Twin', prompt: '/simulation_result', description: 'View simulation result (use with ID)', attribution: 'Suggested' },
  { id: 'suggest-update-plan', title: 'Update plan', category: 'Plans', prompt: '/update_plan', description: 'Update existing treatment plan', attribution: 'Suggested' },
  { id: 'suggest-save-plan', title: 'Save plan', category: 'Plans', prompt: '/save_plan', description: 'Save plan to EHR', attribution: 'Suggested' },
  { id: 'suggest-plan-diff', title: 'Plan diff', category: 'Plans', prompt: '/plan_diff', description: 'Compare plan versions', attribution: 'Suggested' },
  { id: 'suggest-revise-note', title: 'Revise note', category: 'Notes', prompt: '/revise_note', description: 'Revise clinical note with instruction', attribution: 'Suggested' },
  { id: 'suggest-export-csv', title: 'Export CSV', category: 'Exports', prompt: '/export_csv', description: 'Export data as CSV', attribution: 'Suggested' },
  { id: 'suggest-list-exports', title: 'List exports', category: 'Exports', prompt: '/list_exports', description: 'List recent exports', attribution: 'Suggested' },
  { id: 'suggest-download-export', title: 'Download export', category: 'Exports', prompt: '/download_export', description: 'Download export file (use with ID)', attribution: 'Suggested' },
  // UI-only commands
  { id: 'suggest-help', title: 'Help', category: 'Patient / Context', prompt: '/help', description: 'Show available commands', attribution: 'Suggested' },
  { id: 'suggest-shortcuts', title: 'Keyboard shortcuts', category: 'Patient / Context', prompt: '/shortcuts', description: 'Show keyboard shortcuts', attribution: 'Suggested' },
  { id: 'suggest-new-thread', title: 'New conversation', category: 'Patient / Context', prompt: '/new_thread', description: 'Start a new conversation', attribution: 'Suggested' },
  { id: 'suggest-clear', title: 'Clear chat', category: 'Patient / Context', prompt: '/clear', description: 'Clear current conversation', attribution: 'Suggested' },
];

export const PROMPT_CATEGORIES = [
  'All',
  'Patient / Context',
  'Assessments',
  'Alerts',
  'Risk',
  'Digital Twin',
  'Notes',
  'Plans',
  'Exports',
] as const;

/** Semantic colors for category badges in the Prompt Gallery */
export const CATEGORY_COLORS: Record<string, { bg: string; text: string }> = {
  'Patient / Context': { bg: 'bg-sky-500/12 dark:bg-sky-400/15', text: 'text-sky-700 dark:text-sky-300' },
  Assessments: { bg: 'bg-violet-500/12 dark:bg-violet-400/15', text: 'text-violet-700 dark:text-violet-300' },
  Alerts: { bg: 'bg-amber-500/12 dark:bg-amber-400/15', text: 'text-amber-700 dark:text-amber-300' },
  Risk: { bg: 'bg-rose-500/12 dark:bg-rose-400/15', text: 'text-rose-700 dark:text-rose-300' },
  'Digital Twin': { bg: 'bg-emerald-500/12 dark:bg-emerald-400/15', text: 'text-emerald-700 dark:text-emerald-300' },
  Notes: { bg: 'bg-indigo-500/12 dark:bg-indigo-400/15', text: 'text-indigo-700 dark:text-indigo-300' },
  Plans: { bg: 'bg-primary/15 dark:bg-primary/20', text: 'text-primary' },
  Exports: { bg: 'bg-zinc-500/12 dark:bg-zinc-400/15', text: 'text-zinc-600 dark:text-zinc-400' },
};
