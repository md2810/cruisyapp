import 'package:flutter/material.dart';
import 'package:cruisyapp/l10n/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/providers/share_provider.dart';
import '../../../core/providers/trip_provider.dart';
import '../../../shared/models/shared_trip.dart';

class FriendsScreen extends ConsumerWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final sharedTripsAsync = ref.watch(sharedTripsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(l10n.friends),
      ),
      body: sharedTripsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load shared trips',
                  style: textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                FilledButton.tonal(
                  onPressed: () => ref.refresh(sharedTripsStreamProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (sharedTrips) {
          if (sharedTrips.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
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
                        Icons.group_rounded,
                        size: 48,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.noSharedTrips,
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.noSharedTripsSubtitle,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sharedTrips.length,
            itemBuilder: (context, index) {
              final sharedTrip = sharedTrips[index];
              return _SharedTripCard(sharedTrip: sharedTrip);
            },
          );
        },
      ),
    );
  }
}

class _SharedTripCard extends ConsumerWidget {
  final SharedTrip sharedTrip;

  const _SharedTripCard({required this.sharedTrip});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('MMM d, yyyy');

    final trip = sharedTrip.trip;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: colorScheme.surfaceContainerHigh,
      child: InkWell(
        onTap: () => _showTripDetails(context, ref),
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with ship name and read-only badge
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trip.shipName,
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          trip.tripName,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.visibility_rounded,
                          size: 14,
                          color: colorScheme.onSecondaryContainer,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          l10n.readOnly,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Trip info row
              Row(
                children: [
                  Icon(
                    Icons.calendar_month_rounded,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${dateFormat.format(trip.departureDate)} - ${dateFormat.format(trip.arrivalDate)}',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.route_rounded,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${trip.startPort} → ${trip.endPort}',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Owner info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: colorScheme.primaryContainer,
                      child: Text(
                        sharedTrip.ownerName.isNotEmpty
                            ? sharedTrip.ownerName[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.sharedBy(sharedTrip.ownerName),
                            style: textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            l10n.importedOn(dateFormat.format(sharedTrip.importedAt)),
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert_rounded,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      onSelected: (value) => _handleAction(context, ref, value),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'duplicate',
                          child: Row(
                            children: [
                              Icon(Icons.copy_rounded, color: colorScheme.primary),
                              const SizedBox(width: 12),
                              Text(l10n.duplicateToMyTrips),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        PopupMenuItem(
                          value: 'remove',
                          child: Row(
                            children: [
                              Icon(Icons.delete_rounded, color: colorScheme.error),
                              const SizedBox(width: 12),
                              Text(
                                l10n.removeSharedTrip,
                                style: TextStyle(color: colorScheme.error),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTripDetails(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('EEE, MMM d');
    final timeFormat = DateFormat('HH:mm');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              l10n.sharedTrip,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            sharedTrip.trip.shipName,
                            style: GoogleFonts.outfit(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            sharedTrip.trip.tripName,
                            style: textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.sailing_rounded,
                      size: 48,
                      color: colorScheme.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Itinerary
                Text(
                  l10n.itinerary,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                ...sharedTrip.trip.stops.map((stop) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    color: stop.isSeaDay
                        ? colorScheme.secondaryContainer.withOpacity(0.5)
                        : colorScheme.surfaceContainerHigh,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(
                            stop.isSeaDay
                                ? Icons.waves_rounded
                                : Icons.location_on_rounded,
                            color: stop.isSeaDay
                                ? colorScheme.secondary
                                : colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  stop.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (stop.arrivalTime != null)
                                  Text(
                                    stop.departureTime != null
                                        ? '${dateFormat.format(stop.arrivalTime!)} • ${timeFormat.format(stop.arrivalTime!)} - ${timeFormat.format(stop.departureTime!)}'
                                        : dateFormat.format(stop.arrivalTime!),
                                    style: textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _handleAction(context, ref, 'duplicate');
                        },
                        icon: const Icon(Icons.copy_rounded),
                        label: Text(l10n.duplicateToMyTrips),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _handleAction(BuildContext context, WidgetRef ref, String action) async {
    switch (action) {
      case 'duplicate':
        await _duplicateTrip(context, ref);
        break;
      case 'remove':
        await _removeTrip(context, ref);
        break;
    }
  }

  Future<void> _duplicateTrip(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final shareService = ref.read(shareServiceProvider);
    final tripService = ref.read(tripServiceProvider);

    if (shareService == null || tripService == null) return;

    try {
      final newTrip = await shareService.duplicateSharedTrip(sharedTrip);
      await tripService.addTrip(newTrip);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.tripDuplicated),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to duplicate: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _removeTrip(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text(l10n.removeSharedTrip),
        content: Text(l10n.removeSharedTripConfirmation),
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
            child: Text(l10n.removeSharedTrip),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final shareService = ref.read(shareServiceProvider);
      if (shareService == null) return;

      try {
        await shareService.deleteSharedTrip(sharedTrip.id);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to remove: $e'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }
}
