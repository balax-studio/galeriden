import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galerisinden/domain/usecases/market_engine.dart';
import 'package:galerisinden/domain/usecases/expertise_engine.dart';
import 'package:galerisinden/domain/usecases/repair_engine.dart';
import 'package:galerisinden/domain/usecases/auction_engine.dart';
import 'package:galerisinden/domain/usecases/negotiation_engine.dart';
import 'package:galerisinden/domain/usecases/risk_engine.dart';
import 'package:galerisinden/data/models/car_model.dart';
import 'package:galerisinden/data/models/customer_model.dart';
import 'package:galerisinden/data/models/branch_model.dart';
import 'package:galerisinden/data/models/dealership_model.dart';
import 'package:galerisinden/data/models/detailing_model.dart';
import 'package:galerisinden/data/models/expertise_model.dart';
import 'package:galerisinden/data/models/part_order_model.dart';
import 'package:galerisinden/presentation/providers/game_provider.dart';

void main() {
  group('Galerisinden Tycoon Engine Tests', () {
    test('Market Engine generates offline listings with realistic Turkish prices', () {
      final listings = MarketEngine.generateRandomListings(count: 5, playerLevel: 1);
      expect(listings.length, equals(5));
      expect(listings.first.car.brand.isNotEmpty, isTrue);
      expect(listings.first.askingPrice, greaterThanOrEqualTo(250000));
    });

    test('Expertise Engine evaluates vehicle damage correctly', () {
      final listings = MarketEngine.generateRandomListings(count: 1, playerLevel: 1);
      final car = listings.first.car;
      final eval = ExpertiseEngine.evaluateVehicle(car);

      expect(eval.containsKey('overallGrade'), isTrue);
      expect(eval['damagePercentage'], greaterThanOrEqualTo(0));
    });

    test('Repair Engine restores body part to original with Master Tier', () {
      final listings = MarketEngine.generateRandomListings(count: 1, playerLevel: 1);
      final car = listings.first.car;

      // Find a part that is not original, or force one to painted
      final targetPart = car.expertise.bodyParts.keys.firstWhere(
        (k) => car.expertise.bodyParts[k] != PartStatus.original,
        orElse: () => 'Kaput',
      );

      final damagedCar = car.copyWith(
        expertise: ExpertiseReport(
          engineCondition: car.expertise.engineCondition,
          transmissionCondition: car.expertise.transmissionCondition,
          tramerAmount: car.expertise.tramerAmount,
          mileage: car.expertise.mileage,
          isMileageTampered: car.expertise.isMileageTampered,
          bodyParts: {...car.expertise.bodyParts, targetPart: PartStatus.painted},
        ),
      );

      final result = RepairEngine.repairBodyPart(damagedCar, targetPart, RepairTier.master);
      expect(result.isSuccess, isTrue);
      expect(result.updatedCar.expertise.bodyParts[targetPart], equals(PartStatus.original));
    });

    test('Risk Engine evaluates uninspected purchases correctly', () {
      final listings = MarketEngine.generateRandomListings(count: 1, playerLevel: 1);
      final car = listings.first.car;

      // Run 20 evaluations to ensure risk engine produces valid outcomes
      for (int i = 0; i < 20; i++) {
        final outcome = RiskEngine.evaluateUninspectedPurchaseRisk(car);
        expect(outcome.title.isNotEmpty, isTrue);
        expect(outcome.description.isNotEmpty, isTrue);
      }
    });

    test('Repair Engine prevents repairing already original parts and 100% engines', () {
      final listings = MarketEngine.generateRandomListings(count: 1, playerLevel: 1);
      final car = listings.first.car;

      final damagedCar = car.copyWith(
        expertise: ExpertiseReport(
          engineCondition: 80.0,
          transmissionCondition: 80.0,
          tramerAmount: car.expertise.tramerAmount,
          mileage: car.expertise.mileage,
          isMileageTampered: car.expertise.isMileageTampered,
          bodyParts: {...car.expertise.bodyParts, 'Kaput': PartStatus.painted},
        ),
      );

      // 1. Repair part to original first
      final res1 = RepairEngine.repairBodyPart(damagedCar, 'Kaput', RepairTier.master);
      expect(res1.isSuccess, isTrue);

      // 2. Try to repair already original part
      final res2 = RepairEngine.repairBodyPart(res1.updatedCar, 'Kaput', RepairTier.master);
      expect(res2.isSuccess, isFalse);
      expect(res2.costPaid, equals(0.0));

      // 3. Repair engine to 100%
      final engRes1 = RepairEngine.repairEngine(damagedCar, RepairTier.master);
      expect(engRes1.isSuccess, isTrue);

      // 4. Try to repair already 100% engine
      final engRes2 = RepairEngine.repairEngine(engRes1.updatedCar, RepairTier.master);
      expect(engRes2.isSuccess, isFalse);
      expect(engRes2.costPaid, equals(0.0));
    });

    test('NegotiationEngine detects expertise discrepancy correctly', () {
      final listings = MarketEngine.generateRandomListings(count: 1, playerLevel: 1);
      final car = listings.first.car;

      final tamperedCar = car.copyWith(
        expertise: ExpertiseReport(
          engineCondition: car.expertise.engineCondition,
          transmissionCondition: car.expertise.transmissionCondition,
          tramerAmount: car.expertise.tramerAmount,
          mileage: car.expertise.mileage,
          isMileageTampered: true,
          bodyParts: car.expertise.bodyParts,
        ),
      );

      final disc = NegotiationEngine.detectExpertiseDiscrepancy(tamperedCar);
      expect(disc.hasDiscrepancy, isTrue);
      expect(disc.extraDiscountPercent, equals(0.25));
    });

    test('AuctionEngine generates live auctions with 3 rival bidders', () {
      final auction = AuctionEngine.createLiveAuction(playerLevel: 1);
      expect(auction.car.brand.isNotEmpty, isTrue);
      expect(auction.rivals.length, equals(3));
      expect(auction.startingPrice, lessThan(auction.estimatedMarketValue));
    });

    test('CustomerModel generates valid buyer archetypes', () {
      final customer = CustomerModel.generateRandomCustomer();
      expect(customer.name.isNotEmpty, isTrue);
      expect(customer.archetypeTitle.isNotEmpty, isTrue);
    });

    test('BranchModel defines 4 tiers of dealership expansion', () {
      final branches = BranchModel.getAllBranches(3);
      expect(branches.length, equals(4));
      expect(branches.first.maxGarageSlots, equals(3));
      expect(branches.last.maxGarageSlots, equals(15));
    });

    test('DetailingOption returns 4 detailing & tuning options', () {
      final options = DetailingOption.getAvailableOptions();
      expect(options.length, equals(4));
      expect(options.any((o) => o.isRisky), isTrue);
    });

    test('NegotiationEngine evaluates player fraud inspection correctly', () {
      final listings = MarketEngine.generateRandomListings(count: 1, playerLevel: 1);
      final car = listings.first.car.copyWith(
        declarationType: ListingDeclarationType.flawlessClaim,
      );

      final customer = CustomerModel.generateRandomCustomer();
      expect(customer.inspectionProbability, greaterThan(0.0));

      final result = NegotiationEngine.evaluatePlayerFraudInspection(car: car, customer: customer);
      expect(result.title.isNotEmpty, isTrue);
      if (result.caughtFraud) {
        expect(result.fineAmount, equals(10000.0));
        expect(result.reputationPenalty, equals(15));
      }
    });

    test('GameNotifier processes bank loan and repayment correctly', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(gameProvider.notifier);
      final initialBalance = container.read(gameProvider).balance;

      final loanSuccess = notifier.takeBankLoan(
        bankName: 'Ziraat Finans',
        amount: 100000.0,
        months: 6,
      );

      expect(loanSuccess, isTrue);
      expect(container.read(gameProvider).balance, equals(initialBalance + 100000.0));
      expect(container.read(gameProvider).activeLoans.length, equals(1));

      final loan = container.read(gameProvider).activeLoans.first;
      final paySuccess = notifier.payLoanInstallment(loan.id);

      expect(paySuccess, isTrue);
      expect(container.read(gameProvider).activeLoans.first.remainingInstallments, equals(5));
    });

    test('DealershipModel initial state grants 75.000 TL and Heritage Car', () {
      final initialDealership = DealershipModel.initial();
      expect(initialDealership.balance, equals(75000.0));
      expect(initialDealership.ownedCars.length, equals(1));
      expect(initialDealership.ownedCars.first.brand, equals('Tofaş'));
      expect(initialDealership.ownedCars.first.modelName, contains('Murat 124'));
    });

    test('PartOrderModel evaluates delivery progress and remaining time correctly', () {
      final order = PartOrderModel(
        id: 'order_test_1',
        carId: 'car_heritage_dede',
        partName: 'Kaput',
        orderType: OrderType.masterRepair,
        cost: 4500.0,
        orderedAt: DateTime.now().subtract(const Duration(seconds: 10)),
        deliveryDurationSeconds: 60,
      );

      expect(order.isDelivered, isFalse);
      expect(order.remainingSeconds, lessThanOrEqualTo(50));
      expect(order.progressPercentage, greaterThan(0.0));
    });

    test('RepairEngine applies installed part orders correctly', () {
      final car = DealershipModel.initial().ownedCars.first;
      final restoredCar = RepairEngine.applyInstalledPart(car, 'Kaput', OrderType.newOemPart);

      expect(restoredCar.expertise.bodyParts['Kaput'], equals(PartStatus.original));
      expect(restoredCar.expertise.partConditions['Kaput'], equals(100.0));
    });
  });
}
