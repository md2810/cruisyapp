import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

import '../../shared/models/cruise_trip.dart';
import '../../shared/models/shared_trip.dart';

class ShareServiceException implements Exception {
  final String message;
  final dynamic originalError;

  const ShareServiceException(this.message, [this.originalError]);

  @override
  String toString() => message;
}

class ShareService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId;

  ShareService({required this.userId});

  CollectionReference<Map<String, dynamic>> get _sharedTripsCollection =>
      _firestore.collection('users').doc(userId).collection('shared_trips');

  /// Creates a shareable link for a trip
  Future<String> createShareLink({
    required CruiseTrip trip,
    required String ownerName,
  }) async {
    try {
      // Create share data
      final shareData = ShareData(
        ownerUid: userId,
        ownerName: ownerName,
        trip: trip.toShareableMap(),
        sharedAt: DateTime.now().toIso8601String(),
      );

      // Convert to JSON
      final jsonString = jsonEncode(shareData.toMap());

      // Compress using deflate-raw (ZLibCodec with raw: true)
      final compressed = _compress(jsonString);

      // Encode to Base64URL
      final base64Url = base64UrlEncode(compressed);

      // Create deep link
      return 'cruisy://share?data=$base64Url';
    } catch (e) {
      debugPrint('ShareService: Error creating share link - $e');
      throw ShareServiceException('Failed to create share link', e);
    }
  }

  /// Shares a trip using the system share sheet
  Future<void> shareTrip({
    required CruiseTrip trip,
    required String ownerName,
  }) async {
    try {
      final shareLink = await createShareLink(
        trip: trip,
        ownerName: ownerName,
      );

      await Share.share(
        'Check out my cruise on ${trip.shipName}!\n\n$shareLink',
        subject: '${trip.shipName} - ${trip.tripName}',
      );
    } catch (e) {
      debugPrint('ShareService: Error sharing trip - $e');
      throw ShareServiceException('Failed to share trip', e);
    }
  }

  /// Decodes a share link and returns the shared trip data
  SharedTrip? decodeShareLink(String link) {
    try {
      // Parse the URI
      final uri = Uri.parse(link);

      // Validate scheme and host
      if (uri.scheme != 'cruisy' || uri.host != 'share') {
        debugPrint('ShareService: Invalid share link scheme or host');
        return null;
      }

      // Get the data parameter
      final dataParam = uri.queryParameters['data'];
      if (dataParam == null || dataParam.isEmpty) {
        debugPrint('ShareService: No data parameter in share link');
        return null;
      }

      // Decode Base64URL
      final compressed = base64Url.decode(dataParam);

      // Decompress
      final jsonString = _decompress(compressed);

      // Parse JSON
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      // Create SharedTrip
      return SharedTrip.fromShareData(data);
    } catch (e) {
      debugPrint('ShareService: Error decoding share link - $e');
      return null;
    }
  }

  /// Imports a shared trip
  Future<String> importSharedTrip(SharedTrip sharedTrip) async {
    try {
      final doc = await _sharedTripsCollection.add(sharedTrip.toMap());
      debugPrint('ShareService: Imported shared trip with id ${doc.id}');
      return doc.id;
    } on FirebaseException catch (e) {
      debugPrint('ShareService: Firebase error importing trip - ${e.message}');
      throw ShareServiceException('Failed to import trip: ${e.message}', e);
    } catch (e) {
      debugPrint('ShareService: Unexpected error importing trip - $e');
      throw ShareServiceException('An unexpected error occurred', e);
    }
  }

  /// Gets all imported shared trips
  Stream<List<SharedTrip>> getSharedTripsStream() {
    return _sharedTripsCollection
        .orderBy('importedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return SharedTrip.fromFirestore(doc);
      }).toList();
    }).handleError((error) {
      debugPrint('ShareService: Error getting shared trips stream - $error');
      throw ShareServiceException('Failed to load shared trips', error);
    });
  }

  /// Gets all imported shared trips (one-time fetch)
  Future<List<SharedTrip>> getSharedTrips() async {
    try {
      final snapshot = await _sharedTripsCollection
          .orderBy('importedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return SharedTrip.fromFirestore(doc);
      }).toList();
    } on FirebaseException catch (e) {
      debugPrint('ShareService: Firebase error getting shared trips - ${e.message}');
      throw ShareServiceException('Failed to load shared trips: ${e.message}', e);
    } catch (e) {
      debugPrint('ShareService: Unexpected error getting shared trips - $e');
      throw ShareServiceException('An unexpected error occurred', e);
    }
  }

  /// Deletes an imported shared trip
  Future<void> deleteSharedTrip(String tripId) async {
    try {
      await _sharedTripsCollection.doc(tripId).delete();
      debugPrint('ShareService: Deleted shared trip $tripId');
    } on FirebaseException catch (e) {
      debugPrint('ShareService: Firebase error deleting shared trip - ${e.message}');
      throw ShareServiceException('Failed to delete shared trip: ${e.message}', e);
    } catch (e) {
      debugPrint('ShareService: Unexpected error deleting shared trip - $e');
      throw ShareServiceException('An unexpected error occurred', e);
    }
  }

  /// Duplicates a shared trip to user's own trips
  Future<CruiseTrip> duplicateSharedTrip(SharedTrip sharedTrip) {
    // Create a new trip from the shared trip data
    return Future.value(sharedTrip.trip.copyWith(
      id: '', // Will be assigned when saved
    ));
  }

  // Compression helpers using ZLib (deflate-raw equivalent)
  List<int> _compress(String data) {
    final bytes = utf8.encode(data);
    // Use ZLibCodec with raw mode for deflate-raw compression
    final codec = ZLibCodec(raw: true, level: ZLibOption.maxLevel);
    return codec.encode(bytes);
  }

  String _decompress(List<int> compressed) {
    // Use ZLibCodec with raw mode for deflate-raw decompression
    final codec = ZLibCodec(raw: true);
    final decompressed = codec.decode(compressed);
    return utf8.decode(decompressed);
  }
}
