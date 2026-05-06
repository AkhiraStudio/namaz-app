import 'package:flutter/material.dart';
import '../../../../core/theme/solar_theme.dart';

/// Fond dynamique qui change de couleur selon la phase solaire.
class SolarBackgroundWidget extends StatelessWidget {
  final SolarThemeData solarData;
  final Widget child;

  const SolarBackgroundWidget({
    super.key,
    required this.solarData,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(seconds: 2),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            solarData.backgroundColor,
            solarData.backgroundColor.withValues(alpha: 0.7),
          ],
        ),
      ),
      child: child,
    );
  }
}
