import 'package:equatable/equatable.dart';

/// Les 5 prières quotidiennes + Sunrise pour les calculs.
class PrayerTime extends Equatable {
  final DateTime date;
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;

  const PrayerTime({
    required this.date,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  /// Début du 2ème tiers (= fin du 1er tiers).
  DateTime secondThirdOfNight(DateTime fajrNextDay) {
    final nightDuration = fajrNextDay.difference(isha);
    return isha.add(nightDuration ~/ 3);
  }

  /// Début du 3ème tiers (= fin du 2ème tiers). Appelé aussi lastThirdOfNight.
  DateTime lastThirdOfNight(DateTime fajrNextDay) {
    final nightDuration = fajrNextDay.difference(isha);
    return isha.add(nightDuration * 2 ~/ 3);
  }

  /// Applique les décalages (global + par prière) et retourne un nouveau PrayerTime.
  PrayerTime withOffsets({
    int globalMinutes = 0,
    int fajrMinutes = 0,
    int dhuhrMinutes = 0,
    int asrMinutes = 0,
    int maghribMinutes = 0,
    int ishaMinutes = 0,
  }) {
    Duration d(int extra) => Duration(minutes: globalMinutes + extra);
    return PrayerTime(
      date: date,
      fajr: fajr.add(d(fajrMinutes)),
      sunrise: sunrise,
      dhuhr: dhuhr.add(d(dhuhrMinutes)),
      asr: asr.add(d(asrMinutes)),
      maghrib: maghrib.add(d(maghribMinutes)),
      isha: isha.add(d(ishaMinutes)),
    );
  }

  /// Retourne la liste ordonnée [name, time] des 5 prières.
  List<MapEntry<String, DateTime>> get orderedPrayers => [
        MapEntry('Fajr', fajr),
        MapEntry('Dhuhr', dhuhr),
        MapEntry('Asr', asr),
        MapEntry('Maghrib', maghrib),
        MapEntry('Isha', isha),
      ];

  @override
  List<Object?> get props =>
      [date, fajr, sunrise, dhuhr, asr, maghrib, isha];
}
