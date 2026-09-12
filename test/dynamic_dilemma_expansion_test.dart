import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/sale_record_model.dart';
import 'package:galeriden/domain/usecases/contextual_dilemma_pool.dart';
import 'package:galeriden/domain/usecases/dramatic_card_engine.dart';

void main() {
  group('Dynamic Dilemma Expansion Tests', () {
    test('calculateDynamicGrant: scales dynamically with level and cash deficit', () {
      final freshPlayer = DealershipModel.initial().copyWith(level: 1, balance: 10000.0);
      expect(ContextualDilemmaPool.calculateDynamicGrant(freshPlayer), equals(50000.0));

      final highLevelPlayer = DealershipModel.initial().copyWith(level: 4, balance: 10000.0);
      expect(ContextualDilemmaPool.calculateDynamicGrant(highLevelPlayer), equals(160000.0));

      final debtPlayer = DealershipModel.initial().copyWith(level: 2, balance: -50000.0);
      // level 2 * 40k (80k) + debt (50k) + buffer (25k) = 155k
      expect(ContextualDilemmaPool.calculateDynamicGrant(debtPlayer), equals(155000.0));
    });

    test('crisis_family_legacy: legacy_cash choice grants dynamic funds clearing debt', () {
      final debtState = DealershipModel.initial().copyWith(
        level: 2,
        balance: -30000.0,
      );

      final legacyCard = ContextualDilemmaPool.cashCrisisCards.firstWhere(
        (c) => c.id == 'crisis_family_legacy',
      );
      final cashChoice = legacyCard.choices.firstWhere((ch) => ch.id == 'legacy_cash');

      final result = DramaticCardEngine.resolveChoice(debtState, legacyCard, cashChoice);

      expect(result.updatedState.balance, greaterThan(0.0));
      expect(result.outcome.isDynamicGrant, isTrue);
    });

    test('crisis_family_legacy: legacy_classic_car injects 0-cost heirloom classic vehicle', () {
      final state = DealershipModel.initial().copyWith(
        level: 1,
        balance: 5000.0,
        ownedCars: [],
      );

      final legacyCard = ContextualDilemmaPool.cashCrisisCards.firstWhere(
        (c) => c.id == 'crisis_family_legacy',
      );
      final carChoice = legacyCard.choices.firstWhere((ch) => ch.id == 'legacy_classic_car');

      final result = DramaticCardEngine.resolveChoice(state, legacyCard, carChoice);

      expect(result.updatedState.ownedCars.length, equals(1));
      final heirloom = result.updatedState.ownedCars.first;
      expect(heirloom.brand, equals('Mercedes-Benz'));
      expect(heirloom.currentPurchasePrice, equals(0.0));
      expect(heirloom.isHeroShowcase, isTrue);
      expect(heirloom.baseMarketValue, greaterThan(200000.0));
    });

    test('selectContextualCard: routes to high capital pool when balance >= 500k', () {
      final richState = DealershipModel.initial().copyWith(
        level: 4,
        currentDay: 2, // even day
        balance: 750000.0,
      );

      final card = ContextualDilemmaPool.selectContextualCard(richState);
      expect(
        ContextualDilemmaPool.highCapitalCards.any((c) => c.id == card.id),
        isTrue,
        reason: 'Should draw from high capital cards when wealthy',
      );
    });

    test('selectContextualCard: routes to damaged fleet pool when 2+ cars need attention', () {
      final damagedCar1 = CarModel(
        id: 'damaged_1',
        brand: 'Fiat',
        modelName: 'Egea',
        modelYear: 2019,
        bodyType: 'Sedan',
        colorHex: '#FFFFFF',
        baseMarketValue: 120000.0,
        currentPurchasePrice: 100000.0,
        expertise: ExpertiseReport(
          engineCondition: 45.0, // < 70
          transmissionCondition: 50.0,
          tramerAmount: 12000,
          mileage: 180000,
          isMileageTampered: false,
          bodyParts: const {},
        ),
      );

      final damagedCar2 = CarModel(
        id: 'damaged_2',
        brand: 'Renault',
        modelName: 'Megane',
        modelYear: 2017,
        bodyType: 'Sedan',
        colorHex: '#000000',
        baseMarketValue: 140000.0,
        currentPurchasePrice: 110000.0,
        expertise: ExpertiseReport(
          engineCondition: 80.0,
          transmissionCondition: 40.0, // < 70
          tramerAmount: 8000,
          mileage: 140000,
          isMileageTampered: false,
          bodyParts: const {},
        ),
      );

      final fleetState = DealershipModel.initial().copyWith(
        level: 3,
        currentDay: 3, // odd day
        balance: 150000.0,
        ownedCars: [damagedCar1, damagedCar2],
      );

      final card = ContextualDilemmaPool.selectContextualCard(fleetState);
      expect(
        ContextualDilemmaPool.damagedFleetCards.any((c) => c.id == card.id),
        isTrue,
        reason: 'Should draw from damaged fleet cards when having 2+ damaged cars',
      );
    });

    test('selectContextualCard: routes to VIP reputation pool when reputation >= 70', () {
      final vipState = DealershipModel.initial().copyWith(
        level: 4,
        currentDay: 6, // multiple of 3
        balance: 200000.0,
        reputationScore: 130,
        ownedCars: [],
      );

      final card = ContextualDilemmaPool.selectContextualCard(vipState);
      expect(
        ContextualDilemmaPool.vipReputationCards.any((c) => c.id == card.id),
        isTrue,
        reason: 'Should draw from VIP reputation cards when reputation >= 70',
      );
    });

    test('selectContextualCard: routes to post-sale dispute pool when player has sold cars', () {
      final soldRecord = SaleRecordModel(
        id: 'sale_record_1',
        carTitle: 'Ford Focus',
        buyerName: 'Ahmet Bey',
        purchasePrice: 120000.0,
        salePrice: 145000.0,
        netProfit: 25000.0,
        saleDay: 2,
        saleDate: DateTime.now(),
      );

      final disputeState = DealershipModel.initial().copyWith(
        level: 3,
        currentDay: 4, // multiple of 4
        balance: 180000.0,
        reputationScore: 50,
        salesHistory: [soldRecord],
        ownedCars: [],
      );

      final card = ContextualDilemmaPool.selectContextualCard(disputeState);
      expect(
        ContextualDilemmaPool.postSaleDisputeCards.any((c) => c.id == card.id),
        isTrue,
        reason: 'Should draw from post-sale dispute cards when having sales history',
      );
    });
  });
}
