import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:seismic_risk_app/core/theme/app_theme.dart';
import 'package:seismic_risk_app/presentation/providers/building_provider.dart';
import 'package:seismic_risk_app/presentation/screens/address_confirmation_screen.dart';
import 'package:seismic_risk_app/presentation/widgets/simple_map.dart';
import 'package:seismic_risk_app/presentation/widgets/responsive/app_button.dart';

// Simple LatLng class for coordinates
class LatLng {
  final double latitude;
  final double longitude;
  LatLng(this.latitude, this.longitude);
}

class LocationScreen extends ConsumerStatefulWidget {
  final VoidCallback? onComplete;
  
  const LocationScreen({super.key, this.onComplete});

  @override
  ConsumerState<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends ConsumerState<LocationScreen> {
  LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    if (kIsWeb) {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
        );
        setState(() {
          _selectedLocation = LatLng(position.latitude, position.longitude);
        });
      } catch (e) {
        // Default to Istanbul, Turkey for web demo
        setState(() {
          _selectedLocation = LatLng(41.0082, 28.9784);
        });
      }
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      // Permission denied - user can still select location manually
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      // Failed to get location - user can still select manually
    }
  }

  Future<void> _continueToAddress() async {
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location on the map')),
      );
      return;
    }

    try {
      await ref.read(buildingProvider.notifier).createBuilding(
            latitude: _selectedLocation!.latitude,
            longitude: _selectedLocation!.longitude,
          );

      if (mounted) {
        if (widget.onComplete != null) {
          widget.onComplete!();
        } else {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const AddressConfirmationScreen(),
          ),
        );
        }
      }
    } catch (e) {
      // Handle network errors gracefully - allow offline mode
      final errorMessage = e.toString();
      final isNetworkError = errorMessage.contains('DioException') ||
          errorMessage.contains('connection') ||
          errorMessage.contains('network') ||
          errorMessage.contains('XMLHttpRequest');

      if (mounted) {
        if (isNetworkError) {
          // Show a friendly message but allow navigation in offline mode
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.wifi_off, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Backend unavailable. Continuing in offline mode...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );

          // Still navigate - location is stored in state
          // The app can work offline with local state
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            if (widget.onComplete != null) {
              widget.onComplete!();
            } else {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const AddressConfirmationScreen(),
              ),
            );
            }
          }
        } else {
          // Other errors - show and don't navigate
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${errorMessage.length > 100 ? errorMessage.substring(0, 100) + "..." : errorMessage}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Building Location'),
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          Tooltip(
            message: 'Use Current Location',
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.my_location_rounded, size: 20),
              ),
              onPressed: _requestLocationPermission,
            ),
          ),
        ],
      ),
      body: _buildMapView(),
    );
  }

  Widget _buildMapView() {
    final isInWizard = widget.onComplete != null;
    
    return Stack(
      children: [
        // Full screen map - takes all available space
        SizedBox.expand(
          child: _buildMapWidget(),
        ),
        
        // Only show bottom sheet if NOT in wizard (wizard has its own navigation)
        if (!isInWizard)
          Positioned(
          bottom: 0,
          left: 0,
          right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
                ),
                boxShadow: [
                  BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -1),
                  ),
                ],
              ),
              child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Compact location info
                    if (_selectedLocation != null) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: AppTheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                          Text(
                                            '${_selectedLocation!.latitude.toStringAsFixed(6)}',
                                            style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.textPrimary,
                                            ),
                                          ),
                                          Text(
                                            '${_selectedLocation!.longitude.toStringAsFixed(6)}',
                                            style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.textPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                    ] else ...[
                      Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                            size: 18,
                            color: AppTheme.textSecondary,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                              'Tap on the map to select your building location',
                                          style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                    
                    // Single Continue button
                    AppButton(
                      label: _selectedLocation != null ? 'Continue' : 'Select Location',
                      icon: _selectedLocation != null ? Icons.arrow_forward : Icons.location_on,
                      onPressed: _selectedLocation != null ? _continueToAddress : null,
                      variant: AppButtonVariant.primary,
                      fullWidth: true,
                      size: AppButtonSize.medium,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMapWidget() {
    final lat = _selectedLocation?.latitude ?? 41.0082;
    final lng = _selectedLocation?.longitude ?? 28.9784;
    
    return SimpleMap(
      latitude: lat,
      longitude: lng,
      onLocationSelected: (newLat, newLng) {
        setState(() {
          _selectedLocation = LatLng(newLat, newLng);
        });
      },
    );
  }
}
