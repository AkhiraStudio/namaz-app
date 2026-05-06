import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/storage/hive_service.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/user_profile.dart';
import '../providers/profile_provider.dart';
import '../widgets/gender_selector_widget.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  UserGender? _gender;
  int? _cycleDays;
  int? _durationDays;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider).valueOrNull;
    if (profile != null) {
      _nameCtrl.text = profile.name;
      _gender = profile.gender;
      _cycleDays = profile.mensCycleDays;
      _durationDays = profile.mensDurationDays;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final profile = ref.read(profileProvider).valueOrNull;
    if (profile == null || _gender == null) return;
    setState(() => _saving = true);
    await ref.read(profileProvider.notifier).saveProfile(
          profile.copyWith(
            name: _nameCtrl.text.trim(),
            gender: _gender,
            mensCycleDays: _gender == UserGender.female ? _cycleDays : null,
            mensDurationDays: _gender == UserGender.female ? _durationDays : null,
          ),
        );
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.profileUpdatedSnackbar)),
    );
  }

  Future<void> _changeEmail() async {
    final l = context.l10n;
    final ctrl = TextEditingController();
    final confirmed = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.changeEmailTitle),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(labelText: l.newEmailLabel),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.cancelButton)),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: Text(l.confirmButton),
          ),
        ],
      ),
    );
    if (confirmed == null || confirmed.isEmpty || !mounted) return;
    final error = await ref.read(authNotifierProvider.notifier).updateEmail(confirmed);
    if (!mounted) return;
    if (error != null) {
      _showError(error);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.verificationEmailSent)),
      );
    }
  }

  Future<void> _changePassword() async {
    final l = context.l10n;
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool obscure = true;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) {
          return AlertDialog(
            title: Text(l.changePasswordTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: newCtrl,
                  obscureText: true,
                  decoration: InputDecoration(labelText: l.newPasswordLabel),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmCtrl,
                  obscureText: obscure,
                  decoration: InputDecoration(
                    labelText: l.confirmPasswordLabel,
                    suffixIcon: IconButton(
                      icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setS(() => obscure = !obscure),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancelButton)),
              ElevatedButton(
                onPressed: () {
                  if (newCtrl.text.length < 6) return;
                  if (newCtrl.text != confirmCtrl.text) return;
                  Navigator.pop(ctx, true);
                },
                child: Text(l.confirmButton),
              ),
            ],
          );
        },
      ),
    );
    if (confirmed != true || !mounted) return;
    final error = await ref.read(authNotifierProvider.notifier).updatePassword(newCtrl.text);
    if (!mounted) return;
    if (error != null) {
      _showError(error);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.passwordUpdatedSnackbar)),
      );
    }
  }

  Future<void> _deleteProfile() async {
    final l = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.deleteProfileTitle),
        content: Text(l.deleteProfileWarning),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.cancelButton)),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.prayerLate),
            child: Text(l.deleteButton),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await HiveService.clearUserData();
    await ref.read(authNotifierProvider.notifier).deleteAccount();
  }

  Future<void> _linkGoogle() async {
    await ref.read(authNotifierProvider.notifier).linkWithGoogle();
    if (!mounted) return;
    final auth = ref.read(authNotifierProvider);
    if (auth.hasError) {
      _showError(auth.error.toString());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.googleLinkedSnackbar)),
      );
    }
  }

  Future<void> _signOut() async {
    final l = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.signOutDialogTitle),
        content: Text(l.signOutWarning),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.cancelButton)),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.signOutButton),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authNotifierProvider.notifier).signOut();
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red.shade700),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final profile = ref.watch(profileProvider).valueOrNull;
    final authUser = ref.watch(authStateProvider).valueOrNull;
    final isFemale = _gender == UserGender.female;
    final isEmailUser = authUser != null && !authUser.isAnonymous && authUser.email != null;

    return Scaffold(
      appBar: AppBar(title: Text(l.profileScreenTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Center(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.deepPurple,
                    child: Text(
                      (profile?.name.isNotEmpty == true)
                          ? profile!.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.goldLight),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (authUser != null && !authUser.isAnonymous)
                    Text(
                      authUser.email ?? '',
                      style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
                    )
                  else
                    Text(l.anonymousAccountLabel,
                        style: const TextStyle(color: AppColors.textLight, fontSize: 13)),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            _sectionTitle(context, l.personalInfoSection),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameCtrl,
              decoration: _inputDecoration(context, l.firstNameLabel, Icons.person_outline),
            ),
            const SizedBox(height: 16),
            Text(l.genderLabel, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant)),
            const SizedBox(height: 10),
            GenderSelectorWidget(
              selectedGender: _gender,
              onChanged: (g) => setState(() => _gender = g),
            ),

            if (isFemale) ...[
              const SizedBox(height: 20),
              _sectionTitle(context, l.menstrualCycleLabel),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: (_cycleDays ?? 28).toString(),
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration(context, l.cycleDurationLabel, Icons.loop),
                      onChanged: (v) => _cycleDays = int.tryParse(v) ?? 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: TextFormField(
                      initialValue: (_durationDays ?? 7).toString(),
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration(context, l.menstruationDurationLabel, Icons.water_drop_outlined),
                      onChanged: (v) => _durationDays = int.tryParse(v) ?? 7,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text(l.saveButton,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),

            const SizedBox(height: 28),
            _sectionTitle(context, l.accountSection),
            const SizedBox(height: 8),
            if (authUser != null && authUser.isAnonymous)
              _accountTile(
                context,
                icon: Icons.link_rounded,
                title: l.linkGoogleButton,
                subtitle: l.linkGoogleSubtitle,
                onTap: _linkGoogle,
              )
            else if (authUser != null) ...[
              if (isEmailUser) ...[
                _actionTile(
                  context,
                  icon: Icons.email_outlined,
                  title: l.changeEmailTitle,
                  subtitle: authUser.email,
                  onTap: _changeEmail,
                ),
                _actionTile(
                  context,
                  icon: Icons.lock_outline,
                  title: l.changePasswordTitle,
                  onTap: _changePassword,
                ),
              ],
              _accountTile(
                context,
                icon: Icons.logout_rounded,
                iconColor: AppColors.prayerLate,
                title: l.signOutDialogTitle,
                titleColor: AppColors.prayerLate,
                onTap: _signOut,
              ),
            ],

            const SizedBox(height: 28),
            _sectionTitle(context, l.dangerZoneSection, color: AppColors.prayerLate),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.prayerLate.withValues(alpha: 0.4)),
                borderRadius: BorderRadius.circular(14),
                color: AppColors.prayerLate.withValues(alpha: 0.05),
              ),
              child: ListTile(
                leading: const Icon(Icons.delete_forever_rounded, color: AppColors.prayerLate),
                title: Text(l.deleteProfileOption,
                    style: const TextStyle(
                        color: AppColors.prayerLate,
                        fontWeight: FontWeight.w600)),
                subtitle: Text(l.deleteProfileDescription,
                    style: const TextStyle(fontSize: 12)),
                onTap: _deleteProfile,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title, {Color? color}) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: color ?? AppColors.mediumPurple,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
    );
  }

  Widget _accountTile(
    BuildContext context, {
    required IconData icon,
    Color? iconColor,
    required String title,
    Color? titleColor,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(icon, color: iconColor ?? AppColors.deepPurple),
      title: Text(title,
          style: TextStyle(color: titleColor, fontWeight: FontWeight.w600)),
      subtitle: subtitle != null
          ? Text(subtitle, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13))
          : null,
      onTap: onTap,
    );
  }

  Widget _actionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(icon, color: AppColors.deepPurple),
      title: Text(title),
      subtitle: subtitle != null
          ? Text(subtitle, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13))
          : null,
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }

  InputDecoration _inputDecoration(BuildContext context, String label, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      filled: true,
      fillColor: isDark ? AppColors.darkSurface : AppColors.cardBackground,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.deepPurple, width: 1.5),
      ),
    );
  }
}
