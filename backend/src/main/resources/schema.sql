-- Enable PostGIS extension
CREATE EXTENSION IF NOT EXISTS postgis;

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name_hash VARCHAR(255),
    email_hash VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Buildings table with PostGIS geometry
CREATE TABLE IF NOT EXISTS buildings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    location GEOGRAPHY(POINT, 4326) NOT NULL,
    location_accuracy DOUBLE PRECISION,
    map_center_adjusted BOOLEAN,
    address_line VARCHAR(500),
    postal_code VARCHAR(20),
    city VARCHAR(100) NOT NULL,
    district VARCHAR(100),
    neighborhood VARCHAR(100),
    apartment_number VARCHAR(50),
    building_usage VARCHAR(50),
    year_built INTEGER,
    year_of_major_renovation INTEGER,
    num_floors INTEGER,
    num_basement_floors INTEGER,
    typical_floor_height_m DOUBLE PRECISION,
    occupied BOOLEAN,
    primary_structure_type VARCHAR(50),
    floor_system VARCHAR(50),
    foundation_type VARCHAR(50),
    wall_material VARCHAR(50),
    roof_type VARCHAR(50),
    lateral_resistance_system VARCHAR(50),
    presence_of_soft_storey BOOLEAN,
    plan_irregularity BOOLEAN,
    elevation_irregularity BOOLEAN,
    torsion BOOLEAN,
    connection_quality VARCHAR(50),
    typical_column_spacing_m DOUBLE PRECISION,
    floor_area_m2 DOUBLE PRECISION,
    material_quality_indicator VARCHAR(50),
    household_count INTEGER,
    critical_infrastructure BOOLEAN,
    soil_class VARCHAR(10),
    distance_to_fault_km DOUBLE PRECISION,
    local_seismic_zone INTEGER,
    topographic_slope DOUBLE PRECISION,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create spatial index on location
CREATE INDEX IF NOT EXISTS idx_buildings_location ON buildings USING GIST(location);

-- Neighborhood defaults table
CREATE TABLE IF NOT EXISTS neighborhood_defaults (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    neighborhood_id VARCHAR(100) UNIQUE NOT NULL,
    neighborhood_name VARCHAR(200),
    default_year_range_start INTEGER,
    default_year_range_end INTEGER,
    typical_structure_types JSONB,
    typical_num_floors_mean DOUBLE PRECISION,
    typical_num_floors_std DOUBLE PRECISION,
    typical_soil_class VARCHAR(10),
    retrofit_rate_estimate DOUBLE PRECISION,
    expected_material_quality VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Predictions table
CREATE TABLE IF NOT EXISTS predictions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    building_id UUID NOT NULL REFERENCES buildings(id) ON DELETE CASCADE,
    model_version VARCHAR(50) NOT NULL,
    collapse_probability DOUBLE PRECISION NOT NULL,
    damage_category VARCHAR(20) NOT NULL,
    confidence DOUBLE PRECISION NOT NULL,
    top_features JSONB,
    estimated_casualties INTEGER,
    retrofit_priority_score DOUBLE PRECISION,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_predictions_building_id ON predictions(building_id);
CREATE INDEX IF NOT EXISTS idx_predictions_created_at ON predictions(created_at);

-- Photos table
CREATE TABLE IF NOT EXISTS photos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    building_id UUID NOT NULL REFERENCES buildings(id) ON DELETE CASCADE,
    photo_type VARCHAR(50),
    storage_path VARCHAR(500) NOT NULL,
    file_hash VARCHAR(64),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_photos_building_id ON photos(building_id);

-- Audit logs table
CREATE TABLE IF NOT EXISTS audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    building_id UUID REFERENCES buildings(id),
    user_id UUID REFERENCES users(id),
    action VARCHAR(100) NOT NULL,
    details JSONB,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_audit_logs_building_id ON audit_logs(building_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_timestamp ON audit_logs(timestamp);

