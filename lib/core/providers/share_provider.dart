import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/shared_trip.dart';
import '../services/share_service.dart';
import 'auth_provider.dart';

final shareServiceProvider = Provider<ShareService?>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;
  return ShareService(userId: userId);
});

final sharedTripsStreamProvider = StreamProvider<List<SharedTrip>>((ref) {
  final shareService = ref.watch(shareServiceProvider);
  if (shareService == null) {
    return Stream.value([]);
  }
  return shareService.getSharedTripsStream();
});

final sharedTripsProvider = Provider<List<SharedTrip>>((ref) {
  return ref.watch(sharedTripsStreamProvider).valueOrNull ?? [];
});

final sharedTripByIdProvider = Provider.family<SharedTrip?, String>((ref, id) {
  final trips = ref.watch(sharedTripsProvider);
  try {
    return trips.firstWhere((trip) => trip.id == id);
  } catch (_) {
    return null;
  }
});

/// Provider for decoding share links
final decodedShareLinkProvider = Provider.family<SharedTrip?, String>((ref, link) {
  final shareService = ref.watch(shareServiceProvider);
  if (shareService == null) return null;
  return shareService.decodeShareLink(link);
});
