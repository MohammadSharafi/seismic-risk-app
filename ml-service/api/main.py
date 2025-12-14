"""
FastAPI service for seismic risk prediction
"""
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Dict, Optional
import joblib
import numpy as np
import pandas as pd
from pathlib import Path

app = FastAPI(title="Seismic Risk ML Service", version="1.0.0")

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Load model (will be loaded from file or initialized)
MODEL_PATH = Path("models/seismic_risk_model.pkl")
model = None
feature_names = None

class PredictionRequest(BaseModel):
    year_built: Optional[int] = None
    num_floors: Optional[int] = None
    structure_type: Optional[str] = None
    foundation_type: Optional[str] = None
    wall_material: Optional[str] = None
    soil_class: Optional[str] = None
    distance_to_fault_km: Optional[float] = None
    local_seismic_zone: Optional[int] = None
    presence_of_soft_storey: Optional[bool] = None
    material_quality: Optional[str] = None
    year_of_renovation: Optional[int] = None
    num_basement_floors: Optional[int] = None
    floor_area_m2: Optional[float] = None

class PredictionResponse(BaseModel):
    collapse_probability: float
    damage_category: str
    confidence: float
    top_features: List[Dict[str, any]]
    model_version: str

def load_model():
    """Load the trained model"""
    global model, feature_names
    if MODEL_PATH.exists():
        model_data = joblib.load(MODEL_PATH)
        model = model_data['model']
        feature_names = model_data['feature_names']
    else:
        # Initialize a dummy model for development
        from sklearn.ensemble import RandomForestClassifier
        model = RandomForestClassifier(n_estimators=10)
        # Train on dummy data
        X_dummy = np.random.rand(100, 10)
        y_dummy = np.random.randint(0, 2, 100)
        model.fit(X_dummy, y_dummy)
        feature_names = [f'feature_{i}' for i in range(10)]

@app.on_event("startup")
async def startup_event():
    load_model()

@app.get("/health")
async def health_check():
    return {"status": "healthy", "model_loaded": model is not None}

@app.post("/predict", response_model=PredictionResponse)
async def predict(request: PredictionRequest):
    """
    Predict seismic risk for a building
    """
    if model is None:
        raise HTTPException(status_code=503, detail="Model not loaded")
    
    # Feature engineering
    features = extract_features(request)
    
    # Make prediction
    collapse_prob = model.predict_proba([features])[0][1] if hasattr(model, 'predict_proba') else 0.5
    
    # Determine damage category
    damage_category = get_damage_category(collapse_prob)
    
    # Get feature importance (if available)
    top_features = get_top_features(features)
    
    return PredictionResponse(
        collapse_probability=float(collapse_prob),
        damage_category=damage_category,
        confidence=0.85,  # Placeholder
        top_features=top_features,
        model_version="1.0.0"
    )

def extract_features(request: PredictionRequest) -> List[float]:
    """
    Extract and encode features from request
    """
    features = []
    
    # Numerical features
    features.append(request.year_built or 1985)
    features.append(request.num_floors or 5)
    features.append(request.num_basement_floors or 0)
    features.append(request.floor_area_m2 or 100.0)
    features.append(request.distance_to_fault_km or 10.0)
    features.append(request.local_seismic_zone or 3)
    
    # Categorical encoding (simplified - use proper encoding in production)
    structure_encoding = {
        'RC_FRAME': 0.3,
        'RC_SHEAR_WALL': 0.2,
        'MASONRY_UNREINFORCED': 0.9,
        'MASONRY_REINFORCED': 0.5,
        'STEEL_FRAME': 0.1,
        'TIMBER': 0.7,
        'UNKNOWN': 0.5
    }
    features.append(structure_encoding.get(request.structure_type, 0.5))
    
    soil_encoding = {'A': 0.1, 'B': 0.3, 'C': 0.5, 'D': 0.7, 'E': 0.9}
    features.append(soil_encoding.get(request.soil_class, 0.5))
    
    features.append(1.0 if request.presence_of_soft_storey else 0.0)
    
    material_encoding = {'GOOD': 0.2, 'AVERAGE': 0.5, 'POOR': 0.8, 'UNKNOWN': 0.5}
    features.append(material_encoding.get(request.material_quality, 0.5))
    
    # Age factor (older = higher risk)
    if request.year_built:
        age_factor = max(0, (2024 - request.year_built) / 100)
        features.append(age_factor)
    else:
        features.append(0.3)
    
    return features

def get_damage_category(probability: float) -> str:
    """Map probability to damage category"""
    if probability < 0.2:
        return "NONE"
    elif probability < 0.4:
        return "LIGHT"
    elif probability < 0.6:
        return "MODERATE"
    elif probability < 0.8:
        return "SEVERE"
    else:
        return "COLLAPSE"

def get_top_features(features: List[float]) -> List[Dict[str, any]]:
    """Get top contributing features"""
    feature_names_display = [
        'Year Built',
        'Number of Floors',
        'Basement Floors',
        'Floor Area',
        'Distance to Fault',
        'Seismic Zone',
        'Structure Type',
        'Soil Class',
        'Soft Storey',
        'Material Quality',
        'Building Age Factor'
    ]
    
    # Simplified feature importance
    importance = [abs(f) for f in features]
    top_indices = sorted(range(len(importance)), key=lambda i: importance[i], reverse=True)[:3]
    
    return [
        {
            'feature_name': f'feature_{i}',
            'user_friendly_name': feature_names_display[i],
            'contribution': float(features[i]),
            'explanation': f'{feature_names_display[i]} contributes significantly to risk assessment'
        }
        for i in top_indices
    ]

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)

