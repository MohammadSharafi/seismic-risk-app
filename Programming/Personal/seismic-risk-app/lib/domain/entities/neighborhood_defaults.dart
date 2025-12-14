import 'package:freezed_annotation/freezed_annotation.dart';

part 'neighborhood_defaults.freezed.dart';
part 'neighborhood_defaults.g.dart';

@freezed
class NeighborhoodDefaults with _$NeighborhoodDefaults {
  const factory NeighborhoodDefaults({
    required String neighborhoodId,
    String? neighborhoodName,
    YearRange? defaultYearRange,
    Map<String, double>? typicalStructureTypes,
    double? typicalNumFloorsMean,
    double? typicalNumFloorsStd,
    String? typicalSoilClass,
    double? retrofitRateEstimate,
    String? expectedMaterialQuality,
  }) = _NeighborhoodDefaults;

  factory NeighborhoodDefaults.fromJson(Map<String, dynamic> json) =>
      _$NeighborhoodDefaultsFromJson(json);
}

@freezed
class YearRange with _$YearRange {
  const factory YearRange({
    required int start,
    required int end,
  }) = _YearRange;

  factory YearRange.fromJson(Map<String, dynamic> json) =>
      _$YearRangeFromJson(json);
}

