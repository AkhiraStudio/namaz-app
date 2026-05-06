import 'prayer_record.dart';

enum SunnahPrayer {
  // ── Fajr ──────────────────────────────────────────────────────────────────
  fajrRawatib,          // 2r avant Fajr

  // ── Dhuhr — Rawatib avant ─────────────────────────────────────────────────
  dhuhrRawatibBefore1,  // 2r avant Dhuhr
  dhuhrRawatibBefore2,  // 2r avant Dhuhr

  // ── Dhuhr — Duha ──────────────────────────────────────────────────────────
  duha1, duha2, duha3, duha4, // 4×2r avant Dhuhr

  // ── Dhuhr — Rawatib après ─────────────────────────────────────────────────
  dhuhrRawatibAfter,    // 2r après Dhuhr

  // ── Maghrib ───────────────────────────────────────────────────────────────
  maghribRawatib,       // 2r après Maghrib

  // ── Isha ──────────────────────────────────────────────────────────────────
  ishaRawatib,          // 2r après Isha
  shif3,                // 2r après Isha (Shif3)
  witr,                 // Witr (fin de journée)
}

/// Définition statique d'une prière surérogatoire.
class SunnahDef {
  final SunnahPrayer prayer;
  final String label;
  final String rakaat;          // ex: "2 raka'at"
  final PrayerName linkedPrayer;
  final String groupLabel;       // "Rawatib avant", "Duha", etc.

  const SunnahDef({
    required this.prayer,
    required this.label,
    required this.rakaat,
    required this.linkedPrayer,
    required this.groupLabel,
  });
}

/// Toutes les définitions, dans l'ordre d'affichage.
const List<SunnahDef> kSunnahDefs = [
  // Fajr
  SunnahDef(
    prayer: SunnahPrayer.fajrRawatib,
    label: 'Sunnah Fajr',
    rakaat: "2 raka'at",
    linkedPrayer: PrayerName.fajr,
    groupLabel: 'Rawatib avant',
  ),

  // Dhuhr — rawatib avant
  SunnahDef(
    prayer: SunnahPrayer.dhuhrRawatibBefore1,
    label: 'Rawatib avant',
    rakaat: "2 raka'at",
    linkedPrayer: PrayerName.dhuhr,
    groupLabel: 'Rawatib avant',
  ),
  SunnahDef(
    prayer: SunnahPrayer.dhuhrRawatibBefore2,
    label: 'Rawatib avant',
    rakaat: "2 raka'at",
    linkedPrayer: PrayerName.dhuhr,
    groupLabel: 'Rawatib avant',
  ),

  // Dhuhr — Duha
  SunnahDef(
    prayer: SunnahPrayer.duha1,
    label: 'Duha',
    rakaat: "2 raka'at",
    linkedPrayer: PrayerName.dhuhr,
    groupLabel: 'Duha',
  ),
  SunnahDef(
    prayer: SunnahPrayer.duha2,
    label: 'Duha',
    rakaat: "2 raka'at",
    linkedPrayer: PrayerName.dhuhr,
    groupLabel: 'Duha',
  ),
  SunnahDef(
    prayer: SunnahPrayer.duha3,
    label: 'Duha',
    rakaat: "2 raka'at",
    linkedPrayer: PrayerName.dhuhr,
    groupLabel: 'Duha',
  ),
  SunnahDef(
    prayer: SunnahPrayer.duha4,
    label: 'Duha',
    rakaat: "2 raka'at",
    linkedPrayer: PrayerName.dhuhr,
    groupLabel: 'Duha',
  ),

  // Dhuhr — rawatib après
  SunnahDef(
    prayer: SunnahPrayer.dhuhrRawatibAfter,
    label: 'Rawatib après',
    rakaat: "2 raka'at",
    linkedPrayer: PrayerName.dhuhr,
    groupLabel: 'Rawatib après',
  ),

  // Maghrib
  SunnahDef(
    prayer: SunnahPrayer.maghribRawatib,
    label: 'Sunnah Maghrib',
    rakaat: "2 raka'at",
    linkedPrayer: PrayerName.maghrib,
    groupLabel: 'Rawatib après',
  ),

  // Isha
  SunnahDef(
    prayer: SunnahPrayer.ishaRawatib,
    label: 'Sunnah Isha',
    rakaat: "2 raka'at",
    linkedPrayer: PrayerName.isha,
    groupLabel: 'Rawatib après',
  ),
  SunnahDef(
    prayer: SunnahPrayer.shif3,
    label: 'Shif3',
    rakaat: "2 raka'at",
    linkedPrayer: PrayerName.isha,
    groupLabel: 'Shif3 & Witr',
  ),
  SunnahDef(
    prayer: SunnahPrayer.witr,
    label: 'Witr',
    rakaat: '1 raka\'at',
    linkedPrayer: PrayerName.isha,
    groupLabel: 'Shif3 & Witr',
  ),
];

/// Retourne les définitions groupées pour une prière obligatoire donnée.
Map<String, List<SunnahDef>> sunnahGroupsForPrayer(PrayerName prayer) {
  final filtered = kSunnahDefs.where((d) => d.linkedPrayer == prayer);
  final groups = <String, List<SunnahDef>>{};
  for (final def in filtered) {
    groups.putIfAbsent(def.groupLabel, () => []).add(def);
  }
  return groups;
}
