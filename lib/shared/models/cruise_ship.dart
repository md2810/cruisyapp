import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a cruise ship with its MMSI for live tracking
class CruiseShip {
  final String id;
  final String name;
  final int mmsi;
  final String company;
  final bool active;

  const CruiseShip({
    required this.id,
    required this.name,
    required this.mmsi,
    required this.company,
    this.active = true,
  });

  factory CruiseShip.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return CruiseShip(
      id: doc.id,
      name: data['name'] as String? ?? '',
      mmsi: data['mmsi'] as int? ?? 0,
      company: data['company'] as String? ?? '',
      active: data['active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'mmsi': mmsi,
      'company': company,
      'active': active,
    };
  }
}

/// Live position data for a ship
class LivePosition {
  final int mmsi;
  final double latitude;
  final double longitude;
  final double speed;
  final double heading;
  final DateTime timestamp;
  final DateTime updatedAt;
  final String shipName;
  final String company;

  const LivePosition({
    required this.mmsi,
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.heading,
    required this.timestamp,
    required this.updatedAt,
    required this.shipName,
    required this.company,
  });

  factory LivePosition.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return LivePosition(
      mmsi: data['mmsi'] as int? ?? 0,
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0,
      speed: (data['speed'] as num?)?.toDouble() ?? 0,
      heading: (data['heading'] as num?)?.toDouble() ?? 0,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      shipName: data['ship_name'] as String? ?? '',
      company: data['company'] as String? ?? '',
    );
  }

  /// Get the age of this position data
  Duration get age => DateTime.now().difference(updatedAt);

  /// Check if position is fresh (< 10 minutes old)
  bool get isFresh => age.inMinutes < 10;

  /// Check if position is recent (< 3 hours old)
  bool get isRecent => age.inHours < 3;

  /// Check if position is stale (> 3 hours old)
  bool get isStale => !isRecent;

  /// Get status label for UI
  String get statusLabel {
    if (isFresh) return 'Live';
    if (age.inMinutes < 60) return '${age.inMinutes}m ago';
    if (isRecent) return '${age.inHours}h ago';
    return 'Estimated';
  }

  /// Get status type for UI styling
  PositionStatus get status {
    if (isFresh) return PositionStatus.live;
    if (isRecent) return PositionStatus.recent;
    return PositionStatus.estimated;
  }
}

enum PositionStatus {
  live,      // < 10 min old - green
  recent,    // < 3 hours old - yellow
  estimated, // > 3 hours old or calculated - grey
}
