package com.seismicrisk.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Map;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class NeighborhoodDefaults {
    private String neighborhoodId;
    private String neighborhoodName;
    private YearRange defaultYearRange;
    private Map<String, Double> typicalStructureTypes;
    private Double typicalNumFloorsMean;
    private Double typicalNumFloorsStd;
    private String typicalSoilClass;
    private Double retrofitRateEstimate;
    private String expectedMaterialQuality;
    
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class YearRange {
        private int start;
        private int end;
    }
}

