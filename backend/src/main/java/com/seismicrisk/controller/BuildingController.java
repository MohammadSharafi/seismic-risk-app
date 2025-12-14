package com.seismicrisk.controller;

import com.seismicrisk.model.Building;
import com.seismicrisk.service.BuildingService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/buildings")
@RequiredArgsConstructor
public class BuildingController {
    private final BuildingService buildingService;
    
    @PostMapping
    public ResponseEntity<Building> createBuilding(
            @Valid @RequestBody CreateBuildingRequest request) {
        Building building = buildingService.createBuilding(request);
        return ResponseEntity.ok(building);
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<Building> updateBuilding(
            @PathVariable UUID id,
            @RequestBody Map<String, Object> updates) {
        Building building = buildingService.updateBuilding(id, updates);
        return ResponseEntity.ok(building);
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<Building> getBuilding(@PathVariable UUID id) {
        Building building = buildingService.getBuilding(id);
        return ResponseEntity.ok(building);
    }
    
    @PostMapping("/{id}/photos")
    public ResponseEntity<Map<String, String>> uploadPhoto(
            @PathVariable UUID id,
            @RequestParam("photo") MultipartFile file,
            @RequestParam("type") String photoType) {
        String photoId = buildingService.uploadPhoto(id, file, photoType);
        return ResponseEntity.ok(Map.of("photoId", photoId));
    }
    
    public record CreateBuildingRequest(
            Double latitude,
            Double longitude,
            String city
    ) {}
}

