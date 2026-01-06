import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../shared/models/cruise_trip.dart';

class TripServiceException implements Exception {
  final String message;
  final dynamic originalError;

  const TripServiceException(this.message, [this.originalError]);

  @override
  String toString() => message;
}

class TripService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId;

  TripService({required this.userId});

  CollectionReference<Map<String, dynamic>> get _tripsCollection =>
      _firestore.collection('users').doc(userId).collection('trips');

  Stream<List<CruiseTrip>> getTripsStream() {
    return _tripsCollection
        .orderBy('departureDate', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return CruiseTrip.fromFirestore(doc);
      }).toList();
    }).handleError((error) {
      debugPrint('TripService: Error getting trips stream - $error');
      throw TripServiceException('Failed to load trips', error);
    });
  }

  Future<List<CruiseTrip>> getTrips() async {
    try {
      final snapshot = await _tripsCollection
          .orderBy('departureDate', descending: false)
          .get();

      return snapshot.docs.map((doc) {
        return CruiseTrip.fromFirestore(doc);
      }).toList();
    } on FirebaseException catch (e) {
      debugPrint('TripService: Firebase error getting trips - ${e.message}');
      throw TripServiceException('Failed to load trips: ${e.message}', e);
    } catch (e) {
      debugPrint('TripService: Unexpected error getting trips - $e');
      throw TripServiceException('An unexpected error occurred', e);
    }
  }

  Future<CruiseTrip?> getTripById(String tripId) async {
    try {
      final doc = await _tripsCollection.doc(tripId).get();
      if (!doc.exists) return null;
      return CruiseTrip.fromFirestore(doc);
    } on FirebaseException catch (e) {
      debugPrint('TripService: Firebase error getting trip - ${e.message}');
      throw TripServiceException('Failed to load trip: ${e.message}', e);
    } catch (e) {
      debugPrint('TripService: Unexpected error getting trip - $e');
      throw TripServiceException('An unexpected error occurred', e);
    }
  }

  Future<String> addTrip(CruiseTrip trip) async {
    try {
      final docRef = await _tripsCollection.add(trip.toMap());
      debugPrint('TripService: Trip added with id ${docRef.id}');
      return docRef.id;
    } on FirebaseException catch (e) {
      debugPrint('TripService: Firebase error adding trip - ${e.message}');
      throw TripServiceException('Failed to add trip: ${e.message}', e);
    } catch (e) {
      debugPrint('TripService: Unexpected error adding trip - $e');
      throw TripServiceException('An unexpected error occurred', e);
    }
  }

  Future<void> updateTrip(CruiseTrip trip) async {
    try {
      await _tripsCollection.doc(trip.id).update(trip.toMap());
      debugPrint('TripService: Trip ${trip.id} updated');
    } on FirebaseException catch (e) {
      debugPrint('TripService: Firebase error updating trip - ${e.message}');
      throw TripServiceException('Failed to update trip: ${e.message}', e);
    } catch (e) {
      debugPrint('TripService: Unexpected error updating trip - $e');
      throw TripServiceException('An unexpected error occurred', e);
    }
  }

  Future<void> deleteTrip(String tripId) async {
    try {
      await _tripsCollection.doc(tripId).delete();
      debugPrint('TripService: Trip $tripId deleted');
    } on FirebaseException catch (e) {
      debugPrint('TripService: Firebase error deleting trip - ${e.message}');
      throw TripServiceException('Failed to delete trip: ${e.message}', e);
    } catch (e) {
      debugPrint('TripService: Unexpected error deleting trip - $e');
      throw TripServiceException('An unexpected error occurred', e);
    }
  }
}
