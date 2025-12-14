import 'package:freezed_annotation/freezed_annotation.dart';

part 'recommendation.freezed.dart';
part 'recommendation.g.dart';

@freezed
class Recommendation with _$Recommendation {
  const factory Recommendation({
    required String id,
    required RecommendationPriority priority,
    required String title,
    required String description,
    String? estimatedCost,
    String? urgency,
    List<String>? actionSteps,
  }) = _Recommendation;

  factory Recommendation.fromJson(Map<String, dynamic> json) =>
      _$RecommendationFromJson(json);
}

enum RecommendationPriority {
  immediate,
  shortTerm,
  mediumTerm,
  retrofit,
}

