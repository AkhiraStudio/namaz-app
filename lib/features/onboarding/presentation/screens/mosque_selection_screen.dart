import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../features/prayer/presentation/widgets/mosque_nearby_list_widget.dart';
import '../../../../features/prayer/domain/entities/mosque.dart';
import '../providers/profile_provider.dart';

class MosqueSelectionScreen extends ConsumerStatefulWidget {
  const MosqueSelectionScreen({super.key});

  @override
  ConsumerState<MosqueSelectionScreen> createState() =>
      _MosqueSelectionScreenState();
}

class _MosqueSelectionScreenState
    extends ConsumerState<MosqueSelectionScreen> {
  bool _travelerMode = false;
  Mosque? _selectedMosque;

  @override
  void initState() {
    super.initState();
    Future.microtask(_requestLocationPermission);
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }
  }

  Future<void> _finish() async {
    final profileState = ref.read(profileProvider).valueOrNull;
    if (profileState == null) return;

    final updated = profileState.copyWith(
      mosqueName: _selectedMosque?.name,
      mosqueLatitude: _selectedMosque?.latitude,
      mosqueLongitude: _selectedMosque?.longitude,
      travelerMode: _travelerMode,
      onboardingComplete: true,
    );
    await ref.read(profileProvider.notifier).saveProfile(updated);
    if (mounted) context.goNamed(RouteNames.home);
  }

  @override
  Widget build(BuildContext context) {
    final mosqueAsync = ref.watch(nearbyMosquesProvider);
    final l = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        title: Text(l.myMosqueTitle),
        backgroundColor: AppColors.creamBackground,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              value: _travelerMode,
              onChanged: (v) => setState(() => _travelerMode = v),
              title: Text(l.travelerModeLabel),
              subtitle: Text(l.travelerModeSubtitle),
              activeThumbColor: AppColors.deepPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.border),
              ),
            ),
            const SizedBox(height: 24),

            Text(l.nearbyMosquesLabel,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              l.selectMosqueHint,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: mosqueAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.deepPurple),
                ),
                error: (e, _) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_off_rounded,
                        color: AppColors.textLight, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      l.mosquesLoadError,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: () => ref.invalidate(nearbyMosquesProvider),
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(l.retryButton),
                    ),
                  ],
                ),
                data: (mosques) {
                  if (mosques.isEmpty) {
                    return Center(
                      child: Text(
                        l.noMosquesFound,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: mosques.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final mosque = mosques[i];
                      final isSelected = _selectedMosque?.id == mosque.id;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isSelected
                              ? AppColors.deepPurple
                              : AppColors.lightPurple.withValues(alpha: 0.3),
                          child: Icon(
                            isSelected
                                ? Icons.check_rounded
                                : Icons.mosque_rounded,
                            color: isSelected ? Colors.white : AppColors.deepPurple,
                            size: 18,
                          ),
                        ),
                        title: Text(mosque.name,
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            )),
                        subtitle: mosque.address != null
                            ? Text(mosque.address!,
                                style: const TextStyle(fontSize: 12))
                            : null,
                        selected: isSelected,
                        selectedColor: AppColors.deepPurple,
                        onTap: () => setState(() => _selectedMosque = mosque),
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _finish,
                child: Text(_selectedMosque != null
                    ? l.continueWithMosque(_selectedMosque!.name)
                    : l.continueWithoutMosque),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
