package com.seismicrisk.service;

import com.seismicrisk.model.Building;
import com.seismicrisk.model.DamageCategory;
import com.seismicrisk.model.Prediction;
import com.seismicrisk.repository.BuildingRepository;
import com.seismicrisk.repository.PredictionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.reactive.function.client.WebClient;

import java.util.Map;
import java.util.UUID;

// @Service  // Temporarily disabled until Lombok is fixed
@RequiredArgsConstructor
public class PredictionService {
    private final BuildingRepository buildingRepository;
    private final PredictionRepository predictionRepository;
    private final WebClient mlServiceClient;
    
    
    @Transactional
    public UUID triggerPrediction(UUID buildingId) {
        Building building = buildingRepository.findById(buildingId)
            .orElseThrow(() -> new RuntimeException("Building not found"));
        
        // Call ML service
        Map<String, Object> features = extractFeatures(building);
        Map<String, Object> predictionResponse = mlServiceClient.post()
            .uri("/predict")
            .bodyValue(features)
            .retrieve()
            .bodyToMono(Map.class)
            .block();
        
        // Save prediction
        Prediction prediction = Prediction.builder()
            .building(building)
            .modelVersion((String) predictionResponse.get("model_version"))
            .collapseProbability(((Number) predictionResponse.get("collapse_probability")).doubleValue())
            .damageCategory(DamageCategory.valueOf(
                ((String) predictionResponse.get("damage_category")).toUpperCase()))
            .confidence(((Number) predictionResponse.get("confidence")).doubleValue())
            .topFeatures((Map<String, Object>) predictionResponse.get("top_features"))
            .build();
        
        prediction = predictionRepository.save(prediction);
        return prediction.getId();
    }
    
    public Prediction getPrediction(UUID id) {
        return predictionRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Prediction not found"));
    }
    
    private Map<String, Object> extractFeatures(Building building) {
        // Extract features from building for ML model
        // TODO: Fix Lombok annotation processing
        Integer yearBuilt = building.getYearBuilt() != null ? building.getYearBuilt() : 0;
        Integer numFloors = building.getNumFloors() != null ? building.getNumFloors() : 0;
        String structureType = building.getPrimaryStructureType() != null 
            ? building.getPrimaryStructureType().toString() : "UNKNOWN";
        String soilClass = building.getSoilClass() != null 
            ? building.getSoilClass().toString() : "C";
        
        return Map.of(
            "year_built", yearBuilt,
            "num_floors", numFloors,
            "structure_type", structureType,
            "soil_class", soilClass
        );
    }
}

