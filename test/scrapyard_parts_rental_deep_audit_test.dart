import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/localization/translations/ar_translations.dart';
import 'package:galeriden/core/localization/translations/de_translations.dart';
import 'package:galeriden/core/localization/translations/en_translations.dart';
import 'package:galeriden/core/localization/translations/es_translations.dart';
import 'package:galeriden/core/localization/translations/pt_translations.dart';
import 'package:galeriden/core/localization/translations/ru_translations.dart';
import 'package:galeriden/core/localization/translations/tr_translations.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/rental_agreement_model.dart';
import 'package:galeriden/data/models/scrapyard_model.dart';
import 'package:galeriden/domain/usecases/rental_progression_engine.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    container = ProviderContainer();
    // Maintain widget test timer hygiene
    container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
  });

  tearDown(() {
    container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
    container.dispose();
  });

  CarModel createSampleCar({
    String id = 'car_test_1',
    String brand = 'Vosgen',
    String modelName = 'Golf Sekiz',
    double baseValue = 500000,
    double purchasePrice = 450000,
    bool isRented = false,
    bool isConsignment = false,
    bool isLocked = false,
    bool isBarnFind = false,
    double engineCond = 80.0,
    double transmissionCond = 80.0,
    double? customListingPrice,
  }) {
    return CarModel(
      id: id,
      brand: brand,
      modelName: modelName,
      modelYear: 2022,
      bodyType: 'Hatchback',
      colorHex: '#FFFFFF',
      baseMarketValue: baseValue,
      currentPurchasePrice: isConsignment ? 0.0 : purchasePrice,
      isRented: isRented,
      isConsignment: isConsignment,
      isLockedInShowcase: isLocked,
      isBarnFind: isBarnFind,
      isBarnFindRestored: false,
      customListingPrice: customListingPrice,
      expertise: ExpertiseReport(
        engineCondition: engineCond,
        transmissionCondition: transmissionCond,
        tramerAmount: 0,
        mileage: 45000,
        isMileageTampered: false,
        bodyParts: {},
      ),
    );
  }

  ScrapyardCar createSampleScrapCar({
    String id = 'scrap_test_1',
    String brand = 'Vosgen',
    String modelName = 'Golf Hurda',
    double price = 50000,
    bool isPurchased = false,
  }) {
    return ScrapyardCar(
      id: id,
      brand: brand,
      modelName: modelName,
      modelYear: 2015,
      scrapPrice: price,
      estimatedPartTotalValue: 45000,
      damageNote: 'Ağır hasarlı motor kazalı',
      chassisScrapValue: 15000,
      surpriseFindItem: 'Eski Kasetçalar',
      surpriseFindValue: 3500,
      isPurchased: isPurchased,
      parts: [
        SalvagedPart(
          id: 'part_engine_1',
          name: '2.0 TDI Motor Bloğu',
          category: 'engine',
          carModelName: '$brand $modelName',
          conditionPercent: 65,
          tier: PartQualityTier.usable,
          estimatedValue: 25000,
        ),
        SalvagedPart(
          id: 'part_trans_1',
          name: 'DSG Şanzıman',
          category: 'transmission',
          carModelName: '$brand $modelName',
          conditionPercent: 70,
          tier: PartQualityTier.usable,
          estimatedValue: 20000,
        ),
      ],
    );
  }

  group('Scrapyard Lifecycle & Dismantling Deep Tests', () {
    test('buyScrapCar applies trust discount and deducts money correctly', () {
      final notifier = container.read(gameProvider.notifier);
      final scrapCar = createSampleScrapCar(id: 'scrap_1', price: 100000);

      notifier.state = notifier.state.copyWith(
        balance: 200000,
        npcRelationships: {'cikmaci_ibo': 80},
        scrapyardCars: [scrapCar],
      );

      final success = notifier.buyScrapCar('scrap_1');
      expect(success, isTrue);

      final updatedGame = container.read(gameProvider);
      final purchasedCar =
          updatedGame.scrapyardCars.firstWhere((c) => c.id == 'scrap_1');

      expect(purchasedCar.isPurchased, isTrue);
      // Çıkmacı İbo trust discount is 25% (0.75 * 100,000 = 75,000 -> 200,000 - 75,000 = 125,000)
      expect(updatedGame.balance, equals(125000));
    });

    test('buyScrapCar fails gracefully when balance is insufficient', () {
      final notifier = container.read(gameProvider.notifier);
      final scrapCar = createSampleScrapCar(id: 'scrap_poor', price: 100000);

      notifier.state = notifier.state.copyWith(
        balance: 10000,
        scrapyardCars: [scrapCar],
      );

      final success = notifier.buyScrapCar('scrap_poor');
      expect(success, isFalse);
      expect(container.read(gameProvider).balance, equals(10000));
    });

    test('buyAndDismantleScrapCar bulk dismantles scrap car and populates inventory', () {
      final notifier = container.read(gameProvider.notifier);
      final scrapCar = createSampleScrapCar(id: 'scrap_bulk', price: 50000);

      notifier.state = notifier.state.copyWith(
        balance: 200000,
        scrapyardCars: [scrapCar],
        salvagedParts: [],
      );

      final result = notifier.buyAndDismantleScrapCar('scrap_bulk');
      expect(result.success, isTrue);

      final updatedGame = container.read(gameProvider);
      expect(updatedGame.scrapyardCars.any((c) => c.id == 'scrap_bulk'), isFalse);
      expect(updatedGame.balance, isNot(equals(200000)));
    });

    test('dismantleSinglePartFromScrap extracts un-dismantled part only if car is purchased', () {
      final notifier = container.read(gameProvider.notifier);
      final scrapCar = createSampleScrapCar(
        id: 'scrap_single',
        price: 50000,
        isPurchased: false,
      );

      notifier.state = notifier.state.copyWith(
        balance: 100000,
        scrapyardCars: [scrapCar],
        salvagedParts: [],
      );

      // Attempt dismantle before purchase -> must fail
      var result = notifier.dismantleSinglePartFromScrap(
        'scrap_single',
        'part_engine_1',
        forceSuccess: true,
      );
      expect(result.success, isFalse);

      // Mark purchased
      notifier.state = notifier.state.copyWith(
        scrapyardCars: [scrapCar.copyWith(isPurchased: true)],
      );

      result = notifier.dismantleSinglePartFromScrap(
        'scrap_single',
        'part_engine_1',
        forceSuccess: true,
      );
      expect(result.success, isTrue);
      expect(result.isSalvaged, isTrue);

      final updated = container.read(gameProvider);
      expect(updated.salvagedParts.any((p) => p.id == 'part_engine_1'), isTrue);
    });

    test('crushChassisToScrapMetal recovers scrap value plus surprise item', () {
      final notifier = container.read(gameProvider.notifier);
      final scrapCar = createSampleScrapCar(
        id: 'scrap_crush',
        price: 50000,
        isPurchased: true,
      );

      notifier.state = notifier.state.copyWith(
        balance: 100000,
        scrapyardCars: [scrapCar],
      );

      final result = notifier.crushChassisToScrapMetal('scrap_crush');
      expect(result.success, isTrue);

      final updated = container.read(gameProvider);
      expect(updated.scrapyardCars.any((c) => c.id == 'scrap_crush'), isFalse);
      // 100,000 + 15,000 scrap metal + 3,500 surprise item = 118,500
      expect(updated.balance, equals(118500));
    });
  });

  group('Salvaged Parts Refurbishing & B2B Orders', () {
    test('refurbishSalvagedPart restores condition and upgrades part', () {
      final notifier = container.read(gameProvider.notifier);
      final part = SalvagedPart(
        id: 'part_refurb',
        name: 'Turbo Şarj',
        category: 'turbo',
        carModelName: 'Vosgen Golf',
        conditionPercent: 40,
        tier: PartQualityTier.worn,
        estimatedValue: 15000,
      );

      notifier.state = notifier.state.copyWith(
        balance: 50000,
        salvagedParts: [part],
      );

      final success = notifier.refurbishSalvagedPart('part_refurb');
      expect(success, isTrue);

      final updated = container.read(gameProvider);
      final restoredPart =
          updated.salvagedParts.firstWhere((p) => p.id == 'part_refurb');

      expect(restoredPart.conditionPercent, greaterThan(40));
      expect(updated.balance, lessThan(50000));
    });

    test('fulfillB2BPartOrder validates quality tier, brand and awards payout + rep', () {
      final notifier = container.read(gameProvider.notifier);
      final order = B2BPartOrder(
        id: 'order_1',
        mechanicName: 'Kaportacı Şükrü',
        requiredCategory: 'engine',
        requiredCarBrand: 'Vosgen',
        minQualityTier: PartQualityTier.usable,
        offeredPrice: 40000,
        reputationReward: 15,
        description: 'Vosgen motor parçası',
        expiresInDays: 3,
      );

      final matchingPart = SalvagedPart(
        id: 'part_b2b_match',
        name: 'Vosgen 2.0 TDI Blok',
        category: 'engine',
        carModelName: 'Vosgen Passat',
        conditionPercent: 75,
        tier: PartQualityTier.good,
        estimatedValue: 20000,
      );

      notifier.state = notifier.state.copyWith(
        balance: 100000,
        reputationScore: 50,
        b2bPartOrders: [order],
        salvagedParts: [matchingPart],
      );

      final success = notifier.fulfillB2BPartOrder('order_1', 'part_b2b_match');
      expect(success, isTrue);

      final updated = container.read(gameProvider);
      expect(
        updated.b2bPartOrders.firstWhere((o) => o.id == 'order_1').isCompleted,
        isTrue,
      );
      expect(updated.salvagedParts.any((p) => p.id == 'part_b2b_match'), isFalse);
      expect(updated.balance, equals(140000));
      expect(updated.reputationScore, equals(65));
    });
  });

  group('Part Installation & Barn Find Trigger', () {
    test('installPartToCar rejects rented and consignment cars', () {
      final notifier = container.read(gameProvider.notifier);
      final rentedCar = createSampleCar(id: 'car_rented', isRented: true);
      final consignmentCar =
          createSampleCar(id: 'car_consignment', isConsignment: true);
      final regularCar = createSampleCar(id: 'car_regular', isRented: false);

      final part = SalvagedPart(
        id: 'part_engine_inst',
        name: 'Vosgen Motor',
        category: 'engine',
        carModelName: 'Vosgen Golf',
        conditionPercent: 90,
        tier: PartQualityTier.good,
        estimatedValue: 25000,
      );

      notifier.state = notifier.state.copyWith(
        ownedCars: [rentedCar, consignmentCar, regularCar],
        salvagedParts: [part],
      );

      expect(notifier.installPartToCar('part_engine_inst', 'car_rented'), isFalse);
      expect(notifier.installPartToCar('part_engine_inst', 'car_consignment'), isFalse);
      expect(notifier.installPartToCar('part_engine_inst', 'car_regular'), isTrue);
    });

    test('installPartToCar triggers barn find restoration when both engine and transmission reach >= 95%', () {
      final notifier = container.read(gameProvider.notifier);
      final barnFindCar = createSampleCar(
        id: 'barn_car',
        isBarnFind: true,
        engineCond: 94.0,
        transmissionCond: 96.0,
      );

      final pristineEngine = SalvagedPart(
        id: 'pristine_eng',
        name: 'Vosgen Pristine Engine',
        category: 'engine',
        carModelName: 'Vosgen Golf',
        conditionPercent: 100,
        tier: PartQualityTier.pristine,
        estimatedValue: 40000,
      );

      notifier.state = notifier.state.copyWith(
        ownedCars: [barnFindCar],
        salvagedParts: [pristineEngine],
      );

      final success = notifier.installPartToCar('pristine_eng', 'barn_car');
      expect(success, isTrue);

      final updatedCar =
          container.read(gameProvider).ownedCars.firstWhere((c) => c.id == 'barn_car');
      expect(updatedCar.isBarnFindRestored, isTrue);
      expect(updatedCar.isRare, isTrue);
      expect(updatedCar.expertise.engineCondition, greaterThanOrEqualTo(95.0));
    });
  });

  group('Rent a Car Fleet Lifecycle & Daily Progression Engine', () {
    test('rentCar enforces daily rate cap, clears custom listing price and creates rental agreement', () {
      final notifier = container.read(gameProvider.notifier);
      final car = createSampleCar(
        id: 'car_rent_target',
        purchasePrice: 500000,
        customListingPrice: 550000,
      );

      notifier.state = notifier.state.copyWith(
        ownedCars: [car],
        activeRentals: [],
      );

      // Attempt to rent with excessive rate (max for standard is 0.012 -> 6,000)
      final success = notifier.rentCar(
        'car_rent_target',
        10000,
        renterType: 'individual',
        hasInsurance: true,
      );
      expect(success, isTrue);

      final updated = container.read(gameProvider);
      expect(updated.activeRentals.length, equals(1));

      final agreement = updated.activeRentals.first;
      expect(agreement.carId, equals('car_rent_target'));
      expect(agreement.dailyRate, lessThanOrEqualTo(6000));
      expect(agreement.hasInsurance, isTrue);

      final rentedCar = updated.ownedCars.firstWhere((c) => c.id == 'car_rent_target');
      expect(rentedCar.isRented, isTrue);
      expect(rentedCar.isListed, isFalse);
      expect(rentedCar.customListingPrice, isNull);
    });

    test('returnRentedCar ends agreement and frees car back to garage', () {
      final notifier = container.read(gameProvider.notifier);
      final car = createSampleCar(id: 'car_to_return', isRented: true);
      final agreement = RentalAgreement(
        id: 'agree_1',
        carId: 'car_to_return',
        dailyRate: 2500,
        renterName: 'Ahmet Bey',
        renterType: 'individual',
        hasInsurance: true,
        insuranceDailyFee: 500,
      );

      notifier.state = notifier.state.copyWith(
        ownedCars: [car],
        activeRentals: [agreement],
      );

      final success = notifier.returnRentedCar('agree_1');
      expect(success, isTrue);

      final updated = container.read(gameProvider);
      expect(updated.activeRentals.isEmpty, isTrue);
      final freedCar =
          updated.ownedCars.firstWhere((c) => c.id == 'car_to_return');
      expect(freedCar.isRented, isFalse);
    });

    test('RentalProgressionEngine processes daily rental net revenue and tracks metrics', () {
      final car = createSampleCar(id: 'car_prog', purchasePrice: 400000);
      final agreement = RentalAgreement(
        id: 'agree_prog',
        carId: 'car_prog',
        dailyRate: 3000,
        renterName: 'Murat Bey',
        renterType: 'corporate',
        hasInsurance: true,
        insuranceDailyFee: 400,
      );

      final (newBalance, newCars, newRentals, newEvents, newOffers) =
          RentalProgressionEngine.processDailyRentals(
        balance: 50000,
        cars: [car],
        rentals: [agreement],
        events: [],
        incomingOffers: [],
        random: Random(42),
      );

      expect(newEvents, isNotNull);
      // Net income: 3,000 - 400 = 2,600 -> Balance becomes 52,600
      expect(newBalance, equals(52600));

      final updatedAgreement = newRentals.first;
      expect(updatedAgreement.rentedDays, equals(1));
      expect(updatedAgreement.totalEarned, equals(2600));
    });

    test('syncRentalState safely heals orphaned agreements or inconsistent car states', () {
      final notifier = container.read(gameProvider.notifier);
      final ghostAgreement = RentalAgreement(
        id: 'ghost_agree',
        carId: 'car_non_existent',
        dailyRate: 1500,
        renterName: 'Hayalet Müşteri',
        renterType: 'individual',
      );

      final mismatchedCar = createSampleCar(id: 'car_mismatch', isRented: true);

      notifier.state = notifier.state.copyWith(
        ownedCars: [mismatchedCar],
        activeRentals: [ghostAgreement],
      );

      notifier.syncRentalState();

      final updated = container.read(gameProvider);
      // Ghost agreement without car must be pruned
      expect(updated.activeRentals.any((a) => a.id == 'ghost_agree'), isFalse);
      // Car marked rented without active agreement must be reset
      final fixedCar =
          updated.ownedCars.firstWhere((c) => c.id == 'car_mismatch');
      expect(fixedCar.isRented, isFalse);
    });
  });

  group('7-Language & Invariant Hygiene Checks', () {
    test('All 11 newly added scrapyard & rental keys exist across all 7 languages', () {
      final keysToCheck = [
        'scrap_badge_fresh_wreck',
        'scrap_cat_all',
        'scrap_cat_engine',
        'scrap_cat_transmission',
        'scrap_cat_ecu',
        'scrap_cat_brakes',
        'scrap_cat_bodywork',
        'scrap_no_installable_cars',
        'scrap_install_success_toast',
        'scrap_b2b_missing_part_error',
        'scrap_b2b_fulfilled_toast',
      ];

      final maps = <String, Map<String, String>>{
        'tr': trTranslations,
        'en': enTranslations,
        'de': deTranslations,
        'pt': ptTranslations,
        'es': esTranslations,
        'ru': ruTranslations,
        'ar': arTranslations,
      };

      for (final entry in maps.entries) {
        for (final key in keysToCheck) {
          expect(
            entry.value.containsKey(key),
            isTrue,
            reason: 'Language ${entry.key} is missing key $key',
          );
          expect(
            entry.value[key]!.trim().isNotEmpty,
            isTrue,
            reason: 'Language ${entry.key} has empty value for key $key',
          );
        }
      }
    });

    test('Zero unicode emojis and zero parentheses invariant check in new translation strings', () {
      final keysToCheck = [
        'scrap_badge_fresh_wreck',
        'scrap_cat_all',
        'scrap_cat_engine',
        'scrap_cat_transmission',
        'scrap_cat_ecu',
        'scrap_cat_brakes',
        'scrap_cat_bodywork',
        'scrap_no_installable_cars',
        'scrap_install_success_toast',
        'scrap_b2b_missing_part_error',
        'scrap_b2b_fulfilled_toast',
      ];

      final emojiRegex = RegExp(
        r'[\u{1F300}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}\u{1F600}-\u{1F64F}\u{1F680}-\u{1F6FF}]',
        unicode: true,
      );

      final maps = <String, Map<String, String>>{
        'tr': trTranslations,
        'en': enTranslations,
        'de': deTranslations,
        'pt': ptTranslations,
        'es': esTranslations,
        'ru': ruTranslations,
        'ar': arTranslations,
      };

      for (final entry in maps.entries) {
        for (final key in keysToCheck) {
          final val = entry.value[key]!;
          expect(
            emojiRegex.hasMatch(val),
            isFalse,
            reason:
                'Language ${entry.key} contains unicode emoji in key $key: "$val"',
          );
          expect(
            val.contains('(') || val.contains(')'),
            isFalse,
            reason:
                'Language ${entry.key} contains parentheses in key $key: "$val"',
          );
        }
      }
    });
  });
}
