import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seismic_risk_app/data/repositories/prediction_repository.dart';
import 'package:seismic_risk_app/domain/entities/prediction.dart';
import 'package:seismic_risk_app/presentation/providers/building_provider.dart';

final predictionRepositoryProvider = Provider<PredictionRepository>((ref) {
  return PredictionRepository(ref.watch(apiClientProvider));
});

final predictionProvider = FutureProvider.family<Prediction, String>((ref, buildingId) async {
  final repository = ref.watch(predictionRepositoryProvider);
  return await repository.triggerPrediction(buildingId);
});

