import 'package:seismic_risk_app/data/datasources/api_client.dart';
import 'package:seismic_risk_app/domain/entities/building.dart';
import 'package:seismic_risk_app/domain/entities/neighborhood_defaults.dart';

class BuildingRepository {
  final ApiClient _apiClient;

  BuildingRepository(this._apiClient);

  Future<Building> createBuilding({
    required double latitude,
    required double longitude,
    String? city,
  }) async {
    final response = await _apiClient.post(
      '/buildings',
      data: {
        'latitude': latitude,
        'longitude': longitude,
        if (city != null) 'city': city,
      },
    );
    return Building.fromJson(response.data);
  }

  Future<Building> updateBuilding(String buildingId, Map<String, dynamic> updates) async {
    final response = await _apiClient.put(
      '/buildings/$buildingId',
      data: updates,
    );
    return Building.fromJson(response.data);
  }

  Future<Building> getBuilding(String buildingId) async {
    final response = await _apiClient.get('/buildings/$buildingId');
    return Building.fromJson(response.data);
  }

  Future<NeighborhoodDefaults> getNeighborhoodDefaults({
    required double latitude,
    required double longitude,
  }) async {
    final response = await _apiClient.get(
      '/neighborhoods/lookup',
      queryParameters: {
        'lat': latitude,
        'lng': longitude,
      },
    );
    return NeighborhoodDefaults.fromJson(response.data);
  }

  Future<String> uploadPhoto(String buildingId, String photoPath, String photoType) async {
    final response = await _apiClient.uploadFile(
      '/buildings/$buildingId/photos',
      photoPath,
      'photo',
    );
    return response.data['photoId'] as String;
  }
}

