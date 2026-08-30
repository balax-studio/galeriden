import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/branch_model.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/customer_review_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/showroom_decor_model.dart';
import 'package:galeriden/domain/usecases/consignment_engine.dart';
import 'package:galeriden/domain/usecases/review_engine.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    container = ProviderContainer();
    // Stop periodic timer to maintain widget test timer hygiene
    container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
  });

  tearDown(() {
    container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
    container.dispose();
  });

  CarModel createSampleCar({
    String id = 'car_test_1',
    double baseValue = 500000,
    bool isLocked = false,
    bool isHero = false,
    bool isConsignment = false,
    double commissionRate = 0.15,
    bool isWashed = true,
    double engineCond = 90.0,
    double transmissionCond = 90.0,
    int tramer = 0,
    ListingDeclarationType declaration = ListingDeclarationType.honest,
  }) {
    return CarModel(
      id: id,
      brand: 'Vosgen',
      modelName: 'Golf Sekiz',
      modelYear: 2022,
      bodyType: 'Hatchback',
      colorHex: '#FFFFFF',
      baseMarketValue: baseValue,
      currentPurchasePrice: isConsignment ? 0.0 : baseValue * 0.85,
      isLockedInShowcase: isLocked,
      isHeroShowcase: isHero,
      isConsignment: isConsignment,
      consignmentCommissionRate: commissionRate,
      consignmentOwnerName: isConsignment ? 'Avukat Selim Bey' : null,
      consignmentDaysRemaining: isConsignment ? 14 : 0,
      isWashed: isWashed,
      declarationType: declaration,
      expertise: ExpertiseReport(
        engineCondition: engineCond,
        transmissionCondition: transmissionCond,
        tramerAmount: tramer,
        mileage: 45000,
        isMileageTampered: false,
        bodyParts: const {},
      ),
    );
  }

  group('Showroom Capacity & Branch Upgrades Deep Audit', () {
    test('expandGarageSlot increments maxGarageSlots and deducts cost', () {
      final notifier = container.read(gameProvider.notifier);
      notifier.state = notifier.state.copyWith(
        balance: 100000,
        maxGarageSlots: 3,
      );

      final success = notifier.expandGarageSlot(5, 40000);
      expect(success, isTrue);
      expect(notifier.state.maxGarageSlots, equals(5));
      expect(notifier.state.balance, equals(60000));
    });

    test('upgradeBranch enforces level and capital requirements', () {
      final notifier = container.read(gameProvider.notifier);
      final branch = BranchModel.getAllBranches()[2]; // Level 3 requirement

      // 1. Fail due to insufficient level
      notifier.state = notifier.state.copyWith(
        level: 1,
        balance: branch.requiredBalance + 50000,
      );
      expect(notifier.upgradeBranch(branch), isFalse);

      // 2. Fail due to insufficient funds
      notifier.state = notifier.state.copyWith(
        level: branch.targetLevel,
        balance: branch.requiredBalance - 1000,
      );
      expect(notifier.upgradeBranch(branch), isFalse);

      // 3. Success when level and balance are met
      notifier.state = notifier.state.copyWith(
        level: branch.targetLevel,
        balance: branch.requiredBalance + 10000,
      );
      expect(notifier.upgradeBranch(branch), isTrue);
      expect(notifier.state.maxGarageSlots, equals(branch.maxGarageSlots));
      expect(notifier.state.unlockedBuildings.contains('/workshop'), isTrue);
    });

    test('purchaseShowroomDecor prevents duplicate and awards reputation', () {
      final notifier = container.read(gameProvider.notifier);
      notifier.state = notifier.state.copyWith(
        balance: 50000,
        reputationScore: 100,
        unlockedDecorIds: [],
      );

      final success = notifier.purchaseShowroomDecor(
        decorId: 'decor_leather_chair_desk',
        cost: 15000,
        reputationBonus: 15,
      );

      expect(success, isTrue);
      expect(notifier.state.balance, equals(35000));
      expect(notifier.state.unlockedDecorIds.contains('decor_leather_chair_desk'), isTrue);
      expect(notifier.state.reputationScore, equals(115));

      // Attempt duplicate purchase
      final duplicateSuccess = notifier.purchaseShowroomDecor(
        decorId: 'decor_leather_chair_desk',
        cost: 15000,
        reputationBonus: 15,
      );
      expect(duplicateSuccess, isFalse);
    });
  });

  group('Vitrin & Showcase Management Deep Audit', () {
    test('toggleShowcaseLock protects car, clears offers and awards reputation', () {
      final notifier = container.read(gameProvider.notifier);
      final car = createSampleCar(id: 'classic_mercedes', isLocked: false);

      notifier.state = notifier.state.copyWith(
        ownedCars: [car],
        reputationScore: 200,
      );

      final lockSuccess = notifier.toggleShowcaseLock(car.id);
      expect(lockSuccess, isTrue);

      final lockedCar = notifier.state.ownedCars.first;
      expect(lockedCar.isLockedInShowcase, isTrue);
      expect(notifier.state.reputationScore, equals(205)); // +5 reputation

      // Unlock
      final unlockSuccess = notifier.toggleShowcaseLock(car.id);
      expect(unlockSuccess, isTrue);
      expect(notifier.state.ownedCars.first.isLockedInShowcase, isFalse);
    });

    test('toggleHeroShowcase guarantees only 1 single Hero Showcase car', () {
      final notifier = container.read(gameProvider.notifier);
      final car1 = createSampleCar(id: 'car_1');
      final car2 = createSampleCar(id: 'car_2');
      final car3 = createSampleCar(id: 'car_3');

      notifier.state = notifier.state.copyWith(
        ownedCars: [car1, car2, car3],
      );

      // Make car 1 Hero
      notifier.toggleHeroShowcase('car_1');
      expect(notifier.state.ownedCars.firstWhere((c) => c.id == 'car_1').isHeroShowcase, isTrue);
      expect(notifier.state.ownedCars.firstWhere((c) => c.id == 'car_2').isHeroShowcase, isFalse);

      // Make car 2 Hero -> car 1 must automatically lose Hero status
      notifier.toggleHeroShowcase('car_2');
      expect(notifier.state.ownedCars.firstWhere((c) => c.id == 'car_1').isHeroShowcase, isFalse);
      expect(notifier.state.ownedCars.firstWhere((c) => c.id == 'car_2').isHeroShowcase, isTrue);
      expect(notifier.state.ownedCars.firstWhere((c) => c.id == 'car_3').isHeroShowcase, isFalse);
    });

    test('publishAllReadyCars skips locked and rented vehicles', () {
      final notifier = container.read(gameProvider.notifier);
      final readyCar = createSampleCar(id: 'ready_1');
      final lockedCar = createSampleCar(id: 'locked_1', isLocked: true);
      final brokenCar = createSampleCar(id: 'broken_1', engineCond: 50.0);

      notifier.state = notifier.state.copyWith(
        ownedCars: [readyCar, lockedCar, brokenCar],
      );

      final publishedCount = notifier.publishAllReadyCars();
      expect(publishedCount, equals(1));

      final stateCars = notifier.state.ownedCars;
      expect(stateCars.firstWhere((c) => c.id == 'ready_1').isListed, isTrue);
      expect(stateCars.firstWhere((c) => c.id == 'locked_1').isListed, isFalse);
      expect(stateCars.firstWhere((c) => c.id == 'broken_1').isListed, isFalse);
    });
  });

  group('Konsinye (Consignment) Vehicles Deep Audit', () {
    test('ConsignmentEngine generates valid offers with 0 purchase capital requirement', () {
      final offers = ConsignmentEngine.generateConsignmentOffers(
        inGameDay: 5,
        branchTier: 4,
        reputationScore: 150,
      );

      expect(offers.isNotEmpty, isTrue);
      for (final o in offers) {
        expect(o.isConsignment, isTrue);
        expect(o.currentPurchasePrice, equals(0.0));
        expect(o.consignmentCommissionRate, greaterThan(0.05));
        expect(o.consignmentOwnerName, isNotNull);
        expect(o.consignmentDaysRemaining, greaterThan(0));
      }
    });

    test('acceptConsignmentOffer validates garage slot space', () {
      final notifier = container.read(gameProvider.notifier);
      final consignmentCar = createSampleCar(id: 'consignment_1', isConsignment: true);

      // Garage full
      notifier.state = notifier.state.copyWith(
        maxGarageSlots: 2,
        ownedCars: [
          createSampleCar(id: 'c1'),
          createSampleCar(id: 'c2'),
        ],
        consignmentOffers: [consignmentCar],
      );

      expect(notifier.acceptConsignmentOffer(consignmentCar), isFalse);

      // Garage has space
      notifier.state = notifier.state.copyWith(maxGarageSlots: 3);
      expect(notifier.acceptConsignmentOffer(consignmentCar), isTrue);
      expect(notifier.state.ownedCars.any((c) => c.id == 'consignment_1'), isTrue);
      expect(notifier.state.consignmentOffers.isEmpty, isTrue);
    });

    test('Consignment parking fee and commission calculations match economic rules', () {
      expect(ConsignmentEngine.calculateDailyParkingFee(1), equals(300.0));
      expect(ConsignmentEngine.calculateDailyParkingFee(4), equals(2500.0));
      expect(ConsignmentEngine.calculateDailyParkingFee(8), equals(45000.0));

      final car = createSampleCar(isConsignment: true, commissionRate: 0.15);
      final commission = ConsignmentEngine.calculateCommissionEarnings(car, 1000000.0);
      expect(commission, equals(150000.0));
    });
  });

  group('Customer Reviews & ReviewEngine Deep Audit', () {
    test('ReviewEngine generates 5-star review for honest, clean, low-tramer vehicle', () {
      final car = createSampleCar(
        isWashed: true,
        engineCond: 95.0,
        transmissionCond: 95.0,
        tramer: 0,
        declaration: ListingDeclarationType.honest,
      );

      final result = ReviewEngine.generateSaleReview(
        car: car,
        buyerName: 'Ahmet Bey',
        hasVipConcierge: true,
        hasVipLounge: true,
        random: Random(42),
      );

      expect(result.review.rating, equals(5.0));
      expect(result.reputationChange, greaterThanOrEqualTo(5));
      expect(result.review.comment.isNotEmpty, isTrue);
      expect(result.review.reviewerName, equals('Ahmet Bey'));
    });

    test('ReviewEngine severely penalizes dishonest vehicle declarations', () {
      final car = createSampleCar(
        isWashed: false,
        engineCond: 40.0,
        transmissionCond: 40.0,
        tramer: 75000,
        declaration: ListingDeclarationType.flawlessClaim,
      );

      final result = ReviewEngine.generateSaleReview(
        car: car,
        buyerName: 'Mehmet Bey',
        random: Random(42),
      );

      expect(result.review.rating, lessThanOrEqualTo(2.5));
      expect(result.reputationChange, equals(-4));
    });

    test('buyBotReview applies diminishing returns curve and generates valid review', () {
      final notifier = container.read(gameProvider.notifier);
      notifier.state = notifier.state.copyWith(
        balance: 1000000, // Sufficient balance
        reputationScore: 100,
        customerReviews: [],
      );

      // First bot: +5 reputation
      expect(notifier.buyBotReview(), isTrue);
      expect(notifier.state.reputationScore, equals(105));
      expect(notifier.state.customerReviews.length, equals(1));
      expect(notifier.state.customerReviews.first.rating, equals(5.0));

      // After 3 bots: +3 reputation
      final dummyBots = List.generate(
        3,
        (i) => CustomerReviewModel(
          id: 'rev_bot_$i',
          reviewerName: 'Bot $i',
          carTitle: 'Car $i',
          comment: 'Good',
          rating: 5,
          createdAt: DateTime.now(),
        ),
      );
      notifier.state = notifier.state.copyWith(
        customerReviews: dummyBots,
        balance: 1000000,
      );
      notifier.buyBotReview();
      expect(notifier.state.reputationScore, equals(108));

      // After 6 bots: +1 reputation
      final dummyBots7 = List.generate(
        7,
        (i) => CustomerReviewModel(
          id: 'rev_bot_$i',
          reviewerName: 'Bot $i',
          carTitle: 'Car $i',
          comment: 'Good',
          rating: 5,
          createdAt: DateTime.now(),
        ),
      );
      notifier.state = notifier.state.copyWith(
        customerReviews: dummyBots7,
        balance: 1000000,
      );
      notifier.buyBotReview();
      expect(notifier.state.reputationScore, equals(109));
    });

    test('All review and decor strings strictly adhere to 0 emojis and 0 parentheses', () {
      final allDecors = ShowroomDecorModel.getAllDecors();
      for (final d in allDecors) {
        expect(d.title.contains('('), isFalse, reason: 'Title contains parenthesis: ${d.title}');
        expect(d.title.contains(')'), isFalse, reason: 'Title contains parenthesis: ${d.title}');
        expect(d.description.contains('('), isFalse, reason: 'Description contains parenthesis: ${d.description}');
        expect(d.description.contains(')'), isFalse, reason: 'Description contains parenthesis: ${d.description}');
      }
    });
  });
}
