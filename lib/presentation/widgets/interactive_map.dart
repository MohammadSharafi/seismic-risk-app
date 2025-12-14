import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

class InteractiveMap extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final Function(double latitude, double longitude)? onLocationSelected;

  const InteractiveMap({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    this.onLocationSelected,
  });

  @override
  State<InteractiveMap> createState() => _InteractiveMapState();
}

class _InteractiveMapState extends State<InteractiveMap> {
  String? _mapId;
  bool _mapLoaded = false;
  String? _error;
  static int _instanceCount = 0;

  @override
  void initState() {
    super.initState();
    _instanceCount++;
    _mapId = 'interactive-map-$_instanceCount';
    _loadGoogleMaps();
  }

  void _loadGoogleMaps() {
    // Use a unique callback name for this instance
    final callbackName = 'initMap_$_instanceCount';
    
    // Check if Google Maps API is already loaded
    final existingScript = html.window.document.querySelector('script[src*="maps.googleapis.com"]');
    
    if (existingScript != null) {
      // Wait a bit for API to be ready
      Future.delayed(const Duration(milliseconds: 500), () {
        if (js.context.hasProperty('google')) {
          _initializeMap();
        } else {
          setState(() {
            _error = 'Google Maps API failed to load. Using alternative map.';
            _mapLoaded = false;
          });
        }
      });
      return;
    }

    // Set up global callback using js.context
    js.context[callbackName] = js.allowInterop(() {
      _initializeMap();
    });

    // Load Google Maps JavaScript API
    final script = html.ScriptElement()
      ..src = 'https://maps.googleapis.com/maps/api/js?key=AIzaSyBFw0Qbyq9zTFTd-tUY6d-s6U4qZZj5Tyk&callback=$callbackName'
      ..async = true
      ..onError.listen((_) {
        setState(() {
          _error = 'Failed to load Google Maps API. Please check your API key.';
          _mapLoaded = false;
        });
      });

    html.window.document.querySelector('head')?.append(script);
  }

  void _initializeMap() {
    try {
      final lat = widget.initialLatitude ?? 41.0082; // Istanbul default
      final lng = widget.initialLongitude ?? 28.9784;

      // Create map container
      final container = html.DivElement()
        ..id = _mapId!
        ..style.width = '100%'
        ..style.height = '100%';

      // Check if Google Maps is available
      if (!js.context.hasProperty('google') ||
          !js.context['google'].hasProperty('maps') ||
          !js.context['google']['maps'].hasProperty('Map')) {
        throw Exception('Google Maps API not loaded');
      }

      // Create map options
      final mapOptions = js.JsObject.jsify({
        'center': {'lat': lat, 'lng': lng},
        'zoom': 18,
        'mapTypeId': 'roadmap',
        'fullscreenControl': true,
        'zoomControl': true,
        'streetViewControl': false,
      });

      // Create map
      final map = js.JsObject(
        js.context['google']['maps']['Map'],
        [container, mapOptions],
      );

      // Create marker
      final markerOptions = js.JsObject.jsify({
        'position': {'lat': lat, 'lng': lng},
        'map': map,
        'draggable': true,
        'title': 'Your Building Location',
        'animation': js.context['google']['maps']['Animation']['DROP'],
      });

      final marker = js.JsObject(
        js.context['google']['maps']['Marker'],
        [markerOptions],
      );

      // Handle map clicks
      map.callMethod('addListener', [
        'click',
        js.allowInterop((event) {
          try {
            final latLng = event['latLng'];
            final lat = latLng.callMethod('lat', []) as double;
            final lng = latLng.callMethod('lng', []) as double;
            
            // Update marker position
            marker.callMethod('setPosition', [
              js.JsObject.jsify({'lat': lat, 'lng': lng}),
            ]);

            // Notify callback
            widget.onLocationSelected?.call(lat, lng);
          } catch (e) {
            print('Error handling map click: $e');
          }
        }),
      ]);

      // Handle marker drag
      marker.callMethod('addListener', [
        'dragend',
        js.allowInterop((event) {
          try {
            final position = marker.callMethod('getPosition', []);
            final lat = position.callMethod('lat', []) as double;
            final lng = position.callMethod('lng', []) as double;
            widget.onLocationSelected?.call(lat, lng);
          } catch (e) {
            print('Error handling marker drag: $e');
          }
        }),
      ]);

      // Register platform view
      ui_web.platformViewRegistry.registerViewFactory(
        _mapId!,
        (int viewId) => container,
      );

      setState(() {
        _mapLoaded = true;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = 'Error initializing map: $e';
        _mapLoaded = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _error = null;
                  _mapLoaded = false;
                });
                _loadGoogleMaps();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (!_mapLoaded) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading map...'),
          ],
        ),
      );
    }

    return HtmlElementView(viewType: _mapId!);
  }
}
