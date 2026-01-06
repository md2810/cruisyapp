import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cruisyapp/l10n/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/providers/trip_provider.dart';
import '../../../shared/models/cruise_trip.dart';
import '../../../shared/ui/profile_button.dart';

class TripsScreen extends ConsumerWidget {
  const TripsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcomingTrips = ref.watch(upcomingTripsProvider);
    final pastTrips = ref.watch(pastTripsProvider);
    final tripsAsync = ref.watch(tripsStreamProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            expandedHeight: 160,
            title: Text(
              l10n.myVoyages,
              style: GoogleFonts.outfit(
                fontSize: 32,
                fontWeight: FontWeight.w800,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: ProfileButton(
                  onTap: () => context.push('/settings'),
                ),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: tripsAsync.when(
              loading: () => SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    color: colorScheme.primary,
                  ),
                ),
              ),
              error: (error, stack) => SliverFillRemaining(
                child: _buildErrorState(context, l10n),
              ),
              data: (trips) {
                if (upcomingTrips.isEmpty && pastTrips.isEmpty) {
                  return SliverFillRemaining(
                    child: _buildEmptyState(context, l10n),
                  );
                }
                return SliverList(
                  delegate: SliverChildListDelegate([
                    if (upcomingTrips.isNotEmpty) ...[
                      _buildSectionTitle(context, l10n.upcoming),
                      const SizedBox(height: 12),
                      ...upcomingTrips.map((trip) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _buildDismissibleTripCard(context, ref, trip, l10n, isUpcoming: true),
                          )),
                      const SizedBox(height: 24),
                    ],
                    if (pastTrips.isNotEmpty) ...[
                      _buildSectionTitle(context, l10n.pastTrips),
                      const SizedBox(height: 12),
                      ...pastTrips.map((trip) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _buildDismissibleTripCard(context, ref, trip, l10n, isUpcoming: false),
                          )),
                    ],
                    const SizedBox(height: 100),
                  ]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/trip/add'),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.addTrip),
      ),
    );
  }

  Widget _buildDismissibleTripCard(
    BuildContext context,
    WidgetRef ref,
    CruiseTrip trip,
    AppLocalizations l10n, {
    required bool isUpcoming,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dismissible(
      key: Key(trip.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) => _confirmDelete(context, trip, l10n),
      onDismissed: (direction) async {
        try {
          final tripService = ref.read(tripServiceProvider);
          if (tripService != null) {
            await tripService.deleteTrip(trip.id);
            if (context.mounted) {
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
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: colorScheme.error,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Icon(
          Icons.delete_rounded,
          color: colorScheme.onError,
          size: 28,
        ),
      ),
      child: _buildTripCard(context, ref, trip, l10n, isUpcoming: isUpcoming),
    );
  }

  Future<bool> _confirmDelete(BuildContext context, CruiseTrip trip, AppLocalizations l10n) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteTrip),
        content: Text(l10n.deleteTripConfirmation(trip.shipName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Widget _buildErrorState(BuildContext context, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.failedToLoadTrips,
            style: textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.checkConnection,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.sailing_rounded,
                size: 64,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              l10n.noVoyagesYet,
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.startTrackingCruises,
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => context.push('/trip/add'),
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.addFirstTrip),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final textTheme = Theme.of(context).textTheme;

    return Text(
      title,
      style: textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTripCard(
    BuildContext context,
    WidgetRef ref,
    CruiseTrip trip,
    AppLocalizations l10n, {
    required bool isUpcoming,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final dateFormat = DateFormat('MMM d, yyyy');

    return Card(
      color: colorScheme.surfaceContainerHigh,
      child: InkWell(
        onTap: () => context.push('/trip-detail/${trip.id}'),
        onLongPress: () => _showTripOptions(context, ref, trip),
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: CachedNetworkImage(
                    imageUrl: trip.imageUrl ??
                        'https://images.unsplash.com/photo-1548574505-5e239809ee19?q=80&w=200&auto=format&fit=crop',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.sailing_rounded,
                        color: colorScheme.primary.withOpacity(0.5),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: colorScheme.surfaceContainerHighest,
                      child: Icon(
                        isUpcoming ? Icons.sailing_rounded : Icons.check_rounded,
                        color: colorScheme.primary.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.shipName,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      trip.tripName,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      dateFormat.format(trip.departureDate),
                      style: textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isUpcoming
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isUpcoming)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${trip.daysUntilDeparture}d',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: 20,
                    color: colorScheme.onSurfaceVariant,
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
                onSelected: (value) => _handleMenuAction(context, ref, trip, l10n, value),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_rounded, color: colorScheme.primary),
                        const SizedBox(width: 12),
                        Text(l10n.editTrip),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_rounded, color: colorScheme.error),
                        const SizedBox(width: 12),
                        Text(l10n.delete, style: TextStyle(color: colorScheme.error)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleMenuAction(
    BuildContext context,
    WidgetRef ref,
    CruiseTrip trip,
    AppLocalizations l10n,
    String action,
  ) {
    switch (action) {
      case 'edit':
        context.push('/trip/edit/${trip.id}');
        break;
      case 'delete':
        _deleteTrip(context, ref, trip, l10n);
        break;
    }
  }

  Future<void> _deleteTrip(BuildContext context, WidgetRef ref, CruiseTrip trip, AppLocalizations l10n) async {
    final confirmed = await _confirmDelete(context, trip, l10n);
    if (confirmed && context.mounted) {
      try {
        final tripService = ref.read(tripServiceProvider);
        if (tripService != null) {
          await tripService.deleteTrip(trip.id);
          if (context.mounted) {
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

  void _showTripOptions(BuildContext context, WidgetRef ref, CruiseTrip trip) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              trip.shipName,
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Icon(Icons.visibility_rounded, color: colorScheme.primary),
              title: Text(l10n.viewDetails),
              onTap: () {
                Navigator.pop(sheetContext);
                context.push('/trip-detail/${trip.id}');
              },
            ),
            ListTile(
              leading: Icon(Icons.edit_rounded, color: colorScheme.primary),
              title: Text(l10n.editTrip),
              onTap: () {
                Navigator.pop(sheetContext);
                context.push('/trip/edit/${trip.id}');
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_rounded, color: colorScheme.error),
              title: Text(l10n.deleteTrip, style: TextStyle(color: colorScheme.error)),
              onTap: () {
                Navigator.pop(sheetContext);
                _deleteTrip(context, ref, trip, l10n);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
