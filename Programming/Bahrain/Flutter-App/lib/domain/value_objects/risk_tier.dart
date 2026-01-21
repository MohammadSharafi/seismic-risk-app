import 'package:equatable/equatable.dart';

enum RiskTier {
  low,
  medium,
  high;

  String get displayName {
    switch (this) {
      case RiskTier.low:
        return 'Low';
      case RiskTier.medium:
        return 'Medium';
      case RiskTier.high:
        return 'High';
    }
  }

  static RiskTier fromString(String value) {
    switch (value.toLowerCase()) {
      case 'low':
        return RiskTier.low;
      case 'medium':
        return RiskTier.medium;
      case 'high':
        return RiskTier.high;
      default:
        return RiskTier.medium;
    }
  }
}
