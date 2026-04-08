import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Cruisy'**
  String get appTitle;

  /// Today tab label
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Future cruises tab label
  ///
  /// In en, this message translates to:
  /// **'Future Cruises'**
  String get futureCruises;

  /// Past cruises tab label
  ///
  /// In en, this message translates to:
  /// **'Past Cruises'**
  String get pastCruises;

  /// Empty state for past cruises
  ///
  /// In en, this message translates to:
  /// **'No past cruises'**
  String get noPastCruises;

  /// Empty state for upcoming cruises
  ///
  /// In en, this message translates to:
  /// **'No upcoming cruises'**
  String get noUpcomingCruises;

  /// Empty state for today
  ///
  /// In en, this message translates to:
  /// **'No cruise today'**
  String get noCruiseToday;

  /// Subtitle for empty past cruises
  ///
  /// In en, this message translates to:
  /// **'Your completed cruises will appear here'**
  String get completedCruisesAppearHere;

  /// Subtitle for empty upcoming cruises
  ///
  /// In en, this message translates to:
  /// **'Tap the + button above to add your first cruise'**
  String get tapPlusToAddCruise;

  /// Subtitle for no cruise today
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any ongoing cruises'**
  String get noOngoingCruises;

  /// Day label singular
  ///
  /// In en, this message translates to:
  /// **'DAY'**
  String get day;

  /// Days label plural
  ///
  /// In en, this message translates to:
  /// **'DAYS'**
  String get days;

  /// Completed cruise label
  ///
  /// In en, this message translates to:
  /// **'DONE'**
  String get done;

  /// Current port label
  ///
  /// In en, this message translates to:
  /// **'Today: {portName}'**
  String todayPort(String portName);

  /// Next port label
  ///
  /// In en, this message translates to:
  /// **'Next: {portName}'**
  String nextPort(String portName);

  /// Add cruise screen title
  ///
  /// In en, this message translates to:
  /// **'Add Cruise'**
  String get addCruise;

  /// Edit cruise screen title
  ///
  /// In en, this message translates to:
  /// **'Edit Cruise'**
  String get editCruise;

  /// Ship name field label
  ///
  /// In en, this message translates to:
  /// **'Ship Name'**
  String get shipName;

  /// Ship name field hint
  ///
  /// In en, this message translates to:
  /// **'e.g. Symphony of the Seas'**
  String get shipNameHint;

  /// Trip name field label
  ///
  /// In en, this message translates to:
  /// **'Trip Name'**
  String get tripName;

  /// Trip name field hint
  ///
  /// In en, this message translates to:
  /// **'e.g. Caribbean Adventure'**
  String get tripNameHint;

  /// Start date field label
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// End date field label
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// Date picker placeholder
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// Itinerary section header
  ///
  /// In en, this message translates to:
  /// **'Itinerary'**
  String get itinerary;

  /// Day number label
  ///
  /// In en, this message translates to:
  /// **'Day {number}'**
  String dayNumber(int number);

  /// Sea day label
  ///
  /// In en, this message translates to:
  /// **'Sea Day'**
  String get seaDay;

  /// Add stop button tooltip
  ///
  /// In en, this message translates to:
  /// **'Add stop'**
  String get addStop;

  /// Multi-day stay continuation label
  ///
  /// In en, this message translates to:
  /// **'Continued from previous day'**
  String get continuedFromPreviousDay;

  /// Add port sheet title
  ///
  /// In en, this message translates to:
  /// **'Add Port'**
  String get addPort;

  /// Edit port sheet title
  ///
  /// In en, this message translates to:
  /// **'Edit Port'**
  String get editPort;

  /// Port search field hint
  ///
  /// In en, this message translates to:
  /// **'Search ports...'**
  String get searchPorts;

  /// Sea day toggle label
  ///
  /// In en, this message translates to:
  /// **'Sea Day'**
  String get isSeaDay;

  /// Sea day toggle subtitle
  ///
  /// In en, this message translates to:
  /// **'No port this day'**
  String get noPortThisDay;

  /// Multi-day stay toggle label
  ///
  /// In en, this message translates to:
  /// **'Multi-day stay'**
  String get multiDayStay;

  /// Multi-day stay toggle subtitle
  ///
  /// In en, this message translates to:
  /// **'Port visit spanning multiple days'**
  String get portVisitSpanningDays;

  /// Arrival label
  ///
  /// In en, this message translates to:
  /// **'Arrival'**
  String get arrival;

  /// Departure label
  ///
  /// In en, this message translates to:
  /// **'Departure'**
  String get departure;

  /// Date label
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// Time label
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// Time picker placeholder
  ///
  /// In en, this message translates to:
  /// **'Set time'**
  String get setTime;

  /// Save button label
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Delete button label
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Ship name validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter a ship name'**
  String get pleaseEnterShipName;

  /// Date validation error
  ///
  /// In en, this message translates to:
  /// **'Please select start and end dates'**
  String get pleaseSelectDates;

  /// Port validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter or select a port'**
  String get pleaseEnterOrSelectPort;

  /// Date validation error for port
  ///
  /// In en, this message translates to:
  /// **'Please select a date'**
  String get pleaseSelectDate;

  /// Validation error for minimum ports
  ///
  /// In en, this message translates to:
  /// **'You need at least two port stops'**
  String get needAtLeastTwoPorts;

  /// Validation error for first stop
  ///
  /// In en, this message translates to:
  /// **'First stop cannot be a sea day'**
  String get firstStopCannotBeSeaDay;

  /// Validation error for last stop
  ///
  /// In en, this message translates to:
  /// **'Last stop cannot be a sea day'**
  String get lastStopCannotBeSeaDay;

  /// Delete cruise dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Cruise'**
  String get deleteCruise;

  /// Delete cruise confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this cruise? This action cannot be undone.'**
  String get deleteCruiseConfirmation;

  /// Cruise deleted snackbar message
  ///
  /// In en, this message translates to:
  /// **'Cruise deleted'**
  String get cruiseDeleted;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Account section header
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// Sign out button label
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// Sign out confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get signOutConfirmation;

  /// Sign in button label
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get login;

  /// Sign up button label
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// Create account button label
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// Login screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Welcome back, cruiser'**
  String get welcomeBack;

  /// Sign up screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get createYourAccount;

  /// Name field label
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// Name field hint
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get yourName;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Email field hint
  ///
  /// In en, this message translates to:
  /// **'your@email.com'**
  String get emailHint;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Password field hint
  ///
  /// In en, this message translates to:
  /// **'Your password'**
  String get yourPassword;

  /// Name validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get pleaseEnterName;

  /// Email validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// Email format validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidEmail;

  /// Password validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// Password length validation error
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// Divider text between login methods
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// Google sign in button label
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// Link to sign in
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// Link to sign up
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred.'**
  String get unexpectedError;

  /// Google sign in error
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed. Please try again.'**
  String get googleSignInFailed;

  /// Duration in port
  ///
  /// In en, this message translates to:
  /// **'{hours}h in port'**
  String hoursInPort(int hours);

  /// Current stop indicator
  ///
  /// In en, this message translates to:
  /// **'NOW'**
  String get now;

  /// Overview section header
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// Total days count
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String totalDays(int count);

  /// Ports label
  ///
  /// In en, this message translates to:
  /// **'Ports'**
  String get ports;

  /// Port count
  ///
  /// In en, this message translates to:
  /// **'{count} ports'**
  String portCount(int count);

  /// Progress label
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// Progress percentage
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String progressPercent(int percent);

  /// Cruise not started status
  ///
  /// In en, this message translates to:
  /// **'Not started'**
  String get cruiseNotStarted;

  /// Cruise completed status
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get cruiseCompleted;

  /// Map section header
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get map;

  /// View full map button
  ///
  /// In en, this message translates to:
  /// **'View full map'**
  String get viewFullMap;

  /// Language setting label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// English language name
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// German language name
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get german;

  /// App info section header
  ///
  /// In en, this message translates to:
  /// **'App Info'**
  String get appInfo;

  /// Version label
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// My cruises screen title
  ///
  /// In en, this message translates to:
  /// **'My Cruises'**
  String get myCruises;

  /// All cruises filter option
  ///
  /// In en, this message translates to:
  /// **'All Cruises'**
  String get allCruises;

  /// No description provided for @voyages.
  ///
  /// In en, this message translates to:
  /// **'Voyages'**
  String get voyages;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// No description provided for @manageProfilePreferences.
  ///
  /// In en, this message translates to:
  /// **'Manage your profile and preferences'**
  String get manageProfilePreferences;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @manageNotifications.
  ///
  /// In en, this message translates to:
  /// **'Manage notification preferences'**
  String get manageNotifications;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @getHelp.
  ///
  /// In en, this message translates to:
  /// **'Get help with using Cruisy'**
  String get getHelp;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @appVersionLegal.
  ///
  /// In en, this message translates to:
  /// **'App version and legal info'**
  String get appVersionLegal;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @changeDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Change your display name'**
  String get changeDisplayName;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update your password'**
  String get updatePassword;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccountTitle;

  /// No description provided for @permanentlyDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete your account'**
  String get permanentlyDeleteAccount;

  /// No description provided for @tripReminders.
  ///
  /// In en, this message translates to:
  /// **'Trip Reminders'**
  String get tripReminders;

  /// No description provided for @getNotifiedBeforeCruise.
  ///
  /// In en, this message translates to:
  /// **'Get notified before your cruise'**
  String get getNotifiedBeforeCruise;

  /// No description provided for @portAlerts.
  ///
  /// In en, this message translates to:
  /// **'Port Alerts'**
  String get portAlerts;

  /// No description provided for @notificationsAtPorts.
  ///
  /// In en, this message translates to:
  /// **'Notifications when arriving at ports'**
  String get notificationsAtPorts;

  /// No description provided for @countdownUpdates.
  ///
  /// In en, this message translates to:
  /// **'Countdown Updates'**
  String get countdownUpdates;

  /// No description provided for @dailyCountdown.
  ///
  /// In en, this message translates to:
  /// **'Daily countdown notifications'**
  String get dailyCountdown;

  /// No description provided for @appDescription.
  ///
  /// In en, this message translates to:
  /// **'Your personal cruise companion app. Track your voyages, plan excursions, and never miss a moment of your cruise adventure.'**
  String get appDescription;

  /// No description provided for @newVoyage.
  ///
  /// In en, this message translates to:
  /// **'New Voyage'**
  String get newVoyage;

  /// No description provided for @editVoyage.
  ///
  /// In en, this message translates to:
  /// **'Edit Voyage'**
  String get editVoyage;

  /// No description provided for @addCruiseTracking.
  ///
  /// In en, this message translates to:
  /// **'Add your upcoming cruise to start tracking'**
  String get addCruiseTracking;

  /// No description provided for @updateCruiseDetails.
  ///
  /// In en, this message translates to:
  /// **'Update your cruise details'**
  String get updateCruiseDetails;

  /// No description provided for @tripNameOptional.
  ///
  /// In en, this message translates to:
  /// **'Trip Name (Optional)'**
  String get tripNameOptional;

  /// No description provided for @travelDates.
  ///
  /// In en, this message translates to:
  /// **'Travel Dates'**
  String get travelDates;

  /// No description provided for @selectDepartureDates.
  ///
  /// In en, this message translates to:
  /// **'Select departure and return dates'**
  String get selectDepartureDates;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @selectTravelDatesFirst.
  ///
  /// In en, this message translates to:
  /// **'Select travel dates first'**
  String get selectTravelDatesFirst;

  /// No description provided for @addPortsSeaDays.
  ///
  /// In en, this message translates to:
  /// **'Then add your ports and sea days'**
  String get addPortsSeaDays;

  /// No description provided for @noActivityPlanned.
  ///
  /// In en, this message translates to:
  /// **'No activity planned'**
  String get noActivityPlanned;

  /// No description provided for @continued.
  ///
  /// In en, this message translates to:
  /// **'{name} (continued)'**
  String continued(String name);

  /// No description provided for @arrivesTime.
  ///
  /// In en, this message translates to:
  /// **'Arrives {time}'**
  String arrivesTime(String time);

  /// No description provided for @addStopTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Stop'**
  String get addStopTitle;

  /// No description provided for @editStopTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Stop'**
  String get editStopTitle;

  /// No description provided for @dayAtSeaNoPort.
  ///
  /// In en, this message translates to:
  /// **'Day at sea with no port'**
  String get dayAtSeaNoPort;

  /// No description provided for @portNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Port Name'**
  String get portNameLabel;

  /// No description provided for @searchPort.
  ///
  /// In en, this message translates to:
  /// **'Search for a port...'**
  String get searchPort;

  /// No description provided for @coordinatesSaved.
  ///
  /// In en, this message translates to:
  /// **'Coordinates saved for map'**
  String get coordinatesSaved;

  /// No description provided for @arrivalDate.
  ///
  /// In en, this message translates to:
  /// **'Arrival Date'**
  String get arrivalDate;

  /// No description provided for @departureDate.
  ///
  /// In en, this message translates to:
  /// **'Departure Date'**
  String get departureDate;

  /// No description provided for @timesOptional.
  ///
  /// In en, this message translates to:
  /// **'Times (Optional)'**
  String get timesOptional;

  /// No description provided for @updateStop.
  ///
  /// In en, this message translates to:
  /// **'Update Stop'**
  String get updateStop;

  /// No description provided for @pleaseSelectTripDatesFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select trip dates first'**
  String get pleaseSelectTripDatesFirst;

  /// No description provided for @tripNotFound.
  ///
  /// In en, this message translates to:
  /// **'Trip not found'**
  String get tripNotFound;

  /// No description provided for @voyageMayBeDeleted.
  ///
  /// In en, this message translates to:
  /// **'This voyage may have been deleted'**
  String get voyageMayBeDeleted;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// No description provided for @editTripMenu.
  ///
  /// In en, this message translates to:
  /// **'Edit Trip'**
  String get editTripMenu;

  /// No description provided for @shareMenu.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareMenu;

  /// No description provided for @shareComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Share feature coming soon!'**
  String get shareComingSoon;

  /// No description provided for @deleteTripMenu.
  ///
  /// In en, this message translates to:
  /// **'Delete Trip'**
  String get deleteTripMenu;

  /// No description provided for @deleteTripConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?\n\nThis action cannot be undone.'**
  String deleteTripConfirmation(String name);

  /// No description provided for @tripDeleted.
  ///
  /// In en, this message translates to:
  /// **'{name} deleted'**
  String tripDeleted(String name);

  /// No description provided for @failedToDelete.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete: {error}'**
  String failedToDelete(String error);

  /// No description provided for @voyageInProgress.
  ///
  /// In en, this message translates to:
  /// **'VOYAGE IN PROGRESS'**
  String get voyageInProgress;

  /// No description provided for @daysUntil.
  ///
  /// In en, this message translates to:
  /// **'DAYS UNTIL'**
  String get daysUntil;

  /// No description provided for @dayLabel.
  ///
  /// In en, this message translates to:
  /// **'Day {number}'**
  String dayLabel(int number);

  /// No description provided for @daysLabel.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get daysLabel;

  /// No description provided for @departs.
  ///
  /// In en, this message translates to:
  /// **'DEPARTS'**
  String get departs;

  /// No description provided for @nextLabel.
  ///
  /// In en, this message translates to:
  /// **'NEXT'**
  String get nextLabel;

  /// No description provided for @inProgressStatus.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgressStatus;

  /// No description provided for @upcomingStatus.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcomingStatus;

  /// No description provided for @noItineraryYet.
  ///
  /// In en, this message translates to:
  /// **'No itinerary added yet'**
  String get noItineraryYet;

  /// No description provided for @editTripToAddStops.
  ///
  /// In en, this message translates to:
  /// **'Edit this trip to add port stops'**
  String get editTripToAddStops;

  /// No description provided for @addStops.
  ///
  /// In en, this message translates to:
  /// **'Add Stops'**
  String get addStops;

  /// No description provided for @daysCount.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String daysCount(int count);

  /// No description provided for @todayLabel.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get todayLabel;

  /// No description provided for @tripUpdated.
  ///
  /// In en, this message translates to:
  /// **'{name} updated!'**
  String tripUpdated(String name);

  /// No description provided for @tripAdded.
  ///
  /// In en, this message translates to:
  /// **'{name} trip added!'**
  String tripAdded(String name);

  /// No description provided for @failedToSaveTrip.
  ///
  /// In en, this message translates to:
  /// **'Failed to save trip: {error}'**
  String failedToSaveTrip(String error);

  /// No description provided for @addTrip.
  ///
  /// In en, this message translates to:
  /// **'Add Trip'**
  String get addTrip;

  /// No description provided for @editTrip.
  ///
  /// In en, this message translates to:
  /// **'Edit Trip'**
  String get editTrip;

  /// No description provided for @savingTrip.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get savingTrip;

  /// No description provided for @updateTripButton.
  ///
  /// In en, this message translates to:
  /// **'Update Trip'**
  String get updateTripButton;

  /// No description provided for @saveTripButton.
  ///
  /// In en, this message translates to:
  /// **'Save Trip'**
  String get saveTripButton;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get goodEvening;

  /// No description provided for @failedToLoadTrips.
  ///
  /// In en, this message translates to:
  /// **'Failed to load trips'**
  String get failedToLoadTrips;

  /// No description provided for @noUpcomingTrips.
  ///
  /// In en, this message translates to:
  /// **'No upcoming trips'**
  String get noUpcomingTrips;

  /// No description provided for @startPlanningCruise.
  ///
  /// In en, this message translates to:
  /// **'Start planning your next cruise adventure'**
  String get startPlanningCruise;

  /// No description provided for @addFirstTrip.
  ///
  /// In en, this message translates to:
  /// **'Add Your First Trip'**
  String get addFirstTrip;

  /// No description provided for @nextTrip.
  ///
  /// In en, this message translates to:
  /// **'NEXT TRIP'**
  String get nextTrip;

  /// No description provided for @daysLowercase.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get daysLowercase;

  /// No description provided for @hoursRemaining.
  ///
  /// In en, this message translates to:
  /// **'{hours}h remaining'**
  String hoursRemaining(int hours);

  /// No description provided for @packingList.
  ///
  /// In en, this message translates to:
  /// **'Packing List'**
  String get packingList;

  /// No description provided for @documents.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documents;

  /// No description provided for @excursions.
  ///
  /// In en, this message translates to:
  /// **'Excursions'**
  String get excursions;

  /// No description provided for @dining.
  ///
  /// In en, this message translates to:
  /// **'Dining'**
  String get dining;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @myVoyages.
  ///
  /// In en, this message translates to:
  /// **'My Voyages'**
  String get myVoyages;

  /// No description provided for @checkConnection.
  ///
  /// In en, this message translates to:
  /// **'Please check your connection'**
  String get checkConnection;

  /// No description provided for @noVoyagesYet.
  ///
  /// In en, this message translates to:
  /// **'No voyages yet'**
  String get noVoyagesYet;

  /// No description provided for @startTrackingCruises.
  ///
  /// In en, this message translates to:
  /// **'Start tracking your cruise adventures\nby adding your first trip'**
  String get startTrackingCruises;

  /// No description provided for @pastTrips.
  ///
  /// In en, this message translates to:
  /// **'Past Trips'**
  String get pastTrips;

  /// No description provided for @deleteTrip.
  ///
  /// In en, this message translates to:
  /// **'Delete Trip'**
  String get deleteTrip;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @mapFailedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Map failed to load'**
  String get mapFailedToLoad;

  /// No description provided for @checkMapboxConfig.
  ///
  /// In en, this message translates to:
  /// **'Check your Mapbox configuration'**
  String get checkMapboxConfig;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// No description provided for @yourCruiseDestinations.
  ///
  /// In en, this message translates to:
  /// **'Your cruise destinations'**
  String get yourCruiseDestinations;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @trips.
  ///
  /// In en, this message translates to:
  /// **'Trips'**
  String get trips;

  /// No description provided for @allTimeCruisePassport.
  ///
  /// In en, this message translates to:
  /// **'ALL-TIME CRUISE PASSPORT'**
  String get allTimeCruisePassport;

  /// No description provided for @yearCruisePassport.
  ///
  /// In en, this message translates to:
  /// **'{year} CRUISE PASSPORT'**
  String yearCruisePassport(int year);

  /// No description provided for @passport.
  ///
  /// In en, this message translates to:
  /// **'PASSPORT'**
  String get passport;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'DISTANCE'**
  String get distance;

  /// No description provided for @ships.
  ///
  /// In en, this message translates to:
  /// **'SHIPS'**
  String get ships;

  /// No description provided for @allCruiseStats.
  ///
  /// In en, this message translates to:
  /// **'All Cruise Stats'**
  String get allCruiseStats;

  /// No description provided for @longestCruise.
  ///
  /// In en, this message translates to:
  /// **'Longest Cruise'**
  String get longestCruise;

  /// No description provided for @daysOnShip.
  ///
  /// In en, this message translates to:
  /// **'days on {shipName}'**
  String daysOnShip(String shipName);

  /// No description provided for @favoriteShip.
  ///
  /// In en, this message translates to:
  /// **'Favorite Ship'**
  String get favoriteShip;

  /// No description provided for @cruiseCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 cruise} other{{count} cruises}}'**
  String cruiseCount(int count);

  /// No description provided for @viewAllShips.
  ///
  /// In en, this message translates to:
  /// **'View all ships'**
  String get viewAllShips;

  /// No description provided for @allShips.
  ///
  /// In en, this message translates to:
  /// **'All Ships'**
  String get allShips;

  /// No description provided for @aroundWorld.
  ///
  /// In en, this message translates to:
  /// **'{times}x around the world'**
  String aroundWorld(String times);

  /// No description provided for @halfAroundWorld.
  ///
  /// In en, this message translates to:
  /// **'Half way around the world'**
  String get halfAroundWorld;

  /// No description provided for @editToAddPorts.
  ///
  /// In en, this message translates to:
  /// **'Edit this trip to add port stops'**
  String get editToAddPorts;

  /// No description provided for @addStopsButton.
  ///
  /// In en, this message translates to:
  /// **'Add Stops'**
  String get addStopsButton;

  /// No description provided for @todayBadge.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get todayBadge;

  /// No description provided for @continuedPort.
  ///
  /// In en, this message translates to:
  /// **'(continued)'**
  String get continuedPort;

  /// No description provided for @arrivesAt.
  ///
  /// In en, this message translates to:
  /// **'Arrives {time}'**
  String arrivesAt(String time);

  /// No description provided for @countryUS.
  ///
  /// In en, this message translates to:
  /// **'United States'**
  String get countryUS;

  /// No description provided for @countryDE.
  ///
  /// In en, this message translates to:
  /// **'Germany'**
  String get countryDE;

  /// No description provided for @countryES.
  ///
  /// In en, this message translates to:
  /// **'Spain'**
  String get countryES;

  /// No description provided for @countryFR.
  ///
  /// In en, this message translates to:
  /// **'France'**
  String get countryFR;

  /// No description provided for @countryIT.
  ///
  /// In en, this message translates to:
  /// **'Italy'**
  String get countryIT;

  /// No description provided for @countryGR.
  ///
  /// In en, this message translates to:
  /// **'Greece'**
  String get countryGR;

  /// No description provided for @countryHR.
  ///
  /// In en, this message translates to:
  /// **'Croatia'**
  String get countryHR;

  /// No description provided for @countryME.
  ///
  /// In en, this message translates to:
  /// **'Montenegro'**
  String get countryME;

  /// No description provided for @countryPT.
  ///
  /// In en, this message translates to:
  /// **'Portugal'**
  String get countryPT;

  /// No description provided for @countryGB.
  ///
  /// In en, this message translates to:
  /// **'United Kingdom'**
  String get countryGB;

  /// No description provided for @countryNL.
  ///
  /// In en, this message translates to:
  /// **'Netherlands'**
  String get countryNL;

  /// No description provided for @countryBE.
  ///
  /// In en, this message translates to:
  /// **'Belgium'**
  String get countryBE;

  /// No description provided for @countryNO.
  ///
  /// In en, this message translates to:
  /// **'Norway'**
  String get countryNO;

  /// No description provided for @countrySE.
  ///
  /// In en, this message translates to:
  /// **'Sweden'**
  String get countrySE;

  /// No description provided for @countryDK.
  ///
  /// In en, this message translates to:
  /// **'Denmark'**
  String get countryDK;

  /// No description provided for @countryFI.
  ///
  /// In en, this message translates to:
  /// **'Finland'**
  String get countryFI;

  /// No description provided for @countryIS.
  ///
  /// In en, this message translates to:
  /// **'Iceland'**
  String get countryIS;

  /// No description provided for @countryMT.
  ///
  /// In en, this message translates to:
  /// **'Malta'**
  String get countryMT;

  /// No description provided for @countryCY.
  ///
  /// In en, this message translates to:
  /// **'Cyprus'**
  String get countryCY;

  /// No description provided for @countryTR.
  ///
  /// In en, this message translates to:
  /// **'Turkey'**
  String get countryTR;

  /// No description provided for @countryAE.
  ///
  /// In en, this message translates to:
  /// **'United Arab Emirates'**
  String get countryAE;

  /// No description provided for @countryBS.
  ///
  /// In en, this message translates to:
  /// **'Bahamas'**
  String get countryBS;

  /// No description provided for @countryJM.
  ///
  /// In en, this message translates to:
  /// **'Jamaica'**
  String get countryJM;

  /// No description provided for @countryMX.
  ///
  /// In en, this message translates to:
  /// **'Mexico'**
  String get countryMX;

  /// No description provided for @countryBZ.
  ///
  /// In en, this message translates to:
  /// **'Belize'**
  String get countryBZ;

  /// No description provided for @countryHN.
  ///
  /// In en, this message translates to:
  /// **'Honduras'**
  String get countryHN;

  /// No description provided for @countryPA.
  ///
  /// In en, this message translates to:
  /// **'Panama'**
  String get countryPA;

  /// No description provided for @countryAW.
  ///
  /// In en, this message translates to:
  /// **'Aruba'**
  String get countryAW;

  /// No description provided for @countryCW.
  ///
  /// In en, this message translates to:
  /// **'Curacao'**
  String get countryCW;

  /// No description provided for @countrySX.
  ///
  /// In en, this message translates to:
  /// **'Sint Maarten'**
  String get countrySX;

  /// No description provided for @countryVG.
  ///
  /// In en, this message translates to:
  /// **'British Virgin Islands'**
  String get countryVG;

  /// No description provided for @countryVI.
  ///
  /// In en, this message translates to:
  /// **'US Virgin Islands'**
  String get countryVI;

  /// No description provided for @countryPR.
  ///
  /// In en, this message translates to:
  /// **'Puerto Rico'**
  String get countryPR;

  /// No description provided for @countryDO.
  ///
  /// In en, this message translates to:
  /// **'Dominican Republic'**
  String get countryDO;

  /// No description provided for @countryHT.
  ///
  /// In en, this message translates to:
  /// **'Haiti'**
  String get countryHT;

  /// No description provided for @countryAG.
  ///
  /// In en, this message translates to:
  /// **'Antigua and Barbuda'**
  String get countryAG;

  /// No description provided for @countryBB.
  ///
  /// In en, this message translates to:
  /// **'Barbados'**
  String get countryBB;

  /// No description provided for @countryLC.
  ///
  /// In en, this message translates to:
  /// **'Saint Lucia'**
  String get countryLC;

  /// No description provided for @countryGD.
  ///
  /// In en, this message translates to:
  /// **'Grenada'**
  String get countryGD;

  /// No description provided for @countryVC.
  ///
  /// In en, this message translates to:
  /// **'Saint Vincent and the Grenadines'**
  String get countryVC;

  /// No description provided for @countryKY.
  ///
  /// In en, this message translates to:
  /// **'Cayman Islands'**
  String get countryKY;

  /// No description provided for @countryTC.
  ///
  /// In en, this message translates to:
  /// **'Turks and Caicos'**
  String get countryTC;

  /// No description provided for @countryTT.
  ///
  /// In en, this message translates to:
  /// **'Trinidad and Tobago'**
  String get countryTT;

  /// No description provided for @countryCA.
  ///
  /// In en, this message translates to:
  /// **'Canada'**
  String get countryCA;

  /// No description provided for @countryAU.
  ///
  /// In en, this message translates to:
  /// **'Australia'**
  String get countryAU;

  /// No description provided for @countryNZ.
  ///
  /// In en, this message translates to:
  /// **'New Zealand'**
  String get countryNZ;

  /// No description provided for @countryJP.
  ///
  /// In en, this message translates to:
  /// **'Japan'**
  String get countryJP;

  /// No description provided for @countryCN.
  ///
  /// In en, this message translates to:
  /// **'China'**
  String get countryCN;

  /// No description provided for @countryTH.
  ///
  /// In en, this message translates to:
  /// **'Thailand'**
  String get countryTH;

  /// No description provided for @countryVN.
  ///
  /// In en, this message translates to:
  /// **'Vietnam'**
  String get countryVN;

  /// No description provided for @countrySG.
  ///
  /// In en, this message translates to:
  /// **'Singapore'**
  String get countrySG;

  /// No description provided for @countryMY.
  ///
  /// In en, this message translates to:
  /// **'Malaysia'**
  String get countryMY;

  /// No description provided for @countryID.
  ///
  /// In en, this message translates to:
  /// **'Indonesia'**
  String get countryID;

  /// No description provided for @countryPH.
  ///
  /// In en, this message translates to:
  /// **'Philippines'**
  String get countryPH;

  /// No description provided for @countryIN.
  ///
  /// In en, this message translates to:
  /// **'India'**
  String get countryIN;

  /// No description provided for @countryEG.
  ///
  /// In en, this message translates to:
  /// **'Egypt'**
  String get countryEG;

  /// No description provided for @countryMA.
  ///
  /// In en, this message translates to:
  /// **'Morocco'**
  String get countryMA;

  /// No description provided for @countryTN.
  ///
  /// In en, this message translates to:
  /// **'Tunisia'**
  String get countryTN;

  /// No description provided for @countryZA.
  ///
  /// In en, this message translates to:
  /// **'South Africa'**
  String get countryZA;

  /// No description provided for @countryMU.
  ///
  /// In en, this message translates to:
  /// **'Mauritius'**
  String get countryMU;

  /// No description provided for @countrySC.
  ///
  /// In en, this message translates to:
  /// **'Seychelles'**
  String get countrySC;

  /// No description provided for @countryMV.
  ///
  /// In en, this message translates to:
  /// **'Maldives'**
  String get countryMV;

  /// No description provided for @countryCL.
  ///
  /// In en, this message translates to:
  /// **'Chile'**
  String get countryCL;

  /// No description provided for @countryAR.
  ///
  /// In en, this message translates to:
  /// **'Argentina'**
  String get countryAR;

  /// No description provided for @countryBR.
  ///
  /// In en, this message translates to:
  /// **'Brazil'**
  String get countryBR;

  /// No description provided for @countryPE.
  ///
  /// In en, this message translates to:
  /// **'Peru'**
  String get countryPE;

  /// No description provided for @countryEC.
  ///
  /// In en, this message translates to:
  /// **'Ecuador'**
  String get countryEC;

  /// No description provided for @countryCO.
  ///
  /// In en, this message translates to:
  /// **'Colombia'**
  String get countryCO;

  /// No description provided for @countryCR.
  ///
  /// In en, this message translates to:
  /// **'Costa Rica'**
  String get countryCR;

  /// No description provided for @countryFO.
  ///
  /// In en, this message translates to:
  /// **'Faroe Islands'**
  String get countryFO;

  /// No description provided for @countryGL.
  ///
  /// In en, this message translates to:
  /// **'Greenland'**
  String get countryGL;

  /// No description provided for @countrySJ.
  ///
  /// In en, this message translates to:
  /// **'Svalbard'**
  String get countrySJ;

  /// No description provided for @countryAQ.
  ///
  /// In en, this message translates to:
  /// **'Antarctica'**
  String get countryAQ;

  /// No description provided for @countryPF.
  ///
  /// In en, this message translates to:
  /// **'French Polynesia'**
  String get countryPF;

  /// No description provided for @countryFJ.
  ///
  /// In en, this message translates to:
  /// **'Fiji'**
  String get countryFJ;

  /// No description provided for @countryTO.
  ///
  /// In en, this message translates to:
  /// **'Tonga'**
  String get countryTO;

  /// No description provided for @countryWS.
  ///
  /// In en, this message translates to:
  /// **'Samoa'**
  String get countryWS;

  /// No description provided for @countryNC.
  ///
  /// In en, this message translates to:
  /// **'New Caledonia'**
  String get countryNC;

  /// No description provided for @countryVU.
  ///
  /// In en, this message translates to:
  /// **'Vanuatu'**
  String get countryVU;

  /// No description provided for @countryPG.
  ///
  /// In en, this message translates to:
  /// **'Papua New Guinea'**
  String get countryPG;

  /// No description provided for @countrySB.
  ///
  /// In en, this message translates to:
  /// **'Solomon Islands'**
  String get countrySB;

  /// No description provided for @countryGI.
  ///
  /// In en, this message translates to:
  /// **'Gibraltar'**
  String get countryGI;

  /// No description provided for @countryMC.
  ///
  /// In en, this message translates to:
  /// **'Monaco'**
  String get countryMC;

  /// No description provided for @countryAD.
  ///
  /// In en, this message translates to:
  /// **'Andorra'**
  String get countryAD;

  /// No description provided for @countrySI.
  ///
  /// In en, this message translates to:
  /// **'Slovenia'**
  String get countrySI;

  /// No description provided for @countryAL.
  ///
  /// In en, this message translates to:
  /// **'Albania'**
  String get countryAL;

  /// No description provided for @countryBA.
  ///
  /// In en, this message translates to:
  /// **'Bosnia and Herzegovina'**
  String get countryBA;

  /// No description provided for @countryRS.
  ///
  /// In en, this message translates to:
  /// **'Serbia'**
  String get countryRS;

  /// No description provided for @countryRO.
  ///
  /// In en, this message translates to:
  /// **'Romania'**
  String get countryRO;

  /// No description provided for @countryBG.
  ///
  /// In en, this message translates to:
  /// **'Bulgaria'**
  String get countryBG;

  /// No description provided for @countryUA.
  ///
  /// In en, this message translates to:
  /// **'Ukraine'**
  String get countryUA;

  /// No description provided for @countryRU.
  ///
  /// In en, this message translates to:
  /// **'Russia'**
  String get countryRU;

  /// No description provided for @countryEE.
  ///
  /// In en, this message translates to:
  /// **'Estonia'**
  String get countryEE;

  /// No description provided for @countryLV.
  ///
  /// In en, this message translates to:
  /// **'Latvia'**
  String get countryLV;

  /// No description provided for @countryLT.
  ///
  /// In en, this message translates to:
  /// **'Lithuania'**
  String get countryLT;

  /// No description provided for @countryPL.
  ///
  /// In en, this message translates to:
  /// **'Poland'**
  String get countryPL;

  /// No description provided for @countryCZ.
  ///
  /// In en, this message translates to:
  /// **'Czech Republic'**
  String get countryCZ;

  /// No description provided for @countryAT.
  ///
  /// In en, this message translates to:
  /// **'Austria'**
  String get countryAT;

  /// No description provided for @countryCH.
  ///
  /// In en, this message translates to:
  /// **'Switzerland'**
  String get countryCH;

  /// No description provided for @countryIE.
  ///
  /// In en, this message translates to:
  /// **'Ireland'**
  String get countryIE;

  /// No description provided for @countryIL.
  ///
  /// In en, this message translates to:
  /// **'Israel'**
  String get countryIL;

  /// No description provided for @countryJO.
  ///
  /// In en, this message translates to:
  /// **'Jordan'**
  String get countryJO;

  /// No description provided for @countryOM.
  ///
  /// In en, this message translates to:
  /// **'Oman'**
  String get countryOM;

  /// No description provided for @countryQA.
  ///
  /// In en, this message translates to:
  /// **'Qatar'**
  String get countryQA;

  /// No description provided for @countryBH.
  ///
  /// In en, this message translates to:
  /// **'Bahrain'**
  String get countryBH;

  /// No description provided for @countryKW.
  ///
  /// In en, this message translates to:
  /// **'Kuwait'**
  String get countryKW;

  /// No description provided for @countrySA.
  ///
  /// In en, this message translates to:
  /// **'Saudi Arabia'**
  String get countrySA;

  /// No description provided for @notAuthenticated.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to share trips'**
  String get notAuthenticated;

  /// No description provided for @failedToShare.
  ///
  /// In en, this message translates to:
  /// **'Failed to share: {error}'**
  String failedToShare(String error);

  /// No description provided for @tripShared.
  ///
  /// In en, this message translates to:
  /// **'Trip shared successfully!'**
  String get tripShared;

  /// No description provided for @friends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get friends;

  /// No description provided for @friendsTrips.
  ///
  /// In en, this message translates to:
  /// **'Friends\' Trips'**
  String get friendsTrips;

  /// No description provided for @noSharedTrips.
  ///
  /// In en, this message translates to:
  /// **'No shared trips yet'**
  String get noSharedTrips;

  /// No description provided for @noSharedTripsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When friends share their trips with you, they\'ll appear here'**
  String get noSharedTripsSubtitle;

  /// No description provided for @sharedBy.
  ///
  /// In en, this message translates to:
  /// **'Shared by {name}'**
  String sharedBy(String name);

  /// No description provided for @importedOn.
  ///
  /// In en, this message translates to:
  /// **'Imported {date}'**
  String importedOn(String date);

  /// No description provided for @removeSharedTrip.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeSharedTrip;

  /// No description provided for @removeSharedTripConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Remove this shared trip from your list?'**
  String get removeSharedTripConfirmation;

  /// No description provided for @duplicateToMyTrips.
  ///
  /// In en, this message translates to:
  /// **'Duplicate to My Trips'**
  String get duplicateToMyTrips;

  /// No description provided for @tripDuplicated.
  ///
  /// In en, this message translates to:
  /// **'Trip duplicated to your trips!'**
  String get tripDuplicated;

  /// No description provided for @readOnly.
  ///
  /// In en, this message translates to:
  /// **'Read-only'**
  String get readOnly;

  /// No description provided for @sharedTrip.
  ///
  /// In en, this message translates to:
  /// **'Shared Trip'**
  String get sharedTrip;

  /// No description provided for @importTrip.
  ///
  /// In en, this message translates to:
  /// **'Import Trip'**
  String get importTrip;

  /// No description provided for @importTripQuestion.
  ///
  /// In en, this message translates to:
  /// **'Would you like to import this trip from {owner}?'**
  String importTripQuestion(String owner);

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// No description provided for @tripImported.
  ///
  /// In en, this message translates to:
  /// **'Trip imported successfully!'**
  String get tripImported;

  /// No description provided for @invalidShareLink.
  ///
  /// In en, this message translates to:
  /// **'Invalid share link'**
  String get invalidShareLink;

  /// No description provided for @failedToImport.
  ///
  /// In en, this message translates to:
  /// **'Failed to import trip: {error}'**
  String failedToImport(String error);

  /// No description provided for @departureIn.
  ///
  /// In en, this message translates to:
  /// **'Departure in'**
  String get departureIn;

  /// No description provided for @activeVoyage.
  ///
  /// In en, this message translates to:
  /// **'Active Voyage'**
  String get activeVoyage;

  /// No description provided for @atSea.
  ///
  /// In en, this message translates to:
  /// **'At Sea'**
  String get atSea;

  /// No description provided for @currentlyAt.
  ///
  /// In en, this message translates to:
  /// **'Currently at'**
  String get currentlyAt;

  /// No description provided for @nextStop.
  ///
  /// In en, this message translates to:
  /// **'Next Stop'**
  String get nextStop;

  /// No description provided for @voyageComplete.
  ///
  /// In en, this message translates to:
  /// **'Voyage Complete'**
  String get voyageComplete;

  /// No description provided for @portsVisitedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} ports visited'**
  String portsVisitedCount(int count);

  /// No description provided for @daysAtSeaCount.
  ///
  /// In en, this message translates to:
  /// **'{count} days at sea'**
  String daysAtSeaCount(int count);

  /// No description provided for @seaDays.
  ///
  /// In en, this message translates to:
  /// **'sea'**
  String get seaDays;

  /// No description provided for @journeyProgress.
  ///
  /// In en, this message translates to:
  /// **'Journey Progress'**
  String get journeyProgress;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @deletePort.
  ///
  /// In en, this message translates to:
  /// **'Delete Port'**
  String get deletePort;

  /// No description provided for @deletePortConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this port?'**
  String get deletePortConfirmation;

  /// Trip name field hint (optional)
  ///
  /// In en, this message translates to:
  /// **'e.g., Mediterranean Adventure'**
  String get tripNameOptionalHint;

  /// Ship name validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter a ship name'**
  String get shipNameRequired;

  /// Travel dates validation error
  ///
  /// In en, this message translates to:
  /// **'Please select travel dates'**
  String get selectTravelDates;

  /// Validation error for minimum ports
  ///
  /// In en, this message translates to:
  /// **'Please add at least 2 ports (departure and arrival)'**
  String get pleaseAddAtLeastTwoPorts;

  /// Validation error for first stop
  ///
  /// In en, this message translates to:
  /// **'First entry cannot be a sea day'**
  String get firstEntryCannotBeSeaDay;

  /// Validation error for last stop
  ///
  /// In en, this message translates to:
  /// **'Last entry cannot be a sea day'**
  String get lastEntryCannotBeSeaDay;

  /// Default trip name
  ///
  /// In en, this message translates to:
  /// **'Cruise Adventure'**
  String get cruiseAdventureDefault;

  /// Times label for single port
  ///
  /// In en, this message translates to:
  /// **'Times (optional for single port)'**
  String get timesOptionalForSinglePort;

  /// Arrival time optional label
  ///
  /// In en, this message translates to:
  /// **'Arrival (opt.)'**
  String get arrivalOptional;

  /// Arrival time required label
  ///
  /// In en, this message translates to:
  /// **'Arrival *'**
  String get arrivalRequired;

  /// Departure time optional label
  ///
  /// In en, this message translates to:
  /// **'Departure (opt.)'**
  String get departureOptional;

  /// Departure time required label
  ///
  /// In en, this message translates to:
  /// **'Departure *'**
  String get departureRequired;

  /// Times section required label
  ///
  /// In en, this message translates to:
  /// **'Arrival & Departure Times *'**
  String get arrivalAndDepartureTimes;

  /// Date validation error
  ///
  /// In en, this message translates to:
  /// **'Please select a date'**
  String get pleaseSelectADate;

  /// Arrival time validation error
  ///
  /// In en, this message translates to:
  /// **'Please select an arrival time'**
  String get pleaseSelectArrivalTime;

  /// Departure time validation error
  ///
  /// In en, this message translates to:
  /// **'Please select a departure time'**
  String get pleaseSelectDepartureTime;

  /// Multi-day stay toggle label
  ///
  /// In en, this message translates to:
  /// **'Multi-day stay'**
  String get multiDayStayLabel;

  /// Multi-day stay toggle subtitle
  ///
  /// In en, this message translates to:
  /// **'Port visit spanning multiple days'**
  String get portVisitSpanningMultipleDays;

  /// Arrival date label
  ///
  /// In en, this message translates to:
  /// **'Arrival Date'**
  String get arrivalDateLabel;

  /// Departure date label
  ///
  /// In en, this message translates to:
  /// **'Departure Date'**
  String get departureDateLabel;

  /// Arrival time label
  ///
  /// In en, this message translates to:
  /// **'Arrival Time'**
  String get arrivalTimeLabel;

  /// Departure time label
  ///
  /// In en, this message translates to:
  /// **'Departure Time'**
  String get departureTimeLabel;

  /// Arrival optional for first port
  ///
  /// In en, this message translates to:
  /// **'Arrival (optional)'**
  String get arrivalOptionalFirstPort;

  /// Departure optional for last port
  ///
  /// In en, this message translates to:
  /// **'Departure (optional)'**
  String get departureOptionalLastPort;

  /// Coordinates saved confirmation
  ///
  /// In en, this message translates to:
  /// **'Coordinates saved for map'**
  String get coordinatesSavedForMap;

  /// AI import screen title
  ///
  /// In en, this message translates to:
  /// **'AI Import'**
  String get aiImportTitle;

  /// AI import input hint
  ///
  /// In en, this message translates to:
  /// **'Paste your booking confirmation text'**
  String get pasteBookingConfirmation;

  /// AI import text field hint
  ///
  /// In en, this message translates to:
  /// **'Paste the text from your cruise booking confirmation email...'**
  String get bookingConfirmationHint;

  /// Analyzing state label
  ///
  /// In en, this message translates to:
  /// **'Analyzing...'**
  String get analyzing;

  /// Import trip button
  ///
  /// In en, this message translates to:
  /// **'Import Trip'**
  String get importTripButton;

  /// AI import error message
  ///
  /// In en, this message translates to:
  /// **'Failed to parse trip. Please check your text and try again.'**
  String get aiImportError;

  /// AI import success message
  ///
  /// In en, this message translates to:
  /// **'Trip imported successfully!'**
  String get aiImportSuccess;

  /// AI import settings sheet title
  ///
  /// In en, this message translates to:
  /// **'AI Import Settings'**
  String get aiImportSettings;

  /// AI import settings description
  ///
  /// In en, this message translates to:
  /// **'Choose a provider, save your own API key, and pick a model for itinerary import.'**
  String get configureAiImport;

  /// Google recommendation message in AI settings
  ///
  /// In en, this message translates to:
  /// **'Google is the recommended default because the free quota is especially generous for personal use.'**
  String get googleRecommendedDescription;

  /// Recommended badge label
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get googleRecommended;

  /// AI provider field label
  ///
  /// In en, this message translates to:
  /// **'AI Provider'**
  String get aiProvider;

  /// AI model selector label
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get aiModel;

  /// API key field label
  ///
  /// In en, this message translates to:
  /// **'API Key'**
  String get apiKey;

  /// API key field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your API key'**
  String get enterApiKey;

  /// Save API key button label
  ///
  /// In en, this message translates to:
  /// **'Save key'**
  String get saveKey;

  /// Clear API key button label
  ///
  /// In en, this message translates to:
  /// **'Clear key'**
  String get clearKey;

  /// Refresh models button label
  ///
  /// In en, this message translates to:
  /// **'Refresh models'**
  String get refreshModels;

  /// API key storage note
  ///
  /// In en, this message translates to:
  /// **'Saved locally on this device'**
  String get savedOnThisDevice;

  /// Hint shown before a key is saved
  ///
  /// In en, this message translates to:
  /// **'Models are fetched after you save a valid API key.'**
  String get modelsLoadAfterKey;

  /// Message shown while fetching models
  ///
  /// In en, this message translates to:
  /// **'Fetching models…'**
  String get fetchingModels;

  /// Message shown when no models are returned
  ///
  /// In en, this message translates to:
  /// **'No models are available for this key yet.'**
  String get noModelsAvailable;

  /// Error shown when AI import is not configured
  ///
  /// In en, this message translates to:
  /// **'Set up AI Import in Settings before using this feature.'**
  String get aiImportNotConfigured;

  /// Button label to open AI settings
  ///
  /// In en, this message translates to:
  /// **'Open AI settings'**
  String get openAiSettings;

  /// Summary shown when AI import is not configured
  ///
  /// In en, this message translates to:
  /// **'AI import is not configured yet.'**
  String get aiNotConfigured;

  /// Shows the active AI provider and model
  ///
  /// In en, this message translates to:
  /// **'Using {provider} · {model}'**
  String usingAiProviderModel(String provider, String model);

  /// Confirmation after saving an API key
  ///
  /// In en, this message translates to:
  /// **'API key saved'**
  String get aiKeySaved;

  /// Confirmation after clearing an API key
  ///
  /// In en, this message translates to:
  /// **'API key removed'**
  String get aiKeyRemoved;

  /// Confirmation after refreshing models
  ///
  /// In en, this message translates to:
  /// **'Models updated'**
  String get aiModelsUpdated;

  /// Error message when shared trips fail to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load shared trips'**
  String get failedToLoadSharedTrips;

  /// Error message when trip duplication fails
  ///
  /// In en, this message translates to:
  /// **'Failed to duplicate: {error}'**
  String failedToDuplicate(String error);

  /// Error message when shared trip removal fails
  ///
  /// In en, this message translates to:
  /// **'Failed to remove: {error}'**
  String failedToRemove(String error);

  /// Port count and day count summary
  ///
  /// In en, this message translates to:
  /// **'{portCount} ports • {dayCount} days'**
  String portsAndDays(int portCount, int dayCount);

  /// Shows when a trip was shared
  ///
  /// In en, this message translates to:
  /// **'Shared {date}'**
  String sharedOnDate(String date);

  /// Importing state label
  ///
  /// In en, this message translates to:
  /// **'Importing...'**
  String get importing;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
