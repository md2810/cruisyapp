// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Cruisy';

  @override
  String get today => 'Heute';

  @override
  String get futureCruises => 'Zukünftige Reisen';

  @override
  String get pastCruises => 'Vergangene Reisen';

  @override
  String get noPastCruises => 'Keine vergangenen Kreuzfahrten';

  @override
  String get noUpcomingCruises => 'Keine geplanten Kreuzfahrten';

  @override
  String get noCruiseToday => 'Heute keine Kreuzfahrt';

  @override
  String get completedCruisesAppearHere =>
      'Abgeschlossene Reisen erscheinen hier';

  @override
  String get tapPlusToAddCruise =>
      'Tippe auf + um deine erste Kreuzfahrt hinzuzufügen';

  @override
  String get noOngoingCruises => 'Du hast keine laufende Kreuzfahrt';

  @override
  String get day => 'TAG';

  @override
  String get days => 'TAGE';

  @override
  String get done => 'FERTIG';

  @override
  String todayPort(String portName) {
    return 'Heute: $portName';
  }

  @override
  String nextPort(String portName) {
    return 'Nächster Halt: $portName';
  }

  @override
  String get addCruise => 'Kreuzfahrt hinzufügen';

  @override
  String get editCruise => 'Kreuzfahrt bearbeiten';

  @override
  String get shipName => 'Schiffsname';

  @override
  String get shipNameHint => 'z.B. AIDAprima';

  @override
  String get tripName => 'Reisename';

  @override
  String get tripNameHint => 'z.B. Karibik';

  @override
  String get startDate => 'Startdatum';

  @override
  String get endDate => 'Enddatum';

  @override
  String get selectDate => 'Datum wählen';

  @override
  String get itinerary => 'Reiseverlauf';

  @override
  String dayNumber(int number) {
    return 'Tag $number';
  }

  @override
  String get seaDay => 'Seetag';

  @override
  String get addStop => 'Hafen hinzufügen';

  @override
  String get continuedFromPreviousDay => 'Fortsetzung vom Vortag';

  @override
  String get addPort => 'Hafen hinzufügen';

  @override
  String get editPort => 'Hafen bearbeiten';

  @override
  String get searchPorts => 'Häfen suchen...';

  @override
  String get isSeaDay => 'Seetag';

  @override
  String get noPortThisDay => 'Kein Hafen an diesem Tag';

  @override
  String get multiDayStay => 'Mehrtägiger Aufenthalt';

  @override
  String get portVisitSpanningDays => 'Hafenbesuch über mehrere Tage';

  @override
  String get arrival => 'Ankunft';

  @override
  String get departure => 'Abfahrt';

  @override
  String get date => 'Datum';

  @override
  String get time => 'Uhrzeit';

  @override
  String get setTime => 'Zeit festlegen';

  @override
  String get save => 'Speichern';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get delete => 'Löschen';

  @override
  String get pleaseEnterShipName => 'Bitte gib einen Schiffsnamen ein';

  @override
  String get pleaseSelectDates => 'Bitte wähle Start- und Enddatum';

  @override
  String get pleaseEnterOrSelectPort =>
      'Bitte gib einen Hafen ein oder wähle einen aus';

  @override
  String get pleaseSelectDate => 'Bitte wähle ein Datum';

  @override
  String get needAtLeastTwoPorts => 'Du musst mindestens zwei Häfen hinzufügen';

  @override
  String get firstStopCannotBeSeaDay => 'Der erste Stopp kann kein Seetag sein';

  @override
  String get lastStopCannotBeSeaDay => 'Der letzte Stopp kann kein Seetag sein';

  @override
  String get deleteCruise => 'Kreuzfahrt löschen';

  @override
  String get deleteCruiseConfirmation =>
      'Bist du sicher, dass du diese Kreuzfahrt löschen möchtest? Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get cruiseDeleted => 'Kreuzfahrt gelöscht';

  @override
  String get settings => 'Einstellungen';

  @override
  String get account => 'Konto';

  @override
  String get signOut => 'Abmelden';

  @override
  String get signOutConfirmation =>
      'Bist du sicher, dass du dich abmelden möchtest?';

  @override
  String get login => 'Anmelden';

  @override
  String get signUp => 'Registrieren';

  @override
  String get createAccount => 'Konto erstellen';

  @override
  String get welcomeBack => 'Willkommen zurück, Kreuzfahrer';

  @override
  String get createYourAccount => 'Erstelle dein Konto';

  @override
  String get name => 'Name';

  @override
  String get yourName => 'Dein Name';

  @override
  String get email => 'E-Mail';

  @override
  String get emailHint => 'deine@email.de';

  @override
  String get password => 'Passwort';

  @override
  String get yourPassword => 'Dein Passwort';

  @override
  String get pleaseEnterName => 'Bitte gib deinen Namen ein';

  @override
  String get pleaseEnterEmail => 'Bitte gib deine E-Mail-Adresse ein';

  @override
  String get pleaseEnterValidEmail =>
      'Bitte gib eine gültige E-Mail-Adresse ein';

  @override
  String get pleaseEnterPassword => 'Bitte gib dein Passwort ein';

  @override
  String get passwordTooShort =>
      'Das Passwort muss mindestens 6 Zeichen lang sein';

  @override
  String get or => 'ODER';

  @override
  String get continueWithGoogle => 'Mit Google fortfahren';

  @override
  String get alreadyHaveAccount => 'Bereits ein Konto?';

  @override
  String get dontHaveAccount => 'Noch kein Konto?';

  @override
  String get unexpectedError => 'Ein unerwarteter Fehler ist aufgetreten.';

  @override
  String get googleSignInFailed =>
      'Google-Anmeldung fehlgeschlagen. Bitte versuche es erneut.';

  @override
  String hoursInPort(int hours) {
    return '${hours}h im Hafen';
  }

  @override
  String get now => 'JETZT';

  @override
  String get overview => 'Übersicht';

  @override
  String totalDays(int count) {
    return '$count Tage';
  }

  @override
  String get ports => 'Häfen';

  @override
  String portCount(int count) {
    return '$count Häfen';
  }

  @override
  String get progress => 'Fortschritt';

  @override
  String progressPercent(int percent) {
    return '$percent%';
  }

  @override
  String get cruiseNotStarted => 'Noch nicht gestartet';

  @override
  String get cruiseCompleted => 'Abgeschlossen';

  @override
  String get map => 'Karte';

  @override
  String get viewFullMap => 'Vollständige Karte anzeigen';

  @override
  String get language => 'Sprache';

  @override
  String get english => 'Englisch';

  @override
  String get german => 'Deutsch';

  @override
  String get appInfo => 'App-Info';

  @override
  String get version => 'Version';

  @override
  String get myCruises => 'Meine Kreuzfahrten';

  @override
  String get allCruises => 'Alle Kreuzfahrten';

  @override
  String get voyages => 'Reisen';

  @override
  String get accountSettings => 'Kontoeinstellungen';

  @override
  String get manageProfilePreferences => 'Profil und Einstellungen verwalten';

  @override
  String get notifications => 'Benachrichtigungen';

  @override
  String get manageNotifications => 'Benachrichtigungseinstellungen verwalten';

  @override
  String get support => 'Support';

  @override
  String get helpSupport => 'Hilfe & Support';

  @override
  String get getHelp => 'Hilfe zur Nutzung von Cruisy';

  @override
  String get about => 'Über';

  @override
  String get appVersionLegal => 'App-Version und rechtliche Infos';

  @override
  String get editProfile => 'Profil bearbeiten';

  @override
  String get changeDisplayName => 'Anzeigenamen ändern';

  @override
  String get changePassword => 'Passwort ändern';

  @override
  String get updatePassword => 'Passwort aktualisieren';

  @override
  String get deleteAccountTitle => 'Konto löschen';

  @override
  String get permanentlyDeleteAccount => 'Konto dauerhaft löschen';

  @override
  String get tripReminders => 'Reiseerinnerungen';

  @override
  String get getNotifiedBeforeCruise => 'Benachrichtigung vor der Kreuzfahrt';

  @override
  String get portAlerts => 'Hafenbenachrichtigungen';

  @override
  String get notificationsAtPorts => 'Benachrichtigungen bei Ankunft im Hafen';

  @override
  String get countdownUpdates => 'Countdown-Updates';

  @override
  String get dailyCountdown => 'Tägliche Countdown-Benachrichtigungen';

  @override
  String get appDescription =>
      'Deine persönliche Kreuzfahrt-Begleiter-App. Verfolge deine Reisen, plane Ausflüge und verpasse keinen Moment deines Kreuzfahrtabenteuers.';

  @override
  String get newVoyage => 'Neue Reise';

  @override
  String get editVoyage => 'Reise bearbeiten';

  @override
  String get addCruiseTracking =>
      'Füge deine Kreuzfahrt hinzu um sie zu verfolgen';

  @override
  String get updateCruiseDetails => 'Aktualisiere deine Kreuzfahrtdetails';

  @override
  String get tripNameOptional => 'Reisename (Optional)';

  @override
  String get travelDates => 'Reisedaten';

  @override
  String get selectDepartureDates => 'Wähle Abfahrts- und Rückkehrdatum';

  @override
  String get add => 'Hinzufügen';

  @override
  String get selectTravelDatesFirst => 'Wähle zuerst die Reisedaten';

  @override
  String get addPortsSeaDays => 'Dann füge Häfen und Seetage hinzu';

  @override
  String get noActivityPlanned => 'Keine Aktivität geplant';

  @override
  String continued(String name) {
    return '$name (Fortsetzung)';
  }

  @override
  String arrivesTime(String time) {
    return 'Ankunft $time';
  }

  @override
  String get addStopTitle => 'Halt hinzufügen';

  @override
  String get editStopTitle => 'Halt bearbeiten';

  @override
  String get dayAtSeaNoPort => 'Tag auf See ohne Hafen';

  @override
  String get portNameLabel => 'Hafenname';

  @override
  String get searchPort => 'Nach Hafen suchen...';

  @override
  String get coordinatesSaved => 'Koordinaten für Karte gespeichert';

  @override
  String get arrivalDate => 'Ankunftsdatum';

  @override
  String get departureDate => 'Abfahrtsdatum';

  @override
  String get timesOptional => 'Zeiten (Optional)';

  @override
  String get updateStop => 'Halt aktualisieren';

  @override
  String get pleaseSelectTripDatesFirst => 'Bitte wähle zuerst die Reisedaten';

  @override
  String get tripNotFound => 'Reise nicht gefunden';

  @override
  String get voyageMayBeDeleted => 'Diese Reise wurde möglicherweise gelöscht';

  @override
  String get goBack => 'Zurück';

  @override
  String get editTripMenu => 'Reise bearbeiten';

  @override
  String get shareMenu => 'Teilen';

  @override
  String get shareComingSoon => 'Teilen-Funktion kommt bald!';

  @override
  String get deleteTripMenu => 'Reise löschen';

  @override
  String deleteTripConfirmation(String name) {
    return 'Bist du sicher, dass du \"$name\" löschen möchtest?\n\nDiese Aktion kann nicht rückgängig gemacht werden.';
  }

  @override
  String tripDeleted(String name) {
    return '$name gelöscht';
  }

  @override
  String failedToDelete(String error) {
    return 'Löschen fehlgeschlagen: $error';
  }

  @override
  String get voyageInProgress => 'REISE LÄUFT';

  @override
  String get daysUntil => 'TAGE BIS';

  @override
  String dayLabel(int number) {
    return 'Tag $number';
  }

  @override
  String get daysLabel => 'Tage';

  @override
  String get departs => 'ABFAHRT';

  @override
  String get nextLabel => 'NÄCHSTER';

  @override
  String get inProgressStatus => 'Läuft';

  @override
  String get upcomingStatus => 'Bevorstehend';

  @override
  String get noItineraryYet => 'Noch kein Reiseverlauf hinzugefügt';

  @override
  String get editTripToAddStops =>
      'Bearbeite diese Reise um Hafenstopps hinzuzufügen';

  @override
  String get addStops => 'Stopps hinzufügen';

  @override
  String daysCount(int count) {
    return '$count Tage';
  }

  @override
  String get todayLabel => 'HEUTE';

  @override
  String tripUpdated(String name) {
    return '$name aktualisiert!';
  }

  @override
  String tripAdded(String name) {
    return '$name Reise hinzugefügt!';
  }

  @override
  String failedToSaveTrip(String error) {
    return 'Speichern fehlgeschlagen: $error';
  }

  @override
  String get addTrip => 'Reise hinzufügen';

  @override
  String get editTrip => 'Reise bearbeiten';

  @override
  String get savingTrip => 'Speichern...';

  @override
  String get updateTripButton => 'Reise aktualisieren';

  @override
  String get saveTripButton => 'Reise speichern';

  @override
  String get goodMorning => 'Guten Morgen';

  @override
  String get goodAfternoon => 'Guten Tag';

  @override
  String get goodEvening => 'Guten Abend';

  @override
  String get failedToLoadTrips => 'Reisen konnten nicht geladen werden';

  @override
  String get noUpcomingTrips => 'Keine bevorstehenden Reisen';

  @override
  String get startPlanningCruise =>
      'Plane jetzt dein nächstes Kreuzfahrtabenteuer';

  @override
  String get addFirstTrip => 'Erste Reise hinzufügen';

  @override
  String get nextTrip => 'NÄCHSTE REISE';

  @override
  String get daysLowercase => 'Tage';

  @override
  String hoursRemaining(int hours) {
    return '${hours}h verbleibend';
  }

  @override
  String get packingList => 'Packliste';

  @override
  String get documents => 'Dokumente';

  @override
  String get excursions => 'Ausflüge';

  @override
  String get dining => 'Restaurant';

  @override
  String get upcoming => 'Bevorstehend';

  @override
  String get myVoyages => 'Meine Reisen';

  @override
  String get checkConnection => 'Bitte überprüfe deine Verbindung';

  @override
  String get noVoyagesYet => 'Noch keine Reisen';

  @override
  String get startTrackingCruises =>
      'Beginne deine Kreuzfahrtabenteuer zu verfolgen\nindem du deine erste Reise hinzufügst';

  @override
  String get pastTrips => 'Vergangene Reisen';

  @override
  String get deleteTrip => 'Reise löschen';

  @override
  String get viewDetails => 'Details anzeigen';

  @override
  String get mapFailedToLoad => 'Karte konnte nicht geladen werden';

  @override
  String get checkMapboxConfig => 'Überprüfe deine Mapbox-Konfiguration';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get explore => 'Entdecken';

  @override
  String get yourCruiseDestinations => 'Deine Kreuzfahrtziele';

  @override
  String get home => 'Start';

  @override
  String get trips => 'Reisen';

  @override
  String get allTimeCruisePassport => 'KREUZFAHRT-PASS GESAMT';

  @override
  String yearCruisePassport(int year) {
    return '$year KREUZFAHRT-PASS';
  }

  @override
  String get passport => 'PASS';

  @override
  String get distance => 'DISTANZ';

  @override
  String get ships => 'SCHIFFE';

  @override
  String get allCruiseStats => 'Alle Kreuzfahrt-Statistiken';

  @override
  String get longestCruise => 'Längste Kreuzfahrt';

  @override
  String daysOnShip(String shipName) {
    return 'Tage auf $shipName';
  }

  @override
  String get favoriteShip => 'Lieblingsschiff';

  @override
  String cruiseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Kreuzfahrten',
      one: '1 Kreuzfahrt',
    );
    return '$_temp0';
  }

  @override
  String get viewAllShips => 'Alle Schiffe anzeigen';

  @override
  String get allShips => 'Alle Schiffe';

  @override
  String aroundWorld(String times) {
    return '${times}x um die Welt';
  }

  @override
  String get halfAroundWorld => 'Halbe Weltumrundung';

  @override
  String get editToAddPorts => 'Bearbeite diese Reise um Häfen hinzuzufügen';

  @override
  String get addStopsButton => 'Stopps hinzufügen';

  @override
  String get todayBadge => 'HEUTE';

  @override
  String get continuedPort => '(Fortsetzung)';

  @override
  String arrivesAt(String time) {
    return 'Ankunft $time';
  }

  @override
  String get countryUS => 'Vereinigte Staaten';

  @override
  String get countryDE => 'Deutschland';

  @override
  String get countryES => 'Spanien';

  @override
  String get countryFR => 'Frankreich';

  @override
  String get countryIT => 'Italien';

  @override
  String get countryGR => 'Griechenland';

  @override
  String get countryHR => 'Kroatien';

  @override
  String get countryME => 'Montenegro';

  @override
  String get countryPT => 'Portugal';

  @override
  String get countryGB => 'Vereinigtes Königreich';

  @override
  String get countryNL => 'Niederlande';

  @override
  String get countryBE => 'Belgien';

  @override
  String get countryNO => 'Norwegen';

  @override
  String get countrySE => 'Schweden';

  @override
  String get countryDK => 'Dänemark';

  @override
  String get countryFI => 'Finnland';

  @override
  String get countryIS => 'Island';

  @override
  String get countryMT => 'Malta';

  @override
  String get countryCY => 'Zypern';

  @override
  String get countryTR => 'Türkei';

  @override
  String get countryAE => 'Vereinigte Arabische Emirate';

  @override
  String get countryBS => 'Bahamas';

  @override
  String get countryJM => 'Jamaika';

  @override
  String get countryMX => 'Mexiko';

  @override
  String get countryBZ => 'Belize';

  @override
  String get countryHN => 'Honduras';

  @override
  String get countryPA => 'Panama';

  @override
  String get countryAW => 'Aruba';

  @override
  String get countryCW => 'Curaçao';

  @override
  String get countrySX => 'Sint Maarten';

  @override
  String get countryVG => 'Britische Jungferninseln';

  @override
  String get countryVI => 'Amerikanische Jungferninseln';

  @override
  String get countryPR => 'Puerto Rico';

  @override
  String get countryDO => 'Dominikanische Republik';

  @override
  String get countryHT => 'Haiti';

  @override
  String get countryAG => 'Antigua und Barbuda';

  @override
  String get countryBB => 'Barbados';

  @override
  String get countryLC => 'Saint Lucia';

  @override
  String get countryGD => 'Grenada';

  @override
  String get countryVC => 'St. Vincent und die Grenadinen';

  @override
  String get countryKY => 'Kaimaninseln';

  @override
  String get countryTC => 'Turks- und Caicosinseln';

  @override
  String get countryTT => 'Trinidad und Tobago';

  @override
  String get countryCA => 'Kanada';

  @override
  String get countryAU => 'Australien';

  @override
  String get countryNZ => 'Neuseeland';

  @override
  String get countryJP => 'Japan';

  @override
  String get countryCN => 'China';

  @override
  String get countryTH => 'Thailand';

  @override
  String get countryVN => 'Vietnam';

  @override
  String get countrySG => 'Singapur';

  @override
  String get countryMY => 'Malaysia';

  @override
  String get countryID => 'Indonesien';

  @override
  String get countryPH => 'Philippinen';

  @override
  String get countryIN => 'Indien';

  @override
  String get countryEG => 'Ägypten';

  @override
  String get countryMA => 'Marokko';

  @override
  String get countryTN => 'Tunesien';

  @override
  String get countryZA => 'Südafrika';

  @override
  String get countryMU => 'Mauritius';

  @override
  String get countrySC => 'Seychellen';

  @override
  String get countryMV => 'Malediven';

  @override
  String get countryCL => 'Chile';

  @override
  String get countryAR => 'Argentinien';

  @override
  String get countryBR => 'Brasilien';

  @override
  String get countryPE => 'Peru';

  @override
  String get countryEC => 'Ecuador';

  @override
  String get countryCO => 'Kolumbien';

  @override
  String get countryCR => 'Costa Rica';

  @override
  String get countryFO => 'Färöer';

  @override
  String get countryGL => 'Grönland';

  @override
  String get countrySJ => 'Spitzbergen';

  @override
  String get countryAQ => 'Antarktis';

  @override
  String get countryPF => 'Französisch-Polynesien';

  @override
  String get countryFJ => 'Fidschi';

  @override
  String get countryTO => 'Tonga';

  @override
  String get countryWS => 'Samoa';

  @override
  String get countryNC => 'Neukaledonien';

  @override
  String get countryVU => 'Vanuatu';

  @override
  String get countryPG => 'Papua-Neuguinea';

  @override
  String get countrySB => 'Salomonen';

  @override
  String get countryGI => 'Gibraltar';

  @override
  String get countryMC => 'Monaco';

  @override
  String get countryAD => 'Andorra';

  @override
  String get countrySI => 'Slowenien';

  @override
  String get countryAL => 'Albanien';

  @override
  String get countryBA => 'Bosnien und Herzegowina';

  @override
  String get countryRS => 'Serbien';

  @override
  String get countryRO => 'Rumänien';

  @override
  String get countryBG => 'Bulgarien';

  @override
  String get countryUA => 'Ukraine';

  @override
  String get countryRU => 'Russland';

  @override
  String get countryEE => 'Estland';

  @override
  String get countryLV => 'Lettland';

  @override
  String get countryLT => 'Litauen';

  @override
  String get countryPL => 'Polen';

  @override
  String get countryCZ => 'Tschechien';

  @override
  String get countryAT => 'Österreich';

  @override
  String get countryCH => 'Schweiz';

  @override
  String get countryIE => 'Irland';

  @override
  String get countryIL => 'Israel';

  @override
  String get countryJO => 'Jordanien';

  @override
  String get countryOM => 'Oman';

  @override
  String get countryQA => 'Katar';

  @override
  String get countryBH => 'Bahrain';

  @override
  String get countryKW => 'Kuwait';

  @override
  String get countrySA => 'Saudi-Arabien';

  @override
  String get notAuthenticated => 'Bitte melde dich an um Reisen zu teilen';

  @override
  String failedToShare(String error) {
    return 'Teilen fehlgeschlagen: $error';
  }

  @override
  String get tripShared => 'Reise erfolgreich geteilt!';

  @override
  String get friends => 'Freunde';

  @override
  String get friendsTrips => 'Reisen von Freunden';

  @override
  String get noSharedTrips => 'Noch keine geteilten Reisen';

  @override
  String get noSharedTripsSubtitle =>
      'Wenn Freunde ihre Reisen mit dir teilen, erscheinen sie hier';

  @override
  String sharedBy(String name) {
    return 'Geteilt von $name';
  }

  @override
  String importedOn(String date) {
    return 'Importiert am $date';
  }

  @override
  String get removeSharedTrip => 'Entfernen';

  @override
  String get removeSharedTripConfirmation =>
      'Diese geteilte Reise aus deiner Liste entfernen?';

  @override
  String get duplicateToMyTrips => 'Zu meinen Reisen kopieren';

  @override
  String get tripDuplicated => 'Reise zu deinen Reisen kopiert!';

  @override
  String get readOnly => 'Nur lesen';

  @override
  String get sharedTrip => 'Geteilte Reise';

  @override
  String get importTrip => 'Reise importieren';

  @override
  String importTripQuestion(String owner) {
    return 'Möchtest du diese Reise von $owner importieren?';
  }

  @override
  String get import => 'Importieren';

  @override
  String get tripImported => 'Reise erfolgreich importiert!';

  @override
  String get invalidShareLink => 'Ungültiger Teilen-Link';

  @override
  String failedToImport(String error) {
    return 'Import fehlgeschlagen: $error';
  }

  @override
  String get departureIn => 'Abfahrt in';

  @override
  String get activeVoyage => 'Aktive Reise';

  @override
  String get atSea => 'Auf See';

  @override
  String get currentlyAt => 'Aktuell in';

  @override
  String get nextStop => 'Nächster Halt';

  @override
  String get voyageComplete => 'Reise abgeschlossen';

  @override
  String portsVisitedCount(int count) {
    return '$count Häfen besucht';
  }

  @override
  String daysAtSeaCount(int count) {
    return '$count Tage auf See';
  }

  @override
  String get seaDays => 'See';

  @override
  String get journeyProgress => 'Reisefortschritt';

  @override
  String get ok => 'OK';

  @override
  String get deletePort => 'Hafen löschen';

  @override
  String get deletePortConfirmation =>
      'Möchtest du diesen Hafen wirklich löschen?';
}
