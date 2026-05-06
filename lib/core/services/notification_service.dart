import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../shared/extensions/datetime_extensions.dart';

/// Service de notifications locales.
class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  // ── IDs ────────────────────────────────────────────────────────────────────
  static const int _nightThirdId = 1001;
  // Wudu (15 min avant adhan) : 2001–2005
  static const int _wuduBase = 2001;
  // Adhan : 3001–3005
  static const int _adhanBase = 3001;
  // Qada : 4001 (matin), 4002 (soir)
  static const int _qadaMorningId = 4001;
  static const int _qadaEveningId = 4002;

  // ── Canaux Android ─────────────────────────────────────────────────────────
  static const _nightThirdChannel = AndroidNotificationDetails(
    'night_third_channel',
    'Tiers de nuit',
    channelDescription: 'Rappel pour le 3ème tiers de la nuit (Tahajjud)',
    importance: Importance.high,
    priority: Priority.high,
    playSound: true,
    enableVibration: true,
    icon: '@mipmap/ic_launcher',
  );

  static const _wuduChannel = AndroidNotificationDetails(
    'prayer_wudu_channel',
    'Rappel Ablutions',
    channelDescription: 'Rappel 15 min avant chaque prière pour les ablutions',
    importance: Importance.high,
    priority: Priority.high,
    playSound: true,
    enableVibration: true,
    icon: '@mipmap/ic_launcher',
  );

  /// Canal adhan avec son (fichier adhan.mp3 dans android/app/src/main/res/raw/).
  static const _adhanSoundChannel = AndroidNotificationDetails(
    'prayer_adhan_sound_channel',
    'Adhan — Son',
    channelDescription: "Son de l'adhan à l'heure de la prière",
    importance: Importance.max,
    priority: Priority.max,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('adhan'),
    enableVibration: false,
    icon: '@mipmap/ic_launcher',
  );

  /// Canal adhan sans son, vibration uniquement.
  static const _adhanVibrationChannel = AndroidNotificationDetails(
    'prayer_adhan_vibration_channel',
    'Adhan — Vibration',
    channelDescription: 'Vibration à l\'heure de la prière',
    importance: Importance.max,
    priority: Priority.max,
    playSound: false,
    enableVibration: true,
    icon: '@mipmap/ic_launcher',
  );

  static const _qadaChannel = AndroidNotificationDetails(
    'qada_reminder_channel',
    'Rappel Rattrapage',
    channelDescription: 'Rappels quotidiens pour le programme de rattrapage',
    importance: Importance.high,
    priority: Priority.high,
    playSound: true,
    enableVibration: true,
    icon: '@mipmap/ic_launcher',
  );

  // ── Canaux iOS ─────────────────────────────────────────────────────────────
  static const _iosDefault = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  static const _iosAdhanSound = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
    sound: 'adhan.mp3',
  );

  // ── Init ───────────────────────────────────────────────────────────────────
  static Future<void> init() async {
    if (_initialized) return;
    tz.initializeTimeZones();
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(initSettings);
    _initialized = true;
  }

  /// Demande la permission de notifications (Android 13+ et iOS).
  static Future<bool> requestPermission() async {
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final iosImpl = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    if (androidImpl != null) {
      return await androidImpl.requestNotificationsPermission() ?? false;
    }
    if (iosImpl != null) {
      return await iosImpl.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }
    return false;
  }

  // ── Tiers de nuit ──────────────────────────────────────────────────────────

  static Future<void> scheduleNightThirdAlarm(DateTime time) async {
    await init();
    await requestPermission();
    final now = DateTime.now();
    if (time.isBefore(now)) return;
    final scheduledDate = tz.TZDateTime.from(time, tz.local);
    await _plugin.zonedSchedule(
      _nightThirdId,
      '🌙 3ème tiers de la nuit',
      'Lèves-toi pour le meilleur moment de la nuit — ${time.timeHHmm}',
      scheduledDate,
      const NotificationDetails(android: _nightThirdChannel, iOS: _iosDefault),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelNightThirdAlarm() async {
    await init();
    await _plugin.cancel(_nightThirdId);
  }

  static Future<bool> isNightThirdScheduled() async {
    await init();
    final pending = await _plugin.pendingNotificationRequests();
    return pending.any((n) => n.id == _nightThirdId);
  }

  // ── Notifications de prière ────────────────────────────────────────────────

  /// Programme un rappel wudu 15 min avant l'adhan.
  static Future<void> scheduleWuduReminder(
      DateTime time, String prayerName, int index) async {
    await init();
    if (time.isBefore(DateTime.now())) return;
    final scheduledDate = tz.TZDateTime.from(time, tz.local);
    await _plugin.zonedSchedule(
      _wuduBase + index,
      '🕐 $prayerName dans 15 min',
      'Il est temps de faire les ablutions ✨',
      scheduledDate,
      const NotificationDetails(android: _wuduChannel, iOS: _iosDefault),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Programme la notification à l'heure de l'adhan.
  /// [useAdhanSound] : true = son adhan, false = vibration uniquement.
  static Future<void> scheduleAdhanNotification(
      DateTime time, String prayerName, int index,
      {bool useAdhanSound = true}) async {
    await init();
    if (time.isBefore(DateTime.now())) return;
    final scheduledDate = tz.TZDateTime.from(time, tz.local);
    final channel = useAdhanSound ? _adhanSoundChannel : _adhanVibrationChannel;
    await _plugin.zonedSchedule(
      _adhanBase + index,
      '🕌 Le $prayerName sonne !',
      'Prie dans le vert',
      scheduledDate,
      NotificationDetails(
        android: channel,
        iOS: useAdhanSound ? _iosAdhanSound : _iosDefault,
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Annule toutes les notifications de prière (wudu + adhan).
  static Future<void> cancelPrayerNotifications() async {
    await init();
    for (int i = 0; i < 5; i++) {
      await _plugin.cancel(_wuduBase + i);
      await _plugin.cancel(_adhanBase + i);
    }
  }

  // ── Notifications de rattrapage ────────────────────────────────────────────

  /// Programme le rappel matinal avec l'objectif du jour.
  static Future<void> scheduleQadaMorningReminder(int dailyTarget,
      {int hour = 9}) async {
    await init();
    final now = DateTime.now();
    var morning = DateTime(now.year, now.month, now.day, hour, 0);
    if (morning.isBefore(now)) {
      morning = morning.add(const Duration(days: 1));
    }
    final scheduledDate = tz.TZDateTime.from(morning, tz.local);
    await _plugin.zonedSchedule(
      _qadaMorningId,
      '📿 Objectif de rattrapage du jour',
      'Rappel : $dailyTarget prière${dailyTarget > 1 ? 's' : ''} à rattraper aujourd\'hui. Chaque prière compte !',
      scheduledDate,
      const NotificationDetails(android: _qadaChannel, iOS: _iosDefault),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Programme le rappel du soir selon l'avancement du jour.
  /// [todayRemaining] = prières restantes pour atteindre l'objectif aujourd'hui.
  static Future<void> scheduleQadaEveningReminder({
    required int todayRemaining,
    required int dailyTarget,
    int hour = 20,
  }) async {
    await init();
    final now = DateTime.now();
    final evening = DateTime(now.year, now.month, now.day, hour, 0);
    if (evening.isBefore(now)) return; // trop tard, reschedulé demain au lancement

    final isDone = todayRemaining <= 0;
    final title = isDone ? '🌟 Objectif du jour atteint !' : '📿 Rattrapage du soir';
    final body = isDone
        ? 'Félicitations ! Tu as rattrapé tes $dailyTarget prières aujourd\'hui. Continue sur ta lancée !'
        : 'Il te reste $todayRemaining prière${todayRemaining > 1 ? 's' : ''} à rattraper. Tu peux le faire !';

    final scheduledDate = tz.TZDateTime.from(evening, tz.local);
    await _plugin.zonedSchedule(
      _qadaEveningId,
      title,
      body,
      scheduledDate,
      const NotificationDetails(android: _qadaChannel, iOS: _iosDefault),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Annule les notifications de rattrapage.
  static Future<void> cancelQadaNotifications() async {
    await init();
    await _plugin.cancel(_qadaMorningId);
    await _plugin.cancel(_qadaEveningId);
  }

}
