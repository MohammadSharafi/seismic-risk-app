package com.seismicrisk.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;
import org.locationtech.jts.geom.Point;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "buildings")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Building {
    // Lombok @Data generates: getters, setters, toString, equals, hashCode
    // Lombok @Builder generates: builder() method
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    
    @Column(nullable = false)
    private Point location; // PostGIS Point
    
    @Column
    private Double locationAccuracy;
    
    @Column
    private Boolean mapCenterAdjusted;
    
    @Column
    private String addressLine;
    
    @Column
    private String postalCode;
    
    @Column(nullable = false)
    private String city;
    
    @Column
    private String district;
    
    @Column
    private String neighborhood;
    
    @Column
    private String apartmentNumber;
    
    @Enumerated(EnumType.STRING)
    private BuildingUsage buildingUsage;
    
    @Column
    private Integer yearBuilt;
    
    @Column
    private Integer yearOfMajorRenovation;
    
    @Column
    private Integer numFloors;
    
    @Column
    private Integer numBasementFloors;
    
    @Column
    private Double typicalFloorHeightM;
    
    @Column
    private Boolean occupied;
    
    @Enumerated(EnumType.STRING)
    private PrimaryStructureType primaryStructureType;
    
    @Enumerated(EnumType.STRING)
    private FoundationType foundationType;
    
    @Enumerated(EnumType.STRING)
    private WallMaterial wallMaterial;
    
    @Enumerated(EnumType.STRING)
    private SoilClass soilClass;
    
    @Column
    private Double distanceToFaultKm;
    
    @Column
    private Integer localSeismicZone;
    
    @Column
    private Double topographicSlope;
    
    @CreationTimestamp
    private LocalDateTime createdAt;
    
    @UpdateTimestamp
    private LocalDateTime updatedAt;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;
    
    // Manual getters (Lombok not processing correctly)
    public Integer getYearBuilt() { return yearBuilt; }
    public Integer getNumFloors() { return numFloors; }
    public PrimaryStructureType getPrimaryStructureType() { return primaryStructureType; }
    public SoilClass getSoilClass() { return soilClass; }
    
    // Manual builder method
    public static BuildingBuilder builder() {
        return new BuildingBuilder();
    }
    
    public static class BuildingBuilder {
        private Building building = new Building();
        
        public BuildingBuilder location(Point location) { building.location = location; return this; }
        public BuildingBuilder city(String city) { building.city = city; return this; }
        public BuildingBuilder yearBuilt(Integer yearBuilt) { building.yearBuilt = yearBuilt; return this; }
        public BuildingBuilder numFloors(Integer numFloors) { building.numFloors = numFloors; return this; }
        public BuildingBuilder primaryStructureType(PrimaryStructureType type) { building.primaryStructureType = type; return this; }
        public BuildingBuilder soilClass(SoilClass soilClass) { building.soilClass = soilClass; return this; }
        public BuildingBuilder id(UUID id) { building.id = id; return this; }
        public BuildingBuilder locationAccuracy(Double accuracy) { building.locationAccuracy = accuracy; return this; }
        public BuildingBuilder mapCenterAdjusted(Boolean adjusted) { building.mapCenterAdjusted = adjusted; return this; }
        public BuildingBuilder addressLine(String address) { building.addressLine = address; return this; }
        public BuildingBuilder postalCode(String code) { building.postalCode = code; return this; }
        public BuildingBuilder district(String district) { building.district = district; return this; }
        public BuildingBuilder neighborhood(String neighborhood) { building.neighborhood = neighborhood; return this; }
        public BuildingBuilder apartmentNumber(String apt) { building.apartmentNumber = apt; return this; }
        public BuildingBuilder buildingUsage(BuildingUsage usage) { building.buildingUsage = usage; return this; }
        public BuildingBuilder yearOfMajorRenovation(Integer year) { building.yearOfMajorRenovation = year; return this; }
        public BuildingBuilder numBasementFloors(Integer floors) { building.numBasementFloors = floors; return this; }
        public BuildingBuilder typicalFloorHeightM(Double height) { building.typicalFloorHeightM = height; return this; }
        public BuildingBuilder occupied(Boolean occupied) { building.occupied = occupied; return this; }
        public BuildingBuilder foundationType(FoundationType type) { building.foundationType = type; return this; }
        public BuildingBuilder wallMaterial(WallMaterial material) { building.wallMaterial = material; return this; }
        public BuildingBuilder distanceToFaultKm(Double distance) { building.distanceToFaultKm = distance; return this; }
        public BuildingBuilder localSeismicZone(Integer zone) { building.localSeismicZone = zone; return this; }
        public BuildingBuilder topographicSlope(Double slope) { building.topographicSlope = slope; return this; }
        public BuildingBuilder user(User user) { building.user = user; return this; }
        
        public Building build() { return building; }
    }
}

