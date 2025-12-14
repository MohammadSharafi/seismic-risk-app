package com.seismicrisk.service;

import com.seismicrisk.model.NeighborhoodDefaults;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class NeighborhoodService {
    
    public NeighborhoodDefaults getDefaults(double latitude, double longitude) {
        // Query neighborhood defaults from database or use heuristics
        // For now, return default values
        NeighborhoodDefaults.YearRange yearRange = new NeighborhoodDefaults.YearRange(1970, 1999);
        return NeighborhoodDefaults.builder()
            .neighborhoodId("default")
            .defaultYearRange(yearRange)
            .typicalNumFloorsMean(5.0)
            .typicalSoilClass("C")
            .build();
    }
}

