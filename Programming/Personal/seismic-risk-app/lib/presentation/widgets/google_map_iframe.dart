import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

class GoogleMapIframe extends StatefulWidget {
  final double latitude;
  final double longitude;
  final double zoom;

  const GoogleMapIframe({
    super.key,
    required this.latitude,
    required this.longitude,
    this.zoom = 18,
  });

  @override
  State<GoogleMapIframe> createState() => _GoogleMapIframeState();
}

class _GoogleMapIframeState extends State<GoogleMapIframe> {
  String? _iframeId;

  @override
  void initState() {
    super.initState();
    _iframeId = 'google-map-${widget.latitude}-${widget.longitude}-${DateTime.now().millisecondsSinceEpoch}';
    _registerIframe();
  }

  @override
  void didUpdateWidget(GoogleMapIframe oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.latitude != widget.latitude ||
        oldWidget.longitude != widget.longitude) {
      _updateIframe();
    }
  }

  void _registerIframe() {
    // Create iframe element
    final iframe = html.IFrameElement()
      ..src = 'https://www.google.com/maps?q=${widget.latitude},${widget.longitude}&z=${widget.zoom}&output=embed'
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..allowFullscreen = true;

    // Register the platform view
    ui_web.platformViewRegistry.registerViewFactory(
      _iframeId!,
      (int viewId) => iframe,
    );
  }

  void _updateIframe() {
    final iframe = html.window.document
        .getElementById(_iframeId!) as html.IFrameElement?;
    if (iframe != null) {
      iframe.src =
          'https://www.google.com/maps?q=${widget.latitude},${widget.longitude}&z=${widget.zoom}&output=embed';
    }
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _iframeId!);
  }
}

