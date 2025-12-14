package com.seismicrisk.repository;

import com.seismicrisk.model.Building;
import org.locationtech.jts.geom.Point;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface BuildingRepository extends JpaRepository<Building, UUID> {
    @Query(value = "SELECT * FROM buildings WHERE ST_DWithin(location, ST_SetSRID(ST_MakePoint(:lng, :lat), 4326), :distance)", 
           nativeQuery = true)
    java.util.List<Building> findNearbyBuildings(
        @Param("lat") double latitude,
        @Param("lng") double longitude,
        @Param("distance") double distanceMeters
    );
}

