import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/offer_model.dart';
import 'package:galeriden/data/models/trade_in_offer_model.dart';
import 'package:galeriden/domain/usecases/trade_in_engine.dart';
import 'package:galeriden/domain/usecases/collection_album_engine.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Trade-In & Audit Fixes Verification Tests', () {
    late ProviderContainer container;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('TradeInEngine generates valid trade-in offer for target car', () {
      final targetCar = CarModel(
        id: 'target_car_1',
        brand: 'BMW',
        modelName: '320i',
        modelYear: 2018,
        currentPurchasePrice: 850000,
        baseMarketValue: 900000,
        bodyType: 'Sedan',
        colorHex: '0xFF000000',
        expertise: ExpertiseReport(
          engineCondition: 90,
          transmissionCondition: 90,
          tramerAmount: 0,
          mileage: 65000,
          isMileageTampered: false,
          bodyParts: {},
        ),
      );

      final tradeOffer = TradeInEngine.generateTradeInOffer(
        targetCar: targetCar,
        inGameDay: 10,
      );

      expect(tradeOffer.targetCarId, equals(targetCar.id));
      expect(tradeOffer.customerName.isNotEmpty, isTrue);
      expect(tradeOffer.offeredCar.id.isNotEmpty, isTrue);
      expect(tradeOffer.offeredCar.brand.isNotEmpty, isTrue);
      expect(tradeOffer.expiresInDays, greaterThanOrEqualTo(2));
    });

    test('acceptTradeInOffer successfully swaps car and adjusts balance', () {
      final targetCar = CarModel(
        id: 'car_to_trade',
        brand: 'Audi',
        modelName: 'A4',
        modelYear: 2019,
        currentPurchasePrice: 1000000,
        baseMarketValue: 1050000,
        bodyType: 'Sedan',
        colorHex: '0xFFFFFFFF',
        expertise: ExpertiseReport(
          engineCondition: 95,
          transmissionCondition: 95,
          tramerAmount: 0,
          mileage: 50000,
          isMileageTampered: false,
          bodyParts: {},
        ),
      );

      final offeredCar = CarModel(
        id: 'customer_trade_car',
        brand: 'Volkswagen',
        modelName: 'Golf',
        modelYear: 2020,
        currentPurchasePrice: 800000,
        baseMarketValue: 850000,
        bodyType: 'Hatchback',
        colorHex: '0xFF0000FF',
        expertise: ExpertiseReport(
          engineCondition: 92,
          transmissionCondition: 92,
          tramerAmount: 0,
          mileage: 40000,
          isMileageTampered: false,
          bodyParts: {},
        ),
      );

      final dummyOffer = OfferModel(
        id: 'offer_1',
        carId: targetCar.id,
        buyerName: 'Ahmet Bey',
        buyerMessage: 'Aracınıza talibim.',
        offeredAmount: 1080000,
        createdAt: DateTime.now(),
      );

      // Seed initial state
      final notifier = container.read(gameProvider.notifier);
      notifier.state = notifier.state.copyWith(
        balance: 100000.0,
        ownedCars: [targetCar],
        incomingOffers: [dummyOffer],
        carsSold: 0,
      );

      final tradeOffer = TradeInOfferModel(
        id: 'trade_1',
        targetCarId: targetCar.id,
        targetCarName: 'Audi A4',
        customerName: 'Mehmet Usta',
        offeredCar: offeredCar,
        cashDifference: 250000.0, // Customer pays ₺250.000 cash on top
        dialogueText: 'Golf aracımı vereyim, üste 250 bin nakit tamamlayayım.',
        expiresInDays: 3,
      );

      final result = notifier.acceptTradeInOffer(tradeOffer);
      expect(result, isTrue);

      final updatedState = container.read(gameProvider);
      // Car swap verified
      expect(updatedState.ownedCars.any((c) => c.id == targetCar.id), isFalse);
      expect(updatedState.ownedCars.any((c) => c.id == offeredCar.id), isTrue);
      // Balance increased by ₺250.000
      expect(updatedState.balance, equals(350000.0));
      // Incoming offers for target car removed
      expect(updatedState.incomingOffers.any((o) => o.carId == targetCar.id), isFalse);
      // Cars sold incremented
      expect(updatedState.carsSold, equals(1));
    });

    test('acceptTradeInOffer fails if player lacks funds for negative cash difference', () {
      final targetCar = CarModel(
        id: 'cheap_car',
        brand: 'Fiat',
        modelName: 'Egea',
        modelYear: 2021,
        currentPurchasePrice: 600000,
        baseMarketValue: 650000,
        bodyType: 'Sedan',
        colorHex: '0xFFFFFFFF',
        expertise: ExpertiseReport(
          engineCondition: 90,
          transmissionCondition: 90,
          tramerAmount: 0,
          mileage: 30000,
          isMileageTampered: false,
          bodyParts: {},
        ),
      );

      final expensiveCar = CarModel(
        id: 'expensive_car',
        brand: 'Mercedes-Benz',
        modelName: 'C200',
        modelYear: 2022,
        currentPurchasePrice: 1800000,
        baseMarketValue: 1900000,
        bodyType: 'Sedan',
        colorHex: '0xFF000000',
        expertise: ExpertiseReport(
          engineCondition: 98,
          transmissionCondition: 98,
          tramerAmount: 0,
          mileage: 15000,
          isMileageTampered: false,
          bodyParts: {},
        ),
      );

      final notifier = container.read(gameProvider.notifier);
      notifier.state = notifier.state.copyWith(
        balance: 50000.0, // Player only has 50k
        ownedCars: [targetCar],
      );

      final tradeOffer = TradeInOfferModel(
        id: 'trade_upgrade',
        targetCarId: targetCar.id,
        targetCarName: 'Fiat Egea',
        customerName: 'Galerici Hasan',
        offeredCar: expensiveCar,
        cashDifference: -1200000.0, // Player needs to pay ₺1.200.000
        dialogueText: 'C200 veriyorum, Egea ve 1.2M nakit alırım.',
        expiresInDays: 2,
      );

      final result = notifier.acceptTradeInOffer(tradeOffer);
      expect(result, isFalse); // Insufficient funds

      final updatedState = container.read(gameProvider);
      expect(updatedState.balance, equals(50000.0));
      expect(updatedState.ownedCars.first.id, equals(targetCar.id));
    });

    test('CollectionAlbumEngine computes correct progress and milestone rewards', () {
      final progress = CollectionAlbumEngine.calculateAlbumProgress(
        discoveredCarIds: ['bmw_320', 'audi_a4', 'mercedes_c200', 'vw_golf', 'fiat_egea'],
        totalCatalogCarsCount: 30,
      );

      expect(progress.discoveredModelsCount, equals(5));
      expect(progress.totalCatalogCarsCount, equals(30));
      expect(progress.completionPercentage, closeTo(5 / 30, 0.001));

      final reward5 = CollectionAlbumEngine.getMilestoneReward(5);
      expect(reward5, equals(35000));
    });
  });
}
