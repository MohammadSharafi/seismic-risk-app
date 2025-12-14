"""
Training script for seismic risk prediction model
"""
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split, cross_val_score
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import roc_auc_score, brier_score_loss, classification_report
import xgboost as xgb
import lightgbm as lgb
import joblib
from pathlib import Path
import shap

def load_data(filepath: str) -> pd.DataFrame:
    """Load training data"""
    # In production, load from database or CSV
    # For now, generate synthetic data
    np.random.seed(42)
    n_samples = 1000
    
    data = {
        'year_built': np.random.randint(1950, 2020, n_samples),
        'num_floors': np.random.randint(1, 20, n_samples),
        'structure_type': np.random.choice(['RC_FRAME', 'MASONRY_UNREINFORCED', 'STEEL_FRAME'], n_samples),
        'soil_class': np.random.choice(['A', 'B', 'C', 'D', 'E'], n_samples),
        'distance_to_fault_km': np.random.uniform(1, 50, n_samples),
        'local_seismic_zone': np.random.randint(1, 5, n_samples),
        'presence_of_soft_storey': np.random.choice([True, False], n_samples),
        'material_quality': np.random.choice(['GOOD', 'AVERAGE', 'POOR'], n_samples),
    }
    
    df = pd.DataFrame(data)
    
    # Generate target (collapse probability) based on rules
    df['collapse_probability'] = (
        (df['year_built'] < 1970) * 0.3 +
        (df['structure_type'] == 'MASONRY_UNREINFORCED') * 0.4 +
        (df['soil_class'].isin(['D', 'E'])) * 0.2 +
        df['presence_of_soft_storey'] * 0.1 +
        np.random.normal(0, 0.1, n_samples)
    ).clip(0, 1)
    
    df['collapse_label'] = (df['collapse_probability'] > 0.5).astype(int)
    
    return df

def feature_engineering(df: pd.DataFrame) -> pd.DataFrame:
    """Engineer features"""
    df = df.copy()
    
    # Age factor
    df['building_age'] = 2024 - df['year_built']
    df['age_factor'] = df['building_age'] / 100
    
    # Structure type encoding
    structure_map = {
        'RC_FRAME': 0.3,
        'RC_SHEAR_WALL': 0.2,
        'MASONRY_UNREINFORCED': 0.9,
        'MASONRY_REINFORCED': 0.5,
        'STEEL_FRAME': 0.1,
        'TIMBER': 0.7
    }
    df['structure_risk'] = df['structure_type'].map(structure_map).fillna(0.5)
    
    # Soil class encoding
    soil_map = {'A': 0.1, 'B': 0.3, 'C': 0.5, 'D': 0.7, 'E': 0.9}
    df['soil_risk'] = df['soil_class'].map(soil_map)
    
    # Material quality encoding
    material_map = {'GOOD': 0.2, 'AVERAGE': 0.5, 'POOR': 0.8}
    df['material_risk'] = df['material_quality'].map(material_map)
    
    # Soft storey flag
    df['soft_storey_flag'] = df['presence_of_soft_storey'].astype(int)
    
    return df

def train_model(X_train: pd.DataFrame, y_train: pd.Series):
    """Train XGBoost model"""
    model = xgb.XGBClassifier(
        n_estimators=100,
        max_depth=6,
        learning_rate=0.1,
        objective='binary:logistic',
        eval_metric='auc',
        random_state=42
    )
    
    model.fit(X_train, y_train)
    return model

def evaluate_model(model, X_test: pd.DataFrame, y_test: pd.Series):
    """Evaluate model performance"""
    y_pred_proba = model.predict_proba(X_test)[:, 1]
    y_pred = model.predict(X_test)
    
    auc = roc_auc_score(y_test, y_pred_proba)
    brier = brier_score_loss(y_test, y_pred_proba)
    
    print(f"ROC AUC: {auc:.4f}")
    print(f"Brier Score: {brier:.4f}")
    print("\nClassification Report:")
    print(classification_report(y_test, y_pred))
    
    return {'auc': auc, 'brier': brier}

def main():
    """Main training pipeline"""
    print("Loading data...")
    df = load_data("data/training_data.csv")
    
    print("Engineering features...")
    df = feature_engineering(df)
    
    # Select features
    feature_cols = [
        'year_built', 'num_floors', 'building_age', 'age_factor',
        'structure_risk', 'soil_risk', 'material_risk',
        'distance_to_fault_km', 'local_seismic_zone',
        'soft_storey_flag'
    ]
    
    X = df[feature_cols]
    y = df['collapse_label']
    
    # Split data
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y
    )
    
    # Scale features
    scaler = StandardScaler()
    X_train_scaled = scaler.fit_transform(X_train)
    X_test_scaled = scaler.transform(X_test)
    
    print("Training model...")
    model = train_model(
        pd.DataFrame(X_train_scaled, columns=feature_cols),
        y_train
    )
    
    print("Evaluating model...")
    evaluate_model(
        model,
        pd.DataFrame(X_test_scaled, columns=feature_cols),
        y_test
    )
    
    # Save model
    model_dir = Path("models")
    model_dir.mkdir(exist_ok=True)
    
    model_data = {
        'model': model,
        'scaler': scaler,
        'feature_names': feature_cols
    }
    
    joblib.dump(model_data, model_dir / "seismic_risk_model.pkl")
    print(f"\nModel saved to {model_dir / 'seismic_risk_model.pkl'}")
    
    # SHAP analysis
    print("\nComputing SHAP values...")
    explainer = shap.TreeExplainer(model)
    shap_values = explainer.shap_values(X_test_scaled[:100])  # Sample
    
    print("Training complete!")

if __name__ == "__main__":
    main()

