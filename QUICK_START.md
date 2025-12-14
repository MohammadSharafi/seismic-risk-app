# Quick Start Guide

## Prerequisites Check

```bash
# Check Flutter
flutter --version  # Should be 3.8.1+

# Check Java
java -version  # Should be 17+

# Check Maven
mvn -version  # Should be 3.9+

# Check Python
python --version  # Should be 3.11+

# Check Docker
docker --version
docker-compose --version
```

## Step 1: Generate Flutter Code

```bash
cd seismic-risk-app
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

## Step 2: Start Services

### Option A: Docker (Recommended)

```bash
docker-compose up -d
```

This starts:
- PostgreSQL with PostGIS on port 5432
- Spring Boot backend on port 8080
- Python ML service on port 8000

### Option B: Manual

#### Database
```bash
createdb seismic_risk_db
psql -d seismic_risk_db -c "CREATE EXTENSION postgis;"
psql -d seismic_risk_db -f backend/src/main/resources/schema.sql
```

#### Backend
```bash
cd backend
mvn spring-boot:run
```

#### ML Service
```bash
cd ml-service
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
python -m uvicorn api.main:app --reload
```

## Step 3: Configure Google Maps

1. Get API key from [Google Cloud Console](https://console.cloud.google.com/)
2. Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY"/>
```

3. For iOS, add to `ios/Runner/AppDelegate.swift`

## Step 4: Run Flutter App

```bash
cd seismic-risk-app
flutter run
```

## Step 5: Train Initial Model (Optional)

```bash
cd ml-service/training
python train_model.py
```

## Testing the App

1. Launch app → Accept consent
2. Allow location permissions
3. Select building location on map
4. Confirm address
5. Fill building information:
   - Year built
   - Number of floors
   - Structure type
   - Photos (optional)
6. Run assessment
7. View results with risk score and recommendations

## Troubleshooting

### Flutter Code Generation Fails
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Backend Won't Start
- Check PostgreSQL is running
- Verify database credentials in `application.yml`
- Check port 8080 is not in use

### ML Service Errors
- Verify Python 3.11+
- Check all dependencies installed: `pip install -r requirements.txt`
- Ensure port 8000 is available

### Database Connection Issues
```bash
# Check if PostgreSQL is running
docker ps  # If using Docker
# or
pg_isready

# Test connection
psql -d seismic_risk_db -U postgres
```

## Next Steps

- Add authentication (JWT)
- Complete all building form screens
- Implement PDF export
- Add offline sync
- Train model with real data
- Add more ML features

