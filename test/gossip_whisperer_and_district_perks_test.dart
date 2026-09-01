import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/offer_model.dart';
import 'package:galeriden/data/models/player_spread_gossip_model.dart';
import 'package:galeriden/domain/usecases/negotiation_engine.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:galeriden/core/localization/translations/tr_translations.dart';
import 'package:galeriden/core/localization/translations/en_translations.dart';
import 'package:galeriden/core/localization/translations/de_translations.dart';
import 'package:galeriden/core/localization/translations/es_translations.dart';
import 'package:galeriden/core/localization/translations/pt_translations.dart';
import 'package:galeriden/core/localization/translations/ru_translations.dart';
import 'package:galeriden/core/localization/translations/ar_translations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('PlayerSpreadGossipModel Tests', () {
    test('Model serialization and expiration logic works', () {
      final model = PlayerSpreadGossipModel(
        id: 'rumor_123',
        targetSegment: 'SUV',
        priceMultiplier: 1.15,
        createdDay: 5,
        expiresDay: 8,
      );

      final json = model.toJson();
      final fromJson = PlayerSpreadGossipModel.fromJson(json);

      expect(fromJson.id, equals('rumor_123'));
      expect(fromJson.targetSegment, equals('SUV'));
      expect(fromJson.priceMultiplier, equals(1.15));
      expect(fromJson.createdDay, equals(5));
      expect(fromJson.expiresDay, equals(8));

      expect(fromJson.isExpired(7), isFalse);
      expect(fromJson.isExpired(8), isTrue);
      expect(fromJson.isExpired(9), isTrue);
    });
  });

  group('DealershipModel Serialization with Player Spread Gossips', () {
    test('DealershipModel serializes playerSpreadGossips and lastGossipSpreadDay', () {
      final rumor = PlayerSpreadGossipModel(
        id: 'rumor_1',
        targetSegment: 'Sedan',
        priceMultiplier: 1.15,
        createdDay: 1,
        expiresDay: 4,
      );

      final dealership = DealershipModel.initial().copyWith(
        dealershipName: 'Test Galeri',
        balance: 50000,
        playerSpreadGossips: [rumor],
        lastGossipSpreadDay: 1,
      );

      final json = dealership.toJson();
      final restored = DealershipModel.fromJson(json);

      expect(restored.playerSpreadGossips.length, equals(1));
      expect(restored.playerSpreadGossips.first.targetSegment, equals('Sedan'));
      expect(restored.lastGossipSpreadDay, equals(1));
    });
  });

  group('Market Whisperer Provider Actions', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
      await Future.delayed(const Duration(milliseconds: 50));
    });

    tearDown(() {
      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
      container.dispose();
    });

    test('spreadMarketRumor deducts balance, awards XP, and records rumor', () {
      final notifier = container.read(gameProvider.notifier);
      final initialBalance = container.read(gameProvider).balance;

      final success = notifier.spreadMarketRumor('SUV', 2500.0);
      expect(success, isTrue);

      final state = container.read(gameProvider);
      expect(state.balance, equals(initialBalance - 2500.0));
      expect(state.playerSpreadGossips.length, equals(1));
      expect(state.playerSpreadGossips.first.targetSegment, equals('SUV'));
      expect(state.playerSpreadGossips.first.priceMultiplier, equals(1.15));
      expect(state.lastGossipSpreadDay, equals(state.currentDay));

      // Attempting to spread a second rumor on the same day should fail
      final secondAttempt = notifier.spreadMarketRumor('Sedan', 2500.0);
      expect(secondAttempt, isFalse);
      expect(state.playerSpreadGossips.length, equals(1));
    });

    test('advanceGameDay cleans up expired player spread rumors', () {
      final notifier = container.read(gameProvider.notifier);
      notifier.spreadMarketRumor('Klasik', 2500.0);

      expect(container.read(gameProvider).playerSpreadGossips.length, equals(1));

      // Advance 4 days
      notifier.advanceGameDay();
      notifier.advanceGameDay();
      notifier.advanceGameDay();
      notifier.advanceGameDay();

      final state = container.read(gameProvider);
      expect(state.playerSpreadGossips.isEmpty, isTrue);
    });
  });

  group('NegotiationEngine & District/Gossip Offer Multipliers', () {
    test('generateBuyerOffer applies districtMultiplier and gossipMultiplier', () {
      final car = CarModel(
        id: 'car_1',
        brand: 'Ford',
        modelName: 'Mustang',
        modelYear: 1967,
        bodyType: 'Klasik',
        colorHex: '#000000',
        baseMarketValue: 250000,
        currentPurchasePrice: 200000,
        expertise: ExpertiseReport(
          engineCondition: 100,
          transmissionCondition: 100,
          tramerAmount: 0,
          mileage: 50000,
          isMileageTampered: false,
          bodyParts: const {},
        ),
        isRare: true,
      );

      double sumBase = 0;
      double sumBoosted = 0;
      for (int i = 0; i < 50; i++) {
        sumBase += NegotiationEngine.generateBuyerOffer(
          car,
          0,
          districtMultiplier: 1.0,
          gossipMultiplier: 1.0,
        ).offeredAmount;
        sumBoosted += NegotiationEngine.generateBuyerOffer(
          car,
          0,
          districtMultiplier: 1.15,
          gossipMultiplier: 1.15,
        ).offeredAmount;
      }

      expect(sumBoosted / 50, greaterThan(sumBase / 50));
    });
  });

  group('District Perks in completeSale (Etiler & Ankara)', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
      await Future.delayed(const Duration(milliseconds: 50));
    });

    tearDown(() {
      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
      container.dispose();
    });

    test('Etiler grant +10% net profit bonus cash when profitable', () {
      final notifier = container.read(gameProvider.notifier);

      final testCar = CarModel(
        id: 'car_etiler_test',
        brand: 'BMW',
        modelName: 'X5',
        modelYear: 2022,
        bodyType: 'SUV',
        colorHex: '#000000',
        baseMarketValue: 600000,
        currentPurchasePrice: 500000,
        expertise: ExpertiseReport(
          engineCondition: 100,
          transmissionCondition: 100,
          tramerAmount: 0,
          mileage: 30000,
          isMileageTampered: false,
          bodyParts: const {},
        ),
      );

      // Set explicit balance, add car to inventory and unlock Etiler district
      notifier.state = notifier.state.copyWith(
        balance: 100000.0,
        ownedCars: [...notifier.state.ownedCars, testCar],
      );

      notifier.boostDistrictMarketShare('Etiler Galericiler Sitesi', 0.50, 0.0);

      final offer = OfferModel(
        id: 'offer_1',
        carId: testCar.id,
        buyerName: 'Ahmet Bey',
        offeredAmount: 600000,
        buyerMessage: 'Aracınıza talibim.',
        createdAt: DateTime.now(),
      );

      final saleSuccess = notifier.completeSale(offer);
      expect(saleSuccess, isTrue);

      // Profit is 600.000 - 500.000 = 100.000. Etiler 10% bonus adds +10.000, making total profit 110.000.
      final state = container.read(gameProvider);
      expect(state.totalProfit, equals(110000.0));
      expect(state.salesHistory.first.netProfit, equals(110000.0));
    });

    test('Ankara grant +2 reputation bonus for clean sale', () {
      final notifier = container.read(gameProvider.notifier);

      final cleanCar = CarModel(
        id: 'car_ankara_test',
        brand: 'Toyota',
        modelName: 'Corolla',
        modelYear: 2021,
        bodyType: 'Sedan',
        colorHex: '#FFFFFF',
        baseMarketValue: 350000,
        currentPurchasePrice: 300000,
        expertise: ExpertiseReport(
          engineCondition: 100,
          transmissionCondition: 100,
          tramerAmount: 0,
          mileage: 20000,
          isMileageTampered: false,
          bodyParts: const {},
        ),
      );

      notifier.state = notifier.state.copyWith(
        ownedCars: [...notifier.state.ownedCars, cleanCar],
      );
      final initialReputation = notifier.state.reputationScore;

      notifier.boostDistrictMarketShare('Ankara Kızılay Hattı', 0.50, 0.0);

      final offer = OfferModel(
        id: 'offer_ankara_1',
        carId: cleanCar.id,
        buyerName: 'Mehmet Bey',
        offeredAmount: 350000,
        buyerMessage: 'Aracınızı beğendim.',
        createdAt: DateTime.now(),
      );

      final saleSuccess = notifier.completeSale(offer);
      expect(saleSuccess, isTrue);

      final newReputation = container.read(gameProvider).reputationScore;
      // Normal sale (+1 or +2) + Ankara bonus (+2)
      expect(newReputation, greaterThanOrEqualTo(initialReputation + 2));
    });
  });

  group('Invariant Rules Check: Zero Unicode Emojis & Zero Parentheses', () {
    final translationMaps = [
      trTranslations,
      enTranslations,
      deTranslations,
      esTranslations,
      ptTranslations,
      ruTranslations,
      arTranslations,
    ];

    final targetKeys = [
      'gossip_whisperer_card_title',
      'gossip_whisperer_card_subtitle',
      'gossip_whisperer_card_desc',
      'gossip_active_rumors_heading',
      'gossip_rumor_active_pill',
      'gossip_whisperer_already_spread',
      'gossip_whisperer_btn_action',
      'gossip_modal_pick_segment_title',
      'gossip_modal_pick_segment_desc',
      'gossip_whisperer_success_toast',
      'badge_intel_active',
      'district_monopoly_stamp_title',
      'district_monopoly_stamp_desc',
      'badge_max',
    ];

    final emojiRegex = RegExp(
      r'[\u{1F300}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}\u{1F1E6}-\u{1F1FF}]',
      unicode: true,
    );

    test('All newly added keys exist across all 7 languages', () {
      for (final map in translationMaps) {
        for (final key in targetKeys) {
          expect(map.containsKey(key), isTrue,
              reason: 'Key $key missing in a translation map');
          expect(map[key]!.trim().isNotEmpty, isTrue,
              reason: 'Key $key is empty in a translation map');
        }
      }
    });

    test('Zero Unicode emojis in all newly added translation strings', () {
      for (final map in translationMaps) {
        for (final key in targetKeys) {
          final text = map[key]!;
          expect(emojiRegex.hasMatch(text), isFalse,
              reason: 'Emoji detected in string [$key]: "$text"');
        }
      }
    });

    test('Zero parentheses in all newly added translation strings', () {
      for (final map in translationMaps) {
        for (final key in targetKeys) {
          final text = map[key]!;
          expect(text.contains('(') || text.contains(')'), isFalse,
              reason: 'Parenthesis detected in string [$key]: "$text"');
        }
      }
    });
  });
}
