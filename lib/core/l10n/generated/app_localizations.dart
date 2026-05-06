import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

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
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @retryButton.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get retryButton;

  /// No description provided for @cancelButton.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancelButton;

  /// No description provided for @confirmButton.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get confirmButton;

  /// No description provided for @saveButton.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarder'**
  String get saveButton;

  /// No description provided for @continueButton.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get continueButton;

  /// No description provided for @deleteButton.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get deleteButton;

  /// No description provided for @welcomeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue sur Namaz'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Votre compagnon spirituel pour les 5 prières quotidiennes.'**
  String get welcomeSubtitle;

  /// No description provided for @preciseTimesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Horaires Précis'**
  String get preciseTimesTitle;

  /// No description provided for @preciseTimesSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Horaires calculés selon votre mosquée de référence, mis à jour en temps réel.'**
  String get preciseTimesSubtitle;

  /// No description provided for @guidedMakeupTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rattrapage Guidé'**
  String get guidedMakeupTitle;

  /// No description provided for @guidedMakeupSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Suivez vos dettes de prières et rattrapez-les à votre rythme.\n\n🌿 Jardin spirituel — bientôt disponible'**
  String get guidedMakeupSubtitle;

  /// No description provided for @qiblaPlusTitle.
  ///
  /// In fr, this message translates to:
  /// **'Qibla & Plus'**
  String get qiblaPlusTitle;

  /// No description provided for @qiblaPlusSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Boussole Qibla, adhkars, statistiques et bien plus encore.'**
  String get qiblaPlusSubtitle;

  /// No description provided for @skipButton.
  ///
  /// In fr, this message translates to:
  /// **'Passer'**
  String get skipButton;

  /// No description provided for @nextButton.
  ///
  /// In fr, this message translates to:
  /// **'Suivant'**
  String get nextButton;

  /// No description provided for @startButton.
  ///
  /// In fr, this message translates to:
  /// **'Commencer'**
  String get startButton;

  /// No description provided for @createProfileTitle.
  ///
  /// In fr, this message translates to:
  /// **'Créer mon profil'**
  String get createProfileTitle;

  /// No description provided for @yourFirstNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Votre prénom'**
  String get yourFirstNameLabel;

  /// No description provided for @enterFirstNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Entrez votre prénom'**
  String get enterFirstNameHint;

  /// No description provided for @youAreLabel.
  ///
  /// In fr, this message translates to:
  /// **'Vous êtes'**
  String get youAreLabel;

  /// No description provided for @menstrualCycleLabel.
  ///
  /// In fr, this message translates to:
  /// **'Cycle menstruel'**
  String get menstrualCycleLabel;

  /// No description provided for @cycleDurationLabel.
  ///
  /// In fr, this message translates to:
  /// **'Durée cycle (j)'**
  String get cycleDurationLabel;

  /// No description provided for @menstruationDurationLabel.
  ///
  /// In fr, this message translates to:
  /// **'Durée règles (j)'**
  String get menstruationDurationLabel;

  /// No description provided for @profileUpdatedSnackbar.
  ///
  /// In fr, this message translates to:
  /// **'Profil mis à jour !'**
  String get profileUpdatedSnackbar;

  /// No description provided for @changeEmailTitle.
  ///
  /// In fr, this message translates to:
  /// **'Changer l\'email'**
  String get changeEmailTitle;

  /// No description provided for @newEmailLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nouvel email'**
  String get newEmailLabel;

  /// No description provided for @verificationEmailSent.
  ///
  /// In fr, this message translates to:
  /// **'Email de vérification envoyé à la nouvelle adresse.'**
  String get verificationEmailSent;

  /// No description provided for @changePasswordTitle.
  ///
  /// In fr, this message translates to:
  /// **'Changer le mot de passe'**
  String get changePasswordTitle;

  /// No description provided for @newPasswordLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau mot de passe'**
  String get newPasswordLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get confirmPasswordLabel;

  /// No description provided for @passwordUpdatedSnackbar.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe mis à jour !'**
  String get passwordUpdatedSnackbar;

  /// No description provided for @deleteProfileTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le profil'**
  String get deleteProfileTitle;

  /// No description provided for @deleteProfileWarning.
  ///
  /// In fr, this message translates to:
  /// **'Toutes vos données (prières, qada, sunnah) seront supprimées définitivement. Cette action est irréversible.'**
  String get deleteProfileWarning;

  /// No description provided for @googleLinkedSnackbar.
  ///
  /// In fr, this message translates to:
  /// **'Compte Google associé avec succès !'**
  String get googleLinkedSnackbar;

  /// No description provided for @signOutDialogTitle.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get signOutDialogTitle;

  /// No description provided for @signOutWarning.
  ///
  /// In fr, this message translates to:
  /// **'Vos données locales seront conservées.'**
  String get signOutWarning;

  /// No description provided for @signOutButton.
  ///
  /// In fr, this message translates to:
  /// **'Déconnecter'**
  String get signOutButton;

  /// No description provided for @profileScreenTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mon profil'**
  String get profileScreenTitle;

  /// No description provided for @anonymousAccountLabel.
  ///
  /// In fr, this message translates to:
  /// **'Compte anonyme'**
  String get anonymousAccountLabel;

  /// No description provided for @personalInfoSection.
  ///
  /// In fr, this message translates to:
  /// **'Informations personnelles'**
  String get personalInfoSection;

  /// No description provided for @firstNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Prénom'**
  String get firstNameLabel;

  /// No description provided for @genderLabel.
  ///
  /// In fr, this message translates to:
  /// **'Genre'**
  String get genderLabel;

  /// No description provided for @accountSection.
  ///
  /// In fr, this message translates to:
  /// **'Compte'**
  String get accountSection;

  /// No description provided for @linkGoogleButton.
  ///
  /// In fr, this message translates to:
  /// **'Associer à Google'**
  String get linkGoogleButton;

  /// No description provided for @linkGoogleSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegardez vos données sur tous vos appareils'**
  String get linkGoogleSubtitle;

  /// No description provided for @dangerZoneSection.
  ///
  /// In fr, this message translates to:
  /// **'Zone de danger'**
  String get dangerZoneSection;

  /// No description provided for @deleteProfileOption.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer mon profil'**
  String get deleteProfileOption;

  /// No description provided for @deleteProfileDescription.
  ///
  /// In fr, this message translates to:
  /// **'Supprime toutes vos données de manière définitive'**
  String get deleteProfileDescription;

  /// No description provided for @myMosqueTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ma mosquée'**
  String get myMosqueTitle;

  /// No description provided for @travelerModeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Mode Voyageur'**
  String get travelerModeLabel;

  /// No description provided for @travelerModeSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Horaires mis à jour selon votre position GPS'**
  String get travelerModeSubtitle;

  /// No description provided for @nearbyMosquesLabel.
  ///
  /// In fr, this message translates to:
  /// **'Mosquées à proximité'**
  String get nearbyMosquesLabel;

  /// No description provided for @selectMosqueHint.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez votre mosquée de référence'**
  String get selectMosqueHint;

  /// No description provided for @mosquesLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les mosquées.\nVérifiez que la localisation est activée.'**
  String get mosquesLoadError;

  /// No description provided for @noMosquesFound.
  ///
  /// In fr, this message translates to:
  /// **'Aucune mosquée trouvée à proximité.'**
  String get noMosquesFound;

  /// No description provided for @continueWithMosque.
  ///
  /// In fr, this message translates to:
  /// **'Continuer avec {mosqueName}'**
  String continueWithMosque(String mosqueName);

  /// No description provided for @continueWithoutMosque.
  ///
  /// In fr, this message translates to:
  /// **'Continuer sans mosquée'**
  String get continueWithoutMosque;

  /// No description provided for @prayerEndedLabel.
  ///
  /// In fr, this message translates to:
  /// **'Terminée'**
  String get prayerEndedLabel;

  /// No description provided for @currentPrayerLabel.
  ///
  /// In fr, this message translates to:
  /// **'Prière en cours'**
  String get currentPrayerLabel;

  /// No description provided for @nextPrayerLabel.
  ///
  /// In fr, this message translates to:
  /// **'Prochaine prière'**
  String get nextPrayerLabel;

  /// No description provided for @nearbyMosquesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mosquées proches'**
  String get nearbyMosquesTitle;

  /// No description provided for @unableToLoadMosques.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les mosquées.'**
  String get unableToLoadMosques;

  /// No description provided for @postPrayerTasbihTitle.
  ///
  /// In fr, this message translates to:
  /// **'Tasbih post-prière'**
  String get postPrayerTasbihTitle;

  /// No description provided for @subhanaAllahLabel.
  ///
  /// In fr, this message translates to:
  /// **'SubhânAllah'**
  String get subhanaAllahLabel;

  /// No description provided for @alhamdulillahLabel.
  ///
  /// In fr, this message translates to:
  /// **'Al-hamdulillah'**
  String get alhamdulillahLabel;

  /// No description provided for @allahuAkbarLabel.
  ///
  /// In fr, this message translates to:
  /// **'Allahu Akbar'**
  String get allahuAkbarLabel;

  /// No description provided for @editStatusTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le statut'**
  String get editStatusTitle;

  /// No description provided for @validatePrayerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Valider la prière'**
  String get validatePrayerTitle;

  /// No description provided for @prayedEarlyButton.
  ///
  /// In fr, this message translates to:
  /// **'Prié tôt'**
  String get prayedEarlyButton;

  /// No description provided for @prayedOnTimeButton.
  ///
  /// In fr, this message translates to:
  /// **'À l\'heure'**
  String get prayedOnTimeButton;

  /// No description provided for @prayedLateButton.
  ///
  /// In fr, this message translates to:
  /// **'Tard'**
  String get prayedLateButton;

  /// No description provided for @missedButton.
  ///
  /// In fr, this message translates to:
  /// **'Manquée'**
  String get missedButton;

  /// No description provided for @menstruationButton.
  ///
  /// In fr, this message translates to:
  /// **'Menstrues'**
  String get menstruationButton;

  /// No description provided for @prayedOnTimeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Prié à l\'heure'**
  String get prayedOnTimeLabel;

  /// No description provided for @prayedLateLabel.
  ///
  /// In fr, this message translates to:
  /// **'Tard'**
  String get prayedLateLabel;

  /// No description provided for @missedPrayerLabel.
  ///
  /// In fr, this message translates to:
  /// **'Prière manquée'**
  String get missedPrayerLabel;

  /// No description provided for @recordedLabel.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrée'**
  String get recordedLabel;

  /// No description provided for @morningAdhkarsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Adhkars du matin'**
  String get morningAdhkarsTitle;

  /// No description provided for @eveningAdhkarsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Adhkars du soir'**
  String get eveningAdhkarsTitle;

  /// No description provided for @afterPrayerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Après la prière'**
  String get afterPrayerTitle;

  /// No description provided for @adhkarProgressHint.
  ///
  /// In fr, this message translates to:
  /// **'21 invocations • reprendre où j\'en suis'**
  String get adhkarProgressHint;

  /// No description provided for @resetConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser ?'**
  String get resetConfirmTitle;

  /// No description provided for @resetConfirmMessage.
  ///
  /// In fr, this message translates to:
  /// **'Remettre la progression à zéro ?'**
  String get resetConfirmMessage;

  /// No description provided for @resetButton.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser'**
  String get resetButton;

  /// No description provided for @invocationCounter.
  ///
  /// In fr, this message translates to:
  /// **'Invocation {current} / {total}'**
  String invocationCounter(int current, int total);

  /// No description provided for @touchToReciteHint.
  ///
  /// In fr, this message translates to:
  /// **'Toucher l\'écran pour réciter'**
  String get touchToReciteHint;

  /// No description provided for @doneButton.
  ///
  /// In fr, this message translates to:
  /// **'Fait'**
  String get doneButton;

  /// No description provided for @completedLabel.
  ///
  /// In fr, this message translates to:
  /// **'Accomplie'**
  String get completedLabel;

  /// No description provided for @tapToValidateLabel.
  ///
  /// In fr, this message translates to:
  /// **'Toucher pour valider'**
  String get tapToValidateLabel;

  /// No description provided for @allahiBarak.
  ///
  /// In fr, this message translates to:
  /// **'Allahi Barak !'**
  String get allahiBarak;

  /// No description provided for @morningAdhkarsCompletedMessage.
  ///
  /// In fr, this message translates to:
  /// **'Tu as accompli les adhkars du matin.\nQu\'Allah les accepte de ta part.'**
  String get morningAdhkarsCompletedMessage;

  /// No description provided for @eveningAdhkarsCompletedMessage.
  ///
  /// In fr, this message translates to:
  /// **'Tu as accompli les adhkars du soir.\nQu\'Allah les accepte de ta part.'**
  String get eveningAdhkarsCompletedMessage;

  /// No description provided for @sleepAdhkarsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Adhkars du coucher'**
  String get sleepAdhkarsTitle;

  /// No description provided for @sleepAdhkarsCompletedMessage.
  ///
  /// In fr, this message translates to:
  /// **'Tu as accompli les adhkars du coucher.\nQu\'Allah les accepte de ta part.'**
  String get sleepAdhkarsCompletedMessage;

  /// No description provided for @restartButton.
  ///
  /// In fr, this message translates to:
  /// **'Recommencer'**
  String get restartButton;

  /// No description provided for @statisticsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Statistiques'**
  String get statisticsTitle;

  /// No description provided for @missedPrayersPerSalah.
  ///
  /// In fr, this message translates to:
  /// **'Prières manquées par salat'**
  String get missedPrayersPerSalah;

  /// No description provided for @currentStreakLabel.
  ///
  /// In fr, this message translates to:
  /// **'Streak actuel'**
  String get currentStreakLabel;

  /// No description provided for @longestStreakLabel.
  ///
  /// In fr, this message translates to:
  /// **'Meilleur streak'**
  String get longestStreakLabel;

  /// No description provided for @sunnahPrayersTitle.
  ///
  /// In fr, this message translates to:
  /// **'Prières surérogatoires'**
  String get sunnahPrayersTitle;

  /// No description provided for @spiritualPracticesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Pratiques spirituelles'**
  String get spiritualPracticesTitle;

  /// No description provided for @hideMissedPrayers.
  ///
  /// In fr, this message translates to:
  /// **'Masquer les prières manquées'**
  String get hideMissedPrayers;

  /// No description provided for @showMissedPrayers.
  ///
  /// In fr, this message translates to:
  /// **'Afficher les prières manquées'**
  String get showMissedPrayers;

  /// No description provided for @adherenceRateLabel.
  ///
  /// In fr, this message translates to:
  /// **'Taux d\'assiduité'**
  String get adherenceRateLabel;

  /// No description provided for @excellentAdherence.
  ///
  /// In fr, this message translates to:
  /// **'Excellent ! Continuez ainsi.'**
  String get excellentAdherence;

  /// No description provided for @goodAdherence.
  ///
  /// In fr, this message translates to:
  /// **'Bien, mais vous pouvez mieux faire.'**
  String get goodAdherence;

  /// No description provided for @needsEffort.
  ///
  /// In fr, this message translates to:
  /// **'Des efforts sont nécessaires.'**
  String get needsEffort;

  /// No description provided for @completedPrayersLabel.
  ///
  /// In fr, this message translates to:
  /// **'Effectuées'**
  String get completedPrayersLabel;

  /// No description provided for @missedPrayersLabel.
  ///
  /// In fr, this message translates to:
  /// **'Manquées'**
  String get missedPrayersLabel;

  /// No description provided for @earlyLabel.
  ///
  /// In fr, this message translates to:
  /// **'Tôt'**
  String get earlyLabel;

  /// No description provided for @lateLabel.
  ///
  /// In fr, this message translates to:
  /// **'Tard'**
  String get lateLabel;

  /// No description provided for @noneLabel.
  ///
  /// In fr, this message translates to:
  /// **'✓ Aucune'**
  String get noneLabel;

  /// No description provided for @missedSingular.
  ///
  /// In fr, this message translates to:
  /// **'manquée'**
  String get missedSingular;

  /// No description provided for @missedPlural.
  ///
  /// In fr, this message translates to:
  /// **'manquées'**
  String get missedPlural;

  /// No description provided for @weeklyReportTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rapport de la semaine'**
  String get weeklyReportTitle;

  /// No description provided for @previousWeekLabel.
  ///
  /// In fr, this message translates to:
  /// **'Sem. précédente'**
  String get previousWeekLabel;

  /// No description provided for @thisWeekLabel.
  ///
  /// In fr, this message translates to:
  /// **'Cette semaine'**
  String get thisWeekLabel;

  /// No description provided for @selectedPeriodSuffix.
  ///
  /// In fr, this message translates to:
  /// **'sur la période sélectionnée'**
  String get selectedPeriodSuffix;

  /// No description provided for @calculateDebtTitle.
  ///
  /// In fr, this message translates to:
  /// **'Calculer ma dette'**
  String get calculateDebtTitle;

  /// No description provided for @qadaInstructions.
  ///
  /// In fr, this message translates to:
  /// **'Entrez la date à laquelle vous avez arrêté de prier et la date à laquelle vous avez repris. L\'application calculera automatiquement le nombre de jours à rattraper, en déduisant les jours de menstrues si vous êtes une femme.'**
  String get qadaInstructions;

  /// No description provided for @resultLabel.
  ///
  /// In fr, this message translates to:
  /// **'Résultat'**
  String get resultLabel;

  /// No description provided for @totalDaysLabel.
  ///
  /// In fr, this message translates to:
  /// **'Jours totaux'**
  String get totalDaysLabel;

  /// No description provided for @menstruationDeducted.
  ///
  /// In fr, this message translates to:
  /// **'Règles déduites'**
  String get menstruationDeducted;

  /// No description provided for @effectiveDaysLabel.
  ///
  /// In fr, this message translates to:
  /// **'Jours effectifs'**
  String get effectiveDaysLabel;

  /// No description provided for @prayerDaysLabel.
  ///
  /// In fr, this message translates to:
  /// **'Jours de prières'**
  String get prayerDaysLabel;

  /// No description provided for @totalPrayersLabel.
  ///
  /// In fr, this message translates to:
  /// **'Total prières'**
  String get totalPrayersLabel;

  /// No description provided for @setEndGoalLabel.
  ///
  /// In fr, this message translates to:
  /// **'Définir un objectif de fin'**
  String get setEndGoalLabel;

  /// No description provided for @dailyGoalLabel.
  ///
  /// In fr, this message translates to:
  /// **'Objectif quotidien'**
  String get dailyGoalLabel;

  /// No description provided for @desiredEndDateLabel.
  ///
  /// In fr, this message translates to:
  /// **'Date de fin souhaitée'**
  String get desiredEndDateLabel;

  /// No description provided for @chooseDateButton.
  ///
  /// In fr, this message translates to:
  /// **'Choisir une date de fin'**
  String get chooseDateButton;

  /// No description provided for @goalDateButton.
  ///
  /// In fr, this message translates to:
  /// **'Objectif : {day}/{month}/{year}'**
  String goalDateButton(int day, int month, int year);

  /// No description provided for @stopDateHelpText.
  ///
  /// In fr, this message translates to:
  /// **'Début de la période sans pratique'**
  String get stopDateHelpText;

  /// No description provided for @resumeDateHelpText.
  ///
  /// In fr, this message translates to:
  /// **'Reprise de la pratique'**
  String get resumeDateHelpText;

  /// No description provided for @cycleInfoLabel.
  ///
  /// In fr, this message translates to:
  /// **'Cycle utilisé : {cycleDays} j  •  Règles : {mensDays} j\n(depuis votre profil)'**
  String cycleInfoLabel(int cycleDays, int mensDays);

  /// No description provided for @periodLabel.
  ///
  /// In fr, this message translates to:
  /// **'Période {number}'**
  String periodLabel(int number);

  /// No description provided for @startStopLabel.
  ///
  /// In fr, this message translates to:
  /// **'Début (arrêt)'**
  String get startStopLabel;

  /// No description provided for @endResumeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Fin (reprise)'**
  String get endResumeLabel;

  /// No description provided for @daysCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} jours'**
  String daysCount(int count);

  /// No description provided for @pregnancyPeriodLabel.
  ///
  /// In fr, this message translates to:
  /// **'Période de grossesse (sans menstrues)'**
  String get pregnancyPeriodLabel;

  /// No description provided for @addPeriodPremium.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une période (Premium)'**
  String get addPeriodPremium;

  /// No description provided for @addPeriodButton.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une période'**
  String get addPeriodButton;

  /// No description provided for @calculateButton.
  ///
  /// In fr, this message translates to:
  /// **'Calculer'**
  String get calculateButton;

  /// No description provided for @chooseDateLabel.
  ///
  /// In fr, this message translates to:
  /// **'Choisir'**
  String get chooseDateLabel;

  /// No description provided for @qadaStatisticsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Statistiques du rattrapage'**
  String get qadaStatisticsTitle;

  /// No description provided for @makeupPrayersLabel.
  ///
  /// In fr, this message translates to:
  /// **'Prières rattrapées'**
  String get makeupPrayersLabel;

  /// No description provided for @streaksSection.
  ///
  /// In fr, this message translates to:
  /// **'Séries'**
  String get streaksSection;

  /// No description provided for @currentStreakQadaLabel.
  ///
  /// In fr, this message translates to:
  /// **'Série actuelle'**
  String get currentStreakQadaLabel;

  /// No description provided for @longestStreakQadaLabel.
  ///
  /// In fr, this message translates to:
  /// **'Meilleure série'**
  String get longestStreakQadaLabel;

  /// No description provided for @distributionByPrayer.
  ///
  /// In fr, this message translates to:
  /// **'Répartition par prière'**
  String get distributionByPrayer;

  /// No description provided for @totalMakeupAllTime.
  ///
  /// In fr, this message translates to:
  /// **'Total rattrapé (depuis le début)'**
  String get totalMakeupAllTime;

  /// No description provided for @prayerSingular.
  ///
  /// In fr, this message translates to:
  /// **'prière'**
  String get prayerSingular;

  /// No description provided for @prayerPlural.
  ///
  /// In fr, this message translates to:
  /// **'prières'**
  String get prayerPlural;

  /// No description provided for @cycleDurationDisplay.
  ///
  /// In fr, this message translates to:
  /// **'Durée du cycle : {days} jours'**
  String cycleDurationDisplay(int days);

  /// No description provided for @menstruationDurationDisplay.
  ///
  /// In fr, this message translates to:
  /// **'Durée des règles : {days} jours'**
  String menstruationDurationDisplay(int days);

  /// No description provided for @settingsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settingsTitle;

  /// No description provided for @notificationsSection.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get notificationsSection;

  /// No description provided for @prayerRemindersTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rappels de prière'**
  String get prayerRemindersTitle;

  /// No description provided for @prayerRemindersSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Wudu 15 min avant + adhan'**
  String get prayerRemindersSubtitle;

  /// No description provided for @adhanAlertLabel.
  ///
  /// In fr, this message translates to:
  /// **'Alerte à l\'adhan'**
  String get adhanAlertLabel;

  /// No description provided for @qadaRemindersTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rappels de rattrapage'**
  String get qadaRemindersTitle;

  /// No description provided for @qadaRemindersSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Matin {morningHour}h00 · Soir {eveningHour}h00'**
  String qadaRemindersSubtitle(int morningHour, int eveningHour);

  /// No description provided for @morningReminderLabel.
  ///
  /// In fr, this message translates to:
  /// **'Rappel du matin'**
  String get morningReminderLabel;

  /// No description provided for @eveningReminderLabel.
  ///
  /// In fr, this message translates to:
  /// **'Rappel du soir'**
  String get eveningReminderLabel;

  /// No description provided for @morningReminderHelp.
  ///
  /// In fr, this message translates to:
  /// **'Heure du rappel matin'**
  String get morningReminderHelp;

  /// No description provided for @eveningReminderHelp.
  ///
  /// In fr, this message translates to:
  /// **'Heure du rappel soir'**
  String get eveningReminderHelp;

  /// No description provided for @prayersSection.
  ///
  /// In fr, this message translates to:
  /// **'Prières'**
  String get prayersSection;

  /// No description provided for @sunnahPrayersSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Rawatib, Duha, Shif3 & Witr'**
  String get sunnahPrayersSubtitle;

  /// No description provided for @displaySection.
  ///
  /// In fr, this message translates to:
  /// **'Affichage'**
  String get displaySection;

  /// No description provided for @darkModeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Mode sombre'**
  String get darkModeLabel;

  /// No description provided for @showStreakLabel.
  ///
  /// In fr, this message translates to:
  /// **'Afficher la série'**
  String get showStreakLabel;

  /// No description provided for @showStreakSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Jours consécutifs sans prière manquée'**
  String get showStreakSubtitle;

  /// No description provided for @prayerTimesSection.
  ///
  /// In fr, this message translates to:
  /// **'Calcul des horaires'**
  String get prayerTimesSection;

  /// No description provided for @calculationMethodLabel.
  ///
  /// In fr, this message translates to:
  /// **'Méthode de calcul'**
  String get calculationMethodLabel;

  /// No description provided for @adjustmentsLabel.
  ///
  /// In fr, this message translates to:
  /// **'Ajustements'**
  String get adjustmentsLabel;

  /// No description provided for @noActiveOffset.
  ///
  /// In fr, this message translates to:
  /// **'Aucun décalage actif'**
  String get noActiveOffset;

  /// No description provided for @globalOffsetLabel.
  ///
  /// In fr, this message translates to:
  /// **'Global : {offset} min'**
  String globalOffsetLabel(String offset);

  /// No description provided for @allPrayersLabel.
  ///
  /// In fr, this message translates to:
  /// **'Toutes les prières'**
  String get allPrayersLabel;

  /// No description provided for @locationSection.
  ///
  /// In fr, this message translates to:
  /// **'Localisation'**
  String get locationSection;

  /// No description provided for @travelerModeSubtitleSettings.
  ///
  /// In fr, this message translates to:
  /// **'Horaires selon la position GPS'**
  String get travelerModeSubtitleSettings;

  /// No description provided for @dataSection.
  ///
  /// In fr, this message translates to:
  /// **'Données'**
  String get dataSection;

  /// No description provided for @resetPrayersLabel.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser les prières'**
  String get resetPrayersLabel;

  /// No description provided for @resetPrayersWarning.
  ///
  /// In fr, this message translates to:
  /// **'Toutes les données de prières seront supprimées définitivement.'**
  String get resetPrayersWarning;

  /// No description provided for @upgradeToPremium.
  ///
  /// In fr, this message translates to:
  /// **'Passer à Premium'**
  String get upgradeToPremium;

  /// No description provided for @premiumSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Statistiques, adhkars, jardin et plus'**
  String get premiumSubtitle;

  /// No description provided for @discoverButton.
  ///
  /// In fr, this message translates to:
  /// **'Découvrir'**
  String get discoverButton;

  /// No description provided for @editProfileSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le profil'**
  String get editProfileSubtitle;

  /// No description provided for @languageSection.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get languageSection;

  /// No description provided for @period7Days.
  ///
  /// In fr, this message translates to:
  /// **'7j'**
  String get period7Days;

  /// No description provided for @period30Days.
  ///
  /// In fr, this message translates to:
  /// **'30j'**
  String get period30Days;

  /// No description provided for @period3Months.
  ///
  /// In fr, this message translates to:
  /// **'3m'**
  String get period3Months;

  /// No description provided for @period1Year.
  ///
  /// In fr, this message translates to:
  /// **'1an'**
  String get period1Year;

  /// No description provided for @last7DaysLabel.
  ///
  /// In fr, this message translates to:
  /// **'7 derniers jours'**
  String get last7DaysLabel;

  /// No description provided for @last30DaysLabel.
  ///
  /// In fr, this message translates to:
  /// **'30 derniers jours'**
  String get last30DaysLabel;

  /// No description provided for @last3MonthsLabel.
  ///
  /// In fr, this message translates to:
  /// **'3 derniers mois'**
  String get last3MonthsLabel;

  /// No description provided for @lastYearLabel.
  ///
  /// In fr, this message translates to:
  /// **'L\'année écoulée'**
  String get lastYearLabel;

  /// No description provided for @streakDays.
  ///
  /// In fr, this message translates to:
  /// **'{count} j'**
  String streakDays(int count);

  /// No description provided for @dailyGoalPrayers.
  ///
  /// In fr, this message translates to:
  /// **'{count} prières/jour'**
  String dailyGoalPrayers(int count);

  /// No description provided for @errorLabel.
  ///
  /// In fr, this message translates to:
  /// **'Erreur : {message}'**
  String errorLabel(String message);

  /// No description provided for @todayPrayerTimesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Horaires du jour'**
  String get todayPrayerTimesTitle;

  /// No description provided for @nightThirdTitle.
  ///
  /// In fr, this message translates to:
  /// **'Tiers de la nuit'**
  String get nightThirdTitle;

  /// No description provided for @nightTabLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nuit'**
  String get nightTabLabel;

  /// No description provided for @statsTabLabel.
  ///
  /// In fr, this message translates to:
  /// **'Stats'**
  String get statsTabLabel;

  /// No description provided for @mosquesTabLabel.
  ///
  /// In fr, this message translates to:
  /// **'Mosquées'**
  String get mosquesTabLabel;

  /// No description provided for @sunriseLabel.
  ///
  /// In fr, this message translates to:
  /// **'Shourouk'**
  String get sunriseLabel;

  /// No description provided for @validateButton.
  ///
  /// In fr, this message translates to:
  /// **'Valider'**
  String get validateButton;

  /// No description provided for @howDidYouPrayLabel.
  ///
  /// In fr, this message translates to:
  /// **'Comment avez-vous prié ?'**
  String get howDidYouPrayLabel;

  /// No description provided for @prayedEarlyDescription.
  ///
  /// In fr, this message translates to:
  /// **'Prié tôt — dans les 30 premières min'**
  String get prayedEarlyDescription;

  /// No description provided for @prayedOnTimeDescription.
  ///
  /// In fr, this message translates to:
  /// **'Prié à l\'heure'**
  String get prayedOnTimeDescription;

  /// No description provided for @prayedLateDescription.
  ///
  /// In fr, this message translates to:
  /// **'Prié en retard'**
  String get prayedLateDescription;

  /// No description provided for @postPrayerDhikrLabel.
  ///
  /// In fr, this message translates to:
  /// **'Dhikr post-prière'**
  String get postPrayerDhikrLabel;

  /// No description provided for @ayatAlKursiLabel.
  ///
  /// In fr, this message translates to:
  /// **'Ayat al-Kursi — 1×'**
  String get ayatAlKursiLabel;

  /// No description provided for @qadaScreenTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rattrapage'**
  String get qadaScreenTitle;

  /// No description provided for @scheduleTab.
  ///
  /// In fr, this message translates to:
  /// **'Programme'**
  String get scheduleTab;

  /// No description provided for @missedTab.
  ///
  /// In fr, this message translates to:
  /// **'Manquées'**
  String get missedTab;

  /// No description provided for @loadingLabel.
  ///
  /// In fr, this message translates to:
  /// **'Chargement...'**
  String get loadingLabel;

  /// No description provided for @remainingPrayers.
  ///
  /// In fr, this message translates to:
  /// **'{count} prières restantes'**
  String remainingPrayers(int count);

  /// No description provided for @noMissedPrayerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucune prière manquée'**
  String get noMissedPrayerTitle;

  /// No description provided for @allPrayersUpToDate.
  ///
  /// In fr, this message translates to:
  /// **'Toutes vos prières sont à jour.'**
  String get allPrayersUpToDate;

  /// No description provided for @toMakeUpLabel.
  ///
  /// In fr, this message translates to:
  /// **'à rattraper'**
  String get toMakeUpLabel;

  /// No description provided for @missedOnDate.
  ///
  /// In fr, this message translates to:
  /// **'Manquée le {date}'**
  String missedOnDate(String date);

  /// No description provided for @makeUpButton.
  ///
  /// In fr, this message translates to:
  /// **'Rattraper'**
  String get makeUpButton;

  /// No description provided for @calculateTabLabel.
  ///
  /// In fr, this message translates to:
  /// **'Calcul'**
  String get calculateTabLabel;

  /// No description provided for @dailyObjectiveTitle.
  ///
  /// In fr, this message translates to:
  /// **'Objectif : {value}'**
  String dailyObjectiveTitle(String value);

  /// No description provided for @switchToPrayersLabel.
  ///
  /// In fr, this message translates to:
  /// **'En prières'**
  String get switchToPrayersLabel;

  /// No description provided for @switchToDaysLabel.
  ///
  /// In fr, this message translates to:
  /// **'En jours'**
  String get switchToDaysLabel;

  /// No description provided for @dailyGoalDays.
  ///
  /// In fr, this message translates to:
  /// **'{count} jours/jour'**
  String dailyGoalDays(int count);

  /// No description provided for @makeupDaysCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} jours de rattrapage'**
  String makeupDaysCount(int count);

  /// No description provided for @qiblaDetectionMessage.
  ///
  /// In fr, this message translates to:
  /// **'Détection de la Qibla...'**
  String get qiblaDetectionMessage;

  /// No description provided for @facingQiblaLine1.
  ///
  /// In fr, this message translates to:
  /// **'Vous faites face à'**
  String get facingQiblaLine1;

  /// No description provided for @facingQiblaLine2.
  ///
  /// In fr, this message translates to:
  /// **'La Qibla'**
  String get facingQiblaLine2;

  /// No description provided for @turnToLabel.
  ///
  /// In fr, this message translates to:
  /// **'Tournez à'**
  String get turnToLabel;

  /// No description provided for @rightDirection.
  ///
  /// In fr, this message translates to:
  /// **'droite'**
  String get rightDirection;

  /// No description provided for @leftDirection.
  ///
  /// In fr, this message translates to:
  /// **'gauche'**
  String get leftDirection;

  /// No description provided for @calibrateCompassMessage.
  ///
  /// In fr, this message translates to:
  /// **'Calibrez la boussole : tracez un 8 dans l\'air.'**
  String get calibrateCompassMessage;

  /// No description provided for @compassCalibratedLabel.
  ///
  /// In fr, this message translates to:
  /// **'Boussole calibrée'**
  String get compassCalibratedLabel;

  /// No description provided for @calibrationRecommendedLabel.
  ///
  /// In fr, this message translates to:
  /// **'Calibration recommandée'**
  String get calibrationRecommendedLabel;

  /// No description provided for @sunnahSectionLabel.
  ///
  /// In fr, this message translates to:
  /// **'Surérogatoires'**
  String get sunnahSectionLabel;

  /// No description provided for @showInPrayersLabel.
  ///
  /// In fr, this message translates to:
  /// **'Afficher en prières'**
  String get showInPrayersLabel;

  /// No description provided for @showInDaysLabel.
  ///
  /// In fr, this message translates to:
  /// **'Afficher en jours'**
  String get showInDaysLabel;

  /// No description provided for @daysUnit.
  ///
  /// In fr, this message translates to:
  /// **'jours'**
  String get daysUnit;

  /// No description provided for @dailyGoalReachedMessage.
  ///
  /// In fr, this message translates to:
  /// **'Objectif du jour atteint !'**
  String get dailyGoalReachedMessage;

  /// No description provided for @homeNavLabel.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get homeNavLabel;

  /// No description provided for @qadaNavLabel.
  ///
  /// In fr, this message translates to:
  /// **'Rattrapage'**
  String get qadaNavLabel;

  /// No description provided for @firstThirdLabel.
  ///
  /// In fr, this message translates to:
  /// **'1er tiers'**
  String get firstThirdLabel;

  /// No description provided for @secondThirdLabel.
  ///
  /// In fr, this message translates to:
  /// **'2ème tiers'**
  String get secondThirdLabel;

  /// No description provided for @thirdThirdLabel.
  ///
  /// In fr, this message translates to:
  /// **'3ème tiers — Tahajjud'**
  String get thirdThirdLabel;

  /// No description provided for @nowLabel.
  ///
  /// In fr, this message translates to:
  /// **'Maintenant'**
  String get nowLabel;

  /// No description provided for @alarmScheduledAt.
  ///
  /// In fr, this message translates to:
  /// **'Alarme programmée à {time}'**
  String alarmScheduledAt(String time);

  /// No description provided for @alarmCancelledLabel.
  ///
  /// In fr, this message translates to:
  /// **'Alarme annulée'**
  String get alarmCancelledLabel;

  /// No description provided for @globalProgressLabel.
  ///
  /// In fr, this message translates to:
  /// **'Progression globale'**
  String get globalProgressLabel;

  /// No description provided for @dayUnit.
  ///
  /// In fr, this message translates to:
  /// **'jour'**
  String get dayUnit;

  /// No description provided for @weeklyMsgGreatProgress.
  ///
  /// In fr, this message translates to:
  /// **'Excellent progrès cette semaine ! Continuez sur cette lancée.'**
  String get weeklyMsgGreatProgress;

  /// No description provided for @weeklyMsgSlightImprovement.
  ///
  /// In fr, this message translates to:
  /// **'Légère amélioration par rapport à la semaine dernière. Bien joué !'**
  String get weeklyMsgSlightImprovement;

  /// No description provided for @weeklyMsgHarderWeek.
  ///
  /// In fr, this message translates to:
  /// **'Cette semaine a été plus difficile. Chaque prière compte, ne vous découragez pas.'**
  String get weeklyMsgHarderWeek;

  /// No description provided for @weeklyMsgSlightDecline.
  ///
  /// In fr, this message translates to:
  /// **'Petit relâchement cette semaine. Reprenez le rythme, vous en êtes capable.'**
  String get weeklyMsgSlightDecline;

  /// No description provided for @weeklyMsgNotEnoughData.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore assez de données pour comparer.'**
  String get weeklyMsgNotEnoughData;

  /// No description provided for @weeklyMsgStable.
  ///
  /// In fr, this message translates to:
  /// **'Votre régularité est constante. Maintenez cet effort !'**
  String get weeklyMsgStable;

  /// No description provided for @qadaWeeklyMsgExcellent.
  ///
  /// In fr, this message translates to:
  /// **'Excellente semaine ! +{delta} prières de plus que la semaine dernière. BarakAllahu feek !'**
  String qadaWeeklyMsgExcellent(int delta);

  /// No description provided for @qadaWeeklyMsgGood.
  ///
  /// In fr, this message translates to:
  /// **'Bonne progression ! Vous avez rattrapé {delta} prières de plus cette semaine. Continuez !'**
  String qadaWeeklyMsgGood(int delta);

  /// No description provided for @qadaWeeklyMsgStable.
  ///
  /// In fr, this message translates to:
  /// **'Votre régularité est stable. Maintenez ce rythme !'**
  String get qadaWeeklyMsgStable;

  /// No description provided for @qadaWeeklyMsgSlightDecline.
  ///
  /// In fr, this message translates to:
  /// **'Cette semaine a été un peu plus calme. Chaque prière rattrapée est une récompense — reprenez l\'élan !'**
  String get qadaWeeklyMsgSlightDecline;

  /// No description provided for @qadaWeeklyMsgBigDecline.
  ///
  /// In fr, this message translates to:
  /// **'Ne vous découragez pas ! Allah aime les actions accomplies avec constance, même petites. Une prière à la fois.'**
  String get qadaWeeklyMsgBigDecline;

  /// No description provided for @weeklyProgressTitle.
  ///
  /// In fr, this message translates to:
  /// **'Votre progrès'**
  String get weeklyProgressTitle;
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
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
