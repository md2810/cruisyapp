import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Cruisy';

  @override
  String get today => 'Today';

  @override
  String get futureCruises => 'Future Cruises';

  @override
  String get pastCruises => 'Past Cruises';

  @override
  String get noPastCruises => 'No past cruises';

  @override
  String get noUpcomingCruises => 'No upcoming cruises';

  @override
  String get noCruiseToday => 'No cruise today';

  @override
  String get completedCruisesAppearHere => 'Your completed cruises will appear here';

  @override
  String get tapPlusToAddCruise => 'Tap the + button above to add your first cruise';

  @override
  String get noOngoingCruises => 'You don\'t have any ongoing cruises';

  @override
  String get day => 'DAY';

  @override
  String get days => 'DAYS';

  @override
  String get done => 'DONE';

  @override
  String todayPort(String portName) {
    return 'Today: $portName';
  }

  @override
  String nextPort(String portName) {
    return 'Next: $portName';
  }

  @override
  String get addCruise => 'Add Cruise';

  @override
  String get editCruise => 'Edit Cruise';

  @override
  String get shipName => 'Ship Name';

  @override
  String get shipNameHint => 'e.g. Symphony of the Seas';

  @override
  String get tripName => 'Trip Name';

  @override
  String get tripNameHint => 'e.g. Caribbean Adventure';

  @override
  String get startDate => 'Start Date';

  @override
  String get endDate => 'End Date';

  @override
  String get selectDate => 'Select date';

  @override
  String get itinerary => 'Itinerary';

  @override
  String dayNumber(int number) {
    return 'Day $number';
  }

  @override
  String get seaDay => 'Sea Day';

  @override
  String get addStop => 'Add stop';

  @override
  String get continuedFromPreviousDay => 'Continued from previous day';

  @override
  String get addPort => 'Add Port';

  @override
  String get editPort => 'Edit Port';

  @override
  String get searchPorts => 'Search ports...';

  @override
  String get isSeaDay => 'Sea Day';

  @override
  String get noPortThisDay => 'No port this day';

  @override
  String get multiDayStay => 'Multi-day stay';

  @override
  String get portVisitSpanningDays => 'Port visit spanning multiple days';

  @override
  String get arrival => 'Arrival';

  @override
  String get departure => 'Departure';

  @override
  String get date => 'Date';

  @override
  String get time => 'Time';

  @override
  String get setTime => 'Set time';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get pleaseEnterShipName => 'Please enter a ship name';

  @override
  String get pleaseSelectDates => 'Please select start and end dates';

  @override
  String get pleaseEnterOrSelectPort => 'Please enter or select a port';

  @override
  String get pleaseSelectDate => 'Please select a date';

  @override
  String get needAtLeastTwoPorts => 'You need at least two port stops';

  @override
  String get firstStopCannotBeSeaDay => 'First stop cannot be a sea day';

  @override
  String get lastStopCannotBeSeaDay => 'Last stop cannot be a sea day';

  @override
  String get deleteCruise => 'Delete Cruise';

  @override
  String get deleteCruiseConfirmation => 'Are you sure you want to delete this cruise? This action cannot be undone.';

  @override
  String get cruiseDeleted => 'Cruise deleted';

  @override
  String get settings => 'Settings';

  @override
  String get account => 'Account';

  @override
  String get signOut => 'Sign Out';

  @override
  String get signOutConfirmation => 'Are you sure you want to sign out?';

  @override
  String get login => 'Sign In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get createAccount => 'Create Account';

  @override
  String get welcomeBack => 'Welcome back, cruiser';

  @override
  String get createYourAccount => 'Create your account';

  @override
  String get name => 'Name';

  @override
  String get yourName => 'Your name';

  @override
  String get email => 'Email';

  @override
  String get emailHint => 'your@email.com';

  @override
  String get password => 'Password';

  @override
  String get yourPassword => 'Your password';

  @override
  String get pleaseEnterName => 'Please enter your name';

  @override
  String get pleaseEnterEmail => 'Please enter your email';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email';

  @override
  String get pleaseEnterPassword => 'Please enter your password';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get or => 'OR';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get unexpectedError => 'An unexpected error occurred.';

  @override
  String get googleSignInFailed => 'Google sign-in failed. Please try again.';

  @override
  String hoursInPort(int hours) {
    return '${hours}h in port';
  }

  @override
  String get now => 'NOW';

  @override
  String get overview => 'Overview';

  @override
  String totalDays(int count) {
    return '$count days';
  }

  @override
  String get ports => 'Ports';

  @override
  String portCount(int count) {
    return '$count ports';
  }

  @override
  String get progress => 'Progress';

  @override
  String progressPercent(int percent) {
    return '$percent%';
  }

  @override
  String get cruiseNotStarted => 'Not started';

  @override
  String get cruiseCompleted => 'Completed';

  @override
  String get map => 'Map';

  @override
  String get viewFullMap => 'View full map';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get german => 'German';

  @override
  String get appInfo => 'App Info';

  @override
  String get version => 'Version';

  @override
  String get myCruises => 'My Cruises';

  @override
  String get allCruises => 'All Cruises';

  @override
  String get voyages => 'Voyages';

  @override
  String get accountSettings => 'Account Settings';

  @override
  String get manageProfilePreferences => 'Manage your profile and preferences';

  @override
  String get notifications => 'Notifications';

  @override
  String get manageNotifications => 'Manage notification preferences';

  @override
  String get support => 'Support';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get getHelp => 'Get help with using Cruisy';

  @override
  String get about => 'About';

  @override
  String get appVersionLegal => 'App version and legal info';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get changeDisplayName => 'Change your display name';

  @override
  String get changePassword => 'Change Password';

  @override
  String get updatePassword => 'Update your password';

  @override
  String get deleteAccountTitle => 'Delete Account';

  @override
  String get permanentlyDeleteAccount => 'Permanently delete your account';

  @override
  String get tripReminders => 'Trip Reminders';

  @override
  String get getNotifiedBeforeCruise => 'Get notified before your cruise';

  @override
  String get portAlerts => 'Port Alerts';

  @override
  String get notificationsAtPorts => 'Notifications when arriving at ports';

  @override
  String get countdownUpdates => 'Countdown Updates';

  @override
  String get dailyCountdown => 'Daily countdown notifications';

  @override
  String get appDescription => 'Your personal cruise companion app. Track your voyages, plan excursions, and never miss a moment of your cruise adventure.';

  @override
  String get newVoyage => 'New Voyage';

  @override
  String get editVoyage => 'Edit Voyage';

  @override
  String get addCruiseTracking => 'Add your upcoming cruise to start tracking';

  @override
  String get updateCruiseDetails => 'Update your cruise details';

  @override
  String get tripNameOptional => 'Trip Name (Optional)';

  @override
  String get travelDates => 'Travel Dates';

  @override
  String get selectDepartureDates => 'Select departure and return dates';

  @override
  String get add => 'Add';

  @override
  String get selectTravelDatesFirst => 'Select travel dates first';

  @override
  String get addPortsSeaDays => 'Then add your ports and sea days';

  @override
  String get noActivityPlanned => 'No activity planned';

  @override
  String continued(String name) {
    return '$name (continued)';
  }

  @override
  String arrivesTime(String time) {
    return 'Arrives $time';
  }

  @override
  String get addStopTitle => 'Add Stop';

  @override
  String get editStopTitle => 'Edit Stop';

  @override
  String get dayAtSeaNoPort => 'Day at sea with no port';

  @override
  String get portNameLabel => 'Port Name';

  @override
  String get searchPort => 'Search for a port...';

  @override
  String get coordinatesSaved => 'Coordinates saved for map';

  @override
  String get arrivalDate => 'Arrival Date';

  @override
  String get departureDate => 'Departure Date';

  @override
  String get timesOptional => 'Times (Optional)';

  @override
  String get updateStop => 'Update Stop';

  @override
  String get pleaseSelectTripDatesFirst => 'Please select trip dates first';

  @override
  String get tripNotFound => 'Trip not found';

  @override
  String get voyageMayBeDeleted => 'This voyage may have been deleted';

  @override
  String get goBack => 'Go Back';

  @override
  String get editTripMenu => 'Edit Trip';

  @override
  String get shareMenu => 'Share';

  @override
  String get shareComingSoon => 'Share feature coming soon!';

  @override
  String get deleteTripMenu => 'Delete Trip';

  @override
  String deleteTripConfirmation(String name) {
    return 'Are you sure you want to delete \"$name\"?\n\nThis action cannot be undone.';
  }

  @override
  String tripDeleted(String name) {
    return '$name deleted';
  }

  @override
  String failedToDelete(String error) {
    return 'Failed to delete: $error';
  }

  @override
  String get voyageInProgress => 'VOYAGE IN PROGRESS';

  @override
  String get daysUntil => 'DAYS UNTIL';

  @override
  String dayLabel(int number) {
    return 'Day $number';
  }

  @override
  String get daysLabel => 'days';

  @override
  String get departs => 'DEPARTS';

  @override
  String get nextLabel => 'NEXT';

  @override
  String get inProgressStatus => 'In Progress';

  @override
  String get upcomingStatus => 'Upcoming';

  @override
  String get noItineraryYet => 'No itinerary added yet';

  @override
  String get editTripToAddStops => 'Edit this trip to add port stops';

  @override
  String get addStops => 'Add Stops';

  @override
  String daysCount(int count) {
    return '$count days';
  }

  @override
  String get todayLabel => 'TODAY';

  @override
  String tripUpdated(String name) {
    return '$name updated!';
  }

  @override
  String tripAdded(String name) {
    return '$name trip added!';
  }

  @override
  String failedToSaveTrip(String error) {
    return 'Failed to save trip: $error';
  }

  @override
  String get addTrip => 'Add Trip';

  @override
  String get editTrip => 'Edit Trip';

  @override
  String get savingTrip => 'Saving...';

  @override
  String get updateTripButton => 'Update Trip';

  @override
  String get saveTripButton => 'Save Trip';

  @override
  String get goodMorning => 'Good Morning';

  @override
  String get goodAfternoon => 'Good Afternoon';

  @override
  String get goodEvening => 'Good Evening';

  @override
  String get failedToLoadTrips => 'Failed to load trips';

  @override
  String get noUpcomingTrips => 'No upcoming trips';

  @override
  String get startPlanningCruise => 'Start planning your next cruise adventure';

  @override
  String get addFirstTrip => 'Add Your First Trip';

  @override
  String get nextTrip => 'NEXT TRIP';

  @override
  String get daysLowercase => 'days';

  @override
  String hoursRemaining(int hours) {
    return '${hours}h remaining';
  }

  @override
  String get packingList => 'Packing List';

  @override
  String get documents => 'Documents';

  @override
  String get excursions => 'Excursions';

  @override
  String get dining => 'Dining';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get myVoyages => 'My Voyages';

  @override
  String get checkConnection => 'Please check your connection';

  @override
  String get noVoyagesYet => 'No voyages yet';

  @override
  String get startTrackingCruises => 'Start tracking your cruise adventures\nby adding your first trip';

  @override
  String get pastTrips => 'Past Trips';

  @override
  String get deleteTrip => 'Delete Trip';

  @override
  String get viewDetails => 'View Details';

  @override
  String get mapFailedToLoad => 'Map failed to load';

  @override
  String get checkMapboxConfig => 'Check your Mapbox configuration';

  @override
  String get retry => 'Retry';

  @override
  String get explore => 'Explore';

  @override
  String get yourCruiseDestinations => 'Your cruise destinations';

  @override
  String get home => 'Home';

  @override
  String get trips => 'Trips';

  @override
  String get allTimeCruisePassport => 'ALL-TIME CRUISE PASSPORT';

  @override
  String yearCruisePassport(int year) {
    return '$year CRUISE PASSPORT';
  }

  @override
  String get passport => 'PASSPORT';

  @override
  String get distance => 'DISTANCE';

  @override
  String get ships => 'SHIPS';

  @override
  String get allCruiseStats => 'All Cruise Stats';

  @override
  String get longestCruise => 'Longest Cruise';

  @override
  String daysOnShip(String shipName) {
    return 'days on $shipName';
  }

  @override
  String get favoriteShip => 'Favorite Ship';

  @override
  String cruiseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cruises',
      one: '1 cruise',
    );
    return '$_temp0';
  }

  @override
  String get viewAllShips => 'View all ships';

  @override
  String get allShips => 'All Ships';

  @override
  String aroundWorld(String times) {
    return '${times}x around the world';
  }

  @override
  String get halfAroundWorld => 'Half way around the world';

  @override
  String get editToAddPorts => 'Edit this trip to add port stops';

  @override
  String get addStopsButton => 'Add Stops';

  @override
  String get todayBadge => 'TODAY';

  @override
  String get continuedPort => '(continued)';

  @override
  String arrivesAt(String time) {
    return 'Arrives $time';
  }

  @override
  String get countryUS => 'United States';

  @override
  String get countryDE => 'Germany';

  @override
  String get countryES => 'Spain';

  @override
  String get countryFR => 'France';

  @override
  String get countryIT => 'Italy';

  @override
  String get countryGR => 'Greece';

  @override
  String get countryHR => 'Croatia';

  @override
  String get countryME => 'Montenegro';

  @override
  String get countryPT => 'Portugal';

  @override
  String get countryGB => 'United Kingdom';

  @override
  String get countryNL => 'Netherlands';

  @override
  String get countryBE => 'Belgium';

  @override
  String get countryNO => 'Norway';

  @override
  String get countrySE => 'Sweden';

  @override
  String get countryDK => 'Denmark';

  @override
  String get countryFI => 'Finland';

  @override
  String get countryIS => 'Iceland';

  @override
  String get countryMT => 'Malta';

  @override
  String get countryCY => 'Cyprus';

  @override
  String get countryTR => 'Turkey';

  @override
  String get countryAE => 'United Arab Emirates';

  @override
  String get countryBS => 'Bahamas';

  @override
  String get countryJM => 'Jamaica';

  @override
  String get countryMX => 'Mexico';

  @override
  String get countryBZ => 'Belize';

  @override
  String get countryHN => 'Honduras';

  @override
  String get countryPA => 'Panama';

  @override
  String get countryAW => 'Aruba';

  @override
  String get countryCW => 'Curacao';

  @override
  String get countrySX => 'Sint Maarten';

  @override
  String get countryVG => 'British Virgin Islands';

  @override
  String get countryVI => 'US Virgin Islands';

  @override
  String get countryPR => 'Puerto Rico';

  @override
  String get countryDO => 'Dominican Republic';

  @override
  String get countryHT => 'Haiti';

  @override
  String get countryAG => 'Antigua and Barbuda';

  @override
  String get countryBB => 'Barbados';

  @override
  String get countryLC => 'Saint Lucia';

  @override
  String get countryGD => 'Grenada';

  @override
  String get countryVC => 'Saint Vincent and the Grenadines';

  @override
  String get countryKY => 'Cayman Islands';

  @override
  String get countryTC => 'Turks and Caicos';

  @override
  String get countryTT => 'Trinidad and Tobago';

  @override
  String get countryCA => 'Canada';

  @override
  String get countryAU => 'Australia';

  @override
  String get countryNZ => 'New Zealand';

  @override
  String get countryJP => 'Japan';

  @override
  String get countryCN => 'China';

  @override
  String get countryTH => 'Thailand';

  @override
  String get countryVN => 'Vietnam';

  @override
  String get countrySG => 'Singapore';

  @override
  String get countryMY => 'Malaysia';

  @override
  String get countryID => 'Indonesia';

  @override
  String get countryPH => 'Philippines';

  @override
  String get countryIN => 'India';

  @override
  String get countryEG => 'Egypt';

  @override
  String get countryMA => 'Morocco';

  @override
  String get countryTN => 'Tunisia';

  @override
  String get countryZA => 'South Africa';

  @override
  String get countryMU => 'Mauritius';

  @override
  String get countrySC => 'Seychelles';

  @override
  String get countryMV => 'Maldives';

  @override
  String get countryCL => 'Chile';

  @override
  String get countryAR => 'Argentina';

  @override
  String get countryBR => 'Brazil';

  @override
  String get countryPE => 'Peru';

  @override
  String get countryEC => 'Ecuador';

  @override
  String get countryCO => 'Colombia';

  @override
  String get countryCR => 'Costa Rica';

  @override
  String get countryFO => 'Faroe Islands';

  @override
  String get countryGL => 'Greenland';

  @override
  String get countrySJ => 'Svalbard';

  @override
  String get countryAQ => 'Antarctica';

  @override
  String get countryPF => 'French Polynesia';

  @override
  String get countryFJ => 'Fiji';

  @override
  String get countryTO => 'Tonga';

  @override
  String get countryWS => 'Samoa';

  @override
  String get countryNC => 'New Caledonia';

  @override
  String get countryVU => 'Vanuatu';

  @override
  String get countryPG => 'Papua New Guinea';

  @override
  String get countrySB => 'Solomon Islands';

  @override
  String get countryGI => 'Gibraltar';

  @override
  String get countryMC => 'Monaco';

  @override
  String get countryAD => 'Andorra';

  @override
  String get countrySI => 'Slovenia';

  @override
  String get countryAL => 'Albania';

  @override
  String get countryBA => 'Bosnia and Herzegovina';

  @override
  String get countryRS => 'Serbia';

  @override
  String get countryRO => 'Romania';

  @override
  String get countryBG => 'Bulgaria';

  @override
  String get countryUA => 'Ukraine';

  @override
  String get countryRU => 'Russia';

  @override
  String get countryEE => 'Estonia';

  @override
  String get countryLV => 'Latvia';

  @override
  String get countryLT => 'Lithuania';

  @override
  String get countryPL => 'Poland';

  @override
  String get countryCZ => 'Czech Republic';

  @override
  String get countryAT => 'Austria';

  @override
  String get countryCH => 'Switzerland';

  @override
  String get countryIE => 'Ireland';

  @override
  String get countryIL => 'Israel';

  @override
  String get countryJO => 'Jordan';

  @override
  String get countryOM => 'Oman';

  @override
  String get countryQA => 'Qatar';

  @override
  String get countryBH => 'Bahrain';

  @override
  String get countryKW => 'Kuwait';

  @override
  String get countrySA => 'Saudi Arabia';

  @override
  String get notAuthenticated => 'Please sign in to share trips';

  @override
  String failedToShare(String error) {
    return 'Failed to share: $error';
  }

  @override
  String get tripShared => 'Trip shared successfully!';

  @override
  String get friends => 'Friends';

  @override
  String get friendsTrips => 'Friends\' Trips';

  @override
  String get noSharedTrips => 'No shared trips yet';

  @override
  String get noSharedTripsSubtitle => 'When friends share their trips with you, they\'ll appear here';

  @override
  String sharedBy(String name) {
    return 'Shared by $name';
  }

  @override
  String importedOn(String date) {
    return 'Imported $date';
  }

  @override
  String get removeSharedTrip => 'Remove';

  @override
  String get removeSharedTripConfirmation => 'Remove this shared trip from your list?';

  @override
  String get duplicateToMyTrips => 'Duplicate to My Trips';

  @override
  String get tripDuplicated => 'Trip duplicated to your trips!';

  @override
  String get readOnly => 'Read-only';

  @override
  String get sharedTrip => 'Shared Trip';

  @override
  String get importTrip => 'Import Trip';

  @override
  String importTripQuestion(String owner) {
    return 'Would you like to import this trip from $owner?';
  }

  @override
  String get import => 'Import';

  @override
  String get tripImported => 'Trip imported successfully!';

  @override
  String get invalidShareLink => 'Invalid share link';

  @override
  String failedToImport(String error) {
    return 'Failed to import trip: $error';
  }

  @override
  String get liveTracking => 'Live Tracking';

  @override
  String get livePosition => 'Live';

  @override
  String recentPosition(String time) {
    return '$time ago';
  }

  @override
  String get estimatedPosition => 'Estimated';

  @override
  String get departureIn => 'Departure in';

  @override
  String get liveVoyage => 'Live Voyage';

  @override
  String get atSea => 'At Sea';

  @override
  String get currentlyAt => 'Currently at';

  @override
  String get nextStop => 'Next Stop';

  @override
  String get voyageComplete => 'Voyage Complete';

  @override
  String portsVisitedCount(int count) {
    return '$count ports visited';
  }

  @override
  String daysAtSeaCount(int count) {
    return '$count days at sea';
  }

  @override
  String get seaDays => 'sea';

  @override
  String get journeyProgress => 'Journey Progress';
}
