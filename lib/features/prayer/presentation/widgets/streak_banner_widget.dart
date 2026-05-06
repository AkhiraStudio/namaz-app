import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/prayer_statistics_provider.dart';

/// Chip compact affichant la série de jours consécutifs sans prière manquée.
class StreakBannerWidget extends ConsumerWidget {
  const StreakBannerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakAsync = ref.watch(homeStreakProvider);

    return streakAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (streak) {
        if (streak == 0) return const SizedBox.shrink();
        return _StreakChip(streak: streak);
      },
    );
  }
}

class _StreakChip extends StatelessWidget {
  final int streak;
  const _StreakChip({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_fire_department_rounded,
            color: AppColors.gold,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            '$streak jour${streak > 1 ? 's' : ''} sans avoir manqué de prière!',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.gold,
            ),
          ),
        ],
      ),
    );
  }
}
