import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seismic_risk_app/data/datasources/api_client.dart';
import 'package:seismic_risk_app/data/repositories/building_repository.dart';
import 'package:seismic_risk_app/domain/entities/building.dart';
import 'package:seismic_risk_app/domain/entities/neighborhood_defaults.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final buildingRepositoryProvider = Provider<BuildingRepository>((ref) {
  return BuildingRepository(ref.watch(apiClientProvider));
});

final buildingProvider = StateNotifierProvider<BuildingNotifier, Building?>((ref) {
  return BuildingNotifier(ref.watch(buildingRepositoryProvider));
});

class BuildingNotifier extends StateNotifier<Building?> {
  final BuildingRepository _repository;

  BuildingNotifier(this._repository) : super(null);

  Future<void> createBuilding({
    required double latitude,
    required double longitude,
    String? city,
  }) async {
    try {
      final building = await _repository.createBuilding(
        latitude: latitude,
        longitude: longitude,
        city: city,
      );
      state = building;
    } catch (e) {
      // If API call fails, create a local building object with just location
      // This allows the app to work offline
      state = Building(
        id: 'local-${DateTime.now().millisecondsSinceEpoch}',
        latitude: latitude,
        longitude: longitude,
        city: city ?? 'Unknown', // Building requires city, use default if not provided
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      // Don't rethrow - allow offline mode
    }
  }

  Future<void> updateBuilding(Map<String, dynamic> updates) async {
    // If state is null but we have updates that include location, create a basic building
    if (state == null && updates.containsKey('latitude') && updates.containsKey('longitude')) {
      state = Building(
        id: updates['id'] as String? ?? 'local-${DateTime.now().millisecondsSinceEpoch}',
        latitude: updates['latitude'] as double,
        longitude: updates['longitude'] as double,
        city: updates['city'] as String? ?? 'Unknown',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      // Continue with the rest of the updates
    }
    
    if (state == null) return;
    
    final currentBuilding = state!;
    
    // Prepare updates for backend (convert enums to strings)
    final backendUpdates = <String, dynamic>{};
    updates.forEach((key, value) {
      if (value is Enum) {
        backendUpdates[key] = value.toString().split('.').last;
      } else if (key == 'irregularities' && value is Map) {
        backendUpdates[key] = value;
      } else {
        backendUpdates[key] = value;
      }
    });
    
    // Update local state immediately using copyWith
    Building updatedBuilding = currentBuilding;
    backendUpdates.forEach((key, value) {
      switch (key) {
        case 'addressLine':
          updatedBuilding = updatedBuilding.copyWith(addressLine: value as String?);
          break;
        case 'postalCode':
          updatedBuilding = updatedBuilding.copyWith(postalCode: value as String?);
          break;
        case 'city':
          updatedBuilding = updatedBuilding.copyWith(city: value as String);
          break;
        case 'district':
          updatedBuilding = updatedBuilding.copyWith(district: value as String?);
          break;
        case 'neighborhood':
          updatedBuilding = updatedBuilding.copyWith(neighborhood: value as String?);
          break;
        case 'yearBuilt':
          updatedBuilding = updatedBuilding.copyWith(yearBuilt: value as int?);
          break;
        case 'numFloors':
          updatedBuilding = updatedBuilding.copyWith(numFloors: value as int?);
          break;
        case 'primaryStructureType':
          updatedBuilding = updatedBuilding.copyWith(
            primaryStructureType: _parseStructureType(value),
          );
          break;
        case 'buildingUsage':
          updatedBuilding = updatedBuilding.copyWith(
            buildingUsage: _parseBuildingUsage(value),
          );
          break;
        case 'foundationType':
          updatedBuilding = updatedBuilding.copyWith(
            foundationType: _parseFoundationType(value),
          );
          break;
        case 'floorAreaM2':
          updatedBuilding = updatedBuilding.copyWith(floorAreaM2: value as double?);
          break;
        case 'materialQualityIndicator':
          updatedBuilding = updatedBuilding.copyWith(
            materialQualityIndicator: _parseMaterialQuality(value),
          );
          break;
        case 'irregularities':
          if (value is Map) {
            updatedBuilding = updatedBuilding.copyWith(
              irregularities: BuildingIrregularities(
                planIrregularity: value['planIrregularity'] as bool? ?? false,
                elevationIrregularity: value['elevationIrregularity'] as bool? ?? false,
                torsion: value['torsion'] as bool? ?? false,
              ),
            );
          }
          break;
        case 'numBasementFloors':
          updatedBuilding = updatedBuilding.copyWith(numBasementFloors: value as int?);
          break;
        case 'wallMaterial':
          updatedBuilding = updatedBuilding.copyWith(
            wallMaterial: _parseWallMaterial(value),
          );
          break;
        case 'roofType':
          updatedBuilding = updatedBuilding.copyWith(
            roofType: _parseRoofType(value),
          );
          break;
        case 'floorSystem':
          updatedBuilding = updatedBuilding.copyWith(
            floorSystem: _parseFloorSystem(value),
          );
          break;
        case 'lateralResistanceSystem':
          updatedBuilding = updatedBuilding.copyWith(
            lateralResistanceSystem: _parseLateralResistanceSystem(value),
          );
          break;
        case 'connectionQuality':
          updatedBuilding = updatedBuilding.copyWith(
            connectionQuality: _parseConnectionQuality(value),
          );
          break;
        case 'yearOfMajorRenovation':
          updatedBuilding = updatedBuilding.copyWith(yearOfMajorRenovation: value as int?);
          break;
        case 'presenceOfSoftStorey':
          updatedBuilding = updatedBuilding.copyWith(presenceOfSoftStorey: value as bool?);
          break;
        case 'soilClass':
          updatedBuilding = updatedBuilding.copyWith(
            soilClass: _parseSoilClass(value),
          );
          break;
        case 'distanceToFaultKm':
          updatedBuilding = updatedBuilding.copyWith(distanceToFaultKm: value as double?);
          break;
        case 'typicalColumnSpacingM':
          updatedBuilding = updatedBuilding.copyWith(typicalColumnSpacingM: value as double?);
          break;
        case 'occupied':
          updatedBuilding = updatedBuilding.copyWith(occupied: value as bool?);
          break;
        case 'householdCount':
          updatedBuilding = updatedBuilding.copyWith(householdCount: value as int?);
          break;
        case 'criticalInfrastructure':
          updatedBuilding = updatedBuilding.copyWith(criticalInfrastructure: value as bool?);
          break;
      }
    });
    
    updatedBuilding = updatedBuilding.copyWith(updatedAt: DateTime.now());
    state = updatedBuilding;
    
    // Try to sync with backend if building has a real ID (not local)
    if (currentBuilding.id != null && !currentBuilding.id!.startsWith('local-')) {
      try {
        final syncedBuilding = await _repository.updateBuilding(currentBuilding.id!, backendUpdates);
        state = syncedBuilding;
      } catch (e) {
        // Backend update failed, but local state is already updated
        // Keep the local state - at least the UI will work
        print('Backend update failed, using local state: $e');
      }
    }
  }

  PrimaryStructureType? _parseStructureType(dynamic value) {
    if (value is PrimaryStructureType) return value;
    if (value is String) {
      return PrimaryStructureType.values.firstWhere(
        (e) => e.toString().split('.').last == value,
        orElse: () => PrimaryStructureType.unknown,
      );
    }
    return null;
  }

  BuildingUsage? _parseBuildingUsage(dynamic value) {
    if (value is BuildingUsage) return value;
    if (value is String) {
      return BuildingUsage.values.firstWhere(
        (e) => e.toString().split('.').last == value,
        orElse: () => BuildingUsage.residential,
      );
    }
    return null;
  }

  FoundationType? _parseFoundationType(dynamic value) {
    if (value is FoundationType) return value;
    if (value is String) {
      return FoundationType.values.firstWhere(
        (e) => e.toString().split('.').last == value,
        orElse: () => FoundationType.unknown,
      );
    }
    return null;
  }

  MaterialQualityIndicator? _parseMaterialQuality(dynamic value) {
    if (value is MaterialQualityIndicator) return value;
    if (value is String) {
      return MaterialQualityIndicator.values.firstWhere(
        (e) => e.toString().split('.').last == value,
        orElse: () => MaterialQualityIndicator.unknown,
      );
    }
    return null;
  }

  WallMaterial? _parseWallMaterial(dynamic value) {
    if (value is WallMaterial) return value;
    if (value is String) {
      return WallMaterial.values.firstWhere(
        (e) => e.toString().split('.').last == value,
        orElse: () => WallMaterial.brick,
      );
    }
    return null;
  }

  RoofType? _parseRoofType(dynamic value) {
    if (value is RoofType) return value;
    if (value is String) {
      return RoofType.values.firstWhere(
        (e) => e.toString().split('.').last == value,
        orElse: () => RoofType.flat,
      );
    }
    return null;
  }

  FloorSystem? _parseFloorSystem(dynamic value) {
    if (value is FloorSystem) return value;
    if (value is String) {
      return FloorSystem.values.firstWhere(
        (e) => e.toString().split('.').last == value,
        orElse: () => FloorSystem.monolithicRcSlab,
      );
    }
    return null;
  }

  LateralResistanceSystem? _parseLateralResistanceSystem(dynamic value) {
    if (value is LateralResistanceSystem) return value;
    if (value is String) {
      return LateralResistanceSystem.values.firstWhere(
        (e) => e.toString().split('.').last == value,
        orElse: () => LateralResistanceSystem.noneUnknown,
      );
    }
    return null;
  }

  ConnectionQuality? _parseConnectionQuality(dynamic value) {
    if (value is ConnectionQuality) return value;
    if (value is String) {
      return ConnectionQuality.values.firstWhere(
        (e) => e.toString().split('.').last == value,
        orElse: () => ConnectionQuality.unknown,
      );
    }
    return null;
  }

  SoilClass? _parseSoilClass(dynamic value) {
    if (value is SoilClass) return value;
    if (value is String) {
      return SoilClass.values.firstWhere(
        (e) => e.toString().split('.').last == value,
        orElse: () => SoilClass.d,
      );
    }
    return null;
  }

  Future<NeighborhoodDefaults> getNeighborhoodDefaults() async {
    if (state == null) throw Exception('Building not initialized');
    return await _repository.getNeighborhoodDefaults(
      latitude: state!.latitude,
      longitude: state!.longitude,
    );
  }
}
