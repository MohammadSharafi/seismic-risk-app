import 'package:dio/dio.dart';
import 'dart:math' as math;

/// Data source for Turkish earthquake data from multiple APIs
class TurkeySeismicDataSource {
  final Dio _dio;
  
  // Turkey Earthquake API (Kandilli Observatory) - GitHub: Mrjavaci/turkey-earthquake-api
  static const String _turkeyEarthquakeApi = 'https://turkiyeapi.cyclic.app/api/v1/turkey-earthquake';
  
  // Turkey Geographic API for building location data
  static const String _turkeyGeoApi = 'https://turkiyeapi.cyclic.app/api/v1/provinces';

  TurkeySeismicDataSource() : _dio = Dio();

  /// Get recent earthquakes in Turkey from Kandilli Observatory
  /// Returns earthquakes from the last 30 days
  Future<List<Map<String, dynamic>>> getRecentTurkeyEarthquakes({
    int limit = 100,
    double? minMagnitude,
  }) async {
    try {
      final response = await _dio.get(
        _turkeyEarthquakeApi,
        queryParameters: {
          'limit': limit,
          if (minMagnitude != null) 'minMagnitude': minMagnitude,
        },
        options: Options(
          headers: {'Accept': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Handle different response formats
        List<dynamic> earthquakes;
        if (data is Map && data.containsKey('data')) {
          earthquakes = data['data'] as List;
        } else if (data is List) {
          earthquakes = data;
        } else {
          return [];
        }

        return earthquakes.map((e) {
          return {
            'id': e['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
            'properties': {
              'mag': e['magnitude'] ?? e['mag'] ?? 0.0,
              'place': _formatLocation(e),
              'time': _parseDateTime(e['date'] ?? e['time']),
              'title': _formatTitle(e),
              'alert': _getAlertLevel(e['magnitude'] ?? e['mag'] ?? 0.0),
            },
            'geometry': {
              'type': 'Point',
              'coordinates': [
                e['longitude'] ?? e['lng'] ?? 0.0,
                e['latitude'] ?? e['lat'] ?? 0.0,
                e['depth'] ?? e['depthKm'] ?? 0.0,
              ],
            },
          };
        }).toList();
      }
    } catch (e) {
      print('Error fetching Turkey earthquake data: $e');
    }
    return [];
  }

  /// Get earthquake data filtered by province in Turkey
  Future<List<Map<String, dynamic>>> getEarthquakesByProvince({
    required String provinceName,
    int days = 30,
    double? minMagnitude,
  }) async {
    try {
      final allEarthquakes = await getRecentTurkeyEarthquakes(
        limit: 500,
        minMagnitude: minMagnitude,
      );

      // Filter by province name in location
      return allEarthquakes.where((eq) {
        final place = eq['properties']?['place']?.toString().toLowerCase() ?? '';
        return place.contains(provinceName.toLowerCase());
      }).toList();
    } catch (e) {
      print('Error filtering earthquakes by province: $e');
      return [];
    }
  }

  /// Get earthquake data near a location in Turkey
  Future<List<Map<String, dynamic>>> getEarthquakesNearLocation({
    required double latitude,
    required double longitude,
    double radiusKm = 50,
    int days = 30,
    double? minMagnitude,
  }) async {
    try {
      final allEarthquakes = await getRecentTurkeyEarthquakes(
        limit: 500,
        minMagnitude: minMagnitude,
      );

      // Filter by distance
      return allEarthquakes.where((eq) {
        final geometry = eq['geometry'];
        if (geometry == null) return false;

        final coords = geometry['coordinates'] as List?;
        if (coords == null || coords.length < 2) return false;

        final eqLng = (coords[0] as num).toDouble();
        final eqLat = (coords[1] as num).toDouble();

        final distance = _calculateDistance(latitude, longitude, eqLat, eqLng);
        return distance <= radiusKm;
      }).toList();
    } catch (e) {
      print('Error getting earthquakes near location: $e');
      return [];
    }
  }

  /// Get Turkish provinces data for building location context
  Future<List<Map<String, dynamic>>> getTurkeyProvinces() async {
    try {
      final response = await _dio.get(
        _turkeyGeoApi,
        options: Options(
          headers: {'Accept': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data.containsKey('data')) {
          return List<Map<String, dynamic>>.from(data['data']);
        } else if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
      }
    } catch (e) {
      print('Error fetching Turkey provinces: $e');
    }
    return [];
  }

  /// Get districts for a province
  Future<List<Map<String, dynamic>>> getDistrictsByProvince(String provinceName) async {
    try {
      final provinces = await getTurkeyProvinces();
      final province = provinces.firstWhere(
        (p) => (p['name']?.toString().toLowerCase() ?? '') == provinceName.toLowerCase(),
        orElse: () => <String, dynamic>{},
      );

      if (province.containsKey('districts')) {
        return List<Map<String, dynamic>>.from(province['districts']);
      }
    } catch (e) {
      print('Error fetching districts: $e');
    }
    return [];
  }

  /// Calculate distance between two coordinates in kilometers
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth radius in kilometers

    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final sinDLat = math.sin(dLat / 2);
    final sinDLon = math.sin(dLon / 2);
    
    final a = sinDLat * sinDLat +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            sinDLon *
            sinDLon;

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  String _formatLocation(Map<String, dynamic> earthquake) {
    final city = earthquake['city'] ?? earthquake['location'];
    final district = earthquake['district'];
    final province = earthquake['province'];
    
    if (city != null) {
      if (district != null && province != null) {
        return '$city, $district, $province, Turkey';
      } else if (province != null) {
        return '$city, $province, Turkey';
      }
      return '$city, Turkey';
    }
    
    final lat = earthquake['latitude'] ?? earthquake['lat'];
    final lng = earthquake['longitude'] ?? earthquake['lng'];
    if (lat != null && lng != null) {
      return '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
    }
    
    return 'Turkey';
  }

  String _formatTitle(Map<String, dynamic> earthquake) {
    final mag = earthquake['magnitude'] ?? earthquake['mag'] ?? 0.0;
    final location = _formatLocation(earthquake);
    return 'M ${mag.toStringAsFixed(1)} - $location';
  }

  int _parseDateTime(dynamic dateTime) {
    if (dateTime == null) return DateTime.now().millisecondsSinceEpoch;
    
    if (dateTime is int) return dateTime;
    if (dateTime is String) {
      try {
        return DateTime.parse(dateTime).millisecondsSinceEpoch;
      } catch (e) {
        return DateTime.now().millisecondsSinceEpoch;
      }
    }
    
    return DateTime.now().millisecondsSinceEpoch;
  }

  String? _getAlertLevel(double magnitude) {
    if (magnitude >= 6.0) return 'red';
    if (magnitude >= 5.0) return 'orange';
    if (magnitude >= 4.0) return 'yellow';
    return 'green';
  }

  /// Get seismic risk summary for a location in Turkey
  Future<Map<String, dynamic>> getSeismicRiskSummary({
    required double latitude,
    required double longitude,
    int days = 365,
  }) async {
    try {
      final earthquakes = await getEarthquakesNearLocation(
        latitude: latitude,
        longitude: longitude,
        radiusKm: 100,
        days: days,
      );

      if (earthquakes.isEmpty) {
        return {
          'riskLevel': 'low',
          'totalEarthquakes': 0,
          'maxMagnitude': 0.0,
          'lastEarthquakeDate': null,
          'message': 'No significant seismic activity in the area',
        };
      }

      final magnitudes = earthquakes
          .map((e) => (e['properties']?['mag'] as num?)?.toDouble() ?? 0.0)
          .where((m) => m > 0)
          .toList();

      final maxMagnitude = magnitudes.isNotEmpty ? magnitudes.reduce((a, b) => a > b ? a : b) : 0.0;
      final avgMagnitude = magnitudes.isNotEmpty 
          ? magnitudes.reduce((a, b) => a + b) / magnitudes.length 
          : 0.0;

      // Sort by time (most recent first)
      earthquakes.sort((a, b) {
        final timeA = a['properties']?['time'] as int? ?? 0;
        final timeB = b['properties']?['time'] as int? ?? 0;
        return timeB.compareTo(timeA);
      });

      final lastEarthquake = earthquakes.isNotEmpty ? earthquakes.first : null;
      final lastEarthquakeDate = lastEarthquake?['properties']?['time'] as int?;

      String riskLevel;
      if (maxMagnitude >= 6.0 || earthquakes.length > 50) {
        riskLevel = 'high';
      } else if (maxMagnitude >= 5.0 || earthquakes.length > 20) {
        riskLevel = 'medium';
      } else {
        riskLevel = 'low';
      }

      return {
        'riskLevel': riskLevel,
        'totalEarthquakes': earthquakes.length,
        'maxMagnitude': maxMagnitude,
        'avgMagnitude': avgMagnitude,
        'lastEarthquakeDate': lastEarthquakeDate,
        'lastEarthquakeMagnitude': lastEarthquake?['properties']?['mag'],
      };
    } catch (e) {
      print('Error getting seismic risk summary: $e');
      return {
        'riskLevel': 'unknown',
        'totalEarthquakes': 0,
        'maxMagnitude': 0.0,
        'lastEarthquakeDate': null,
        'error': e.toString(),
      };
    }
  }
}

