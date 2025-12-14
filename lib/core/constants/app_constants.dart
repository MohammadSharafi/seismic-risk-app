class AppConstants {
  // API Configuration
  static const String baseUrl = 'http://localhost:8080/api/v1';
  static const String mlServiceUrl = 'http://localhost:8000';
  
  // Turkey-specific bounds
  static const double turkeyMinLat = 35.8;
  static const double turkeyMaxLat = 42.1;
  static const double turkeyMinLng = 25.7;
  static const double turkeyMaxLng = 44.8;
  
  // Risk thresholds
  static const double lowRiskThreshold = 0.2;
  static const double mediumRiskThreshold = 0.5;
  static const double highRiskThreshold = 0.8;
  
  // Validation
  static const int minFloors = 1;
  static const int maxFloors = 50;
  
  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration predictionTimeout = Duration(seconds: 5);
}

