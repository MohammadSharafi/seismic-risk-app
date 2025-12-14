import 'package:freezed_annotation/freezed_annotation.dart';

part 'building.freezed.dart';
part 'building.g.dart';

@freezed
class Building with _$Building {
  const factory Building({
    String? id,
    required double latitude,
    required double longitude,
    double? locationAccuracy,
    bool? mapCenterAdjusted,
    String? addressLine,
    String? postalCode,
    required String city,
    String? district,
    String? neighborhood,
    String? apartmentNumber,
    BuildingUsage? buildingUsage,
    int? yearBuilt,
    int? yearOfMajorRenovation,
    int? numFloors,
    int? numBasementFloors,
    double? typicalFloorHeightM,
    bool? occupied,
    PrimaryStructureType? primaryStructureType,
    FloorSystem? floorSystem,
    FoundationType? foundationType,
    WallMaterial? wallMaterial,
    RoofType? roofType,
    LateralResistanceSystem? lateralResistanceSystem,
    bool? presenceOfSoftStorey,
    BuildingIrregularities? irregularities,
    ConnectionQuality? connectionQuality,
    double? typicalColumnSpacingM,
    double? floorAreaM2,
    MaterialQualityIndicator? materialQualityIndicator,
    int? householdCount,
    bool? criticalInfrastructure,
    SoilClass? soilClass,
    double? distanceToFaultKm,
    int? localSeismicZone,
    double? topographicSlope,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Building;

  factory Building.fromJson(Map<String, dynamic> json) =>
      _$BuildingFromJson(json);
}

enum BuildingUsage {
  residential,
  commercial,
  mixed,
  public,
  industrial,
}

enum PrimaryStructureType {
  rcFrame,
  rcShearWall,
  masonryUnreinforced,
  masonryReinforced,
  steelFrame,
  timber,
  precastConcrete,
  mixed,
  unknown,
}

enum FloorSystem {
  slabOnGrade,
  monolithicRcSlab,
  precastSlab,
  timber,
  other,
}

enum FoundationType {
  shallowSpreadFooting,
  raftMat,
  pileFoundation,
  mixed,
  unknown,
}

enum WallMaterial {
  brick,
  stone,
  concreteBlock,
  pouredInPlaceConcrete,
  timber,
}

enum RoofType {
  flat,
  pitched,
  dome,
  other,
}

enum LateralResistanceSystem {
  momentFrames,
  shearWalls,
  braces,
  noneUnknown,
}

enum ConnectionQuality {
  good,
  moderate,
  poor,
  unknown,
}

enum MaterialQualityIndicator {
  good,
  average,
  poor,
  unknown,
}

enum SoilClass {
  a,
  b,
  c,
  d,
  e,
}

@freezed
class BuildingIrregularities with _$BuildingIrregularities {
  const factory BuildingIrregularities({
    @Default(false) bool planIrregularity,
    @Default(false) bool elevationIrregularity,
    @Default(false) bool torsion,
  }) = _BuildingIrregularities;

  factory BuildingIrregularities.fromJson(Map<String, dynamic> json) =>
      _$BuildingIrregularitiesFromJson(json);
}

