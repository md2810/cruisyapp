import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cruisyapp/l10n/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../../core/providers/trip_provider.dart';
import '../../../shared/models/cruise_trip.dart';

// Filter options for cruise list
enum CruiseFilter { past, future, today }

// Provider for sheet filter state - smart default
final cruiseFilterProvider = StateProvider<CruiseFilter>((ref) {
  final trips = ref.watch(tripsProvider);
  final hasOngoingCruise = trips.any((t) => t.isOngoing);
  return hasOngoingCruise ? CruiseFilter.today : CruiseFilter.future;
});

// Provider to check if there's an ongoing cruise
final hasOngoingCruiseProvider = Provider<bool>((ref) {
  final trips = ref.watch(tripsProvider);
  return trips.any((t) => t.isOngoing);
});

// Provider for the ongoing cruise (if any)
final ongoingCruiseProvider = Provider<CruiseTrip?>((ref) {
  final trips = ref.watch(tripsProvider);
  try {
    return trips.firstWhere((t) => t.isOngoing);
  } catch (e) {
    return null;
  }
});

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final DraggableScrollableController _sheetController = DraggableScrollableController();

  // Snap points: 20%, 40%, 90%
  static const double _minExtent = 0.20;
  static const double _midExtent = 0.40;
  static const double _maxExtent = 0.90;

  bool _isMapInteracting = false;

  // Map and annotation managers
  PolylineAnnotationManager? _routeAnnotationManager;
  CircleAnnotationManager? _shipAnnotationManager;

  // Timer for updating ship position
  Timer? _shipPositionTimer;

  @override
  void dispose() {
    _sheetController.dispose();
    _shipPositionTimer?.cancel();
    super.dispose();
  }

  void _onMapCreated(MapboxMap mapboxMap) async {
    // Configure Mapbox ornaments for compact display
    mapboxMap.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
    mapboxMap.logo.updateSettings(LogoSettings(
      enabled: true,
      position: OrnamentPosition.TOP_LEFT,
      marginLeft: 16,
      marginTop: 48,
    ));
    mapboxMap.attribution.updateSettings(AttributionSettings(
      enabled: true,
      position: OrnamentPosition.TOP_LEFT,
      marginLeft: 100,
      marginTop: 52,
    ));

    // Set globe projection
    mapboxMap.style.setProjection(StyleProjection(name: StyleProjectionName.globe));

    // Set initial camera
    mapboxMap.setCamera(
      CameraOptions(
        center: Point(coordinates: Position(10.0, 35.0)),
        zoom: 1.0,
        pitch: 0.0,
      ),
    );

    // Create annotation managers
    _routeAnnotationManager = await mapboxMap.annotations.createPolylineAnnotationManager();
    _shipAnnotationManager = await mapboxMap.annotations.createCircleAnnotationManager();

    // Initial route update
    _updateMapAnnotations();

    // Start timer to update ship position every minute
    _shipPositionTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _updateShipPosition();
    });
  }

  void _updateMapAnnotations() {
    final filter = ref.read(cruiseFilterProvider);
    final allTrips = ref.read(tripsProvider);

    // Clear existing annotations
    _routeAnnotationManager?.deleteAll();
    _shipAnnotationManager?.deleteAll();

    List<CruiseTrip> tripsToShow;

    switch (filter) {
      case CruiseFilter.past:
        tripsToShow = allTrips.where((t) => t.isCompleted).toList();
        break;
      case CruiseFilter.future:
        tripsToShow = allTrips.where((t) => t.isUpcoming).toList();
        break;
      case CruiseFilter.today:
        tripsToShow = allTrips.where((t) => t.isOngoing).toList();
        break;
    }

    // Add route lines for each trip
    for (final trip in tripsToShow) {
      _addCruiseRoute(trip, filter == CruiseFilter.today);
    }

    // Add ship marker if showing today's cruise
    if (filter == CruiseFilter.today) {
      _updateShipPosition();
    }
  }

  void _addCruiseRoute(CruiseTrip trip, bool showProgress) {
    if (_routeAnnotationManager == null) return;

    // Get port stops with coordinates (excluding sea days)
    final portsWithCoords = trip.stops
        .where((s) => !s.isSeaDay && s.latitude != null && s.longitude != null)
        .toList();

    if (portsWithCoords.length < 2) return;

    if (showProgress) {
      // Split into past and future segments for ongoing cruise
      final now = DateTime.now();

      // Find the current segment
      int currentSegmentEnd = 0;
      for (int i = 0; i < portsWithCoords.length; i++) {
        final stop = portsWithCoords[i];
        if (stop.departureTime != null && now.isAfter(stop.departureTime!)) {
          currentSegmentEnd = i + 1;
        } else if (stop.arrivalTime != null && now.isAfter(stop.arrivalTime!)) {
          currentSegmentEnd = i + 1;
        }
      }

      // Past route (bright)
      if (currentSegmentEnd > 0) {
        final pastCoords = portsWithCoords
            .take(currentSegmentEnd + 1)
            .map((s) => Position(s.longitude!, s.latitude!))
            .toList();

        if (pastCoords.length >= 2) {
          _routeAnnotationManager!.create(
            PolylineAnnotationOptions(
              geometry: LineString(coordinates: pastCoords),
              lineColor: 0xFF4FC3F7, // Bright cyan
              lineWidth: 3.0,
              lineOpacity: 1.0,
            ),
          );
        }
      }

      // Future route (transparent)
      if (currentSegmentEnd < portsWithCoords.length - 1) {
        final futureCoords = portsWithCoords
            .skip(currentSegmentEnd > 0 ? currentSegmentEnd : 0)
            .map((s) => Position(s.longitude!, s.latitude!))
            .toList();

        if (futureCoords.length >= 2) {
          _routeAnnotationManager!.create(
            PolylineAnnotationOptions(
              geometry: LineString(coordinates: futureCoords),
              lineColor: 0xFF4FC3F7, // Same cyan but transparent
              lineWidth: 2.5,
              lineOpacity: 0.4,
            ),
          );
        }
      }
    } else {
      // Full route (single color based on past/future)
      final coords = portsWithCoords
          .map((s) => Position(s.longitude!, s.latitude!))
          .toList();

      final isPast = trip.isCompleted;

      _routeAnnotationManager!.create(
        PolylineAnnotationOptions(
          geometry: LineString(coordinates: coords),
          lineColor: isPast ? 0xFF81C784 : 0xFF4FC3F7, // Green for past, cyan for future
          lineWidth: 2.5,
          lineOpacity: isPast ? 0.8 : 0.6,
        ),
      );
    }
  }

  void _updateShipPosition() {
    if (_shipAnnotationManager == null) return;

    final ongoingCruise = ref.read(ongoingCruiseProvider);
    if (ongoingCruise == null) {
      _shipAnnotationManager!.deleteAll();
      return;
    }

    final position = _calculateShipPosition(ongoingCruise);
    if (position == null) return;

    _shipAnnotationManager!.deleteAll();

    // Create ship marker as a styled circle with outer ring
    _shipAnnotationManager!.create(
      CircleAnnotationOptions(
        geometry: Point(coordinates: position),
        circleColor: 0xFFFFFFFF, // White center
        circleRadius: 8.0,
        circleStrokeColor: 0xFF1976D2, // Blue border
        circleStrokeWidth: 3.0,
        circleOpacity: 1.0,
      ),
    );
  }

  Position? _calculateShipPosition(CruiseTrip cruise) {
    final now = DateTime.now();

    // Get port stops with coordinates (excluding sea days)
    final portsWithCoords = cruise.stops
        .where((s) => !s.isSeaDay && s.latitude != null && s.longitude != null)
        .toList();

    if (portsWithCoords.isEmpty) return null;

    // Check if we're at a port
    for (final stop in portsWithCoords) {
      if (stop.arrivalTime != null && stop.departureTime != null) {
        if (now.isAfter(stop.arrivalTime!) && now.isBefore(stop.departureTime!)) {
          // Ship is docked at this port
          return Position(stop.longitude!, stop.latitude!);
        }
      }
    }

    // Check if we're between ports
    for (int i = 0; i < portsWithCoords.length - 1; i++) {
      final currentPort = portsWithCoords[i];
      final nextPort = portsWithCoords[i + 1];

      final departureTime = currentPort.departureTime;
      final arrivalTime = nextPort.arrivalTime;

      if (departureTime != null && arrivalTime != null) {
        if (now.isAfter(departureTime) && now.isBefore(arrivalTime)) {
          // Ship is between these two ports - interpolate position
          final totalDuration = arrivalTime.difference(departureTime).inMinutes;
          final elapsed = now.difference(departureTime).inMinutes;
          final progress = (elapsed / totalDuration).clamp(0.0, 1.0);

          // Linear interpolation (good enough for display purposes)
          final lat = currentPort.latitude! +
              (nextPort.latitude! - currentPort.latitude!) * progress;
          final lon = currentPort.longitude! +
              (nextPort.longitude! - currentPort.longitude!) * progress;

          return Position(lon, lat);
        }
      }
    }

    // Default: return first port if before cruise, last port if after
    if (portsWithCoords.first.arrivalTime != null &&
        now.isBefore(portsWithCoords.first.arrivalTime!)) {
      return Position(portsWithCoords.first.longitude!, portsWithCoords.first.latitude!);
    }

    return Position(portsWithCoords.last.longitude!, portsWithCoords.last.latitude!);
  }

  void _collapseSheet() {
    if (_sheetController.isAttached && _sheetController.size > _minExtent) {
      _sheetController.animateTo(
        _minExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to filter changes and update map
    ref.listen(cruiseFilterProvider, (previous, next) {
      _updateMapAnnotations();
    });

    // Listen to trip changes and update map
    ref.listen(tripsProvider, (previous, next) {
      _updateMapAnnotations();
    });

    return Scaffold(
      body: Stack(
        children: [
          // Map background
          Listener(
            onPointerDown: (_) {
              if (!_isMapInteracting) {
                _isMapInteracting = true;
                _collapseSheet();
              }
            },
            onPointerUp: (_) {
              _isMapInteracting = false;
            },
            child: SizedBox.expand(
              child: Container(
                color: const Color(0xFF0a1929),
                child: MapWidget(
                  onMapCreated: _onMapCreated,
                  styleUri: MapboxStyles.DARK,
                  cameraOptions: CameraOptions(
                    center: Point(coordinates: Position(10.0, 35.0)),
                    zoom: 1.0,
                    pitch: 0.0,
                  ),
                ),
              ),
            ),
          ),
          // Draggable sheet
          NotificationListener<DraggableScrollableNotification>(
            onNotification: (notification) {
              return false;
            },
            child: DraggableScrollableSheet(
              controller: _sheetController,
              initialChildSize: _midExtent,
              minChildSize: _minExtent,
              maxChildSize: _maxExtent,
              snap: true,
              snapSizes: const [_minExtent, _midExtent, _maxExtent],
              builder: (context, scrollController) {
                return _CruiseSheet(
                  scrollController: scrollController,
                  sheetController: _sheetController,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CruiseSheet extends ConsumerWidget {
  const _CruiseSheet({
    required this.scrollController,
    required this.sheetController,
  });

  final ScrollController scrollController;
  final DraggableScrollableController sheetController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final filter = ref.watch(cruiseFilterProvider);
    final allTrips = ref.watch(tripsProvider);
    final hasOngoing = ref.watch(hasOngoingCruiseProvider);

    // Filter trips based on selection
    List<CruiseTrip> trips;
    switch (filter) {
      case CruiseFilter.past:
        trips = allTrips.where((t) => t.isCompleted).toList()
          ..sort((a, b) => b.departureDate.compareTo(a.departureDate));
        break;
      case CruiseFilter.future:
        trips = allTrips.where((t) => t.isUpcoming).toList()
          ..sort((a, b) => a.departureDate.compareTo(b.departureDate));
        break;
      case CruiseFilter.today:
        trips = allTrips.where((t) => t.isOngoing).toList();
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 16, 8),
            child: Row(
              children: [
                // Dropdown for filter
                _FilterDropdown(filter: filter, hasOngoing: hasOngoing),
                const Spacer(),
                // Add cruise button
                IconButton(
                  onPressed: () => context.push('/trip/add'),
                  icon: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add_rounded,
                      color: colorScheme.onPrimaryContainer,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                // Profile button
                IconButton(
                  onPressed: () => context.push('/settings'),
                  icon: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_rounded,
                      color: colorScheme.onPrimaryContainer,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Cruise list
          Expanded(
            child: trips.isEmpty
                ? _EmptyState(filter: filter)
                : ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    itemCount: trips.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _CruiseCard(trip: trips[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterDropdown extends ConsumerWidget {
  const _FilterDropdown({required this.filter, required this.hasOngoing});

  final CruiseFilter filter;
  final bool hasOngoing;

  String _getFilterLabel(BuildContext context, CruiseFilter f) {
    final l10n = AppLocalizations.of(context)!;
    switch (f) {
      case CruiseFilter.past:
        return l10n.pastCruises;
      case CruiseFilter.future:
        return l10n.futureCruises;
      case CruiseFilter.today:
        return l10n.today;
    }
  }

  IconData _getFilterIcon(CruiseFilter f) {
    switch (f) {
      case CruiseFilter.past:
        return Icons.history_rounded;
      case CruiseFilter.future:
        return Icons.schedule_rounded;
      case CruiseFilter.today:
        return Icons.sailing_rounded;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    // Build menu items - only show "Today" if there's an ongoing cruise
    final menuItems = <PopupMenuItem<CruiseFilter>>[];

    if (hasOngoing) {
      menuItems.add(
        PopupMenuItem(
          value: CruiseFilter.today,
          child: _FilterMenuItem(
            icon: _getFilterIcon(CruiseFilter.today),
            label: _getFilterLabel(context, CruiseFilter.today),
            isSelected: filter == CruiseFilter.today,
          ),
        ),
      );
    }

    menuItems.add(
      PopupMenuItem(
        value: CruiseFilter.future,
        child: _FilterMenuItem(
          icon: _getFilterIcon(CruiseFilter.future),
          label: _getFilterLabel(context, CruiseFilter.future),
          isSelected: filter == CruiseFilter.future,
        ),
      ),
    );

    menuItems.add(
      PopupMenuItem(
        value: CruiseFilter.past,
        child: _FilterMenuItem(
          icon: _getFilterIcon(CruiseFilter.past),
          label: _getFilterLabel(context, CruiseFilter.past),
          isSelected: filter == CruiseFilter.past,
        ),
      ),
    );

    return PopupMenuButton<CruiseFilter>(
      initialValue: filter,
      onSelected: (value) {
        ref.read(cruiseFilterProvider.notifier).state = value;
      },
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _getFilterLabel(context, filter),
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            color: colorScheme.onSurfaceVariant,
          ),
        ],
      ),
      itemBuilder: (context) => menuItems,
    );
  }
}

class _FilterMenuItem extends StatelessWidget {
  const _FilterMenuItem({
    required this.icon,
    required this.label,
    required this.isSelected,
  });

  final IconData icon;
  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(
          icon,
          color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
          size: 20,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.filter});

  final CruiseFilter filter;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    String message;
    String subtitle;
    IconData icon;

    switch (filter) {
      case CruiseFilter.past:
        icon = Icons.history_rounded;
        message = l10n.noPastCruises;
        subtitle = l10n.completedCruisesAppearHere;
        break;
      case CruiseFilter.future:
        icon = Icons.schedule_rounded;
        message = l10n.noUpcomingCruises;
        subtitle = l10n.tapPlusToAddCruise;
        break;
      case CruiseFilter.today:
        icon = Icons.sailing_rounded;
        message = l10n.noCruiseToday;
        subtitle = l10n.noOngoingCruises;
        break;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CruiseCard extends StatelessWidget {
  const _CruiseCard({required this.trip});

  final CruiseTrip trip;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      color: colorScheme.surfaceContainerHigh,
      child: InkWell(
        onTap: () => context.push('/trip-detail/${trip.id}'),
        child: SizedBox(
          height: 100,
          child: Row(
            children: [
              // Left quarter: Countdown
              Container(
                width: 100,
                color: colorScheme.primaryContainer,
                child: _CountdownSection(trip: trip),
              ),
              // Right 3/4: Trip info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Ship name
                      Text(
                        trip.shipName,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      // Port info
                      _PortInfo(trip: trip),
                    ],
                  ),
                ),
              ),
              // Chevron
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountdownSection extends StatelessWidget {
  const _CountdownSection({required this.trip});

  final CruiseTrip trip;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    String countText;
    String labelText;

    if (trip.isCompleted) {
      countText = '\u2713';
      labelText = l10n.done;
    } else if (trip.isOngoing) {
      countText = '${trip.currentDay}';
      labelText = l10n.day;
    } else {
      final days = trip.daysUntilDeparture;
      countText = '$days';
      labelText = days == 1 ? l10n.day : l10n.days;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          countText,
          style: GoogleFonts.outfit(
            fontSize: trip.isCompleted ? 36 : 42,
            fontWeight: FontWeight.w800,
            color: colorScheme.onPrimaryContainer,
            height: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          labelText,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
            color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

class _PortInfo extends StatelessWidget {
  const _PortInfo({required this.trip});

  final CruiseTrip trip;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    // For ongoing trips, show next/today's port
    if (trip.isOngoing) {
      final currentStop = trip.currentStop;
      final nextStop = trip.nextStop;

      if (currentStop != null && !currentStop.isSeaDay) {
        return Row(
          children: [
            Icon(
              Icons.location_on_rounded,
              size: 16,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                l10n.todayPort(currentStop.name),
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      } else if (nextStop != null) {
        return Row(
          children: [
            Icon(
              Icons.navigation_rounded,
              size: 16,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                l10n.nextPort(nextStop.name),
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      }
    }

    // Default: Show start -> end port
    return Row(
      children: [
        Expanded(
          child: Text(
            '${trip.startPort} \u2192 ${trip.endPort}',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
