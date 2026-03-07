# Cruisy App - AI Agent Documentation

## Project Overview

Cruisy is a **Flutter-based mobile application** for cruise trip planning and voyage management. The app allows users to:

- Track their cruise trips and itineraries
- Manage port stops and sea days
- Share trips with friends
- View cruise statistics and passport history

The project follows a **feature-based architecture** with clean separation between UI, business logic, and data layers.

### Technology Stack

- **Frontend**: Flutter 3.6+ with Dart
- **State Management**: Riverpod + Flutter Hooks
- **Navigation**: go_router
- **Backend**: Firebase (Auth, Firestore)
- **Maps**: Mapbox Maps Flutter
- **Localization**: English, German (ARB files)

---

## Project Structure

```
lib/
├── core/
│   ├── providers/          # Riverpod providers for state management
│   │   ├── auth_provider.dart
│   │   ├── share_provider.dart
│   │   └── trip_provider.dart
│   └── services/           # Business logic and data access
│       ├── auth_service.dart
│       ├── deep_link_service.dart
│       ├── port_search_service.dart
│       ├── share_service.dart
│       ├── trip_service.dart
│       └── wpi_ports_data.dart
├── features/               # Feature-based UI organization
│   ├── auth/presentation/
│   ├── dashboard/presentation/
│   ├── friends/presentation/
│   ├── home/presentation/
│   ├── map/presentation/
│   ├── settings/presentation/
│   ├── trip_detail/presentation/
│   └── trips/presentation/
├── shared/                 # Shared resources
│   ├── models/            # Data models (CruiseTrip, PortStop)
│   ├── navigation/        # Router and navigation components
│   └── ui/                # Shared UI components
├── l10n/                  # Localization files
│   ├── app_en.arb
│   ├── app_de.arb
│   └── generated/         # Generated localization classes
├── firebase_options.dart  # Firebase configuration
└── main.dart             # App entry point
```

---

## Build and Run Commands

### Prerequisites

- Flutter SDK 3.6.0 or higher
- Dart SDK (bundled with Flutter)
- Android Studio / Xcode (for platform-specific builds)
- Firebase project configuration

### Development Commands

```bash
# Get dependencies
flutter pub get

# Generate localization files
flutter gen-l10n

# Run in debug mode
flutter run

# Run on specific device
flutter run -d <device_id>

# Build APK (Android)
flutter build apk

# Build App Bundle (Android)
flutter build appbundle

# Build iOS
flutter build ios

# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
flutter format .
```

### Code Generation

Localization files are auto-generated from ARB files:
```bash
flutter gen-l10n
```

Generated files are in `lib/l10n/generated/` and should NOT be manually edited.

---

## Architecture Patterns

### State Management (Riverpod)

- **Providers**: Located in `lib/core/providers/`
- **Services**: Injected via providers, located in `lib/core/services/`
- **Pattern**: Use `ConsumerWidget`/`ConsumerStatefulWidget` for UI that needs state

Example provider usage:
```dart
// Watch auth state
final user = ref.watch(currentUserProvider);

// Watch trips stream
final trips = ref.watch(tripsProvider);
```

### Navigation (go_router)

Routes are defined in `lib/shared/navigation/router.dart`:
- `/` - Home screen
- `/login` - Authentication screen
- `/settings` - Settings screen
- `/trip-detail/:tripId` - Trip detail view
- `/trip/add` - Add new trip
- `/trip/edit/:tripId` - Edit trip
- `/friends` - Friends list
- `/import-trip` - Import shared trip

### Data Models

All models have:
- `fromFirestore()` - Factory from Firestore document
- `fromMap()` - Factory from Map
- `toMap()` - Convert to Firestore-compatible Map
- `toShareableMap()` - Convert to JSON for sharing
- `copyWith()` - Immutable updates

---

## Code Style Guidelines

### Dart/Flutter Conventions

1. **Follow Flutter Lints**: The project uses `package:flutter_lints/flutter.yaml`
2. **Naming**:
   - Classes: `PascalCase`
   - Files: `snake_case.dart`
   - Private members: `_leadingUnderscore`
   - Constants: `kConstantName` or `camelCase`

3. **Imports**: Use absolute imports with package prefix:
   ```dart
   import 'package:cruisyapp/core/providers/auth_provider.dart';
   ```

4. **Null Safety**: The project uses Dart null safety - always handle nullable values

### UI Guidelines

1. **Theme**: Dark mode only (defined in `main.dart`)
   - Seed color: `Color(0xFF003366)` (navy blue)
   - Font: Google Fonts "Outfit"

2. **Card Style**: 
   - Elevation: 0
   - Border radius: 28
   
3. **Button Style**:
   - Border radius: 28

4. **Navigation Bar**:
   - Height: 80

### Localization

All user-facing strings must use localization:
```dart
final l10n = AppLocalizations.of(context)!;
Text(l10n.appTitle);
```

Add new strings to `lib/l10n/app_en.arb` first, then `app_de.arb`.

---

## Testing

### Current Test Setup

Tests are located in `test/` directory. Currently minimal test coverage with placeholder tests.

### Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

### Test Guidelines

- Widget tests should mock Firebase services
- Use `ProviderScope` with overrides for testing Riverpod providers
- Integration tests require Firebase configuration

---

## Security Considerations

### Firebase

- Service account JSON should NEVER be committed (in `.gitignore`)
- API keys are configured in `firebase_options.dart` (these are public client keys)

### Credentials to Protect

- Any API keys in `android/app/google-services.json`

### Huawei Compatibility

The app gracefully handles devices without Google Play Services:
- Firebase initialization is wrapped in try-catch
- Falls back to guest mode when Firebase unavailable

---

## Common Development Tasks

### Adding a New Screen

1. Create file in appropriate `features/*/presentation/` directory
2. Add route to `lib/shared/navigation/router.dart`
3. Use `ConsumerWidget` or `ConsumerStatefulWidget` if state needed
4. Add localization strings to ARB files

### Adding a New Model

1. Create in `lib/shared/models/`
2. Include: `fromFirestore`, `fromMap`, `toMap`, `toShareableMap`, `copyWith`
3. Handle Firestore `Timestamp` to `DateTime` conversion

### Adding Localization

1. Add string to `lib/l10n/app_en.arb` with description
2. Add translation to `lib/l10n/app_de.arb`
3. Run `flutter gen-l10n`
4. Use via `AppLocalizations.of(context)!.yourKey`

---

## Troubleshooting

### Common Issues

**Build failures after Flutter upgrade:**
```bash
flutter clean
flutter pub get
```

**Localization not updating:**
```bash
flutter gen-l10n
```

**Firebase not initializing (dev environment):**
- Check `firebase_options.dart` exists
- Verify `google-services.json` in `android/app/`

**Mapbox not loading:**
- Check Mapbox access token configuration
- Verify internet permission in AndroidManifest.xml

---

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Riverpod Documentation](https://riverpod.dev/)
- [go_router Documentation](https://pub.dev/packages/go_router)
- [Mapbox Flutter Documentation](https://docs.mapbox.com/flutter/)
- [Firebase Flutter Setup](https://firebase.google.com/docs/flutter/setup)
