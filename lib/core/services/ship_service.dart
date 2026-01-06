import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../shared/models/cruise_ship.dart';

class ShipServiceException implements Exception {
  final String message;
  final dynamic originalError;

  const ShipServiceException(this.message, [this.originalError]);

  @override
  String toString() => message;
}

class ShipService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _shipsCollection =>
      _firestore.collection('ships');

  CollectionReference<Map<String, dynamic>> get _livePositionsCollection =>
      _firestore.collection('live_positions');

  /// Get all active ships
  Stream<List<CruiseShip>> getShipsStream() {
    return _shipsCollection
        .where('active', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return CruiseShip.fromFirestore(doc);
      }).toList();
    }).handleError((error) {
      debugPrint('ShipService: Error getting ships stream - $error');
      throw ShipServiceException('Failed to load ships', error);
    });
  }

  /// Get all ships (one-time fetch)
  Future<List<CruiseShip>> getShips() async {
    try {
      final snapshot = await _shipsCollection
          .where('active', isEqualTo: true)
          .orderBy('name')
          .get();

      return snapshot.docs.map((doc) {
        return CruiseShip.fromFirestore(doc);
      }).toList();
    } on FirebaseException catch (e) {
      debugPrint('ShipService: Firebase error getting ships - ${e.message}');
      throw ShipServiceException('Failed to load ships: ${e.message}', e);
    } catch (e) {
      debugPrint('ShipService: Unexpected error getting ships - $e');
      throw ShipServiceException('An unexpected error occurred', e);
    }
  }

  /// Search ships by name
  Future<List<CruiseShip>> searchShips(String query) async {
    try {
      final ships = await getShips();
      if (query.isEmpty) return ships;

      final lowerQuery = query.toLowerCase();
      return ships.where((ship) {
        return ship.name.toLowerCase().contains(lowerQuery) ||
            ship.company.toLowerCase().contains(lowerQuery);
      }).toList();
    } catch (e) {
      debugPrint('ShipService: Error searching ships - $e');
      throw ShipServiceException('Failed to search ships', e);
    }
  }

  /// Get ship by MMSI
  Future<CruiseShip?> getShipByMmsi(int mmsi) async {
    try {
      final snapshot = await _shipsCollection
          .where('mmsi', isEqualTo: mmsi)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return CruiseShip.fromFirestore(snapshot.docs.first);
    } on FirebaseException catch (e) {
      debugPrint('ShipService: Firebase error getting ship - ${e.message}');
      throw ShipServiceException('Failed to load ship: ${e.message}', e);
    } catch (e) {
      debugPrint('ShipService: Unexpected error getting ship - $e');
      throw ShipServiceException('An unexpected error occurred', e);
    }
  }

  /// Get live position for a ship
  Future<LivePosition?> getLivePosition(int mmsi) async {
    try {
      final doc = await _livePositionsCollection.doc(mmsi.toString()).get();
      if (!doc.exists) return null;
      return LivePosition.fromFirestore(doc);
    } on FirebaseException catch (e) {
      debugPrint('ShipService: Firebase error getting position - ${e.message}');
      throw ShipServiceException('Failed to load position: ${e.message}', e);
    } catch (e) {
      debugPrint('ShipService: Unexpected error getting position - $e');
      throw ShipServiceException('An unexpected error occurred', e);
    }
  }

  /// Stream live position for a ship
  Stream<LivePosition?> getLivePositionStream(int mmsi) {
    return _livePositionsCollection
        .doc(mmsi.toString())
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return LivePosition.fromFirestore(doc);
    }).handleError((error) {
      debugPrint('ShipService: Error getting position stream - $error');
      throw ShipServiceException('Failed to load position', error);
    });
  }
}
