import 'package:home_widget/home_widget.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import '../../features/prayer/domain/entities/prayer_time.dart';
import '../../features/qada/domain/entities/qada_progress.dart';
import '../../features/prayer/domain/entities/prayer_record.dart';

class HomeWidgetService {
  static const String _androidName        = 'NamazWidgetProvider';
  static const String _androidNameMini    = 'MiniPrayerWidgetProvider';
  static const String _androidNameQada    = 'QadaTrackerWidgetProvider';
  static const String _iosName            = 'NamazWidget';
  static const String _iosAppGroupId      = 'group.com.example.namaz_app';

  Future<void> initialize() async {
    await HomeWidget.setAppGroupId(_iosAppGroupId);
  }

  Future<void> update({
    required PrayerTime prayerTime,
    required MapEntry<String, DateTime>? nextPrayer,
    required int prayedCount,
  }) async {
    final fmt = DateFormat('HH:mm');

    // Horaires des 5 prières
    await HomeWidget.saveWidgetData<String>('fajr_time',    fmt.format(prayerTime.fajr));
    await HomeWidget.saveWidgetData<String>('dhuhr_time',   fmt.format(prayerTime.dhuhr));
    await HomeWidget.saveWidgetData<String>('asr_time',     fmt.format(prayerTime.asr));
    await HomeWidget.saveWidgetData<String>('maghrib_time', fmt.format(prayerTime.maghrib));
    await HomeWidget.saveWidgetData<String>('isha_time',    fmt.format(prayerTime.isha));

    // Prochaine prière (mise en évidence dans la liste du bas)
    await HomeWidget.saveWidgetData<String>('next_prayer_name', nextPrayer?.key ?? '');

    // Lever du soleil
    await HomeWidget.saveWidgetData<String>('sunrise_time', fmt.format(prayerTime.sunrise));

    // Date hijri
    final hijri = HijriCalendar.now();
    await HomeWidget.saveWidgetData<String>(
      'hijri_date',
      '${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear}',
    );

    // Fenêtre de la prière en cours (pour la barre tricolore)
    final current = _currentPrayerWindow(prayerTime);
    await HomeWidget.saveWidgetData<String>('current_prayer_name', current?.name ?? '');
    await HomeWidget.saveWidgetData<String>(
      'prayer_window_start_ms',
      (current?.windowStart.millisecondsSinceEpoch ?? 0).toString(),
    );
    await HomeWidget.saveWidgetData<String>(
      'prayer_window_end_ms',
      (current?.windowEnd.millisecondsSinceEpoch ?? 0).toString(),
    );

    await HomeWidget.updateWidget(androidName: _androidName,     iOSName: _iosName);
    await HomeWidget.updateWidget(androidName: _androidNameMini, iOSName: _iosName);
  }

  Future<void> updateQada({
    required QadaProgress progress,
    required Map<PrayerName, int> todayCounts,
  }) async {
    await HomeWidget.saveWidgetData<int>('qada_has_program',  progress.totalPrayersOwed > 0 ? 1 : 0);
    await HomeWidget.saveWidgetData<int>('qada_daily_target', progress.dailyTargetPrayers);
    await HomeWidget.saveWidgetData<int>('qada_streak',       progress.currentStreak);
    await HomeWidget.saveWidgetData<int>('qada_remaining',    progress.remaining);

    final todayTotal = todayCounts.values.fold(0, (a, b) => a + b);
    await HomeWidget.saveWidgetData<int>('qada_today_total',   todayTotal);
    await HomeWidget.saveWidgetData<int>('qada_today_fajr',    todayCounts[PrayerName.fajr]    ?? 0);
    await HomeWidget.saveWidgetData<int>('qada_today_dhuhr',   todayCounts[PrayerName.dhuhr]   ?? 0);
    await HomeWidget.saveWidgetData<int>('qada_today_asr',     todayCounts[PrayerName.asr]     ?? 0);
    await HomeWidget.saveWidgetData<int>('qada_today_maghrib', todayCounts[PrayerName.maghrib] ?? 0);
    await HomeWidget.saveWidgetData<int>('qada_today_isha',    todayCounts[PrayerName.isha]    ?? 0);

    // Restant par prière (totalDaysOwed - done par type)
    final daysOwed = progress.totalDaysOwed;
    for (final name in PrayerName.values) {
      final done = progress.prayersDoneByName[name] ?? 0;
      final rem  = (daysOwed - done).clamp(0, daysOwed);
      await HomeWidget.saveWidgetData<int>('qada_rem_${name.name}', rem);
    }

    await HomeWidget.updateWidget(androidName: _androidNameQada, iOSName: _iosName);
  }

  /// Retourne la fenêtre horaire de la prière actuellement active, null si aucune.
  ({String name, DateTime windowStart, DateTime windowEnd})? _currentPrayerWindow(
    PrayerTime times,
  ) {
    final now = DateTime.now();
    final windows = [
      (name: 'Fajr',    start: times.fajr,    end: times.sunrise),
      (name: 'Dhuhr',   start: times.dhuhr,   end: times.asr),
      (name: 'Asr',     start: times.asr,     end: times.maghrib),
      (name: 'Maghrib', start: times.maghrib, end: times.isha),
      (name: 'Isha',    start: times.isha,    end: times.isha.add(const Duration(hours: 3))),
    ];
    for (final w in windows) {
      if (now.isAfter(w.start) && now.isBefore(w.end)) {
        return (name: w.name, windowStart: w.start, windowEnd: w.end);
      }
    }
    return null;
  }
}
