import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/localization/language_model.dart';
import '../core/services/ad_service.dart';
import '../core/services/local_notification_service.dart';
import '../data/models/car_model.dart';
import '../presentation/providers/game_provider.dart';
import '../presentation/providers/market_provider.dart';
import '../presentation/providers/outsourced_tuning_provider.dart';
import '../presentation/providers/real_estate_market_provider.dart';
import '../presentation/providers/settings_provider.dart';
import '../presentation/providers/theme_provider.dart';
import '../presentation/providers/vasita_market_provider.dart';
import '../presentation/widgets/neo_brutal_touch_feedback_overlay.dart';
import 'router.dart';

/// Universal mobile gesture scroll behavior with bouncing physics & multi-device drag support
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.trackpad,
      };

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  }
}

class GaleridenApp extends ConsumerStatefulWidget {
  const GaleridenApp({super.key});

  @override
  ConsumerState<GaleridenApp> createState() => _GaleridenAppState();
}

class _GaleridenAppState extends ConsumerState<GaleridenApp> with WidgetsBindingObserver {
  StreamSubscription<String>? _payloadSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AdService.instance.initializeWithTrackingConsent();
    });
    _payloadSub = LocalNotificationService.payloadStream.stream.listen((payload) {
      if (payload == 'route_showroom' || payload == 'route_daily_login') {
        appRouter.go('/dashboard');
      }
    });
  }

  @override
  void dispose() {
    _payloadSub?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      ref.read(gameProvider.notifier).onAppPaused();
      ref.read(marketProvider.notifier).onAppPaused();
      ref.read(vasitaMarketProvider.notifier).onAppPaused();
      ref.read(realEstateMarketProvider.notifier).onAppPaused();
      ref.read(outsourcedTuningProvider.notifier).onAppPaused();

      final game = ref.read(gameProvider);
      final settings = ref.read(settingsProvider);

      if (!settings.isNotificationsEnabled) {
        LocalNotificationService.instance.cancelAllReminders();
        return;
      }

      CarModel? listedCar;
      for (final car in game.ownedCars) {
        if (car.isListed && !car.isRented) {
          listedCar = car;
          break;
        }
      }

      final hasListedCar = listedCar != null;
      LocalNotificationService.instance.scheduleLocalizedReminders(
        languageCode: settings.languageCode,
        hasListedCar: hasListedCar,
        carTitle: listedCar != null ? '${listedCar.brand} ${listedCar.modelName}' : null,
      );
    } else if (state == AppLifecycleState.resumed) {
      ref.read(gameProvider.notifier).onAppResumed();
      ref.read(marketProvider.notifier).onAppResumed();
      ref.read(vasitaMarketProvider.notifier).onAppResumed();
      ref.read(realEstateMarketProvider.notifier).onAppResumed();
      ref.read(outsourcedTuningProvider.notifier).onAppResumed();
      LocalNotificationService.instance.cancelShowroomOfferReminder();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final settings = ref.watch(settingsProvider);

    return MaterialApp.router(
      title: 'Galeriden',
      debugShowCheckedModeBanner: false,
      theme: themeState.buildThemeData(),
      locale: Locale(settings.languageCode),
      supportedLocales: AppLanguage.values.map((e) => e.locale).toList(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: appRouter,
      scrollBehavior: const AppScrollBehavior(),
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        final clampedScaler = mediaQuery.textScaler.clamp(
          minScaleFactor: 0.80,
          maxScaleFactor: 1.15,
        );

        final textDirection = settings.isRtl ? TextDirection.rtl : TextDirection.ltr;

        return Directionality(
          textDirection: textDirection,
          child: MediaQuery(
            data: mediaQuery.copyWith(textScaler: clampedScaler),
            child: NeoBrutalTouchFeedbackOverlay(
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        );
      },
    );
  }
}
