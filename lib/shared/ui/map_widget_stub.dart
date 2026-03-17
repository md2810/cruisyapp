// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

/// Stub MapWidget for web platform since Mapbox doesn't support web
class MapWidget extends StatefulWidget {
  final Function(dynamic)? onMapCreated;
  final String? styleUri;
  final dynamic cameraOptions;
  final Function(dynamic)? onStyleLoadedListener;
  final Function(dynamic)? onMapLoadErrorListener;

  const MapWidget({
    super.key,
    this.onMapCreated,
    this.styleUri,
    this.cameraOptions,
    this.onStyleLoadedListener,
    this.onMapLoadErrorListener,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  @override
  void initState() {
    super.initState();
    // Call onMapCreated with a stub map instance
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onMapCreated?.call(MapboxMap());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0a1929),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.map_outlined,
              size: 64,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Map Preview',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Interactive map available on mobile app',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Stub classes for web
class MapboxMap {
  void setCamera(dynamic options) {}
  void flyTo(dynamic cameraOptions, [dynamic animationOptions]) {}
  dynamic get style => _StyleStub();
  dynamic get scaleBar => _ScaleBarStub();
  dynamic get logo => _LogoStub();
  dynamic get attribution => _AttributionStub();
  dynamic get annotations => _AnnotationsStub();
}

class _StyleStub {
  void setProjection(dynamic projection) {}
}

class _ScaleBarStub {
  void updateSettings(dynamic settings) {}
}

class _LogoStub {
  void updateSettings(dynamic settings) {}
}

class _AttributionStub {
  void updateSettings(dynamic settings) {}
}

class _AnnotationsStub {
  Future<PolylineAnnotationManager> createPolylineAnnotationManager() async {
    return PolylineAnnotationManager();
  }
  Future<CircleAnnotationManager> createCircleAnnotationManager() async {
    return CircleAnnotationManager();
  }
}

class MapboxStyles {
  static const String DARK = 'mapbox://styles/mapbox/dark-v11';
  static const String LIGHT = 'mapbox://styles/mapbox/light-v11';
  static const String SATELLITE = 'mapbox://styles/mapbox/satellite-v9';
  static const String STREETS = 'mapbox://styles/mapbox/streets-v12';
}

class CameraOptions {
  final dynamic center;
  final double? zoom;
  final double? pitch;
  final double? bearing;

  const CameraOptions({this.center, this.zoom, this.pitch, this.bearing});
}

class Point {
  final dynamic coordinates;
  const Point({this.coordinates});
}

class Position {
  final double lat;
  final double lng;
  Position(this.lng, this.lat);

  @override
  String toString() => 'Position($lng, $lat)';
}

class ScaleBarSettings {
  final bool enabled;
  final dynamic position;
  ScaleBarSettings({this.enabled = true, this.position});
}

class LogoSettings {
  final bool enabled;
  final dynamic position;
  final double? marginLeft;
  final double? marginTop;
  LogoSettings({this.enabled = true, this.position, this.marginLeft, this.marginTop});
}

class AttributionSettings {
  final bool enabled;
  final dynamic position;
  final double? marginLeft;
  final double? marginTop;
  AttributionSettings({this.enabled = true, this.position, this.marginLeft, this.marginTop});
}

class StyleProjection {
  final dynamic name;
  StyleProjection({this.name});
}

class StyleProjectionName {
  static const globe = 'globe';
  static const mercator = 'mercator';
}

class MapAnimationOptions {
  final int? duration;
  MapAnimationOptions({this.duration});
}

class PolylineAnnotationManager {
  void deleteAll() {}
  Future<void> create(dynamic options) async {}
}

class CircleAnnotationManager {
  void deleteAll() {}
  Future<void> create(dynamic options) async {}
}

class PolylineAnnotationOptions {
  final dynamic geometry;
  final int? lineColor;
  final double? lineWidth;
  final double? lineOpacity;
  PolylineAnnotationOptions({this.geometry, this.lineColor, this.lineWidth, this.lineOpacity});
}

class CircleAnnotationOptions {
  final dynamic geometry;
  final int? circleColor;
  final double? circleRadius;
  final int? circleStrokeColor;
  final double? circleStrokeWidth;
  final double? circleOpacity;
  CircleAnnotationOptions({
    this.geometry,
    this.circleColor,
    this.circleRadius,
    this.circleStrokeColor,
    this.circleStrokeWidth,
    this.circleOpacity,
  });
}

class LineString {
  final List<dynamic> coordinates;
  LineString({required this.coordinates});
}

class OrnamentPosition {
  static const TOP_LEFT = 'top-left';
  static const TOP_RIGHT = 'top-right';
  static const BOTTOM_LEFT = 'bottom-left';
  static const BOTTOM_RIGHT = 'bottom-right';
}

// Stub event classes
class StyleLoadedEventData {}
class MapLoadingErrorEventData {
  final String message;
  MapLoadingErrorEventData({this.message = ''});
}
