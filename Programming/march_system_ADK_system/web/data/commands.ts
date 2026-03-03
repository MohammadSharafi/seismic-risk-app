// Command system documentation
// Base commands supported by the backend (PolicyEngine.ALLOWED_COMMANDS). Keep in sync with backend.
export const BACKEND_BASE_COMMANDS = new Set([
  '/summary', '/alerts', '/risk_profile', '/risk_drivers', '/risk_mitigation', '/risk_compare',
  '/twin_snapshot', '/simulate', '/simulation_result', '/latest_assessment', '/redflags', '/ack_redflag',
  '/assessment_detail', '/assessment_trend', '/alert_detail', '/resolve_alert', '/escalate', '/create_alert',
  '/draft_note', '/draft_plan', '/update_plan', '/save_plan', '/plan_diff', '/revise_note',
  '/export_pdf', '/export_csv', '/list_exports', '/download_export', '/fhir_patient'
]);

// UI-only: handled in frontend, not sent to API
export const UI_ONLY_BASE_COMMANDS = new Set(['/clear', '/new_thread', '/help', '/shortcuts']);

export function isBackendCommand(baseCommand: string): boolean {
  const normalized = baseCommand.startsWith('/') ? baseCommand.toLowerCase() : '/' + baseCommand.toLowerCase();
  return BACKEND_BASE_COMMANDS.has(normalized);
}

export const commandCategories = {
  'Patient / Context': [
    '/change_patient - Switch to different patient',
    '/context on|off - Toggle patient context',
    '/fhir_patient - Load patient from FHIR server (when configured)',
    '/sources - View active data sources',
    '/mode compact|standard|detailed - Set response density',
    '/window last_7_days|last_14_days - Set time window'
  ],
  'Assessments': [
    '/latest_assessment - Show most recent assessment',
    '/assessment_detail <ID> - Show detailed assessment',
    '/redflags - Show red flags requiring attention',
    '/ack_redflag <ID> - Acknowledge a red flag',
    '/assessment_trend <METRIC> - Show metric trend'
  ],
  'Risk': [
    '/risk_profile - Show current risk profile',
    '/risk_drivers - Show key risk drivers',
    '/risk_mitigation - Show mitigation strategies',
    '/risk_compare - Compare risk over time'
  ],
  'Alerts': [
    '/alerts - Show active alerts',
    '/alert_detail <ID> - Show alert details',
    '/create_alert - Create new alert',
    '/resolve_alert <ID> - Resolve an alert',
    '/escalate <ID> - Escalate an alert'
  ],
  'Digital Twin': [
    '/twin_snapshot - Show current twin state',
    '/simulate - Run what-if simulation',
    '/simulation_result <ID> - View simulation result'
  ],
  'Plans': [
    '/draft_plan - Generate treatment plan draft',
    '/update_plan - Update existing plan',
    '/save_plan - Save plan to EHR',
    '/plan_diff - Compare plan versions'
  ],
  'Notes': [
    '/draft_note - Generate clinical note draft',
    '/revise_note "<instruction>" - Revise note',
    '/finalize_note - Finalize note for signing',
    '/log_note - Log note to EHR'
  ],
  'Exports': [
    '/export_pdf - Export data as PDF',
    '/export_csv - Export data as CSV',
    '/list_exports - List recent exports',
    '/download_export <ID> - Download export file'
  ]
};

// Quick prompt mappings
export const quickPromptCommands = {
  'Summary': '/summary',
  'Latest assessment': '/latest_assessment',
  'Risk factors': '/risk_drivers',
  'Alerts': '/alerts',
  'FHIR patient': '/fhir_patient',
  'Twin snapshot': '/twin_snapshot',
  'Run simulation': '/simulate',
  'Draft note': '/draft_note',
  'Draft plan': '/draft_plan',
  'Export PDF': '/export_pdf'
};
