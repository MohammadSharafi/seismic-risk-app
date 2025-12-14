import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

enum MapStyle {
  street,
  satellite,
  terrain,
}

/// Enhanced map widget with multiple view options
class SimpleMap extends StatefulWidget {
  final double latitude;
  final double longitude;
  final Function(double latitude, double longitude)? onLocationSelected;

  const SimpleMap({
    super.key,
    required this.latitude,
    required this.longitude,
    this.onLocationSelected,
  });

  @override
  State<SimpleMap> createState() => _SimpleMapState();
}

class _SimpleMapState extends State<SimpleMap> {
  late MapController _mapController;
  late LatLng _selectedLocation;
  Marker? _marker;
  CircleMarker? _circle;
  MapStyle _currentStyle = MapStyle.street;
  final double _circleRadius = 50.0; // meters

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _selectedLocation = LatLng(widget.latitude, widget.longitude);
    _updateMarkerAndCircle();
  }

  @override
  void didUpdateWidget(SimpleMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.latitude != widget.latitude ||
        oldWidget.longitude != widget.longitude) {
      _selectedLocation = LatLng(widget.latitude, widget.longitude);
      _updateMarkerAndCircle();
      _mapController.move(_selectedLocation, _mapController.camera.zoom);
    }
  }

  void _updateMarkerAndCircle() {
    // Enhanced marker with building icon
    _marker = Marker(
      point: _selectedLocation,
      width: 60,
      height: 60,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.4),
              blurRadius: 15,
              spreadRadius: 3,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer ring
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.red,
                  width: 3,
                ),
              ),
            ),
            // Inner icon
            const Icon(
              Icons.business,
              color: Colors.red,
              size: 32,
            ),
          ],
        ),
      ),
    );

    // Circle around building
    _circle = CircleMarker(
      point: _selectedLocation,
      radius: _circleRadius,
      color: Colors.red.withOpacity(0.15),
      borderColor: Colors.red.withOpacity(0.6),
      borderStrokeWidth: 2.5,
    );
  }

  void _onMapTap(TapPosition position, LatLng point) {
    setState(() {
      _selectedLocation = point;
      _updateMarkerAndCircle();
    });
    widget.onLocationSelected?.call(point.latitude, point.longitude);
  }

  String _getTileUrl() {
    switch (_currentStyle) {
      case MapStyle.satellite:
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
      case MapStyle.terrain:
        return 'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png';
      case MapStyle.street:
        return 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
    }
  }

  List<String> _getSubdomains() {
    switch (_currentStyle) {
      case MapStyle.satellite:
      case MapStyle.terrain:
      case MapStyle.street:
        return const ['a', 'b', 'c'];
    }
  }

  void _zoomIn() {
    _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1);
  }

  void _zoomOut() {
    _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1);
  }

  void _changeMapStyle(MapStyle style) {
    setState(() {
      _currentStyle = style;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Map
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _selectedLocation,
            initialZoom: 18.0,
            onTap: _onMapTap,
            minZoom: 10.0,
            maxZoom: 19.0,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: _getTileUrl(),
              subdomains: _getSubdomains(),
              userAgentPackageName: 'com.seismicrisk.app',
              maxZoom: 19,
            ),
            // Circle layer
            if (_circle != null)
              CircleLayer(
                circles: [_circle!],
              ),
            // Marker layer
            MarkerLayer(
              markers: _marker != null ? [_marker!] : [],
            ),
          ],
        ),
        
        // Map style selector
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStyleButton(
                  icon: Icons.map,
                  label: 'Street',
                  style: MapStyle.street,
                  isActive: _currentStyle == MapStyle.street,
                ),
                const Divider(height: 1),
                _buildStyleButton(
                  icon: Icons.satellite,
                  label: 'Satellite',
                  style: MapStyle.satellite,
                  isActive: _currentStyle == MapStyle.satellite,
                ),
                const Divider(height: 1),
                _buildStyleButton(
                  icon: Icons.terrain,
                  label: 'Terrain',
                  style: MapStyle.terrain,
                  isActive: _currentStyle == MapStyle.terrain,
                ),
              ],
            ),
          ),
        ),
        
        // Zoom controls
        Positioned(
          bottom: 120,
          right: 16,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _zoomIn,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: const Icon(Icons.add, size: 24),
                    ),
                  ),
                ),
                const Divider(height: 1),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _zoomOut,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: const Icon(Icons.remove, size: 24),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStyleButton({
    required IconData icon,
    required String label,
    required MapStyle style,
    required bool isActive,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _changeMapStyle(style),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: isActive ? Colors.blue.shade50 : Colors.transparent,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isActive ? Colors.blue.shade700 : Colors.grey.shade700,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color: isActive ? Colors.blue.shade700 : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
