import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../../core/providers/ship_provider.dart';
import '../../../core/providers/trip_provider.dart';
import '../../../shared/models/cruise_ship.dart';
import '../../../shared/models/cruise_trip.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> with WidgetsBindingObserver {
  MapboxMap? _mapboxMap;
  double _currentZoom = 1.0;
  String? _mapError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _mapboxMap = null;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // App is in background - reduce map resources
    } else if (state == AppLifecycleState.resumed) {
      // App is in foreground - restore map
    }
  }

  void _onMapCreated(MapboxMap mapboxMap) {
    debugPrint('Mapbox: Map created successfully');
    _mapboxMap = mapboxMap;

    // Hide Mapbox ornaments (scale bar, logo, attribution)
    mapboxMap.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
    mapboxMap.logo.updateSettings(LogoSettings(enabled: false));
    mapboxMap.attribution.updateSettings(AttributionSettings(enabled: false));

    // Set globe projection for 3D globe view
    mapboxMap.style.setProjection(StyleProjection(name: StyleProjectionName.globe));

    // Set initial camera to show full globe
    mapboxMap.setCamera(
      CameraOptions(
        center: Point(coordinates: Position(10.0, 35.0)), // Center on Mediterranean
        zoom: 1.0, // Global view to see the whole globe
        pitch: 0.0,
      ),
    );
    _currentZoom = 1.0;
  }

  void _onStyleLoaded(StyleLoadedEventData data) {
    debugPrint('Mapbox: Style loaded successfully');
  }

  void _onMapLoadError(MapLoadingErrorEventData data) {
    debugPrint('Mapbox: Error loading map - ${data.message}');
    if (mounted) {
      setState(() {
        _mapError = data.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          // Map container with SizedBox.expand for full screen coverage
          SizedBox.expand(
            child: Container(
              color: const Color(0xFF0a1929), // Dark fallback color
              child: MapWidget(
                onMapCreated: _onMapCreated,
                onStyleLoadedListener: _onStyleLoaded,
                onMapLoadErrorListener: _onMapLoadError,
                styleUri: MapboxStyles.DARK,
                cameraOptions: CameraOptions(
                  center: Point(coordinates: Position(10.0, 35.0)),
                  zoom: 1.0, // Global view to see the whole globe
                  pitch: 0.0,
                ),
              ),
            ),
          ),
          // Error overlay
          if (_mapError != null)
            Positioned.fill(
              child: Container(
                color: colorScheme.surface.withOpacity(0.9),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.map_outlined,
                          size: 64,
                          color: colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.mapFailedToLoad,
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.checkMapboxConfig,
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        FilledButton.tonal(
                          onPressed: () {
                            setState(() {
                              _mapError = null;
                            });
                          },
                          child: Text(l10n.retry),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          // Header gradient
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.explore,
                              style: GoogleFonts.outfit(
                                fontSize: 40,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.yourCruiseDestinations,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _ProfileButton(
                        onTap: () => context.push('/settings'),
                        isMapStyle: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Map controls
          Positioned(
            bottom: 140,
            right: 16,
            child: Column(
              children: [
                _MapControlButton(
                  icon: Icons.public_rounded,
                  onPressed: () {
                    _mapboxMap?.flyTo(
                      CameraOptions(
                        center: Point(coordinates: Position(10.0, 35.0)),
                        zoom: 1.0,
                        pitch: 0.0,
                      ),
                      MapAnimationOptions(duration: 500),
                    );
                    setState(() {
                      _currentZoom = 1.0;
                    });
                  },
                ),
                const SizedBox(height: 8),
                _MapControlButton(
                  icon: Icons.add_rounded,
                  onPressed: () {
                    setState(() {
                      _currentZoom = (_currentZoom + 1).clamp(0.0, 20.0);
                    });
                    _mapboxMap?.flyTo(
                      CameraOptions(zoom: _currentZoom),
                      MapAnimationOptions(duration: 300),
                    );
                  },
                ),
                const SizedBox(height: 8),
                _MapControlButton(
                  icon: Icons.remove_rounded,
                  onPressed: () {
                    setState(() {
                      _currentZoom = (_currentZoom - 1).clamp(0.0, 20.0);
                    });
                    _mapboxMap?.flyTo(
                      CameraOptions(zoom: _currentZoom),
                      MapAnimationOptions(duration: 300),
                    );
                  },
                ),
              ],
            ),
          ),
          // Ship position card for ongoing trips
          _buildShipPositionCard(context, l10n),
        ],
      ),
    );
  }

  Widget _buildShipPositionCard(BuildContext context, AppLocalizations l10n) {
    final trips = ref.watch(tripsProvider);
    final ongoingTrips = trips.where((t) => t.isOngoing && t.mmsi != null).toList();

    if (ongoingTrips.isEmpty) {
      return const SizedBox.shrink();
    }

    // Show the first ongoing trip with MMSI
    final trip = ongoingTrips.first;

    return Positioned(
      bottom: 100,
      left: 16,
      right: 80,
      child: _ShipPositionCard(
        trip: trip,
        onLocate: (lat, lng) {
          _mapboxMap?.flyTo(
            CameraOptions(
              center: Point(coordinates: Position(lng, lat)),
              zoom: 8.0,
              pitch: 0.0,
            ),
            MapAnimationOptions(duration: 800),
          );
          setState(() {
            _currentZoom = 8.0;
          });
        },
      ),
    );
  }
}

class _ShipPositionCard extends ConsumerWidget {
  final CruiseTrip trip;
  final void Function(double lat, double lng) onLocate;

  const _ShipPositionCard({
    required this.trip,
    required this.onLocate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    // Watch live position for this ship
    final livePositionAsync = ref.watch(livePositionProvider(trip.mmsi!));

    return livePositionAsync.when(
      loading: () => _buildCard(
        context,
        colorScheme,
        textTheme,
        l10n,
        isLoading: true,
      ),
      error: (_, __) => _buildCard(
        context,
        colorScheme,
        textTheme,
        l10n,
        isEstimated: true,
      ),
      data: (livePosition) {
        if (livePosition == null || livePosition.isStale) {
          // Use interpolated position from route
          return _buildCard(
            context,
            colorScheme,
            textTheme,
            l10n,
            isEstimated: true,
            estimatedPosition: _getInterpolatedPosition(),
          );
        }

        return _buildCard(
          context,
          colorScheme,
          textTheme,
          l10n,
          livePosition: livePosition,
        );
      },
    );
  }

  _InterpolatedPosition? _getInterpolatedPosition() {
    // Calculate position based on trip progress
    final progress = trip.progress;
    final stopsWithCoords = trip.stops
        .where((s) => !s.isSeaDay && s.latitude != null && s.longitude != null)
        .toList();

    if (stopsWithCoords.length < 2) return null;

    // Find which segment we're on
    final totalStops = stopsWithCoords.length;
    final segmentProgress = progress * (totalStops - 1);
    final segmentIndex = segmentProgress.floor().clamp(0, totalStops - 2);
    final segmentFraction = segmentProgress - segmentIndex;

    final from = stopsWithCoords[segmentIndex];
    final to = stopsWithCoords[segmentIndex + 1];

    // Linear interpolation
    final lat = from.latitude! + (to.latitude! - from.latitude!) * segmentFraction;
    final lng = from.longitude! + (to.longitude! - from.longitude!) * segmentFraction;

    return _InterpolatedPosition(
      latitude: lat,
      longitude: lng,
      fromPort: from.name,
      toPort: to.name,
    );
  }

  Widget _buildCard(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
    AppLocalizations l10n, {
    bool isLoading = false,
    bool isEstimated = false,
    LivePosition? livePosition,
    _InterpolatedPosition? estimatedPosition,
  }) {
    return Card(
      color: colorScheme.surfaceContainerHigh.withOpacity(0.95),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ship name and status badge
            Row(
              children: [
                Icon(
                  Icons.directions_boat_rounded,
                  color: colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    trip.shipName,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _StatusBadge(
                  isLoading: isLoading,
                  livePosition: livePosition,
                  isEstimated: isEstimated,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Position info
            if (isLoading)
              Row(
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Loading position...',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              )
            else if (livePosition != null)
              _buildPositionInfo(
                context,
                colorScheme,
                textTheme,
                latitude: livePosition.latitude,
                longitude: livePosition.longitude,
                speed: livePosition.speed,
                heading: livePosition.heading,
              )
            else if (estimatedPosition != null)
              _buildEstimatedInfo(
                context,
                colorScheme,
                textTheme,
                estimatedPosition,
              )
            else
              Text(
                'Position unavailable',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            const SizedBox(height: 12),
            // Locate button
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: () {
                  final lat = livePosition?.latitude ?? estimatedPosition?.latitude;
                  final lng = livePosition?.longitude ?? estimatedPosition?.longitude;
                  if (lat != null && lng != null) {
                    onLocate(lat, lng);
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.my_location_rounded, size: 16),
                    const SizedBox(width: 8),
                    const Text('Locate on map'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPositionInfo(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme, {
    required double latitude,
    required double longitude,
    required double speed,
    required double heading,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.speed_rounded,
              size: 14,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              '${speed.toStringAsFixed(1)} kn',
              style: textTheme.bodySmall,
            ),
            const SizedBox(width: 16),
            Icon(
              Icons.navigation_rounded,
              size: 14,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              '${heading.toStringAsFixed(0)}°',
              style: textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${latitude.toStringAsFixed(4)}°, ${longitude.toStringAsFixed(4)}°',
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  Widget _buildEstimatedInfo(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
    _InterpolatedPosition position,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.route_rounded,
              size: 14,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '${position.fromPort} → ${position.toPort}',
                style: textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Estimated based on itinerary',
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isLoading;
  final LivePosition? livePosition;
  final bool isEstimated;

  const _StatusBadge({
    required this.isLoading,
    required this.livePosition,
    required this.isEstimated,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildBadge(
        context,
        color: Colors.grey,
        text: '...',
      );
    }

    if (livePosition != null) {
      final status = livePosition!.status;
      switch (status) {
        case PositionStatus.live:
          return _buildBadge(
            context,
            color: Colors.green,
            text: 'Live',
            icon: Icons.circle,
          );
        case PositionStatus.recent:
          return _buildBadge(
            context,
            color: Colors.orange,
            text: livePosition!.statusLabel,
            icon: Icons.schedule_rounded,
          );
        case PositionStatus.estimated:
          return _buildBadge(
            context,
            color: Colors.grey,
            text: 'Estimated',
            icon: Icons.gps_off_rounded,
          );
      }
    }

    return _buildBadge(
      context,
      color: Colors.grey,
      text: 'Estimated',
      icon: Icons.gps_off_rounded,
    );
  }

  Widget _buildBadge(
    BuildContext context, {
    required Color color,
    required String text,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 10,
              color: color,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _InterpolatedPosition {
  final double latitude;
  final double longitude;
  final String fromPort;
  final String toPort;

  const _InterpolatedPosition({
    required this.latitude,
    required this.longitude,
    required this.fromPort,
    required this.toPort,
  });
}

class _MapControlButton extends StatelessWidget {
  const _MapControlButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.6),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}

class _ProfileButton extends StatelessWidget {
  const _ProfileButton({
    required this.onTap,
    this.isMapStyle = false,
  });

  final VoidCallback onTap;
  final bool isMapStyle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isMapStyle
              ? Colors.white.withOpacity(0.2)
              : colorScheme.primaryContainer,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.person_rounded,
          color: isMapStyle ? Colors.white : colorScheme.onPrimaryContainer,
          size: 20,
        ),
      ),
    );
  }
}
