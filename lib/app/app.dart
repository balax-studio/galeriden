import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../presentation/providers/game_provider.dart';
import '../presentation/providers/market_provider.dart';
import '../presentation/providers/theme_provider.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      ref.read(gameProvider.notifier).onAppPaused();
      ref.read(marketProvider.notifier).onAppPaused();
    } else if (state == AppLifecycleState.resumed) {
      ref.read(gameProvider.notifier).onAppResumed();
      ref.read(marketProvider.notifier).onAppResumed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Galeriden',
      debugShowCheckedModeBanner: false,
      theme: themeState.buildThemeData(),
      routerConfig: appRouter,
      scrollBehavior: const AppScrollBehavior(),
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        final clampedScaler = mediaQuery.textScaler.clamp(
          minScaleFactor: 0.80,
          maxScaleFactor: 1.15,
        );
        return MediaQuery(
          data: mediaQuery.copyWith(textScaler: clampedScaler),
          child: NeoBrutalTouchFeedbackOverlay(
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
