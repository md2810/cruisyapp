import 'package:cloud_firestore/cloud_firestore.dart';

class PortStop {
  final String id;
  final String name;
  final DateTime? arrivalTime;
  final DateTime? departureTime;
  final bool isSeaDay;
  final String? countryCode;
  final double? latitude;
  final double? longitude;

  const PortStop({
    required this.id,
    required this.name,
    this.arrivalTime,
    this.departureTime,
    this.isSeaDay = false,
    this.countryCode,
    this.latitude,
    this.longitude,
  });

  Duration? get duration {
    if (arrivalTime == null || departureTime == null) return null;
    return departureTime!.difference(arrivalTime!);
  }

  bool get isCurrentStop {
    final now = DateTime.now();
    if (arrivalTime == null || departureTime == null) return false;
    return now.isAfter(arrivalTime!) && now.isBefore(departureTime!);
  }

  bool get isPastStop {
    if (departureTime == null) return false;
    return DateTime.now().isAfter(departureTime!);
  }

  factory PortStop.fromMap(Map<String, dynamic> map) {
    return PortStop(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      arrivalTime: _parseTimestamp(map['arrivalTime']),
      departureTime: _parseTimestamp(map['departureTime']),
      isSeaDay: map['isSeaDay'] as bool? ?? false,
      countryCode: map['countryCode'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'arrivalTime': arrivalTime != null ? Timestamp.fromDate(arrivalTime!) : null,
      'departureTime': departureTime != null ? Timestamp.fromDate(departureTime!) : null,
      'isSeaDay': isSeaDay,
      'countryCode': countryCode,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  /// Convert to JSON-serializable map (for sharing)
  Map<String, dynamic> toShareableMap() {
    return {
      'id': id,
      'name': name,
      'arrivalTime': arrivalTime?.toIso8601String(),
      'departureTime': departureTime?.toIso8601String(),
      'isSeaDay': isSeaDay,
      'countryCode': countryCode,
      'latitude': latitude,
      'longitude': longitude,
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

  PortStop copyWith({
    String? id,
    String? name,
    DateTime? arrivalTime,
    DateTime? departureTime,
    bool? isSeaDay,
    String? countryCode,
    double? latitude,
    double? longitude,
  }) {
    return PortStop(
      id: id ?? this.id,
      name: name ?? this.name,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      departureTime: departureTime ?? this.departureTime,
      isSeaDay: isSeaDay ?? this.isSeaDay,
      countryCode: countryCode ?? this.countryCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
