// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get retryButton => 'Retry';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get confirmButton => 'Confirm';

  @override
  String get saveButton => 'Save';

  @override
  String get continueButton => 'Continue';

  @override
  String get deleteButton => 'Delete';

  @override
  String get welcomeTitle => 'Welcome to Namaz';

  @override
  String get welcomeSubtitle =>
      'Your spiritual companion for the 5 daily prayers.';

  @override
  String get preciseTimesTitle => 'Precise Times';

  @override
  String get preciseTimesSubtitle =>
      'Prayer times calculated based on your reference mosque, updated in real time.';

  @override
  String get guidedMakeupTitle => 'Guided Makeup';

  @override
  String get guidedMakeupSubtitle =>
      'Track your missed prayers and make them up at your own pace.\n\n🌿 Spiritual garden — coming soon';

  @override
  String get qiblaPlusTitle => 'Qibla & More';

  @override
  String get qiblaPlusSubtitle =>
      'Qibla compass, adhkars, statistics and much more.';

  @override
  String get skipButton => 'Skip';

  @override
  String get nextButton => 'Next';

  @override
  String get startButton => 'Get Started';

  @override
  String get createProfileTitle => 'Create my profile';

  @override
  String get yourFirstNameLabel => 'Your first name';

  @override
  String get enterFirstNameHint => 'Enter your first name';

  @override
  String get youAreLabel => 'You are';

  @override
  String get menstrualCycleLabel => 'Menstrual cycle';

  @override
  String get cycleDurationLabel => 'Cycle duration (d)';

  @override
  String get menstruationDurationLabel => 'Period duration (d)';

  @override
  String get profileUpdatedSnackbar => 'Profile updated!';

  @override
  String get changeEmailTitle => 'Change email';

  @override
  String get newEmailLabel => 'New email';

  @override
  String get verificationEmailSent =>
      'Verification email sent to the new address.';

  @override
  String get changePasswordTitle => 'Change password';

  @override
  String get newPasswordLabel => 'New password';

  @override
  String get confirmPasswordLabel => 'Confirm';

  @override
  String get passwordUpdatedSnackbar => 'Password updated!';

  @override
  String get deleteProfileTitle => 'Delete profile';

  @override
  String get deleteProfileWarning =>
      'All your data (prayers, qada, sunnah) will be permanently deleted. This action is irreversible.';

  @override
  String get googleLinkedSnackbar => 'Google account linked successfully!';

  @override
  String get signOutDialogTitle => 'Sign out';

  @override
  String get signOutWarning => 'Your local data will be preserved.';

  @override
  String get signOutButton => 'Sign out';

  @override
  String get profileScreenTitle => 'My profile';

  @override
  String get anonymousAccountLabel => 'Anonymous account';

  @override
  String get personalInfoSection => 'Personal information';

  @override
  String get firstNameLabel => 'First name';

  @override
  String get genderLabel => 'Gender';

  @override
  String get accountSection => 'Account';

  @override
  String get linkGoogleButton => 'Link to Google';

  @override
  String get linkGoogleSubtitle => 'Back up your data across all your devices';

  @override
  String get dangerZoneSection => 'Danger zone';

  @override
  String get deleteProfileOption => 'Delete my profile';

  @override
  String get deleteProfileDescription => 'Permanently deletes all your data';

  @override
  String get myMosqueTitle => 'My mosque';

  @override
  String get travelerModeLabel => 'Traveler Mode';

  @override
  String get travelerModeSubtitle =>
      'Prayer times updated based on your GPS location';

  @override
  String get nearbyMosquesLabel => 'Nearby mosques';

  @override
  String get selectMosqueHint => 'Select your reference mosque';

  @override
  String get mosquesLoadError =>
      'Unable to load mosques.\nPlease make sure location is enabled.';

  @override
  String get noMosquesFound => 'No mosque found nearby.';

  @override
  String continueWithMosque(String mosqueName) {
    return 'Continue with $mosqueName';
  }

  @override
  String get continueWithoutMosque => 'Continue without mosque';

  @override
  String get prayerEndedLabel => 'Ended';

  @override
  String get currentPrayerLabel => 'Current prayer';

  @override
  String get nextPrayerLabel => 'Next prayer';

  @override
  String get nearbyMosquesTitle => 'Nearby mosques';

  @override
  String get unableToLoadMosques => 'Unable to load mosques.';

  @override
  String get postPrayerTasbihTitle => 'Post-prayer tasbih';

  @override
  String get subhanaAllahLabel => 'SubhânAllah';

  @override
  String get alhamdulillahLabel => 'Al-hamdulillah';

  @override
  String get allahuAkbarLabel => 'Allahu Akbar';

  @override
  String get editStatusTitle => 'Edit status';

  @override
  String get validatePrayerTitle => 'Record prayer';

  @override
  String get prayedEarlyButton => 'Prayed early';

  @override
  String get prayedOnTimeButton => 'On time';

  @override
  String get prayedLateButton => 'Late';

  @override
  String get missedButton => 'Missed';

  @override
  String get menstruationButton => 'Menstruation';

  @override
  String get prayedOnTimeLabel => 'Prayed on time';

  @override
  String get prayedLateLabel => 'Prayed late';

  @override
  String get missedPrayerLabel => 'Missed prayer';

  @override
  String get recordedLabel => 'Recorded';

  @override
  String get morningAdhkarsTitle => 'Morning Adhkars';

  @override
  String get eveningAdhkarsTitle => 'Evening Adhkars';

  @override
  String get afterPrayerTitle => 'After prayer';

  @override
  String get adhkarProgressHint => '21 invocations • resume where I left off';

  @override
  String get resetConfirmTitle => 'Reset?';

  @override
  String get resetConfirmMessage => 'Reset progress to zero?';

  @override
  String get resetButton => 'Reset';

  @override
  String invocationCounter(int current, int total) {
    return 'Invocation $current / $total';
  }

  @override
  String get touchToReciteHint => 'Tap screen to recite';

  @override
  String get doneButton => 'Done';

  @override
  String get completedLabel => 'Completed';

  @override
  String get tapToValidateLabel => 'Tap to validate';

  @override
  String get allahiBarak => 'Allahi Barak!';

  @override
  String get morningAdhkarsCompletedMessage =>
      'You have completed the morning adhkars.\nMay Allah accept them from you.';

  @override
  String get eveningAdhkarsCompletedMessage =>
      'You have completed the evening adhkars.\nMay Allah accept them from you.';

  @override
  String get sleepAdhkarsTitle => 'Sleep Adhkars';

  @override
  String get sleepAdhkarsCompletedMessage =>
      'You have completed the sleep adhkars.\nMay Allah accept them from you.';

  @override
  String get restartButton => 'Restart';

  @override
  String get statisticsTitle => 'Statistics';

  @override
  String get missedPrayersPerSalah => 'Missed prayers per salah';

  @override
  String get currentStreakLabel => 'Current streak';

  @override
  String get longestStreakLabel => 'Best streak';

  @override
  String get sunnahPrayersTitle => 'Sunnah prayers';

  @override
  String get spiritualPracticesTitle => 'Spiritual practices';

  @override
  String get hideMissedPrayers => 'Hide missed prayers';

  @override
  String get showMissedPrayers => 'Show missed prayers';

  @override
  String get adherenceRateLabel => 'Adherence rate';

  @override
  String get excellentAdherence => 'Excellent! Keep it up.';

  @override
  String get goodAdherence => 'Good, but you can do better.';

  @override
  String get needsEffort => 'Effort is needed.';

  @override
  String get completedPrayersLabel => 'Completed';

  @override
  String get missedPrayersLabel => 'Missed';

  @override
  String get earlyLabel => 'Early';

  @override
  String get lateLabel => 'Late';

  @override
  String get noneLabel => '✓ None';

  @override
  String get missedSingular => 'missed';

  @override
  String get missedPlural => 'missed';

  @override
  String get weeklyReportTitle => 'Weekly report';

  @override
  String get previousWeekLabel => 'Previous week';

  @override
  String get thisWeekLabel => 'This week';

  @override
  String get selectedPeriodSuffix => 'over the selected period';

  @override
  String get calculateDebtTitle => 'Calculate my debt';

  @override
  String get qadaInstructions =>
      'Enter the date when you stopped praying and the date when you resumed. The app will automatically calculate the number of days to make up, deducting menstruation days if you are a woman.';

  @override
  String get resultLabel => 'Result';

  @override
  String get totalDaysLabel => 'Total days';

  @override
  String get menstruationDeducted => 'Periods deducted';

  @override
  String get effectiveDaysLabel => 'Effective days';

  @override
  String get prayerDaysLabel => 'Prayer days';

  @override
  String get totalPrayersLabel => 'Total prayers';

  @override
  String get setEndGoalLabel => 'Set an end goal';

  @override
  String get dailyGoalLabel => 'Daily goal';

  @override
  String get desiredEndDateLabel => 'Desired end date';

  @override
  String get chooseDateButton => 'Choose an end date';

  @override
  String goalDateButton(int day, int month, int year) {
    return 'Goal: $day/$month/$year';
  }

  @override
  String get stopDateHelpText => 'Start of the period without practice';

  @override
  String get resumeDateHelpText => 'Resumption of practice';

  @override
  String cycleInfoLabel(int cycleDays, int mensDays) {
    return 'Cycle used: $cycleDays d  •  Period: $mensDays d\n(from your profile)';
  }

  @override
  String periodLabel(int number) {
    return 'Period $number';
  }

  @override
  String get startStopLabel => 'Start (stop)';

  @override
  String get endResumeLabel => 'End (resume)';

  @override
  String daysCount(int count) {
    return '$count days';
  }

  @override
  String get pregnancyPeriodLabel => 'Pregnancy period (no menstruation)';

  @override
  String get addPeriodPremium => 'Add a period (Premium)';

  @override
  String get addPeriodButton => 'Add a period';

  @override
  String get calculateButton => 'Calculate';

  @override
  String get chooseDateLabel => 'Choose';

  @override
  String get qadaStatisticsTitle => 'Makeup statistics';

  @override
  String get makeupPrayersLabel => 'Makeup prayers';

  @override
  String get streaksSection => 'Streaks';

  @override
  String get currentStreakQadaLabel => 'Current streak';

  @override
  String get longestStreakQadaLabel => 'Best streak';

  @override
  String get distributionByPrayer => 'Distribution by prayer';

  @override
  String get totalMakeupAllTime => 'Total made up (since the beginning)';

  @override
  String get prayerSingular => 'prayer';

  @override
  String get prayerPlural => 'prayers';

  @override
  String cycleDurationDisplay(int days) {
    return 'Cycle duration: $days days';
  }

  @override
  String menstruationDurationDisplay(int days) {
    return 'Period duration: $days days';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get notificationsSection => 'Notifications';

  @override
  String get prayerRemindersTitle => 'Prayer reminders';

  @override
  String get prayerRemindersSubtitle => 'Wudu 15 min before + adhan';

  @override
  String get adhanAlertLabel => 'Adhan alert';

  @override
  String get qadaRemindersTitle => 'Makeup reminders';

  @override
  String qadaRemindersSubtitle(int morningHour, int eveningHour) {
    return 'Morning $morningHour:00 · Evening $eveningHour:00';
  }

  @override
  String get morningReminderLabel => 'Morning reminder';

  @override
  String get eveningReminderLabel => 'Evening reminder';

  @override
  String get morningReminderHelp => 'Morning reminder time';

  @override
  String get eveningReminderHelp => 'Evening reminder time';

  @override
  String get prayersSection => 'Prayers';

  @override
  String get sunnahPrayersSubtitle => 'Rawatib, Duha, Shif3 & Witr';

  @override
  String get displaySection => 'Display';

  @override
  String get darkModeLabel => 'Dark mode';

  @override
  String get showStreakLabel => 'Show streak';

  @override
  String get showStreakSubtitle => 'Consecutive days without a missed prayer';

  @override
  String get prayerTimesSection => 'Prayer time calculation';

  @override
  String get calculationMethodLabel => 'Calculation method';

  @override
  String get adjustmentsLabel => 'Adjustments';

  @override
  String get noActiveOffset => 'No active offset';

  @override
  String globalOffsetLabel(String offset) {
    return 'Global: $offset min';
  }

  @override
  String get allPrayersLabel => 'All prayers';

  @override
  String get locationSection => 'Location';

  @override
  String get travelerModeSubtitleSettings => 'Times based on GPS position';

  @override
  String get dataSection => 'Data';

  @override
  String get resetPrayersLabel => 'Reset prayers';

  @override
  String get resetPrayersWarning =>
      'All prayer data will be permanently deleted.';

  @override
  String get upgradeToPremium => 'Upgrade to Premium';

  @override
  String get premiumSubtitle => 'Statistics, adhkars, garden and more';

  @override
  String get discoverButton => 'Discover';

  @override
  String get editProfileSubtitle => 'Edit profile';

  @override
  String get languageSection => 'Language';

  @override
  String get period7Days => '7d';

  @override
  String get period30Days => '30d';

  @override
  String get period3Months => '3m';

  @override
  String get period1Year => '1y';

  @override
  String get last7DaysLabel => 'Last 7 days';

  @override
  String get last30DaysLabel => 'Last 30 days';

  @override
  String get last3MonthsLabel => 'Last 3 months';

  @override
  String get lastYearLabel => 'This year';

  @override
  String streakDays(int count) {
    return '$count d';
  }

  @override
  String dailyGoalPrayers(int count) {
    return '$count prayers/day';
  }

  @override
  String errorLabel(String message) {
    return 'Error: $message';
  }

  @override
  String get todayPrayerTimesTitle => 'Today\'s prayer times';

  @override
  String get nightThirdTitle => 'Night third';

  @override
  String get nightTabLabel => 'Night';

  @override
  String get statsTabLabel => 'Stats';

  @override
  String get mosquesTabLabel => 'Mosques';

  @override
  String get sunriseLabel => 'Sunrise';

  @override
  String get validateButton => 'Record';

  @override
  String get howDidYouPrayLabel => 'How did you pray?';

  @override
  String get prayedEarlyDescription => 'Prayed early — within the first 30 min';

  @override
  String get prayedOnTimeDescription => 'Prayed on time';

  @override
  String get prayedLateDescription => 'Prayed late';

  @override
  String get postPrayerDhikrLabel => 'Post-prayer dhikr';

  @override
  String get ayatAlKursiLabel => 'Ayat al-Kursi — 1×';

  @override
  String get qadaScreenTitle => 'Makeup prayers';

  @override
  String get scheduleTab => 'Schedule';

  @override
  String get missedTab => 'Missed';

  @override
  String get loadingLabel => 'Loading...';

  @override
  String remainingPrayers(int count) {
    return '$count prayers remaining';
  }

  @override
  String get noMissedPrayerTitle => 'No missed prayers';

  @override
  String get allPrayersUpToDate => 'All your prayers are up to date.';

  @override
  String get toMakeUpLabel => 'to make up';

  @override
  String missedOnDate(String date) {
    return 'Missed on $date';
  }

  @override
  String get makeUpButton => 'Make up';

  @override
  String get calculateTabLabel => 'Calc';

  @override
  String dailyObjectiveTitle(String value) {
    return 'Goal: $value';
  }

  @override
  String get switchToPrayersLabel => 'In prayers';

  @override
  String get switchToDaysLabel => 'In days';

  @override
  String dailyGoalDays(int count) {
    return '$count days/day';
  }

  @override
  String makeupDaysCount(int count) {
    return '$count makeup days';
  }

  @override
  String get qiblaDetectionMessage => 'Detecting Qibla...';

  @override
  String get facingQiblaLine1 => 'You are facing';

  @override
  String get facingQiblaLine2 => 'The Qibla';

  @override
  String get turnToLabel => 'Turn';

  @override
  String get rightDirection => 'right';

  @override
  String get leftDirection => 'left';

  @override
  String get calibrateCompassMessage =>
      'Calibrate the compass: draw a figure 8 in the air.';

  @override
  String get compassCalibratedLabel => 'Compass calibrated';

  @override
  String get calibrationRecommendedLabel => 'Calibration recommended';

  @override
  String get sunnahSectionLabel => 'Sunnah';

  @override
  String get showInPrayersLabel => 'Show in prayers';

  @override
  String get showInDaysLabel => 'Show in days';

  @override
  String get daysUnit => 'days';

  @override
  String get dailyGoalReachedMessage => 'Daily goal reached!';

  @override
  String get homeNavLabel => 'Home';

  @override
  String get qadaNavLabel => 'Makeup';

  @override
  String get firstThirdLabel => '1st third';

  @override
  String get secondThirdLabel => '2nd third';

  @override
  String get thirdThirdLabel => '3rd third — Tahajjud';

  @override
  String get nowLabel => 'Now';

  @override
  String alarmScheduledAt(String time) {
    return 'Alarm set for $time';
  }

  @override
  String get alarmCancelledLabel => 'Alarm cancelled';

  @override
  String get globalProgressLabel => 'Overall progress';

  @override
  String get dayUnit => 'day';

  @override
  String get weeklyMsgGreatProgress =>
      'Excellent progress this week! Keep it up.';

  @override
  String get weeklyMsgSlightImprovement =>
      'Slight improvement compared to last week. Well done!';

  @override
  String get weeklyMsgHarderWeek =>
      'This week was harder. Every prayer counts — don\'t give up.';

  @override
  String get weeklyMsgSlightDecline =>
      'A slight drop this week. Get back on track — you can do it.';

  @override
  String get weeklyMsgNotEnoughData => 'Not enough data yet to compare.';

  @override
  String get weeklyMsgStable =>
      'Your consistency is steady. Keep up the effort!';

  @override
  String qadaWeeklyMsgExcellent(int delta) {
    return 'Excellent week! +$delta more prayers than last week. BarakAllahu feek!';
  }

  @override
  String qadaWeeklyMsgGood(int delta) {
    return 'Good progress! You made up $delta more prayers this week. Keep going!';
  }

  @override
  String get qadaWeeklyMsgStable =>
      'Your consistency is stable. Keep up the pace!';

  @override
  String get qadaWeeklyMsgSlightDecline =>
      'This week was a bit quieter. Every makeup prayer is a reward — get back on track!';

  @override
  String get qadaWeeklyMsgBigDecline =>
      'Don\'t give up! Allah loves consistent actions, even small ones. One prayer at a time.';

  @override
  String get weeklyProgressTitle => 'Your progress';
}
