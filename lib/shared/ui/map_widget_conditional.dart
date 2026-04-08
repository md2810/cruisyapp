// Conditional import for MapWidget - uses platform-specific implementations
// On iOS: Apple Maps via apple_maps_flutter
// On Android: Mapbox via mapbox_maps_flutter
// On Web: Stub implementation

import 'dart:io';

import 'package:apple_maps_flutter/apple_maps_flutter.dart' as apple;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart'
    if (dart.library.html) 'map_widget_stub.dart'
    as mapbox;

// Export common types
export 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart'
    if (dart.library.html) 'map_widget_stub.dart';

/// Platform-aware MapWidget that uses Apple Maps on iOS and Mapbox on Android.
class MapWidget extends StatefulWidget {
  const MapWidget({
    super.key,
    this.onMapCreated,
    this.styleUri,
    this.cameraOptions,
    this.onStyleLoadedListener,
    this.onMapLoadErrorListener,
  });

  final Function(dynamic mapController)? onMapCreated;
  final String? styleUri;
  final dynamic cameraOptions;
  final Function(dynamic)? onStyleLoadedListener;
  final Function(dynamic)? onMapLoadErrorListener;

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  Set<apple.Polyline> _applePolylines = <apple.Polyline>{};
  Set<apple.Annotation> _appleAnnotations = <apple.Annotation>{};

  bool get _isIOS => !kIsWeb && Platform.isIOS;

  @override
  Widget build(BuildContext context) {
    if (_isIOS) {
      return _buildAppleMap();
    }

    return _buildMapboxMap();
  }

  Widget _buildAppleMap() {
    final initialCameraPosition =
        _parseAppleCameraPosition() ??
        const apple.CameraPosition(target: apple.LatLng(35.0, 10.0), zoom: 1.0);

    return apple.AppleMap(
      initialCameraPosition: initialCameraPosition,
      mapType: apple.MapType.standard,
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      compassEnabled: false,
      onMapCreated: _onAppleMapCreated,
      annotations: _appleAnnotations,
      polylines: _applePolylines,
    );
  }

  Widget _buildMapboxMap() {
    return mapbox.MapWidget(
      onMapCreated: widget.onMapCreated,
      onStyleLoadedListener: widget.onStyleLoadedListener,
      onMapLoadErrorListener: widget.onMapLoadErrorListener,
      styleUri: widget.styleUri ?? mapbox.MapboxStyles.DARK,
      cameraOptions:
          widget.cameraOptions ??
          mapbox.CameraOptions(
            center: mapbox.Point(coordinates: mapbox.Position(10.0, 35.0)),
            zoom: 1.0,
            pitch: 0.0,
          ),
    );
  }

  apple.CameraPosition? _parseAppleCameraPosition() {
    final options = widget.cameraOptions;
    if (options == null) {
      return null;
    }

    if (options is mapbox.CameraOptions) {
      return _cameraPositionFromMapbox(options);
    }

    try {
      final optionsStr = options.toString();
      final centerMatch = RegExp(r'Position\(([^)]+)\)').firstMatch(optionsStr);
      if (centerMatch == null) {
        return null;
      }

      final coords =
          centerMatch
              .group(1)
              ?.split(',')
              .map((value) => value.trim())
              .toList();
      if (coords == null || coords.length < 2) {
        return null;
      }

      final lng = double.tryParse(coords[0]) ?? 10.0;
      final lat = double.tryParse(coords[1]) ?? 35.0;
      final zoomMatch = RegExp(r'zoom:\s*(\d+\.?\d*)').firstMatch(optionsStr);
      final zoom =
          zoomMatch != null
              ? double.tryParse(zoomMatch.group(1) ?? '1.0') ?? 1.0
              : 1.0;

      return apple.CameraPosition(target: apple.LatLng(lat, lng), zoom: zoom);
    } catch (error) {
      debugPrint('Error parsing Apple camera position: $error');
      return null;
    }
  }

  apple.CameraPosition _cameraPositionFromMapbox(mapbox.CameraOptions options) {
    final center = options.center?.coordinates;
    final latitude = center?.lat.toDouble() ?? 35.0;
    final longitude = center?.lng.toDouble() ?? 10.0;

    return apple.CameraPosition(
      target: apple.LatLng(latitude, longitude),
      zoom: options.zoom ?? 1.0,
    );
  }

  void _onAppleMapCreated(apple.AppleMapController controller) {
    final wrapper = AppleMapControllerWrapper(
      controller,
      onUpsertPolyline: _upsertApplePolyline,
      onClearPolylines: _clearApplePolylines,
      onUpsertAnnotation: _upsertAppleAnnotation,
      onClearAnnotations: _clearAppleAnnotations,
    );
    widget.onMapCreated?.call(wrapper);
  }

  void _upsertApplePolyline(apple.Polyline polyline) {
    if (!mounted) {
      return;
    }

    final polylinesById = <String, apple.Polyline>{
      for (final entry in _applePolylines) entry.polylineId.value: entry,
    };
    polylinesById[polyline.polylineId.value] = polyline;

    setState(() {
      _applePolylines = polylinesById.values.toSet();
    });
  }

  void _clearApplePolylines() {
    if (!mounted) {
      return;
    }

    setState(() {
      _applePolylines = <apple.Polyline>{};
    });
  }

  void _upsertAppleAnnotation(apple.Annotation annotation) {
    if (!mounted) {
      return;
    }

    final annotationsById = <String, apple.Annotation>{
      for (final entry in _appleAnnotations) entry.annotationId.value: entry,
    };
    annotationsById[annotation.annotationId.value] = annotation;

    setState(() {
      _appleAnnotations = annotationsById.values.toSet();
    });
  }

  void _clearAppleAnnotations() {
    if (!mounted) {
      return;
    }

    setState(() {
      _appleAnnotations = <apple.Annotation>{};
    });
  }
}

/// Wrapper for Apple Maps controller to provide a Mapbox-like surface.
class AppleMapControllerWrapper {
  AppleMapControllerWrapper(
    this._controller, {
    required void Function(apple.Polyline polyline) onUpsertPolyline,
    required VoidCallback onClearPolylines,
    required void Function(apple.Annotation annotation) onUpsertAnnotation,
    required VoidCallback onClearAnnotations,
  }) : _annotations = AppleAnnotationsWrapper(
         polylineManager: ApplePolylineAnnotationManager(
           onUpsertPolyline: onUpsertPolyline,
           onClear: onClearPolylines,
         ),
         circleManager: AppleCircleAnnotationManager(
           onUpsertAnnotation: onUpsertAnnotation,
           onClear: onClearAnnotations,
         ),
       );

  final apple.AppleMapController _controller;
  final AppleAnnotationsWrapper _annotations;

  Future<void> setCamera(dynamic options) async {
    final cameraPosition = _parseCameraOptions(options);
    if (cameraPosition == null) {
      return;
    }

    await _controller.animateCamera(
      apple.CameraUpdate.newCameraPosition(cameraPosition),
    );
  }

  Future<void> flyTo(dynamic cameraOptions, [dynamic animationOptions]) async {
    await setCamera(cameraOptions);
  }

  AppleAnnotationsWrapper get annotations => _annotations;

  AppleStyleWrapper get style => AppleStyleWrapper();

  AppleScaleBarWrapper get scaleBar => AppleScaleBarWrapper();

  AppleLogoWrapper get logo => AppleLogoWrapper();

  AppleAttributionWrapper get attribution => AppleAttributionWrapper();

  apple.CameraPosition? _parseCameraOptions(dynamic options) {
    if (options is mapbox.CameraOptions) {
      final center = options.center?.coordinates;
      return apple.CameraPosition(
        target: apple.LatLng(
          center?.lat.toDouble() ?? 35.0,
          center?.lng.toDouble() ?? 10.0,
        ),
        zoom: options.zoom ?? 1.0,
      );
    }

    try {
      final optionsStr = options.toString();
      final centerMatch = RegExp(r'Position\(([^)]+)\)').firstMatch(optionsStr);
      if (centerMatch == null) {
        return null;
      }

      final coords =
          centerMatch
              .group(1)
              ?.split(',')
              .map((value) => value.trim())
              .toList();
      if (coords == null || coords.length < 2) {
        return null;
      }

      final lng = double.tryParse(coords[0]) ?? 10.0;
      final lat = double.tryParse(coords[1]) ?? 35.0;
      final zoomMatch = RegExp(r'zoom:\s*(\d+\.?\d*)').firstMatch(optionsStr);
      final zoom =
          zoomMatch != null
              ? double.tryParse(zoomMatch.group(1) ?? '1.0') ?? 1.0
              : 1.0;

      return apple.CameraPosition(target: apple.LatLng(lat, lng), zoom: zoom);
    } catch (_) {
      return null;
    }
  }
}

class AppleAnnotationsWrapper {
  const AppleAnnotationsWrapper({
    required ApplePolylineAnnotationManager polylineManager,
    required AppleCircleAnnotationManager circleManager,
  }) : _polylineManager = polylineManager,
       _circleManager = circleManager;

  final ApplePolylineAnnotationManager _polylineManager;
  final AppleCircleAnnotationManager _circleManager;

  Future<ApplePolylineAnnotationManager>
  createPolylineAnnotationManager() async {
    return _polylineManager;
  }

  Future<AppleCircleAnnotationManager> createCircleAnnotationManager() async {
    return _circleManager;
  }
}

class ApplePolylineAnnotationManager {
  ApplePolylineAnnotationManager({
    required void Function(apple.Polyline polyline) onUpsertPolyline,
    required VoidCallback onClear,
  }) : _onUpsertPolyline = onUpsertPolyline,
       _onClear = onClear;

  final void Function(apple.Polyline polyline) _onUpsertPolyline;
  final VoidCallback _onClear;

  int _nextId = 0;

  void deleteAll() {
    _nextId = 0;
    _onClear();
  }

  Future<void> create(dynamic options) async {
    if (options is! mapbox.PolylineAnnotationOptions) {
      return;
    }

    final points =
        options.geometry.coordinates
            .map(
              (position) => apple.LatLng(
                position.lat.toDouble(),
                position.lng.toDouble(),
              ),
            )
            .toList();
    if (points.length < 2) {
      return;
    }

    final color = _applyOpacity(
      Color(options.lineColor ?? 0xFF4FC3F7),
      options.lineOpacity ?? 1.0,
    );

    _onUpsertPolyline(
      apple.Polyline(
        polylineId: apple.PolylineId('apple_polyline_${_nextId++}'),
        points: points,
        color: color,
        width: ((options.lineWidth ?? 3.0).round()).clamp(1, 24).toInt(),
      ),
    );
  }
}

class AppleCircleAnnotationManager {
  AppleCircleAnnotationManager({
    required void Function(apple.Annotation annotation) onUpsertAnnotation,
    required VoidCallback onClear,
  }) : _onUpsertAnnotation = onUpsertAnnotation,
       _onClear = onClear;

  final void Function(apple.Annotation annotation) _onUpsertAnnotation;
  final VoidCallback _onClear;

  int _nextId = 0;

  void deleteAll() {
    _nextId = 0;
    _onClear();
  }

  Future<void> create(dynamic options) async {
    if (options is! mapbox.CircleAnnotationOptions) {
      return;
    }

    final position = options.geometry.coordinates;
    final opacity = options.circleOpacity ?? 1.0;

    _onUpsertAnnotation(
      apple.Annotation(
        annotationId: apple.AnnotationId('apple_annotation_${_nextId++}'),
        position: apple.LatLng(
          position.lat.toDouble(),
          position.lng.toDouble(),
        ),
        alpha: opacity.clamp(0.0, 1.0).toDouble(),
      ),
    );
  }
}

class AppleStyleWrapper {
  void setProjection(dynamic projection) {}
}

class AppleScaleBarWrapper {
  void updateSettings(dynamic settings) {}
}

class AppleLogoWrapper {
  void updateSettings(dynamic settings) {}
}

class AppleAttributionWrapper {
  void updateSettings(dynamic settings) {}
}

class StyleProjectionName {
  static const String globe = 'globe';
  static const String mercator = 'mercator';
}

class StyleProjection {
  StyleProjection({required this.name});

  final String name;
}

class ScaleBarSettings {
  ScaleBarSettings({this.enabled = true});

  final bool enabled;
}

class LogoSettings {
  LogoSettings({
    this.enabled = true,
    this.position,
    this.marginLeft,
    this.marginTop,
  });

  final bool enabled;
  final String? position;
  final double? marginLeft;
  final double? marginTop;
}

class AttributionSettings {
  AttributionSettings({
    this.enabled = true,
    this.position,
    this.marginLeft,
    this.marginTop,
  });

  final bool enabled;
  final String? position;
  final double? marginLeft;
  final double? marginTop;
}

class OrnamentPosition {
  static const String topLeft = 'top-left';
  static const String topRight = 'top-right';
  static const String bottomLeft = 'bottom-left';
  static const String bottomRight = 'bottom-right';
}

class MapAnimationOptions {
  MapAnimationOptions({this.duration});

  final int? duration;
}

Color _applyOpacity(Color color, double opacity) {
  final normalizedOpacity = opacity.clamp(0.0, 1.0).toDouble();
  return color.withValues(alpha: normalizedOpacity);
}
