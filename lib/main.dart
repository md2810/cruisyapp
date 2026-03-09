import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cruisyapp/l10n/generated/app_localizations.dart';

import 'core/providers/auth_provider.dart';
import 'firebase_options.dart';
import 'shared/navigation/router.dart';

// Locale provider for language switching - syncs with Firebase
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  return LocaleNotifier();
});

// User ID provider for language sync
final currentUserIdProvider = StateProvider<String?>((ref) => null);

class LocaleNotifier extends StateNotifier<Locale?> {
  bool _isInitialized = false;
  String? _currentUserId;

  LocaleNotifier() : super(null);

  Future<void> initialize(String? userId) async {
    if (_isInitialized && _currentUserId == userId) return;
    _isInitialized = true;
    _currentUserId = userId;

    if (userId == null) {
      state = null;
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists && doc.data()?['language'] != null) {
        final langCode = doc.data()!['language'] as String;
        state = Locale(langCode);
      }
    } catch (e) {
      debugPrint('Failed to load language preference: $e');
    }
  }

  Future<void> setLocale(Locale? locale, String? userId) async {
    state = locale;
    _currentUserId = userId;

    if (userId == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .set({
        'language': locale?.languageCode,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Failed to save language preference: $e');
    }
  }
}

// Firebase availability provider
final firebaseAvailableProvider = StateProvider<bool>((ref) => false);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Try to initialize Firebase, but don't crash if it fails
  // (e.g., on Huawei devices without Google Play Services)
  bool firebaseInitialized = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseInitialized = true;
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    debugPrint('App will continue without Firebase services.');
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(
    ProviderScope(
      overrides: [
        firebaseAvailableProvider.overrideWith((ref) => firebaseInitialized),
      ],
      child: const CruisyApp(),
    ),
  );
}

class CruisyApp extends ConsumerWidget {
  const CruisyApp({super.key});

  static const _seedColor = Color(0xFF003366);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);
    
    // Initialize auth state listener (including locale sync)
    ref.watch(authStateListenerProvider);

    final textTheme = GoogleFonts.outfitTextTheme(
      ThemeData.dark().textTheme,
    );

    return MaterialApp.router(
      title: 'Cruisy',
      debugShowCheckedModeBanner: false,

      // Localization
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('de'),
      ],

      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.dark,
        ),
        textTheme: textTheme,
        appBarTheme: AppBarTheme(
          centerTitle: false,
          titleTextStyle: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          height: 80,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
              );
            }
            return textTheme.labelSmall;
          }),
        ),
      ),
      routerConfig: router,
    );
  }
}
