import 'package:hive/hive.dart';
import '../../../../core/constants/hive_keys.dart';
import '../../domain/entities/app_settings.dart';

part 'settings_model.g.dart';

@HiveType(typeId: HiveTypeIds.settingsModel)
class SettingsModel extends HiveObject {
  @HiveField(0) late String languageCode;
  @HiveField(1) late int timeFormatIndex;
  @HiveField(2) late bool travelerMode;
  @HiveField(3) late bool darkMode;
  @HiveField(4) late int mensCycleDays;
  @HiveField(5) late int mensDurationDays;
  @HiveField(6) bool? prayerNotifEnabled;
  @HiveField(7) bool? qadaNotifEnabled;
  @HiveField(8) int? prayerAlertTypeIndex;
  @HiveField(9) bool? showSunnahPrayers;
  @HiveField(10) int? qadaMorningHour;
  @HiveField(11) int? qadaEveningHour;
  @HiveField(12) bool? showStreak;
  @HiveField(13) int? calculationMethodIndex;
  @HiveField(14) int? globalOffsetMinutes;
  @HiveField(15) int? fajrOffsetMinutes;
  @HiveField(16) int? dhuhrOffsetMinutes;
  @HiveField(17) int? asrOffsetMinutes;
  @HiveField(18) int? maghribOffsetMinutes;
  @HiveField(19) int? ishaOffsetMinutes;

  SettingsModel({
    required this.languageCode,
    required this.timeFormatIndex,
    required this.travelerMode,
    required this.darkMode,
    required this.mensCycleDays,
    required this.mensDurationDays,
    this.prayerNotifEnabled,
    this.qadaNotifEnabled,
    this.prayerAlertTypeIndex,
    this.showSunnahPrayers,
    this.qadaMorningHour,
    this.qadaEveningHour,
    this.showStreak,
    this.calculationMethodIndex,
    this.globalOffsetMinutes,
    this.fajrOffsetMinutes,
    this.dhuhrOffsetMinutes,
    this.asrOffsetMinutes,
    this.maghribOffsetMinutes,
    this.ishaOffsetMinutes,
  });

  factory SettingsModel.fromEntity(AppSettings e) => SettingsModel(
        languageCode: e.languageCode,
        timeFormatIndex: e.timeFormat.index,
        travelerMode: e.travelerMode,
        darkMode: e.darkMode,
        mensCycleDays: e.mensCycleDays,
        mensDurationDays: e.mensDurationDays,
        prayerNotifEnabled: e.prayerNotifEnabled,
        qadaNotifEnabled: e.qadaNotifEnabled,
        prayerAlertTypeIndex: e.prayerAlertType.index,
        showSunnahPrayers: e.showSunnahPrayers,
        qadaMorningHour: e.qadaMorningHour,
        qadaEveningHour: e.qadaEveningHour,
        showStreak: e.showStreak,
        calculationMethodIndex: e.calculationMethod,
        globalOffsetMinutes: e.globalOffsetMinutes,
        fajrOffsetMinutes: e.fajrOffsetMinutes,
        dhuhrOffsetMinutes: e.dhuhrOffsetMinutes,
        asrOffsetMinutes: e.asrOffsetMinutes,
        maghribOffsetMinutes: e.maghribOffsetMinutes,
        ishaOffsetMinutes: e.ishaOffsetMinutes,
      );

  static T _safeEnum<T>(List<T> values, int index, T fallback) =>
      (index >= 0 && index < values.length) ? values[index] : fallback;

  AppSettings toEntity() => AppSettings(
        languageCode: languageCode,
        timeFormat: _safeEnum(TimeFormat.values, timeFormatIndex, TimeFormat.fr24h),
        travelerMode: travelerMode,
        darkMode: darkMode,
        mensCycleDays: mensCycleDays,
        mensDurationDays: mensDurationDays,
        prayerNotifEnabled: prayerNotifEnabled ?? true,
        qadaNotifEnabled: qadaNotifEnabled ?? true,
        prayerAlertType: _safeEnum(
            PrayerAlertType.values, prayerAlertTypeIndex ?? 0, PrayerAlertType.adhan),
        showSunnahPrayers: showSunnahPrayers ?? false,
        qadaMorningHour: qadaMorningHour ?? 9,
        qadaEveningHour: qadaEveningHour ?? 20,
        showStreak: showStreak ?? true,
        calculationMethod: calculationMethodIndex ?? 12,
        globalOffsetMinutes: globalOffsetMinutes ?? 0,
        fajrOffsetMinutes: fajrOffsetMinutes ?? 0,
        dhuhrOffsetMinutes: dhuhrOffsetMinutes ?? 0,
        asrOffsetMinutes: asrOffsetMinutes ?? 0,
        maghribOffsetMinutes: maghribOffsetMinutes ?? 0,
        ishaOffsetMinutes: ishaOffsetMinutes ?? 0,
      );
}
