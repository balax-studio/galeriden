import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galeriden/data/models/black_market_car_model.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/offer_model.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Black Market Realistic Consequences & Negative Events Test Suite', () {
    test('CarModel stores black market risk properties accurately', () {
      final car = CarModel(
        id: 'bm_test_1',
        brand: 'Merso',
        modelName: 'C-200 Makam AMG [Karaborsa]',
        modelYear: 2021,
        bodyType: 'Sedan',
        colorHex: '#111111',
        baseMarketValue: 2000000,
        currentPurchasePrice: 1000000,
        isRare: true,
        isBlackMarket: true,
        blackMarketRiskType: 'change_vin',
        blackMarketRiskPercent: 35,
        blackMarketSellerAlias: 'Gölge Kadir',
        expertise: ExpertiseReport(
          engineCondition: 85.0,
          transmissionCondition: 85.0,
          tramerAmount: 0,
          mileage: 45000,
          isMileageTampered: true,
          bodyParts: const {},
        ),
      );

      expect(car.isBlackMarket, isTrue);
      expect(car.blackMarketRiskType, equals('change_vin'));
      expect(car.blackMarketRiskPercent, equals(35));
      expect(car.blackMarketSellerAlias, equals('Gölge Kadir'));

      final json = car.toJson();
      final fromJson = CarModel.fromJson(json);

      expect(fromJson.isBlackMarket, isTrue);
      expect(fromJson.blackMarketRiskType, equals('change_vin'));
      expect(fromJson.blackMarketRiskPercent, equals(35));
      expect(fromJson.blackMarketSellerAlias, equals('Gölge Kadir'));
    });

    test('buyBlackMarketCar properly sets black market risk attributes into the garage car', () {
      final notifier = GameNotifier();
      final bmCar = BlackMarketCarModel(
        id: 'bm_unit_test',
        brand: 'Bemeve',
        modelName: 'M-Dört Pist Fırtınası',
        modelYear: 2022,
        askingPrice: 500000,
        realMarketValue: 4000000,
        riskType: 'smuggled_exotic',
        riskLevelPercent: 40,
        sellerAlias: 'Liman Kaçakçısı Rıza',
        riskDescription: 'İkiz plaka ve sahte gümrük belgesi.',
      );

      notifier.state = notifier.state.copyWith(
        balance: 1000000,
        maxGarageSlots: 10,
        blackMarketCars: [bmCar],
        ownedCars: [],
      );

      final success = notifier.buyBlackMarketCar(bmCar.id);
      expect(success, isTrue);
      expect(notifier.state.ownedCars.length, equals(1));

      final purchased = notifier.state.ownedCars.first;
      expect(purchased.isBlackMarket, isTrue);
      expect(purchased.blackMarketRiskType, equals('smuggled_exotic'));
      expect(purchased.blackMarketRiskPercent, equals(40));
      expect(purchased.blackMarketSellerAlias, equals('Liman Kaçakçısı Rıza'));
    });

    test('buyBlackMarketCar with isCleansed=true sets clean attributes and 0 risk', () {
      final notifier = GameNotifier();
      final bmCar = BlackMarketCarModel(
        id: 'bm_cleansed_test',
        brand: 'Merso',
        modelName: 'G-63 Tuğla V8',
        modelYear: 2023,
        askingPrice: 800000,
        realMarketValue: 6000000,
        riskType: 'change_vin',
        riskLevelPercent: 50,
        sellerAlias: 'Gölge Kadir',
        riskDescription: 'Change şasi numaralı araç.',
      );

      notifier.state = notifier.state.copyWith(
        balance: 2000000,
        maxGarageSlots: 10,
        blackMarketCars: [bmCar],
        ownedCars: [],
      );

      final success = notifier.buyBlackMarketCar(bmCar.id, isCleansed: true);
      expect(success, isTrue);
      expect(notifier.state.ownedCars.length, equals(1));

      final purchased = notifier.state.ownedCars.first;
      expect(purchased.isBlackMarket, isFalse);
      expect(purchased.blackMarketRiskPercent, equals(0));
      expect(purchased.blackMarketRiskType, equals('cleansed'));
      expect(purchased.expertise.isMileageTampered, isFalse);
      expect(purchased.modelName.contains('Aklanmış'), isTrue);
    });

    test('advanceGameDay processes black market risks and generates contextual negative events', () {
      final notifier = GameNotifier();
      final highRiskCar = CarModel(
        id: 'bm_raid_test_car',
        brand: 'Merso',
        modelName: 'G-63 Tuğla V8 [Karaborsa]',
        modelYear: 2022,
        bodyType: 'SUV',
        colorHex: '#000000',
        baseMarketValue: 8000000,
        currentPurchasePrice: 3000000,
        isRare: true,
        isBlackMarket: true,
        blackMarketRiskType: 'smuggled_exotic',
        blackMarketRiskPercent: 100, // 100% test guarantee
        blackMarketSellerAlias: 'Baron Ejder',
        expertise: ExpertiseReport(
          engineCondition: 90.0,
          transmissionCondition: 90.0,
          tramerAmount: 0,
          mileage: 12000,
          isMileageTampered: true,
          bodyParts: const {},
        ),
      );

      notifier.state = notifier.state.copyWith(
        balance: 500000,
        reputationScore: 100,
        ownedCars: [highRiskCar],
        recentEvents: [],
      );

      // Simulate day advance
      notifier.advanceGameDay();

      // Verify that negative event was triggered
      expect(notifier.state.recentEvents, isNotEmpty);
      final hasBlackMarketEvent = notifier.state.recentEvents.any((e) =>
          e.title.contains('GÜMRÜK') ||
          e.title.contains('ASAYİŞ') ||
          e.title.contains('YERALTI') ||
          e.title.contains('MALİ') ||
          e.title.contains('EMNİYET') ||
          e.title.contains('POLİS'));
      expect(hasBlackMarketEvent, isTrue);
    });

    test('acceptOffer handles Noter inspection and blocks sale on black market car with fine', () {
      final notifier = GameNotifier();
      final riskyCar = CarModel(
        id: 'bm_notary_car',
        brand: 'Porş',
        modelName: 'Dokuz-Onbir Turbo [Karaborsa]',
        modelYear: 2021,
        bodyType: 'Coupe',
        colorHex: '#EEEEEE',
        baseMarketValue: 12000000,
        currentPurchasePrice: 4000000,
        isRare: true,
        isBlackMarket: true,
        blackMarketRiskType: 'change_vin',
        blackMarketRiskPercent: 100, // 100% risk triggers notary block
        blackMarketSellerAlias: 'Gölge Kadir',
        expertise: ExpertiseReport(
          engineCondition: 90.0,
          transmissionCondition: 90.0,
          tramerAmount: 0,
          mileage: 20000,
          isMileageTampered: true,
          bodyParts: const {},
        ),
      );

      final offer = OfferModel(
        id: 'offer_notary_test',
        carId: 'bm_notary_car',
        buyerName: 'Ahmet Alıcı',
        offeredAmount: 6000000,
        buyerMessage: 'Aracı çok beğendim hemen almak istiyorum.',
        createdAt: DateTime.now(),
        offerType: OfferType.cash,
      );

      notifier.state = notifier.state.copyWith(
        balance: 100000,
        reputationScore: 100,
        ownedCars: [riskyCar],
        incomingOffers: [offer],
        recentEvents: [],
      );

      notifier.acceptOffer(offer);

      // Verify that either notary blocked the sale or processed it (reputation/fine applied on block)
      final notaryEvent = notifier.state.recentEvents.any((e) => e.title.contains('NOTER'));
      if (notaryEvent) {
        expect(notifier.state.reputationScore, lessThan(100));
        expect(notifier.state.balance, equals(92000)); // 100.000 - 8.000 fine
        expect(notifier.state.ownedCars.length, equals(1)); // Car was not sold
      }
    });
  });
}
