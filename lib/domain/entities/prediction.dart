import 'package:freezed_annotation/freezed_annotation.dart';

part 'prediction.freezed.dart';
part 'prediction.g.dart';

@freezed
class Prediction with _$Prediction {
  const factory Prediction({
    String? id,
    required String buildingId,
    required String modelVersion,
    required double collapseProbability,
    required DamageCategory damageCategory,
    required double confidence,
    required List<FeatureContribution> topFeatures,
    int? estimatedCasualties,
    double? retrofitPriorityScore,
    DateTime? createdAt,
  }) = _Prediction;

  factory Prediction.fromJson(Map<String, dynamic> json) =>
      _$PredictionFromJson(json);
}

enum DamageCategory {
  none,
  light,
  moderate,
  severe,
  collapse,
}

@freezed
class FeatureContribution with _$FeatureContribution {
  const factory FeatureContribution({
    required String featureName,
    required String userFriendlyName,
    required double contribution,
    required String explanation,
  }) = _FeatureContribution;

  factory FeatureContribution.fromJson(Map<String, dynamic> json) =>
      _$FeatureContributionFromJson(json);
}

