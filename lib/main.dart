import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:home_widget/home_widget.dart';
import 'firebase_options.dart';

import 'core/storage/hive_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/notification_scheduler.dart';
import 'core/services/home_widget_service.dart';
import 'core/router/app_router.dart';
import 'core/router/route_names.dart';
import 'core/theme/app_theme.dart';
import 'core/l10n/app_localizations.dart';
import 'features/settings/presentation/providers/settings_provider.dart';
import 'features/prayer/presentation/providers/prayer_times_provider.dart';
import 'features/prayer/presentation/providers/current_prayer_provider.dart';
import 'features/prayer/presentation/providers/prayer_record_provider.dart';
import 'features/qada/presentation/providers/qada_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation Hive (stockage local)
  await HiveService.init();

  // Initialisation Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialisation notifications locales (alarmes tiers de nuit)
  await NotificationService.init();

  // Initialisation du service de widgets écran d'accueil
  await HomeWidgetService().initialize();

  await Purchases.setLogLevel(LogLevel.debug);
  await Purchases.configure(
    PurchasesConfiguration('test_ZDZrFLLsDANAaNOFZdVbCUfOMRl'),
  );

  runApp(
    const ProviderScope(
      child: NamazApp(),
    ),
  );
}

class NamazApp extends ConsumerStatefulWidget {
  const NamazApp({super.key});

  @override
  ConsumerState<NamazApp> createState() => _NamazAppState();
}

class _NamazAppState extends ConsumerState<NamazApp> {
  bool _widgetInitialized = false;
  StreamSubscription<Uri?>? _widgetClickSub;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(settingsProvider.notifier).load());
    _widgetClickSub = HomeWidget.widgetClicked.listen(_onWidgetTap);
    HomeWidget.initiallyLaunchedFromHomeWidget().then(_onWidgetTap);
  }

  void _onWidgetTap(Uri? uri) {
    if (uri?.scheme == 'namaz' && uri?.host == 'open') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(goRouterProvider).go(RoutePaths.qada);
      });
    }
  }

  @override
  void dispose() {
    _widgetClickSub?.cancel();
    super.dispose();
  }

  void _updateHomeWidget(WidgetRef ref) {
    final timesAsync = ref.read(prayerTimesProvider);
    final nextPrayer = ref.read(nextPrayerProvider);
    final records = ref.read(prayerRecordProvider).valueOrNull ?? {};
    final prayedCount = records.values.where((r) => !r.isMissed).length;

    timesAsync.whenData((times) {
      HomeWidgetService().update(
        prayerTime: times,
        nextPrayer: nextPrayer,
        prayedCount: prayedCount,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final settingsLoaded = ref.watch(settingsLoadedProvider);

    // Attendre que Hive soit lu avant d'afficher l'app
    if (!settingsLoaded) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    // Mise à jour immédiate du widget au premier chargement (données déjà en cache)
    if (!_widgetInitialized) {
      _widgetInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _updateHomeWidget(ref));
    }

    // Replanifie les notifications de prière quand les horaires sont chargés
    ref.listen(prayerTimesProvider, (_, next) {
      next.whenData((times) {
        NotificationScheduler.schedulePrayerNotifications(times, settings);
        _updateHomeWidget(ref);
      });
    });

    // Met à jour le widget quand les enregistrements de prière changent
    ref.listen(prayerRecordProvider, (_, __) => _updateHomeWidget(ref));

    // Met à jour le widget qada dès que la progression est chargée
    ref.listen(qadaProgressProvider, (_, next) {
      next.whenData((progress) {
        final counts = ref.read(todayQadaCountsProvider).valueOrNull ?? {};
        HomeWidgetService().updateQada(progress: progress, todayCounts: counts);
      });
    });

    // Replanifie la notif qada + met à jour le widget qada quand les comptes changent
    ref.listen(todayQadaCountsProvider, (_, next) {
      next.whenData((counts) {
        final progress = ref.read(qadaProgressProvider).valueOrNull;
        if (progress != null) {
          NotificationScheduler.scheduleQadaNotifications(progress, counts, settings);
          HomeWidgetService().updateQada(progress: progress, todayCounts: counts);
        }
      });
    });

    final isRtl = AppLocalizationsSetup.isRtl(settings.languageCode);

    return MaterialApp.router(
      title: 'Namaz App',
      debugShowCheckedModeBanner: false,

      // Thème Material 3 (clair / sombre selon settings)
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
      themeAnimationDuration: Duration.zero,

      // Navigation go_router (Riverpod-aware, auth gate inclus)
      routerConfig: ref.watch(goRouterProvider),

      // Localisation — 7 langues
      locale: Locale(settings.languageCode),
      supportedLocales: AppLocalizationsSetup.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Directionality RTL pour l'arabe
      builder: (context, child) => Directionality(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: child!,
      ),
    );
  }
}
