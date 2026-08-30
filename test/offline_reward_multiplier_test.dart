import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/theme/app_theme.dart';
import 'package:galeriden/domain/usecases/offline_multiplier_engine.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:galeriden/presentation/screens/dashboard/widgets/dashboard_retention_modals.dart';
import 'package:galeriden/presentation/widgets/neo_brutal_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('OfflineMultiplierEngine Unit Tests', () {
    test('OfflineMultiplierEngine returns valid multiplier within defined tiers', () {
      final validMultipliers = {1.5, 2.0, 2.5, 3.0};
      final rng = math.Random(42);

      for (int i = 0; i < 100; i++) {
        final mult = OfflineMultiplierEngine.getRandomMultiplier(rng: rng);
        expect(validMultipliers.contains(mult), isTrue,
            reason: 'Generated multiplier $mult is not in valid set');
      }
    });

    test('OfflineMultiplierEngine calculates bonus and total amounts accurately', () {
      const earned = 10000.0;

      // 1.5x
      expect(OfflineMultiplierEngine.calculateBonusAmount(earned, 1.5), 5000.0);
      expect(OfflineMultiplierEngine.calculateTotalAmount(earned, 1.5), 15000.0);

      // 2.0x
      expect(OfflineMultiplierEngine.calculateBonusAmount(earned, 2.0), 10000.0);
      expect(OfflineMultiplierEngine.calculateTotalAmount(earned, 2.0), 20000.0);

      // 2.5x
      expect(OfflineMultiplierEngine.calculateBonusAmount(earned, 2.5), 15000.0);
      expect(OfflineMultiplierEngine.calculateTotalAmount(earned, 2.5), 25000.0);

      // 3.0x
      expect(OfflineMultiplierEngine.calculateBonusAmount(earned, 3.0), 20000.0);
      expect(OfflineMultiplierEngine.calculateTotalAmount(earned, 3.0), 30000.0);

      // Zero or negative
      expect(OfflineMultiplierEngine.calculateBonusAmount(0.0, 2.0), 0.0);
      expect(OfflineMultiplierEngine.calculateBonusAmount(-50.0, 2.0), 0.0);
      expect(OfflineMultiplierEngine.calculateBonusAmount(earned, 1.0), 0.0);
    });

    test('OfflineMultiplierEngine formats multipliers cleanly without trailing decimals for integers', () {
      expect(OfflineMultiplierEngine.formatMultiplier(1.5), '1.5x');
      expect(OfflineMultiplierEngine.formatMultiplier(2.0), '2x');
      expect(OfflineMultiplierEngine.formatMultiplier(2.5), '2.5x');
      expect(OfflineMultiplierEngine.formatMultiplier(3.0), '3x');
    });
  });

  group('showOfflineRecapModal Widget Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
    });

    tearDown(() {
      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
      container.dispose();
    });

    testWidgets(
        'Renders multiplier rewarded ad button when earnedIncome > 0 and allows standard claim',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            locale: const Locale('tr'),
            supportedLocales: const [Locale('tr'), Locale('en')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      DashboardRetentionModals.showOfflineRecapModal(
                        context,
                        {
                          'title': 'Çevrimdışı Kazanç Raporu',
                          'earnedIncome': 25000.0,
                          'bulletPoints': [
                            'Oto Yıkama çalıştı ve gelir sağladı',
                            '2 yeni teklif vitrinde bekliyor',
                          ],
                        },
                      );
                    },
                    child: const Text('Open Modal'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Open Modal
      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Check Title and Earnings
      expect(find.text('Çevrimdışı Kazanç Raporu'), findsOneWidget);
      expect(find.text('Oto Yıkama çalıştı ve gelir sağladı'), findsOneWidget);

      // Check Multiplier Buttons and Badges
      expect(find.byIcon(Icons.movie_filter_rounded), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

      // Tap standard claim
      final standardClaimFinder =
          find.widgetWithIcon(NeoBrutalButton, Icons.check_circle_rounded);
      await tester.tap(standardClaimFinder);
      await tester.pumpAndSettle();

      // Modal should be dismissed
      expect(find.text('Çevrimdışı Kazanç Raporu'), findsNothing);
    });

    testWidgets(
        'Tapping rewarded multiplier button triggers AdService and credits bonus income to balance',
        (WidgetTester tester) async {
      // Set initial dealership balance
      final notifier = container.read(gameProvider.notifier);
      notifier.state = notifier.state.copyWith(balance: 50000.0);
      final initialBalance = notifier.state.balance;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            locale: const Locale('tr'),
            supportedLocales: const [Locale('tr'), Locale('en')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, _) {
                  return ElevatedButton(
                    onPressed: () {
                      DashboardRetentionModals.showOfflineRecapModal(
                        context,
                        {
                          'title': 'Çevrimdışı Kazanç Raporu',
                          'earnedIncome': 10000.0,
                          'bulletPoints': [],
                        },
                        ref: ref,
                      );
                    },
                    child: const Text('Open Modal'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Open Modal
      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Find the rewarded multiplier button
      final multiplierButtonFinder =
          find.widgetWithIcon(NeoBrutalButton, Icons.movie_filter_rounded);
      expect(multiplierButtonFinder, findsOneWidget);

      // Tap Multiplier Button
      await tester.tap(multiplierButtonFinder);
      await tester.pumpAndSettle();

      // In test env, fallback dialog appears if not on web; claim reward on fallback dialog
      final claimGiftFinder = find.byIcon(Icons.card_giftcard_rounded);
      if (claimGiftFinder.evaluate().isNotEmpty) {
        await tester.tap(claimGiftFinder);
        await tester.pumpAndSettle();
      }

      // Dialog dismissed
      expect(find.text('Çevrimdışı Kazanç Raporu'), findsNothing);

      // Balance should have increased by bonus income (> 0)
      expect(notifier.state.balance, greaterThan(initialBalance));

      // Advance debounce timer
      await tester.pump(const Duration(milliseconds: 600));
    });

    testWidgets('Does not show multiplier button when earnedIncome == 0',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            locale: const Locale('tr'),
            supportedLocales: const [Locale('tr'), Locale('en')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      DashboardRetentionModals.showOfflineRecapModal(
                        context,
                        {
                          'title': 'Çevrimdışı Kazanç Raporu',
                          'earnedIncome': 0.0,
                          'bulletPoints': [
                            'Herhangi bir gelir oluşmadı',
                          ],
                        },
                      );
                    },
                    child: const Text('Open Modal'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Open Modal
      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Should not have multiplier button
      expect(find.byIcon(Icons.movie_filter_rounded), findsNothing);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

      // Close modal
      await tester.tap(find.byIcon(Icons.check_circle_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Çevrimdışı Kazanç Raporu'), findsNothing);
    });
  });
}
