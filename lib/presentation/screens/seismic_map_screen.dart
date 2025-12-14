import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seismic_risk_app/data/datasources/seismic_data_source.dart';
import 'package:seismic_risk_app/presentation/widgets/responsive/app_card.dart';
import 'package:seismic_risk_app/presentation/widgets/responsive/responsive_layout.dart';

final seismicDataSourceProvider =
    Provider<SeismicDataSource>((ref) => SeismicDataSource());

class SeismicMapScreen extends ConsumerStatefulWidget {
  const SeismicMapScreen({super.key});

  @override
  ConsumerState<SeismicMapScreen> createState() => _SeismicMapScreenState();
}

class _SeismicMapScreenState extends ConsumerState<SeismicMapScreen> {
  List<Map<String, dynamic>> _earthquakes = [];
  bool _isLoading = true;
  Map<String, dynamic>? _selectedEarthquake;

  @override
  void initState() {
    super.initState();
    _loadEarthquakes();
  }

  Future<void> _loadEarthquakes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final dataSource = ref.read(seismicDataSourceProvider);
      final earthquakes = await dataSource.getSignificantEarthquakes(limit: 100);
      
      setState(() {
        _earthquakes = earthquakes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seismic Activity Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEarthquakes,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                if (!isMobile)
                  Expanded(
                    flex: 1,
                    child: Container(
                      color: const Color(0xFFF5F7FA),
                      child: _buildEarthquakeList(context, false),
                    ),
                  ),
                Expanded(
                  flex: isMobile ? 1 : 2,
                  child: Column(
                    children: [
                      if (isMobile)
                        Container(
                          height: 300,
                          color: const Color(0xFFF5F7FA),
                          child: _buildEarthquakeList(context, true),
                        ),
                      Expanded(
                        child: _buildMapView(context),
                      ),
                      if (_selectedEarthquake != null)
                        _buildEarthquakeDetails(context, isMobile),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildMapView(BuildContext context) {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Interactive Map View',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_earthquakes.length} earthquakes displayed',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'This view shows recent significant earthquakes from USGS data. '
                'Click on an earthquake from the list to see details.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarthquakeList(BuildContext context, bool isMobile) {
    if (_earthquakes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'No earthquakes found',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      itemCount: _earthquakes.length,
      itemBuilder: (context, index) {
        final earthquake = _earthquakes[index];
        final properties = earthquake['properties'] as Map<String, dynamic>? ?? {};
        final magnitude = (properties['mag'] as num?)?.toDouble() ?? 0.0;
        final place = properties['place'] as String? ?? 'Unknown location';
        final time = properties['time'] as int?;
        final date = time != null
            ? DateTime.fromMillisecondsSinceEpoch(time)
            : DateTime.now();

        return AppCard(
          margin: EdgeInsets.only(bottom: isMobile ? 12 : 16),
          onTap: () {
            setState(() {
              _selectedEarthquake = earthquake;
            });
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _getMagnitudeColor(magnitude).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        magnitude.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _getMagnitudeColor(magnitude),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(date),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEarthquakeDetails(BuildContext context, bool isMobile) {
    if (_selectedEarthquake == null) return const SizedBox.shrink();

    final properties =
        _selectedEarthquake!['properties'] as Map<String, dynamic>? ?? {};
    final magnitude = (properties['mag'] as num?)?.toDouble() ?? 0.0;
    final place = properties['place'] as String? ?? 'Unknown location';
    final time = properties['time'] as int?;
    final date = time != null
        ? DateTime.fromMillisecondsSinceEpoch(time)
        : DateTime.now();
    final depth = properties['depth'] as num?;
    final geometry = _selectedEarthquake!['geometry'] as Map<String, dynamic>?;
    final coordinates = geometry?['coordinates'] as List?;
    final latitude = coordinates != null && coordinates.length > 1
        ? (coordinates[1] as num?)?.toDouble()
        : null;
    final longitude = coordinates != null && coordinates.length > 0
        ? (coordinates[0] as num?)?.toDouble()
        : null;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Earthquake Details',
                style: TextStyle(
                  fontSize: isMobile ? 18 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _selectedEarthquake = null;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Magnitude', magnitude.toStringAsFixed(1),
              _getMagnitudeColor(magnitude)),
          if (latitude != null && longitude != null)
            _buildDetailRow('Location', '$latitude, $longitude', null),
          if (depth != null)
            _buildDetailRow('Depth', '${depth.toStringAsFixed(1)} km', null),
          _buildDetailRow('Time', _formatDate(date), null),
          _buildDetailRow('Place', place, null),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color? valueColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: valueColor ?? Colors.black87,
                fontWeight: valueColor != null ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getMagnitudeColor(double magnitude) {
    if (magnitude >= 7.0) return Colors.red;
    if (magnitude >= 6.0) return Colors.orange;
    if (magnitude >= 5.0) return Colors.amber;
    return Colors.green;
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

