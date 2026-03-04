# System Readiness Report — Patient List & Deployment

**Date:** 2025-02-25  
**Scope:** Patient picker flow, March API Postgres integration, ECS task definitions

---

## 1. Summary

Patient loading is wired end-to-end. Gaps in ECS task definitions and DSN resolution were fixed. Remaining requirements are configuration (secret name and schema) and redeploy.

---

## 2. Changes Made

### 2.1 March API (`MarchAgent/src/march/api/app.py`)

| Change | Description |
|--------|-------------|
| **Configurable schema/table** | Env vars `MARCH_PATIENT_SCHEMA` and `MARCH_PATIENT_TABLE` (default: `fluxfhir_dev.patient`) so production can use different schemas. |
| **Logging** | `patients:` and `postgres DSN:` logs for failures (CloudWatch). |
| **Null safety** | `COALESCE(name_0_given, ARRAY[]::text[])` to handle null name arrays. |

### 2.2 ECS Task Definitions

| File | Added env vars |
|------|----------------|
| `deploy/taskdef-staging.json` | `MARCH_AWS__REGION`, `MARCH_RDS_SECRET_ID`, CORS |
| `deploy/taskdef-prod.json` | `MARCH_AWS__REGION`, `MARCH_RDS_SECRET_ID`, `MARCH_CORS_ALLOW_ORIGINS`, `MARCH_CSRF__ALLOWED_ORIGINS` |

Previously, task defs did not set `MARCH_RDS_SECRET_ID` or `MARCH_AWS__REGION`, so the API could not obtain the Postgres DSN from Secrets Manager.

---

## 3. Deployment Checklist

### 3.1 AWS Secrets Manager

Ensure a secret exists with your Postgres credentials in this format:

```json
{
  "username": "...",
  "password": "...",
  "host": "...",
  "dbname": "...",
  "port": "5432"
}
```

- Terraform (March stack): `march/rds/postgres` (or `${secrets_prefix}/rds/postgres`)
- Custom deployment: Set `MARCH_RDS_SECRET_ID` in the task def to your secret name/ARN

### 3.2 ECS Task Definition

If you use a different secret or Postgres schema:

- **Different secret:** Override `MARCH_RDS_SECRET_ID` in the task def (or via Parameter Store).
- **Different schema/table:** Add `MARCH_PATIENT_SCHEMA` and `MARCH_PATIENT_TABLE`.

### 3.3 IAM

The ECS task execution role needs:

- `secretsmanager:GetSecretValue` for the RDS secret.
- Network access to RDS (same VPC / security groups).

### 3.4 Redeploy

1. **API:** Rebuild and deploy the March API image (CI/CD or `scripts/deploy-api-only.sh`).
2. **UI:** Redeploy the UI only if `.env` was changed (otherwise it’s optional).

---

## 4. Verify End-to-End

### 4.1 API

```bash
curl -s "http://YOUR-ALB-DNS/v1/patients?tenantId=default" | jq .
```

- `[]` → DSN/secret or schema issue; check CloudWatch logs.
- `[{ "mrn": "...", "name": "..." }]` → API is working.

### 4.2 UI

1. Open the deployed UI.
2. Open the patient picker (Select Patient).
3. Confirm patients load from the API.

---

## 5. Troubleshooting

See `docs/DEBUG_NO_PATIENTS.md` for:

- Env var reference.
- Common causes and fixes.
- Log message patterns for CloudWatch.

---

## 6. Files Modified

| Path | Changes |
|------|---------|
| `MarchAgent/src/march/api/app.py` | Patient schema/table config, logging, DSN logging, null handling |
| `MarchAgent/deploy/taskdef-staging.json` | `MARCH_RDS_SECRET_ID`, `MARCH_AWS__REGION` |
| `MarchAgent/deploy/taskdef-prod.json` | `MARCH_RDS_SECRET_ID`, `MARCH_AWS__REGION`, CORS/CSRF |
| `MarchAgent/.env.example` | Patient-related env var notes |
| `docs/DEBUG_NO_PATIENTS.md` | Env var list, causes, fixes |
