import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/constants/first_time_action_keys.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/customer_review_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/offer_model.dart';
import 'package:galeriden/data/models/part_order_model.dart';
import 'package:galeriden/data/models/scrapyard_model.dart';
import 'package:galeriden/domain/usecases/negotiation_engine.dart';
import 'package:galeriden/domain/usecases/repair_engine.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('24 Improvements Comprehensive Verification', () {
    ExpertiseReport createEmptyReport() {
      return ExpertiseReport(
        engineCondition: 90.0,
        transmissionCondition: 90.0,
        tramerAmount: 0,
        mileage: 50000,
        isMileageTampered: false,
        bodyParts: const {},
      );
    }

    test('1. Consignment Commission Accounting: Only commission is earned as gallery profit', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(gameProvider.notifier);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final consignmentCar = CarModel(
        id: 'car_consignment_1',
        brand: 'Mercedes',
        modelName: 'C200',
        modelYear: 2020,
        bodyType: 'Sedan',
        colorHex: '0xFF000000',
        baseMarketValue: 1000000.0,
        currentPurchasePrice: 0.0,
        isConsignment: true,
        consignmentCommissionRate: 0.10, // 10%
        consignmentDaysRemaining: 7,
        expertise: createEmptyReport(),
      );

      final offer = OfferModel(
        id: 'offer_1',
        carId: consignmentCar.id,
        buyerName: 'Ahmet Bey',
        offeredAmount: 1000000.0,
        buyerMessage: 'Aracınıza talibim.',
        status: OfferStatus.pending,
        createdAt: DateTime.now(),
      );

      notifier.state = notifier.state.copyWith(
        ownedCars: [consignmentCar],
        incomingOffers: [offer],
        balance: 50000.0,
        totalProfit: 0.0,
        tutorialCompleted: true,
        completedFirstTimeActions: {FirstTimeActionKeys.firstCarSell},
      );

      final initialBalance = notifier.state.balance;
      notifier.acceptOffer(offer);

      // 10% commission on 1.000.000 = 100.000 profit
      expect(notifier.state.balance, equals(initialBalance + 100000.0));
      expect(notifier.state.totalProfit, equals(100000.0));
      expect(notifier.state.salesHistory.first.isConsignment, isTrue);
      expect(notifier.state.salesHistory.first.netProfit, equals(100000.0));
    });

    test('2. Consignment Countdown and Expiry: Car returned to owner when days reach 0', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(gameProvider.notifier);

      final expiringCar = CarModel(
        id: 'car_expiring',
        brand: 'BMW',
        modelName: '320i',
        modelYear: 2019,
        bodyType: 'Sedan',
        colorHex: '0xFF000000',
        baseMarketValue: 800000.0,
        currentPurchasePrice: 0.0,
        isConsignment: true,
        consignmentCommissionRate: 0.10,
        consignmentDaysRemaining: 1,
        expertise: createEmptyReport(),
      );

      notifier.state = notifier.state.copyWith(
        ownedCars: [expiringCar],
      );

      // Advance day triggers _processConsignmentDays
      notifier.advanceGameDay();

      // Car should be removed from showroom and returned to owner
      expect(notifier.state.ownedCars.any((c) => c.id == 'car_expiring'), isFalse);
      expect(notifier.state.dailyRacesRemaining, equals(3)); // Daily race quota reset
    });

    test('3. Night Race Limit, Entry Fee, and Engine Wear Mechanics', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(gameProvider.notifier);

      final raceCar = CarModel(
        id: 'race_car_1',
        brand: 'Volkswagen',
        modelName: 'Golf GTI',
        modelYear: 2021,
        bodyType: 'Hatchback',
        colorHex: '0xFFCC0000',
        baseMarketValue: 600000.0,
        currentPurchasePrice: 500000.0,
        appliedDetailingOptionIds: ['tune_ecu_stg2', 'tune_exhaust'],
        expertise: ExpertiseReport(
          engineCondition: 90.0,
          transmissionCondition: 90.0,
          tramerAmount: 0,
          mileage: 40000,
          isMileageTampered: false,
          bodyParts: const {},
        ),
      );

      notifier.state = notifier.state.copyWith(
        ownedCars: [raceCar],
        balance: 50000.0,
        dailyRacesRemaining: 3,
      );

      // Race 1
      final res1 = notifier.enterNightRace(raceCar);
      expect(res1, isNotNull);
      expect(notifier.state.dailyRacesRemaining, equals(2));
      expect(notifier.state.ownedCars.first.expertise.engineCondition, lessThan(90.0));

      // Exhaust remaining races
      notifier.enterNightRace(notifier.state.ownedCars.first);
      notifier.enterNightRace(notifier.state.ownedCars.first);
      expect(notifier.state.dailyRacesRemaining, equals(0));

      // Attempt 4th race should be blocked
      final resBlocked = notifier.enterNightRace(notifier.state.ownedCars.first);
      expect(resBlocked.isWon, isFalse);
      expect(resBlocked.raceSummary.contains('haklarınızı'), isTrue);
    });

    test('4. Scrapyard Parts Integration in Repair & Workshop', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(gameProvider.notifier);

      final car = CarModel(
        id: 'car_repair',
        brand: 'Fiat',
        modelName: 'Egea',
        modelYear: 2020,
        bodyType: 'Sedan',
        colorHex: '0xFFFFFFFF',
        baseMarketValue: 400000.0,
        currentPurchasePrice: 350000.0,
        expertise: createEmptyReport(),
      );

      final scrapPart = SalvagedPart(
        id: 'scrap_1',
        name: 'Ön Tampon',
        carModelName: 'Fiat Egea',
        category: 'body',
        conditionPercent: 80,
        estimatedValue: 3000.0,
      );

      notifier.state = notifier.state.copyWith(
        ownedCars: [car],
        salvagedParts: [scrapPart],
        balance: 10000.0,
      );

      // Free scrap part repair order
      final ordered = notifier.orderPart(
        carId: car.id,
        partName: 'Ön Tampon',
        orderType: OrderType.salvagedScrap,
        cost: 0.0,
        deliveryDurationSeconds: 20,
      );

      expect(ordered, isTrue);
      expect(notifier.state.salvagedParts.isEmpty, isTrue);
      expect(notifier.state.pendingOrders.length, equals(1));
      expect(notifier.state.pendingOrders.first.orderType, equals(OrderType.salvagedScrap));
      expect(notifier.state.pendingOrders.first.cost, equals(0.0));
    });

    test('5. Staff Academy Courses and District Dominance Discounts', () {
      final car = CarModel(
        id: 'car_test',
        brand: 'Renault',
        modelName: 'Megane',
        modelYear: 2020,
        bodyType: 'Sedan',
        colorHex: '0xFF000000',
        baseMarketValue: 500000.0,
        currentPurchasePrice: 450000.0,
        expertise: createEmptyReport(),
      );

      // Base OEM cost without discounts
      final baseCost = RepairEngine.calculatePartRepairCost(car, 'Kaput', OrderType.newOemPart);

      // Discounted cost with İkitelli %15 + Academy %10
      final discountedCost = RepairEngine.calculatePartRepairCost(
        car,
        'Kaput',
        OrderType.newOemPart,
        discountFactor: 0.85 * 0.90,
      );

      expect(discountedCost, lessThan(baseCost));
      expect(discountedCost, closeTo(baseCost * 0.85 * 0.90, 200.0));
    });

    test('6. Interactive Customer Reviews: Replies, Compensation Coupons, Bot PR', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(gameProvider.notifier);

      final review = CustomerReviewModel(
        id: 'rev_bad_1',
        reviewerName: 'Mehmet K.',
        carTitle: 'Renault Clio',
        comment: 'Arabanın kliması arızalı çıktı.',
        rating: 2,
        createdAt: DateTime.now(),
      );

      notifier.state = notifier.state.copyWith(
        customerReviews: [review],
        reputationScore: 50,
        balance: 20000.0,
      );

      // 1. Reply to review
      notifier.replyToCustomerReview('rev_bad_1', 'Klima kompresörünüzü ücretsiz değiştirelim efendim.');
      expect(notifier.state.customerReviews.first.reply, isNotNull);
      expect(notifier.state.reputationScore, equals(51)); // +1 rep

      // 2. Send compensation coupon (₺500)
      final compSuccess = notifier.compensateCustomerReview('rev_bad_1');
      expect(compSuccess, isTrue);
      expect(notifier.state.customerReviews.first.isCompensated, isTrue);
      expect(notifier.state.customerReviews.first.rating, equals(4)); // elevated to 4 stars
      expect(notifier.state.reputationScore, equals(54)); // +3 rep
      expect(notifier.state.balance, equals(19500.0)); // ₺500 deducted

      // 3. Buy Bot / PR Review Package (₺2.000)
      final botSuccess = notifier.buyBotReview();
      expect(botSuccess, isTrue);
      expect(notifier.state.customerReviews.length, equals(2));
      expect(notifier.state.customerReviews.first.rating, equals(5));
      expect(notifier.state.reputationScore, equals(59)); // +5 rep
      expect(notifier.state.balance, equals(17500.0)); // ₺2.000 deducted
    });

    test('7. Notary Fraud Claim on Tampered Mileage', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(gameProvider.notifier);

      final tamperedCar = CarModel(
        id: 'car_tampered_1',
        brand: 'Ford',
        modelName: 'Focus',
        modelYear: 2018,
        bodyType: 'Hatchback',
        colorHex: '0xFF000000',
        baseMarketValue: 350000.0,
        currentPurchasePrice: 320000.0,
        expertise: ExpertiseReport(
          engineCondition: 80.0,
          transmissionCondition: 80.0,
          tramerAmount: 5000,
          mileage: 60000,
          isMileageTampered: true,
          bodyParts: const {},
        ),
      );

      notifier.state = notifier.state.copyWith(
        ownedCars: [tamperedCar],
        balance: 10000.0,
        reputationScore: 50,
      );

      final claimSuccess = notifier.claimNotaryFraudCompensation(tamperedCar.id);
      expect(claimSuccess, isTrue);
      expect(notifier.state.balance, equals(13500.0)); // +₺3.500 compensation
      expect(notifier.state.reputationScore, equals(52)); // +2 rep
      expect(notifier.state.ownedCars.first.expertise.isMileageTampered, isFalse);
    });

    test('8. Negotiation Engine integrates Academy and Specialization Trader Perks', () {
      final car = CarModel(
        id: 'car_trade',
        brand: 'Honda',
        modelName: 'Civic',
        modelYear: 2021,
        bodyType: 'Sedan',
        colorHex: '0xFFFFFFFF',
        baseMarketValue: 800000.0,
        currentPurchasePrice: 700000.0,
        expertise: createEmptyReport(),
      );

      final offer = OfferModel(
        id: 'offer_trade',
        carId: car.id,
        buyerName: 'Alıcı',
        offeredAmount: 750000.0,
        buyerMessage: 'Fiyat bu mudur?',
        status: OfferStatus.pending,
        createdAt: DateTime.now(),
      );

      final outcome = NegotiationEngine.evaluateCounterOffer(
        currentOffer: offer,
        playerTargetPrice: 770000.0,
        car: car,
        negotiationSkillLevel: 3,
        strategy: 'ikna_et',
        purchasedAcademyCourses: ['course_sales_master'],
        isTraderSpecialization: true,
      );

      expect(outcome, isNotNull);
      expect(outcome.updatedOffer, isNotNull);
    });
  });
}
