# Setup Guide

## Prerequisites

- Flutter SDK 3.8.1+
- Java 17+
- Maven 3.9+
- Python 3.11+
- Docker & Docker Compose
- PostgreSQL with PostGIS (or use Docker)

## Quick Start

### 1. Generate Flutter Code

```bash
cd seismic-risk-app
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### 2. Start Services with Docker

```bash
docker-compose up -d
```

This will start:
- PostgreSQL with PostGIS on port 5432
- Spring Boot backend on port 8080
- Python ML service on port 8000

### 3. Run Flutter App

```bash
cd seismic-risk-app
flutter run
```

## Manual Setup

### Database Setup

```bash
# Create database
createdb seismic_risk_db

# Enable PostGIS
psql -d seismic_risk_db -c "CREATE EXTENSION postgis;"

# Run schema
psql -d seismic_risk_db -f backend/src/main/resources/schema.sql
```

### Backend Setup

```bash
cd backend
mvn clean install
mvn spring-boot:run
```

### ML Service Setup

```bash
cd ml-service
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
python -m uvicorn api.main:app --reload
```

### Train ML Model (Optional)

```bash
cd ml-service/training
python train_model.py
```

## Configuration

### Flutter App

Update `lib/core/constants/app_constants.dart`:
- `baseUrl`: Backend API URL (default: http://localhost:8080/api/v1)
- `mlServiceUrl`: ML service URL (default: http://localhost:8000)

### Backend

Update `backend/src/main/resources/application.yml`:
- Database credentials
- ML service URL
- JWT secret (for production)

### Google Maps API Key

For the Flutter app to use Google Maps:

1. Get API key from Google Cloud Console
2. Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY"/>
```

3. Add to `ios/Runner/AppDelegate.swift`:
```swift
GMSServices.provideAPIKey("YOUR_API_KEY")
```

## Troubleshooting

### Flutter Code Generation Issues

If freezed files are missing:
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Backend Compilation Issues

```bash
cd backend
mvn clean
mvn compile
```

### Database Connection Issues

Check if PostgreSQL is running:
```bash
docker ps  # If using Docker
# or
pg_isready
```

### ML Service Not Starting

Check Python version:
```bash
python --version  # Should be 3.11+
```

Install dependencies:
```bash
pip install -r ml-service/requirements.txt
```

