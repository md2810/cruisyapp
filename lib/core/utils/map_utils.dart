import 'dart:math' as math;

/// Utility class for map-related calculations
class MapUtils {
  MapUtils._();

  /// Earth radius in kilometers
  static const double earthRadiusKm = 6371.0;

  /// Convert degrees to radians
  static double degToRad(double degrees) => degrees * math.pi / 180.0;

  /// Convert radians to degrees
  static double radToDeg(double radians) => radians * 180.0 / math.pi;

  /// Calculate the great circle distance between two points in kilometers
  static double haversineDistance(LatLng start, LatLng end) {
    final dLat = degToRad(end.latitude - start.latitude);
    final dLon = degToRad(end.longitude - start.longitude);
    
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(degToRad(start.latitude)) *
            math.cos(degToRad(end.latitude)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  /// Calculate intermediate points along a great circle path
  /// 
  /// Uses spherical interpolation to generate points between start and end
  /// that follow the shortest path on a sphere (great circle route).
  /// 
  /// [start] - Starting coordinate
  /// [end] - Ending coordinate
  /// [numPoints] - Number of intermediate points to generate (default: 50)
  /// 
  /// Returns a list of LatLng points including start and end
  static List<LatLng> calculateCurvedPolyline(
    LatLng start,
    LatLng end, {
    int numPoints = 50,
  }) {
    if (numPoints < 2) {
      return [start, end];
    }

    final points = <LatLng>[];
    final lat1 = degToRad(start.latitude);
    final lon1 = degToRad(start.longitude);
    final lat2 = degToRad(end.latitude);
    final lon2 = degToRad(end.longitude);

    // Calculate the angular distance between points
    final d = math.acos(
      math.sin(lat1) * math.sin(lat2) +
          math.cos(lat1) * math.cos(lat2) * math.cos(lon2 - lon1),
    );

    // If points are very close, just return straight line
    if (d < 0.0001) {
      return [start, end];
    }

    // Generate intermediate points using spherical interpolation
    for (int i = 0; i <= numPoints; i++) {
      final f = i / numPoints;
      
      // Spherical interpolation (slerp)
      final A = math.sin((1 - f) * d) / math.sin(d);
      final B = math.sin(f * d) / math.sin(d);

      final x = A * math.cos(lat1) * math.cos(lon1) + B * math.cos(lat2) * math.cos(lon2);
      final y = A * math.cos(lat1) * math.sin(lon1) + B * math.cos(lat2) * math.sin(lon2);
      final z = A * math.sin(lat1) + B * math.sin(lat2);

      final lat = radToDeg(math.atan2(z, math.sqrt(x * x + y * y)));
      final lon = radToDeg(math.atan2(y, x));

      points.add(LatLng(lat, lon));
    }

    return points;
  }

  /// Calculate a curved polyline using quadratic Bezier curve
  /// 
  /// This creates a more pronounced curve that looks more organic.
  /// The curve bulges outward based on the distance between points.
  /// 
  /// [start] - Starting coordinate
  /// [end] - Ending coordinate
  /// [numPoints] - Number of points to generate (default: 50)
  /// [curvature] - How much the curve deviates from straight line (0.0-1.0, default: 0.2)
  /// 
  /// Returns a list of LatLng points
  static List<LatLng> calculateBezierCurvedPolyline(
    LatLng start,
    LatLng end, {
    int numPoints = 50,
    double curvature = 0.2,
  }) {
    if (numPoints < 2) {
      return [start, end];
    }

    // Calculate control point for quadratic Bezier curve
    // The control point is perpendicular to the midpoint, creating an arc
    final midLat = (start.latitude + end.latitude) / 2;
    final midLon = (start.longitude + end.longitude) / 2;

    // Calculate perpendicular offset
    final dLat = end.latitude - start.latitude;
    final dLon = end.longitude - start.longitude;
    
    // Distance between points
    final distance = math.sqrt(dLat * dLat + dLon * dLon);
    
    // Perpendicular direction (rotate 90 degrees)
    final perpLat = -dLon;
    final perpLon = dLat;
    
    // Normalize and scale by curvature
    final perpLength = math.sqrt(perpLat * perpLat + perpLon * perpLon);
    final scale = perpLength > 0 ? (distance * curvature) / perpLength : 0;
    
    // Control point offset perpendicular to the line
    final controlLat = midLat + perpLat * scale;
    final controlLon = midLon + perpLon * scale;
    final controlPoint = LatLng(controlLat, controlLon);

    // Generate points along quadratic Bezier curve
    final points = <LatLng>[];
    for (int i = 0; i <= numPoints; i++) {
      final t = i / numPoints;
      
      // Quadratic Bezier formula: B(t) = (1-t)²P₀ + 2(1-t)tP₁ + t²P₂
      final oneMinusT = 1 - t;
      final oneMinusTSquared = oneMinusT * oneMinusT;
      final tSquared = t * t;
      
      final lat = oneMinusTSquared * start.latitude +
          2 * oneMinusT * t * controlPoint.latitude +
          tSquared * end.latitude;
      
      final lon = oneMinusTSquared * start.longitude +
          2 * oneMinusT * t * controlPoint.longitude +
          tSquared * end.longitude;
      
      points.add(LatLng(lat, lon));
    }

    return points;
  }

  /// Calculate a great circle route with intermediate points
  /// 
  /// This is the recommended method for drawing cruise routes as it
  /// follows the actual shortest path on Earth's surface.
  /// 
  /// [start] - Starting coordinate
  /// [end] - Ending coordinate  
  /// [numPoints] - Number of intermediate points (default: 100)
  /// 
  /// Returns a list of LatLng suitable for drawing polylines
  static List<LatLng> calculateGreatCirclePolyline(
    LatLng start,
    LatLng end, {
    int numPoints = 100,
  }) {
    return calculateCurvedPolyline(start, end, numPoints: numPoints);
  }

  /// Calculate multiple curved segments for a route with multiple stops
  /// 
  /// [waypoints] - List of coordinates representing ports/stops
  /// [numPointsPerSegment] - Number of points per segment (default: 50)
  /// 
  /// Returns a flattened list of LatLng representing the full curved route
  static List<LatLng> calculateCurvedRoute(
    List<LatLng> waypoints, {
    int numPointsPerSegment = 50,
  }) {
    if (waypoints.length < 2) return waypoints;

    final allPoints = <LatLng>[];

    for (int i = 0; i < waypoints.length - 1; i++) {
      final segment = calculateGreatCirclePolyline(
        waypoints[i],
        waypoints[i + 1],
        numPoints: numPointsPerSegment,
      );

      // Add all points except the last one (to avoid duplicates)
      if (i < waypoints.length - 2) {
        allPoints.addAll(segment.take(segment.length - 1));
      } else {
        allPoints.addAll(segment);
      }
    }

    return allPoints;
  }
}

/// Simple lat/long coordinate class
class LatLng {
  final double latitude;
  final double longitude;

  const LatLng(this.latitude, this.longitude);

  @override
  String toString() => 'LatLng($latitude, $longitude)';

  @override
  bool operator ==(Object other) =>
      other is LatLng &&
      other.latitude == latitude &&
      other.longitude == longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);
}
