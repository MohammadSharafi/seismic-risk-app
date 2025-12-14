import 'package:seismic_risk_app/data/datasources/api_client.dart';
import 'package:seismic_risk_app/domain/entities/prediction.dart';

class PredictionRepository {
  final ApiClient _apiClient;

  PredictionRepository(this._apiClient);

  Future<Prediction> triggerPrediction(String buildingId) async {
    final response = await _apiClient.post('/predict/$buildingId');
    final predictionId = response.data['predictionId'] as String;
    return getPrediction(predictionId);
  }

  Future<Prediction> getPrediction(String predictionId) async {
    final response = await _apiClient.get('/predictions/$predictionId');
    return Prediction.fromJson(response.data);
  }
}

