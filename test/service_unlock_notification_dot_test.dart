import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/data/models/theme_palette_model.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:galeriden/presentation/screens/dashboard/widgets/dashboard_services_grid.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Service Unlock Notification Dot Tests', () {
    test('DealershipModel tracks seenFeatureRoutes and reports isFeatureNew correctly', () {
      final initialGame = DealershipModel.initial();
      expect(initialGame.seenFeatureRoutes.contains('/marketplace'), isTrue);
      expect(initialGame.seenFeatureRoutes.contains('/vasita'), isFalse);
      expect(initialGame.seenFeatureRoutes.contains('/emlak'), isFalse);

      // Level 1: Vasita is locked, so isFeatureNew is false
      expect(initialGame.isFeatureNew('/vasita'), isFalse);

      // Level 3: Vasita is unlocked, but not seen -> isFeatureNew is true
      final lvl3Game = initialGame.copyWith(level: 3);
      expect(lvl3Game.isFeatureUnlocked('/vasita'), isTrue);
      expect(lvl3Game.isFeatureNew('/vasita'), isTrue);

      // After markFeatureSeen, isFeatureNew becomes false
      final seenGame = lvl3Game.markFeatureSeen('/vasita');
      expect(seenGame.seenFeatureRoutes.contains('/vasita'), isTrue);
      expect(seenGame.seenFeatureRoutes.contains('/vasita-market'), isTrue);
      expect(seenGame.isFeatureNew('/vasita'), isFalse);

      // Serialization round-trip preserves seenFeatureRoutes
      final json = seenGame.toJson();
      final restoredGame = DealershipModel.fromJson(json);
      expect(restoredGame.seenFeatureRoutes.contains('/vasita'), isTrue);
      expect(restoredGame.isFeatureNew('/vasita'), isFalse);
    });

    testWidgets('DashboardServicesGrid shows notification dot instead of LVL badges, clears on tap', (tester) async {
      // Create a level 4 game where /vasita and /emlak are newly unlocked (not in seenFeatureRoutes)
      final initialGame = DealershipModel.initial();
      final lvl4Game = initialGame.copyWith(
        level: 4,
        seenFeatureRoutes: {
          '/marketplace',
          '/showroom',
          '/expertise',
          '/branches',
          '/character-growth',
          '/settings',
          '/dealership-identity',
          '/theme-store',
        },
      );
      final palette = ThemePaletteModel.defaultPalettes.first;

      SharedPreferences.setMockInitialValues({
        'dealership_state_v2': jsonEncode(lvl4Game.toJson()),
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
          GoRoute(path: '/vasita', builder: (_, __) => const SizedBox()),
          GoRoute(path: '/emlak', builder: (_, __) => const SizedBox()),
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

      // Verify that 'LVL 3' and 'LVL 4' text badges are NOT rendered anywhere
      expect(find.text('LVL 3'), findsNothing);
      expect(find.text('LVL 4'), findsNothing);

      // Verify Vasıta and Emlak cards exist
      expect(find.text('Vasıta Pazarı'), findsOneWidget);
      expect(find.text('Emlak Pazarı'), findsOneWidget);

      // Check that Vasıta and Emlak are initially marked as new in the state
      expect(container.read(gameProvider).isFeatureNew('/vasita'), isTrue);
      expect(container.read(gameProvider).isFeatureNew('/emlak'), isTrue);

      // Tap Vasıta Pazarı card
      await tester.tap(find.text('Vasıta Pazarı'));
      await tester.pump();

      // State is now updated: /vasita is seen!
      expect(container.read(gameProvider).isFeatureNew('/vasita'), isFalse);
      expect(container.read(gameProvider).seenFeatureRoutes.contains('/vasita'), isTrue);

      // Return back to dashboard / tap Emlak Pazarı
      router.go('/');
      await tester.pump();

      // Emlak Pazarı is still new
      expect(container.read(gameProvider).isFeatureNew('/emlak'), isTrue);

      // Tap Emlak Pazarı card
      await tester.tap(find.text('Emlak Pazarı'));
      await tester.pump();

      // Flush the 350ms save debounce timer
      await tester.pump(const Duration(milliseconds: 500));

      // Both are now marked as seen!
      expect(container.read(gameProvider).isFeatureNew('/emlak'), isFalse);
      expect(container.read(gameProvider).seenFeatureRoutes.contains('/emlak'), isTrue);
    });
  });
}
