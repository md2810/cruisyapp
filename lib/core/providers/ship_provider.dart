import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/cruise_ship.dart';
import '../services/ship_service.dart';

final shipServiceProvider = Provider<ShipService>((ref) {
  return ShipService();
});

final shipsStreamProvider = StreamProvider<List<CruiseShip>>((ref) {
  final shipService = ref.watch(shipServiceProvider);
  return shipService.getShipsStream();
});

final shipsProvider = Provider<List<CruiseShip>>((ref) {
  return ref.watch(shipsStreamProvider).valueOrNull ?? [];
});

final shipByMmsiProvider = Provider.family<CruiseShip?, int>((ref, mmsi) {
  final ships = ref.watch(shipsProvider);
  try {
    return ships.firstWhere((ship) => ship.mmsi == mmsi);
  } catch (_) {
    return null;
  }
});

final livePositionProvider =
    StreamProvider.family<LivePosition?, int>((ref, mmsi) {
  final shipService = ref.watch(shipServiceProvider);
  return shipService.getLivePositionStream(mmsi);
});

/// Hardcoded fallback list of popular cruise ships
/// This is used when Firestore is not available or returns an empty list
const List<Map<String, dynamic>> _fallbackShips = [
  // AIDA Cruises
  {'name': 'AIDAprima', 'company': 'AIDA Cruises', 'mmsi': 211349270},
  {'name': 'AIDAperla', 'company': 'AIDA Cruises', 'mmsi': 211362320},
  {'name': 'AIDAnova', 'company': 'AIDA Cruises', 'mmsi': 211368350},
  {'name': 'AIDAcosma', 'company': 'AIDA Cruises', 'mmsi': 211378270},
  {'name': 'AIDAbella', 'company': 'AIDA Cruises', 'mmsi': 211305710},
  {'name': 'AIDAblu', 'company': 'AIDA Cruises', 'mmsi': 247295800},
  {'name': 'AIDAdiva', 'company': 'AIDA Cruises', 'mmsi': 211310290},
  {'name': 'AIDAluna', 'company': 'AIDA Cruises', 'mmsi': 211318040},
  {'name': 'AIDAmar', 'company': 'AIDA Cruises', 'mmsi': 211326280},
  {'name': 'AIDAsol', 'company': 'AIDA Cruises', 'mmsi': 211330610},
  {'name': 'AIDAstella', 'company': 'AIDA Cruises', 'mmsi': 247316100},

  // TUI Cruises (Mein Schiff)
  {'name': 'Mein Schiff 1', 'company': 'TUI Cruises', 'mmsi': 255806360},
  {'name': 'Mein Schiff 2', 'company': 'TUI Cruises', 'mmsi': 255806370},
  {'name': 'Mein Schiff 3', 'company': 'TUI Cruises', 'mmsi': 256622000},
  {'name': 'Mein Schiff 4', 'company': 'TUI Cruises', 'mmsi': 256622000},
  {'name': 'Mein Schiff 5', 'company': 'TUI Cruises', 'mmsi': 256622000},
  {'name': 'Mein Schiff 6', 'company': 'TUI Cruises', 'mmsi': 256622000},
  {'name': 'Mein Schiff 7', 'company': 'TUI Cruises', 'mmsi': 256622000},

  // Royal Caribbean
  {'name': 'Icon of the Seas', 'company': 'Royal Caribbean', 'mmsi': 311000726},
  {'name': 'Wonder of the Seas', 'company': 'Royal Caribbean', 'mmsi': 311000651},
  {'name': 'Symphony of the Seas', 'company': 'Royal Caribbean', 'mmsi': 311000587},
  {'name': 'Harmony of the Seas', 'company': 'Royal Caribbean', 'mmsi': 311000541},
  {'name': 'Oasis of the Seas', 'company': 'Royal Caribbean', 'mmsi': 311000484},
  {'name': 'Allure of the Seas', 'company': 'Royal Caribbean', 'mmsi': 311000491},
  {'name': 'Spectrum of the Seas', 'company': 'Royal Caribbean', 'mmsi': 311000619},
  {'name': 'Odyssey of the Seas', 'company': 'Royal Caribbean', 'mmsi': 311000654},
  {'name': 'Anthem of the Seas', 'company': 'Royal Caribbean', 'mmsi': 311000534},
  {'name': 'Quantum of the Seas', 'company': 'Royal Caribbean', 'mmsi': 311000521},
  {'name': 'Ovation of the Seas', 'company': 'Royal Caribbean', 'mmsi': 311000548},
  {'name': 'Navigator of the Seas', 'company': 'Royal Caribbean', 'mmsi': 311000391},
  {'name': 'Independence of the Seas', 'company': 'Royal Caribbean', 'mmsi': 311000424},
  {'name': 'Freedom of the Seas', 'company': 'Royal Caribbean', 'mmsi': 311000410},
  {'name': 'Liberty of the Seas', 'company': 'Royal Caribbean', 'mmsi': 311000417},
  {'name': 'Adventure of the Seas', 'company': 'Royal Caribbean', 'mmsi': 311000363},
  {'name': 'Explorer of the Seas', 'company': 'Royal Caribbean', 'mmsi': 311000348},
  {'name': 'Mariner of the Seas', 'company': 'Royal Caribbean', 'mmsi': 311000356},
  {'name': 'Voyager of the Seas', 'company': 'Royal Caribbean', 'mmsi': 311000341},
  {'name': 'Serenade of the Seas', 'company': 'Royal Caribbean', 'mmsi': 311000384},
  {'name': 'Jewel of the Seas', 'company': 'Royal Caribbean', 'mmsi': 311000377},
  {'name': 'Brilliance of the Seas', 'company': 'Royal Caribbean', 'mmsi': 311000370},
  {'name': 'Radiance of the Seas', 'company': 'Royal Caribbean', 'mmsi': 311000355},
  {'name': 'Vision of the Seas', 'company': 'Royal Caribbean', 'mmsi': 311000270},
  {'name': 'Rhapsody of the Seas', 'company': 'Royal Caribbean', 'mmsi': 311000277},
  {'name': 'Grandeur of the Seas', 'company': 'Royal Caribbean', 'mmsi': 311000263},
  {'name': 'Enchantment of the Seas', 'company': 'Royal Caribbean', 'mmsi': 311000256},

  // Carnival Cruise Line
  {'name': 'Carnival Celebration', 'company': 'Carnival Cruise Line', 'mmsi': 309999000},
  {'name': 'Carnival Jubilee', 'company': 'Carnival Cruise Line', 'mmsi': 309999001},
  {'name': 'Mardi Gras', 'company': 'Carnival Cruise Line', 'mmsi': 319179000},
  {'name': 'Carnival Venezia', 'company': 'Carnival Cruise Line', 'mmsi': 319181000},
  {'name': 'Carnival Firenze', 'company': 'Carnival Cruise Line', 'mmsi': 319182000},
  {'name': 'Carnival Panorama', 'company': 'Carnival Cruise Line', 'mmsi': 319083000},
  {'name': 'Carnival Horizon', 'company': 'Carnival Cruise Line', 'mmsi': 319081000},
  {'name': 'Carnival Vista', 'company': 'Carnival Cruise Line', 'mmsi': 319046000},
  {'name': 'Carnival Breeze', 'company': 'Carnival Cruise Line', 'mmsi': 309621000},
  {'name': 'Carnival Magic', 'company': 'Carnival Cruise Line', 'mmsi': 309606000},
  {'name': 'Carnival Dream', 'company': 'Carnival Cruise Line', 'mmsi': 309584000},

  // Norwegian Cruise Line
  {'name': 'Norwegian Prima', 'company': 'Norwegian Cruise Line', 'mmsi': 311000702},
  {'name': 'Norwegian Viva', 'company': 'Norwegian Cruise Line', 'mmsi': 311000717},
  {'name': 'Norwegian Encore', 'company': 'Norwegian Cruise Line', 'mmsi': 311000636},
  {'name': 'Norwegian Bliss', 'company': 'Norwegian Cruise Line', 'mmsi': 311000602},
  {'name': 'Norwegian Joy', 'company': 'Norwegian Cruise Line', 'mmsi': 311000581},
  {'name': 'Norwegian Escape', 'company': 'Norwegian Cruise Line', 'mmsi': 311000535},
  {'name': 'Norwegian Breakaway', 'company': 'Norwegian Cruise Line', 'mmsi': 311000500},
  {'name': 'Norwegian Getaway', 'company': 'Norwegian Cruise Line', 'mmsi': 311000507},
  {'name': 'Norwegian Epic', 'company': 'Norwegian Cruise Line', 'mmsi': 311000485},

  // MSC Cruises
  {'name': 'MSC World Europa', 'company': 'MSC Cruises', 'mmsi': 256623000},
  {'name': 'MSC Seascape', 'company': 'MSC Cruises', 'mmsi': 256622000},
  {'name': 'MSC Seashore', 'company': 'MSC Cruises', 'mmsi': 256619000},
  {'name': 'MSC Virtuosa', 'company': 'MSC Cruises', 'mmsi': 256614000},
  {'name': 'MSC Grandiosa', 'company': 'MSC Cruises', 'mmsi': 256611000},
  {'name': 'MSC Bellissima', 'company': 'MSC Cruises', 'mmsi': 256608000},
  {'name': 'MSC Meraviglia', 'company': 'MSC Cruises', 'mmsi': 256603000},
  {'name': 'MSC Seaview', 'company': 'MSC Cruises', 'mmsi': 256606000},
  {'name': 'MSC Seaside', 'company': 'MSC Cruises', 'mmsi': 256604000},
  {'name': 'MSC Euribia', 'company': 'MSC Cruises', 'mmsi': 256621000},

  // Costa Cruises
  {'name': 'Costa Smeralda', 'company': 'Costa Cruises', 'mmsi': 247448800},
  {'name': 'Costa Toscana', 'company': 'Costa Cruises', 'mmsi': 247463300},
  {'name': 'Costa Firenze', 'company': 'Costa Cruises', 'mmsi': 247390100},
  {'name': 'Costa Diadema', 'company': 'Costa Cruises', 'mmsi': 247354200},
  {'name': 'Costa Fascinosa', 'company': 'Costa Cruises', 'mmsi': 247315900},
  {'name': 'Costa Favolosa', 'company': 'Costa Cruises', 'mmsi': 247302200},

  // Princess Cruises
  {'name': 'Sun Princess', 'company': 'Princess Cruises', 'mmsi': 310666000},
  {'name': 'Discovery Princess', 'company': 'Princess Cruises', 'mmsi': 310626000},
  {'name': 'Enchanted Princess', 'company': 'Princess Cruises', 'mmsi': 310612000},
  {'name': 'Sky Princess', 'company': 'Princess Cruises', 'mmsi': 310608000},
  {'name': 'Majestic Princess', 'company': 'Princess Cruises', 'mmsi': 310555000},
  {'name': 'Royal Princess', 'company': 'Princess Cruises', 'mmsi': 310505000},
  {'name': 'Regal Princess', 'company': 'Princess Cruises', 'mmsi': 310496000},
  {'name': 'Crown Princess', 'company': 'Princess Cruises', 'mmsi': 310438000},
  {'name': 'Caribbean Princess', 'company': 'Princess Cruises', 'mmsi': 310421000},

  // Celebrity Cruises
  {'name': 'Celebrity Ascent', 'company': 'Celebrity Cruises', 'mmsi': 256643000},
  {'name': 'Celebrity Beyond', 'company': 'Celebrity Cruises', 'mmsi': 256632000},
  {'name': 'Celebrity Apex', 'company': 'Celebrity Cruises', 'mmsi': 256621000},
  {'name': 'Celebrity Edge', 'company': 'Celebrity Cruises', 'mmsi': 256608000},
  {'name': 'Celebrity Reflection', 'company': 'Celebrity Cruises', 'mmsi': 256509000},
  {'name': 'Celebrity Silhouette', 'company': 'Celebrity Cruises', 'mmsi': 256495000},
  {'name': 'Celebrity Eclipse', 'company': 'Celebrity Cruises', 'mmsi': 256482000},
  {'name': 'Celebrity Equinox', 'company': 'Celebrity Cruises', 'mmsi': 256469000},
  {'name': 'Celebrity Solstice', 'company': 'Celebrity Cruises', 'mmsi': 256456000},

  // Holland America Line
  {'name': 'Rotterdam', 'company': 'Holland America Line', 'mmsi': 244198000},
  {'name': 'Nieuw Statendam', 'company': 'Holland America Line', 'mmsi': 244158000},
  {'name': 'Koningsdam', 'company': 'Holland America Line', 'mmsi': 244125000},
  {'name': 'Oosterdam', 'company': 'Holland America Line', 'mmsi': 244107000},
  {'name': 'Westerdam', 'company': 'Holland America Line', 'mmsi': 244115000},
  {'name': 'Zuiderdam', 'company': 'Holland America Line', 'mmsi': 244100000},
  {'name': 'Noordam', 'company': 'Holland America Line', 'mmsi': 244082000},

  // Disney Cruise Line
  {'name': 'Disney Wish', 'company': 'Disney Cruise Line', 'mmsi': 311000714},
  {'name': 'Disney Treasure', 'company': 'Disney Cruise Line', 'mmsi': 311000730},
  {'name': 'Disney Fantasy', 'company': 'Disney Cruise Line', 'mmsi': 311000508},
  {'name': 'Disney Dream', 'company': 'Disney Cruise Line', 'mmsi': 311000493},
  {'name': 'Disney Wonder', 'company': 'Disney Cruise Line', 'mmsi': 311000256},
  {'name': 'Disney Magic', 'company': 'Disney Cruise Line', 'mmsi': 311000249},

  // Cunard
  {'name': 'Queen Mary 2', 'company': 'Cunard', 'mmsi': 310627000},
  {'name': 'Queen Elizabeth', 'company': 'Cunard', 'mmsi': 310531000},
  {'name': 'Queen Victoria', 'company': 'Cunard', 'mmsi': 310501000},
  {'name': 'Queen Anne', 'company': 'Cunard', 'mmsi': 310750000},

  // Viking Ocean
  {'name': 'Viking Saturn', 'company': 'Viking Ocean', 'mmsi': 258764000},
  {'name': 'Viking Mars', 'company': 'Viking Ocean', 'mmsi': 258762000},
  {'name': 'Viking Neptune', 'company': 'Viking Ocean', 'mmsi': 258760000},
  {'name': 'Viking Venus', 'company': 'Viking Ocean', 'mmsi': 258758000},
  {'name': 'Viking Sea', 'company': 'Viking Ocean', 'mmsi': 258754000},
  {'name': 'Viking Star', 'company': 'Viking Ocean', 'mmsi': 258752000},
  {'name': 'Viking Sky', 'company': 'Viking Ocean', 'mmsi': 258756000},
  {'name': 'Viking Orion', 'company': 'Viking Ocean', 'mmsi': 258759000},
  {'name': 'Viking Jupiter', 'company': 'Viking Ocean', 'mmsi': 258761000},

  // Hurtigruten
  {'name': 'MS Fridtjof Nansen', 'company': 'Hurtigruten', 'mmsi': 259387000},
  {'name': 'MS Roald Amundsen', 'company': 'Hurtigruten', 'mmsi': 259385000},
];

List<CruiseShip> _getFallbackShips() {
  return _fallbackShips.map((data) {
    return CruiseShip(
      id: data['mmsi'].toString(),
      name: data['name'] as String,
      company: data['company'] as String,
      mmsi: data['mmsi'] as int,
      active: true,
    );
  }).toList();
}

/// Provider for searching ships with a query
class ShipSearchNotifier extends StateNotifier<AsyncValue<List<CruiseShip>>> {
  final ShipService _shipService;

  ShipSearchNotifier(this._shipService) : super(const AsyncValue.loading()) {
    _loadShips();
  }

  List<CruiseShip> _allShips = [];
  String _currentQuery = '';

  Future<void> _loadShips() async {
    try {
      _allShips = await _shipService.getShips();
      // If Firestore returns empty, use fallback
      if (_allShips.isEmpty) {
        _allShips = _getFallbackShips();
      }
      state = AsyncValue.data(_allShips);
    } catch (e) {
      // On error, use fallback ships instead of showing error
      _allShips = _getFallbackShips();
      state = AsyncValue.data(_allShips);
    }
  }

  void search(String query) {
    _currentQuery = query.toLowerCase();
    if (_currentQuery.isEmpty) {
      state = AsyncValue.data(_allShips);
      return;
    }

    final filtered = _allShips.where((ship) {
      return ship.name.toLowerCase().contains(_currentQuery) ||
          ship.company.toLowerCase().contains(_currentQuery);
    }).toList();

    state = AsyncValue.data(filtered);
  }

  void refresh() {
    state = const AsyncValue.loading();
    _loadShips();
  }
}

final shipSearchProvider =
    StateNotifierProvider<ShipSearchNotifier, AsyncValue<List<CruiseShip>>>(
        (ref) {
  final shipService = ref.watch(shipServiceProvider);
  return ShipSearchNotifier(shipService);
});
