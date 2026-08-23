import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/domain/usecases/black_market_container_engine.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:galeriden/presentation/widgets/mini_games/mystery_container_unboxing_modal.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('BlackMarketContainerEngine Tests', () {
    test('Drop rates and vehicle price intervals match requested probabilities', () {
      int standardCount = 0;
      int rareCount = 0;
      int exoticCount = 0;
      int hyperCount = 0;

      final random = math.Random(42);

      for (int i = 0; i < 2000; i++) {
        final result = BlackMarketContainerEngine.generateContainerDrop(
          currentDay: 10,
          random: random,
        );

        final car = result.car;
        expect(car.blackMarketRiskPercent, equals(0));
        expect(car.expertise.engineCondition, greaterThanOrEqualTo(90));
        expect(car.baseMarketValue, greaterThan(0));

        switch (result.tier) {
          case MysteryContainerTier.standard:
            standardCount++;
            expect(car.baseMarketValue, greaterThanOrEqualTo(2000000));
            expect(car.baseMarketValue, lessThanOrEqualTo(4200000));
            break;
          case MysteryContainerTier.rare:
            rareCount++;
            expect(car.baseMarketValue, greaterThanOrEqualTo(4200000));
            expect(car.baseMarketValue, lessThanOrEqualTo(6500000));
            break;
          case MysteryContainerTier.exotic:
            exoticCount++;
            expect(car.baseMarketValue, greaterThanOrEqualTo(7000000));
            expect(car.baseMarketValue, lessThanOrEqualTo(10500000));
            break;
          case MysteryContainerTier.legendaryHyper:
            hyperCount++;
            expect(car.baseMarketValue, greaterThanOrEqualTo(13500000));
            expect(car.baseMarketValue, lessThanOrEqualTo(22000000));
            break;
        }
      }

      // Expected: Standard 15%, Rare 40%, Exotic 30%, Hyper 15%
      final standardPct = standardCount / 2000;
      final rarePct = rareCount / 2000;
      final exoticPct = exoticCount / 2000;
      final hyperPct = hyperCount / 2000;

      expect(standardPct, closeTo(0.15, 0.04));
      expect(rarePct, closeTo(0.40, 0.04));
      expect(exoticPct, closeTo(0.30, 0.04));
      expect(hyperPct, closeTo(0.15, 0.04));
    });

    test('Cooldown days remaining logic works correctly', () {
      expect(BlackMarketContainerEngine.daysRemaining(lastPurchaseDay: 0, currentDay: 1), equals(0));
      expect(BlackMarketContainerEngine.isAvailable(lastPurchaseDay: 0, currentDay: 1), isTrue);

      expect(BlackMarketContainerEngine.daysRemaining(lastPurchaseDay: 1, currentDay: 1), equals(7));
      expect(BlackMarketContainerEngine.isAvailable(lastPurchaseDay: 1, currentDay: 1), isFalse);

      expect(BlackMarketContainerEngine.daysRemaining(lastPurchaseDay: 1, currentDay: 4), equals(4));
      expect(BlackMarketContainerEngine.isAvailable(lastPurchaseDay: 1, currentDay: 4), isFalse);

      expect(BlackMarketContainerEngine.daysRemaining(lastPurchaseDay: 1, currentDay: 7), equals(1));
      expect(BlackMarketContainerEngine.isAvailable(lastPurchaseDay: 1, currentDay: 7), isFalse);

      expect(BlackMarketContainerEngine.daysRemaining(lastPurchaseDay: 1, currentDay: 8), equals(0));
      expect(BlackMarketContainerEngine.isAvailable(lastPurchaseDay: 1, currentDay: 8), isTrue);
    });
  });

  group('DealershipModel Serialization Tests', () {
    test('lastMysteryContainerPurchaseDay serializes and deserializes', () {
      final model = DealershipModel.initial().copyWith(
        currentDay: 15,
        lastMysteryContainerPurchaseDay: 10,
      );

      expect(model.mysteryContainerDaysRemaining, equals(2));
      expect(model.isMysteryContainerAvailable, isFalse);

      final json = model.toJson();
      expect(json['lastMysteryContainerPurchaseDay'], equals(10));

      final restored = DealershipModel.fromJson(json);
      expect(restored.lastMysteryContainerPurchaseDay, equals(10));
      expect(restored.mysteryContainerDaysRemaining, equals(2));
    });
  });

  group('GameMarketMixin buyMysteryContainer State Tests', () {
    test('buyMysteryContainer succeeds when conditions are met and enforces 7-day cooldown', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      // Stop periodic timer to keep test clean
      notifier.stopPeriodicOrganicOfferTimer();

      final initialCarCount = container.read(gameProvider).ownedCars.length;

      // Give player plenty of cash
      notifier.addMoney(10000000);

      // Purchase container
      final result1 = notifier.buyMysteryContainer(random: math.Random(1));
      expect(result1, isNotNull);
      expect(container.read(gameProvider).ownedCars.length, equals(initialCarCount + 1));
      expect(container.read(gameProvider).lastMysteryContainerPurchaseDay, equals(1));
      expect(container.read(gameProvider).isMysteryContainerAvailable, isFalse);

      // Attempt immediate second purchase on same day -> should fail
      final result2 = notifier.buyMysteryContainer(random: math.Random(2));
      expect(result2, isNull);
      expect(container.read(gameProvider).ownedCars.length, equals(initialCarCount + 1));

      container.dispose();
    });

    test('buyMysteryContainer fails when balance is insufficient', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.stopPeriodicOrganicOfferTimer();

      final initialCarCount = container.read(gameProvider).ownedCars.length;

      // Ensure balance is low (< 3.5M)
      final currentBal = container.read(gameProvider).balance;
      notifier.deductBalance(currentBal); // 0 balance

      final result = notifier.buyMysteryContainer();
      expect(result, isNull);
      expect(container.read(gameProvider).ownedCars.length, equals(initialCarCount));

      container.dispose();
    });
  });

  group('MysteryContainerUnboxingModal Widget Tests', () {
    testWidgets('Renders unboxing modal and triggers break seal animation flow', (tester) async {
      final result = BlackMarketContainerEngine.generateContainerDrop(
        currentDay: 1,
        random: math.Random(99),
      );

      bool claimed = false;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('tr'), Locale('en')],
          locale: const Locale('tr'),
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  MysteryContainerUnboxingModal.show(
                    context,
                    result: result,
                    onClaim: () {
                      claimed = true;
                    },
                  );
                },
                child: const Text('Open Modal'),
              ),
            ),
          ),
        ),
      );

      // Tap button to show dialog
      await tester.tap(find.text('Open Modal'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify Initial Stage 0 (Sealed Container)
      expect(find.text('MÜHRÜ KIR & KAPAĞI AÇ'), findsOneWidget);
      expect(find.text('İTHAL LİMAN SEVKİYATI • MÜHÜRLÜ KONTEYNER'), findsOneWidget);

      // Tap Break Seal
      await tester.tap(find.text('MÜHRÜ KIR & KAPAĞI AÇ'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Advance through animation stages (2300ms shake + 1100ms reveal)
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pump(const Duration(milliseconds: 1000));

      // Check car revealed with claim button
      expect(find.text('ARACI GARAJA ÇEK'), findsOneWidget);
      expect(find.text(result.car.modelName), findsOneWidget);
      expect(find.text('${result.car.modelYear} ${result.car.brand}'), findsOneWidget);

      // Tap Claim
      await tester.tap(find.text('ARACI GARAJA ÇEK'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(claimed, isTrue);
    });
  });
}
