package com.seismicrisk.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;
import java.util.Map;
import java.util.UUID;

@Entity
@Table(name = "predictions")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Prediction {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "building_id", nullable = false)
    private Building building;
    
    @Column(nullable = false)
    private String modelVersion;
    
    @Column(nullable = false)
    private Double collapseProbability;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private DamageCategory damageCategory;
    
    @Column(nullable = false)
    private Double confidence;
    
    @Column(columnDefinition = "jsonb")
    @Convert(converter = JsonMapConverter.class)
    private Map<String, Object> topFeatures;
    
    @Column
    private Integer estimatedCasualties;
    
    @Column
    private Double retrofitPriorityScore;
    
    @CreationTimestamp
    private LocalDateTime createdAt;
}

