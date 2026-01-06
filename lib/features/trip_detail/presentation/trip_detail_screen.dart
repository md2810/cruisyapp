import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/share_provider.dart';
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
                  color: colorScheme.primaryContainer.withValues(alpha: 0.3),
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
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
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
                        color: colorScheme.primary.withValues(alpha: 0.5),
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
                          Colors.black.withValues(alpha: 0.2),
                          colorScheme.surface.withValues(alpha: 0.95),
                          colorScheme.surface,
                        ],
                        stops: const [0.0, 0.5, 0.85, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              // Popup Menu for Edit/Delete
              PopupMenuButton<String>(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.more_vert_rounded, color: Colors.white, size: 20),
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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ship Name and Trip Name Header
                  _buildHeader(context, trip),
                  const SizedBox(height: 24),

                  // Status Hero Card
                  _buildHeroStatusCard(context, trip),
                  const SizedBox(height: 16),

                  // Quick Stats Row
                  _buildQuickStats(context, trip),
                  const SizedBox(height: 24),

                  // Journey Progress
                  _buildJourneyProgress(context, trip),
                  const SizedBox(height: 28),

                  // Itinerary Section
                  _buildItinerarySection(context, trip),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, CruiseTrip trip) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getStatusColor(trip, colorScheme).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getStatusIcon(trip),
                size: 14,
                color: _getStatusColor(trip, colorScheme),
              ),
              const SizedBox(width: 6),
              Text(
                _getStatusText(trip, l10n),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _getStatusColor(trip, colorScheme),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Ship Name
        Text(
          trip.shipName,
          style: GoogleFonts.outfit(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 4),

        // Trip Name
        Text(
          trip.tripName,
          style: TextStyle(
            fontSize: 16,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroStatusCard(BuildContext context, CruiseTrip trip) {
    if (trip.isCompleted) {
      return _buildCompletedCard(context, trip);
    }

    if (trip.isOngoing) {
      return _buildOngoingCard(context, trip);
    }

    return _buildUpcomingCard(context, trip);
  }

  Widget _buildUpcomingCard(BuildContext context, CruiseTrip trip) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final daysUntil = trip.daysUntilDeparture;
    final dateFormat = DateFormat('EEEE, MMMM d');

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer,
            colorScheme.primaryContainer.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.departureIn,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$daysUntil',
                        style: GoogleFonts.outfit(
                          fontSize: 56,
                          fontWeight: FontWeight.w800,
                          height: 1,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        daysUntil == 1 ? l10n.day : l10n.daysLabel,
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: colorScheme.onPrimaryContainer.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 14,
                          color: colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          dateFormat.format(trip.departureDate),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.onPrimaryContainer.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.sailing_rounded,
                size: 40,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOngoingCard(BuildContext context, CruiseTrip trip) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final currentDay = trip.currentDay;
    final currentStop = _getCurrentStop(trip);
    final nextStop = _getNextStop(trip);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.greenAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.liveVoyage,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  l10n.dayLabel(currentDay),
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (currentStop != null) ...[
              Text(
                currentStop.isSeaDay ? l10n.atSea : l10n.currentlyAt,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    currentStop.isSeaDay ? Icons.waves_rounded : Icons.location_on_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      currentStop.name,
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (nextStop != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white.withValues(alpha: 0.8),
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.nextStop,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                          Text(
                            nextStop.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (nextStop.arrivalTime != null)
                      Text(
                        DateFormat('MMM d').format(nextStop.arrivalTime!),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedCard(BuildContext context, CruiseTrip trip) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final portCount = trip.stops.where((s) => !s.isSeaDay).length;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.tertiaryContainer,
            colorScheme.tertiaryContainer.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.voyageComplete,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onTertiaryContainer.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.portsVisitedCount(portCount),
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onTertiaryContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.daysAtSeaCount(trip.totalDays),
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onTertiaryContainer.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colorScheme.onTertiaryContainer.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                size: 32,
                color: colorScheme.onTertiaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, CruiseTrip trip) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final portCount = trip.stops.where((s) => !s.isSeaDay).length;
    final seaDayCount = trip.stops.where((s) => s.isSeaDay).length;

    return Row(
      children: [
        // Duration
        Expanded(
          child: _StatChip(
            icon: Icons.schedule_rounded,
            value: '${trip.totalDays}',
            label: l10n.daysLowercase,
            color: colorScheme.secondary,
            backgroundColor: colorScheme.secondaryContainer,
          ),
        ),
        const SizedBox(width: 12),
        // Ports
        Expanded(
          child: _StatChip(
            icon: Icons.anchor_rounded,
            value: '$portCount',
            label: l10n.ports,
            color: colorScheme.primary,
            backgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(width: 12),
        // Sea Days
        Expanded(
          child: _StatChip(
            icon: Icons.waves_rounded,
            value: '$seaDayCount',
            label: l10n.seaDays,
            color: colorScheme.tertiary,
            backgroundColor: colorScheme.tertiaryContainer.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildJourneyProgress(BuildContext context, CruiseTrip trip) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final progress = trip.progress;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.journeyProgress,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(progress * 100).toInt()}%',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Custom progress track
          Stack(
            children: [
              // Background track
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              // Progress fill
              FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary,
                        colorScheme.primary.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              // Ship indicator
              if (trip.isOngoing)
                Positioned(
                  left: (MediaQuery.of(context).size.width - 80) * progress.clamp(0.0, 1.0) - 10,
                  top: -4,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: colorScheme.surface, width: 2),
                    ),
                    child: Icon(
                      Icons.sailing,
                      size: 10,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.startPort,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    DateFormat('MMM d').format(trip.departureDate),
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    trip.endPort,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    DateFormat('MMM d').format(trip.arrivalDate),
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  PortStop? _getCurrentStop(CruiseTrip trip) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

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

      if (!today.isBefore(arrivalDay) && !today.isAfter(departureDay)) {
        return stop;
      }
    }
    return null;
  }

  PortStop? _getNextStop(CruiseTrip trip) {
    final now = DateTime.now();

    for (final stop in trip.stops) {
      if (stop.arrivalTime == null || stop.isSeaDay) continue;

      if (stop.arrivalTime!.isAfter(now)) {
        return stop;
      }
    }
    return null;
  }

  void _handleMenuAction(BuildContext context, WidgetRef ref, CruiseTrip trip, String action) {
    switch (action) {
      case 'edit':
        context.push('/trip/edit/${trip.id}');
        break;
      case 'share':
        _shareTrip(context, ref, trip);
        break;
      case 'delete':
        _confirmDelete(context, ref, trip);
        break;
    }
  }

  Future<void> _shareTrip(BuildContext context, WidgetRef ref, CruiseTrip trip) async {
    final l10n = AppLocalizations.of(context)!;
    final shareService = ref.read(shareServiceProvider);
    final ownerName = ref.read(userDisplayNameProvider);

    if (shareService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.notAuthenticated),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      // Show loading indicator
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      await shareService.shareTrip(
        trip: trip,
        ownerName: ownerName,
      );

      // Close loading indicator
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Close loading indicator if still showing
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.failedToShare(e.toString())),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
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

  Color _getStatusColor(CruiseTrip trip, ColorScheme colorScheme) {
    if (trip.isCompleted) return colorScheme.tertiary;
    if (trip.isOngoing) return colorScheme.primary;
    return colorScheme.secondary;
  }

  IconData _getStatusIcon(CruiseTrip trip) {
    if (trip.isCompleted) return Icons.check_circle_rounded;
    if (trip.isOngoing) return Icons.sailing_rounded;
    return Icons.schedule_rounded;
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
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.route_rounded,
                size: 32,
                color: colorScheme.primary,
              ),
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
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.tonal(
              onPressed: () => context.push('/trip/edit/${trip.id}'),
              child: Text(l10n.addStopsButton),
            ),
          ],
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
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                l10n.daysCount(tripDays.length),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
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

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isToday
                ? colorScheme.primaryContainer.withValues(alpha: 0.4)
                : (stop != null
                    ? (stop.isSeaDay
                        ? colorScheme.secondaryContainer.withValues(alpha: 0.3)
                        : colorScheme.surfaceContainerHigh)
                    : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(16),
            border: isToday
                ? Border.all(color: colorScheme.primary, width: 2)
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Day number
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isToday
                        ? colorScheme.primary
                        : (stop != null
                            ? (stop.isSeaDay
                                ? colorScheme.secondary.withValues(alpha: 0.8)
                                : colorScheme.primaryContainer)
                            : colorScheme.surfaceContainerHigh),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
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
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: (stop.isSeaDay
                              ? colorScheme.secondary
                              : colorScheme.primary)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      stop.isSeaDay ? Icons.waves_rounded : Icons.location_on_rounded,
                      color: isToday
                          ? colorScheme.primary
                          : (stop.isSeaDay
                              ? colorScheme.secondary
                              : colorScheme.onSurfaceVariant),
                      size: 18,
                    ),
                  )
                else if (!isPast)
                  IconButton(
                    icon: Icon(
                      Icons.add_circle_outline_rounded,
                      color: colorScheme.primary.withValues(alpha: 0.5),
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

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final Color backgroundColor;

  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
