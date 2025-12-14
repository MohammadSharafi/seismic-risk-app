import 'package:flutter/material.dart';
import 'dart:html' as html;

class WebMapWidget extends StatelessWidget {
  final double latitude;
  final double longitude;
  final double? zoom;

  const WebMapWidget({
    super.key,
    required this.latitude,
    required this.longitude,
    this.zoom = 18,
  });

  @override
  Widget build(BuildContext context) {
    // Use Google Maps Embed API
    final mapUrl = 'https://www.google.com/maps/embed/v1/place?'
        'key=AIzaSyBFw0Qbyq9zTFTd-tUY6d-s6U4qZZj5Tyk&'
        'q=$latitude,$longitude&'
        'zoom=$zoom';

    return HtmlElementView(
      viewType: 'google-map',
      onPlatformViewCreated: (int viewId) {
        final iframe = html.IFrameElement()
          ..src = mapUrl
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%';
        
        // Get the container element
        final container = html.window.document.getElementById('google-map-$viewId');
        if (container != null) {
          container.append(iframe);
        }
      },
    );
  }
}

