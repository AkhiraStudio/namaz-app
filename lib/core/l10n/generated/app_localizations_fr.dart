// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get retryButton => 'Réessayer';

  @override
  String get cancelButton => 'Annuler';

  @override
  String get confirmButton => 'Confirmer';

  @override
  String get saveButton => 'Sauvegarder';

  @override
  String get continueButton => 'Continuer';

  @override
  String get deleteButton => 'Supprimer';

  @override
  String get welcomeTitle => 'Bienvenue sur Namaz';

  @override
  String get welcomeSubtitle =>
      'Votre compagnon spirituel pour les 5 prières quotidiennes.';

  @override
  String get preciseTimesTitle => 'Horaires Précis';

  @override
  String get preciseTimesSubtitle =>
      'Horaires calculés selon votre mosquée de référence, mis à jour en temps réel.';

  @override
  String get guidedMakeupTitle => 'Rattrapage Guidé';

  @override
  String get guidedMakeupSubtitle =>
      'Suivez vos dettes de prières et rattrapez-les à votre rythme.\n\n🌿 Jardin spirituel — bientôt disponible';

  @override
  String get qiblaPlusTitle => 'Qibla & Plus';

  @override
  String get qiblaPlusSubtitle =>
      'Boussole Qibla, adhkars, statistiques et bien plus encore.';

  @override
  String get skipButton => 'Passer';

  @override
  String get nextButton => 'Suivant';

  @override
  String get startButton => 'Commencer';

  @override
  String get createProfileTitle => 'Créer mon profil';

  @override
  String get yourFirstNameLabel => 'Votre prénom';

  @override
  String get enterFirstNameHint => 'Entrez votre prénom';

  @override
  String get youAreLabel => 'Vous êtes';

  @override
  String get menstrualCycleLabel => 'Cycle menstruel';

  @override
  String get cycleDurationLabel => 'Durée cycle (j)';

  @override
  String get menstruationDurationLabel => 'Durée règles (j)';

  @override
  String get profileUpdatedSnackbar => 'Profil mis à jour !';

  @override
  String get changeEmailTitle => 'Changer l\'email';

  @override
  String get newEmailLabel => 'Nouvel email';

  @override
  String get verificationEmailSent =>
      'Email de vérification envoyé à la nouvelle adresse.';

  @override
  String get changePasswordTitle => 'Changer le mot de passe';

  @override
  String get newPasswordLabel => 'Nouveau mot de passe';

  @override
  String get confirmPasswordLabel => 'Confirmer';

  @override
  String get passwordUpdatedSnackbar => 'Mot de passe mis à jour !';

  @override
  String get deleteProfileTitle => 'Supprimer le profil';

  @override
  String get deleteProfileWarning =>
      'Toutes vos données (prières, qada, sunnah) seront supprimées définitivement. Cette action est irréversible.';

  @override
  String get googleLinkedSnackbar => 'Compte Google associé avec succès !';

  @override
  String get signOutDialogTitle => 'Se déconnecter';

  @override
  String get signOutWarning => 'Vos données locales seront conservées.';

  @override
  String get signOutButton => 'Déconnecter';

  @override
  String get profileScreenTitle => 'Mon profil';

  @override
  String get anonymousAccountLabel => 'Compte anonyme';

  @override
  String get personalInfoSection => 'Informations personnelles';

  @override
  String get firstNameLabel => 'Prénom';

  @override
  String get genderLabel => 'Genre';

  @override
  String get accountSection => 'Compte';

  @override
  String get linkGoogleButton => 'Associer à Google';

  @override
  String get linkGoogleSubtitle =>
      'Sauvegardez vos données sur tous vos appareils';

  @override
  String get dangerZoneSection => 'Zone de danger';

  @override
  String get deleteProfileOption => 'Supprimer mon profil';

  @override
  String get deleteProfileDescription =>
      'Supprime toutes vos données de manière définitive';

  @override
  String get myMosqueTitle => 'Ma mosquée';

  @override
  String get travelerModeLabel => 'Mode Voyageur';

  @override
  String get travelerModeSubtitle =>
      'Horaires mis à jour selon votre position GPS';

  @override
  String get nearbyMosquesLabel => 'Mosquées à proximité';

  @override
  String get selectMosqueHint => 'Sélectionnez votre mosquée de référence';

  @override
  String get mosquesLoadError =>
      'Impossible de charger les mosquées.\nVérifiez que la localisation est activée.';

  @override
  String get noMosquesFound => 'Aucune mosquée trouvée à proximité.';

  @override
  String continueWithMosque(String mosqueName) {
    return 'Continuer avec $mosqueName';
  }

  @override
  String get continueWithoutMosque => 'Continuer sans mosquée';

  @override
  String get prayerEndedLabel => 'Terminée';

  @override
  String get currentPrayerLabel => 'Prière en cours';

  @override
  String get nextPrayerLabel => 'Prochaine prière';

  @override
  String get nearbyMosquesTitle => 'Mosquées proches';

  @override
  String get unableToLoadMosques => 'Impossible de charger les mosquées.';

  @override
  String get postPrayerTasbihTitle => 'Tasbih post-prière';

  @override
  String get subhanaAllahLabel => 'SubhânAllah';

  @override
  String get alhamdulillahLabel => 'Al-hamdulillah';

  @override
  String get allahuAkbarLabel => 'Allahu Akbar';

  @override
  String get editStatusTitle => 'Modifier le statut';

  @override
  String get validatePrayerTitle => 'Valider la prière';

  @override
  String get prayedEarlyButton => 'Prié tôt';

  @override
  String get prayedOnTimeButton => 'À l\'heure';

  @override
  String get prayedLateButton => 'Tard';

  @override
  String get missedButton => 'Manquée';

  @override
  String get menstruationButton => 'Menstrues';

  @override
  String get prayedOnTimeLabel => 'Prié à l\'heure';

  @override
  String get prayedLateLabel => 'Tard';

  @override
  String get missedPrayerLabel => 'Prière manquée';

  @override
  String get recordedLabel => 'Enregistrée';

  @override
  String get morningAdhkarsTitle => 'Adhkars du matin';

  @override
  String get eveningAdhkarsTitle => 'Adhkars du soir';

  @override
  String get afterPrayerTitle => 'Après la prière';

  @override
  String get adhkarProgressHint => '21 invocations • reprendre où j\'en suis';

  @override
  String get resetConfirmTitle => 'Réinitialiser ?';

  @override
  String get resetConfirmMessage => 'Remettre la progression à zéro ?';

  @override
  String get resetButton => 'Réinitialiser';

  @override
  String invocationCounter(int current, int total) {
    return 'Invocation $current / $total';
  }

  @override
  String get touchToReciteHint => 'Toucher l\'écran pour réciter';

  @override
  String get doneButton => 'Fait';

  @override
  String get completedLabel => 'Accomplie';

  @override
  String get tapToValidateLabel => 'Toucher pour valider';

  @override
  String get allahiBarak => 'Allahi Barak !';

  @override
  String get morningAdhkarsCompletedMessage =>
      'Tu as accompli les adhkars du matin.\nQu\'Allah les accepte de ta part.';

  @override
  String get eveningAdhkarsCompletedMessage =>
      'Tu as accompli les adhkars du soir.\nQu\'Allah les accepte de ta part.';

  @override
  String get sleepAdhkarsTitle => 'Adhkars du coucher';

  @override
  String get sleepAdhkarsCompletedMessage =>
      'Tu as accompli les adhkars du coucher.\nQu\'Allah les accepte de ta part.';

  @override
  String get restartButton => 'Recommencer';

  @override
  String get statisticsTitle => 'Statistiques';

  @override
  String get missedPrayersPerSalah => 'Prières manquées par salat';

  @override
  String get currentStreakLabel => 'Streak actuel';

  @override
  String get longestStreakLabel => 'Meilleur streak';

  @override
  String get sunnahPrayersTitle => 'Prières surérogatoires';

  @override
  String get spiritualPracticesTitle => 'Pratiques spirituelles';

  @override
  String get hideMissedPrayers => 'Masquer les prières manquées';

  @override
  String get showMissedPrayers => 'Afficher les prières manquées';

  @override
  String get adherenceRateLabel => 'Taux d\'assiduité';

  @override
  String get excellentAdherence => 'Excellent ! Continuez ainsi.';

  @override
  String get goodAdherence => 'Bien, mais vous pouvez mieux faire.';

  @override
  String get needsEffort => 'Des efforts sont nécessaires.';

  @override
  String get completedPrayersLabel => 'Effectuées';

  @override
  String get missedPrayersLabel => 'Manquées';

  @override
  String get earlyLabel => 'Tôt';

  @override
  String get lateLabel => 'Tard';

  @override
  String get noneLabel => '✓ Aucune';

  @override
  String get missedSingular => 'manquée';

  @override
  String get missedPlural => 'manquées';

  @override
  String get weeklyReportTitle => 'Rapport de la semaine';

  @override
  String get previousWeekLabel => 'Sem. précédente';

  @override
  String get thisWeekLabel => 'Cette semaine';

  @override
  String get selectedPeriodSuffix => 'sur la période sélectionnée';

  @override
  String get calculateDebtTitle => 'Calculer ma dette';

  @override
  String get qadaInstructions =>
      'Entrez la date à laquelle vous avez arrêté de prier et la date à laquelle vous avez repris. L\'application calculera automatiquement le nombre de jours à rattraper, en déduisant les jours de menstrues si vous êtes une femme.';

  @override
  String get resultLabel => 'Résultat';

  @override
  String get totalDaysLabel => 'Jours totaux';

  @override
  String get menstruationDeducted => 'Règles déduites';

  @override
  String get effectiveDaysLabel => 'Jours effectifs';

  @override
  String get prayerDaysLabel => 'Jours de prières';

  @override
  String get totalPrayersLabel => 'Total prières';

  @override
  String get setEndGoalLabel => 'Définir un objectif de fin';

  @override
  String get dailyGoalLabel => 'Objectif quotidien';

  @override
  String get desiredEndDateLabel => 'Date de fin souhaitée';

  @override
  String get chooseDateButton => 'Choisir une date de fin';

  @override
  String goalDateButton(int day, int month, int year) {
    return 'Objectif : $day/$month/$year';
  }

  @override
  String get stopDateHelpText => 'Début de la période sans pratique';

  @override
  String get resumeDateHelpText => 'Reprise de la pratique';

  @override
  String cycleInfoLabel(int cycleDays, int mensDays) {
    return 'Cycle utilisé : $cycleDays j  •  Règles : $mensDays j\n(depuis votre profil)';
  }

  @override
  String periodLabel(int number) {
    return 'Période $number';
  }

  @override
  String get startStopLabel => 'Début (arrêt)';

  @override
  String get endResumeLabel => 'Fin (reprise)';

  @override
  String daysCount(int count) {
    return '$count jours';
  }

  @override
  String get pregnancyPeriodLabel => 'Période de grossesse (sans menstrues)';

  @override
  String get addPeriodPremium => 'Ajouter une période (Premium)';

  @override
  String get addPeriodButton => 'Ajouter une période';

  @override
  String get calculateButton => 'Calculer';

  @override
  String get chooseDateLabel => 'Choisir';

  @override
  String get qadaStatisticsTitle => 'Statistiques du rattrapage';

  @override
  String get makeupPrayersLabel => 'Prières rattrapées';

  @override
  String get streaksSection => 'Séries';

  @override
  String get currentStreakQadaLabel => 'Série actuelle';

  @override
  String get longestStreakQadaLabel => 'Meilleure série';

  @override
  String get distributionByPrayer => 'Répartition par prière';

  @override
  String get totalMakeupAllTime => 'Total rattrapé (depuis le début)';

  @override
  String get prayerSingular => 'prière';

  @override
  String get prayerPlural => 'prières';

  @override
  String cycleDurationDisplay(int days) {
    return 'Durée du cycle : $days jours';
  }

  @override
  String menstruationDurationDisplay(int days) {
    return 'Durée des règles : $days jours';
  }

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get notificationsSection => 'Notifications';

  @override
  String get prayerRemindersTitle => 'Rappels de prière';

  @override
  String get prayerRemindersSubtitle => 'Wudu 15 min avant + adhan';

  @override
  String get adhanAlertLabel => 'Alerte à l\'adhan';

  @override
  String get qadaRemindersTitle => 'Rappels de rattrapage';

  @override
  String qadaRemindersSubtitle(int morningHour, int eveningHour) {
    return 'Matin ${morningHour}h00 · Soir ${eveningHour}h00';
  }

  @override
  String get morningReminderLabel => 'Rappel du matin';

  @override
  String get eveningReminderLabel => 'Rappel du soir';

  @override
  String get morningReminderHelp => 'Heure du rappel matin';

  @override
  String get eveningReminderHelp => 'Heure du rappel soir';

  @override
  String get prayersSection => 'Prières';

  @override
  String get sunnahPrayersSubtitle => 'Rawatib, Duha, Shif3 & Witr';

  @override
  String get displaySection => 'Affichage';

  @override
  String get darkModeLabel => 'Mode sombre';

  @override
  String get showStreakLabel => 'Afficher la série';

  @override
  String get showStreakSubtitle => 'Jours consécutifs sans prière manquée';

  @override
  String get prayerTimesSection => 'Calcul des horaires';

  @override
  String get calculationMethodLabel => 'Méthode de calcul';

  @override
  String get adjustmentsLabel => 'Ajustements';

  @override
  String get noActiveOffset => 'Aucun décalage actif';

  @override
  String globalOffsetLabel(String offset) {
    return 'Global : $offset min';
  }

  @override
  String get allPrayersLabel => 'Toutes les prières';

  @override
  String get locationSection => 'Localisation';

  @override
  String get travelerModeSubtitleSettings => 'Horaires selon la position GPS';

  @override
  String get dataSection => 'Données';

  @override
  String get resetPrayersLabel => 'Réinitialiser les prières';

  @override
  String get resetPrayersWarning =>
      'Toutes les données de prières seront supprimées définitivement.';

  @override
  String get upgradeToPremium => 'Passer à Premium';

  @override
  String get premiumSubtitle => 'Statistiques, adhkars, jardin et plus';

  @override
  String get discoverButton => 'Découvrir';

  @override
  String get editProfileSubtitle => 'Modifier le profil';

  @override
  String get languageSection => 'Langue';

  @override
  String get period7Days => '7j';

  @override
  String get period30Days => '30j';

  @override
  String get period3Months => '3m';

  @override
  String get period1Year => '1an';

  @override
  String get last7DaysLabel => '7 derniers jours';

  @override
  String get last30DaysLabel => '30 derniers jours';

  @override
  String get last3MonthsLabel => '3 derniers mois';

  @override
  String get lastYearLabel => 'L\'année écoulée';

  @override
  String streakDays(int count) {
    return '$count j';
  }

  @override
  String dailyGoalPrayers(int count) {
    return '$count prières/jour';
  }

  @override
  String errorLabel(String message) {
    return 'Erreur : $message';
  }

  @override
  String get todayPrayerTimesTitle => 'Horaires du jour';

  @override
  String get nightThirdTitle => 'Tiers de la nuit';

  @override
  String get nightTabLabel => 'Nuit';

  @override
  String get statsTabLabel => 'Stats';

  @override
  String get mosquesTabLabel => 'Mosquées';

  @override
  String get sunriseLabel => 'Shourouk';

  @override
  String get validateButton => 'Valider';

  @override
  String get howDidYouPrayLabel => 'Comment avez-vous prié ?';

  @override
  String get prayedEarlyDescription => 'Prié tôt — dans les 30 premières min';

  @override
  String get prayedOnTimeDescription => 'Prié à l\'heure';

  @override
  String get prayedLateDescription => 'Prié en retard';

  @override
  String get postPrayerDhikrLabel => 'Dhikr post-prière';

  @override
  String get ayatAlKursiLabel => 'Ayat al-Kursi — 1×';

  @override
  String get qadaScreenTitle => 'Rattrapage';

  @override
  String get scheduleTab => 'Programme';

  @override
  String get missedTab => 'Manquées';

  @override
  String get loadingLabel => 'Chargement...';

  @override
  String remainingPrayers(int count) {
    return '$count prières restantes';
  }

  @override
  String get noMissedPrayerTitle => 'Aucune prière manquée';

  @override
  String get allPrayersUpToDate => 'Toutes vos prières sont à jour.';

  @override
  String get toMakeUpLabel => 'à rattraper';

  @override
  String missedOnDate(String date) {
    return 'Manquée le $date';
  }

  @override
  String get makeUpButton => 'Rattraper';

  @override
  String get calculateTabLabel => 'Calcul';

  @override
  String dailyObjectiveTitle(String value) {
    return 'Objectif : $value';
  }

  @override
  String get switchToPrayersLabel => 'En prières';

  @override
  String get switchToDaysLabel => 'En jours';

  @override
  String dailyGoalDays(int count) {
    return '$count jours/jour';
  }

  @override
  String makeupDaysCount(int count) {
    return '$count jours de rattrapage';
  }

  @override
  String get qiblaDetectionMessage => 'Détection de la Qibla...';

  @override
  String get facingQiblaLine1 => 'Vous faites face à';

  @override
  String get facingQiblaLine2 => 'La Qibla';

  @override
  String get turnToLabel => 'Tournez à';

  @override
  String get rightDirection => 'droite';

  @override
  String get leftDirection => 'gauche';

  @override
  String get calibrateCompassMessage =>
      'Calibrez la boussole : tracez un 8 dans l\'air.';

  @override
  String get compassCalibratedLabel => 'Boussole calibrée';

  @override
  String get calibrationRecommendedLabel => 'Calibration recommandée';

  @override
  String get sunnahSectionLabel => 'Surérogatoires';

  @override
  String get showInPrayersLabel => 'Afficher en prières';

  @override
  String get showInDaysLabel => 'Afficher en jours';

  @override
  String get daysUnit => 'jours';

  @override
  String get dailyGoalReachedMessage => 'Objectif du jour atteint !';

  @override
  String get homeNavLabel => 'Accueil';

  @override
  String get qadaNavLabel => 'Rattrapage';

  @override
  String get firstThirdLabel => '1er tiers';

  @override
  String get secondThirdLabel => '2ème tiers';

  @override
  String get thirdThirdLabel => '3ème tiers — Tahajjud';

  @override
  String get nowLabel => 'Maintenant';

  @override
  String alarmScheduledAt(String time) {
    return 'Alarme programmée à $time';
  }

  @override
  String get alarmCancelledLabel => 'Alarme annulée';

  @override
  String get globalProgressLabel => 'Progression globale';

  @override
  String get dayUnit => 'jour';

  @override
  String get weeklyMsgGreatProgress =>
      'Excellent progrès cette semaine ! Continuez sur cette lancée.';

  @override
  String get weeklyMsgSlightImprovement =>
      'Légère amélioration par rapport à la semaine dernière. Bien joué !';

  @override
  String get weeklyMsgHarderWeek =>
      'Cette semaine a été plus difficile. Chaque prière compte, ne vous découragez pas.';

  @override
  String get weeklyMsgSlightDecline =>
      'Petit relâchement cette semaine. Reprenez le rythme, vous en êtes capable.';

  @override
  String get weeklyMsgNotEnoughData =>
      'Pas encore assez de données pour comparer.';

  @override
  String get weeklyMsgStable =>
      'Votre régularité est constante. Maintenez cet effort !';

  @override
  String qadaWeeklyMsgExcellent(int delta) {
    return 'Excellente semaine ! +$delta prières de plus que la semaine dernière. BarakAllahu feek !';
  }

  @override
  String qadaWeeklyMsgGood(int delta) {
    return 'Bonne progression ! Vous avez rattrapé $delta prières de plus cette semaine. Continuez !';
  }

  @override
  String get qadaWeeklyMsgStable =>
      'Votre régularité est stable. Maintenez ce rythme !';

  @override
  String get qadaWeeklyMsgSlightDecline =>
      'Cette semaine a été un peu plus calme. Chaque prière rattrapée est une récompense — reprenez l\'élan !';

  @override
  String get qadaWeeklyMsgBigDecline =>
      'Ne vous découragez pas ! Allah aime les actions accomplies avec constance, même petites. Une prière à la fois.';

  @override
  String get weeklyProgressTitle => 'Votre progrès';
}
