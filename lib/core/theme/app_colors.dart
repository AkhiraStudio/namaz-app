import 'package:flutter/material.dart';

/// Palette de couleurs de l'application Namaz App.
/// Style : Minimalisme Premium — fond crème/beige, violet profond, touches dorées.
class AppColors {
  AppColors._();

  // ── Couleurs primaires ──────────────────────────────────────────────────────
  static const Color deepPurple = Color(0xFF2E1A47);
  static const Color mediumPurple = Color(0xFF6E618E);
  static const Color lightPurple = Color(0xFFB8A9D4);

  // ── Couleurs d'accentuation ─────────────────────────────────────────────────
  static const Color gold = Color(0xFFD4A843);
  static const Color goldLight = Color(0xFFF0D080);

  // ── Fond clair (mode jour) ─────────────────────────────────────────────────
  static const Color creamBackground = Color(0xFFFAF6F0);
  static const Color beigeBackground = Color(0xFFF5EFE4);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // ── Fond sombre (mode nuit) ────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF1A0F2E);
  static const Color darkSurface = Color(0xFF2A1A42);
  static const Color darkCard = Color(0xFF3D2A5C);

  // ── Statuts prière ──────────────────────────────────────────────────────────
  static const Color prayerEarly = Color.fromARGB(255, 107, 175, 109);   // Vert  — Prié tôt
  static const Color prayerOnTime = Color.fromARGB(255, 219, 136, 10);  // Orange — Prié à l'heure
  static const Color prayerLate = Color.fromARGB(255, 194, 88, 80);    // Rouge  — Prié tard
  static const Color prayerMissed = Color(0xFF212121);  // Noir   — Prière manquée
  static const Color prayerMenstruation = Color.fromARGB(255, 194, 93, 127); // Rose — Menstrues (féminin)

  // ── Mode Solaire ────────────────────────────────────────────────────────────
  static const Color solarFajr = Color(0xFFFFE0B2);      // Crème chaud
  static const Color solarMorning = Color(0xFFFFF8E1);   // Jaune pâle
  static const Color solarDhuhr = Color(0xFFE3F2FD);     // Bleu ciel
  static const Color solarAfternoon = Color(0xFFFFF3E0); // Orange doux
  static const Color solarMaghrib = Color(0xFFEDE7F6);   // Violet rosé
  static const Color solarIsha = Color(0xFF311B92);       // Violet profond
  static const Color solarNight = Color(0xFF1A0F2E);     // Nuit

  // ── Textes ──────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A0F2E);
  static const Color textSecondary = Color(0xFF6E618E);
  static const Color textLight = Color(0xFF9E9E9E);
  static const Color textOnDark = Color(0xFFFAF6F0);

  // ── Dividers & Borders ──────────────────────────────────────────────────────
  static const Color divider = Color(0xFFE0D8F0);
  static const Color border = Color(0xFFD0C8E8);

  // ── Couleurs d'identité par prière ─────────────────────────────────────────
  static const Map<String, Color> prayerAccentColors = {
    'Fajr'    : Color(0xFF2E3F7A),
    'Dhuhr'   : Color(0xFFB89A5E),
    'Asr'     : Color(0xFFB87050),
    'Maghrib' : Color(0xFF7A3F6A),
    'Isha'    : Color(0xFF2E1F50),
  };

  static Color prayerAccent(String prayerName) =>
      prayerAccentColors[prayerName] ?? mediumPurple;
}
