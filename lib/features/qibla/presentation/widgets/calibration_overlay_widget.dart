import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Bannière affichée quand la boussole n'est pas calibrée.
class CalibrationOverlayWidget extends StatelessWidget {
  const CalibrationOverlayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.prayerOnTime.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.prayerOnTime),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded,
              color: AppColors.prayerOnTime, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Calibrez la boussole : tracez un 8 dans l\'air avec votre téléphone.',
              style: TextStyle(
                  color: AppColors.prayerOnTime,
                  fontSize: 13,
                  height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
