import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Service for handling deep links
class DeepLinkService {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  /// Initialize the deep link listener
  Future<void> init({
    required Ref ref,
    required GoRouter router,
  }) async {
    // Handle initial link if app was launched from a deep link
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri, ref, router);
      }
    } catch (e) {
      debugPrint('DeepLinkService: Error getting initial link - $e');
    }

    // Listen for incoming links while app is running
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) => _handleDeepLink(uri, ref, router),
      onError: (e) {
        debugPrint('DeepLinkService: Error in link stream - $e');
      },
    );
  }

  void _handleDeepLink(Uri uri, Ref ref, GoRouter router) {
    debugPrint('DeepLinkService: Received deep link - $uri');

    // Handle cruisy://share?data=... links
    if (uri.scheme == 'cruisy' && uri.host == 'share') {
      final data = uri.queryParameters['data'];
      if (data != null && data.isNotEmpty) {
        // Navigate to import screen with the data
        router.push('/import-trip?data=${Uri.encodeComponent(data)}');
      }
    }
  }

  /// Dispose the deep link listener
  void dispose() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
  }
}

/// Provider for the deep link service
final deepLinkServiceProvider = Provider<DeepLinkService>((ref) {
  final service = DeepLinkService();
  ref.onDispose(() => service.dispose());
  return service;
});
