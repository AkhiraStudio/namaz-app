import 'package:equatable/equatable.dart';

enum TimeFormat { fr24h, en12h }

enum PrayerAlertType { adhan, vibration }

class PrayerCalcMethod {
  final int apiIndex;
  final String name;
  final String region;
  const PrayerCalcMethod({required this.apiIndex, required this.name, required this.region});
}

const List<PrayerCalcMethod> kPrayerCalcMethods = [
  PrayerCalcMethod(apiIndex: 12, name: 'Union des Mosquées de France', region: '🇫🇷 France'),
  PrayerCalcMethod(apiIndex: 3,  name: 'Muslim World League',          region: '🌍 Europe'),
  PrayerCalcMethod(apiIndex: 2,  name: 'ISNA',                         region: '🇺🇸 Amérique du Nord'),
  PrayerCalcMethod(apiIndex: 4,  name: 'Umm Al-Qura',                  region: '🇸🇦 Arabie Saoudite'),
  PrayerCalcMethod(apiIndex: 5,  name: 'Autorité Égyptienne',          region: '🇪🇬 Égypte'),
  PrayerCalcMethod(apiIndex: 13, name: 'Diyanet',                      region: '🇹🇷 Turquie'),
  PrayerCalcMethod(apiIndex: 1,  name: 'Karachi',                      region: '🇵🇰 Asie du Sud'),
];

class AppSettings extends Equatable {
  final String languageCode;
  final TimeFormat timeFormat;
  final bool travelerMode;
  final bool darkMode;
  final int mensCycleDays;
  final int mensDurationDays;
  final bool prayerNotifEnabled;
  final bool qadaNotifEnabled;
  final PrayerAlertType prayerAlertType;
  final bool showSunnahPrayers;
  final int qadaMorningHour;
  final int qadaEveningHour;
  final bool showStreak;
  final int calculationMethod;    // Aladhan API method index
  final int globalOffsetMinutes;  // décalage global (toutes prières)
  final int fajrOffsetMinutes;
  final int dhuhrOffsetMinutes;
  final int asrOffsetMinutes;
  final int maghribOffsetMinutes;
  final int ishaOffsetMinutes;

  const AppSettings({
    this.languageCode = 'fr',
    this.timeFormat = TimeFormat.fr24h,
    this.travelerMode = false,
    this.darkMode = false,
    this.mensCycleDays = 28,
    this.mensDurationDays = 7,
    this.prayerNotifEnabled = true,
    this.qadaNotifEnabled = true,
    this.prayerAlertType = PrayerAlertType.adhan,
    this.showSunnahPrayers = false,
    this.qadaMorningHour = 9,
    this.qadaEveningHour = 20,
    this.showStreak = true,
    this.calculationMethod = 12,  // UOIF — France par défaut
    this.globalOffsetMinutes = 0,
    this.fajrOffsetMinutes = 0,
    this.dhuhrOffsetMinutes = 0,
    this.asrOffsetMinutes = 0,
    this.maghribOffsetMinutes = 0,
    this.ishaOffsetMinutes = 0,
  });

  AppSettings copyWith({
    String? languageCode,
    TimeFormat? timeFormat,
    bool? travelerMode,
    bool? darkMode,
    int? mensCycleDays,
    int? mensDurationDays,
    bool? prayerNotifEnabled,
    bool? qadaNotifEnabled,
    PrayerAlertType? prayerAlertType,
    bool? showSunnahPrayers,
    int? qadaMorningHour,
    int? qadaEveningHour,
    bool? showStreak,
    int? calculationMethod,
    int? globalOffsetMinutes,
    int? fajrOffsetMinutes,
    int? dhuhrOffsetMinutes,
    int? asrOffsetMinutes,
    int? maghribOffsetMinutes,
    int? ishaOffsetMinutes,
  }) {
    return AppSettings(
      languageCode: languageCode ?? this.languageCode,
      timeFormat: timeFormat ?? this.timeFormat,
      travelerMode: travelerMode ?? this.travelerMode,
      darkMode: darkMode ?? this.darkMode,
      mensCycleDays: mensCycleDays ?? this.mensCycleDays,
      mensDurationDays: mensDurationDays ?? this.mensDurationDays,
      prayerNotifEnabled: prayerNotifEnabled ?? this.prayerNotifEnabled,
      qadaNotifEnabled: qadaNotifEnabled ?? this.qadaNotifEnabled,
      prayerAlertType: prayerAlertType ?? this.prayerAlertType,
      showSunnahPrayers: showSunnahPrayers ?? this.showSunnahPrayers,
      qadaMorningHour: qadaMorningHour ?? this.qadaMorningHour,
      qadaEveningHour: qadaEveningHour ?? this.qadaEveningHour,
      showStreak: showStreak ?? this.showStreak,
      calculationMethod: calculationMethod ?? this.calculationMethod,
      globalOffsetMinutes: globalOffsetMinutes ?? this.globalOffsetMinutes,
      fajrOffsetMinutes: fajrOffsetMinutes ?? this.fajrOffsetMinutes,
      dhuhrOffsetMinutes: dhuhrOffsetMinutes ?? this.dhuhrOffsetMinutes,
      asrOffsetMinutes: asrOffsetMinutes ?? this.asrOffsetMinutes,
      maghribOffsetMinutes: maghribOffsetMinutes ?? this.maghribOffsetMinutes,
      ishaOffsetMinutes: ishaOffsetMinutes ?? this.ishaOffsetMinutes,
    );
  }

  @override
  List<Object?> get props => [
        languageCode, timeFormat, travelerMode,
        darkMode, mensCycleDays, mensDurationDays,
        prayerNotifEnabled, qadaNotifEnabled, prayerAlertType,
        showSunnahPrayers, qadaMorningHour, qadaEveningHour,
        showStreak, calculationMethod, globalOffsetMinutes,
        fajrOffsetMinutes, dhuhrOffsetMinutes, asrOffsetMinutes,
        maghribOffsetMinutes, ishaOffsetMinutes,
      ];
}
