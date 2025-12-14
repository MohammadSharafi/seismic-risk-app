package com.seismicrisk.controller;

import com.seismicrisk.model.NeighborhoodDefaults;
import com.seismicrisk.service.NeighborhoodService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/neighborhoods")
@RequiredArgsConstructor
public class NeighborhoodController {
    private final NeighborhoodService neighborhoodService;
    
    @GetMapping("/lookup")
    public ResponseEntity<NeighborhoodDefaults> getNeighborhoodDefaults(
            @RequestParam double lat,
            @RequestParam double lng) {
        NeighborhoodDefaults defaults = neighborhoodService.getDefaults(lat, lng);
        return ResponseEntity.ok(defaults);
    }
}

