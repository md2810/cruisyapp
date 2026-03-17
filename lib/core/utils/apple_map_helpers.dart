import 'package:flutter/material.dart';
import 'package:apple_maps_flutter/apple_maps_flutter.dart' as apple;
import 'map_utils.dart';

/// Helper class for drawing curved polylines on Apple Maps
/// 
/// Example usage:
/// ```dart
/// final helper = AppleMapPolylineHelper();
/// 
/// // Create a curved polyline between two ports
/// final polyline = helper.createCurvedPolyline(
///   start: const LatLng(36.0, 14.0),  // Mediterranean
///   end: const LatLng(37.5, 23.0),    // Greece
///   color: Colors.cyan,
///   width: 3,
/// );
/// 
/// // Add to your AppleMap
/// AppleMap(
///   polylines: {polyline},
///   ...
/// )
/// ```
class AppleMapPolylineHelper {
  /// Creates a curved polyline between two points using great circle calculation
  /// 
  /// [start] - Starting coordinate (latitude, longitude)
  /// [end] - Ending coordinate (latitude, longitude)
  /// [polylineId] - Unique identifier for this polyline
  /// [color] - Line color
  /// [width] - Line width in pixels
  /// [numPoints] - Number of points to generate for the curve (default: 100)
  static apple.Polyline createCurvedPolyline({
    required LatLng start,
    required LatLng end,
    required String polylineId,
    required Color color,
    required int width,
    int numPoints = 100,
  }) {
    // Calculate curved points using great circle formula
    final curvedPoints = MapUtils.calculateGreatCirclePolyline(
      start,
      end,
      numPoints: numPoints,
    );

    // Convert to Apple Maps LatLng
    final applePoints = curvedPoints
        .map((p) => apple.LatLng(p.latitude, p.longitude))
        .toList();

    return apple.Polyline(
      polylineId: apple.PolylineId(polylineId),
      points: applePoints,
      color: color,
      width: width,
    );
  }

  /// Creates a polyline with a custom bezier curve
  /// 
  /// This creates a more pronounced curve than the great circle route.
  /// 
  /// [start] - Starting coordinate
  /// [end] - Ending coordinate
  /// [polylineId] - Unique identifier
  /// [color] - Line color
  /// [width] - Line width
  /// [curvature] - How much the curve deviates (0.0 = straight, 1.0 = very curved)
  static apple.Polyline createBezierPolyline({
    required LatLng start,
    required LatLng end,
    required String polylineId,
    required Color color,
    required int width,
    double curvature = 0.3,
  }) {
    // Calculate curved points using bezier curve
    final curvedPoints = MapUtils.calculateBezierCurvedPolyline(
      start,
      end,
      numPoints: 100,
      curvature: curvature,
    );

    // Convert to Apple Maps LatLng
    final applePoints = curvedPoints
        .map((p) => apple.LatLng(p.latitude, p.longitude))
        .toList();

    return apple.Polyline(
      polylineId: apple.PolylineId(polylineId),
      points: applePoints,
      color: color,
      width: width,
    );
  }

  /// Creates a complete cruise route with multiple stops
  /// 
  /// [waypoints] - List of port coordinates in order
  /// [polylineId] - Base identifier for polylines
  /// [color] - Line color
  /// [width] - Line width
  /// [curved] - Whether to use curved lines between ports
  static Set<apple.Polyline> createCruiseRoute({
    required List<LatLng> waypoints,
    required String polylineId,
    required Color color,
    required int width,
    bool curved = true,
  }) {
    if (waypoints.length < 2) return {};

    final polylines = <apple.Polyline>{};

    for (int i = 0; i < waypoints.length - 1; i++) {
      if (curved) {
        polylines.add(createCurvedPolyline(
          start: waypoints[i],
          end: waypoints[i + 1],
          polylineId: '${polylineId}_segment_$i',
          color: color,
          width: width,
        ));
      } else {
        // Straight line
        polylines.add(apple.Polyline(
          polylineId: apple.PolylineId('${polylineId}_segment_$i'),
          points: [
            apple.LatLng(waypoints[i].latitude, waypoints[i].longitude),
            apple.LatLng(waypoints[i + 1].latitude, waypoints[i + 1].longitude),
          ],
          color: color,
          width: width,
        ));
      }
    }

    return polylines;
  }

  /// Creates port annotations for Apple Maps
  /// 
  /// [ports] - List of port coordinates and names
  static Set<apple.Annotation> createPortAnnotations({
    required List<({LatLng position, String name})> ports,
  }) {
    return ports.asMap().entries.map((entry) {
      final index = entry.key;
      final port = entry.value;
      
      return apple.Annotation(
        annotationId: apple.AnnotationId('port_$index'),
        position: apple.LatLng(port.position.latitude, port.position.longitude),
        infoWindow: apple.InfoWindow(
          title: port.name,
          snippet: 'Port ${index + 1} of ${ports.length}',
        ),
      );
    }).toSet();
  }

  /// Creates a ship annotation at the current interpolated position
  /// 
  /// [position] - Current ship position
  static apple.Annotation createShipAnnotation({
    required LatLng position,
  }) {
    return apple.Annotation(
      annotationId: apple.AnnotationId('ship'),
      position: apple.LatLng(position.latitude, position.longitude),
      infoWindow: apple.InfoWindow(title: 'Current Position'),
    );
  }
}

/// Example: Complete Apple Maps implementation for cruise route display
/// 
/// This shows how to integrate curved polylines with a full cruise route:
///
/// ```dart
/// class CruiseMapScreen extends StatefulWidget {
///   final CruiseTrip trip;
///   
///   const CruiseMapScreen({super.key, required this.trip});
///   
///   @override
///   State<CruiseMapScreen> createState() => _CruiseMapScreenState();
/// }
///
/// class _CruiseMapScreenState extends State<CruiseMapScreen> {
///   late Set<apple.Polyline> _polylines;
///   late Set<apple.Annotation> _annotations;
///   
///   @override
///   void initState() {
///     super.initState();
///     _updateRoute();
///   }
///   
///   void _updateRoute() {
///     // Get ports with coordinates
///     final ports = widget.trip.stops
///         .where((s) => !s.isSeaDay && s.latitude != null && s.longitude != null)
///         .toList();
///     
///     if (ports.length >= 2) {
///       // Create waypoints
///       final waypoints = ports
///           .map((p) => LatLng(p.latitude!, p.longitude!))
///           .toList();
///       
///       // Create curved route polylines
///       _polylines = AppleMapPolylineHelper.createCruiseRoute(
///         waypoints: waypoints,
///         polylineId: 'route',
///         color: Colors.cyan,
///         width: 3,
///         curved: true,
///       );
///       
///       // Create port annotations
///       final portData = ports
///           .map((p) => (
///                 position: LatLng(p.latitude!, p.longitude!),
///                 name: p.name,
///               ))
///           .toList();
///       
///       _annotations = AppleMapPolylineHelper.createPortAnnotations(
///         ports: portData,
///       );
///     }
///   }
///   
///   @override
///   Widget build(BuildContext context) {
///     return apple.AppleMap(
///       initialCameraPosition: apple.CameraPosition(
///         target: apple.LatLng(
///           widget.trip.stops.first.latitude!,
///           widget.trip.stops.first.longitude!,
///         ),
///         zoom: 5.0,
///       ),
///       polylines: _polylines,
///       annotations: _annotations,
///       mapType: apple.MapType.standard,
///     );
///   }
/// }
/// ```
