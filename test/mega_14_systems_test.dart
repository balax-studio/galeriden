import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/cheque_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/mega_systems_extensions_model.dart';
import 'package:galeriden/data/models/scrapyard_model.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('14 Sistem Kapsamlı Geliştirme Test Paketi', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('1. DealerTitle and Morning Siftah Ritual work correctly', () {
      expect(DealerTitle.fromId('samanlik_kurdu'), equals(DealerTitle.samanlikKurdu));
      expect(DealerTitle.fromId('unknown'), equals(DealerTitle.caylak));

      final notifier = container.read(gameProvider.notifier);
      final initialBalance = notifier.state.balance;

      final success = notifier.performMorningSiftah();
      expect(success, isTrue);
      expect(notifier.state.balance, equals(initialBalance + 100.0));
      expect(notifier.state.skills.xp, greaterThan(0));
    });

    test('2. Dyno HP test and 3-Tier Expertise packages calculate correctly', () {
      final notifier = container.read(gameProvider.notifier);
      final car = CarModel(
        id: 'dyno_test_car_1',
        brand: 'BMW',
        modelName: '320i',
        modelYear: 2020,
        bodyType: 'Sedan',
        colorHex: '#FFFFFF',
        baseMarketValue: 1200000.0,
        currentPurchasePrice: 1000000.0,
        expertise: ExpertiseReport(
          engineCondition: 92.0,
          transmissionCondition: 90.0,
          tramerAmount: 0,
          mileage: 45000,
          isMileageTampered: false,
          bodyParts: {'Kaput': PartStatus.original},
        ),
      );

      notifier.state = notifier.state.copyWith(
        balance: 50000.0,
        ownedCars: [car],
      );

      final report = notifier.performDynoHpTest(car.id, ExpertisePackageTier.vipFull);
      expect(report, isNotNull);
      expect(report!.measuredHp, greaterThan(150));
      expect(report.healthPercentage, greaterThan(85.0));

      final updatedCar = notifier.state.ownedCars.first;
      expect(updatedCar.appliedDetailingOptionIds.contains('dyno_certified'), isTrue);
      expect(updatedCar.baseMarketValue, equals(1200000.0));
      expect(updatedCar.estimatedRealValue, greaterThan(car.estimatedRealValue));
    });

    test('3. Stage 1 & 2 Chip Tuning Remap and Bodykit boost car performance and value', () {
      final notifier = container.read(gameProvider.notifier);
      final car = CarModel(
        id: 'tuning_car_1',
        brand: 'Golf',
        modelName: 'R-Line',
        modelYear: 2022,
        bodyType: 'Hatchback',
        colorHex: '#38BDF8',
        baseMarketValue: 900000.0,
        currentPurchasePrice: 850000.0,
        expertise: ExpertiseReport(
          engineCondition: 95.0,
          transmissionCondition: 95.0,
          tramerAmount: 0,
          mileage: 25000,
          isMileageTampered: false,
          bodyParts: {'Kaput': PartStatus.original},
        ),
      );

      notifier.state = notifier.state.copyWith(
        balance: 50000.0,
        ownedCars: [car],
      );

      // Stage 2 Tuning
      final tuneSuccess = notifier.applyChipTuning(car.id, ChipTuningStage.stage2);
      expect(tuneSuccess, isTrue);
      expect(notifier.state.ownedCars.first.appliedDetailingOptionIds.contains('stage_2_ecu'), isTrue);
      expect(notifier.state.ownedCars.first.baseMarketValue, equals(900000.0));
      expect(notifier.state.ownedCars.first.estimatedRealValue, greaterThan(900000.0));

      // Bodykit & Cam Filmi
      final bodykitSuccess = notifier.installBodykitAndTint(car.id);
      expect(bodykitSuccess, isTrue);
      expect(notifier.state.ownedCars.first.appliedDetailingOptionIds.contains('bodykit_tint'), isTrue);
      expect(notifier.state.ownedCars.first.baseMarketValue, equals(900000.0));
    });

    test('4. Turkish Hospitality Tea, Coffee and Hometown Plate in negotiation', () {
      final notifier = container.read(gameProvider.notifier);
      final car = CarModel(
        id: 'hospitality_car_1',
        brand: 'Egea',
        modelName: 'Cross',
        modelYear: 2023,
        bodyType: 'SUV',
        colorHex: '#D97706',
        baseMarketValue: 750000.0,
        currentPurchasePrice: 700000.0,
        plateNumber: '34 XYZ 99',
        expertise: ExpertiseReport(
          engineCondition: 88.0,
          transmissionCondition: 88.0,
          tramerAmount: 0,
          mileage: 15000,
          isMileageTampered: false,
          bodyParts: {'Kaput': PartStatus.original},
        ),
      );

      notifier.state = notifier.state.copyWith(
        balance: 10000.0,
        ownedCars: [car],
      );

      final teaSuccess = notifier.treatNegotiationBeverage(NegotiationTreat.tea);
      expect(teaSuccess, isTrue);
      expect(notifier.state.balance, equals(9950.0));

      final plateSuccess = notifier.giftHometownPlate(car.id, '06');
      expect(plateSuccess, isTrue);
      expect(notifier.state.ownedCars.first.plateNumber, equals('06 GAL 34'));
      expect(notifier.state.balance, equals(9450.0));
    });

    test('5. Factoring Cheque cashing credits cash at 8.5% discount', () {
      final notifier = container.read(gameProvider.notifier);
      final cheque = Cheque(
        id: 'cheque_factoring_1',
        customerName: 'Cengiz İnşaat',
        amount: 200000.0,
        daysUntilDue: 25,
      );

      notifier.state = notifier.state.copyWith(
        balance: 10000.0,
        activeCheques: [cheque],
      );

      final deal = notifier.cashInChequeWithFactoring(cheque.id);
      expect(deal, isNotNull);
      expect(deal!.payoutCash, equals(183000.0));
      expect(notifier.state.activeCheques.isEmpty, isTrue);
      expect(notifier.state.balance, equals(193000.0));
    });

    test('6. Police encounter choices and Chassis cold stamping work as expected', () {
      final notifier = container.read(gameProvider.notifier);
      final car = CarModel(
        id: 'black_market_car_1',
        brand: 'Mercedes',
        modelName: 'C200',
        modelYear: 2019,
        bodyType: 'Sedan',
        colorHex: '#000000',
        baseMarketValue: 1500000.0,
        currentPurchasePrice: 900000.0,
        expertise: ExpertiseReport(
          engineCondition: 80.0,
          transmissionCondition: 80.0,
          tramerAmount: 15000,
          mileage: 60000,
          isMileageTampered: false,
          bodyParts: {'Kaput': PartStatus.original},
        ),
      );

      notifier.state = notifier.state.copyWith(
        balance: 20000.0,
        ownedCars: [car],
      );

      // Cold Stamping
      final coldStampSuccess = notifier.coldStampChassis(car.id);
      expect(coldStampSuccess, isTrue);
      expect(notifier.state.ownedCars.first.isChassisRepaired, isTrue);
      expect(notifier.state.ownedCars.first.appliedDetailingOptionIds.contains('chassis_restamped'), isTrue);

      // Police Encounter Bribe
      final bribeSuccess = notifier.handlePoliceEncounter(car.id, PoliceEncounterAction.bribe);
      expect(bribeSuccess, isTrue);
    });

    test('7. Scrapyard bulk selling and treasure search provide cash', () {
      final notifier = container.read(gameProvider.notifier);
      final scrapPart = SalvagedPart(
        id: 'part_1',
        name: 'Çıkma Şanzıman',
        carModelName: 'Fiat Egea',
        category: 'transmission',
        conditionPercent: 80,
        estimatedValue: 6000.0,
      );

      notifier.state = notifier.state.copyWith(
        balance: 5000.0,
        salvagedParts: [scrapPart],
      );

      final bulkPayout = notifier.sellScrapPartsInBulk();
      expect(bulkPayout, greaterThanOrEqualTo(1500.0));
      expect(notifier.state.balance, greaterThanOrEqualTo(6500.0));
      expect(notifier.state.salvagedParts.isEmpty, isTrue);

      final treasureCash = notifier.searchScrapForTreasures();
      expect(treasureCash, anyOf(isNull, greaterThanOrEqualTo(0.0)));
    });

    test('8. Auto wash tunnel, ozone sanitization, VIP film set and review responses', () {
      final notifier = container.read(gameProvider.notifier);
      final car = CarModel(
        id: 'vip_rental_car_1',
        brand: 'Porsche',
        modelName: 'Panamera',
        modelYear: 2021,
        bodyType: 'Spor',
        colorHex: '#EF4444',
        baseMarketValue: 3500000.0,
        currentPurchasePrice: 3000000.0,
        expertise: ExpertiseReport(
          engineCondition: 98.0,
          transmissionCondition: 98.0,
          tramerAmount: 0,
          mileage: 20000,
          isMileageTampered: false,
          bodyParts: {'Kaput': PartStatus.original},
        ),
      );

      notifier.state = notifier.state.copyWith(
        balance: 100000.0,
        ownedCars: [car],
        reputationScore: 50,
      );

      // Tunnel
      final tunnelSuccess = notifier.purchaseAutoWashTunnel();
      expect(tunnelSuccess, isTrue);
      expect(notifier.state.unlockedBuildings.contains('auto_wash_tunnel'), isTrue);

      // Ozone
      final ozoneSuccess = notifier.applyOzoneSanitization(car.id);
      expect(ozoneSuccess, isTrue);
      expect(notifier.state.ownedCars.first.appliedDetailingOptionIds.contains('ozone_sanitized'), isTrue);

      // VIP Film Set
      final contract = VipSetRentalContract.generate(car);
      expect(contract.totalPayout, greaterThan(10000.0));
      final acceptSuccess = notifier.acceptVipFilmSetRental(contract);
      expect(acceptSuccess, isTrue);

      // Reviews & Influencer
      notifier.respondToReview('rev_1', 'Teşekkürler!');
      expect(notifier.state.reputationScore, equals(55));

      final sponsorSuccess = notifier.sponsorAutoInfluencer();
      expect(sponsorSuccess, isTrue);
      expect(notifier.state.reputationScore, equals(70));
    });

    test('9. Financial Health Grade calculates correct letters', () {
      final gradeAPlus = HealthGrade.calculate(
        balance: 500000.0,
        totalDebt: 50000.0,
        totalInventoryValue: 2000000.0,
        dailyExpenses: 2000.0,
      );
      expect(gradeAPlus, equals(HealthGrade.aPlus));

      final gradeD = HealthGrade.calculate(
        balance: 10000.0,
        totalDebt: 60000.0,
        totalInventoryValue: 50000.0,
        dailyExpenses: 2000.0,
      );
      expect(gradeD, equals(HealthGrade.d));
    });
  });
}
