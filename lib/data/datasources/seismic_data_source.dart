import 'package:dio/dio.dart';
import 'turkey_seismic_data_source.dart';

class SeismicDataSource {
  final Dio _dio;
  final TurkeySeismicDataSource _turkeyDataSource;

  static const String _baseUrl = 'https://earthquake.usgs.gov/fdsnws/event/1';

  SeismicDataSource() 
      : _dio = Dio(),
        _turkeyDataSource = TurkeySeismicDataSource();

  /// Get recent earthquakes near a location
  /// Returns earthquakes from the last 30 days within radius (in km) of lat/lng
  /// For Turkey, prioritizes Turkish data sources
  Future<List<Map<String, dynamic>>> getRecentEarthquakes({
    required double latitude,
    required double longitude,
    double radiusKm = 500,
    int limit = 100,
    double minMagnitude = 3.0,
    bool preferTurkey = true,
  }) async {
    // Check if location is in Turkey (rough bounds)
    final isInTurkey = latitude >= 35.0 && latitude <= 43.0 && 
                       longitude >= 25.0 && longitude <= 45.0;

    // Try Turkish API first if in Turkey
    if (isInTurkey && preferTurkey) {
      try {
        final turkeyEarthquakes = await _turkeyDataSource.getEarthquakesNearLocation(
          latitude: latitude,
          longitude: longitude,
          radiusKm: radiusKm,
          days: 30,
          minMagnitude: minMagnitude,
        );
        
        if (turkeyEarthquakes.isNotEmpty) {
          return turkeyEarthquakes.take(limit).toList();
        }
      } catch (e) {
        print('Turkish API failed, falling back to USGS: $e');
      }
    }

    // Fallback to USGS
    try {
      final response = await _dio.get(
        '$_baseUrl/query',
        queryParameters: {
          'format': 'geojson',
          'latitude': latitude,
          'longitude': longitude,
          'maxradiuskm': radiusKm,
          'limit': limit,
          'minmagnitude': minMagnitude,
          'orderby': 'time',
        },
      );

      if (response.data['features'] != null) {
        return List<Map<String, dynamic>>.from(response.data['features']);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get significant earthquakes in Turkey (prioritizes Turkish data sources)
  /// Falls back to USGS if Turkish API fails
  Future<List<Map<String, dynamic>>> getSignificantEarthquakes({
    int limit = 50,
    bool preferTurkey = true,
  }) async {
    // Try Turkish API first
    if (preferTurkey) {
      try {
        final turkeyEarthquakes = await _turkeyDataSource.getRecentTurkeyEarthquakes(
          limit: limit,
          minMagnitude: 4.0,
        );
        
        if (turkeyEarthquakes.isNotEmpty) {
          return turkeyEarthquakes;
        }
      } catch (e) {
        print('Turkish API failed, falling back to USGS: $e');
      }
    }

    // Fallback to USGS with Turkey region filter
    try {
      final response = await _dio.get(
        '$_baseUrl/query',
        queryParameters: {
          'format': 'geojson',
          'minmagnitude': 4.5,
          'limit': limit,
          'orderby': 'magnitude',
          'minlatitude': 35.0,
          'maxlatitude': 43.0,
          'minlongitude': 25.0,
          'maxlongitude': 45.0,
        },
      );

      if (response.data['features'] != null) {
        return List<Map<String, dynamic>>.from(response.data['features']);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get earthquake history for a location
  /// For Turkey, uses Turkish data sources when possible
  Future<List<Map<String, dynamic>>> getEarthquakeHistory({
    required double latitude,
    required double longitude,
    double radiusKm = 100,
    int daysBack = 365,
    bool preferTurkey = true,
  }) async {
    // Check if location is in Turkey
    final isInTurkey = latitude >= 35.0 && latitude <= 43.0 && 
                       longitude >= 25.0 && longitude <= 45.0;

    // Try Turkish API first if in Turkey
    if (isInTurkey && preferTurkey) {
      try {
        final turkeyEarthquakes = await _turkeyDataSource.getEarthquakesNearLocation(
          latitude: latitude,
          longitude: longitude,
          radiusKm: radiusKm,
          days: daysBack,
        );
        
        if (turkeyEarthquakes.isNotEmpty) {
          return turkeyEarthquakes;
        }
      } catch (e) {
        print('Turkish API failed, falling back to USGS: $e');
      }
    }

    // Fallback to USGS
    try {
      final endTime = DateTime.now().toUtc().toIso8601String();
      final startTime =
          DateTime.now().subtract(Duration(days: daysBack)).toUtc().toIso8601String();

      final response = await _dio.get(
        '$_baseUrl/query',
        queryParameters: {
          'format': 'geojson',
          'latitude': latitude,
          'longitude': longitude,
          'maxradiuskm': radiusKm,
          'starttime': startTime,
          'endtime': endTime,
          'orderby': 'time',
          'limit': 1000,
        },
      );

      if (response.data['features'] != null) {
        return List<Map<String, dynamic>>.from(response.data['features']);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get seismic risk statistics for a region
  /// For Turkey, uses Turkish data sources for better accuracy
  Future<Map<String, dynamic>> getSeismicRiskStats({
    required double latitude,
    required double longitude,
    double radiusKm = 100,
    bool preferTurkey = true,
  }) async {
    // Check if location is in Turkey
    final isInTurkey = latitude >= 35.0 && latitude <= 43.0 && 
                       longitude >= 25.0 && longitude <= 45.0;

    // Try Turkish API first if in Turkey
    if (isInTurkey && preferTurkey) {
      try {
        final riskSummary = await _turkeyDataSource.getSeismicRiskSummary(
          latitude: latitude,
          longitude: longitude,
          days: 365,
        );
        
        if (riskSummary.containsKey('error') == false) {
          // Convert to match expected format
          return {
            'totalCount': riskSummary['totalEarthquakes'] ?? 0,
            'averageMagnitude': riskSummary['avgMagnitude'] ?? 0.0,
            'maxMagnitude': riskSummary['maxMagnitude'] ?? 0.0,
            'lastEarthquakeDate': riskSummary['lastEarthquakeDate'],
            'riskLevel': (riskSummary['riskLevel'] as String?)?.toUpperCase() ?? 'UNKNOWN',
          };
        }
      } catch (e) {
        print('Turkish risk summary failed, using USGS: $e');
      }
    }

    // Fallback to USGS
    try {
      final earthquakes = await getEarthquakeHistory(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
        daysBack: 365,
        preferTurkey: false,
      );

      if (earthquakes.isEmpty) {
        return {
          'totalCount': 0,
          'averageMagnitude': 0.0,
          'maxMagnitude': 0.0,
          'lastEarthquakeDate': null,
          'riskLevel': 'LOW',
        };
      }

      final magnitudes = earthquakes
          .map((e) =>
              (e['properties']?['mag'] as num?)?.toDouble() ?? 0.0)
          .where((m) => m > 0)
          .toList();

      final avgMagnitude = magnitudes.isEmpty
          ? 0.0
          : magnitudes.reduce((a, b) => a + b) / magnitudes.length;

      final maxMagnitude = magnitudes.isEmpty ? 0.0 : magnitudes.reduce((a, b) => a > b ? a : b);

      // Get most recent earthquake
      final sorted = List<Map<String, dynamic>>.from(earthquakes);
      sorted.sort((a, b) {
        final timeA = a['properties']?['time'] as int? ?? 0;
        final timeB = b['properties']?['time'] as int? ?? 0;
        return timeB.compareTo(timeA);
      });
      final lastEarthquake = sorted.isNotEmpty ? sorted.first : null;

      // Determine risk level
      String riskLevel = 'LOW';
      if (maxMagnitude >= 6.0 || earthquakes.length > 50) {
        riskLevel = 'HIGH';
      } else if (maxMagnitude >= 5.0 || earthquakes.length > 20) {
        riskLevel = 'MODERATE';
      }

      return {
        'totalCount': earthquakes.length,
        'averageMagnitude': avgMagnitude,
        'maxMagnitude': maxMagnitude,
        'lastEarthquakeDate': lastEarthquake?['properties']?['time'],
        'riskLevel': riskLevel,
      };
    } catch (e) {
      return {
        'totalCount': 0,
        'averageMagnitude': 0.0,
        'maxMagnitude': 0.0,
        'lastEarthquakeDate': null,
        'riskLevel': 'UNKNOWN',
      };
    }
  }
}
