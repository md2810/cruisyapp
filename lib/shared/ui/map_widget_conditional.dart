// Conditional import for MapWidget - uses platform-specific implementations
// On iOS: Apple Maps via apple_maps_flutter
// On Android: Mapbox via mapbox_maps_flutter
// On Web: Stub implementation

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Platform-specific imports
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox
    if (dart.library.html) 'map_widget_stub.dart';
import 'package:apple_maps_flutter/apple_maps_flutter.dart' as apple;

// Export common types
export 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart'
    if (dart.library.html) 'map_widget_stub.dart';

/// Platform-aware MapWidget that uses Apple Maps on iOS and Mapbox on Android
class MapWidget extends StatefulWidget {
  final Function(dynamic mapController)? onMapCreated;
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
  // iOS-specific controllers
  apple.AppleMapController? _appleMapController;

  /// Check if running on iOS
  bool get _isIOS => !kIsWeb && Platform.isIOS;

  @override
  Widget build(BuildContext context) {
    // On iOS, use Apple Maps
    if (_isIOS) {
      return _buildAppleMap();
    }

    // On Android and other platforms, use Mapbox
    return _buildMapboxMap();
  }

  /// Build Apple Maps widget for iOS
  Widget _buildAppleMap() {
    // Parse camera options for Apple Maps
    final initialCameraPosition = _parseAppleCameraPosition();

    return apple.AppleMap(
      initialCameraPosition: initialCameraPosition ??
          const apple.CameraPosition(
            target: apple.LatLng(35.0, 10.0),
            zoom: 1.0,
          ),
      mapType: apple.MapType.standard,
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      compassEnabled: false,
      onMapCreated: _onAppleMapCreated,
      polylines: const {}, // Initially empty, can be set via controller
    );
  }

  /// Build Mapbox widget for Android/Web
  Widget _buildMapboxMap() {
    return mapbox.MapWidget(
      onMapCreated: widget.onMapCreated,
      onStyleLoadedListener: widget.onStyleLoadedListener,
      onMapLoadErrorListener: widget.onMapLoadErrorListener,
      styleUri: widget.styleUri ?? mapbox.MapboxStyles.DARK,
      cameraOptions: widget.cameraOptions ??
          mapbox.CameraOptions(
            center: mapbox.Point(
                coordinates: mapbox.Position(10.0, 35.0)),
            zoom: 1.0,
            pitch: 0.0,
          ),
    );
  }

  /// Parse camera options from Mapbox format to Apple Maps format
  apple.CameraPosition? _parseAppleCameraPosition() {
    try {
      final options = widget.cameraOptions;
      if (options == null) return null;

      // Handle Mapbox CameraOptions - try to extract using toString parsing
      // since we can't reliably cast across package boundaries
      final optionsStr = options.toString();
      
      // Try to extract center coordinates from the string representation
      // Format: CameraOptions(center: Point(coordinates: Position(lng, lat)), zoom: X, ...)
      final centerMatch = RegExp(r'Position\(([^)]+)\)').firstMatch(optionsStr);
      if (centerMatch != null) {
        final coords = centerMatch.group(1);
        if (coords != null) {
          final parts = coords.split(',').map((s) => s.trim()).toList();
          if (parts.length >= 2) {
            final lng = double.tryParse(parts[0]) ?? 10.0;
            final lat = double.tryParse(parts[1]) ?? 35.0;
            
            // Extract zoom
            final zoomMatch = RegExp(r'zoom:\s*(\d+\.?\d*)').firstMatch(optionsStr);
            final zoom = zoomMatch != null 
                ? double.tryParse(zoomMatch.group(1) ?? '1.0') ?? 1.0 
                : 1.0;
            
            return apple.CameraPosition(
              target: apple.LatLng(lat, lng),
              zoom: zoom,
            );
          }
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error parsing camera position: $e');
      return null;
    }
  }

  /// Called when Apple Maps is created
  void _onAppleMapCreated(apple.AppleMapController controller) {
    _appleMapController = controller;

    // Create a wrapper that provides a compatible interface
    final wrapper = AppleMapControllerWrapper(controller);
    widget.onMapCreated?.call(wrapper);
  }
}

/// Wrapper for Apple Maps controller to provide compatible interface
class AppleMapControllerWrapper {
  final apple.AppleMapController _controller;

  AppleMapControllerWrapper(this._controller);

  /// Set camera position (compatible with Mapbox API)
  Future<void> setCamera(dynamic options) async {
    final pos = _parseCameraOptions(options);
    if (pos != null) {
      await _controller.animateCamera(
        apple.CameraUpdate.newCameraPosition(pos),
      );
    }
  }

  /// Fly to a new camera position (compatible with Mapbox API)
  Future<void> flyTo(dynamic cameraOptions, [dynamic animationOptions]) async {
    await setCamera(cameraOptions);
  }

  /// Get annotation manager (for polylines)
  AppleAnnotationsWrapper get annotations => AppleAnnotationsWrapper(_controller);

  /// Get style (stub for compatibility)
  AppleStyleWrapper get style => AppleStyleWrapper();

  /// Get scale bar (stub for compatibility)
  AppleScaleBarWrapper get scaleBar => AppleScaleBarWrapper();

  /// Get logo (stub for compatibility)
  AppleLogoWrapper get logo => AppleLogoWrapper();

  /// Get attribution (stub for compatibility)
  AppleAttributionWrapper get attribution => AppleAttributionWrapper();

  /// Parse camera options from dynamic input
  apple.CameraPosition? _parseCameraOptions(dynamic options) {
    try {
      final optionsStr = options.toString();
      
      // Extract position
      final centerMatch = RegExp(r'Position\(([^)]+)\)').firstMatch(optionsStr);
      if (centerMatch != null) {
        final coords = centerMatch.group(1);
        if (coords != null) {
          final parts = coords.split(',').map((s) => s.trim()).toList();
          if (parts.length >= 2) {
            final lng = double.tryParse(parts[0]) ?? 10.0;
            final lat = double.tryParse(parts[1]) ?? 35.0;
            
            // Extract zoom
            final zoomMatch = RegExp(r'zoom:\s*(\d+\.?\d*)').firstMatch(optionsStr);
            final zoom = zoomMatch != null 
                ? double.tryParse(zoomMatch.group(1) ?? '1.0') ?? 1.0 
                : 1.0;
            
            return apple.CameraPosition(
              target: apple.LatLng(lat, lng),
              zoom: zoom,
            );
          }
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

/// Wrapper for Apple Maps annotations
class AppleAnnotationsWrapper {
  final apple.AppleMapController _controller;

  AppleAnnotationsWrapper(this._controller);

  /// Create polyline annotation manager
  Future<ApplePolylineAnnotationManager> createPolylineAnnotationManager() async {
    return ApplePolylineAnnotationManager(_controller);
  }

  /// Create circle annotation manager
  Future<AppleCircleAnnotationManager> createCircleAnnotationManager() async {
    return AppleCircleAnnotationManager(_controller);
  }
}

/// Wrapper for Apple Maps polyline annotation manager
class ApplePolylineAnnotationManager {
  final apple.AppleMapController _controller;

  ApplePolylineAnnotationManager(this._controller);

  /// Delete all polylines
  void deleteAll() {
    // On Apple Maps, polylines are managed through the widget state
    // This would need to be implemented via state management
  }

  /// Create a new polyline annotation
  Future<void> create(dynamic options) async {
    // Parse options and create polyline
    // This is a stub - actual implementation would require
    // state management to update the AppleMap widget
  }
}

/// Wrapper for Apple Maps circle annotation manager
class AppleCircleAnnotationManager {
  final apple.AppleMapController _controller;

  AppleCircleAnnotationManager(this._controller);

  /// Delete all circles
  void deleteAll() {
    // On Apple Maps, circles are managed through the widget state
  }

  /// Create a new circle annotation
  Future<void> create(dynamic options) async {
    // Parse options and create circle
    // This is a stub - actual implementation would require
    // state management to update the AppleMap widget
  }
}

/// Wrapper for Apple Maps style
class AppleStyleWrapper {
  /// Set projection (stub - Apple Maps doesn't support this)
  void setProjection(dynamic projection) {
    // Apple Maps doesn't support projection changes
  }
}

/// Wrapper for Apple Maps scale bar settings
class AppleScaleBarWrapper {
  void updateSettings(dynamic settings) {
    // Apple Maps doesn't expose scale bar settings
  }
}

/// Wrapper for Apple Maps logo settings
class AppleLogoWrapper {
  void updateSettings(dynamic settings) {
    // Apple Maps doesn't expose logo settings
  }
}

/// Wrapper for Apple Maps attribution settings
class AppleAttributionWrapper {
  void updateSettings(dynamic settings) {
    // Apple Maps doesn't expose attribution settings
  }
}

/// Style projection names (compatible with Mapbox)
class StyleProjectionName {
  static const String globe = 'globe';
  static const String mercator = 'mercator';
}

/// Style projection (compatible with Mapbox)
class StyleProjection {
  final String name;
  StyleProjection({required this.name});
}

/// Scale bar settings (compatible with Mapbox)
class ScaleBarSettings {
  final bool enabled;
  ScaleBarSettings({this.enabled = true});
}

/// Logo settings (compatible with Mapbox)
class LogoSettings {
  final bool enabled;
  final String? position;
  final double? marginLeft;
  final double? marginTop;
  LogoSettings({
    this.enabled = true,
    this.position,
    this.marginLeft,
    this.marginTop,
  });
}

/// Attribution settings (compatible with Mapbox)
class AttributionSettings {
  final bool enabled;
  final String? position;
  final double? marginLeft;
  final double? marginTop;
  AttributionSettings({
    this.enabled = true,
    this.position,
    this.marginLeft,
    this.marginTop,
  });
}

/// Ornament positions
class OrnamentPosition {
  static const String topLeft = 'top-left';
  static const String topRight = 'top-right';
  static const String bottomLeft = 'bottom-left';
  static const String bottomRight = 'bottom-right';
}

/// Map animation options
class MapAnimationOptions {
  final int? duration;
  MapAnimationOptions({this.duration});
}
