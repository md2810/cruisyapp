import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/cruise_trip.dart';
import '../services/trip_service.dart';
import 'auth_provider.dart';

final tripServiceProvider = Provider<TripService?>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;
  return TripService(userId: userId);
});

final tripsStreamProvider = StreamProvider<List<CruiseTrip>>((ref) {
  final tripService = ref.watch(tripServiceProvider);
  if (tripService == null) {
    return Stream.value([]);
  }
  return tripService.getTripsStream();
});

final tripsProvider = Provider<List<CruiseTrip>>((ref) {
  return ref.watch(tripsStreamProvider).valueOrNull ?? [];
});

final upcomingTripsProvider = Provider<List<CruiseTrip>>((ref) {
  final trips = ref.watch(tripsProvider);
  return trips.where((trip) => trip.isUpcoming).toList()
    ..sort((a, b) => a.departureDate.compareTo(b.departureDate));
});

final pastTripsProvider = Provider<List<CruiseTrip>>((ref) {
  final trips = ref.watch(tripsProvider);
  return trips.where((trip) => trip.isCompleted).toList()
    ..sort((a, b) => b.arrivalDate.compareTo(a.arrivalDate));
});

final ongoingTripsProvider = Provider<List<CruiseTrip>>((ref) {
  final trips = ref.watch(tripsProvider);
  return trips.where((trip) => trip.isOngoing).toList();
});

final nextTripProvider = Provider<CruiseTrip?>((ref) {
  final upcomingTrips = ref.watch(upcomingTripsProvider);
  if (upcomingTrips.isEmpty) return null;
  return upcomingTrips.first;
});

final tripByIdProvider = Provider.family<CruiseTrip?, String>((ref, id) {
  final trips = ref.watch(tripsProvider);
  try {
    return trips.firstWhere((trip) => trip.id == id);
  } catch (_) {
    return null;
  }
});
