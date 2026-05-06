import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../features/premium/presentation/providers/premium_provider.dart';

/// Shell scaffold avec la bottom navigation bar principale.
class AppShellScaffold extends ConsumerWidget {
  final Widget child;
  const AppShellScaffold({super.key, required this.child});

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith(RoutePaths.qada)) return 1;
    if (location.startsWith(RoutePaths.qibla)) return 2;
    if (location.startsWith(RoutePaths.settings)) return 3;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.goNamed(RouteNames.home);
      case 1:
        context.goNamed(RouteNames.qada);
      case 2:
        context.goNamed(RouteNames.qibla);
      case 3:
        context.goNamed(RouteNames.settings);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = _selectedIndex(context);
    final isPremium = ref.watch(isPremiumProvider);
    final isHome = selectedIndex == 0;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Stack(
        children: [
          child,
          if (isPremium && isHome)
            Positioned(
              top: topPadding + 16,
              right: 16,
              child: Image.asset(
                'assets/images/pro_badge.jpeg',
                height: 30,
              ),
            ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (i) => _onTap(context, i),
        backgroundColor: Theme.of(context).colorScheme.surface,
        indicatorColor: AppColors.deepPurple.withValues(alpha: 0.12),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: context.l10n.homeNavLabel,
          ),
          NavigationDestination(
            icon: const Icon(Icons.replay_outlined),
            selectedIcon: const Icon(Icons.replay_rounded),
            label: context.l10n.qadaNavLabel,
          ),
          const NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore_rounded),
            label: 'Qibla',
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings_rounded),
            label: context.l10n.settingsTitle,
          ),
        ],
      ),
    );
  }
}
