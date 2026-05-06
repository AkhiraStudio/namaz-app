import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'route_names.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/onboarding/presentation/providers/profile_provider.dart';
import '../../features/onboarding/presentation/screens/splash_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/onboarding/presentation/screens/profile_setup_screen.dart';
import '../../features/prayer/presentation/screens/home_screen.dart';
import '../../features/prayer/presentation/screens/prayer_detail_screen.dart';
import '../../features/prayer/presentation/screens/adhkar_screen.dart';
import '../../features/prayer/presentation/screens/statistics_screen.dart';
import '../../features/qada/presentation/screens/qada_screen.dart';
import '../../features/qada/presentation/screens/qada_calculator_screen.dart';
import '../../features/qada/presentation/screens/qada_stats_screen.dart';
import '../../features/qibla/presentation/screens/qibla_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/onboarding/presentation/screens/profile_screen.dart';
import '../../shared/widgets/app_bottom_nav_bar.dart';
import '../../features/premium/presentation/providers/premium_provider.dart';
import '../../features/premium/presentation/screens/paywall_screen.dart';

// ── Router notifier (écoute l'auth state pour forcer le redirect) ─────────────

class _RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  _RouterNotifier(this._ref) {
    _ref.listen(authStateProvider, (_, __) => notifyListeners());
    _ref.listen(isPremiumProvider, (_, __) => notifyListeners());
    _ref.listen(profileProvider, (_, __) => notifyListeners());
  }
}

// ── Provider GoRouter ─────────────────────────────────────────────────────────

final goRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);

  return GoRouter(
    initialLocation: RoutePaths.splash,
    refreshListenable: notifier,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final authAsync = ref.read(authStateProvider);
      final isAuthenticated = authAsync.valueOrNull != null;
      final isOnLoginPage = state.matchedLocation == RoutePaths.login;

      // Auth non encore chargé — on ne redirige pas
      if (authAsync.isLoading) return null;

      if (!isAuthenticated && !isOnLoginPage) return RoutePaths.login;
      if (isAuthenticated && isOnLoginPage) return RoutePaths.splash;

      // Si le profil est déjà complet, on saute l'onboarding
      final profile = ref.read(profileProvider).valueOrNull;
      final onboardingDone = profile?.onboardingComplete ?? false;
      final loc = state.matchedLocation;
      if (onboardingDone &&
          (loc == RoutePaths.onboarding || loc == RoutePaths.profileSetup)) {
        return RoutePaths.home;
      }

      // Redirects premium — routes accessibles uniquement avec un abonnement actif
      final isPremium = ref.read(isPremiumProvider);
      if (!isPremium) {
        if (loc == '/home/statistics') {
          return '${RoutePaths.paywall}?from=${Uri.encodeComponent(loc)}';
        }
        if (loc.startsWith('/home/adhkar/')) {
          return '${RoutePaths.paywall}?from=${Uri.encodeComponent(loc)}';
        }
        if (loc == '/home/qada/stats') {
          return '${RoutePaths.paywall}?from=${Uri.encodeComponent(loc)}';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RoutePaths.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePaths.onboarding,
        name: RouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: RoutePaths.profileSetup,
        name: RouteNames.profileSetup,
        builder: (context, state) => const ProfileSetupScreen(),
      ),

      // Paywall — hors ShellRoute (pas de bottom nav)
      GoRoute(
        path: RoutePaths.paywall,
        name: RouteNames.paywall,
        builder: (context, state) => const PaywallScreen(),
      ),

      // Shell route avec bottom navigation bar
      ShellRoute(
        builder: (context, state, child) => AppShellScaffold(child: child),
        routes: [
          GoRoute(
            path: RoutePaths.home,
            name: RouteNames.home,
            builder: (context, state) => const HomeScreen(),
            routes: [
              GoRoute(
                path: 'prayer/:id',
                name: RouteNames.prayerDetail,
                builder: (context, state) {
                  final prayerId = state.pathParameters['id'] ?? '';
                  return PrayerDetailScreen(prayerId: prayerId);
                },
              ),
              GoRoute(
                path: 'adhkar/:type',
                name: RouteNames.adhkar,
                builder: (context, state) {
                  final type = state.pathParameters['type'] ?? 'morning';
                  return AdhkarScreen(type: type);
                },
              ),
              GoRoute(
                path: 'statistics',
                name: RouteNames.statistics,
                builder: (context, state) => const StatisticsScreen(),
              ),
            ],
          ),
          GoRoute(
            path: RoutePaths.qada,
            name: RouteNames.qada,
            builder: (context, state) => const QadaScreen(),
            routes: [
              GoRoute(
                path: 'calculator',
                name: RouteNames.qadaCalculator,
                builder: (context, state) => const QadaCalculatorScreen(),
              ),
              GoRoute(
                path: 'stats',
                name: RouteNames.qadaStats,
                builder: (context, state) => const QadaStatsScreen(),
              ),
            ],
          ),
          GoRoute(
            path: RoutePaths.qibla,
            name: RouteNames.qibla,
            builder: (context, state) => const QiblaScreen(),
          ),
          GoRoute(
            path: RoutePaths.settings,
            name: RouteNames.settings,
            builder: (context, state) => const SettingsScreen(),
            routes: [
              GoRoute(
                path: 'profile',
                name: RouteNames.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

/// Alias conservé pour la compatibilité avec les fichiers existants qui
/// importent [appRouter] directement. À terme, préférer [goRouterProvider].
final GoRouter appRouter = GoRouter(
  initialLocation: RoutePaths.splash,
  debugLogDiagnostics: false,
  routes: const [],
);
