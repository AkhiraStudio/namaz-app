import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../domain/entities/mosque.dart';
import '../../domain/usecases/get_nearby_mosques_usecase.dart';
import '../providers/prayer_times_provider.dart';

final nearbyMosquesProvider = FutureProvider<List<Mosque>>((ref) async {
  final position = await ref.watch(currentPositionProvider.future);
  final useCase = GetNearbyMosquesUseCase(ref.read(prayerRepositoryProvider));
  final result = await useCase(
    latitude: position.latitude,
    longitude: position.longitude,
  );
  return result.fold(
    (failure) => throw Exception(failure.message),
    (list) => list,
  );
});

class MosqueNearbyListWidget extends ConsumerWidget {
  const MosqueNearbyListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mosqueAsync = ref.watch(nearbyMosquesProvider);
    final l = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        mosqueAsync.when(
          loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.deepPurple)),
          error: (e, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.unableToLoadMosques,
                  style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Text(
                e.toString(),
                style: const TextStyle(fontSize: 11, color: AppColors.prayerLate),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => ref.invalidate(nearbyMosquesProvider),
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: Text(l.retryButton),
              ),
            ],
          ),
          data: (mosques) {
            if (mosques.isEmpty) {
              return Text(
                l.noMosquesFound,
                style: const TextStyle(color: AppColors.textSecondary),
              );
            }
            return Column(
              children: mosques
                  .take(5)
                  .map((m) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _MosqueTile(mosque: m),
                      ))
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _MosqueTile extends StatelessWidget {
  final Mosque mosque;
  const _MosqueTile({required this.mosque});

  Future<void> _openInMaps() async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1'
      '&query=${mosque.latitude},${mosque.longitude}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openInMaps,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.deepPurple.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.mosque_rounded,
                  color: AppColors.deepPurple, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mosque.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (mosque.address != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      mosque.address!,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (mosque.distanceMeters != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.deepPurple.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      mosque.formattedDistance,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.deepPurple,
                      ),
                    ),
                  ),
                const SizedBox(height: 4),
                const Icon(Icons.open_in_new_rounded,
                    size: 14, color: AppColors.textLight),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
