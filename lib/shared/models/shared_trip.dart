import 'package:cloud_firestore/cloud_firestore.dart';

import 'cruise_trip.dart';

/// A cruise trip shared by another user
class SharedTrip {
  final String id;
  final String ownerUid;
  final String ownerName;
  final CruiseTrip trip;
  final DateTime sharedAt;
  final DateTime importedAt;

  const SharedTrip({
    required this.id,
    required this.ownerUid,
    required this.ownerName,
    required this.trip,
    required this.sharedAt,
    required this.importedAt,
  });

  factory SharedTrip.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final tripData = data['trip'] as Map<String, dynamic>? ?? {};

    return SharedTrip(
      id: doc.id,
      ownerUid: data['ownerUid'] as String? ?? '',
      ownerName: data['ownerName'] as String? ?? 'Unknown',
      trip: CruiseTrip.fromMap(tripData),
      sharedAt: (data['sharedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      importedAt: (data['importedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerUid': ownerUid,
      'ownerName': ownerName,
      'trip': trip.toShareableMap(),
      'sharedAt': Timestamp.fromDate(sharedAt),
      'importedAt': Timestamp.fromDate(importedAt),
    };
  }

  /// Create a SharedTrip from decoded share data
  factory SharedTrip.fromShareData(Map<String, dynamic> data) {
    final tripData = data['trip'] as Map<String, dynamic>? ?? {};

    return SharedTrip(
      id: '', // Will be assigned when saved
      ownerUid: data['ownerUid'] as String? ?? '',
      ownerName: data['ownerName'] as String? ?? 'Unknown',
      trip: CruiseTrip.fromMap(tripData),
      sharedAt: DateTime.tryParse(data['sharedAt'] as String? ?? '') ?? DateTime.now(),
      importedAt: DateTime.now(),
    );
  }
}

/// Data structure for sharing a trip
class ShareData {
  final String ownerUid;
  final String ownerName;
  final Map<String, dynamic> trip;
  final String sharedAt;

  const ShareData({
    required this.ownerUid,
    required this.ownerName,
    required this.trip,
    required this.sharedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'ownerUid': ownerUid,
      'ownerName': ownerName,
      'trip': trip,
      'sharedAt': sharedAt,
    };
  }

  factory ShareData.fromMap(Map<String, dynamic> map) {
    return ShareData(
      ownerUid: map['ownerUid'] as String? ?? '',
      ownerName: map['ownerName'] as String? ?? 'Unknown',
      trip: map['trip'] as Map<String, dynamic>? ?? {},
      sharedAt: map['sharedAt'] as String? ?? DateTime.now().toIso8601String(),
    );
  }
}
