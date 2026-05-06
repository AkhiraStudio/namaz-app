/// Noms et chemins de toutes les routes de l'application.
class RouteNames {
  RouteNames._();

  static const String login = 'login';
  static const String splash = 'splash';
  static const String onboarding = 'onboarding';
  static const String profileSetup = 'profile-setup';
  static const String mosqueSelection = 'mosque-selection';

  // Shell routes (bottom nav)
  static const String home = 'home';
  static const String prayer = 'prayer';
  static const String qada = 'qada';
  static const String qibla = 'qibla';
  static const String settings = 'settings';

  // Sub-routes
  static const String profile = 'profile';
  static const String prayerDetail = 'prayer-detail';
  static const String adhkar = 'adhkar';
  static const String statistics = 'statistics';
  static const String qadaCalculator = 'qada-calculator';
  static const String qadaStats = 'qada-stats';

  // Premium
  static const String paywall = 'paywall';
}

/// Chemins URL des routes.
class RoutePaths {
  RoutePaths._();

  static const String login = '/login';
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String profileSetup = '/profile-setup';
  static const String mosqueSelection = '/mosque-selection';

  static const String home = '/home';
  static const String prayer = '/home/prayer';
  static const String qada = '/home/qada';
  static const String qibla = '/home/qibla';
  static const String settings = '/home/settings';

  static const String prayerDetail = '/home/prayer/:id';
  static const String adhkar = '/home/prayer/adhkar/:type';
  static const String statistics = '/home/prayer/statistics';
  static const String qadaCalculator = '/home/qada/calculator';
  static const String qadaStats = '/home/qada/stats';

  // Premium
  static const String paywall = '/paywall';
}
