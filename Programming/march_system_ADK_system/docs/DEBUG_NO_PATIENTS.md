# Debug: No patients in the database

When the Select Patient modal shows "No patients in the database. Ensure the backend is running and seeded.", follow this checklist.

## Flow

1. **UI** (PatientPickerModal) calls `fetchPatients('default')`
2. **API base** = `VITE_MARCH_API_URL` (e.g. `http://march-staging-alb-2122679412.us-east-1.elb.amazonaws.com` for dev)
3. **Endpoints tried** (in order):
   - `/v1/patients?tenantId=default`
   - `/api/v1/patients?tenantId=default`
   - `/patients?tenantId=default`
   - `/api/patients?tenantId=default`
   - `/fhir/Patient?_count=200`
4. **Backend** (March API) queries Postgres via `_resolve_postgres_dsn` and `MARCH_PATIENT_SCHEMA`/`MARCH_PATIENT_TABLE` (default: `fluxfhir_dev.patient`)
5. **Fallback** if API returns `[]`: `VITE_MARCH_DEFAULT_PATIENTS` (format: `mrn:Name;mrn:Name`)

## API env vars (required for patients)

| Env var | Purpose |
|---------|---------|
| `MARCH_DATABASE__POSTGRES_URL` | Full Postgres DSN (alternative to Secrets Manager) |
| `MARCH_RDS_SECRET_ID` | Secrets Manager secret ID with `{username, password, host, dbname, port}` (default: `fluxfhir/dev/rds/postgres`) |
| `MARCH_AWS__REGION` | AWS region for Secrets Manager (default: `us-east-1`) |
| `MARCH_PATIENT_SCHEMA` | Schema name (default: `fluxfhir_dev`) |
| `MARCH_PATIENT_TABLE` | Table name (default: `patient`) |

## Causes

| Symptom | Cause | Fix |
|--------|-------|-----|
| API returns 200 with `[]` | Postgres DSN not set | Set `MARCH_DATABASE__POSTGRES_URL` or `MARCH_RDS_SECRET_ID` (task def must include it) |
| API returns 200 with `[]` | Wrong secret name | Set `MARCH_RDS_SECRET_ID` to your actual secret (e.g. `march/rds/postgres`) |
| API returns 200 with `[]` | Schema/table mismatch | Set `MARCH_PATIENT_SCHEMA` and `MARCH_PATIENT_TABLE` to match your DB |
| CORS / network error | Cross-origin request blocked | Ensure `MARCH_CORS_ALLOW_ORIGINS` includes your S3 UI URL |
| 404 / 5xx | Endpoint missing or error | Check March API CloudWatch logs for `patients:` and `postgres DSN:` messages |

## Quick fix: demo patients

Add to `MarchAgent/web/.env.dev` (or the env used for your build):

```
VITE_MARCH_DEFAULT_PATIENTS=p-dev-001:Demo Patient 001;p1:Demo Patient P1
```

Then rebuild and redeploy. When the API returns an empty list, the UI will show these demo patients instead.

## Verify API

```bash
curl -s "http://march-staging-alb-2122679412.us-east-1.elb.amazonaws.com/v1/patients?tenantId=default" | jq .
```

- `[]` = empty DB or no DSN
- `[{ "mrn": "...", "name": "..." }]` = working
- 404/500 = route or server error
