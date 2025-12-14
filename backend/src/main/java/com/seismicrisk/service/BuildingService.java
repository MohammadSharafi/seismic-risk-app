package com.seismicrisk.service;

import com.seismicrisk.controller.BuildingController.CreateBuildingRequest;
import com.seismicrisk.model.Building;
import com.seismicrisk.repository.BuildingRepository;
import lombok.RequiredArgsConstructor;
import org.locationtech.jts.geom.Coordinate;
import org.locationtech.jts.geom.GeometryFactory;
import org.locationtech.jts.geom.Point;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class BuildingService {
    private final BuildingRepository buildingRepository;
    private final GeometryFactory geometryFactory = new GeometryFactory();
    private final FileStorageService fileStorageService;
    
    @Transactional
    public Building createBuilding(CreateBuildingRequest request) {
        Point location = geometryFactory.createPoint(
            new Coordinate(request.latitude(), request.longitude())
        );
        
        Building building = Building.builder()
            .location(location)
            .city(request.city())
            .build();
        
        return buildingRepository.save(building);
    }
    
    @Transactional
    public Building updateBuilding(UUID id, Map<String, Object> updates) {
        Building building = buildingRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Building not found"));
        
        // Apply updates using reflection or MapStruct
        updates.forEach((key, value) -> {
            // Simplified - use proper mapping in production
            try {
                var field = Building.class.getDeclaredField(key);
                field.setAccessible(true);
                field.set(building, value);
            } catch (Exception e) {
                // Handle error
            }
        });
        
        return buildingRepository.save(building);
    }
    
    public Building getBuilding(UUID id) {
        return buildingRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Building not found"));
    }
    
    public String uploadPhoto(UUID buildingId, MultipartFile file, String photoType) {
        Building building = getBuilding(buildingId);
        String photoId = fileStorageService.store(file);
        // Save photo metadata to database
        return photoId;
    }
    
}

