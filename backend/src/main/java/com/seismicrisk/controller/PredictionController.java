package com.seismicrisk.controller;

import com.seismicrisk.model.Prediction;
import com.seismicrisk.service.PredictionService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.UUID;

// @RestController  // Temporarily disabled until Lombok is fixed
@RequestMapping("/api/v1")
@RequiredArgsConstructor
public class PredictionController {
    // private final PredictionService predictionService;  // Temporarily disabled
    
    @PostMapping("/predict/{buildingId}")
    public ResponseEntity<Map<String, String>> triggerPrediction(
            @PathVariable UUID buildingId) {
        UUID predictionId = predictionService.triggerPrediction(buildingId);
        return ResponseEntity.ok(Map.of("predictionId", predictionId.toString()));
    }
    
    @GetMapping("/predictions/{id}")
    public ResponseEntity<Prediction> getPrediction(@PathVariable UUID id) {
        Prediction prediction = predictionService.getPrediction(id);
        return ResponseEntity.ok(prediction);
    }
}

