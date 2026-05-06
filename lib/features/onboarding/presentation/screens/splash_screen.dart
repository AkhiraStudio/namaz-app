import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/user_profile.dart';
import '../providers/profile_provider.dart';
import '../../../prayer/presentation/providers/prayer_times_provider.dart';
import '../../../prayer/presentation/providers/prayer_record_provider.dart';
import '../../../prayer/presentation/providers/prayer_statistics_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
    _checkNavigation();
  }

  Future<void> _checkNavigation() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // Restauration cloud (no-op si Hive déjà rempli ou utilisateur anonyme)
    final profileRepo = ref.read(profileRepositoryProvider);
    await profileRepo.restoreFromCloud();
    final prayerRepo = ref.read(prayerRepositoryProvider);
    await prayerRepo.restoreFromCloud();

    // Si l'utilisateur a un vrai compte (non anonyme) mais que le profil
    // n'est pas dans Firestore (données perdues avant fix des règles), on
    // crée un profil minimal pour éviter de refaire l'onboarding.
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final localProfile = await profileRepo.getProfile();
    final noLocalProfile = localProfile.fold((_) => true, (p) => p == null);
    if (noLocalProfile && firebaseUser != null && !firebaseUser.isAnonymous) {
      const uuid = Uuid();
      final fallback = UserProfile(
        id: uuid.v4(),
        name: firebaseUser.displayName ?? '',
        gender: UserGender.male,
        languageCode: 'fr',
        onboardingComplete: true,
      );
      await profileRepo.saveProfile(fallback);
    }

    // Invalider les providers qui ont peut-être mis en cache des valeurs vides
    // avant la restauration, pour qu'ils relisent Hive maintenant
    ref.invalidate(profileProvider);
    ref.invalidate(onboardingCompleteProvider);
    ref.invalidate(prayerRecordProvider);
    ref.invalidate(weeklyPrayerDotsProvider);

    if (!mounted) return;
    final isComplete = await ref.read(onboardingCompleteProvider.future);
    if (!mounted) return;
    if (isComplete) {
      context.goNamed(RouteNames.home);
    } else {
      context.goNamed(RouteNames.onboarding);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/logo.jpg',
                width: 260,
                height: 260,
              ),
              const SizedBox(height: 48),
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: AppColors.deepPurple,
                  strokeWidth: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
