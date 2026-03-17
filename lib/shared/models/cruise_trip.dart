import 'package:cloud_firestore/cloud_firestore.dart';

import 'port_stop.dart';

class CruiseTrip {
  final String id;
  final String shipName;
  final String tripName;
  final DateTime departureDate;
  final DateTime arrivalDate;
  final String startPort;
  final String endPort;
  final List<PortStop> stops;
  final String? imageUrl;

  const CruiseTrip({
    required this.id,
    required this.shipName,
    required this.tripName,
    required this.departureDate,
    required this.arrivalDate,
    required this.startPort,
    required this.endPort,
    required this.stops,
    this.imageUrl,
  });

  factory CruiseTrip.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return CruiseTrip(
      id: doc.id,
      shipName: data['shipName'] as String? ?? '',
      tripName: data['tripName'] as String? ?? '',
      departureDate: _parseTimestamp(data['departureDate']) ?? DateTime.now(),
      arrivalDate: _parseTimestamp(data['arrivalDate']) ?? DateTime.now(),
      startPort: data['startPort'] as String? ?? '',
      endPort: data['endPort'] as String? ?? '',
      imageUrl: data['imageUrl'] as String?,
      stops: (data['stops'] as List<dynamic>?)
              ?.map((stop) => PortStop.fromMap(stop as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  factory CruiseTrip.fromMap(Map<String, dynamic> data, {String id = ''}) {
    return CruiseTrip(
      id: id,
      shipName: data['shipName'] as String? ?? '',
      tripName: data['tripName'] as String? ?? '',
      departureDate: _parseTimestamp(data['departureDate']) ?? DateTime.now(),
      arrivalDate: _parseTimestamp(data['arrivalDate']) ?? DateTime.now(),
      startPort: data['startPort'] as String? ?? '',
      endPort: data['endPort'] as String? ?? '',
      imageUrl: data['imageUrl'] as String?,
      stops: (data['stops'] as List<dynamic>?)
              ?.map((stop) => PortStop.fromMap(stop as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'shipName': shipName,
      'tripName': tripName,
      'departureDate': Timestamp.fromDate(departureDate),
      'arrivalDate': Timestamp.fromDate(arrivalDate),
      'startPort': startPort,
      'endPort': endPort,
      'imageUrl': imageUrl,
      'stops': stops.map((stop) => stop.toMap()).toList(),
    };
  }

  /// Convert to JSON-serializable map (for sharing)
  Map<String, dynamic> toShareableMap() {
    return {
      'shipName': shipName,
      'tripName': tripName,
      'departureDate': departureDate.toIso8601String(),
      'arrivalDate': arrivalDate.toIso8601String(),
      'startPort': startPort,
      'endPort': endPort,
      'imageUrl': imageUrl,
      'stops': stops.map((stop) => stop.toShareableMap()).toList(),
    };
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  double get progress {
    final now = DateTime.now();

    if (now.isBefore(departureDate)) {
      return 0.0;
    }

    if (now.isAfter(arrivalDate)) {
      return 1.0;
    }

    final totalDuration = arrivalDate.difference(departureDate).inMinutes;
    final elapsedDuration = now.difference(departureDate).inMinutes;

    return (elapsedDuration / totalDuration).clamp(0.0, 1.0);
  }

  Duration get totalDuration => arrivalDate.difference(departureDate);

  int get totalDays => totalDuration.inDays;

  Duration get timeUntilDeparture {
    final now = DateTime.now();
    if (now.isAfter(departureDate)) {
      return Duration.zero;
    }
    return departureDate.difference(now);
  }

  int get daysUntilDeparture => timeUntilDeparture.inDays;

  bool get isUpcoming => DateTime.now().isBefore(departureDate);

  bool get isOngoing {
    final now = DateTime.now();
    return now.isAfter(departureDate) && now.isBefore(arrivalDate);
  }

  bool get isCompleted => DateTime.now().isAfter(arrivalDate);

  int get currentDay {
    if (!isOngoing) return 0;
    return DateTime.now().difference(departureDate).inDays + 1;
  }

  PortStop? get currentStop {
    for (final stop in stops) {
      if (stop.isCurrentStop) {
        return stop;
      }
    }
    return null;
  }

  PortStop? get nextStop {
    final now = DateTime.now();
    for (final stop in stops) {
      if (stop.arrivalTime != null && stop.arrivalTime!.isAfter(now)) {
        return stop;
      }
    }
    return null;
  }

  int get completedStopsCount {
    return stops.where((stop) => stop.isPastStop).length;
  }

  CruiseTrip copyWith({
    String? id,
    String? shipName,
    String? tripName,
    DateTime? departureDate,
    DateTime? arrivalDate,
    String? startPort,
    String? endPort,
    List<PortStop>? stops,
    Object? imageUrl = _sentinel,
  }) {
    return CruiseTrip(
      id: id ?? this.id,
      shipName: shipName ?? this.shipName,
      tripName: tripName ?? this.tripName,
      departureDate: departureDate ?? this.departureDate,
      arrivalDate: arrivalDate ?? this.arrivalDate,
      startPort: startPort ?? this.startPort,
      endPort: endPort ?? this.endPort,
      stops: stops ?? this.stops,
      imageUrl: imageUrl == _sentinel ? this.imageUrl : imageUrl as String?,
    );
  }

  static const _sentinel = Object();
}
