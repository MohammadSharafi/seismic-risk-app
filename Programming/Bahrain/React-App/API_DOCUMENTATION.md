# Clinical Visit Analysis API Documentation

## Overview

This document describes the API endpoints for the Clinical Visit Analysis workflow, which consists of 4 steps:
1. **Patient State** - Review current patient data
2. **AI Assessment** - Generate AI-powered clinical analysis
3. **Clinical Decision** - Doctor reviews and finalizes decision
4. **Finalized** - Visit record is saved

---

## Endpoint 1: Generate AI Analysis

### Request

**Endpoint:** `POST /api/visits/{encounter_id}/analyze`

**Headers:**
```
Content-Type: application/json
Authorization: Bearer {token}
```

**Path Parameters:**
- `encounter_id` (string, required) - The encounter/visit ID

**Request Body:**
```json
{
  "patient_id": "pat_fatima_alkhalifa_001",
  "encounter_id": "enc_fatima_20260109_01",
  "visit_trigger": {
    "type": "Background Monitoring Alert",
    "timestamp": "2026-01-09T09:15:00Z",
    "source": "AI"
  }
}
```

**Alternative Request (without visit_trigger):**
```json
{
  "patient_id": "pat_fatima_alkhalifa_001",
  "encounter_id": "enc_fatima_20260109_01"
}
```

**Request Fields:**
- `patient_id` (string, required) - Patient identifier
- `encounter_id` (string, required) - Encounter identifier
- `visit_trigger` (object, optional) - Information about what triggered this visit
  - `type` (string, enum) - One of: `"Background Monitoring Alert"`, `"Scheduled Follow-up"`, `"Manual Review"`, `"Alarm-Triggered Review"`
  - `timestamp` (string, ISO 8601) - When the trigger occurred
  - `source` (string, enum) - One of: `"AI"`, `"System"`, `"Doctor"`

### Response

**Status Code:** `200 OK`

**Response Body:**
```json
{
  "analysis_id": "analysis_20260109_001",
  "encounter_id": "enc_fatima_20260109_01",
  "patient_id": "pat_fatima_alkhalifa_001",
  "risk_tier": "High",
  "reasoning": [
    "Multiple high-risk comorbidities detected: Chronic hypertension, Renal vulnerability",
    "Elevated blood pressure above target range (156/98 mmHg)",
    "Missed antihypertensive medication doses documented",
    "Overdue preeclampsia surveillance labs (ordered Jan 9, not completed)",
    "Missed MFM follow-up appointment (scheduled Dec 27, no-show)"
  ],
  "evidence_references": [
    {
      "type": "observation",
      "label": "BP 156/98 (Jan 9, 14:40)",
      "observation_id": "obs_fatima_20260109_01",
      "source": "vitals",
      "timestamp": "2026-01-09T14:40:00Z",
      "status": null
    },
    {
      "type": "condition",
      "label": "Chronic hypertension (Active)",
      "condition_id": "cond_fatima_20210903_01",
      "source": "problem_list",
      "timestamp": null,
      "status": "active"
    },
    {
      "type": "medication_request",
      "label": "Labetalol 200mg BID - Missed refill",
      "medication_request_id": "medreq_fatima_20251218_01",
      "source": "medication",
      "status": "overdue"
    },
    {
      "type": "procedure",
      "label": "Preeclampsia labs - Not completed",
      "procedure_id": "proc_fatima_20260109_02",
      "source": "lab_order",
      "status": "ordered"
    },
    {
      "type": "encounter",
      "label": "MFM follow-up - No-show",
      "encounter_id": "enc_fatima_20251227_01",
      "source": "appointment",
      "status": "cancelled"
    }
  ],
  "medication_recommendations": [
    {
      "id": "med_rec_001",
      "medication": "Labetalol",
      "dose": "200 mg",
      "frequency": "twice daily",
      "duration": "Ongoing",
      "rationale": "Restore antihypertensive coverage after missed refill; current BP elevated",
      "evidence": [
        "BP 156/98 (Jan 9, 14:40)",
        "Medication refill overdue since Dec 16"
      ],
      "status": "Planned",
      "medication_id": "med_labetalol_tab_100mg",
      "action": "restart"
    },
    {
      "id": "med_rec_003",
      "medication": "Aspirin",
      "dose": "81 mg",
      "frequency": "once daily",
      "duration": null,
      "rationale": "Preeclampsia prophylaxis",
      "evidence": [
        "Chronic HTN in pregnancy",
        "Renal vulnerability"
      ],
      "status": "Planned",
      "medication_id": null,
      "action": "add"
    },
    {
      "id": "med_rec_002",
      "medication": "Nifedipine ER",
      "dose": "30 mg",
      "frequency": "once daily",
      "duration": "Ongoing",
      "rationale": "Adjunct therapy for BP control escalation in pregnancy",
      "evidence": [
        "BP 156/98 (Jan 9, 14:40)",
        "Chronic HTN in pregnancy"
      ],
      "status": "Planned",
      "medication_id": "med_nifedipine_er_tab_30mg",
      "action": "add"
    }
  ],
  "procedure_recommendations": [
    {
      "id": "proc_rec_001",
      "procedure": "Preeclampsia evaluation panel (CBC, CMP/LFTs, urine protein quantification)",
      "timing": "Immediate (within 24 hours)",
      "rationale": "Complete overdue surveillance labs for suspected preeclampsia evaluation",
      "evidence": [
        "Symptom-triggered evaluation (headache, visual changes, edema)",
        "Urine protein 2+ on dipstick",
        "BP 156/98 mmHg"
      ],
      "status": "Planned",
      "procedure_category": "laboratory",
      "priority": "urgent"
    },
    {
      "id": "proc_rec_002",
      "procedure": "Non-stress test (NST)",
      "timing": "Same day",
      "rationale": "Fetal assessment during maternal hypertensive symptoms",
      "evidence": [
        "BP 156/98 mmHg",
        "Suspected preeclampsia evaluation"
      ],
      "status": "Planned",
      "procedure_category": "other",
      "priority": "urgent"
    },
    {
      "id": "proc_rec_003",
      "procedure": "Schedule high-risk OB follow-up",
      "timing": "Within 7 days",
      "rationale": "Close follow-up after medication adjustment and lab completion",
      "evidence": [
        "Missed MFM follow-up (Dec 27)",
        "Active preeclampsia evaluation"
      ],
      "status": "Planned",
      "procedure_category": "other",
      "priority": "routine"
    }
  ],
  "model_version": "ClinicalAI v3.2.1",
  "analysis_timestamp": "2026-01-09T15:20:00Z",
  "confidence_score": 0.87,
  "data_freshness": {
    "last_updated": "2026-01-09T14:40:00Z",
    "age_days": 0
  }
}
```

**Response Fields:**

- `analysis_id` (string) - Unique identifier for this analysis
- `encounter_id` (string) - Encounter identifier
- `patient_id` (string) - Patient identifier
- `risk_tier` (string, enum) - One of: `"Low"`, `"Medium"`, `"High"`
- `reasoning` (array of strings) - List of clinical reasoning points
- `evidence_references` (array of objects) - References to supporting clinical data
  - `type` (string) - Type of evidence: `"observation"`, `"condition"`, `"medication_request"`, `"procedure"`, `"encounter"`
  - `label` (string) - Human-readable label for display
  - `{type}_id` (string) - ID of the referenced entity (e.g., `observation_id`, `condition_id`)
  - `source` (string) - Source category
  - `timestamp` (string, ISO 8601, optional) - When the evidence was recorded
  - `status` (string, optional) - Status of the referenced entity
- `medication_recommendations` (array of objects) - AI-proposed medication changes
  - `id` (string) - Unique recommendation ID
  - `medication` (string) - Medication name
  - `dose` (string) - Dosage
  - `frequency` (string) - Frequency of administration
  - `duration` (string, optional) - Duration of treatment
  - `rationale` (string) - Clinical justification
  - `evidence` (array of strings) - Evidence supporting this recommendation
  - `status` (string, enum) - `"Planned"` or `"Not planned"` (default: `"Planned"`)
  - `medication_id` (string, optional) - Reference to medication catalog
  - `action` (string, enum) - `"add"`, `"modify"`, `"restart"`, `"discontinue"`
- `procedure_recommendations` (array of objects) - AI-proposed procedures/orders
  - `id` (string) - Unique recommendation ID
  - `procedure` (string) - Procedure name
  - `timing` (string) - When to perform (e.g., "Immediate", "In 7 days")
  - `rationale` (string) - Clinical justification
  - `evidence` (array of strings) - Evidence supporting this recommendation
  - `status` (string, enum) - `"Planned"` or `"Not planned"` (default: `"Planned"`)
  - `procedure_category` (string) - Category: `"laboratory"`, `"imaging"`, `"other"`, etc.
  - `priority` (string, enum) - `"urgent"`, `"routine"`
- `model_version` (string) - AI model version used
- `analysis_timestamp` (string, ISO 8601) - When analysis was generated
- `confidence_score` (number, 0-1) - AI confidence level
- `data_freshness` (object) - Information about data recency
  - `last_updated` (string, ISO 8601) - Last data update timestamp
  - `age_days` (number) - Days since last update

**Alternative Response Example (Low Risk, Minimal Recommendations):**
```json
{
  "analysis_id": "analysis_20260110_002",
  "encounter_id": "enc_fatima_20260110_01",
  "patient_id": "pat_fatima_alkhalifa_001",
  "risk_tier": "Low",
  "reasoning": [
    "BP within target range (128/82 mmHg)",
    "All medications current and adherent",
    "Recent labs within normal limits"
  ],
  "evidence_references": [
    {
      "type": "observation",
      "label": "BP 128/82 (Jan 10, 10:00)",
      "observation_id": "obs_fatima_20260110_01",
      "source": "vitals",
      "timestamp": "2026-01-10T10:00:00Z",
      "status": null
    }
  ],
  "medication_recommendations": [],
  "procedure_recommendations": [
    {
      "id": "proc_rec_004",
      "procedure": "Continue routine monitoring",
      "timing": "Next scheduled visit",
      "rationale": "Stable condition, no changes needed",
      "evidence": [
        "BP 128/82 mmHg",
        "Stable on current regimen"
      ],
      "status": "Planned",
      "procedure_category": "other",
      "priority": "routine"
    }
  ],
  "model_version": "ClinicalAI v3.2.1",
  "analysis_timestamp": "2026-01-10T10:15:00Z",
  "confidence_score": 0.92,
  "data_freshness": {
    "last_updated": "2026-01-10T10:00:00Z",
    "age_days": 0
  }
}
```

**Error Responses:**

- `400 Bad Request` - Invalid request body or missing required fields
- `404 Not Found` - Encounter or patient not found
- `500 Internal Server Error` - Analysis generation failed

---

## Endpoint 2: Finalize Decision

### Request

**Endpoint:** `POST /api/visits/{encounter_id}/finalize`

**Headers:**
```
Content-Type: application/json
Authorization: Bearer {token}
```

**Path Parameters:**
- `encounter_id` (string, required) - The encounter/visit ID

**Request Body (Standard Example):**
```json
{
  "encounter_id": "enc_fatima_20260109_01",
  "patient_id": "pat_fatima_alkhalifa_001",
  "practitioner_id": "prac_laila_alhaddad_001",
  "analysis_id": "analysis_20260109_001",
  "doctor_decision": {
    "risk_tier": "High",
    "reasoning_notes": "Agree with AI assessment. Patient has multiple compounding risk factors: missed medication doses, overdue labs, and missed follow-up. BP elevated at 156/98. Proceeding with medication restart, lab completion, and close follow-up.",
    "ai_risk_tier": "High",
    "risk_tier_override": false,
    "override_rationale": null
  },
  "medications": [
    {
      "id": "med_rec_001",
      "medication": "Labetalol",
      "dose": "200 mg",
      "frequency": "twice daily",
      "duration": "Ongoing",
      "rationale": "Restore antihypertensive coverage after missed refill; current BP elevated",
      "evidence": [
        "BP 156/98 (Jan 9, 14:40)",
        "Medication refill overdue since Dec 16"
      ],
      "status": "Planned",
      "medication_id": "med_labetalol_tab_100mg",
      "action": "restart",
      "medication_request_id": null
    },
    {
      "id": "med_rec_002",
      "medication": "Nifedipine ER",
      "dose": "30 mg",
      "frequency": "once daily",
      "duration": "Ongoing",
      "rationale": "Adjunct therapy for BP control escalation in pregnancy",
      "evidence": [
        "BP 156/98 (Jan 9, 14:40)",
        "Chronic HTN in pregnancy"
      ],
      "status": "Planned",
      "medication_id": "med_nifedipine_er_tab_30mg",
      "action": "add",
      "medication_request_id": null
    },
    {
      "id": "med_rec_003",
      "medication": "Aspirin",
      "dose": "81 mg",
      "frequency": "once daily",
      "duration": null,
      "rationale": "Preeclampsia prophylaxis",
      "evidence": [
        "Chronic HTN in pregnancy"
      ],
      "status": "Planned",
      "medication_id": null,
      "action": "add",
      "medication_request_id": null
    }
  ],
  "procedures": [
    {
      "id": "proc_rec_001",
      "procedure": "Preeclampsia evaluation panel (CBC, CMP/LFTs, urine protein quantification)",
      "timing": "Immediate (within 24 hours)",
      "rationale": "Complete overdue surveillance labs for suspected preeclampsia evaluation",
      "evidence": [
        "Symptom-triggered evaluation (headache, visual changes, edema)",
        "Urine protein 2+ on dipstick",
        "BP 156/98 mmHg"
      ],
      "status": "Planned",
      "procedure_category": "laboratory",
      "priority": "urgent",
      "procedure_id": null
    },
    {
      "id": "proc_rec_002",
      "procedure": "Non-stress test (NST)",
      "timing": "Same day",
      "rationale": "Fetal assessment during maternal hypertensive symptoms",
      "evidence": [
        "BP 156/98 mmHg",
        "Suspected preeclampsia evaluation"
      ],
      "status": "Planned",
      "procedure_category": "other",
      "priority": "urgent",
      "procedure_id": null
    },
    {
      "id": "proc_rec_003",
      "procedure": "Schedule high-risk OB follow-up",
      "timing": "Within 7 days",
      "rationale": "Close follow-up after medication adjustment and lab completion",
      "evidence": [
        "Missed MFM follow-up (Dec 27)",
        "Active preeclampsia evaluation"
      ],
      "status": "Planned",
      "procedure_category": "other",
      "priority": "routine",
      "procedure_id": null
    }
  ],
  "timestamp": "2026-01-09T15:45:00Z"
}
```

**Alternative Request Examples:**

**Example 1: Risk Tier Override (Doctor disagrees with AI)**
```json
{
  "encounter_id": "enc_fatima_20260109_01",
  "patient_id": "pat_fatima_alkhalifa_001",
  "practitioner_id": "prac_laila_alhaddad_001",
  "analysis_id": "analysis_20260109_001",
  "doctor_decision": {
    "risk_tier": "Medium",
    "reasoning_notes": "While AI assessed as High risk, patient's BP has improved since last visit. Current readings are borderline. Adjusting to Medium risk with close monitoring.",
    "ai_risk_tier": "High",
    "risk_tier_override": true,
    "override_rationale": "BP improved from 156/98 to 142/88. Patient reports better medication adherence. Close monitoring sufficient."
  },
  "medications": [
    {
      "id": "med_rec_001",
      "medication": "Labetalol",
      "dose": "200 mg",
      "frequency": "twice daily",
      "duration": "Ongoing",
      "rationale": "Continue current dose, monitor response",
      "evidence": [
        "BP 142/88 (Jan 9, 14:40)",
        "Improved from previous readings"
      ],
      "status": "Planned",
      "medication_id": "med_labetalol_tab_100mg",
      "action": "modify",
      "medication_request_id": "medreq_fatima_20251218_01"
    }
  ],
  "procedures": [
    {
      "id": "proc_rec_001",
      "procedure": "Follow-up BP check",
      "timing": "In 2 weeks",
      "rationale": "Monitor response to current regimen",
      "evidence": [
        "BP 142/88 mmHg",
        "Recent improvement"
      ],
      "status": "Planned",
      "procedure_category": "other",
      "priority": "routine",
      "procedure_id": null
    }
  ],
  "timestamp": "2026-01-09T15:45:00Z"
}
```

**Example 2: No Medications, Only Procedures**
```json
{
  "encounter_id": "enc_fatima_20260110_01",
  "patient_id": "pat_fatima_alkhalifa_001",
  "practitioner_id": "prac_laila_alhaddad_001",
  "analysis_id": "analysis_20260110_002",
  "doctor_decision": {
    "risk_tier": "Low",
    "reasoning_notes": "Patient stable on current medications. No changes needed. Continue routine monitoring.",
    "ai_risk_tier": "Low",
    "risk_tier_override": false,
    "override_rationale": null
  },
  "medications": [],
  "procedures": [
    {
      "id": "proc_rec_004",
      "procedure": "Continue routine monitoring",
      "timing": "Next scheduled visit",
      "rationale": "Stable condition, no changes needed",
      "evidence": [
        "BP 128/82 mmHg",
        "Stable on current regimen"
      ],
      "status": "Planned",
      "procedure_category": "other",
      "priority": "routine",
      "procedure_id": null
    }
  ],
  "timestamp": "2026-01-10T10:30:00Z"
}
```

**Example 3: No Procedures, Only Medications**
```json
{
  "encounter_id": "enc_fatima_20260111_01",
  "patient_id": "pat_fatima_alkhalifa_001",
  "practitioner_id": "prac_laila_alhaddad_001",
  "analysis_id": "analysis_20260111_003",
  "doctor_decision": {
    "risk_tier": "Medium",
    "reasoning_notes": "Medication adjustment needed for better BP control. No additional procedures required at this time.",
    "ai_risk_tier": "Medium",
    "risk_tier_override": false,
    "override_rationale": null
  },
  "medications": [
    {
      "id": "med_rec_004",
      "medication": "Labetalol",
      "dose": "300 mg",
      "frequency": "twice daily",
      "duration": null,
      "rationale": "Increase dose for better BP control",
      "evidence": [
        "BP 148/92 (Jan 11, 09:00)",
        "Current dose insufficient"
      ],
      "status": "Planned",
      "medication_id": "med_labetalol_tab_100mg",
      "action": "modify",
      "medication_request_id": "medreq_fatima_20251218_01"
    }
  ],
  "procedures": [],
  "timestamp": "2026-01-11T09:45:00Z"
}
```

**Example 4: Medication with Null Values**
```json
{
  "encounter_id": "enc_fatima_20260112_01",
  "patient_id": "pat_fatima_alkhalifa_001",
  "practitioner_id": "prac_laila_alhaddad_001",
  "analysis_id": "analysis_20260112_004",
  "doctor_decision": {
    "risk_tier": "High",
    "reasoning_notes": "Adding new medication not in catalog. Will need to create custom medication entry.",
    "ai_risk_tier": "High",
    "risk_tier_override": false,
    "override_rationale": null
  },
  "medications": [
    {
      "id": "med_rec_005",
      "medication": "Custom Medication Name",
      "dose": "10 mg",
      "frequency": "once daily",
      "duration": null,
      "rationale": "Trial medication for specific condition",
      "evidence": [
        "Clinical indication",
        "Patient-specific need"
      ],
      "status": "Planned",
      "medication_id": null,
      "action": "add",
      "medication_request_id": null
    }
  ],
  "procedures": [
    {
      "id": "proc_rec_005",
      "procedure": "Lab monitoring",
      "timing": "In 1 week",
      "rationale": "Monitor response to new medication",
      "evidence": [
        "New medication started"
      ],
      "status": "Planned",
      "procedure_category": "laboratory",
      "priority": "routine",
      "procedure_id": null
    }
  ],
  "timestamp": "2026-01-12T11:20:00Z"
}
```

**Request Fields:**

- `encounter_id` (string, required) - Encounter identifier
- `patient_id` (string, required) - Patient identifier
- `practitioner_id` (string, required) - Doctor/practitioner identifier
- `analysis_id` (string, required) - Reference to the AI analysis
- `doctor_decision` (object, required) - Doctor's final clinical decision
  - `risk_tier` (string, enum, required) - Final risk tier selected by doctor: `"Low"`, `"Medium"`, `"High"`
  - `reasoning_notes` (string, required) - Doctor's clinical reasoning notes (entered in textarea)
  - `ai_risk_tier` (string, enum, required) - Original AI assessment risk tier (from analysis response)
  - `risk_tier_override` (boolean, required) - Calculated by frontend: `true` if `risk_tier !== ai_risk_tier`, `false` otherwise
  - `override_rationale` (string, nullable) - If `risk_tier_override: true`, this should be the same as `reasoning_notes` or a subset of it. If `false`, can be `null`
- `medications` (array of objects) - Finalized medication recommendations
  - **Only include items with `"status": "Planned"`** (items marked as "Not planned" are excluded)
  - All fields from medication_recommendations can be edited by doctor:
    - `id` (string) - Recommendation ID from AI analysis
    - `medication` (string) - Can be edited
    - `dose` (string) - Can be edited
    - `frequency` (string) - Can be edited
    - `duration` (string, optional) - Can be edited
    - `rationale` (string) - Can be edited
    - `evidence` (array of strings) - Read-only, from AI analysis
    - `status` (string, enum) - `"Planned"` or `"Not planned"` (only "Planned" items are sent)
    - `medication_id` (string, optional) - Reference to medication catalog
    - `action` (string, enum) - `"add"`, `"modify"`, `"restart"`, `"discontinue"`
    - `medication_request_id` (string, nullable) - ID if updating existing request, `null` if new
- `procedures` (array of objects) - Finalized procedure recommendations
  - **Only include items with `"status": "Planned"`** (items marked as "Not planned" are excluded)
  - All fields from procedure_recommendations can be edited by doctor:
    - `id` (string) - Recommendation ID from AI analysis
    - `procedure` (string) - Can be edited
    - `timing` (string) - Can be edited
    - `rationale` (string) - Can be edited
    - `evidence` (array of strings) - Read-only, from AI analysis
    - `status` (string, enum) - `"Planned"` or `"Not planned"` (only "Planned" items are sent)
    - `procedure_category` (string) - Category: `"laboratory"`, `"imaging"`, `"other"`, etc.
    - `priority` (string, enum) - `"urgent"`, `"routine"`
    - `procedure_id` (string, nullable) - ID if updating existing procedure, `null` if new
- `timestamp` (string, ISO 8601, required) - When decision was finalized (frontend generates this)

**Note:** `visit_outcome` is **NOT** sent in the request. The backend should generate it based on the decisions made (e.g., if follow-up procedures are planned → "Follow-up scheduled").

### Response

**Status Code:** `200 OK`

**Response Body (Standard Example):**
```json
{
  "visit_id": "visit_20260109_001",
  "encounter_id": "enc_fatima_20260109_01",
  "status": "completed",
  "finalized_at": "2026-01-09T15:45:00Z",
  "visit_outcome": {
    "status": "Follow-up scheduled",
    "details": "Medication adjustments approved, urgent labs ordered, follow-up scheduled within 7 days"
  },
  "medication_requests_created": [
    "medreq_fatima_20260109_03",
    "medreq_fatima_20260109_04"
  ],
  "procedures_created": [
    "proc_fatima_20260109_04",
    "proc_fatima_20260109_05",
    "proc_fatima_20260109_06"
  ],
  "care_plan_updated": "cp_fatima_20260109_01"
}
```

**Alternative Response Examples:**

**Example 1: No Action Outcome (No medications/procedures planned)**
```json
{
  "visit_id": "visit_20260110_002",
  "encounter_id": "enc_fatima_20260110_01",
  "status": "completed",
  "finalized_at": "2026-01-10T10:30:00Z",
  "visit_outcome": {
    "status": "No action",
    "details": null
  },
  "medication_requests_created": [],
  "procedures_created": [],
  "care_plan_updated": null
}
```

**Example 2: Monitoring Continued (Only monitoring procedures)**
```json
{
  "visit_id": "visit_20260111_003",
  "encounter_id": "enc_fatima_20260111_01",
  "status": "completed",
  "finalized_at": "2026-01-11T09:45:00Z",
  "visit_outcome": {
    "status": "Monitoring continued",
    "details": "Medication adjusted, continue current monitoring plan"
  },
  "medication_requests_created": [
    "medreq_fatima_20260111_05"
  ],
  "procedures_created": [],
  "care_plan_updated": "cp_fatima_20260111_02"
}
```

**Example 3: Partial Creation (Some items failed)**
```json
{
  "visit_id": "visit_20260112_004",
  "encounter_id": "enc_fatima_20260112_01",
  "status": "completed",
  "finalized_at": "2026-01-12T11:20:00Z",
  "visit_outcome": {
    "status": "Follow-up scheduled",
    "details": "Medication added, lab monitoring scheduled"
  },
  "medication_requests_created": [
    "medreq_fatima_20260112_06"
  ],
  "procedures_created": [
    "proc_fatima_20260112_07"
  ],
  "care_plan_updated": null
}
```

**Response Fields:**

- `visit_id` (string) - Unique identifier for the finalized visit
- `encounter_id` (string) - Encounter identifier
- `status` (string) - Visit status: `"completed"`
- `finalized_at` (string, ISO 8601) - Timestamp of finalization
- `visit_outcome` (object) - **Generated by backend** based on the decisions made
  - `status` (string, enum) - One of: `"No action"`, `"Follow-up scheduled"`, `"Monitoring continued"`
  - `details` (string, nullable) - Additional details about the outcome. Can be `null` if no details needed
- `medication_requests_created` (array of strings) - IDs of created medication requests. Can be empty array `[]` if no medications were planned
- `procedures_created` (array of strings) - IDs of created procedures. Can be empty array `[]` if no procedures were planned
- `care_plan_updated` (string, nullable) - ID of updated care plan if applicable. Can be `null` if no care plan was updated

**Error Responses:**

- `400 Bad Request` - Invalid request body, missing required fields, or validation errors
  - If `risk_tier_override: true` but `override_rationale` is missing
  - If no medications or procedures with `status: "Planned"`
- `404 Not Found` - Encounter, patient, practitioner, or analysis not found
- `409 Conflict` - Visit already finalized
- `500 Internal Server Error` - Finalization failed

---

## Data Types and Enums

### Risk Tier
- `"Low"`
- `"Medium"`
- `"High"`

### Visit Trigger Type
- `"Background Monitoring Alert"`
- `"Scheduled Follow-up"`
- `"Manual Review"`
- `"Alarm-Triggered Review"`

### Visit Trigger Source
- `"AI"`
- `"System"`
- `"Doctor"`

### Evidence Reference Type
- `"observation"`
- `"condition"`
- `"medication_request"`
- `"procedure"`
- `"encounter"`

### Medication Action
- `"add"` - Add new medication
- `"modify"` - Modify existing medication
- `"restart"` - Restart discontinued medication
- `"discontinue"` - Stop medication

### Recommendation Status
- `"Planned"` - Approved and will be executed
- `"Not planned"` - Rejected or deferred

### Procedure Category
- `"laboratory"`
- `"imaging"`
- `"other"`
- `"education"`
- `"consultation"`
- `"immunization"`

### Procedure Priority
- `"urgent"` - Immediate action required
- `"routine"` - Standard priority

### Visit Outcome Status
- `"No action"` - No changes needed
- `"Follow-up scheduled"` - Follow-up visit scheduled
- `"Monitoring continued"` - Continue current monitoring

---

## Complete Request/Response Examples

### Example 1: Full Workflow with All Fields

**Request to Analyze:**
```json
{
  "patient_id": "pat_fatima_alkhalifa_001",
  "encounter_id": "enc_fatima_20260109_01",
  "visit_trigger": {
    "type": "Background Monitoring Alert",
    "timestamp": "2026-01-09T09:15:00Z",
    "source": "AI"
  }
}
```

**Response from Analyze:**
```json
{
  "analysis_id": "analysis_20260109_001",
  "encounter_id": "enc_fatima_20260109_01",
  "patient_id": "pat_fatima_alkhalifa_001",
  "risk_tier": "High",
  "reasoning": [
    "Multiple high-risk comorbidities detected",
    "Elevated blood pressure above target range"
  ],
  "evidence_references": [
    {
      "type": "observation",
      "label": "BP 156/98 (Jan 9, 14:40)",
      "observation_id": "obs_fatima_20260109_01",
      "source": "vitals",
      "timestamp": "2026-01-09T14:40:00Z",
      "status": null
    }
  ],
  "medication_recommendations": [
    {
      "id": "med_rec_001",
      "medication": "Labetalol",
      "dose": "200 mg",
      "frequency": "twice daily",
      "duration": "Ongoing",
      "rationale": "Restore antihypertensive coverage",
      "evidence": ["BP 156/98 (Jan 9, 14:40)"],
      "status": "Planned",
      "medication_id": "med_labetalol_tab_100mg",
      "action": "restart"
    }
  ],
  "procedure_recommendations": [
    {
      "id": "proc_rec_001",
      "procedure": "Preeclampsia evaluation panel",
      "timing": "Immediate (within 24 hours)",
      "rationale": "Complete overdue surveillance labs",
      "evidence": ["Symptom-triggered evaluation"],
      "status": "Planned",
      "procedure_category": "laboratory",
      "priority": "urgent"
    }
  ],
  "model_version": "ClinicalAI v3.2.1",
  "analysis_timestamp": "2026-01-09T15:20:00Z",
  "confidence_score": 0.87,
  "data_freshness": {
    "last_updated": "2026-01-09T14:40:00Z",
    "age_days": 0
  }
}
```

**Request to Finalize:**
```json
{
  "encounter_id": "enc_fatima_20260109_01",
  "patient_id": "pat_fatima_alkhalifa_001",
  "practitioner_id": "prac_laila_alhaddad_001",
  "analysis_id": "analysis_20260109_001",
  "doctor_decision": {
    "risk_tier": "High",
    "reasoning_notes": "Agree with AI assessment. Proceeding with recommended plan.",
    "ai_risk_tier": "High",
    "risk_tier_override": false,
    "override_rationale": null
  },
  "medications": [
    {
      "id": "med_rec_001",
      "medication": "Labetalol",
      "dose": "200 mg",
      "frequency": "twice daily",
      "duration": "Ongoing",
      "rationale": "Restore antihypertensive coverage",
      "evidence": ["BP 156/98 (Jan 9, 14:40)"],
      "status": "Planned",
      "medication_id": "med_labetalol_tab_100mg",
      "action": "restart",
      "medication_request_id": null
    }
  ],
  "procedures": [
    {
      "id": "proc_rec_001",
      "procedure": "Preeclampsia evaluation panel",
      "timing": "Immediate (within 24 hours)",
      "rationale": "Complete overdue surveillance labs",
      "evidence": ["Symptom-triggered evaluation"],
      "status": "Planned",
      "procedure_category": "laboratory",
      "priority": "urgent",
      "procedure_id": null
    }
  ],
  "timestamp": "2026-01-09T15:45:00Z"
}
```

**Response from Finalize:**
```json
{
  "visit_id": "visit_20260109_001",
  "encounter_id": "enc_fatima_20260109_01",
  "status": "completed",
  "finalized_at": "2026-01-09T15:45:00Z",
  "visit_outcome": {
    "status": "Follow-up scheduled",
    "details": "Medication adjustments approved, urgent labs ordered, follow-up scheduled within 7 days"
  },
  "medication_requests_created": [
    "medreq_fatima_20260109_03"
  ],
  "procedures_created": [
    "proc_fatima_20260109_04"
  ],
  "care_plan_updated": "cp_fatima_20260109_01"
}
```

### Example 2: Minimal Request (No Visit Trigger, No Recommendations)

**Request to Analyze (without visit_trigger):**
```json
{
  "patient_id": "pat_fatima_alkhalifa_001",
  "encounter_id": "enc_fatima_20260110_01"
}
```

**Response from Analyze (Low Risk, No Recommendations):**
```json
{
  "analysis_id": "analysis_20260110_002",
  "encounter_id": "enc_fatima_20260110_01",
  "patient_id": "pat_fatima_alkhalifa_001",
  "risk_tier": "Low",
  "reasoning": [
    "BP within target range",
    "All medications current"
  ],
  "evidence_references": [
    {
      "type": "observation",
      "label": "BP 128/82 (Jan 10, 10:00)",
      "observation_id": "obs_fatima_20260110_01",
      "source": "vitals",
      "timestamp": "2026-01-10T10:00:00Z",
      "status": null
    }
  ],
  "medication_recommendations": [],
  "procedure_recommendations": [],
  "model_version": "ClinicalAI v3.2.1",
  "analysis_timestamp": "2026-01-10T10:15:00Z",
  "confidence_score": 0.95,
  "data_freshness": {
    "last_updated": "2026-01-10T10:00:00Z",
    "age_days": 0
  }
}
```

**Request to Finalize (No Medications/Procedures):**
```json
{
  "encounter_id": "enc_fatima_20260110_01",
  "patient_id": "pat_fatima_alkhalifa_001",
  "practitioner_id": "prac_laila_alhaddad_001",
  "analysis_id": "analysis_20260110_002",
  "doctor_decision": {
    "risk_tier": "Low",
    "reasoning_notes": "Patient stable. Continue current plan.",
    "ai_risk_tier": "Low",
    "risk_tier_override": false,
    "override_rationale": null
  },
  "medications": [],
  "procedures": [],
  "timestamp": "2026-01-10T10:30:00Z"
}
```

**Response from Finalize:**
```json
{
  "visit_id": "visit_20260110_002",
  "encounter_id": "enc_fatima_20260110_01",
  "status": "completed",
  "finalized_at": "2026-01-10T10:30:00Z",
  "visit_outcome": {
    "status": "No action",
    "details": null
  },
  "medication_requests_created": [],
  "procedures_created": [],
  "care_plan_updated": null
}
```

### Example 3: Risk Tier Override Scenario

**Request to Finalize (Doctor Overrides AI Assessment):**
```json
{
  "encounter_id": "enc_fatima_20260111_01",
  "patient_id": "pat_fatima_alkhalifa_001",
  "practitioner_id": "prac_laila_alhaddad_001",
  "analysis_id": "analysis_20260111_003",
  "doctor_decision": {
    "risk_tier": "Medium",
    "reasoning_notes": "While AI assessed as High risk, patient's condition has improved. BP readings are now borderline. Adjusting to Medium risk with close monitoring. Patient reports better adherence to medications.",
    "ai_risk_tier": "High",
    "risk_tier_override": true,
    "override_rationale": "BP improved from 156/98 to 142/88. Patient reports better medication adherence. Close monitoring sufficient without escalation to High risk tier."
  },
  "medications": [
    {
      "id": "med_rec_006",
      "medication": "Labetalol",
      "dose": "200 mg",
      "frequency": "twice daily",
      "duration": null,
      "rationale": "Continue current dose, monitor response",
      "evidence": [
        "BP 142/88 (Jan 11, 09:00)",
        "Improved from previous readings"
      ],
      "status": "Planned",
      "medication_id": "med_labetalol_tab_100mg",
      "action": "modify",
      "medication_request_id": "medreq_fatima_20251218_01"
    }
  ],
  "procedures": [
    {
      "id": "proc_rec_006",
      "procedure": "Follow-up BP check",
      "timing": "In 2 weeks",
      "rationale": "Monitor response to current regimen",
      "evidence": [
        "BP 142/88 mmHg",
        "Recent improvement"
      ],
      "status": "Planned",
      "procedure_category": "other",
      "priority": "routine",
      "procedure_id": null
    }
  ],
  "timestamp": "2026-01-11T09:45:00Z"
}
```

**Response from Finalize:**
```json
{
  "visit_id": "visit_20260111_003",
  "encounter_id": "enc_fatima_20260111_01",
  "status": "completed",
  "finalized_at": "2026-01-11T09:45:00Z",
  "visit_outcome": {
    "status": "Monitoring continued",
    "details": "Risk tier adjusted to Medium based on clinical judgment. Medication continued, follow-up scheduled."
  },
  "medication_requests_created": [
    "medreq_fatima_20260111_07"
  ],
  "procedures_created": [
    "proc_fatima_20260111_08"
  ],
  "care_plan_updated": "cp_fatima_20260111_03"
}
```

### Example 4: Medication with Null Values

**Request to Finalize (Custom Medication, No Medication ID):**
```json
{
  "encounter_id": "enc_fatima_20260112_01",
  "patient_id": "pat_fatima_alkhalifa_001",
  "practitioner_id": "prac_laila_alhaddad_001",
  "analysis_id": "analysis_20260112_004",
  "doctor_decision": {
    "risk_tier": "Medium",
    "reasoning_notes": "Adding custom medication not in standard catalog. Will need manual entry in system.",
    "ai_risk_tier": "Medium",
    "risk_tier_override": false,
    "override_rationale": null
  },
  "medications": [
    {
      "id": "med_rec_007",
      "medication": "Custom Medication Name",
      "dose": "10 mg",
      "frequency": "once daily",
      "duration": null,
      "rationale": "Trial medication for specific condition",
      "evidence": [
        "Clinical indication",
        "Patient-specific need"
      ],
      "status": "Planned",
      "medication_id": null,
      "action": "add",
      "medication_request_id": null
    }
  ],
  "procedures": [],
  "timestamp": "2026-01-12T11:20:00Z"
}
```

**Response from Finalize:**
```json
{
  "visit_id": "visit_20260112_004",
  "encounter_id": "enc_fatima_20260112_01",
  "status": "completed",
  "finalized_at": "2026-01-12T11:20:00Z",
  "visit_outcome": {
    "status": "Monitoring continued",
    "details": "Custom medication added, monitoring plan continued"
  },
  "medication_requests_created": [
    "medreq_fatima_20260112_09"
  ],
  "procedures_created": [],
  "care_plan_updated": null
}
```

---

## Workflow Example

### Step 1: Patient State
Frontend displays current patient data. No API call needed (data already loaded).

### Step 2: Generate AI Analysis
```http
POST /api/visits/enc_fatima_20260109_01/analyze
Content-Type: application/json

{
  "patient_id": "pat_fatima_alkhalifa_001",
  "encounter_id": "enc_fatima_20260109_01",
  "visit_trigger": {
    "type": "Background Monitoring Alert",
    "timestamp": "2026-01-09T09:15:00Z",
    "source": "AI"
  }
}
```

Response: AI Analysis JSON (see Endpoint 1 Response)

### Step 3: Clinical Decision
Doctor reviews AI recommendations, may edit/add/remove medications and procedures, selects final risk tier, and enters reasoning notes.

### Step 4: Finalize Decision
```http
POST /api/visits/enc_fatima_20260109_01/finalize
Content-Type: application/json

{
  "encounter_id": "enc_fatima_20260109_01",
  "patient_id": "pat_fatima_alkhalifa_001",
  "practitioner_id": "prac_laila_alhaddad_001",
  "analysis_id": "analysis_20260109_001",
  "doctor_decision": {
    "risk_tier": "High",
    "reasoning_notes": "...",
    "ai_risk_tier": "High",
    "risk_tier_override": false,
    "override_rationale": null
  },
  "medications": [...],
  "procedures": [...],
  "timestamp": "2026-01-09T15:45:00Z"
}
```

Response: Finalization confirmation (see Endpoint 2 Response)

---

## Null Value Reference Guide

This section documents all fields that can be `null` and when they should be used.

### Request Fields (Finalize Decision)

**Fields that can be `null`:**
- `doctor_decision.override_rationale` - `null` when `risk_tier_override: false`
- `medications[].duration` - `null` if duration is not specified or ongoing indefinitely
- `medications[].medication_id` - `null` if medication is not in catalog (custom medication)
- `medications[].medication_request_id` - `null` if creating new medication request (not updating existing)
- `procedures[].procedure_id` - `null` if creating new procedure (not updating existing)

**Fields that should be empty arrays `[]`:**
- `medications` - Empty array if no medications are planned
- `procedures` - Empty array if no procedures are planned

**Fields that can be omitted (optional):**
- `visit_trigger` - Can be omitted entirely from analyze request

### Response Fields

**Fields that can be `null`:**
- `visit_outcome.details` - `null` if no additional details needed
- `care_plan_updated` - `null` if no care plan was updated
- `evidence_references[].timestamp` - `null` if timestamp not available
- `evidence_references[].status` - `null` if status not applicable

**Fields that should be empty arrays `[]`:**
- `medication_recommendations` - Empty array if AI recommends no medication changes
- `procedure_recommendations` - Empty array if AI recommends no procedures
- `medication_requests_created` - Empty array if no medications were planned
- `procedures_created` - Empty array if no procedures were planned

### Common Null Value Scenarios

**Scenario 1: No Visit Trigger**
```json
{
  "patient_id": "pat_fatima_alkhalifa_001",
  "encounter_id": "enc_fatima_20260109_01"
}
```
Note: `visit_trigger` field is completely omitted, not set to `null`.

**Scenario 2: Medication Without Catalog Entry**
```json
{
  "id": "med_rec_001",
  "medication": "Custom Medication",
  "dose": "10 mg",
  "frequency": "once daily",
  "duration": null,
  "rationale": "Custom medication",
  "evidence": [],
  "status": "Planned",
  "medication_id": null,
  "action": "add",
  "medication_request_id": null
}
```

**Scenario 3: Updating Existing Medication**
```json
{
  "id": "med_rec_001",
  "medication": "Labetalol",
  "dose": "300 mg",
  "frequency": "twice daily",
  "duration": null,
  "rationale": "Increase dose",
  "evidence": ["BP elevated"],
  "status": "Planned",
  "medication_id": "med_labetalol_tab_100mg",
  "action": "modify",
  "medication_request_id": "medreq_fatima_20251218_01"
}
```
Note: `medication_request_id` is NOT null when updating existing request.

**Scenario 4: No Recommendations**
```json
{
  "medications": [],
  "procedures": []
}
```

**Scenario 5: No Override Rationale**
```json
{
  "risk_tier": "High",
  "reasoning_notes": "Agree with AI",
  "ai_risk_tier": "High",
  "risk_tier_override": false,
  "override_rationale": null
}
```

**Scenario 6: Response with Null Values**
```json
{
  "visit_id": "visit_20260110_001",
  "encounter_id": "enc_fatima_20260110_01",
  "status": "completed",
  "finalized_at": "2026-01-10T10:30:00Z",
  "visit_outcome": {
    "status": "No action",
    "details": null
  },
  "medication_requests_created": [],
  "procedures_created": [],
  "care_plan_updated": null
}
```

---

## Notes

1. **Evidence References**: All evidence references should link to actual entities in your database (observations, conditions, medication_requests, procedures, encounters).

2. **Medication Actions**: 
   - Use `"add"` for new medications
   - Use `"restart"` for medications that were stopped and need to be resumed
   - Use `"modify"` for dose/frequency changes
   - Use `"discontinue"` for stopping medications

3. **Status Filtering**: Only send items with `"status": "Planned"` in the finalize request. Items marked as `"Not planned"` should be excluded.

4. **Risk Tier Override Calculation**: 
   - Frontend should calculate `risk_tier_override` by comparing `doctor_decision.risk_tier` with `ai_analysis.risk_tier`
   - If different: `risk_tier_override: true` and `override_rationale` should contain the reasoning (can be same as `reasoning_notes`)
   - If same: `risk_tier_override: false` and `override_rationale: null`

5. **Visit Outcome**: The `visit_outcome` is **NOT** sent from frontend. Backend should generate it based on:
   - If follow-up procedures are planned → `"Follow-up scheduled"`
   - If no procedures/medications planned → `"No action"`
   - If only monitoring continues → `"Monitoring continued"`

6. **Timestamps**: All timestamps should be in ISO 8601 format (UTC), e.g., `"2026-01-09T15:45:00Z"`.

7. **Idempotency**: The finalize endpoint should be idempotent. If called multiple times with the same data, it should return the same result without creating duplicates.

8. **Validation**: The backend should validate that:
   - All referenced medication_ids and procedure_ids exist
   - The practitioner_id is valid and has permission
   - The encounter is in a valid state for finalization
   - Required fields are present and properly formatted
   - If `risk_tier_override: true`, `override_rationale` must not be null/empty

---

## Integration Checklist

- [ ] Implement `/api/visits/{encounter_id}/analyze` endpoint
- [ ] Implement `/api/visits/{encounter_id}/finalize` endpoint
- [ ] Create database tables/collections for:
  - [ ] AI analyses
  - [ ] Doctor decisions
  - [ ] Visit outcomes
- [ ] Set up validation for all request fields
- [ ] Implement medication request creation/updates
- [ ] Implement procedure creation/updates
- [ ] Handle care plan updates if applicable
- [ ] Add error handling and appropriate HTTP status codes
- [ ] Add logging for audit trail
- [ ] Test with sample data matching the provided JSON structures

---

## Support

For questions or issues, please contact the development team.
