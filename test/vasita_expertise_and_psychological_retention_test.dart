import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/listing_model.dart';
import 'package:galeriden/domain/usecases/vasita_negotiation_engine.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:galeriden/presentation/providers/vasita_market_provider.dart';
import 'package:galeriden/core/localization/translations/tr_translations.dart';
import 'package:galeriden/core/localization/translations/en_translations.dart';
import 'package:galeriden/core/localization/translations/de_translations.dart';
import 'package:galeriden/core/localization/translations/pt_translations.dart';
import 'package:galeriden/core/localization/translations/es_translations.dart';
import 'package:galeriden/core/localization/translations/ru_translations.dart';
import 'package:galeriden/core/localization/translations/ar_translations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Vasita Psychological Retention & Expertise Engine Tests', () {
    test('performDetailedExpertise completes report, deducts 3500 cash, and rewards XP', () async {
      final container = ProviderContainer();
      addTearDown(() {
        container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
        container.dispose();
      });

      // Ensure player has sufficient balance
      final initialBalance = container.read(gameProvider).balance;
      expect(initialBalance, greaterThanOrEqualTo(3500.0));

      final market = container.read(vasitaMarketProvider);
      expect(market.isNotEmpty, isTrue);

      final listing = market.first;
      expect(listing.isExpertiseCompleted, isFalse);

      final success = container
          .read(vasitaMarketProvider.notifier)
          .performDetailedExpertise(listing.id, cost: 3500.0);

      expect(success, isTrue);

      final updatedListing = container
          .read(vasitaMarketProvider)
          .firstWhere((l) => l.id == listing.id);

      expect(updatedListing.isExpertiseCompleted, isTrue);
      // Deducts 3500 cost + firstExpertise first-time reward adds 5000
      expect(container.read(gameProvider).balance, closeTo(initialBalance - 3500.0 + 5000.0, 1.0));
      expect(container.read(gameProvider).npcRelationships['haydar_usta'], isNotNull);
    });

    test('VasitaNegotiationEngine provides dynamic thinking steps and nearMissAmount', () {
      expect(VasitaNegotiationEngine.thinkingStepKeys.length, greaterThanOrEqualTo(3));

      final testCar = CarModel(
        id: 'test_car',
        brand: 'Renault',
        modelName: 'Clio',
        modelYear: 2020,
        bodyType: 'Hatchback',
        colorHex: '#FFFFFF',
        baseMarketValue: 600000.0,
        currentPurchasePrice: 600000.0,
        expertise: ExpertiseReport(
          engineCondition: 85.0,
          transmissionCondition: 85.0,
          tramerAmount: 0,
          mileage: 60000,
          isMileageTampered: false,
          bodyParts: {},
        ),
      );

      final listing = ListingModel(
        id: 'list_test_1',
        sellerName: 'Ahmet Bey',
        sellerCity: 'İstanbul',
        car: testCar,
        title: 'Renault Clio 2020',
        askingPrice: 600000.0,
        sellerTrait: 'tok_satici',
        description: 'Temiz aile aracı',
        createdAt: DateTime.now(),
      );

      // Perform repeated evaluations with 88% ratio until rejection occurs
      VasitaNegotiationOutcome? rejectedOutcome;
      for (int i = 0; i < 20; i++) {
        final outcome = VasitaNegotiationEngine.evaluateOffer(
          listing: listing,
          offeredPrice: 520000.0,
          currentPatience: 50,
          playerLevel: 1,
        );
        if (!outcome.isAccepted && !outcome.isWalkaway) {
          rejectedOutcome = outcome;
          break;
        }
      }

      expect(rejectedOutcome, isNotNull);
      expect(rejectedOutcome!.nearMissAmount, isNotNull);
      expect(rejectedOutcome.nearMissAmount!, greaterThan(0));
    });

    test('Cultural and vehicle-specific cult tactics generate appropriately', () {
      final tofasCar = CarModel(
        id: 'tofas_1',
        brand: 'Tofaş',
        modelName: 'Şahin',
        modelYear: 1996,
        bodyType: 'Sedan',
        colorHex: '#FFFFFF',
        baseMarketValue: 120000.0,
        currentPurchasePrice: 120000.0,
        expertise: ExpertiseReport(
          engineCondition: 70.0,
          transmissionCondition: 70.0,
          tramerAmount: 5000,
          mileage: 180000,
          isMileageTampered: false,
          bodyParts: {},
        ),
      );

      final tofasListing = ListingModel(
        id: 'l_tofas',
        sellerName: 'Murat Usta',
        sellerCity: 'Bursa',
        car: tofasCar,
        title: 'Tofaş Şahin 1996',
        askingPrice: 120000.0,
        sellerTrait: 'aceleci',
        description: 'Tüplü ve öfkeli',
        createdAt: DateTime.now(),
      );

      final tactics = VasitaNegotiationEngine.getTacticsForVehicle(tofasListing.car.vehicleCategory);
      final tofasTactic = tactics.where((t) => t.id == 'tofas_lpg');
      expect(tofasTactic.isNotEmpty, isTrue);

      // BMW German service tactic
      final bmwCar = CarModel(
        id: 'bmw_1',
        brand: 'BMW',
        modelName: '320i',
        modelYear: 2018,
        bodyType: 'Sedan',
        colorHex: '#000000',
        baseMarketValue: 1500000.0,
        currentPurchasePrice: 1500000.0,
        expertise: ExpertiseReport(
          engineCondition: 80.0,
          transmissionCondition: 80.0,
          tramerAmount: 15000,
          mileage: 90000,
          isMileageTampered: false,
          bodyParts: {},
        ),
      );

      final bmwListing = ListingModel(
        id: 'l_bmw',
        sellerName: 'Can',
        sellerCity: 'İzmir',
        car: bmwCar,
        title: 'BMW 320i 2018',
        askingPrice: 1500000.0,
        sellerTrait: 'tok_satici',
        description: 'Borusan çıkışlı',
        createdAt: DateTime.now(),
      );

      final bmwTactics = VasitaNegotiationEngine.getTacticsForVehicle(bmwListing.car.vehicleCategory);
      final germanTactic = bmwTactics.where((t) => t.id == 'alman_servis');
      expect(germanTactic.isNotEmpty, isTrue);
    });

    test('vasitaLockedListingsProvider tracks walked away sellers', () {
      final container = ProviderContainer();
      addTearDown(() {
        container.dispose();
      });

      expect(container.read(vasitaLockedListingsProvider).isEmpty, isTrue);

      container.read(vasitaLockedListingsProvider.notifier).update((state) => {...state, 'listing_locked_1'});

      expect(container.read(vasitaLockedListingsProvider).contains('listing_locked_1'), isTrue);
    });

    test('hasCertifiedExpertise stays true when purchased and recorded in inventory', () {
      final container = ProviderContainer();
      addTearDown(() {
        container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
        container.dispose();
      });

      final testCar = CarModel(
        id: 'car_certified_1',
        brand: 'Honda',
        modelName: 'Civic',
        modelYear: 2021,
        bodyType: 'Sedan',
        colorHex: '#FFFFFF',
        baseMarketValue: 800000.0,
        currentPurchasePrice: 800000.0,
        expertise: ExpertiseReport(
          engineCondition: 90.0,
          transmissionCondition: 90.0,
          tramerAmount: 0,
          mileage: 45000,
          isMileageTampered: false,
          bodyParts: {},
        ),
      );

      final listing = ListingModel(
        id: 'list_certified_1',
        sellerName: 'Mehmet',
        sellerCity: 'Ankara',
        car: testCar,
        title: 'Honda Civic 2021',
        askingPrice: 800000.0,
        sellerTrait: 'tok_satici',
        description: 'Yetkili servis bakımlı',
        createdAt: DateTime.now(),
        isExpertiseCompleted: true,
      );

      container.read(gameProvider.notifier).state =
          container.read(gameProvider).copyWith(balance: 1000000.0);

      container.read(gameProvider.notifier).buyCar(listing.car, listing.askingPrice, isExpertiseCompleted: true);

      final inventory = container.read(gameProvider).ownedCars;
      final boughtCar = inventory.firstWhere((c) => c.id == testCar.id);

      expect(boughtCar.hasCertifiedExpertise, isTrue);
      expect(boughtCar.provenanceLog.any((l) => l.contains('Kurumsal ekspertiz')), isTrue);
    });

    test('vasitaLockedListingsProvider clears on gameProvider currentDay change', () {
      final container = ProviderContainer();
      addTearDown(() {
        container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
        container.dispose();
      });

      container.read(vasitaMarketProvider);
      container.read(vasitaLockedListingsProvider.notifier).state = {'listing_1', 'listing_2'};
      expect(container.read(vasitaLockedListingsProvider).length, 2);

      // Advance day
      container.read(gameProvider.notifier).advanceGameDay();

      expect(container.read(vasitaLockedListingsProvider).isEmpty, isTrue);
    });

    test('Invariant check: zero unicode emojis and zero parentheses in new expertise keys', () {
      final keysToCheck = [
        'vasita_expertise_title',
        'vasita_expertise_zeigarnik_badge',
        'vasita_expertise_complete_desc',
        'vasita_expertise_incomplete_desc',
        'vasita_expertise_seal_text',
        'vasita_expertise_btn_negotiate',
        'vasita_expertise_btn_full_check',
        'vasita_think_step_1',
        'vasita_think_step_2',
        'vasita_think_step_3',
        'vasita_near_miss_message',
        'vasita_sunk_cost_warning',
        'vasita_walkaway_lockout_title',
        'vasita_walkaway_lockout_desc',
        'vasita_badge_locked_today',
        'vasita_tactic_tofas_lpg_title',
        'vasita_tactic_german_service_title',
        'vasita_tactic_commercial_kantar_title',
        'vasita_tactic_classic_garage_title',
        'vasita_certified_badge',
        'vasita_btn_seller_walked',
        'vasita_btn_insufficient_funds',
        'auction_reclaim_insufficient_funds',
        'real_estate_renovation_in_progress',
        'real_estate_presale_last_unit_blocked',
      ];

      final allMaps = [
        trTranslations,
        enTranslations,
        deTranslations,
        ptTranslations,
        esTranslations,
        ruTranslations,
        arTranslations,
      ];

      final emojiRegex = RegExp(
        r'[\u{1F300}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}\u{1F000}-\u{1F02F}\u{1F0A0}-\u{1F0FF}]',
        unicode: true,
      );

      for (final map in allMaps) {
        for (final k in keysToCheck) {
          final val = map[k];
          expect(val, isNotNull, reason: 'Key $k must exist');
          expect(val!.contains('(') || val.contains(')'), isFalse,
              reason: 'Key $k has parentheses: "$val"');
          expect(emojiRegex.hasMatch(val), isFalse,
              reason: 'Key $k has emoji: "$val"');
        }
      }
    });
  });
}
