import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'wpi_ports_data.dart';

final portSearchServiceProvider = Provider<PortSearchService>((ref) {
  return PortSearchService();
});

class PortSearchResult {
  final String name;
  final String? countryCode;
  final double latitude;
  final double longitude;

  const PortSearchResult({
    required this.name,
    this.countryCode,
    required this.latitude,
    required this.longitude,
  });

  /// Display name with country for UI
  String get displayName => countryCode != null ? '$name, $countryCode' : name;
}

class PortSearchService {
  List<PortSearchResult> search(String query) {
    if (query.isEmpty) {
      // Return popular cruise ports as default suggestions
      return _getPopularPorts();
    }

    final lowerQuery = query.toLowerCase();

    // Search by port name or country
    final results = _wpiPorts
        .where((port) =>
            port.name.toLowerCase().contains(lowerQuery) ||
            (port.countryCode?.toLowerCase().contains(lowerQuery) ?? false))
        .take(30)
        .toList();

    // Sort results: exact matches first, then starts-with, then contains
    results.sort((a, b) {
      final aName = a.name.toLowerCase();
      final bName = b.name.toLowerCase();

      // Exact match
      if (aName == lowerQuery && bName != lowerQuery) return -1;
      if (bName == lowerQuery && aName != lowerQuery) return 1;

      // Starts with
      final aStarts = aName.startsWith(lowerQuery);
      final bStarts = bName.startsWith(lowerQuery);
      if (aStarts && !bStarts) return -1;
      if (bStarts && !aStarts) return 1;

      // Alphabetical
      return aName.compareTo(bName);
    });

    return results;
  }

  PortSearchResult? findByName(String name) {
    final lowerName = name.toLowerCase();
    try {
      return _wpiPorts.firstWhere(
        (port) => port.name.toLowerCase() == lowerName,
      );
    } catch (e) {
      // Try partial match if exact match fails
      try {
        return _wpiPorts.firstWhere(
          (port) => port.name.toLowerCase().contains(lowerName) ||
              lowerName.contains(port.name.toLowerCase()),
        );
      } catch (e) {
        return null;
      }
    }
  }

  /// Returns a curated list of popular cruise ports for empty search
  List<PortSearchResult> _getPopularPorts() {
    const popularPortNames = [
      'Miami',
      'Fort Lauderdale',
      'Nassau',
      'Barcelona',
      'Southampton',
      'Cozumel',
      'San Juan',
      'Venice',
      'Singapore',
      'Sydney',
    ];

    return popularPortNames
        .map((name) => _wpiPorts.where((p) => p.name == name).firstOrNull)
        .whereType<PortSearchResult>()
        .toList();
  }
}
