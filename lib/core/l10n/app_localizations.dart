import 'package:flutter/material.dart';
import 'generated/app_localizations.dart';

export 'generated/app_localizations.dart';

/// Configuration de la localisation — 7 langues supportées.
class AppLocalizationsSetup {
  AppLocalizationsSetup._();

  static const List<Locale> supportedLocales = [
    Locale('fr'), // Français
    Locale('en'), // Anglais
    Locale('ar'), // Arabe
    Locale('zh'), // Mandarin
    Locale('de'), // Allemand
    Locale('es'), // Espagnol
    Locale('it'), // Italien
  ];

  static const Locale defaultLocale = Locale('fr');

  /// Retourne true si la langue est écrite de droite à gauche.
  static bool isRtl(String languageCode) => languageCode == 'ar';
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
