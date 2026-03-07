import 'package:flutter/material.dart';

/// Stub MapWidget for web platform since Mapbox doesn't support web
class MapWidget extends StatelessWidget {
  final Function(dynamic)? onMapCreated;
  final String? styleUri;
  final dynamic cameraOptions;

  const MapWidget({
    super.key,
    this.onMapCreated,
    this.styleUri,
    this.cameraOptions,
  });

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
  dynamic get style => null;
  dynamic get scaleBar => null;
  dynamic get logo => null;
  dynamic get attribution => null;
}

class MapboxStyles {
  // ignore: constant_identifier_names
  static const String DARK = 'mapbox://styles/mapbox/dark-v11';
}

class CameraOptions {
  final dynamic center;
  final double? zoom;
  final double? pitch;

  const CameraOptions({this.center, this.zoom, this.pitch});
}

class Point {
  final dynamic coordinates;
  const Point({this.coordinates});
}

class Position {
  final double lat;
  final double lng;
  Position(this.lng, this.lat);
}

class ScaleBarSettings {
  final bool enabled;
  ScaleBarSettings({this.enabled = true});
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
  CircleAnnotationOptions({this.geometry, this.circleColor, this.circleRadius, this.circleStrokeColor, this.circleStrokeWidth, this.circleOpacity});
}

class LineString {
  final List<dynamic> coordinates;
  LineString({required this.coordinates});
}

class OrnamentPosition {
  static const topLeft = 'top-left';
}
