import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/vehicle_category.dart';
import 'package:galeriden/domain/usecases/consignment_auction_engine.dart';
import 'package:galeriden/core/constants/first_time_action_keys.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';

CarModel createSampleCar({
  String id = 'car_test_1',
  String brand = 'Vosgen',
  String modelName = 'Pas-At',
  int modelYear = 2020,
  String bodyType = 'Sedan',
  double baseMarketValue = 600000.0,
  double purchasePrice = 520000.0,
  bool isRare = false,
  bool isBarnFind = false,
  String plateRarity = 'standard',
  String colorRarity = 'standard',
  VehicleCategory vehicleCategory = VehicleCategory.car,
  bool isRented = false,
  bool isLockedInShowcase = false,
  bool isConsignment = false,
  double engineCondition = 92.0,
  double transmissionCondition = 88.0,
  int tramerAmount = 12000,
}) {
  return CarModel(
    id: id,
    brand: brand,
    modelName: modelName,
    modelYear: modelYear,
    bodyType: bodyType,
    colorHex: '0xFFFFFFFF',
    colorDisplayName: 'Beyaz',
    baseMarketValue: baseMarketValue,
    currentPurchasePrice: purchasePrice,
    isRare: isRare,
    isBarnFind: isBarnFind,
    plateNumber: '34ABC123',
    plateRarity: plateRarity,
    colorRarity: colorRarity,
    vehicleCategory: vehicleCategory,
    isRented: isRented,
    isLockedInShowcase: isLockedInShowcase,
    isConsignment: isConsignment,
    expertise: ExpertiseReport(
      engineCondition: engineCondition,
      transmissionCondition: transmissionCondition,
      mileage: 65000,
      tramerAmount: tramerAmount,
      isMileageTampered: false,
      bodyParts: const {'Kaput': PartStatus.original, 'Tavan': PartStatus.original},
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ConsignmentAuctionEngine Unit Tests', () {
    test('1. Eligibility checks: rented, showcase-locked, or consignment cars cannot be auctioned', () {
      final normalCar = createSampleCar();
      expect(ConsignmentAuctionEngine.canListCar(normalCar), isTrue);

      final rentedCar = createSampleCar(isRented: true);
      expect(ConsignmentAuctionEngine.canListCar(rentedCar), isFalse);

      final showcaseCar = createSampleCar(isLockedInShowcase: true);
      expect(ConsignmentAuctionEngine.canListCar(showcaseCar), isFalse);

      final consignmentCar = createSampleCar(isConsignment: true);
      expect(ConsignmentAuctionEngine.canListCar(consignmentCar), isFalse);
    });

    test('2. Fee calculation accuracy: 0.5% commission + ₺1,250 fixed listing fee', () {
      // 500,000 TL sale price
      final fees500k = ConsignmentAuctionEngine.calculateAuctionFees(500000.0);
      expect(fees500k.commission, equals(2500.0));
      expect(fees500k.fixedFee, equals(1250.0));
      expect(fees500k.totalDeductions, equals(3750.0));
      expect(fees500k.netPayout, equals(496250.0));

      // 100,000 TL sale price
      final fees100k = ConsignmentAuctionEngine.calculateAuctionFees(100000.0);
      expect(fees100k.commission, equals(500.0));
      expect(fees100k.fixedFee, equals(1250.0));
      expect(fees100k.totalDeductions, equals(1750.0));
      expect(fees100k.netPayout, equals(98250.0));
    });

    test('3. Auction initialization produces correct starting price and buyer pool', () {
      final car = createSampleCar(baseMarketValue: 500000.0);
      final reservePrice = 350000.0;
      final auction = ConsignmentAuctionEngine.createAuction(
        car: car,
        reservePrice: reservePrice,
      );

      expect(auction.reservePrice, equals(350000.0));
      expect(auction.startingPrice, equals(280000.0)); // 80% of 350,000
      expect(auction.currentBid, equals(280000.0));
      expect(auction.secondsRemaining, equals(30));
      expect(auction.isEnded, isFalse);
      expect(auction.buyers.length, greaterThanOrEqualTo(4));
    });

    test('4. Specification tuning: Rare / Classic / Special color cars attract high collector budgets', () {
      final standardCar = createSampleCar(isRare: false, colorRarity: 'standard');
      final rareCar = createSampleCar(isRare: true, colorRarity: 'legendary', bodyType: 'Klasik', modelYear: 1995);

      final standardBuyers = ConsignmentAuctionEngine.generateBuyersForCar(standardCar);
      final rareBuyers = ConsignmentAuctionEngine.generateBuyersForCar(rareCar);

      final standardCollector = standardBuyers.firstWhere((b) => b.type == ConsignmentBuyerType.collector);
      final rareCollector = rareBuyers.firstWhere((b) => b.type == ConsignmentBuyerType.collector);

      // Collector budget should be noticeably higher for rare candidate
      expect(rareCollector.maxBudget, greaterThan(rareCar.estimatedRealValue * 0.95));
      expect(standardCollector.maxBudget, lessThanOrEqualTo(standardCar.estimatedRealValue * 1.15));
    });

    test('5. Specification tuning: Commercial vehicles attract higher fleet manager budgets', () {
      final commercialCar = createSampleCar(vehicleCategory: VehicleCategory.commercial, bodyType: 'Minivan');
      final passengerCar = createSampleCar(vehicleCategory: VehicleCategory.classic, bodyType: 'Coupe');

      final commercialBuyers = ConsignmentAuctionEngine.generateBuyersForCar(commercialCar);
      final passengerBuyers = ConsignmentAuctionEngine.generateBuyersForCar(passengerCar);

      final commercialFleet = commercialBuyers.firstWhere((b) => b.type == ConsignmentBuyerType.fleet);
      final passengerFleet = passengerBuyers.firstWhere((b) => b.type == ConsignmentBuyerType.fleet);

      expect(commercialFleet.maxBudget, greaterThan(commercialCar.estimatedRealValue * 0.85));
      expect(passengerFleet.maxBudget, lessThanOrEqualTo(passengerCar.estimatedRealValue * 0.95));
    });

    test('6. Auction tick simulation: bids increment, reserve price logic, and hammer resolution', () {
      final car = createSampleCar(baseMarketValue: 400000.0);
      var auction = ConsignmentAuctionEngine.createAuction(
        car: car,
        reservePrice: 250000.0,
      );

      // Simulate full 35 ticks until completion
      for (int i = 0; i < 40; i++) {
        auction = ConsignmentAuctionEngine.tick(auction);
        if (auction.isEnded) break;
      }

      expect(auction.isEnded, isTrue);
      expect(auction.secondsRemaining, equals(0));

      if (auction.currentBid >= auction.reservePrice && auction.highestBidder != null) {
        expect(auction.isSold, isTrue);
        expect(auction.netPayout, greaterThan(0));
      } else {
        expect(auction.isSold, isFalse);
      }
    });
  });

  group('sellCarAtAuction State Integration Tests', () {
    test('7. GameInventoryMixin.sellCarAtAuction updates balance, inventory, and sales history', () async {
      final container = ProviderContainer();
      addTearDown(() {
        container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
        container.dispose();
      });

      final notifier = container.read(gameProvider.notifier);
      notifier.stopPeriodicOrganicOfferTimer();

      // Add a test car to ownedCars and pre-mark firstCarSell to isolate net cash arithmetic
      final car = createSampleCar(id: 'auction_target_car_1', purchasePrice: 200000.0);
      notifier.state = notifier.state.copyWith(
        ownedCars: [...notifier.state.ownedCars, car],
        completedFirstTimeActions: {
          ...notifier.state.completedFirstTimeActions,
          FirstTimeActionKeys.firstCarSell,
        },
      );

      final initialBalance = container.read(gameProvider).balance;
      final initialSold = container.read(gameProvider).carsSold;

      final salePrice = 300000.0;
      final commission = 1500.0;
      final fixedFee = 1250.0;
      final netCash = salePrice - commission - fixedFee; // 297,250.0

      final success = notifier.sellCarAtAuction(
        carId: car.id,
        salePrice: salePrice,
        commission: commission,
        fixedFee: fixedFee,
        buyerName: 'Koleksiyoner Selim Bey',
      );

      expect(success, isTrue);

      final state = container.read(gameProvider);
      // Car removed from garage
      expect(state.ownedCars.any((c) => c.id == car.id), isFalse);
      // Balance increased by net payout
      expect(state.balance, equals(initialBalance + netCash));
      // Cars sold incremented
      expect(state.carsSold, equals(initialSold + 1));
      // Sales history contains the record
      expect(state.salesHistory.first.carTitle, contains('• Müzayede'));
      expect(state.salesHistory.first.buyerName, equals('Koleksiyoner Selim Bey'));
      expect(state.salesHistory.first.salePrice, equals(salePrice));
    });
  });
}
