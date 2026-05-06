import 'package:flutter/material.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';

class StreakFlameWidget extends StatelessWidget {
  final int streakDays;
  const StreakFlameWidget({super.key, required this.streakDays});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: streakDays > 0
            ? AppColors.gold.withValues(alpha: 0.12)
            : AppColors.beigeBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: streakDays > 0 ? AppColors.gold : AppColors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            color: streakDays > 0 ? AppColors.gold : AppColors.textLight,
            size: 20,
          ),
          const SizedBox(width: 6),
          Text(
            '$streakDays ${streakDays == 1 ? context.l10n.dayUnit : context.l10n.daysUnit}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: streakDays > 0 ? AppColors.gold : AppColors.textLight,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
