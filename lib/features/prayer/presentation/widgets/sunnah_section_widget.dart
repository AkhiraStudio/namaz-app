import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/prayer_record.dart';
import '../../domain/entities/sunnah_prayer.dart';
import '../providers/sunnah_provider.dart';

class SunnahSectionWidget extends ConsumerWidget {
  final PrayerName prayerName;

  const SunnahSectionWidget({super.key, required this.prayerName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checked = ref.watch(sunnahProvider);
    final groups = sunnahGroupsForPrayer(prayerName);
    if (groups.isEmpty) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Connecteur visuel (trait + point) reliant la carte du dessus
        Column(
          children: [
            Container(
              width: 2,
              height: 12,
              color: AppColors.gold.withValues(alpha: 0.4),
            ),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
        // Section principale
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.25)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Barre gauche dorée
                    Container(width: 3, color: AppColors.gold),
                    Expanded(
                      child: Padding(
                        padding:
                            const EdgeInsets.fromLTRB(12, 10, 14, 12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // En-tête
                            Row(
                              children: [
                                const Icon(Icons.auto_awesome_rounded,
                                    size: 13, color: AppColors.gold),
                                const SizedBox(width: 6),
                                Text(
                                  context.l10n.sunnahSectionLabel,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.gold
                                        .withValues(alpha: 0.85),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Groupes
                            ...groups.entries.map((entry) {
                              final allDone = entry.value.every(
                                  (d) => checked.contains(d.prayer));
                              return Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 8),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          entry.key,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: allDone
                                                ? AppColors.prayerEarly
                                                : cs.onSurface.withValues(
                                                    alpha: 0.7),
                                          ),
                                        ),
                                        if (allDone) ...[
                                          const SizedBox(width: 4),
                                          const Icon(
                                              Icons.check_circle_rounded,
                                              size: 11,
                                              color:
                                                  AppColors.prayerEarly),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: entry.value.map((def) {
                                        final isDone = checked
                                            .contains(def.prayer);
                                        return GestureDetector(
                                          onTap: () => ref
                                              .read(sunnahProvider
                                                  .notifier)
                                              .toggle(def.prayer),
                                          child: Container(
                                            padding: const EdgeInsets
                                                .symmetric(
                                                horizontal: 10,
                                                vertical: 5),
                                            decoration: BoxDecoration(
                                              color: isDone
                                                  ? AppColors.gold
                                                      .withValues(
                                                          alpha: 0.15)
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      8),
                                              border: Border.all(
                                                color: isDone
                                                    ? AppColors.gold
                                                    : AppColors.gold
                                                        .withValues(
                                                            alpha: 0.4),
                                              ),
                                            ),
                                            child: Text(
                                              isDone
                                                  ? '✓ ${def.rakaat}'
                                                  : def.rakaat,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: isDone
                                                    ? FontWeight.w600
                                                    : FontWeight.normal,
                                                color: isDone
                                                    ? AppColors.gold
                                                    : cs.onSurface,
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
