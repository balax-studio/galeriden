import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/constants/car_specifications.dart';
import 'package:galeriden/core/localization/translations/ar_translations.dart';
import 'package:galeriden/core/localization/translations/de_translations.dart';
import 'package:galeriden/core/localization/translations/en_translations.dart';
import 'package:galeriden/core/localization/translations/es_translations.dart';
import 'package:galeriden/core/localization/translations/pt_translations.dart';
import 'package:galeriden/core/localization/translations/ru_translations.dart';
import 'package:galeriden/core/localization/translations/tr_translations.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/domain/usecases/market_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Hypercar Market & Pity Engine Tests', () {
    test('billionaire player (₺955M balance) generates healthy balance: 3 to 6 hypercars in 40 listings (~1 every 10-12 cars)', () {
      final listings = MarketEngine.generateRandomListings(
        count: 40,
        playerBalance: 955000000,
      );

      expect(listings.length, 40);

      final hyperListings = listings.where((l) => l.car.isHyperCar).toList();
      final normalListings = listings.where((l) => !l.car.isHyperCar).toList();

      // In 40 listings with 12-item chunks, pity guarantee ensures at least 3 hypercars.
      // Balanced weight (1.0) ensures hypercars do not flood the market (max 6).
      expect(hyperListings.length, greaterThanOrEqualTo(3));
      expect(hyperListings.length, lessThanOrEqualTo(6));

      // The majority of the marketplace (at least 34 out of 40) must be normal market cars
      expect(normalListings.length, greaterThanOrEqualTo(34));

      // Verify every hypercar has valid hyper attributes
      for (final listing in hyperListings) {
        expect(listing.car.isHyperCar, isTrue);
        expect(listing.car.currentPurchasePrice, greaterThanOrEqualTo(50000000));
        expect(listing.sellerTrait.contains('('), isFalse);
        expect(listing.sellerTrait.contains(')'), isFalse);
        expect(listing.title.contains('('), isFalse);
        expect(listing.title.contains(')'), isFalse);
      }
    });

    test('hypercar asking prices scale dynamically between ₺50M and ₺450M TL', () {
      final listings = MarketEngine.generateRandomListings(
        count: 50,
        playerBalance: 955000000,
      );

      final hyperListings = listings.where((l) => l.car.isHyperCar).toList();
      expect(hyperListings.isNotEmpty, isTrue);

      for (final listing in hyperListings) {
        expect(listing.car.currentPurchasePrice, greaterThanOrEqualTo(50000000));
        expect(listing.car.currentPurchasePrice, lessThanOrEqualTo(450000000));
      }
    });

    test('low budget player (₺100k balance) sees zero hypercars in marketplace', () {
      final listings = MarketEngine.generateRandomListings(
        count: 50,
        playerBalance: 100000,
      );

      final hyperListings = listings.where((l) => l.car.isHyperCar).toList();
      expect(hyperListings.isEmpty, isTrue);
    });

    test('CarSpecifications returns high-performance specs for all hypercar models', () {
      final hyperModelsToCheck = [
        ('Bugaç', 'Veyro 16.4 Dört-Turbo'),
        ('Bugaç', 'Şiron Safkan W16'),
        ('Bugaç', 'Divo Karbon Heykel'),
        ('Bugaç', 'Bolid Pist Roketi'),
        ('Köniğ', 'Agera RS İsveç Mermisi'),
        ('Köniğ', 'Jesko Taarruz Kanatlı'),
        ('Köniğ', 'Regera Hibrit Megavat'),
        ('Köniğ', 'Gemera Dört Kişilik Roket'),
        ('Pagan', 'Zonda F İtalyan Karbon'),
        ('Pagan', 'Huayra BC Rüzgar Şövalyesi'),
        ('Pagan', 'Utopia Saf Manuel V12'),
        ('Rolso', 'Fantom VIII Saray Kasa'),
        ('Rolso', 'Gost Safir Makam'),
        ('Rolso', 'Kullinan Zırhlı Taht'),
        ('Rolso', 'Spektr Elektrikli Malikane'),
        ('Ferro', 'LaFerro Hibrit V12'),
        ('Ferro', 'Daytona SP3 Safkan'),
      ];

      for (final item in hyperModelsToCheck) {
        final spec = CarSpecifications.getSpecs(item.$1, item.$2);
        // All hypercars have at least 550 HP
        expect(
          spec.horsepower,
          greaterThanOrEqualTo(550),
          reason: '${item.$1} ${item.$2} should have >= 550 HP but was ${spec.horsepower}',
        );
        // All hypercars have fast acceleration under 5.5s (even heavy luxury Rolso)
        expect(
          spec.zeroToHundredSeconds,
          lessThanOrEqualTo(5.5),
          reason: '${item.$1} ${item.$2} 0-100 should be <= 5.5s but was ${spec.zeroToHundredSeconds}',
        );
      }
    });

    test('isHyperCar detection works accurately for models and brands', () {
      final testExpertise = ExpertiseReport(
        engineCondition: 100,
        transmissionCondition: 100,
        tramerAmount: 0,
        mileage: 500,
        isMileageTampered: false,
        bodyParts: const {},
      );

      final bugacCar = CarModel(
        id: 'test_bugac',
        brand: 'Bugaç',
        modelName: 'Şiron Safkan W16',
        modelYear: 2023,
        bodyType: 'Coupe',
        colorHex: '#000000',
        currentPurchasePrice: 150000000,
        baseMarketValue: 150000000,
        expertise: testExpertise,
      );
      expect(bugacCar.isHyperCar, isTrue);

      final laFerroCar = CarModel(
        id: 'test_ferro',
        brand: 'Ferro',
        modelName: 'LaFerro Hibrit V12',
        modelYear: 2022,
        bodyType: 'Coupe',
        colorHex: '#FF0000',
        currentPurchasePrice: 110000000,
        baseMarketValue: 110000000,
        expertise: testExpertise,
      );
      expect(laFerroCar.isHyperCar, isTrue);

      final clunker = CarModel(
        id: 'test_clunker',
        brand: 'Doğan',
        modelName: 'SLX',
        modelYear: 1996,
        bodyType: 'Sedan',
        colorHex: '#FFFFFF',
        currentPurchasePrice: 150000,
        baseMarketValue: 150000,
        expertise: testExpertise,
      );
      expect(clunker.isHyperCar, isFalse);
    });

    test('7-language localization invariant: all hypercar keys exist without emojis or parentheses', () {
      final translationMaps = [
        ('tr', trTranslations),
        ('en', enTranslations),
        ('de', deTranslations),
        ('pt', ptTranslations),
        ('es', esTranslations),
        ('ru', ruTranslations),
        ('ar', arTranslations),
      ];

      final requiredKeys = [
        'badge_hyper_collection',
        'hyper_1',
        'hyper_2',
        'hyper_3',
        'hyper_4',
        'hyper_5',
        'desc_hyper_collector_1',
        'seller_profile_hyper_vip',
      ];

      final emojiPattern = RegExp(
        r'[\u{1F300}-\u{1F9FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]|[\u{1F600}-\u{1F64F}]|[\u{1F680}-\u{1F6FF}]',
        unicode: true,
      );

      for (final entry in translationMaps) {
        final lang = entry.$1;
        final map = entry.$2;

        for (final key in requiredKeys) {
          expect(map.containsKey(key), isTrue, reason: 'Language $lang missing key $key');
          final value = map[key]!;
          expect(value.isNotEmpty, isTrue, reason: 'Language $lang has empty value for $key');

          // Strict Invariant: Zero Unicode emojis
          expect(
            emojiPattern.hasMatch(value),
            isFalse,
            reason: 'Language $lang key $key contains forbidden emoji: $value',
          );

          // Strict Invariant: Zero Parentheses
          expect(
            value.contains('(') || value.contains(')'),
            isFalse,
            reason: 'Language $lang key $key contains forbidden parentheses: $value',
          );
        }
      }
    });
  });
}
