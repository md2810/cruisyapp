import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:cruisyapp/l10n/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/trip_provider.dart';
import '../../../main.dart';
import '../../../shared/models/cruise_trip.dart';
import '../../../shared/models/port_stop.dart';

// Year filter provider
final selectedYearProvider = StateProvider<int?>((ref) => null); // null = ALL-TIME

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userName = ref.watch(userDisplayNameProvider);
    final trips = ref.watch(tripsProvider);
    final selectedYear = ref.watch(selectedYearProvider);

    // Calculate stats based on selected year
    final stats = _calculateStats(trips, selectedYear);
    final years = _getAvailableYears(trips);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: _ProfileHeader(userName: userName, ref: ref),
            ),
            // Year Filter Tabs
            SliverToBoxAdapter(
              child: _YearFilterTabs(years: years, ref: ref),
            ),
            // Content
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Cruise Passport Card
                  _CruisePassportCard(stats: stats),
                  const SizedBox(height: 16),
                  // Longest Cruise Card
                  _LongestCruiseCard(
                    longestCruise: stats.longestCruise,
                    longestCruiseDays: stats.longestCruiseDays,
                  ),
                  const SizedBox(height: 16),
                  // Favorite Ship Card
                  _FavoriteShipCard(
                    favoriteShip: stats.favoriteShip,
                    favoriteShipCount: stats.favoriteShipCount,
                    allShips: stats.shipCounts,
                  ),
                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<int> _getAvailableYears(List<CruiseTrip> trips) {
    final years = <int>{};
    final currentYear = DateTime.now().year;

    for (final trip in trips) {
      years.add(trip.departureDate.year);
      years.add(trip.arrivalDate.year);
    }

    // Add current year and next year even if no trips
    years.add(currentYear);
    years.add(currentYear + 1);

    final sortedYears = years.toList()..sort((a, b) => b.compareTo(a));
    return sortedYears;
  }

  _CruiseStats _calculateStats(List<CruiseTrip> trips, int? selectedYear) {
    if (trips.isEmpty) {
      return _CruiseStats.empty();
    }

    int totalCruises = 0;
    double totalDays = 0;
    double totalDistanceNm = 0;
    final uniquePorts = <String>{};
    final shipCounts = <String, int>{};
    CruiseTrip? longestCruise;
    int longestCruiseDays = 0;

    for (final trip in trips) {
      // Check if trip falls within selected year (or all time)
      final tripStartYear = trip.departureDate.year;
      final tripEndYear = trip.arrivalDate.year;

      if (selectedYear != null) {
        // Skip if trip doesn't touch this year at all
        if (tripEndYear < selectedYear || tripStartYear > selectedYear) {
          continue;
        }
      }

      totalCruises++;

      // Calculate days (split if spans years)
      final tripDays = _calculateDaysForYear(trip, selectedYear);
      totalDays += tripDays;

      // Track longest cruise (only for all-time or if fully within year)
      if (selectedYear == null ||
          (tripStartYear == selectedYear && tripEndYear == selectedYear)) {
        if (trip.totalDays > longestCruiseDays) {
          longestCruiseDays = trip.totalDays;
          longestCruise = trip;
        }
      }

      // Calculate distance
      totalDistanceNm += _calculateTripDistance(trip, selectedYear);

      // Collect unique ports
      for (final stop in trip.stops) {
        if (!stop.isSeaDay && stop.name.isNotEmpty) {
          // Check if this stop falls within the selected year
          if (selectedYear == null || _stopInYear(stop, trip, selectedYear)) {
            uniquePorts.add(stop.name);
          }
        }
      }

      // Count ships
      shipCounts[trip.shipName] = (shipCounts[trip.shipName] ?? 0) + 1;
    }

    // Find favorite ship
    String? favoriteShip;
    int favoriteShipCount = 0;
    for (final entry in shipCounts.entries) {
      if (entry.value > favoriteShipCount) {
        favoriteShipCount = entry.value;
        favoriteShip = entry.key;
      }
    }

    // Calculate percentage for favorite ship
    final totalShipTrips = shipCounts.values.fold<int>(0, (a, b) => a + b);
    final favoriteShipPercent = totalShipTrips > 0
        ? ((favoriteShipCount / totalShipTrips) * 100).round()
        : 0;

    return _CruiseStats(
      totalCruises: totalCruises,
      totalDays: totalDays.round(),
      totalDistanceNm: totalDistanceNm.round(),
      uniquePortsCount: uniquePorts.length,
      uniqueShipsCount: shipCounts.length,
      favoriteShip: favoriteShip,
      favoriteShipCount: favoriteShipCount,
      favoriteShipPercent: favoriteShipPercent,
      shipCounts: shipCounts,
      longestCruise: longestCruise,
      longestCruiseDays: longestCruiseDays,
    );
  }

  double _calculateDaysForYear(CruiseTrip trip, int? year) {
    if (year == null) {
      return trip.totalDays.toDouble();
    }

    final yearStart = DateTime(year, 1, 1);
    final yearEnd = DateTime(year, 12, 31, 23, 59, 59);

    final effectiveStart = trip.departureDate.isAfter(yearStart)
        ? trip.departureDate
        : yearStart;
    final effectiveEnd = trip.arrivalDate.isBefore(yearEnd)
        ? trip.arrivalDate
        : yearEnd;

    if (effectiveStart.isAfter(effectiveEnd)) {
      return 0;
    }

    return effectiveEnd.difference(effectiveStart).inDays.toDouble() + 1;
  }

  bool _stopInYear(PortStop stop, CruiseTrip trip, int year) {
    final stopDate = stop.arrivalTime ?? trip.departureDate;
    return stopDate.year == year;
  }

  double _calculateTripDistance(CruiseTrip trip, int? year) {
    double distance = 0;
    final portsWithCoords = trip.stops
        .where((s) => !s.isSeaDay && s.latitude != null && s.longitude != null)
        .toList();

    for (int i = 0; i < portsWithCoords.length - 1; i++) {
      final from = portsWithCoords[i];
      final to = portsWithCoords[i + 1];

      // If year filter, check if this segment falls within the year
      if (year != null) {
        final segmentDate = from.departureTime ?? from.arrivalTime ?? trip.departureDate;
        if (segmentDate.year != year) {
          continue;
        }
      }

      distance += _haversineDistanceNm(
        from.latitude!, from.longitude!,
        to.latitude!, to.longitude!,
      );
    }

    return distance;
  }

  double _haversineDistanceNm(double lat1, double lon1, double lat2, double lon2) {
    const earthRadiusNm = 3440.065; // Earth radius in nautical miles

    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) * math.cos(_toRadians(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadiusNm * c;
  }

  double _toRadians(double degrees) => degrees * math.pi / 180;
}

class _CruiseStats {
  final int totalCruises;
  final int totalDays;
  final int totalDistanceNm;
  final int uniquePortsCount;
  final int uniqueShipsCount;
  final String? favoriteShip;
  final int favoriteShipCount;
  final int favoriteShipPercent;
  final Map<String, int> shipCounts;
  final CruiseTrip? longestCruise;
  final int longestCruiseDays;

  const _CruiseStats({
    required this.totalCruises,
    required this.totalDays,
    required this.totalDistanceNm,
    required this.uniquePortsCount,
    required this.uniqueShipsCount,
    required this.favoriteShip,
    required this.favoriteShipCount,
    required this.favoriteShipPercent,
    required this.shipCounts,
    required this.longestCruise,
    required this.longestCruiseDays,
  });

  factory _CruiseStats.empty() => const _CruiseStats(
    totalCruises: 0,
    totalDays: 0,
    totalDistanceNm: 0,
    uniquePortsCount: 0,
    uniqueShipsCount: 0,
    favoriteShip: null,
    favoriteShipCount: 0,
    favoriteShipPercent: 0,
    shipCounts: {},
    longestCruise: null,
    longestCruiseDays: 0,
  );
}

class _ProfileHeader extends StatelessWidget {
  final String userName;
  final WidgetRef ref;

  const _ProfileHeader({required this.userName, required this.ref});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    // Get initials from name
    final initials = userName.isNotEmpty
        ? userName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : 'U';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Name and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      l10n.myCruises,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              // Close button
              IconButton(
                onPressed: () => context.pop(),
                icon: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Action buttons
          Row(
            children: [
              _ActionChip(
                icon: Icons.group_rounded,
                label: l10n.friends,
                onTap: () => context.push('/friends'),
              ),
              const SizedBox(width: 8),
              _ActionChip(
                icon: Icons.settings_rounded,
                label: l10n.settings,
                onTap: () => _showSettingsSheet(context, ref),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSettingsSheet(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.settings,
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 24),
              // Account section
              _SettingsSectionTitle(title: l10n.account),
              _SettingsItem(
                icon: Icons.person_outline_rounded,
                title: l10n.accountSettings,
                subtitle: l10n.manageProfilePreferences,
                onTap: () {},
              ),
              _SettingsItem(
                icon: Icons.notifications_outlined,
                title: l10n.notifications,
                subtitle: l10n.manageNotifications,
                onTap: () {},
              ),
              _LanguageSettingsItem(ref: ref),
              const SizedBox(height: 16),
              // Support section
              _SettingsSectionTitle(title: l10n.support),
              _SettingsItem(
                icon: Icons.help_outline_rounded,
                title: l10n.helpSupport,
                subtitle: l10n.getHelp,
                onTap: () {},
              ),
              _SettingsItem(
                icon: Icons.info_outline_rounded,
                title: l10n.about,
                subtitle: l10n.appVersionLegal,
                onTap: () => _showAboutDialog(context),
              ),
              const SizedBox(height: 24),
              // Sign out button (only show if Firebase is available)
              Consumer(
                builder: (context, ref, _) {
                  final authService = ref.watch(authServiceProvider);
                  if (authService == null) {
                    return const SizedBox.shrink();
                  }
                  return SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _confirmSignOut(context, ref),
                      style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.errorContainer,
                        foregroundColor: colorScheme.error,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      icon: const Icon(Icons.logout_rounded),
                      label: Text(l10n.signOut),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showAboutDialog(
      context: context,
      applicationName: l10n.appTitle,
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          Icons.sailing_rounded,
          size: 32,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      children: [
        Text(l10n.appDescription),
      ],
    );
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final authService = ref.read(authServiceProvider);

    // If auth service is not available, don't show sign out option
    if (authService == null) {
      Navigator.of(context).pop();
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.signOut),
        content: Text(l10n.signOutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.signOut),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await authService.signOut();
      if (context.mounted) {
        Navigator.of(context).pop(); // Close settings sheet
      }
    }
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _YearFilterTabs extends ConsumerWidget {
  final List<int> years;
  final WidgetRef ref;

  const _YearFilterTabs({required this.years, required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedYear = ref.watch(selectedYearProvider);
    final l10n = AppLocalizations.of(context)!;

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // ALL-TIME tab
          _YearTab(
            label: l10n.allCruises.toUpperCase(),
            isSelected: selectedYear == null,
            onTap: () => ref.read(selectedYearProvider.notifier).state = null,
          ),
          const SizedBox(width: 8),
          // Year tabs
          ...years.map((year) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _YearTab(
              label: '$year',
              isSelected: selectedYear == year,
              onTap: () => ref.read(selectedYearProvider.notifier).state = year,
            ),
          )),
        ],
      ),
    );
  }
}

class _YearTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _YearTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? Colors.white.withValues(alpha: 0.15) : Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.5),
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _CruisePassportCard extends StatelessWidget {
  final _CruiseStats stats;

  const _CruisePassportCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final selectedYear = ProviderScope.containerOf(context).read(selectedYearProvider);
    final title = selectedYear == null
        ? l10n.allTimeCruisePassport
        : l10n.yearCruisePassport(selectedYear);

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1a237e), // Deep blue
            Color(0xFF0d47a1), // Slightly lighter blue
            Color(0xFF1565c0), // Even lighter at bottom
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.sailing_rounded,
                            size: 14,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            l10n.passport,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.6),
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {}, // TODO: Share functionality
                  icon: Icon(
                    Icons.ios_share_rounded,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: 22,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Main stats row
            Row(
              children: [
                Expanded(
                  child: _StatColumn(
                    label: l10n.voyages.toUpperCase(),
                    value: '${stats.totalCruises}',
                    subtitle: null,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: _StatColumn(
                    label: l10n.distance,
                    value: _formatDistance(stats.totalDistanceNm),
                    subtitle: _getDistanceSubtitle(stats.totalDistanceNm, l10n),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Secondary stats row
            Row(
              children: [
                Expanded(
                  child: _StatColumn(
                    label: l10n.days.toUpperCase(),
                    value: '${stats.totalDays}d',
                    subtitle: null,
                    smaller: true,
                  ),
                ),
                Expanded(
                  child: _StatColumn(
                    label: l10n.ports.toUpperCase(),
                    value: '${stats.uniquePortsCount}',
                    subtitle: null,
                    smaller: true,
                  ),
                ),
                Expanded(
                  child: _StatColumn(
                    label: l10n.ships,
                    value: '${stats.uniqueShipsCount}',
                    subtitle: stats.favoriteShip != null
                        ? '${stats.favoriteShipPercent}% ${stats.favoriteShip}'
                        : null,
                    smaller: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // All stats button
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {}, // TODO: All stats screen
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.allCruiseStats,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDistance(int nm) {
    if (nm >= 1000) {
      return '${(nm / 1000).toStringAsFixed(1)}k nm';
    }
    return '$nm nm';
  }

  String? _getDistanceSubtitle(int nm, AppLocalizations l10n) {
    // Earth circumference is about 21,600 nm
    if (nm >= 21600) {
      final times = (nm / 21600).toStringAsFixed(1);
      return l10n.aroundWorld(times);
    } else if (nm >= 10800) {
      return l10n.halfAroundWorld;
    }
    return null;
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final String? subtitle;
  final bool smaller;

  const _StatColumn({
    required this.label,
    required this.value,
    this.subtitle,
    this.smaller = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.6),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: smaller ? 24 : 36,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.6),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}

class _LongestCruiseCard extends StatelessWidget {
  final CruiseTrip? longestCruise;
  final int longestCruiseDays;

  const _LongestCruiseCard({
    required this.longestCruise,
    required this.longestCruiseDays,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (longestCruise == null) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6a1b9a), // Purple
            Color(0xFF8e24aa), // Lighter purple
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.longestCruise,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.ios_share_rounded,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '$longestCruiseDays',
              style: GoogleFonts.outfit(
                fontSize: 64,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.daysOnShip(longestCruise!.shipName),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
            if (longestCruise!.tripName.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                longestCruise!.tripName,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FavoriteShipCard extends StatelessWidget {
  final String? favoriteShip;
  final int favoriteShipCount;
  final Map<String, int> allShips;

  const _FavoriteShipCard({
    required this.favoriteShip,
    required this.favoriteShipCount,
    required this.allShips,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (favoriteShip == null) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showAllShips(context, l10n),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.favoriteShip,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Icon(
                      Icons.ios_share_rounded,
                      color: colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  favoriteShip!,
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.cruiseCount(favoriteShipCount),
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                // View all ships hint
                Row(
                  children: [
                    Text(
                      l10n.viewAllShips,
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAllShips(BuildContext context, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;

    // Sort ships by count
    final sortedShips = allShips.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.allShips,
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            ...sortedShips.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.sailing_rounded,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    l10n.cruiseCount(entry.value),
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _SettingsSectionTitle extends StatelessWidget {
  final String title;

  const _SettingsSectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(icon, color: colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: colorScheme.onSurfaceVariant,
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}

class _LanguageSettingsItem extends ConsumerWidget {
  final WidgetRef ref;

  const _LanguageSettingsItem({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);

    final currentLanguage = currentLocale?.languageCode == 'de'
        ? l10n.german
        : l10n.english;

    return ListTile(
      leading: Icon(Icons.language_rounded, color: colorScheme.primary),
      title: Text(l10n.language),
      subtitle: Text(currentLanguage),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: colorScheme.onSurfaceVariant,
      ),
      onTap: () => _showLanguageSheet(context, ref),
      contentPadding: EdgeInsets.zero,
    );
  }

  void _showLanguageSheet(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.read(localeProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.language,
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  'EN',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              title: Text(l10n.english),
              trailing: currentLocale?.languageCode != 'de'
                  ? Icon(Icons.check_rounded, color: colorScheme.primary)
                  : null,
              onTap: () {
                ref.read(localeProvider.notifier).state = const Locale('en');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  'DE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              title: Text(l10n.german),
              trailing: currentLocale?.languageCode == 'de'
                  ? Icon(Icons.check_rounded, color: colorScheme.primary)
                  : null,
              onTap: () {
                ref.read(localeProvider.notifier).state = const Locale('de');
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
