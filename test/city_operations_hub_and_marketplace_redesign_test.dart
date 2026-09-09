import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/data/models/theme_palette_model.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:galeriden/presentation/screens/dashboard/widgets/dashboard_services_grid.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('City Operations Hub & Marketplace Redesign Tests', () {
    testWidgets(
      'Renders Standalone Marketplace Hero card and City Operations Hub Box properly',
      (tester) async {
        tester.view.physicalSize = const Size(1000, 3000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final initialGame = DealershipModel.initial();
        final lvl2Game = initialGame.copyWith(
          level: 2,
          unlockedBuildings: {
            ...initialGame.unlockedBuildings,
            '/side-businesses',
            '/rent-a-car',
            '/reviews',
          },
          seenFeatureRoutes: {
            '/marketplace',
            '/showroom',
            '/expertise',
            '/branches',
            '/character-growth',
          },
        );
        final palette = ThemePaletteModel.defaultPalettes.first;

        SharedPreferences.setMockInitialValues({
          'dealership_state_v2': jsonEncode(lvl2Game.toJson()),
        });

        final container = ProviderContainer(
          overrides: [
            gameProvider.overrideWith((ref) => GameNotifier()),
          ],
        );

        addTearDown(() {
          container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
          container.dispose();
        });

        final router = GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => Scaffold(
                body: SingleChildScrollView(
                  child: Consumer(
                    builder: (context, ref, child) {
                      final game = ref.watch(gameProvider);
                      return DashboardServicesGrid(
                        game: game,
                        palette: palette,
                      );
                    },
                  ),
                ),
              ),
            ),
            GoRoute(path: '/marketplace', builder: (_, __) => const SizedBox()),
            GoRoute(path: '/side-businesses', builder: (_, __) => const SizedBox()),
            GoRoute(path: '/rent-a-car', builder: (_, __) => const SizedBox()),
            GoRoute(path: '/scrapyard', builder: (_, __) => const SizedBox()),
            GoRoute(path: '/showroom-decor', builder: (_, __) => const SizedBox()),
            GoRoute(path: '/reviews', builder: (_, __) => const SizedBox()),
          ],
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(
              routerConfig: router,
              locale: const Locale('tr'),
              supportedLocales: const [Locale('tr'), Locale('en')],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
            ),
          ),
        );

        await tester.pump();
        container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();

        // 1. Verify Standalone Marketplace Hero card
        expect(find.text('Araç Satın Al'), findsOneWidget);
        expect(find.text('AÇIK OTO PAZARINA GİR'), findsOneWidget);
        expect(find.text('YENİ İLANLAR'), findsOneWidget);

        // 2. Verify City Operations Hub Box exists
        expect(find.text('ŞEHİR & YAN SEKTÖRLER'), findsOneWidget);

        // 3. Verify Enlarged Featured Hero Slot for Yan İşletmeler at Level 2
        expect(find.text('Yan İşletmeler'), findsOneWidget);
        expect(find.text('TESİSLER'), findsOneWidget);

        // 4. Verify Next Unlock Teaser line exists for level 3
        expect(find.textContaining('Gece Sanayisi'), findsOneWidget);

        // 5. Tap on Marketplace Action Button
        await tester.tap(find.text('AÇIK OTO PAZARINA GİR'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
      },
    );

    testWidgets(
      'Renders all 10 unlocked services with vibrant themed bento tiles, telemetry pills, and VIP Casino strip',
      (tester) async {
        tester.view.physicalSize = const Size(1000, 4000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final initialGame = DealershipModel.initial();
        final lvl5Game = initialGame.copyWith(
          level: 5,
          unlockedBuildings: {
            ...initialGame.unlockedBuildings,
            '/side-businesses',
            '/rent-a-car',
            '/reviews',
            '/showroom-decor',
            '/scrapyard',
            '/consignment',
            '/night-market',
            '/gossip',
            '/districts',
            '/casino',
          },
          seenFeatureRoutes: {
            '/marketplace',
            '/showroom',
          },
        );
        final palette = ThemePaletteModel.defaultPalettes.first;

        SharedPreferences.setMockInitialValues({
          'dealership_state_v2': jsonEncode(lvl5Game.toJson()),
        });

        final container = ProviderContainer(
          overrides: [
            gameProvider.overrideWith((ref) => GameNotifier()),
          ],
        );

        addTearDown(() {
          container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
          container.dispose();
        });

        final router = GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => Scaffold(
                body: SingleChildScrollView(
                  child: Consumer(
                    builder: (context, ref, child) {
                      final game = ref.watch(gameProvider);
                      return DashboardServicesGrid(
                        game: game,
                        palette: palette,
                      );
                    },
                  ),
                ),
              ),
            ),
            GoRoute(path: '/casino', builder: (_, __) => const SizedBox()),
            GoRoute(path: '/side-businesses', builder: (_, __) => const SizedBox()),
            GoRoute(path: '/rent-a-car', builder: (_, __) => const SizedBox()),
            GoRoute(path: '/reviews', builder: (_, __) => const SizedBox()),
            GoRoute(path: '/showroom-decor', builder: (_, __) => const SizedBox()),
            GoRoute(path: '/scrapyard', builder: (_, __) => const SizedBox()),
            GoRoute(path: '/consignment', builder: (_, __) => const SizedBox()),
            GoRoute(path: '/night-market', builder: (_, __) => const SizedBox()),
            GoRoute(path: '/gossip', builder: (_, __) => const SizedBox()),
            GoRoute(path: '/districts', builder: (_, __) => const SizedBox()),
          ],
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(
              routerConfig: router,
              locale: const Locale('tr'),
              supportedLocales: const [Locale('tr'), Locale('en')],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
            ),
          ),
        );

        await tester.pump();
        container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();

        // Verify Hub Box title and badge
        expect(find.text('ŞEHİR & YAN SEKTÖRLER'), findsOneWidget);
        expect(find.text('10 AKTİF SEKTÖR'), findsOneWidget);

        // Verify Hero slot for Side Businesses
        expect(find.text('Yan İşletmeler'), findsOneWidget);

        // Verify Casino Strip at the bottom
        expect(find.text('Yeraltı Casino'), findsOneWidget);
        expect(find.text('MASAYA GEÇ'), findsOneWidget);

        // Verify Bento tiles exist
        expect(find.text('Rent-a-Car'), findsOneWidget);
        expect(find.text('Hurdalık & Parça'), findsOneWidget);
        expect(find.text('Gece Sanayisi'), findsOneWidget);
        expect(find.text('Dedikodu Hattı'), findsOneWidget);
        expect(find.text('Konsinye & Emanet'), findsOneWidget);
        expect(find.text('Semt Hakimiyeti'), findsOneWidget);
        expect(find.text('Showroom Mimari'), findsOneWidget);
        expect(find.text('Müşteri Yorumları'), findsOneWidget);

        // Tap on Casino button
        await tester.tap(find.text('MASAYA GEÇ'), warnIfMissed: false);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
      },
    );
  });
}
