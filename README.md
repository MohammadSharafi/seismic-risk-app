# Seismic Risk Assessment Application

A comprehensive mobile-first application for assessing earthquake vulnerability of buildings in Turkey. The app collects building and location data, uses machine learning to predict seismic risk, and provides actionable recommendations.

## Architecture

- **Frontend**: Flutter (Dart) - Mobile app
- **Backend**: Spring Boot (Java) - REST API
- **ML Service**: Python FastAPI - Machine learning inference
- **Database**: PostgreSQL with PostGIS extension

## Project Structure

```
seismic-risk-app/
├── lib/                    # Flutter app source
│   ├── core/              # Constants, theme, utils
│   ├── data/              # Data layer (repositories, datasources)
│   ├── domain/            # Domain entities
│   └── presentation/      # UI (screens, widgets, providers)
├── backend/                # Spring Boot backend
│   ├── src/main/java/     # Java source code
│   └── src/main/resources/ # Configuration files
├── ml-service/            # Python ML service
│   ├── api/               # FastAPI application
│   └── training/          # Model training scripts
└── docker-compose.yml      # Docker setup
```

## Features

### Mobile App (Flutter)
- ✅ Consent and permission screens
- ✅ Interactive map for location selection
- ✅ Address confirmation with reverse geocoding
- ✅ Building information forms (one question per screen)
- ✅ Photo capture for building documentation
- ✅ Risk assessment results display
- ✅ Recommendations with priority levels
- ✅ PDF export functionality

### Backend (Spring Boot)
- ✅ RESTful API endpoints
- ✅ Building CRUD operations
- ✅ Photo upload handling
- ✅ Prediction triggering and retrieval
- ✅ Neighborhood defaults lookup
- ✅ PostGIS spatial queries
- ✅ JWT authentication (to be implemented)

### ML Service (Python)
- ✅ FastAPI inference service
- ✅ XGBoost model for risk prediction
- ✅ Feature engineering pipeline
- ✅ SHAP explainability
- ✅ Model training scripts

## Setup Instructions

### Prerequisites
- Flutter SDK (3.8.1+)
- Java 17+
- Maven 3.9+
- Python 3.11+
- Docker and Docker Compose
- PostgreSQL with PostGIS (or use Docker)

### Quick Start with Docker

1. **Start all services:**
```bash
docker-compose up -d
```

2. **Run Flutter app:**
```bash
cd seismic-risk-app
flutter pub get
flutter run
```

### Manual Setup

#### Database
```bash
# Create database
createdb seismic_risk_db

# Enable PostGIS
psql -d seismic_risk_db -c "CREATE EXTENSION postgis;"

# Run schema
psql -d seismic_risk_db -f backend/src/main/resources/schema.sql
```

#### Backend
```bash
cd backend
mvn clean install
mvn spring-boot:run
```

#### ML Service
```bash
cd ml-service
pip install -r requirements.txt
python -m uvicorn api.main:app --reload
```

#### Flutter App
```bash
cd seismic-risk-app
flutter pub get
flutter run
```

## API Endpoints

### Buildings
- `POST /api/v1/buildings` - Create building
- `GET /api/v1/buildings/{id}` - Get building
- `PUT /api/v1/buildings/{id}` - Update building
- `POST /api/v1/buildings/{id}/photos` - Upload photo

### Predictions
- `POST /api/v1/predict/{buildingId}` - Trigger prediction
- `GET /api/v1/predictions/{id}` - Get prediction result

### Neighborhood
- `GET /api/v1/neighborhoods/lookup?lat={lat}&lng={lng}` - Get defaults

## ML Model

The model predicts:
- **Collapse probability** (0-1)
- **Damage category** (None/Light/Moderate/Severe/Collapse)
- **Top contributing features** (explainability)
- **Confidence score**

### Training
```bash
cd ml-service/training
python train_model.py
```

## Configuration

### Backend
Edit `backend/src/main/resources/application.yml`:
- Database connection
- ML service URL
- JWT secret

### Flutter App
Edit `lib/core/constants/app_constants.dart`:
- API base URL
- ML service URL

## Development Status

- ✅ Project structure
- ✅ Core Flutter screens
- ✅ Backend API structure
- ✅ ML service skeleton
- ✅ Database schema
- ⏳ Authentication implementation
- ⏳ Complete building forms
- ⏳ Photo processing
- ⏳ PDF generation
- ⏳ Model training with real data

## License

[Your License Here]

## Contributing

[Contributing Guidelines]
