import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/detailing_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/offer_model.dart';
import 'package:galeriden/data/models/part_order_model.dart';
import 'package:galeriden/data/models/sale_record_model.dart';
import 'package:galeriden/data/models/staff_model.dart';
import 'package:galeriden/domain/usecases/repair_engine.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Araç Bakım & Onarım Maliyeti ve Kâr Hesaplama Test Paketi', () {
    late ProviderContainer container;

    CarModel createBaseCar({
      String id = 'car_test_1',
      double purchasePrice = 200000.0,
      double marketValue = 250000.0,
      double maintenanceCost = 0.0,
      double? listingPrice,
    }) {
      return CarModel(
        id: id,
        brand: 'Toyota',
        modelName: 'Corolla',
        modelYear: 2021,
        bodyType: 'Sedan',
        colorHex: '#336699',
        baseMarketValue: marketValue,
        currentPurchasePrice: purchasePrice,
        maintenanceCost: maintenanceCost,
        customListingPrice: listingPrice,
        expertise: ExpertiseReport(
          mileage: 80000,
          isMileageTampered: false,
          engineCondition: 60.0,
          transmissionCondition: 60.0,
          tramerAmount: 0,
          bodyParts: {
            'Kaput': PartStatus.painted,
            'Tavan': PartStatus.original,
          },
          partConditions: {
            'Kaput': 70.0,
            'Tavan': 100.0,
          },
        ),
      );
    }

    setUp(() {
      container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.stopPeriodicOrganicOfferTimer();
    });

    tearDown(() {
      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
      container.dispose();
    });

    test('1. CarModel maintenanceCost, totalCost ve netEstimatedProfit hesapları doğrulanır', () {
      final car = createBaseCar(
        purchasePrice: 200000.0,
        marketValue: 260000.0,
        listingPrice: 260000.0,
      );
      expect(car.maintenanceCost, equals(0.0));
      expect(car.totalCost, equals(200000.0));
      expect(car.netEstimatedProfit, equals(60000.0)); // 260k - 200k
      expect(car.profitMarginPercent, closeTo(30.0, 0.01)); // (60k / 200k) * 100

      // Bakım masrafı eklendiğinde
      final upgradedCar = car.copyWith(maintenanceCost: 25000.0);
      expect(upgradedCar.maintenanceCost, equals(25000.0));
      expect(upgradedCar.totalCost, equals(225000.0)); // 200k + 25k
      expect(upgradedCar.netEstimatedProfit, equals(35000.0)); // 260k - 225k
      expect(upgradedCar.profitMarginPercent, closeTo((35000.0 / 225000.0) * 100, 0.01));

      // İlanda fiyat belirlendiğinde
      final listedCar = upgradedCar.copyWith(customListingPrice: 270000.0);
      expect(listedCar.netEstimatedProfit, equals(45000.0)); // 270k - 225k

      // Serialization kontrolü
      final json = listedCar.toJson();
      expect(json['maintenanceCost'], equals(25000.0));
      final deserialized = CarModel.fromJson(json);
      expect(deserialized.maintenanceCost, equals(25000.0));
      expect(deserialized.totalCost, equals(225000.0));
    });

    test('2. SaleRecordModel maintenanceCost ve totalCost alanları serialization dahil çalışır', () {
      final record = SaleRecordModel(
        id: 'sale_123',
        carTitle: 'Toyota Corolla',
        buyerName: 'Ahmet Bey',
        purchasePrice: 150000.0,
        maintenanceCost: 15000.0,
        salePrice: 190000.0,
        saleDay: 5,
        saleDate: DateTime.now(),
        netProfit: 25000.0, // 190k - 165k
      );

      expect(record.purchasePrice, equals(150000.0));
      expect(record.maintenanceCost, equals(15000.0));
      expect(record.totalCost, equals(165000.0));

      final json = record.toJson();
      expect(json['maintenanceCost'], equals(15000.0));
      final parsed = SaleRecordModel.fromJson(json);
      expect(parsed.maintenanceCost, equals(15000.0));
      expect(parsed.totalCost, equals(165000.0));
      expect(parsed.netProfit, equals(25000.0));
    });

    test('3. Oto yıkama ve detaylı temizlik car.maintenanceCost değerini artırır', () {
      final initialCar = createBaseCar(purchasePrice: 180000.0);
      final notifier = container.read(gameProvider.notifier);
      notifier.state = notifier.state.copyWith(
        balance: 50000.0,
        ownedCars: [initialCar],
      );

      // Yıkama servisi uygula
      final washSuccess = notifier.performWashService(
        initialCar.id,
        cost: 1500.0,
        valueBoostPercent: 0.03,
        setWashed: true,
      );
      expect(washSuccess, isTrue);

      final carAfterWash = notifier.state.ownedCars.firstWhere((c) => c.id == initialCar.id);
      expect(carAfterWash.maintenanceCost, equals(1500.0));
      expect(carAfterWash.totalCost, equals(181500.0));

      // Detailing seçeneği uygula
      final option = DetailingOption.getAvailableOptions().first; // cost: 3500.0
      final detailingSuccess = notifier.applyDetailingOption(initialCar.id, option);
      expect(detailingSuccess, isTrue);

      final carAfterDetailing = notifier.state.ownedCars.firstWhere((c) => c.id == initialCar.id);
      expect(carAfterDetailing.maintenanceCost, equals(1500.0 + option.cost));
      expect(carAfterDetailing.totalCost, equals(180000.0 + 1500.0 + option.cost));
    });

    test('4. Atölye istasyon onarımı car.maintenanceCost değerini artırır', () {
      final initialCar = createBaseCar(purchasePrice: 200000.0);
      final notifier = container.read(gameProvider.notifier);
      notifier.state = notifier.state.copyWith(
        balance: 50000.0,
        ownedCars: [initialCar],
      );

      final repairSuccess = notifier.performWorkshopStationRepair(
        initialCar.id,
        repairType: 'engine',
        cost: 3500.0,
      );
      expect(repairSuccess, isTrue);

      // Sanayi çırağı indirimi (%15 indirim) ile 3500 * 0.85 = 2975 TL
      final carAfterRepair = notifier.state.ownedCars.firstWhere((c) => c.id == initialCar.id);
      expect(carAfterRepair.maintenanceCost, equals(2975.0));
      expect(carAfterRepair.totalCost, equals(202975.0));
    });

    test('5. Mekanik tier onarımı ve anında parça montajı car.maintenanceCost değerini artırır', () {
      final initialCar = createBaseCar(purchasePrice: 200000.0);
      final notifier = container.read(gameProvider.notifier);
      notifier.state = notifier.state.copyWith(
        balance: 50000.0,
        ownedCars: [initialCar],
        hiredStaff: [
          StaffModel(
            id: 'staff_1',
            name: 'Ali Usta',
            role: StaffRole.masterMechanic,
            morale: 80,
            hiredAt: DateTime.now(),
          ),
        ],
      );

      final result = notifier.repairEngineWithTier(initialCar, RepairTier.master);
      expect(result.isSuccess, isTrue);
      expect(result.costPaid, greaterThan(0));

      final updatedCar = notifier.state.ownedCars.firstWhere((c) => c.id == initialCar.id);
      expect(updatedCar.maintenanceCost, equals(result.costPaid));
      expect(updatedCar.totalCost, equals(200000.0 + result.costPaid));

      // Instant repair kontrolü
      final instantSuccess = notifier.instantRepair(
        carId: initialCar.id,
        partName: 'Kaput',
        orderType: OrderType.newOemPart,
        cost: 5000.0,
      );
      expect(instantSuccess, isTrue);

      final carAfterInstant = notifier.state.ownedCars.firstWhere((c) => c.id == initialCar.id);
      expect(carAfterInstant.maintenanceCost, equals(result.costPaid + 5000.0));
    });

    test('6. Satış (sellCar) toplam maliyeti (totalCost) baz alarak net kâr hesaplar', () {
      // Araç: Alış 200.000, Bakım 20.000, Toplam Maliyet 220.000
      final car = createBaseCar(
        purchasePrice: 200000.0,
        maintenanceCost: 20000.0,
      );

      final notifier = container.read(gameProvider.notifier);
      notifier.state = notifier.state.copyWith(
        balance: 50000.0,
        totalProfit: 10000.0,
        ownedCars: [car],
      );

      // 250.000 TL'ye sat
      final sold = notifier.sellCar(car.id, 250000.0);
      expect(sold, isTrue);

      // Kâr: 250.000 - 220.000 (totalCost) = 30.000 TL
      // totalProfit: 10.000 + 30.000 = 40.000 TL
      expect(notifier.state.totalProfit, equals(40000.0));
      expect(notifier.state.balance, equals(300000.0));
      expect(notifier.state.ownedCars.any((c) => c.id == car.id), isFalse);
    });

    test('7. Müşteri teklifi kabulünde (completeSale) kâr car.totalCost üzerinden hesaplanır', () {
      final car = createBaseCar(
        purchasePrice: 150000.0,
        maintenanceCost: 15000.0, // totalCost = 165000
        listingPrice: 190000.0,
      );

      final notifier = container.read(gameProvider.notifier);
      notifier.state = notifier.state.copyWith(
        balance: 10000.0,
        ownedCars: [car],
        salesHistory: [],
      );

      // Gelen teklif: 180.000 TL
      // Beklenen kâr: 180.000 - 165.000 = 15.000 TL
      final offer = OfferModel(
        id: 'offer_test_1',
        carId: car.id,
        buyerName: 'Zeynep Kaya',
        offeredAmount: 180000.0,
        buyerMessage: 'Araç için anında nakit veriyorum.',
        createdAt: DateTime.now(),
      );

      final completed = notifier.completeSale(offer);
      expect(completed, isTrue);

      expect(notifier.state.salesHistory.length, equals(1));
      final sale = notifier.state.salesHistory.first;
      expect(sale.maintenanceCost, equals(15000.0));
      expect(sale.totalCost, equals(165000.0));
      expect(sale.netProfit, equals(15000.0));
    });

    test('8. Müzayede satışı (sellCarAtAuction) kâr hesabında car.totalCost kullanır', () {
      final car = createBaseCar(
        purchasePrice: 100000.0,
        maintenanceCost: 20000.0, // totalCost = 120000
      );

      final notifier = container.read(gameProvider.notifier);
      notifier.state = notifier.state.copyWith(
        balance: 10000.0,
        ownedCars: [car],
        salesHistory: [],
      );

      // Satış fiyatı 150.000, komisyon 5.000, sabit ücret 2.000 => net ele geçen: 143.000
      // Net kâr: 143.000 - 120.000 (totalCost) = 23.000 TL
      final sold = notifier.sellCarAtAuction(
        carId: car.id,
        salePrice: 150000.0,
        commission: 5000.0,
        fixedFee: 2000.0,
        buyerName: 'Müzayede Alıcısı',
      );
      expect(sold, isTrue);

      final record = notifier.state.salesHistory.first;
      expect(record.maintenanceCost, equals(20000.0));
      expect(record.totalCost, equals(120000.0));
      expect(record.netProfit, equals(23000.0));
    });
  });
}
