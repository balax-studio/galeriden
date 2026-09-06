import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/localization/translations/ar_translations.dart';
import 'package:galeriden/core/localization/translations/de_translations.dart';
import 'package:galeriden/core/localization/translations/en_translations.dart';
import 'package:galeriden/core/localization/translations/es_translations.dart';
import 'package:galeriden/core/localization/translations/pt_translations.dart';
import 'package:galeriden/core/localization/translations/ru_translations.dart';
import 'package:galeriden/core/localization/translations/tr_translations.dart';
import 'package:galeriden/core/constants/first_time_action_keys.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/data/models/vehicle_category.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/domain/usecases/vasita_market_engine.dart';
import 'package:galeriden/domain/usecases/vasita_negotiation_engine.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('VehicleCategory Enum & Invariants', () {
    test('catalog counts match authentic screenshot reference numbers', () {
      expect(VehicleCategory.motorcycle.catalogCount, 125979);
      expect(VehicleCategory.minivan.catalogCount, 75097);
      expect(VehicleCategory.commercial.catalogCount, 48944);
      expect(VehicleCategory.rentalFleet.catalogCount, 10539);
      expect(VehicleCategory.marine.catalogCount, 10929);
      expect(VehicleCategory.damaged.catalogCount, 4391);
      expect(VehicleCategory.caravan.catalogCount, 5814);
      expect(VehicleCategory.classic.catalogCount, 1848);
      expect(VehicleCategory.aircraft.catalogCount, 13);
      expect(VehicleCategory.atv.catalogCount, 3217);
      expect(VehicleCategory.utv.catalogCount, 443);
    });

    test('rarity tier assignments are consistent and authentic', () {
      expect(VehicleCategory.aircraft.rarityKey, 'vasita_rarity_mythic');
      expect(VehicleCategory.classic.rarityKey, 'vasita_rarity_epic');
      expect(VehicleCategory.utv.rarityKey, 'vasita_rarity_epic');
      expect(VehicleCategory.damaged.rarityKey, 'vasita_rarity_rare');
      expect(VehicleCategory.atv.rarityKey, 'vasita_rarity_rare');
      expect(VehicleCategory.marine.rarityKey, 'vasita_rarity_uncommon');
      expect(VehicleCategory.caravan.rarityKey, 'vasita_rarity_uncommon');
      expect(VehicleCategory.rentalFleet.rarityKey, 'vasita_rarity_uncommon');
      expect(VehicleCategory.motorcycle.rarityKey, 'vasita_rarity_common');
      expect(VehicleCategory.minivan.rarityKey, 'vasita_rarity_common');
      expect(VehicleCategory.commercial.rarityKey, 'vasita_rarity_common');
    });

    test('contextual keys for wash and repairs are defined for all categories', () {
      for (final cat in VehicleCategory.values) {
        expect(cat.localizationKey.isNotEmpty, true);
        expect(cat.washTitleKey.isNotEmpty, true);
        expect(cat.washDetailKey.isNotEmpty, true);
        expect(cat.engineRepairKey.isNotEmpty, true);
        expect(cat.transmissionRepairKey.isNotEmpty, true);
        expect(cat.bodyworkRepairKey.isNotEmpty, true);
      }
    });

    test('VehicleCategory fromString handles case variations and fallbacks', () {
      expect(VehicleCategory.fromString('motorcycle'), VehicleCategory.motorcycle);
      expect(VehicleCategory.fromString('MOTORCYCLE'), VehicleCategory.motorcycle);
      expect(VehicleCategory.fromString('aircraft'), VehicleCategory.aircraft);
      expect(VehicleCategory.fromString('marine'), VehicleCategory.marine);
      expect(VehicleCategory.fromString('unknown_category'), VehicleCategory.car);
      expect(VehicleCategory.fromString(null), VehicleCategory.car);
    });
  });

  group('CarModel VehicleCategory Serialization', () {
    test('toJson and fromJson preserve vehicleCategory', () {
      final marineListings =
          VasitaMarketEngine.generateListings(count: 1, categoryFilter: VehicleCategory.marine);
      final marineCar = marineListings.first.car;

      final json = marineCar.toJson();
      expect(json['vehicleCategory'], 'marine');

      final reconstructed = CarModel.fromJson(json);
      expect(reconstructed.vehicleCategory, VehicleCategory.marine);
      expect(reconstructed.brand, marineCar.brand);
      expect(reconstructed.modelName, marineCar.modelName);
    });

    test('copyWith updates or maintains vehicleCategory', () {
      final atvListings =
          VasitaMarketEngine.generateListings(count: 1, categoryFilter: VehicleCategory.atv);
      final atv = atvListings.first.car;

      final updated = atv.copyWith(currentPurchasePrice: 150000);
      expect(updated.vehicleCategory, VehicleCategory.atv);
      expect(updated.currentPurchasePrice, 150000);

      final converted = atv.copyWith(vehicleCategory: VehicleCategory.utv);
      expect(converted.vehicleCategory, VehicleCategory.utv);
    });
  });

  group('VasitaMarketEngine Listing Generation', () {
    test('generates expected count of random listings', () {
      final listings = VasitaMarketEngine.generateListings(count: 8);
      expect(listings.length, 8);
      for (final item in listings) {
        expect(item.car.brand.isNotEmpty, true);
        expect(item.car.modelName.isNotEmpty, true);
        expect(item.car.baseMarketValue > 0, true);
        expect(item.askingPrice > 0, true);
        expect(item.sellerName.isNotEmpty, true);
        expect(item.sellerCity.isNotEmpty, true);
      }
    });

    test('filters exclusively by category when provided', () {
      final motorcycleListings =
          VasitaMarketEngine.generateListings(count: 6, categoryFilter: VehicleCategory.motorcycle);
      for (final item in motorcycleListings) {
        expect(item.car.vehicleCategory, VehicleCategory.motorcycle);
      }

      final aircraftListings =
          VasitaMarketEngine.generateListings(count: 4, categoryFilter: VehicleCategory.aircraft);
      for (final item in aircraftListings) {
        expect(item.car.vehicleCategory, VehicleCategory.aircraft);
      }
    });

    test('damaged vehicles have compromised conditions and tramer amount', () {
      final damagedListings =
          VasitaMarketEngine.generateListings(count: 5, categoryFilter: VehicleCategory.damaged);
      for (final item in damagedListings) {
        expect(item.car.vehicleCategory, VehicleCategory.damaged);
        expect(item.car.expertise.tramerAmount > 0, true);
        expect(item.car.expertise.engineCondition < 85, true);
      }
    });
  });

  group('Dealership Level Gating for Vasita Pazari', () {
    test('/vasita is locked at level 1 and level 2, unlocked at level 3+', () {
      final lvl1Dealership = DealershipModel.initial().copyWith(level: 1);
      expect(lvl1Dealership.isFeatureUnlocked('/vasita'), false);
      expect(lvl1Dealership.isFeatureUnlocked('/vasita-market'), false);
      expect(DealershipModel.getRequiredLevel('/vasita'), 3);
      expect(DealershipModel.getRequiredLevel('/vasita-market'), 3);

      final lvl2Dealership = lvl1Dealership.copyWith(level: 2);
      expect(lvl2Dealership.isFeatureUnlocked('/vasita'), false);
      expect(lvl2Dealership.isFeatureUnlocked('/vasita-market'), false);

      final lvl3Dealership = lvl1Dealership.copyWith(level: 3);
      expect(lvl3Dealership.isFeatureUnlocked('/vasita'), true);
      expect(lvl3Dealership.isFeatureUnlocked('/vasita-market'), true);

      final lvl5Dealership = lvl1Dealership.copyWith(level: 5);
      expect(lvl5Dealership.isFeatureUnlocked('/vasita'), true);
      expect(lvl5Dealership.isFeatureUnlocked('/vasita-market'), true);
    });
  });

  group('Vasita Purchase and Garage Integration', () {
    late GameNotifier gameNotifier;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      gameNotifier = GameNotifier();
      await Future.delayed(const Duration(milliseconds: 50));
      gameNotifier.state = gameNotifier.state.copyWith(balance: 5000000);
    });

    tearDown(() {
      gameNotifier.stopPeriodicOrganicOfferTimer();
    });

    test('purchased vasita enters ownedCars and reduces balance', () {
      gameNotifier.state = gameNotifier.state.copyWith(balance: 100000000, maxGarageSlots: 10);
      final caravanListings =
          VasitaMarketEngine.generateListings(count: 1, categoryFilter: VehicleCategory.caravan);
      final caravanListing = caravanListings.first;

      final initialBalance = gameNotifier.state.balance;
      final outcome = gameNotifier.buyCar(caravanListing.car, caravanListing.askingPrice);

      expect(outcome != null, true);
      expect(gameNotifier.state.ownedCars.any((c) => c.id == caravanListing.car.id), true);
      final ownedCaravan =
          gameNotifier.state.ownedCars.firstWhere((c) => c.id == caravanListing.car.id);
      expect(ownedCaravan.vehicleCategory, VehicleCategory.caravan);
      expect(gameNotifier.state.balance < initialBalance, true);
    });
  });

  group('Localization and Invariant Compliance', () {
    final translationMaps = [
      trTranslations,
      enTranslations,
      deTranslations,
      ptTranslations,
      esTranslations,
      ruTranslations,
      arTranslations,
    ];

    final testKeys = [
      'service_vasita_market',
      'service_vasita_market_sub',
      'vasita_market_title',
      'vasita_market_desc',
      'vasita_filter_all',
      'vasita_listing_count',
      'vasita_buy_success',
      'vasita_inspect_title',
      'vasita_buy_button',
      'vasita_inspected_badge',
      'vehicle_cat_car',
      'vehicle_cat_motorcycle',
      'vehicle_cat_minivan',
      'vehicle_cat_commercial',
      'vehicle_cat_rental',
      'vehicle_cat_marine',
      'vehicle_cat_damaged',
      'vehicle_cat_caravan',
      'vehicle_cat_classic',
      'vehicle_cat_aircraft',
      'vehicle_cat_atv',
      'vehicle_cat_utv',
      'vasita_rarity_common',
      'vasita_rarity_uncommon',
      'vasita_rarity_rare',
      'vasita_rarity_epic',
      'vasita_rarity_mythic',
      'wash_title_marine',
      'wash_detail_marine',
      'repair_engine_marine',
      'repair_transmission_marine',
      'repair_body_marine',
      'wash_title_aircraft',
      'wash_detail_aircraft',
      'repair_engine_aircraft',
      'repair_transmission_aircraft',
      'repair_body_aircraft',
      'wash_title_bike_atv',
      'wash_detail_bike_atv',
      'repair_engine_bike_atv',
      'repair_transmission_bike_atv',
      'repair_body_bike_atv',
      'wash_title_caravan',
      'wash_detail_caravan',
      'repair_engine_caravan',
      'repair_transmission_caravan',
      'repair_body_caravan',
      'wash_title_commercial',
      'wash_detail_commercial',
      'repair_engine_commercial',
      'repair_transmission_commercial',
      'repair_body_commercial',
      'dyno_dialog_title_marine',
      'dyno_dialog_title_aircraft',
      'dyno_dialog_title_motorcycle',
      'dyno_dialog_title_commercial',
      'dyno_dialog_title_caravan',
      'dyno_dialog_title_terrain',
      'vasita_btn_marine_action',
      'vasita_btn_aircraft_action',
      'vasita_btn_caravan_action',
      'vasita_btn_motorcycle_action',
      'vasita_btn_commercial_action',
      'vasita_btn_terrain_action',
      'vasita_btn_classic_action',
      'vasita_btn_damaged_action',
      'vasita_btn_fleet_action',
      'vasita_btn_minivan_action',
      'vasita_upgrade_completed_badge',
      'vasita_upgrade_success_toast',
      'vasita_upgrade_err_not_found',
      'vasita_upgrade_err_already_done',
      'vasita_upgrade_err_insufficient_funds',
      'vasita_negotiation_title',
      'vasita_negotiation_subtitle',
      'vasita_tactics_header',
      'vasita_btn_start_negotiation',
      'vasita_btn_submit_offer',
      'vasita_btn_complete_noter',
      'vasita_btn_rescue_tea',
      'vasita_btn_leave_table',
      'vasita_label_your_offer',
      'vasita_label_bonus_chance',
      'vasita_label_success_chance',
      'vasita_garage_slots_badge',
      'vasita_btn_garage_full',
      'vasita_tactic_success_toast',
      'vasita_tactic_failed_toast',
      'noter_dialog_title',
      'noter_dialog_subtitle',
      'noter_certificate_header',
      'noter_field_plate',
      'noter_field_vin',
      'noter_field_vehicle',
      'noter_field_mileage',
      'noter_field_seller',
      'noter_field_buyer',
      'noter_field_agreed_price',
      'noter_stamp_text',
      'noter_costs_breakdown_title',
      'noter_fee_devir_rate',
      'noter_fee_registration',
      'noter_fee_total_cost',
      'noter_btn_complete_transfer',
      'noter_label_player_balance',
      'noter_insufficient_balance_warning',
      'noter_buy_success_toast',
      'noter_buy_error_funds',
      'vasita_btn_asking_price',
      'vasita_negotiation_walkaway_title',
      'vasita_negotiation_walkaway_desc',
      'vasita_expertise_card_title',
      'vasita_expertise_engine',
      'vasita_expertise_transmission',
      'vasita_expertise_tramer',
      'vasita_expertise_mileage_tampered',
      'vasita_expertise_mileage_verified',
      'vasita_expertise_parts_title',
      'vasita_expertise_paint_original',
      'vasita_expertise_paint_local',
      'vasita_expertise_paint_replaced',
      'vasita_expertise_expand',
      'vasita_expertise_collapse',
      'vasita_label_patience',
      'vasita_tactic_used',
    ];

    test('all 7 languages have all vasita keys populated without empty values', () {
      for (final map in translationMaps) {
        for (final key in testKeys) {
          expect(map.containsKey(key), true, reason: 'Missing key $key in translation');
          expect(map[key]!.isNotEmpty, true, reason: 'Empty string for key $key in translation');
        }
      }
    });

    test('zero parentheses invariant in all vasita strings across all 7 languages', () {
      for (final map in translationMaps) {
        for (final key in testKeys) {
          final text = map[key]!;
          expect(
            text.contains('(') || text.contains(')'),
            false,
            reason: 'Parentheses found in key: $key -> "$text"',
          );
        }
      }
    });
  });

  group('Parody Brand & Copyright Compliance', () {
    test('no raw trademarked brand names exist in templates', () {
      final bannedRealBrands = [
        'Yamaha', 'Honda', 'BMW', 'Ducati', 'Kawasaki',
        'Mercedes-Benz', 'Mercedes', 'Ford', 'Renault',
        'Cessna', 'Can-Am', 'Polaris', 'Hymer', 'Adria', 'Knaus', 'Jeanneau', 'Sea-Doo',
      ];

      for (final t in VasitaMarketEngine.templates) {
        expect(
          bannedRealBrands.contains(t.brand),
          false,
          reason: 'Raw trademark brand found in template: ${t.brand} ${t.modelName}',
        );
      }
    });

    test('all templates use authentic parody brand naming', () {
      final validParodyBrands = [
        'Yamaho', 'Hondam', 'Bemeve', 'Dukati', 'Kavazaki',
        'Fort', 'Vosgen', 'Merso', 'Fiyasko', 'Skaniya',
        'İsuzi', 'İveko', 'Çelikvolvo', 'Reno', 'Toyo',
        'Su-Doo', 'Janu Marine', 'Riva Lüks', 'Aksopar',
        'Adriana', 'Haymer', 'Kınavs', 'Şevrole', 'Cesna',
        'Sirus', 'Bel Helikopter', 'Kanam', 'Polaris Dağkurdu',
      ];

      for (final t in VasitaMarketEngine.templates) {
        expect(
          validParodyBrands.contains(t.brand),
          true,
          reason: 'Unregistered parody brand in template: ${t.brand}',
        );
      }
    });

    test('authentic Turkish sahibinden seller traits are assigned properly', () {
      final listings = VasitaMarketEngine.generateListings(count: 25);
      for (final l in listings) {
        expect(l.sellerTrait.isNotEmpty, true);
        expect(l.description.isNotEmpty, true);
        expect(l.title.contains('•'), true);
      }
    });
  });

  group('Showroom Vasita Upgrade Actions', () {
    test('upgradeVasitaVehicle modifies isVasitaUpgraded and increases value', () {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();

      // Stop organic offer timer for test hygiene
      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();

      final listings = VasitaMarketEngine.generateListings(
        count: 1,
        categoryFilter: VehicleCategory.marine,
      );
      final marineCar = listings.first.car;

      // Add car to dealership
      container.read(gameProvider.notifier).state = container.read(gameProvider.notifier).state.copyWith(
        ownedCars: [marineCar],
        balance: 500000.0,
      );

      final initialVal = marineCar.estimatedRealValue;

      final res = container.read(gameProvider.notifier).upgradeVasitaVehicle(marineCar.id);
      expect(res['success'], true);

      final updatedCar = container.read(gameProvider.notifier).state.ownedCars.first;
      expect(updatedCar.isVasitaUpgraded, true);
      expect(updatedCar.estimatedRealValue > initialVal, true);
      expect(updatedCar.provenanceLog.isNotEmpty, true);

      // Cannot be upgraded twice
      final secondRes = container.read(gameProvider.notifier).upgradeVasitaVehicle(marineCar.id);
      expect(secondRes['success'], false);
    });
  });

  group('Vasita Negotiation Engine & Notary Transfer Protocol', () {
    test('calculateNoterFee strictly computes dynamic 2 per mille (0.2%) rounded', () {
      expect(VasitaNegotiationEngine.calculateNoterFee(100000), 200.0);
      expect(VasitaNegotiationEngine.calculateNoterFee(250000), 500.0);
      expect(VasitaNegotiationEngine.calculateNoterFee(1000000), 2000.0);
      expect(VasitaNegotiationEngine.calculateNoterFee(1234567), 2469.0);
      expect(VasitaNegotiationEngine.calculateNoterFee(0), 0.0);
    });

    test('calculateTotalAcquisitionCost combines agreedPrice, noterFee, and fixed registrationFee', () {
      const price = 500000.0;
      final noterFee = VasitaNegotiationEngine.calculateNoterFee(price);
      const regFee = VasitaNegotiationEngine.registrationFee;
      final total = VasitaNegotiationEngine.calculateTotalAcquisitionCost(price);

      expect(noterFee, 1000.0);
      expect(regFee, 850.0);
      expect(total, 501850.0);
    });

    test('getTacticsForVehicle includes universal tactics and category-specific tactics', () {
      // Motorcycle
      final motoTactics = VasitaNegotiationEngine.getTacticsForVehicle(VehicleCategory.motorcycle);
      final motoIds = motoTactics.map((t) => t.id).toList();
      expect(motoIds.contains('pesin_noter'), true);
      expect(motoIds.contains('sanayi_cayi'), true);
      expect(motoIds.contains('moto_sasi'), true);

      // Caravan
      final caravanTactics = VasitaNegotiationEngine.getTacticsForVehicle(VehicleCategory.caravan);
      final caravanIds = caravanTactics.map((t) => t.id).toList();
      expect(caravanIds.contains('karavan_izolasyon'), true);

      // Marine
      final marineTactics = VasitaNegotiationEngine.getTacticsForVehicle(VehicleCategory.marine);
      final marineIds = marineTactics.map((t) => t.id).toList();
      expect(marineIds.contains('deniz_ozmoz'), true);

      // Classic
      final classicTactics = VasitaNegotiationEngine.getTacticsForVehicle(VehicleCategory.classic);
      final classicIds = classicTactics.map((t) => t.id).toList();
      expect(classicIds.contains('klasik_seri'), true);

      // Damaged
      final damagedTactics = VasitaNegotiationEngine.getTacticsForVehicle(VehicleCategory.damaged);
      final damagedIds = damagedTactics.map((t) => t.id).toList();
      expect(damagedIds.contains('hasarli_kurtarici'), true);

      // ATV / UTV
      final atvTactics = VasitaNegotiationEngine.getTacticsForVehicle(VehicleCategory.atv);
      final atvIds = atvTactics.map((t) => t.id).toList();
      expect(atvIds.contains('arazi_diferansiyel'), true);

      // Commercial
      final commTactics = VasitaNegotiationEngine.getTacticsForVehicle(VehicleCategory.commercial);
      final commIds = commTactics.map((t) => t.id).toList();
      expect(commIds.contains('tramer_baski'), true);
      expect(commIds.contains('usta_lift'), true);
    });

    test('calculateOfferSuccessProbability respects asking price ratio, patience, and level', () {
      final listing = VasitaMarketEngine.generateListings(count: 1).first;
      final asking = listing.askingPrice;

      // Generous offer (100% of asking) with high patience
      final highProb = VasitaNegotiationEngine.calculateOfferSuccessProbability(
        listing: listing,
        offeredPrice: asking,
        patience: 90,
        playerLevel: 10,
        extraBonusPercent: 0.10,
      );
      expect(highProb >= 85, true);

      // Extreme lowball offer (50% of asking) with zero patience
      final lowProb = VasitaNegotiationEngine.calculateOfferSuccessProbability(
        listing: listing,
        offeredPrice: asking * 0.50,
        patience: 10,
        playerLevel: 1,
        extraBonusPercent: 0.0,
      );
      expect(lowProb <= 20, true);
    });

    test('rollTactic outputs consistent outcome, message, and patience change', () {
      final listing = VasitaMarketEngine.generateListings(count: 1).first;
      final teaTactic = VasitaNegotiationEngine.allTactics.firstWhere((t) => t.id == 'sanayi_cayi');

      final outcome = VasitaNegotiationEngine.rollTactic(
        tactic: teaTactic,
        listing: listing,
        currentPatience: 50,
        playerLevel: 5,
      );

      expect(outcome.message.isNotEmpty, true);
      expect(outcome.patienceChange != 0, true);
      expect(outcome.isWalkaway, false);
    });

    test('buyCarWithNoter updates balance, adds car to garage with notary log, and respects constraints', () {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.stopPeriodicOrganicOfferTimer();

      final listing = VasitaMarketEngine.generateListings(
        count: 1,
        categoryFilter: VehicleCategory.motorcycle,
      ).first;
      final car = listing.car;

      const agreedPrice = 200000.0;
      final noterFee = VasitaNegotiationEngine.calculateNoterFee(agreedPrice);
      const regFee = VasitaNegotiationEngine.registrationFee;
      const totalCost = agreedPrice + 400.0 + 850.0;

      // 1. Rejects when insufficient funds
      notifier.state = notifier.state.copyWith(
        balance: 100000.0,
        ownedCars: [],
        maxGarageSlots: 5,
      );
      final failFunds = notifier.buyCarWithNoter(
        car: car,
        agreedPrice: agreedPrice,
        noterFee: noterFee,
        registrationFee: regFee,
      );
      expect(failFunds, isNull);
      expect(notifier.state.ownedCars.isEmpty, true);

      // 2. Rejects when garage is full
      notifier.state = notifier.state.copyWith(
        balance: 1000000.0,
        ownedCars: List.generate(5, (_) => car),
        maxGarageSlots: 5,
      );
      final failGarage = notifier.buyCarWithNoter(
        car: car,
        agreedPrice: agreedPrice,
        noterFee: noterFee,
        registrationFee: regFee,
      );
      expect(failGarage, isNull);
      expect(notifier.state.ownedCars.length, 5);

      // 3. Successfully completes purchase
      notifier.state = notifier.state.copyWith(
        balance: 500000.0,
        ownedCars: [],
        maxGarageSlots: 5,
        completedFirstTimeActions: {FirstTimeActionKeys.firstCarBuy},
      );
      final successOutcome = notifier.buyCarWithNoter(
        car: car,
        agreedPrice: agreedPrice,
        noterFee: noterFee,
        registrationFee: regFee,
        isExpertiseCompleted: true,
      );
      expect(successOutcome, isNotNull);
      expect(notifier.state.balance, 500000.0 - totalCost);
      expect(notifier.state.ownedCars.length, 1);
      final boughtCar = notifier.state.ownedCars.first;
      expect(boughtCar.currentPurchasePrice, agreedPrice);
      expect(boughtCar.provenanceLog.any((l) => l.contains('Noter tesciliyle')), true);
    });
  });

  group('Vasita Dynamic Expertise & Safety Analysis Tests', () {
    test('VasitaMarketEngine generates authentic body parts per vehicle category', () {
      final listings = VasitaMarketEngine.generateListings(count: 30);
      for (final listing in listings) {
        final exp = listing.car.expertise;
        expect(exp.bodyParts.isNotEmpty, isTrue);

        if (listing.car.vehicleCategory == VehicleCategory.motorcycle) {
          expect(exp.bodyParts.containsKey('Ön Maşa & Gidon'), isTrue);
          expect(exp.bodyParts.containsKey('Depo / Yakıt Tankı'), isTrue);
        } else if (listing.car.vehicleCategory == VehicleCategory.marine) {
          expect(exp.bodyParts.containsKey('Gövde / Karina'), isTrue);
        } else if (listing.car.vehicleCategory == VehicleCategory.aircraft) {
          expect(exp.bodyParts.containsKey('Gövde (Füzelaj)'), isTrue);
          expect(exp.isChassisAligned, isTrue);
          expect(exp.hasAirbagDeployed, isFalse);
          expect(exp.isMileageTampered, isFalse);
        }
      }
    });

    test('Chassis alignment is not fixed: clean vehicles have intact chassis', () {
      final listings = VasitaMarketEngine.generateListings(count: 40);
      final alignedCount = listings.where((l) => l.car.expertise.isChassisAligned).length;
      final damagedChassisCount = listings.where((l) => !l.car.expertise.isChassisAligned).length;

      expect(alignedCount, greaterThan(20));
      expect(damagedChassisCount, lessThan(alignedCount));
      final cleanCars = listings.where((l) => l.car.expertise.tramerAmount == 0).toList();
      for (final cleanCar in cleanCars) {
        expect(cleanCar.car.expertise.isChassisAligned, isTrue);
      }
    });

    test('Damaged category vehicles frequently have compromised chassis', () {
      final damagedListings = VasitaMarketEngine.generateListings(
        count: 20,
        categoryFilter: VehicleCategory.damaged,
      );
      final compromisedCount =
          damagedListings.where((l) => !l.car.expertise.isChassisAligned).length;
      expect(compromisedCount, greaterThan(0));
    });

    test('ExpertiseReport serialization preserves isChassisAligned and hasAirbagDeployed', () {
      final report = ExpertiseReport(
        engineCondition: 92.0,
        transmissionCondition: 89.0,
        tramerAmount: 65000,
        mileage: 65000,
        isMileageTampered: true,
        isChassisAligned: false,
        hasAirbagDeployed: true,
        bodyParts: {'Kaput': PartStatus.changed},
      );

      final json = report.toJson();
      expect(json['isChassisAligned'], isFalse);
      expect(json['hasAirbagDeployed'], isTrue);
      expect(json['isMileageTampered'], isTrue);

      final reconstructed = ExpertiseReport.fromJson(json);
      expect(reconstructed.isChassisAligned, isFalse);
      expect(reconstructed.hasAirbagDeployed, isTrue);
      expect(reconstructed.isMileageTampered, isTrue);
    });
  });
}
