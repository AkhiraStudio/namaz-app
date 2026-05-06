import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart' show Uuid;
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../domain/entities/user_profile.dart';
import '../providers/profile_provider.dart';
import '../widgets/gender_selector_widget.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  UserGender? _selectedGender;
  int? _mensCycleDays;
  int? _mensDurationDays;

  bool get _canContinue =>
      _nameController.text.trim().isNotEmpty && _selectedGender != null;

  Future<void> _continue() async {
    if (!_canContinue) return;
    const uuid = Uuid();
    final profile = UserProfile(
      id: uuid.v4(),
      name: _nameController.text.trim(),
      gender: _selectedGender!,
      languageCode: 'fr',
      mensCycleDays: _selectedGender == UserGender.female ? (_mensCycleDays ?? 28) : null,
      mensDurationDays: _selectedGender == UserGender.female ? (_mensDurationDays ?? 7) : null,
    );
    final profileWithOnboarding = profile.copyWith(onboardingComplete: true);
    await ref.read(profileProvider.notifier).saveProfile(profileWithOnboarding);
    if (mounted) context.goNamed(RouteNames.home);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        title: Text(l.createProfileTitle),
        backgroundColor: AppColors.creamBackground,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.yourFirstNameLabel,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: l.enterFirstNameHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(l.youAreLabel,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            GenderSelectorWidget(
              selectedGender: _selectedGender,
              onChanged: (g) => setState(() => _selectedGender = g),
            ),
            if (_selectedGender == UserGender.female) ...[
              const SizedBox(height: 24),
              Text(l.menstrualCycleLabel,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l.cycleDurationLabel,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged: (v) => setState(
                          () => _mensCycleDays = int.tryParse(v) ?? 28),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l.menstruationDurationLabel,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged: (v) => setState(
                          () => _mensDurationDays = int.tryParse(v) ?? 7),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canContinue ? _continue : null,
                child: Text(l.continueButton),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
