import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../main.dart';
import '../services/auth_service.dart';

// Re-export currentUserIdProvider from main.dart for convenience
export '../../../main.dart' show currentUserIdProvider;

final authServiceProvider = Provider<AuthService?>((ref) {
  final firebaseAvailable = ref.watch(firebaseAvailableProvider);
  if (!firebaseAvailable) return null;
  return AuthService();
});

final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  if (authService == null) {
    // Firebase not available, return empty stream
    return Stream.value(null);
  }
  return authService.authStateChanges;
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});

// Initialize locale when auth state changes - using listen to avoid modifying providers during build
final authStateListenerProvider = Provider<void>((ref) {
  // Use listen instead of watch to handle side effects
  ref.listen(currentUserProvider, (previous, current) {
    final userId = current?.uid;
    
    // Update the currentUserIdProvider
    ref.read(currentUserIdProvider.notifier).state = userId;
    
    // Initialize locale from Firebase
    if (userId != null) {
      ref.read(localeProvider.notifier).initialize(userId);
    }
  });
});

final userDisplayNameProvider = Provider<String>((ref) {
  final authService = ref.watch(authServiceProvider);
  if (authService == null) return 'Guest';
  return authService.currentUserDisplayName;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});
