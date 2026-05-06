import 'notification_service.dart';
import '../../features/prayer/domain/entities/prayer_time.dart';
import '../../features/qada/domain/entities/qada_progress.dart';
import '../../features/prayer/domain/entities/prayer_record.dart';
import '../../features/settings/domain/entities/app_settings.dart';

/// Orchestrateur des notifications : planifie prière et rattrapage
/// en fonction des données disponibles et des paramètres utilisateur.
class NotificationScheduler {
  static const _prayerNames = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

  /// Planifie les notifications de prière (wudu + adhan) pour aujourd'hui.
  /// Annule d'abord les existantes, puis replanifie celles qui sont dans le futur.
  static Future<void> schedulePrayerNotifications(
    PrayerTime times,
    AppSettings settings,
  ) async {
    await NotificationService.cancelPrayerNotifications();
    if (!settings.prayerNotifEnabled) return;

    final prayerTimes = [
      times.fajr,
      times.dhuhr,
      times.asr,
      times.maghrib,
      times.isha,
    ];

    final useAdhanSound = settings.prayerAlertType == PrayerAlertType.adhan;

    for (int i = 0; i < prayerTimes.length; i++) {
      final adhanTime = prayerTimes[i];
      final wuduTime = adhanTime.subtract(const Duration(minutes: 15));
      // Rappel wudu 15 min avant
      await NotificationService.scheduleWuduReminder(wuduTime, _prayerNames[i], i);
      // Notification adhan (son ou vibration selon préférence)
      await NotificationService.scheduleAdhanNotification(
        adhanTime, _prayerNames[i], i,
        useAdhanSound: useAdhanSound,
      );
    }
  }

  /// Planifie les notifications de rattrapage (matin + soir).
  /// [todayCounts] : nombre de rattrapages effectués aujourd'hui par prière.
  static Future<void> scheduleQadaNotifications(
    QadaProgress progress,
    Map<PrayerName, int> todayCounts,
    AppSettings settings,
  ) async {
    await NotificationService.cancelQadaNotifications();
    if (!settings.qadaNotifEnabled) return;
    if (progress.totalPrayersOwed == 0) return; // pas de programme de rattrapage

    // Rappel du matin
    await NotificationService.scheduleQadaMorningReminder(
      progress.dailyTargetPrayers,
      hour: settings.qadaMorningHour,
    );

    // Rappel du soir selon avancement
    final todayDone = todayCounts.values.fold(0, (sum, n) => sum + n);
    final todayRemaining =
        (progress.dailyTargetPrayers - todayDone).clamp(0, progress.dailyTargetPrayers);
    await NotificationService.scheduleQadaEveningReminder(
      todayRemaining: todayRemaining,
      dailyTarget: progress.dailyTargetPrayers,
      hour: settings.qadaEveningHour,
    );
  }
}
