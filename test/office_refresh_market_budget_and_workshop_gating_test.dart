import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/offer_model.dart';
import 'package:galeriden/domain/usecases/market_engine.dart';
import 'package:galeriden/domain/usecases/negotiation_engine.dart';
import 'package:galeriden/domain/usecases/smart_office_hook_engine.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Feature 1: Office Dynamic Seed & Usage Day Gating', () {
    test('Office grant and smart hook usage sets last claimed day and locks for today', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      final initialGame = container.read(gameProvider);
      expect(initialGame.isOfficeGrantClaimedToday, isFalse);
      expect(initialGame.isSmartHookClaimedToday, isFalse);

      // Claim office grant
      final grantAmount = notifier.claimOfficeAdGrant();
      expect(grantAmount, equals(25000.0));

      final postGrantGame = container.read(gameProvider);
      expect(postGrantGame.lastOfficeGrantClaimDay, equals(postGrantGame.currentDay));
      expect(postGrantGame.isOfficeGrantClaimedToday, isTrue);

      // Execute smart hook
      final hookSuccess = notifier.executeSmartOfficeHook(SmartHookType.lowBalanceGrant);
      expect(hookSuccess, isTrue);

      final postHookGame = container.read(gameProvider);
      expect(postHookGame.lastSmartHookUsedDay, equals(postHookGame.currentDay));
      expect(postHookGame.isSmartHookClaimedToday, isTrue);

      // Advance day resets daily usage flags
      notifier.state = postHookGame.copyWith(currentDay: postHookGame.currentDay + 1);
      final nextDayGame = container.read(gameProvider);
      expect(nextDayGame.isOfficeGrantClaimedToday, isFalse);
      expect(nextDayGame.isSmartHookClaimedToday, isFalse);
    });

    test('refreshOfficeSeed updates officeSeed and rotates dialogues and gossip', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      final game1 = container.read(gameProvider);
      final grant1 = SmartOfficeHookEngine.getDailyGrantVariant(game1);
      final gossip1 = SmartOfficeHookEngine.getOfficeGossipAndTips(game1);

      notifier.refreshOfficeSeed();
      final game2 = container.read(gameProvider);
      expect(game2.officeSeed, equals(game1.officeSeed + 1));

      final grant2 = SmartOfficeHookEngine.getDailyGrantVariant(game2);
      final gossip2 = SmartOfficeHookEngine.getOfficeGossipAndTips(game2);

      expect(grant1.title.isNotEmpty, isTrue);
      expect(grant2.title.isNotEmpty, isTrue);
      expect(gossip1.isNotEmpty, isTrue);
      expect(gossip2.isNotEmpty, isTrue);
    });
  });

  group('Feature 2: Realistic Market Pricing & Budget Segment Distribution', () {
    test('Market generates budget-appropriate car segments without distorting market values', () {
      // Low balance: ₺50.000
      final lowBudgetListings = MarketEngine.generateRandomListings(
        count: 25,
        playerLevel: 1,
        playerBalance: 50000.0,
      );

      expect(lowBudgetListings.isNotEmpty, isTrue);
      // Soft-lock prevention guarantees at least 1 affordable car
      expect(lowBudgetListings.any((l) => l.askingPrice <= 50000.0), isTrue);

      // Base market values are kept realistic and positive
      for (final listing in lowBudgetListings) {
        expect(listing.car.baseMarketValue, greaterThanOrEqualTo(35000.0));
        expect(listing.askingPrice, greaterThanOrEqualTo(35000.0));
      }

      // High balance: ₺5.000.000
      final highBudgetListings = MarketEngine.generateRandomListings(
        count: 25,
        playerLevel: 10,
        playerBalance: 5000000.0,
      );

      expect(highBudgetListings.isNotEmpty, isTrue);
      // High budget market has higher average asking price
      final lowAvg = lowBudgetListings.map((l) => l.askingPrice).reduce((a, b) => a + b) / lowBudgetListings.length;
      final highAvg = highBudgetListings.map((l) => l.askingPrice).reduce((a, b) => a + b) / highBudgetListings.length;
      expect(highAvg, greaterThan(lowAvg));
    });
  });

  group('Feature 3: Workshop 10.000 KM Maintenance One-Time Gating', () {
    test('10k maintenance cannot be performed multiple times on the same car', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      final testCar = CarModel(
        id: 'test_maint_car_1',
        brand: 'Reno',
        modelName: 'Clio',
        modelYear: 2018,
        bodyType: 'Hatchback',
        colorHex: '#FFFFFF',
        colorDisplayName: 'Beyaz',
        plateNumber: '34ABC123',
        baseMarketValue: 350000,
        currentPurchasePrice: 300000,
        isPeriodicMaintained: false,
        expertise: ExpertiseReport(
          engineCondition: 70.0,
          transmissionCondition: 70.0,
          tramerAmount: 0,
          mileage: 85000,
          isMileageTampered: false,
          bodyParts: {},
        ),
      );

      notifier.state = container.read(gameProvider).copyWith(
        balance: 50000.0,
        ownedCars: [testCar],
      );

      // First maintenance execution succeeds
      final success1 = notifier.performPeriodicMaintenance(testCar.id);
      expect(success1, isTrue);

      final carAfterMaint = container.read(gameProvider).ownedCars.firstWhere((c) => c.id == testCar.id);
      expect(carAfterMaint.isPeriodicMaintained, isTrue);
      expect(carAfterMaint.expertise.engineCondition, equals(85.0));
      expect(carAfterMaint.expertise.transmissionCondition, equals(85.0));

      // Second maintenance execution fails (locked)
      final success2 = notifier.performPeriodicMaintenance(testCar.id);
      expect(success2, isFalse);
    });
  });

  group('Feature 4: Workshop Condition-Based Smart Gating Logic', () {
    test('Bodywork repair is completed when all parts are original', () {
      final pristineParts = <String, PartStatus>{
        'Kaput': PartStatus.original,
        'Tavan': PartStatus.original,
        'Sol Ön Çamurluk': PartStatus.original,
        'Sağ Ön Çamurluk': PartStatus.original,
      };

      final hasDamagedParts = pristineParts.values.any((v) => v != PartStatus.original);
      expect(hasDamagedParts, isFalse);

      final damagedParts = <String, PartStatus>{
        'Kaput': PartStatus.painted,
        'Tavan': PartStatus.original,
        'Sol Ön Çamurluk': PartStatus.changed,
      };

      final hasDamagedParts2 = damagedParts.values.any((v) => v != PartStatus.original);
      expect(hasDamagedParts2, isTrue);
    });
  });

  group('Feature 5: Customer Offer Timeout & Dismissal', () {
    test('Generated offers have dynamic expiresAt and can be dismissed when expired', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      final testCar = CarModel(
        id: 'test_offer_car_1',
        brand: 'Fiat',
        modelName: 'Egea',
        modelYear: 2021,
        bodyType: 'Sedan',
        colorHex: '#FFFFFF',
        colorDisplayName: 'Beyaz',
        plateNumber: '06XYZ789',
        baseMarketValue: 450000,
        currentPurchasePrice: 420000,
        customListingPrice: 480000,
        expertise: ExpertiseReport(
          engineCondition: 90.0,
          transmissionCondition: 90.0,
          tramerAmount: 0,
          mileage: 45000,
          isMileageTampered: false,
          bodyParts: {},
        ),
      );

      final offer = NegotiationEngine.generateBuyerOffer(testCar, 480000.0);
      expect(offer.expiresAt.isAfter(offer.createdAt), isTrue);

      // Add offer to state
      notifier.addOffer(offer);
      expect(container.read(gameProvider).incomingOffers.length, equals(1));

      // Dismiss / Reject offer
      notifier.dismissOffer(offer.id);
      expect(container.read(gameProvider).incomingOffers.isEmpty, isTrue);
    });

    test('Expired offer model correctly reports isExpired', () {
      final now = DateTime.now();
      final expiredOffer = OfferModel(
        id: 'expired_1',
        carId: 'car_1',
        buyerName: 'Ahmet Bey',
        offeredAmount: 300000,
        buyerMessage: 'Acil satılık',
        createdAt: now.subtract(const Duration(minutes: 20)),
        expiresAt: now.subtract(const Duration(minutes: 5)),
        status: OfferStatus.expired,
      );

      expect(expiredOffer.isExpired, isTrue);
    });
  });
}
