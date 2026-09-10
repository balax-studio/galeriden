import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galeriden/core/utils/color_parser.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/game_event_model.dart';
import 'package:galeriden/domain/usecases/dramatic_card_engine.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Events & Narrative Audit Tests (Task 6: A6, B5, B7, C3)', () {
    test('B5: ColorParser parses hex codes robustly without exception', () {
      final c1 = ColorParser.parseCarColor('#D90429');
      expect(c1.r, greaterThan(0));

      final c2 = ColorParser.parseCarColor('0xFF112233');
      expect(c2.a, equals(1.0));

      final c3 = ColorParser.parseCarColor('AABBCC');
      expect(c3.b, greaterThan(0));

      final c4 = ColorParser.parseCarColor(null);
      expect(c4, equals(ColorParser.defaultCarFallbackColor));

      final c5 = ColorParser.parseCarColor('invalid_hex');
      expect(c5, equals(ColorParser.defaultCarFallbackColor));
    });

    test('C3 & game_event_model: GameEventChoice serialization with mechanics', () {
      const choice = GameEventChoice(
        label: 'Cezayı Kabul Et • -60.000 ₺',
        resultText: 'Yediemine çekildi',
        balanceChange: -60000.0,
        reputationChange: -20,
        targetCarEffect: 'impound',
        sideBusinessId: 'car_wash',
        sideBusinessDowntimeDays: 2,
        staffMoraleChange: -10,
      );

      final json = choice.toJson();
      expect(json['targetCarEffect'], equals('impound'));
      expect(json['sideBusinessId'], equals('car_wash'));
      expect(json['sideBusinessDowntimeDays'], equals(2));
      expect(json['staffMoraleChange'], equals(-10));

      final deserialized = GameEventChoice.fromJson(json);
      expect(deserialized.targetCarEffect, equals('impound'));
      expect(deserialized.sideBusinessId, equals('car_wash'));
      expect(deserialized.sideBusinessDowntimeDays, equals(2));
      expect(deserialized.staffMoraleChange, equals(-10));
    });

    test('A6 & C3: resolveDramaticCardChoice executes consequences properly', () {
      final container = ProviderContainer(
        overrides: [
          gameProvider.overrideWith((ref) => GameNotifier()),
        ],
      );
      addTearDown(() {
        container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
        container.dispose();
      });

      final notifier = container.read(gameProvider.notifier);

      final car = CarModel(
        id: 'test_car_1',
        brand: 'Vosgen',
        modelName: 'Polo',
        modelYear: 2020,
        bodyType: 'Hatchback',
        colorHex: '#FFFFFF',
        baseMarketValue: 200000,
        currentPurchasePrice: 190000,
        maintenanceCost: 0,
        isDetailedCleaned: true,
        isWashed: true,
        isPolished: false,
        isRare: false,
        expertise: ExpertiseReport(
          engineCondition: 100,
          transmissionCondition: 100,
          tramerAmount: 0,
          mileage: 40000,
          isMileageTampered: false,
          bodyParts: {'Kaput': PartStatus.original},
        ),
        declarationType: ListingDeclarationType.honest,
      );

      notifier.state = notifier.state.copyWith(
        balance: 50000.0,
        reputationScore: 50,
        ownedCars: [car],
      );

      final card = DramaticCardEngine.generateDailyDilemma(1, notifier.state);
      final choice = card.choices.first;

      final initialBalance = notifier.state.balance;
      final initialReputation = notifier.state.reputation;
      final initialXP = notifier.state.experience;

      final result = notifier.resolveDramaticCardChoice(
        card: card,
        choice: choice,
        fixedRoll: 0.0,
      );

      expect(
        notifier.state.balance,
        equals(initialBalance - choice.upfrontCost + result.outcome.moneyDelta),
      );
      expect(
        notifier.state.reputation,
        equals((initialReputation + result.outcome.reputationDelta).clamp(0, 1000)),
      );
      expect(
        notifier.state.experience,
        equals(initialXP + result.outcome.xpReward),
      );
    });
  });
}

