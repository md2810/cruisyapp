import 'package:flutter/material.dart';
import 'package:cruisyapp/l10n/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/providers/trip_provider.dart';
import '../../../core/services/port_search_service.dart';
import '../../../shared/models/cruise_trip.dart';
import '../../../shared/models/port_stop.dart';

class TripFormScreen extends ConsumerStatefulWidget {
  final String? tripId;

  const TripFormScreen({super.key, this.tripId});

  bool get isEditing => tripId != null;

  @override
  ConsumerState<TripFormScreen> createState() => _TripFormScreenState();
}

class _TripFormScreenState extends ConsumerState<TripFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _shipNameController = TextEditingController();
  final _tripNameController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  List<PortStop> _stops = [];
  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void dispose() {
    _shipNameController.dispose();
    _tripNameController.dispose();
    super.dispose();
  }

  void _initializeFromTrip(CruiseTrip trip) {
    if (_isInitialized) return;
    _isInitialized = true;

    _shipNameController.text = trip.shipName;
    _tripNameController.text = trip.tripName;
    _startDate = trip.departureDate;
    _endDate = trip.arrivalDate;
    _stops = List.from(trip.stops);
  }

  Future<void> _selectDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(1950), // Allow cruises from 1950 onwards
      lastDate: now.add(const Duration(days: 365 * 5)), // 5 years in the future
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : DateTimeRange(
              start: now.add(const Duration(days: 7)),
              end: now.add(const Duration(days: 14)),
            ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            datePickerTheme: DatePickerThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _addStop({DateTime? suggestedDate}) {
    final l10n = AppLocalizations.of(context)!;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseSelectTripDatesFirst),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Determine if this will be the first or last port
    final ports = _stops.where((s) => !s.isSeaDay).toList();
    final isFirstPort = ports.isEmpty;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => _AddPortSheet(
        startDate: _startDate!,
        endDate: _endDate!,
        suggestedDate: suggestedDate,
        isFirstPort: isFirstPort,
        isLastPort: true, // When adding, it becomes the last port
        onAdd: (stop) {
          setState(() {
            _stops.add(stop);
            _sortStops();
          });
        },
      ),
    );
  }

  void _editStop(int index) {
    if (_startDate == null || _endDate == null) return;

    // Determine if this is the first or last port
    final nonSeaDayStops = _stops.where((s) => !s.isSeaDay).toList();
    final currentStop = _stops[index];
    final isFirstPort = nonSeaDayStops.isNotEmpty && nonSeaDayStops.first == currentStop;
    final isLastPort = nonSeaDayStops.isNotEmpty && nonSeaDayStops.last == currentStop;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => _AddPortSheet(
        startDate: _startDate!,
        endDate: _endDate!,
        existingStop: currentStop,
        isFirstPort: isFirstPort,
        isLastPort: isLastPort,
        onAdd: (stop) {
          setState(() {
            _stops[index] = stop;
            _sortStops();
          });
        },
      ),
    );
  }

  void _sortStops() {
    _stops.sort((a, b) {
      if (a.arrivalTime == null && b.arrivalTime == null) return 0;
      if (a.arrivalTime == null) return 1;
      if (b.arrivalTime == null) return -1;
      return a.arrivalTime!.compareTo(b.arrivalTime!);
    });
  }

  void _removeStop(int index) {
    setState(() {
      _stops.removeAt(index);
    });
  }

  Future<void> _confirmDeleteStop(BuildContext context, PortStop stop) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deletePort),
        content: Text('${stop.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final stopIndex = _stops.indexOf(stop);
      if (stopIndex != -1) _removeStop(stopIndex);
    }
  }

  String? _validateStops() {
    final l10n = AppLocalizations.of(context)!;
    // Count non-sea-day ports
    final ports = _stops.where((s) => !s.isSeaDay).toList();

    if (ports.length < 2) {
      return l10n.pleaseAddAtLeastTwoPorts;
    }

    // Check first entry is not a sea day
    if (_stops.isNotEmpty && _stops.first.isSeaDay) {
      return l10n.firstEntryCannotBeSeaDay;
    }

    // Check last entry is not a sea day
    if (_stops.isNotEmpty && _stops.last.isSeaDay) {
      return l10n.lastEntryCannotBeSeaDay;
    }

    return null;
  }

  Future<void> _saveTrip() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    if (_shipNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.shipNameRequired),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.selectTravelDates),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final stopsError = _validateStops();
    if (stopsError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(stopsError),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final tripService = ref.read(tripServiceProvider);
      if (tripService == null) {
        throw Exception('Not authenticated');
      }

      // Get first and last non-sea-day ports for start/end port names
      final ports = _stops.where((s) => !s.isSeaDay).toList();
      final startPort = ports.first.name;
      final endPort = ports.last.name;

      final trip = CruiseTrip(
        id: widget.tripId ?? '',
        shipName: _shipNameController.text.trim(),
        tripName: _tripNameController.text.trim().isNotEmpty
            ? _tripNameController.text.trim()
            : l10n.cruiseAdventureDefault,
        departureDate: _startDate!,
        arrivalDate: _endDate!,
        startPort: startPort,
        endPort: endPort,
        stops: _stops,
        imageUrl:
            'https://images.unsplash.com/photo-1548574505-5e239809ee19?q=80&w=1000&auto=format&fit=crop',
      );

      if (widget.isEditing) {
        await tripService.updateTrip(trip);
      } else {
        await tripService.addTrip(trip);
      }

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing
                  ? l10n.tripUpdated(trip.shipName)
                  : l10n.tripAdded(trip.shipName),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.failedToSaveTrip(e.toString())),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Get all days in the trip range
  List<DateTime> _getTripDays() {
    if (_startDate == null || _endDate == null) return [];

    final days = <DateTime>[];
    var current = DateTime(_startDate!.year, _startDate!.month, _startDate!.day);
    final end = DateTime(_endDate!.year, _endDate!.month, _endDate!.day);

    while (!current.isAfter(end)) {
      days.add(current);
      current = current.add(const Duration(days: 1));
    }
    return days;
  }

  // Find stop for a specific day
  PortStop? _getStopForDay(DateTime day) {
    for (final stop in _stops) {
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final dateFormat = DateFormat('MMM d, yyyy');

    // If editing, load existing trip data
    if (widget.isEditing) {
      final existingTrip = ref.watch(tripByIdProvider(widget.tripId!));
      if (existingTrip != null) {
        _initializeFromTrip(existingTrip);
      }
    }

    final tripDays = _getTripDays();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            FocusScope.of(context).unfocus();
            context.pop();
          },
          icon: const Icon(Icons.close_rounded),
        ),
        title: Text(widget.isEditing ? l10n.editTrip : l10n.addTrip),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton(
              onPressed: _isLoading ? null : _saveTrip,
              child: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.onPrimary,
                      ),
                    )
                  : Text(l10n.save),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.sailing_rounded,
                size: 64,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                widget.isEditing ? l10n.editVoyage : l10n.newVoyage,
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.isEditing
                    ? l10n.updateCruiseDetails
                    : l10n.addCruiseTracking,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),

              // Trip Name (first, for the narrative flow)
              TextFormField(
                controller: _tripNameController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: l10n.tripNameOptional,
                  hintText: l10n.tripNameOptionalHint,
                  prefixIcon: const Icon(Icons.confirmation_number_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                ),
              ),
              const SizedBox(height: 20),

              // Ship Name
              TextFormField(
                controller: _shipNameController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                onEditingComplete: () => FocusScope.of(context).unfocus(),
                decoration: InputDecoration(
                  labelText: l10n.shipName,
                  hintText: l10n.shipNameHint,
                  prefixIcon: const Icon(Icons.directions_boat_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.shipNameRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Travel Dates
              Text(
                l10n.travelDates,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _selectDateRange,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_month_rounded,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _startDate != null && _endDate != null
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${dateFormat.format(_startDate!)} - ${dateFormat.format(_endDate!)}',
                                    style: textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    l10n.daysCount(_endDate!.difference(_startDate!).inDays + 1),
                                    style: textTheme.bodySmall?.copyWith(
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                l10n.selectDepartureDates,
                                style: textTheme.bodyLarge?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Itinerary Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.itinerary,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () => _addStop(),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: Text(l10n.add),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Day-by-day itinerary
              if (tripDays.isEmpty)
                _buildEmptyItinerary(colorScheme, textTheme)
              else
                _buildDayByDayItinerary(tripDays, colorScheme, textTheme),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: _isLoading ? null : _saveTrip,
                  icon: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.onPrimary,
                          ),
                        )
                      : Icon(widget.isEditing
                          ? Icons.save_rounded
                          : Icons.add_rounded),
                  label: Text(
                    _isLoading
                        ? l10n.savingTrip
                        : (widget.isEditing ? l10n.updateTripButton : l10n.saveTripButton),
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyItinerary(ColorScheme colorScheme, TextTheme textTheme) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.calendar_today_rounded,
            size: 48,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.selectTravelDatesFirst,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.addPortsSeaDays,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayByDayItinerary(
    List<DateTime> days,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('EEE, MMM d');
    final timeFormat = DateFormat('HH:mm');

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: days.length,
      itemBuilder: (context, index) {
        final day = days[index];
        final stop = _getStopForDay(day);

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
          color: stop != null
              ? (stop.isSeaDay
                  ? colorScheme.secondaryContainer.withValues(alpha: 0.5)
                  : colorScheme.surfaceContainerHigh)
              : colorScheme.surfaceContainerHighest,
          child: InkWell(
            onTap: stop != null
                ? () {
                    final stopIndex = _stops.indexOf(stop);
                    if (stopIndex != -1) _editStop(stopIndex);
                  }
                : () => _addStop(suggestedDate: day),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Day number
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: stop != null
                          ? (stop.isSeaDay
                              ? colorScheme.secondary
                              : colorScheme.primaryContainer)
                          : colorScheme.surfaceContainerHigh,
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
                            color: stop != null
                                ? (stop.isSeaDay
                                    ? colorScheme.onSecondary
                                    : colorScheme.onPrimaryContainer)
                                : colorScheme.onSurfaceVariant,
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
                        Text(
                          dateFormat.format(day),
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                        if (stop != null) ...[
                          Text(
                            isContinuation
                                ? l10n.continued(stop.name)
                                : stop.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (!isContinuation &&
                              stop.arrivalTime != null &&
                              !stop.isSeaDay) ...[
                            const SizedBox(height: 2),
                            Text(
                              stop.departureTime != null
                                  ? '${timeFormat.format(stop.arrivalTime!)} - ${timeFormat.format(stop.departureTime!)}'
                                  : l10n.arrivesTime(timeFormat.format(stop.arrivalTime!)),
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
                  // Action icon
                  if (stop != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isContinuation)
                          IconButton(
                            icon: Icon(
                              Icons.delete_outline_rounded,
                              color: colorScheme.error,
                              size: 20,
                            ),
                            onPressed: () => _confirmDeleteStop(context, stop),
                          ),
                        Icon(
                          Icons.edit_rounded,
                          color: colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                      ],
                    )
                  else
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        Icons.add_rounded,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Add Port Sheet with Search and Multi-day support
class _AddPortSheet extends ConsumerStatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final DateTime? suggestedDate;
  final PortStop? existingStop;
  final Function(PortStop) onAdd;
  final bool isFirstPort;
  final bool isLastPort;

  const _AddPortSheet({
    required this.startDate,
    required this.endDate,
    this.suggestedDate,
    this.existingStop,
    required this.onAdd,
    this.isFirstPort = false,
    this.isLastPort = false,
  });

  @override
  ConsumerState<_AddPortSheet> createState() => _AddPortSheetState();
}

class _AddPortSheetState extends ConsumerState<_AddPortSheet> {
  final _searchController = TextEditingController();
  List<PortSearchResult> _searchResults = [];
  PortSearchResult? _selectedPort;
  DateTime? _arrivalDate;
  TimeOfDay? _arrivalTime;
  DateTime? _departureDate;
  TimeOfDay? _departureTime;
  bool _isSeaDay = false;
  bool _isMultiDay = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingStop != null) {
      _searchController.text = widget.existingStop!.name;
      _isSeaDay = widget.existingStop!.isSeaDay;

      if (widget.existingStop!.arrivalTime != null) {
        _arrivalDate = DateTime(
          widget.existingStop!.arrivalTime!.year,
          widget.existingStop!.arrivalTime!.month,
          widget.existingStop!.arrivalTime!.day,
        );
        _arrivalTime = TimeOfDay.fromDateTime(widget.existingStop!.arrivalTime!);
      }

      if (widget.existingStop!.departureTime != null) {
        _departureDate = DateTime(
          widget.existingStop!.departureTime!.year,
          widget.existingStop!.departureTime!.month,
          widget.existingStop!.departureTime!.day,
        );
        _departureTime = TimeOfDay.fromDateTime(widget.existingStop!.departureTime!);

        // Check if multi-day
        if (_arrivalDate != null && _departureDate != null) {
          _isMultiDay = !_arrivalDate!.isAtSameMomentAs(_departureDate!);
        }
      }

      // Try to find matching port for coordinates
      if (!_isSeaDay) {
        final portService = ref.read(portSearchServiceProvider);
        _selectedPort = portService.findByName(widget.existingStop!.name);
      }
    } else if (widget.suggestedDate != null) {
      _arrivalDate = widget.suggestedDate;
      _departureDate = widget.suggestedDate;
    }
    _performSearch('');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    final portService = ref.read(portSearchServiceProvider);
    setState(() {
      _searchResults = portService.search(query);
    });
  }

  void _selectPort(PortSearchResult port) {
    setState(() {
      _selectedPort = port;
      _searchController.text = port.name;
      _searchResults = [];
    });
  }

  Future<void> _selectArrivalDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _arrivalDate ?? widget.suggestedDate ?? widget.startDate,
      firstDate: widget.startDate,
      lastDate: widget.endDate,
    );
    if (picked != null) {
      setState(() {
        _arrivalDate = picked;
        // If not multi-day, sync departure date
        if (!_isMultiDay) {
          _departureDate = picked;
        }
      });
      // Auto-open departure date picker if not set and multi-day is enabled
      if (_isMultiDay && _departureDate == null) {
        await Future.delayed(const Duration(milliseconds: 200));
        if (mounted) await _selectDepartureDate();
      }
    }
  }

  Future<void> _selectDepartureDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _departureDate ?? _arrivalDate ?? widget.startDate,
      firstDate: _arrivalDate ?? widget.startDate,
      lastDate: widget.endDate,
    );
    if (picked != null) {
      setState(() => _departureDate = picked);
    }
  }

  Future<void> _selectArrivalTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _arrivalTime ?? const TimeOfDay(hour: 8, minute: 0),
    );
    if (picked != null) {
      setState(() => _arrivalTime = picked);
    }
  }

  Future<void> _selectDepartureTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _departureTime ?? const TimeOfDay(hour: 18, minute: 0),
    );
    if (picked != null) {
      setState(() => _departureTime = picked);
    }
  }

  void _save() {
    final l10n = AppLocalizations.of(context)!;
    final name = _searchController.text.trim();
    if (name.isEmpty && !_isSeaDay) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseEnterOrSelectPort),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_arrivalDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseSelectADate),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Require arrival and departure times for port stops (not sea days)
    // Except: first port doesn't need arrival time, last port doesn't need departure time
    if (!_isSeaDay) {
      if (_arrivalTime == null && !widget.isFirstPort) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.pleaseSelectArrivalTime),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      if (_departureTime == null && !widget.isLastPort) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.pleaseSelectDepartureTime),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    DateTime? arrivalDateTime;
    DateTime? departureDateTime;

    if (_isSeaDay) {
      // Sea days: use date only with midnight times
      arrivalDateTime = DateTime(
        _arrivalDate!.year,
        _arrivalDate!.month,
        _arrivalDate!.day,
        0,
        0,
      );
      departureDateTime = DateTime(
        _arrivalDate!.year,
        _arrivalDate!.month,
        _arrivalDate!.day,
        23,
        59,
      );
    } else if (_isMultiDay) {
      // Multi-day: use separate dates with times
      // First port: arrival time optional (defaults to 00:00)
      arrivalDateTime = _arrivalTime != null
          ? DateTime(
              _arrivalDate!.year,
              _arrivalDate!.month,
              _arrivalDate!.day,
              _arrivalTime!.hour,
              _arrivalTime!.minute,
            )
          : DateTime(
              _arrivalDate!.year,
              _arrivalDate!.month,
              _arrivalDate!.day,
              0,
              0,
            );

      final depDate = _departureDate ?? _arrivalDate!;
      // Last port: departure time optional (defaults to 23:59)
      departureDateTime = _departureTime != null
          ? DateTime(
              depDate.year,
              depDate.month,
              depDate.day,
              _departureTime!.hour,
              _departureTime!.minute,
            )
          : DateTime(
              depDate.year,
              depDate.month,
              depDate.day,
              23,
              59,
            );
    } else {
      // Single day: same date for both
      // First port: arrival time optional (defaults to 00:00)
      arrivalDateTime = _arrivalTime != null
          ? DateTime(
              _arrivalDate!.year,
              _arrivalDate!.month,
              _arrivalDate!.day,
              _arrivalTime!.hour,
              _arrivalTime!.minute,
            )
          : DateTime(
              _arrivalDate!.year,
              _arrivalDate!.month,
              _arrivalDate!.day,
              0,
              0,
            );

      // Last port: departure time optional (defaults to 23:59)
      departureDateTime = _departureTime != null
          ? DateTime(
              _arrivalDate!.year,
              _arrivalDate!.month,
              _arrivalDate!.day,
              _departureTime!.hour,
              _departureTime!.minute,
            )
          : DateTime(
              _arrivalDate!.year,
              _arrivalDate!.month,
              _arrivalDate!.day,
              23,
              59,
            );
    }

    final stop = PortStop(
      id: widget.existingStop?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: _isSeaDay ? l10n.seaDay : name,
      arrivalTime: arrivalDateTime,
      departureTime: departureDateTime,
      isSeaDay: _isSeaDay,
      countryCode: _selectedPort?.countryCode,
      latitude: _selectedPort?.latitude,
      longitude: _selectedPort?.longitude,
    );

    widget.onAdd(stop);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('MMM d, yyyy');

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.existingStop != null ? l10n.editStopTitle : l10n.addStopTitle,
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),

            // Sea Day Toggle
            Card(
              color: colorScheme.surfaceContainerHigh,
              child: SwitchListTile(
                title: Text(l10n.isSeaDay),
                subtitle: Text(l10n.dayAtSeaNoPort),
                secondary: Icon(
                  Icons.waves_rounded,
                  color:
                      _isSeaDay ? colorScheme.primary : colorScheme.onSurfaceVariant,
                ),
                value: _isSeaDay,
                onChanged: (value) => setState(() => _isSeaDay = value),
              ),
            ),
            const SizedBox(height: 16),

            // Port Search
            if (!_isSeaDay) ...[
              TextField(
                controller: _searchController,
                textCapitalization: TextCapitalization.words,
                autofocus: widget.existingStop == null, // Auto-focus on new stops
                decoration: InputDecoration(
                  labelText: l10n.portNameLabel,
                  hintText: l10n.searchPort,
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            _performSearch('');
                            setState(() => _selectedPort = null);
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                ),
                onChanged: (value) {
                  _performSearch(value);
                  if (_selectedPort != null && _selectedPort!.name != value) {
                    setState(() => _selectedPort = null);
                  }
                },
              ),

              // Search Results
              if (_searchResults.isNotEmpty && _selectedPort == null)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  constraints: const BoxConstraints(maxHeight: 150),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final port = _searchResults[index];
                      return ListTile(
                        dense: true,
                        leading: Icon(
                          Icons.location_on_rounded,
                          color: colorScheme.primary,
                        ),
                        title: Text(port.name),
                        subtitle:
                            port.countryCode != null ? Text(port.countryCode!) : null,
                        onTap: () => _selectPort(port),
                      );
                    },
                  ),
                ),

              if (_selectedPort != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_rounded,
                          color: colorScheme.primary, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        l10n.coordinatesSavedForMap,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
            ],

            // Date Selection
            Text(
              _isMultiDay ? l10n.arrivalDateLabel : l10n.date,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selectArrivalDate,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, color: colorScheme.primary),
                    const SizedBox(width: 16),
                    Text(
                      _arrivalDate != null
                          ? dateFormat.format(_arrivalDate!)
                          : l10n.selectDate,
                      style: TextStyle(
                        color: _arrivalDate != null
                            ? colorScheme.onSurface
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Multi-day toggle (only for ports)
            if (!_isSeaDay) ...[
              const SizedBox(height: 16),
              Card(
                color: colorScheme.surfaceContainerHigh,
                child: SwitchListTile(
                  title: Text(l10n.multiDayStayLabel),
                  subtitle: Text(l10n.portVisitSpanningMultipleDays),
                  secondary: Icon(
                    Icons.date_range_rounded,
                    color: _isMultiDay
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                  value: _isMultiDay,
                  onChanged: (value) {
                    setState(() {
                      _isMultiDay = value;
                      if (!value) {
                        _departureDate = _arrivalDate;
                      }
                    });
                  },
                ),
              ),
            ],

            // Departure date (only for multi-day)
            if (_isMultiDay && !_isSeaDay) ...[
              const SizedBox(height: 16),
              Text(
                l10n.departureDateLabel,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectDepartureDate,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_rounded,
                          color: colorScheme.primary),
                      const SizedBox(width: 16),
                      Text(
                        _departureDate != null
                            ? dateFormat.format(_departureDate!)
                            : l10n.selectDate,
                        style: TextStyle(
                          color: _departureDate != null
                              ? colorScheme.onSurface
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Time Selection (only for ports, not sea days)
            if (!_isSeaDay) ...[
              const SizedBox(height: 16),
              Text(
                widget.isFirstPort && widget.isLastPort
                    ? l10n.timesOptionalForSinglePort
                    : widget.isFirstPort
                        ? '${l10n.departureTimeLabel} *'
                        : widget.isLastPort
                            ? '${l10n.arrivalTimeLabel} *'
                            : l10n.arrivalAndDepartureTimes,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _selectArrivalTime,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: colorScheme.outline.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.login_rounded,
                                color: colorScheme.primary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              _arrivalTime != null
                                  ? _arrivalTime!.format(context)
                                  : widget.isFirstPort ? l10n.arrivalOptional : l10n.arrivalRequired,
                              style: TextStyle(
                                color: _arrivalTime != null
                                    ? colorScheme.onSurface
                                    : colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _selectDepartureTime,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: colorScheme.outline.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.logout_rounded,
                                color: colorScheme.primary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              _departureTime != null
                                  ? _departureTime!.format(context)
                                  : widget.isLastPort ? l10n.departureOptional : l10n.departureRequired,
                              style: TextStyle(
                                color: _departureTime != null
                                    ? colorScheme.onSurface
                                    : colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: _save,
                child:
                    Text(widget.existingStop != null ? l10n.updateStop : l10n.addStopTitle),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
