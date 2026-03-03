import { EntityItem } from '../components/EntityPickerPalette';

// Visits
export const sampleVisits: EntityItem[] = [
  {
    id: 'VIS-1044',
    date: 'Jan 21, 2026',
    time: '10:30',
    type: 'IVF monitoring',
    summary: 'US: 8 follicles 12–16mm; continue meds; labs next 48h; stress red flag noted.',
    chips: ['Completed', 'Has note', 'Has labs', 'High priority']
  },
  {
    id: 'VIS-1039',
    date: 'Jan 18, 2026',
    time: '09:10',
    type: 'Follow-up',
    summary: 'Symptoms stable; adherence high; plan unchanged.',
    chips: ['Completed', 'Has note']
  },
  {
    id: 'VIS-1031',
    date: 'Jan 12, 2026',
    time: '14:00',
    type: 'Consult',
    summary: 'Discussed protocol options; baseline labs pending.',
    chips: ['Completed', 'Has labs']
  },
  {
    id: 'VIS-1028',
    date: 'Jan 10, 2026',
    time: '11:15',
    type: 'IVF monitoring',
    summary: 'E2 rising appropriately; 6 follicles >10mm; continue current protocol.',
    chips: ['Completed', 'Has note', 'Has labs']
  },
  {
    id: 'VIS-1021',
    date: 'Jan 5, 2026',
    time: '08:30',
    type: 'Baseline',
    summary: 'AFC 11; all baseline labs WNL; cleared to start stim cycle.',
    chips: ['Completed', 'Has note', 'Has labs']
  },
  {
    id: 'VIS-1015',
    date: 'Dec 28, 2025',
    time: '15:45',
    type: 'Follow-up',
    summary: 'Post-transfer week 2; beta hCG positive; continue progesterone support.',
    chips: ['Completed', 'Has note']
  },
  {
    id: 'VIS-1008',
    date: 'Dec 20, 2025',
    time: '10:00',
    type: 'Procedure',
    summary: 'Fresh embryo transfer day 5; grade AA blastocyst; patient tolerated well.',
    chips: ['Completed', 'Has note', 'High priority']
  },
  {
    id: 'VIS-1002',
    date: 'Dec 15, 2025',
    time: '07:30',
    type: 'Retrieval',
    summary: 'Egg retrieval: 12 oocytes collected; patient stable post-procedure.',
    chips: ['Completed', 'Has note', 'Has labs']
  }
];

// Alerts
export const sampleAlerts: EntityItem[] = [
  {
    id: 'ALT-5892',
    date: 'Jan 23, 2026',
    time: '08:15',
    type: 'Lab critical',
    severity: 'critical',
    summary: 'E2 >4000 pg/mL — consider OHSS risk; reduce stimulation or trigger decision needed.',
    chips: ['Critical', 'Unresolved', 'Requires action']
  },
  {
    id: 'ALT-5881',
    date: 'Jan 22, 2026',
    time: '14:30',
    type: 'Medication adherence',
    severity: 'high',
    summary: 'Patient missed 2 doses of Gonal-F; contact for adherence check.',
    chips: ['High priority', 'Pending']
  },
  {
    id: 'ALT-5874',
    date: 'Jan 21, 2026',
    time: '10:45',
    type: 'Symptom reported',
    severity: 'medium',
    summary: 'Patient reports severe bloating and mild abdominal pain; monitor for OHSS.',
    chips: ['Acknowledged']
  },
  {
    id: 'ALT-5862',
    date: 'Jan 20, 2026',
    time: '09:00',
    type: 'Follow-up overdue',
    severity: 'medium',
    summary: 'Post-procedure follow-up scheduled 5 days ago; no-show recorded.',
    chips: ['Pending']
  },
  {
    id: 'ALT-5855',
    date: 'Jan 18, 2026',
    time: '16:20',
    type: 'Lab result',
    severity: 'low',
    summary: 'TSH slightly elevated at 3.2; consider thyroid support.',
    chips: ['Resolved']
  },
  {
    id: 'ALT-5847',
    date: 'Jan 17, 2026',
    time: '11:30',
    type: 'System flag',
    severity: 'low',
    summary: 'Duplicate lab order detected for AMH; cancel duplicate order.',
    chips: ['Resolved']
  },
  {
    id: 'ALT-5839',
    date: 'Jan 15, 2026',
    time: '08:45',
    type: 'Consent missing',
    severity: 'high',
    summary: 'Embryo cryopreservation consent not signed; patient needs to complete.',
    chips: ['High priority', 'Pending']
  },
  {
    id: 'ALT-5821',
    date: 'Jan 12, 2026',
    time: '13:10',
    type: 'Insurance issue',
    severity: 'medium',
    summary: 'Pre-authorization pending for ICSI procedure; verify coverage.',
    chips: ['Resolved']
  }
];

// Assessments
export const sampleAssessments: EntityItem[] = [
  {
    id: 'ASS-2048',
    date: 'Jan 22, 2026',
    time: '09:00',
    type: 'Stimulation monitoring',
    summary: 'Day 8 stim: 10 follicles 10-14mm; E2 1850 pg/mL; FSH 6.2; LH 2.1. Continue protocol.',
    chips: ['Completed', 'Has labs']
  },
  {
    id: 'ASS-2041',
    date: 'Jan 20, 2026',
    time: '08:30',
    type: 'Stimulation monitoring',
    summary: 'Day 6 stim: 8 follicles 8-12mm; E2 980 pg/mL; responding well to protocol.',
    chips: ['Completed', 'Has labs']
  },
  {
    id: 'ASS-2034',
    date: 'Jan 18, 2026',
    time: '07:45',
    type: 'Baseline assessment',
    summary: 'Baseline US: AFC 12; E2 <50; all baseline labs WNL; cleared to start stimulation.',
    chips: ['Completed', 'Has labs']
  },
  {
    id: 'ASS-2029',
    date: 'Jan 15, 2026',
    time: '10:15',
    type: 'Pre-cycle screening',
    summary: 'AMH 3.2 ng/mL; normal ovarian reserve; TSH 2.1; CBC WNL; ready for protocol.',
    chips: ['Completed', 'Has labs']
  },
  {
    id: 'ASS-2021',
    date: 'Jan 10, 2026',
    time: '09:30',
    type: 'Consultation',
    summary: 'Initial fertility assessment: regular cycles; partner SA pending; discussed IVF options.',
    chips: ['Completed']
  },
  {
    id: 'ASS-2014',
    date: 'Jan 5, 2026',
    time: '14:00',
    type: 'Post-transfer',
    summary: 'Week 2 post-transfer: beta hCG 245; appropriate rise; continue progesterone.',
    chips: ['Completed', 'Has labs', 'High priority']
  },
  {
    id: 'ASS-2008',
    date: 'Dec 28, 2025',
    time: '08:00',
    type: 'Transfer day',
    summary: 'Fresh day 5 transfer: grade AA blastocyst; excellent endometrial lining 10mm.',
    chips: ['Completed', 'High priority']
  },
  {
    id: 'ASS-2001',
    date: 'Dec 20, 2025',
    time: '07:15',
    type: 'Retrieval',
    summary: 'Egg retrieval: 14 oocytes retrieved; 12 mature (MII); ICSI performed.',
    chips: ['Completed', 'High priority', 'Has labs']
  }
];

// Exports
export const sampleExports: EntityItem[] = [
  {
    id: 'EXP-3421',
    date: 'Jan 22, 2026',
    time: '16:45',
    type: 'PDF Report',
    title: 'Cycle Summary Report',
    summary: 'Complete cycle summary including assessments, labs, medications, and outcomes.',
    chips: ['Ready', 'PDF', '2.4 MB']
  },
  {
    id: 'EXP-3418',
    date: 'Jan 21, 2026',
    time: '11:30',
    type: 'CSV Export',
    title: 'Lab Results Dataset',
    summary: 'All laboratory results from last 3 months: hormones, metabolic panel, etc.',
    chips: ['Ready', 'CSV', '156 KB']
  },
  {
    id: 'EXP-3412',
    date: 'Jan 20, 2026',
    time: '09:15',
    type: 'PDF Report',
    title: 'Risk Analysis Report',
    summary: 'Comprehensive risk assessment including drivers, trends, and mitigation strategies.',
    chips: ['Ready', 'PDF', '1.8 MB']
  },
  {
    id: 'EXP-3407',
    date: 'Jan 18, 2026',
    time: '14:20',
    type: 'CSV Export',
    title: 'Medication History',
    summary: 'Complete medication administration records for current cycle.',
    chips: ['Ready', 'CSV', '89 KB']
  },
  {
    id: 'EXP-3401',
    date: 'Jan 15, 2026',
    time: '10:00',
    type: 'PDF Report',
    title: 'Patient Care Summary',
    summary: 'Comprehensive care summary for insurance pre-authorization.',
    chips: ['Ready', 'PDF', '3.1 MB']
  },
  {
    id: 'EXP-3395',
    date: 'Jan 12, 2026',
    time: '15:45',
    type: 'CSV Export',
    title: 'Assessment Trends',
    summary: 'Time series data of key assessment metrics over last 6 months.',
    chips: ['Ready', 'CSV', '203 KB']
  },
  {
    id: 'EXP-3388',
    date: 'Jan 10, 2026',
    time: '08:30',
    type: 'PDF Report',
    title: 'Clinical Notes Bundle',
    summary: 'All clinical notes from visits in current treatment cycle.',
    chips: ['Ready', 'PDF', '1.2 MB']
  },
  {
    id: 'EXP-3382',
    date: 'Jan 8, 2026',
    time: '13:15',
    type: 'CSV Export',
    title: 'Alert History',
    summary: 'Historical alert data including resolution times and outcomes.',
    chips: ['Ready', 'CSV', '67 KB']
  }
];

// Simulations
export const sampleSimulations: EntityItem[] = [
  {
    id: 'SIM-7721',
    date: 'Jan 22, 2026',
    time: '15:30',
    type: 'Protocol adjustment',
    title: 'What if: Reduce Gonal-F to 150 IU',
    summary: 'Predicted outcome: 8-10 follicles, E2 ~2200, OHSS risk reduced by 35%, similar retrieval success.',
    chips: ['Completed', 'Recommended']
  },
  {
    id: 'SIM-7714',
    date: 'Jan 21, 2026',
    time: '10:15',
    type: 'Trigger timing',
    title: 'What if: Trigger 24h earlier',
    summary: 'Predicted outcome: 7-9 mature oocytes (vs. 9-11), slightly lower maturation rate.',
    chips: ['Completed']
  },
  {
    id: 'SIM-7708',
    date: 'Jan 20, 2026',
    time: '14:45',
    type: 'Add antagonist',
    title: 'What if: Add Cetrotide on day 6',
    summary: 'Predicted outcome: reduced premature LH surge risk, similar follicle development.',
    chips: ['Completed', 'Recommended']
  },
  {
    id: 'SIM-7701',
    date: 'Jan 18, 2026',
    time: '09:30',
    type: 'Protocol comparison',
    title: 'Antagonist vs. Long Agonist',
    summary: 'Antagonist protocol predicted: shorter cycle, lower OHSS risk, similar success rates.',
    chips: ['Completed']
  },
  {
    id: 'SIM-7695',
    date: 'Jan 15, 2026',
    time: '11:20',
    type: 'Dose optimization',
    title: 'What if: Start at 200 IU vs. 225 IU',
    summary: 'Predicted outcome: 200 IU → 9-11 follicles, slightly longer stim but lower med cost.',
    chips: ['Completed']
  },
  {
    id: 'SIM-7688',
    date: 'Jan 12, 2026',
    time: '16:00',
    type: 'Cycle timing',
    title: 'What if: Delay cycle start by 1 week',
    summary: 'Predicted outcome: no significant impact on success; allows time for metabolic optimization.',
    chips: ['Completed', 'Recommended']
  },
  {
    id: 'SIM-7681',
    date: 'Jan 10, 2026',
    time: '08:45',
    type: 'Transfer strategy',
    title: 'Fresh vs. Frozen transfer',
    summary: 'Frozen transfer predicted: 8% higher implantation rate due to optimal endometrial prep.',
    chips: ['Completed', 'High priority']
  },
  {
    id: 'SIM-7674',
    date: 'Jan 8, 2026',
    time: '13:30',
    type: 'Lifestyle intervention',
    title: 'What if: 3-month lifestyle optimization',
    summary: 'Predicted outcome: improved egg quality metrics, 12% increase in euploidy rate.',
    chips: ['Completed']
  }
];

// Red Flags
export const sampleRedFlags: EntityItem[] = [
  {
    id: 'FLAG-184',
    date: 'Jan 22, 2026',
    time: '09:00',
    type: 'Clinical risk',
    severity: 'high',
    title: 'High OHSS risk',
    summary: 'E2 >3500 pg/mL with 18 follicles; consider coast, reduce trigger dose, or cancel cycle.',
    chips: ['Unacknowledged', 'High priority']
  },
  {
    id: 'FLAG-183',
    date: 'Jan 21, 2026',
    time: '14:30',
    type: 'Patient reported',
    severity: 'medium',
    title: 'Severe stress and anxiety',
    summary: 'Patient reports high stress levels affecting sleep and eating; consider mental health support.',
    chips: ['Unacknowledged']
  },
  {
    id: 'FLAG-182',
    date: 'Jan 20, 2026',
    time: '10:15',
    type: 'Lab abnormality',
    severity: 'medium',
    title: 'Thyroid function borderline',
    summary: 'TSH 3.8 mIU/L; may impact cycle outcome; consider thyroid support or retest.',
    chips: ['Acknowledged']
  },
  {
    id: 'FLAG-181',
    date: 'Jan 18, 2026',
    time: '08:45',
    type: 'Medication issue',
    severity: 'high',
    title: 'Missed critical doses',
    summary: 'Patient missed trigger shot timing by 3 hours; may impact retrieval quality.',
    chips: ['Acknowledged', 'High priority']
  },
  {
    id: 'FLAG-180',
    date: 'Jan 15, 2026',
    time: '16:00',
    type: 'Poor response',
    severity: 'medium',
    title: 'Suboptimal follicular response',
    summary: 'Only 4 follicles on day 8 of stim; consider protocol adjustment or cycle cancellation.',
    chips: ['Acknowledged']
  },
  {
    id: 'FLAG-179',
    date: 'Jan 12, 2026',
    time: '11:30',
    type: 'Financial concern',
    severity: 'low',
    title: 'Medication cost burden',
    summary: 'Patient expressed financial stress regarding medication costs; explore alternatives.',
    chips: ['Acknowledged']
  },
  {
    id: 'FLAG-178',
    date: 'Jan 10, 2026',
    time: '09:20',
    type: 'Partner issue',
    severity: 'medium',
    title: 'Partner unavailable for retrieval',
    summary: 'Partner may not be available for fresh sample; discuss backup options.',
    chips: ['Resolved']
  },
  {
    id: 'FLAG-177',
    date: 'Jan 8, 2026',
    time: '15:10',
    type: 'Endometrial concern',
    severity: 'medium',
    title: 'Thin endometrial lining',
    summary: 'Endometrium only 6mm on day 12; may need estrogen support or cycle delay.',
    chips: ['Resolved']
  }
];
