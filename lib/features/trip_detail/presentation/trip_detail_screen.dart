import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/providers/trip_provider.dart';
import '../../../shared/models/cruise_trip.dart';
import '../../../shared/models/port_stop.dart';

class TripDetailScreen extends ConsumerWidget {
  const TripDetailScreen({
    super.key,
    required this.tripId,
  });

  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trip = ref.watch(tripByIdProvider(tripId));
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    if (trip == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.sailing_rounded,
                  size: 48,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.tripNotFound,
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.voyageMayBeDeleted,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_rounded),
                label: Text(l10n.goBack),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero App Bar with Background Image
          SliverAppBar.large(
            expandedHeight: 280,
            pinned: true,
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: trip.imageUrl ??
                        'https://images.unsplash.com/photo-1548574505-5e239809ee19?q=80&w=1000&auto=format&fit=crop',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: colorScheme.surfaceContainerHighest,
                      child: Center(
                        child: CircularProgressIndicator(color: colorScheme.primary),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.sailing_rounded,
                        size: 64,
                        color: colorScheme.primary.withOpacity(0.5),
                      ),
                    ),
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                          colorScheme.surface.withOpacity(0.9),
                          colorScheme.surface,
                        ],
                        stops: const [0.0, 0.4, 0.8, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
              title: Text(
                trip.shipName,
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
            ),
            actions: [
              // Popup Menu for Edit/Delete
              PopupMenuButton<String>(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.more_vert_rounded, color: Colors.white),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                onSelected: (value) => _handleMenuAction(context, ref, trip, value),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_rounded, color: colorScheme.primary),
                        const SizedBox(width: 12),
                        Text(l10n.editTripMenu),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'share',
                    child: Row(
                      children: [
                        Icon(Icons.share_rounded, color: colorScheme.onSurface),
                        const SizedBox(width: 12),
                        Text(l10n.shareMenu),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_rounded, color: colorScheme.error),
                        const SizedBox(width: 12),
                        Text(l10n.deleteTripMenu, style: TextStyle(color: colorScheme.error)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
            ],
          ),
          // Content
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Trip Name Subtitle
                Text(
                  trip.tripName,
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),

                // Bento Grid Row 1: Days Until + Next Port
                _buildBentoRow1(context, trip),
                const SizedBox(height: 16),

                // Bento Grid Row 2: Progress + Duration
                _buildBentoRow2(context, trip),
                const SizedBox(height: 32),

                // Itinerary Section
                _buildItinerarySection(context, trip),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(BuildContext context, WidgetRef ref, CruiseTrip trip, String action) {
    final l10n = AppLocalizations.of(context)!;
    switch (action) {
      case 'edit':
        context.push('/trip/edit/${trip.id}');
        break;
      case 'share':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.shareComingSoon),
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
      case 'delete':
        _confirmDelete(context, ref, trip);
        break;
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, CruiseTrip trip) async {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text(l10n.deleteTripMenu),
        content: Text(l10n.deleteTripConfirmation(trip.shipName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final tripService = ref.read(tripServiceProvider);
        if (tripService != null) {
          await tripService.deleteTrip(trip.id);
          if (context.mounted) {
            context.pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.tripDeleted(trip.shipName)),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.failedToDelete(e.toString())),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  Widget _buildBentoRow1(BuildContext context, CruiseTrip trip) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final daysUntil = trip.daysUntilDeparture;
    final nextPort = trip.stops.isNotEmpty ? trip.stops.first : null;

    return Row(
      children: [
        // Days Until Card (Large)
        Expanded(
          flex: 3,
          child: Card(
            color: colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        trip.isOngoing ? Icons.sailing_rounded : Icons.schedule_rounded,
                        color: colorScheme.onPrimaryContainer,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        trip.isOngoing ? l10n.voyageInProgress : l10n.daysUntil,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                          color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    trip.isCompleted ? l10n.done : (trip.isOngoing ? l10n.dayLabel(trip.currentDay) : '$daysUntil'),
                    style: GoogleFonts.outfit(
                      fontSize: trip.isOngoing ? 48 : 64,
                      fontWeight: FontWeight.w800,
                      height: 1,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  if (!trip.isOngoing && !trip.isCompleted) ...[
                    const SizedBox(height: 4),
                    Text(
                      l10n.daysLabel,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Next Port Card
        Expanded(
          flex: 2,
          child: Card(
            color: colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        color: colorScheme.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        trip.isUpcoming ? l10n.departs : l10n.nextLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    trip.isUpcoming ? trip.startPort : (nextPort?.name ?? trip.endPort),
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('MMM d').format(trip.isUpcoming ? trip.departureDate : trip.arrivalDate),
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBentoRow2(BuildContext context, CruiseTrip trip) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final progress = trip.progress;

    return Row(
      children: [
        // Progress Card
        Expanded(
          flex: 2,
          child: Card(
            color: colorScheme.surfaceContainerHigh,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.progress,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(trip, colorScheme).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getStatusText(trip, l10n),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(trip, colorScheme),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        trip.startPort,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.primary,
                        ),
                      ),
                      Text(
                        trip.endPort,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Duration Card
        Expanded(
          child: Card(
            color: colorScheme.tertiaryContainer.withOpacity(0.5),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.timer_outlined,
                    color: colorScheme.tertiary,
                    size: 24,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${trip.totalDays}',
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onTertiaryContainer,
                    ),
                  ),
                  Text(
                    l10n.daysLowercase,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onTertiaryContainer.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(CruiseTrip trip, ColorScheme colorScheme) {
    if (trip.isCompleted) return colorScheme.tertiary;
    if (trip.isOngoing) return colorScheme.primary;
    return colorScheme.secondary;
  }

  String _getStatusText(CruiseTrip trip, AppLocalizations l10n) {
    if (trip.isCompleted) return l10n.cruiseCompleted;
    if (trip.isOngoing) return l10n.inProgressStatus;
    return l10n.upcomingStatus;
  }

  Widget _buildItinerarySection(BuildContext context, CruiseTrip trip) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final tripDays = _getTripDays(trip);

    if (trip.stops.isEmpty) {
      return Card(
        color: colorScheme.surfaceContainerHigh,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.route_rounded,
                size: 48,
                color: colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.noItineraryYet,
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.editToAddPorts,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.tonal(
                onPressed: () => context.push('/trip/edit/${trip.id}'),
                child: Text(l10n.addStopsButton),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.itinerary,
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              l10n.daysCount(tripDays.length),
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildDayByDayItinerary(context, trip, tripDays),
      ],
    );
  }

  List<DateTime> _getTripDays(CruiseTrip trip) {
    final days = <DateTime>[];
    var current = DateTime(trip.departureDate.year, trip.departureDate.month, trip.departureDate.day);
    final end = DateTime(trip.arrivalDate.year, trip.arrivalDate.month, trip.arrivalDate.day);

    while (!current.isAfter(end)) {
      days.add(current);
      current = current.add(const Duration(days: 1));
    }
    return days;
  }

  PortStop? _getStopForDay(CruiseTrip trip, DateTime day) {
    for (final stop in trip.stops) {
      if (stop.arrivalTime == null) continue;

      final arrivalDay = DateTime(
        stop.arrivalTime!.year,
        stop.arrivalTime!.month,
        stop.arrivalTime!.day,
      );

      final departureDay = stop.departureTime != null
          ? DateTime(
              stop.departureTime!.year,
              stop.departureTime!.month,
              stop.departureTime!.day,
            )
          : arrivalDay;

      if (!day.isBefore(arrivalDay) && !day.isAfter(departureDay)) {
        return stop;
      }
    }
    return null;
  }

  Widget _buildDayByDayItinerary(BuildContext context, CruiseTrip trip, List<DateTime> days) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('EEE, MMM d');
    final timeFormat = DateFormat('HH:mm');
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: days.length,
      itemBuilder: (context, index) {
        final day = days[index];
        final stop = _getStopForDay(trip, day);
        final isToday = day.isAtSameMomentAs(today);
        final isPast = day.isBefore(today);

        // Check if this day is a continuation of a multi-day stay
        bool isContinuation = false;
        if (stop != null && stop.arrivalTime != null) {
          final arrivalDay = DateTime(
            stop.arrivalTime!.year,
            stop.arrivalTime!.month,
            stop.arrivalTime!.day,
          );
          isContinuation = day.isAfter(arrivalDay);
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          color: isToday
              ? colorScheme.primaryContainer.withOpacity(0.3)
              : (stop != null
                  ? (stop.isSeaDay
                      ? colorScheme.secondaryContainer.withOpacity(0.5)
                      : colorScheme.surfaceContainerHigh)
                  : colorScheme.surfaceContainerHighest.withOpacity(0.5)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Day number
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isToday
                        ? colorScheme.primary
                        : (stop != null
                            ? (stop.isSeaDay
                                ? colorScheme.secondary
                                : colorScheme.primaryContainer)
                            : colorScheme.surfaceContainerHigh),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${index + 1}',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isToday
                              ? colorScheme.onPrimary
                              : (stop != null
                                  ? (stop.isSeaDay
                                      ? colorScheme.onSecondary
                                      : colorScheme.onPrimaryContainer)
                                  : colorScheme.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Day info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            dateFormat.format(day),
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          if (isToday) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                l10n.todayBadge,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onPrimary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      if (stop != null) ...[
                        Text(
                          isContinuation
                              ? '${stop.name} ${l10n.continuedPort}'
                              : stop.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isToday ? colorScheme.primary : null,
                          ),
                        ),
                        if (!isContinuation &&
                            stop.arrivalTime != null &&
                            !stop.isSeaDay) ...[
                          const SizedBox(height: 2),
                          Text(
                            stop.departureTime != null
                                ? '${timeFormat.format(stop.arrivalTime!)} - ${timeFormat.format(stop.departureTime!)}'
                                : l10n.arrivesAt(timeFormat.format(stop.arrivalTime!)),
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ] else ...[
                        Text(
                          l10n.noActivityPlanned,
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Status icon
                if (stop != null)
                  Icon(
                    stop.isSeaDay ? Icons.waves_rounded : Icons.location_on_rounded,
                    color: isToday
                        ? colorScheme.primary
                        : (stop.isSeaDay
                            ? colorScheme.secondary
                            : colorScheme.onSurfaceVariant),
                    size: 20,
                  )
                else if (!isPast)
                  IconButton(
                    icon: Icon(
                      Icons.add_circle_outline_rounded,
                      color: colorScheme.primary.withOpacity(0.5),
                    ),
                    onPressed: () => context.push('/trip/edit/${trip.id}'),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
