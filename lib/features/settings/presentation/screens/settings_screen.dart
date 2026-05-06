import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/route_names.dart';
import '../../../onboarding/presentation/providers/profile_provider.dart';
import '../providers/settings_provider.dart';
import '../../domain/entities/app_settings.dart';
import '../widgets/settings_section_widget.dart';
import '../widgets/language_selector_widget.dart';
import '../../../prayer/presentation/providers/prayer_statistics_provider.dart';
import '../../../prayer/presentation/providers/prayer_record_provider.dart';
import '../../../qada/presentation/providers/qada_provider.dart';
import '../../../premium/presentation/providers/premium_provider.dart';
import '../../../premium/domain/entities/premium_status.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final settings = ref.watch(settingsProvider);
    final profile = ref.watch(profileProvider).valueOrNull;
    final isPremium = ref.watch(isPremiumProvider);
    final premiumStatus = ref.watch(premiumStatusProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.settingsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          // ── Premium ──────────────────────────────────────────────────────────
          _PremiumBannerSection(
            isPremium: isPremium,
            premiumStatus: premiumStatus,
          ),

          // ── Profil ───────────────────────────────────────────────────────────
          _ProfileTile(profile: profile),

          // ── Langue ───────────────────────────────────────────────────────────
          SettingsSectionWidget(
            title: l.languageSection,
            children: [
              LanguageSelectorWidget(
                selectedCode: settings.languageCode,
                onChanged: (code) =>
                    ref.read(settingsProvider.notifier).updateLanguage(code),
              ),
            ],
          ),

          // ── Notifications ────────────────────────────────────────────────────
          SettingsSectionWidget(
            title: l.notificationsSection,
            children: [
              SwitchListTile(
                secondary: Icon(Icons.notifications_rounded,
                    color: Theme.of(context).colorScheme.primary),
                title: Text(l.prayerRemindersTitle),
                subtitle: Text(l.prayerRemindersSubtitle),
                value: settings.prayerNotifEnabled,
                onChanged: (v) =>
                    ref.read(settingsProvider.notifier).togglePrayerNotif(v),
              ),
              if (settings.prayerNotifEnabled)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.adhanAlertLabel,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 8),
                      SegmentedButton<PrayerAlertType>(
                        style: SegmentedButton.styleFrom(
                          selectedBackgroundColor:
                              Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                          selectedForegroundColor:
                              Theme.of(context).colorScheme.primary,
                        ),
                        segments: const [
                          ButtonSegment(
                            value: PrayerAlertType.adhan,
                            label: Text('Adhan'),
                            icon: Icon(Icons.music_note_rounded, size: 16),
                          ),
                          ButtonSegment(
                            value: PrayerAlertType.vibration,
                            label: Text('Vibration'),
                            icon: Icon(Icons.vibration_rounded, size: 16),
                          ),
                        ],
                        selected: {settings.prayerAlertType},
                        onSelectionChanged: (s) => ref
                            .read(settingsProvider.notifier)
                            .updatePrayerAlertType(s.first),
                      ),
                    ],
                  ),
                ),
              SwitchListTile(
                secondary: Icon(Icons.replay_rounded,
                    color: Theme.of(context).colorScheme.primary),
                title: Text(l.qadaRemindersTitle),
                subtitle: Text(
                  l.qadaRemindersSubtitle(
                      settings.qadaMorningHour, settings.qadaEveningHour),
                ),
                value: settings.qadaNotifEnabled,
                onChanged: (v) =>
                    ref.read(settingsProvider.notifier).toggleQadaNotif(v),
              ),
              if (settings.qadaNotifEnabled) ...[
                ListTile(
                  leading: const Icon(Icons.wb_sunny_outlined),
                  title: Text(l.morningReminderLabel),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isPremium)
                        const Padding(
                          padding: EdgeInsets.only(right: 6),
                          child: Icon(Icons.lock_rounded,
                              size: 14, color: AppColors.mediumPurple),
                        ),
                      Text(
                        '${settings.qadaMorningHour}h00',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  onTap: () async {
                    if (!isPremium) {
                      context.pushNamed(RouteNames.paywall);
                      return;
                    }
                    final l = context.l10n;
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(
                          hour: settings.qadaMorningHour, minute: 0),
                      helpText: l.morningReminderHelp,
                    );
                    if (picked != null && context.mounted) {
                      ref
                          .read(settingsProvider.notifier)
                          .updateQadaNotifHours(
                            morningHour: picked.hour,
                            eveningHour: settings.qadaEveningHour,
                          );
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.nights_stay_outlined),
                  title: Text(l.eveningReminderLabel),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isPremium)
                        const Padding(
                          padding: EdgeInsets.only(right: 6),
                          child: Icon(Icons.lock_rounded,
                              size: 14, color: AppColors.mediumPurple),
                        ),
                      Text(
                        '${settings.qadaEveningHour}h00',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  onTap: () async {
                    if (!isPremium) {
                      context.pushNamed(RouteNames.paywall);
                      return;
                    }
                    final l = context.l10n;
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(
                          hour: settings.qadaEveningHour, minute: 0),
                      helpText: l.eveningReminderHelp,
                    );
                    if (picked != null && context.mounted) {
                      ref
                          .read(settingsProvider.notifier)
                          .updateQadaNotifHours(
                            morningHour: settings.qadaMorningHour,
                            eveningHour: picked.hour,
                          );
                    }
                  },
                ),
              ],
            ],
          ),

          // ── Prières ──────────────────────────────────────────────────────────
          SettingsSectionWidget(
            title: l.prayersSection,
            children: [
              SwitchListTile(
                secondary: Icon(Icons.auto_awesome_rounded,
                    color: Theme.of(context).colorScheme.primary),
                title: Text(l.sunnahPrayersTitle),
                subtitle: Text(l.sunnahPrayersSubtitle),
                value: settings.showSunnahPrayers,
                onChanged: (v) =>
                    ref.read(settingsProvider.notifier).toggleSunnahPrayers(v),
              ),
            ],
          ),

          // ── Affichage ────────────────────────────────────────────────────────
          SettingsSectionWidget(
            title: l.displaySection,
            children: [
              SwitchListTile(
                secondary: Icon(Icons.dark_mode_rounded,
                    color: Theme.of(context).colorScheme.primary),
                title: Text(l.darkModeLabel),
                value: settings.darkMode,
                onChanged: (v) =>
                    ref.read(settingsProvider.notifier).toggleDarkMode(v),
              ),
              SwitchListTile(
                secondary: const Icon(
                  Icons.local_fire_department_rounded,
                  color: AppColors.gold,
                ),
                title: Text(l.showStreakLabel),
                subtitle: Text(l.showStreakSubtitle),
                value: settings.showStreak,
                onChanged: (v) =>
                    ref.read(settingsProvider.notifier).toggleShowStreak(v),
              ),
            ],
          ),

          // ── Calcul des horaires ──────────────────────────────────────────────
          SettingsSectionWidget(
            title: l.prayerTimesSection,
            children: [
              ListTile(
                leading: Icon(Icons.calculate_rounded,
                    color: Theme.of(context).colorScheme.primary),
                title: Text(l.calculationMethodLabel),
                subtitle: Text(
                  kPrayerCalcMethods
                      .firstWhere(
                        (m) => m.apiIndex == settings.calculationMethod,
                        orElse: () => kPrayerCalcMethods.first,
                      )
                      .region,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500),
                ),
                onTap: () => _showMethodPicker(context, ref, settings),
              ),
              ExpansionTile(
                leading: Icon(Icons.tune_rounded,
                    color: Theme.of(context).colorScheme.primary),
                title: Text(l.adjustmentsLabel),
                subtitle: Text(
                  settings.globalOffsetMinutes != 0
                      ? l.globalOffsetLabel(
                          settings.globalOffsetMinutes > 0
                              ? '+${settings.globalOffsetMinutes}'
                              : '${settings.globalOffsetMinutes}')
                      : l.noActiveOffset,
                ),
                children: [
                  _OffsetTile(
                    label: l.allPrayersLabel,
                    icon: Icons.access_time_rounded,
                    value: settings.globalOffsetMinutes,
                    onChanged: (v) =>
                        ref.read(settingsProvider.notifier).updateGlobalOffset(v),
                  ),
                  const Divider(indent: 16, endIndent: 16, height: 8),
                  _OffsetTile(
                    label: 'Fajr',
                    icon: Icons.wb_twilight,
                    value: settings.fajrOffsetMinutes,
                    onChanged: (v) => ref
                        .read(settingsProvider.notifier)
                        .updatePrayerOffset(fajr: v),
                  ),
                  _OffsetTile(
                    label: 'Dhuhr',
                    icon: Icons.wb_sunny_rounded,
                    value: settings.dhuhrOffsetMinutes,
                    onChanged: (v) => ref
                        .read(settingsProvider.notifier)
                        .updatePrayerOffset(dhuhr: v),
                  ),
                  _OffsetTile(
                    label: 'Asr',
                    icon: Icons.wb_sunny_outlined,
                    value: settings.asrOffsetMinutes,
                    onChanged: (v) => ref
                        .read(settingsProvider.notifier)
                        .updatePrayerOffset(asr: v),
                  ),
                  _OffsetTile(
                    label: 'Maghrib',
                    icon: Icons.nightlight_rounded,
                    value: settings.maghribOffsetMinutes,
                    onChanged: (v) => ref
                        .read(settingsProvider.notifier)
                        .updatePrayerOffset(maghrib: v),
                  ),
                  _OffsetTile(
                    label: 'Isha',
                    icon: Icons.nights_stay_rounded,
                    value: settings.ishaOffsetMinutes,
                    onChanged: (v) => ref
                        .read(settingsProvider.notifier)
                        .updatePrayerOffset(isha: v),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ],
          ),

          // ── Localisation ─────────────────────────────────────────────────────
          SettingsSectionWidget(
            title: l.locationSection,
            children: [
              SwitchListTile(
                secondary: Icon(Icons.flight_rounded,
                    color: Theme.of(context).colorScheme.primary),
                title: Text(l.travelerModeLabel),
                subtitle: Text(l.travelerModeSubtitleSettings),
                value: settings.travelerMode,
                onChanged: (v) => ref
                    .read(settingsProvider.notifier)
                    .toggleTravelerMode(v),
              ),
            ],
          ),

          // ── Données ──────────────────────────────────────────────────────────
          SettingsSectionWidget(
            title: l.dataSection,
            children: [
              ListTile(
                leading: const Icon(Icons.refresh_rounded,
                    color: AppColors.prayerLate),
                title: Text(l.resetPrayersLabel,
                    style: const TextStyle(color: AppColors.prayerLate)),
                onTap: () => _confirmReset(context, ref),
              ),
            ],
          ),

          const SizedBox(height: 32),
          const Center(
            child: Text(
              'Namaz App v1.0.0',
              style: TextStyle(color: AppColors.textLight, fontSize: 12),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showMethodPicker(
      BuildContext context, WidgetRef ref, AppSettings settings) {
    final l = context.l10n;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.4,
          maxChildSize: 0.85,
          expand: false,
          builder: (_, controller) => Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(ctx).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(l.calculationMethodLabel,
                  style: Theme.of(ctx).textTheme.titleMedium),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  controller: controller,
                  children: [
                    ...kPrayerCalcMethods.map((m) => ListTile(
                          title: Text(m.name),
                          subtitle: Text(m.region),
                          trailing: settings.calculationMethod == m.apiIndex
                              ? Icon(Icons.check_rounded,
                                  color: Theme.of(ctx).colorScheme.primary)
                              : null,
                          onTap: () {
                            ref
                                .read(settingsProvider.notifier)
                                .updateCalculationMethod(m.apiIndex);
                            Navigator.pop(ctx);
                          },
                        )),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.resetButton),
        content: Text(l.resetPrayersWarning),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.cancelButton)),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.prayerLate),
            child: Text(l.resetButton),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(settingsProvider.notifier).resetPrayerData();
      ref.invalidate(prayerStatisticsProvider);
      ref.invalidate(weeklyReportProvider);
      ref.invalidate(sunnahStatisticsProvider);
      ref.invalidate(prayerRecordProvider);
      ref.invalidate(qadaProgressProvider);
      ref.invalidate(pendingRecentMissedProvider);
      ref.invalidate(todayQadaCountsProvider);
      ref.invalidate(qadaDebtProvider);
    }
  }
}

// ── Bannière Premium ──────────────────────────────────────────────────────────

class _PremiumBannerSection extends StatelessWidget {
  final bool isPremium;
  final PremiumStatus? premiumStatus;

  const _PremiumBannerSection({
    required this.isPremium,
    required this.premiumStatus,
  });

  @override
  Widget build(BuildContext context) {
    if (isPremium) return const SizedBox.shrink();
    return _UpgradeBanner();
  }
}

class _UpgradeBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return GestureDetector(
      onTap: () => context.pushNamed(RouteNames.paywall),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.deepPurple, AppColors.mediumPurple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.workspace_premium_rounded,
                color: AppColors.gold, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.upgradeToPremium,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l.premiumSubtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.gold,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                l.discoverButton,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tuile profil ──────────────────────────────────────────────────────────────

class _ProfileTile extends StatelessWidget {
  final dynamic profile;
  const _ProfileTile({this.profile});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final name = (profile?.name as String?) ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.deepPurple,
          child: Text(
            initial,
            style: const TextStyle(
                color: AppColors.goldLight,
                fontWeight: FontWeight.bold,
                fontSize: 18),
          ),
        ),
        title: Text(
          name.isNotEmpty ? name : l.profileScreenTitle,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(l.editProfileSubtitle,
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => context.goNamed(RouteNames.profile),
      ),
    );
  }
}

// ── Tuile ajustement ±min ─────────────────────────────────────────────────────

class _OffsetTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final int value;
  final ValueChanged<int> onChanged;

  const _OffsetTile({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isActive = value != 0;
    return ListTile(
      dense: true,
      leading: Icon(icon, size: 20, color: cs.onSurfaceVariant),
      title: Text(label),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_rounded, size: 18),
            onPressed: () => onChanged(value - 1),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
          ),
          SizedBox(
            width: 52,
            child: Text(
              isActive
                  ? '${value > 0 ? '+' : ''}$value min'
                  : '0 min',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isActive ? cs.primary : cs.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded, size: 18),
            onPressed: () => onChanged(value + 1),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
