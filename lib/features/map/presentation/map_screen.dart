import 'package:flutter/material.dart';
import 'package:cruisyapp/l10n/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

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
                color: colorScheme.surface.withValues(alpha: 0.9),
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
                    Colors.black.withValues(alpha: 0.7),
                    Colors.black.withValues(alpha: 0.3),
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
                                color: Colors.white.withValues(alpha: 0.7),
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
        ],
      ),
    );
  }
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
      color: Colors.black.withValues(alpha: 0.6),
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
              ? Colors.white.withValues(alpha: 0.2)
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
