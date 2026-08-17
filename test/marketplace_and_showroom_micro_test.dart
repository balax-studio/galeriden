import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/listing_model.dart';
import 'package:galeriden/data/models/marketplace_extensions_model.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('2. El Pazarı & Showroom Stok Yönetimi Mikro Geliştirme Test Paketi', () {
    late ProviderContainer container;
    late CarModel car1;
    late CarModel car2;

    setUp(() {
      container = ProviderContainer();

      car1 = CarModel(
        id: 'market_test_car_1',
        brand: 'Honda',
        modelName: 'Civic',
        modelYear: 2019,
        bodyType: 'Sedan',
        colorHex: '#000000',
        baseMarketValue: 500000.0,
        currentPurchasePrice: 420000.0,
        expertise: ExpertiseReport(
          mileage: 80000,
          isMileageTampered: false,
          engineCondition: 90.0,
          transmissionCondition: 90.0,
          tramerAmount: 0,
          bodyParts: {'Kaput': PartStatus.original},
          partConditions: {'Kaput': 100.0},
        ),
      );

      car2 = CarModel(
        id: 'market_test_car_2',
        brand: 'BMW',
        modelName: '320i',
        modelYear: 2021,
        bodyType: 'Sedan',
        colorHex: '#FFFFFF',
        baseMarketValue: 900000.0,
        currentPurchasePrice: 800000.0,
        expertise: ExpertiseReport(
          mileage: 45000,
          isMileageTampered: false,
          engineCondition: 85.0,
          transmissionCondition: 85.0,
          tramerAmount: 5000,
          bodyParts: {'Kaput': PartStatus.painted},
          partConditions: {'Kaput': 75.0},
        ),
      );

      container.read(gameProvider.notifier).state = container.read(gameProvider).copyWith(
        balance: 200000,
        ownedCars: [car1, car2],
      );
    });

    test('1. Seller personas map correctly from seller traits with discount flexibilities', () {
      final personaUrgent = SellerPersona.fromString('Acil Satılık');
      final personaOfficer = SellerPersona.fromString('Memurdan');
      final personaExpat = SellerPersona.fromString('Gurbetçiden');
      final personaDealer = SellerPersona.fromString('Galeriden');

      expect(personaUrgent, equals(SellerPersona.urgentCash));
      expect(personaUrgent.discountFlexibility, greaterThan(0.20));

      expect(personaOfficer, equals(SellerPersona.meticulousOfficer));
      expect(personaOfficer.discountFlexibility, lessThan(0.10));

      expect(personaExpat, equals(SellerPersona.expat));
      expect(personaDealer, equals(SellerPersona.colleagueDealer));
    });

    test('2. MarketSortOption sorts listings by price, mileage, and model year', () {
      final list1 = ListingModel(
        id: 'list_1',
        car: car1,
        sellerName: 'Ahmet',
        sellerTrait: 'Sahibinden',
        sellerCity: 'Ankara',
        title: 'Temiz Civic',
        description: 'Bakımlı',
        askingPrice: 480000.0,
        createdAt: DateTime.now(),
      );

      final list2 = ListingModel(
        id: 'list_2',
        car: car2,
        sellerName: 'Mehmet',
        sellerTrait: 'Galeriden',
        sellerCity: 'İstanbul',
        title: 'BMW 320i',
        description: 'M Sport',
        askingPrice: 850000.0,
        createdAt: DateTime.now(),
      );

      final listings = [list2, list1];

      // Sort by Price Ascending
      final priceAsc = MarketSortOption.priceAsc.sortListings(listings);
      expect(priceAsc.first.id, equals('list_1'));
      expect(priceAsc.last.id, equals('list_2'));

      // Sort by Model Year Descending
      final yearDesc = MarketSortOption.yearDesc.sortListings(listings);
      expect(yearDesc.first.id, equals('list_2')); // 2021 model
      expect(yearDesc.last.id, equals('list_1')); // 2019 model

      // Sort by Mileage Ascending
      final mileageAsc = MarketSortOption.mileageAsc.sortListings(listings);
      expect(mileageAsc.first.id, equals('list_2')); // 45k km
      expect(mileageAsc.last.id, equals('list_1')); // 80k km
    });

    test('3. Listing slogans contain 4 distinct marketing angles and appeal buffs', () {
      expect(ListingSlogan.presets.length, greaterThanOrEqualTo(4));
      for (final slogan in ListingSlogan.presets) {
        expect(slogan.name, isNotEmpty);
        expect(slogan.headline, isNotEmpty);
        expect(slogan.appealBuff, isNotEmpty);
      }
    });

    test('4. publishAllReadyCars publishes unlisted ready cars at recommended price and awards XP', () {
      final initialXp = container.read(gameProvider).skills.xp;

      // Both cars are unlisted and healthy (>70% condition)
      expect(container.read(gameProvider).ownedCars.every((c) => !c.isListed), isTrue);

      final publishedCount = container.read(gameProvider.notifier).publishAllReadyCars();

      expect(publishedCount, equals(2));
      final updatedCars = container.read(gameProvider).ownedCars;
      expect(updatedCars.every((c) => c.isListed), isTrue);
      expect(container.read(gameProvider).skills.xp, equals(initialXp + 50));
    });

    test('5. startWeekendFlashSale applies 10% discount on listed cars and triggers offers', () {
      // First publish cars
      container.read(gameProvider.notifier).publishAllReadyCars();
      final initialPrice1 = container.read(gameProvider).ownedCars.first.listingPrice;

      final discountedCount = container.read(gameProvider.notifier).startWeekendFlashSale();

      expect(discountedCount, equals(2));
      final discountedPrice1 = container.read(gameProvider).ownedCars.first.listingPrice;
      expect(discountedPrice1, equals((initialPrice1 * 0.90).roundToDouble()));
    });
  });
}
