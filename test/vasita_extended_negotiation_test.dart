import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/localization/translations/ar_translations.dart';
import 'package:galeriden/core/localization/translations/de_translations.dart';
import 'package:galeriden/core/localization/translations/en_translations.dart';
import 'package:galeriden/core/localization/translations/es_translations.dart';
import 'package:galeriden/core/localization/translations/pt_translations.dart';
import 'package:galeriden/core/localization/translations/ru_translations.dart';
import 'package:galeriden/core/localization/translations/tr_translations.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/listing_model.dart';
import 'package:galeriden/data/models/vehicle_category.dart';
import 'package:galeriden/domain/usecases/vasita_negotiation_engine.dart';

void main() {
  CarModel createSampleCar({
    required String brand,
    required String modelName,
    required String bodyType,
    required VehicleCategory category,
    int modelYear = 2022,
    bool isRare = false,
  }) {
    return CarModel(
      id: 'test-car-1',
      brand: brand,
      modelName: modelName,
      modelYear: modelYear,
      bodyType: bodyType,
      colorHex: '#000000',
      baseMarketValue: 1500000.0,
      currentPurchasePrice: 1500000.0,
      maintenanceCost: 5000.0,
      isDetailedCleaned: false,
      isWashed: false,
      isPolished: false,
      isRare: isRare,
      declarationType: ListingDeclarationType.honest,
      appliedDetailingOptionIds: const [],
      isRented: false,
      isDoped: false,
      isChassisRepaired: false,
      isLockedInShowcase: false,
      daysListed: 0,
      isHeroShowcase: false,
      isBarnFind: false,
      isBarnFindRestored: false,
      provenanceLog: const [],
      allowsInstallments: false,
      listingPhotoLocation: 'urban',
      listingPhotoCount: 3,
      listingTone: 'formal',
      hideDamagedPhotos: false,
      hasNonOriginalParts: false,
      plateNumber: '34 GLR 101',
      plateRarity: 'standard',
      colorRarity: 'standard',
      colorDisplayName: 'Siyah',
      barnFindStage: 0,
      isBarnFindOriginalParts: false,
      hasGloveboxSearched: false,
      carSpirit: 'normal',
      isConsignment: false,
      consignmentCommissionRate: 0.1,
      consignmentDaysRemaining: 14,
      isBlackMarket: false,
      blackMarketRiskPercent: 0,
      expertise: ExpertiseReport(
        engineCondition: 85.0,
        transmissionCondition: 80.0,
        mileage: 45000,
        tramerAmount: 0,
        isMileageTampered: false,
        bodyParts: const {},
      ),
      vehicleCategory: category,
    );
  }

  ListingModel createSampleListing(CarModel car, {double askingPrice = 1500000.0}) {
    return ListingModel(
      id: 'test-listing-1',
      car: car,
      sellerName: 'Kemal Güneş',
      sellerCity: 'Mersin',
      sellerTrait: 'Lojistik Filosu',
      title: 'Satılık Araç',
      description: 'Temiz kullanılmış',
      askingPrice: askingPrice,
      isExpertiseCompleted: true,
      createdAt: DateTime.now(),
    );
  }

  group('Vehicle-Specific Thinking Steps & Suspense Duration', () {
    test('Commercial vehicle returns commercial thinking steps', () {
      final car = createSampleCar(
        brand: 'Çelikvolvo',
        modelName: 'FH 540 Demir Yürek',
        bodyType: 'Ağır Ticari Çekici',
        category: VehicleCategory.commercial,
      );
      final listing = createSampleListing(car, askingPrice: 1800000.0);
      final steps = VasitaNegotiationEngine.getThinkingStepsForListing(listing);

      expect(steps.length, 4);
      expect(steps[0], 'vasita_think_comm_1');
      expect(steps[1], 'vasita_think_comm_2');
      expect(steps[2], 'vasita_think_comm_3');
      expect(steps[3], 'vasita_think_comm_4');

      final duration = VasitaNegotiationEngine.getThinkingStepDurationMs(listing);
      expect(duration, 1000);
    });

    test('High-stakes vehicle (>= ₺2.000.000) appends suspense high-stakes step and increases duration', () {
      final car = createSampleCar(
        brand: 'Çelikvolvo',
        modelName: 'FH 540 Demir Yürek',
        bodyType: 'Ağır Ticari Çekici',
        category: VehicleCategory.commercial,
      );
      final listing = createSampleListing(car, askingPrice: 4185000.0);
      final steps = VasitaNegotiationEngine.getThinkingStepsForListing(listing);

      expect(steps.length, 5);
      expect(steps.last, 'vasita_think_high_stakes');

      final duration = VasitaNegotiationEngine.getThinkingStepDurationMs(listing);
      expect(duration, 1050);
    });

    test('Sport / Performance vehicle returns performance thinking steps', () {
      final car = createSampleCar(
        brand: 'Porsche',
        modelName: '911 Carrera',
        bodyType: 'Coupe Spor',
        category: VehicleCategory.car,
        isRare: true,
      );
      final listing = createSampleListing(car, askingPrice: 1950000.0);
      final steps = VasitaNegotiationEngine.getThinkingStepsForListing(listing);

      expect(steps[0], 'vasita_think_perf_1');
      expect(steps[3], 'vasita_think_perf_4');
      expect(VasitaNegotiationEngine.getThinkingStepDurationMs(listing), 1000);
    });

    test('Classic vehicle returns classic nostaljik thinking steps', () {
      final car = createSampleCar(
        brand: 'Tofaş',
        modelName: 'Şahin S',
        bodyType: 'Sedan Klasik',
        category: VehicleCategory.classic,
        modelYear: 1996,
      );
      final listing = createSampleListing(car, askingPrice: 280000.0);
      final steps = VasitaNegotiationEngine.getThinkingStepsForListing(listing);

      expect(steps[0], 'vasita_think_classic_1');
      expect(steps[3], 'vasita_think_classic_4');
      expect(VasitaNegotiationEngine.getThinkingStepDurationMs(listing), 850);
    });

    test('SUV vehicle returns off-road thinking steps', () {
      final car = createSampleCar(
        brand: 'Jeep',
        modelName: 'Cherokee Trail',
        bodyType: 'SUV Arazi',
        category: VehicleCategory.car,
      );
      final listing = createSampleListing(car, askingPrice: 1200000.0);
      final steps = VasitaNegotiationEngine.getThinkingStepsForListing(listing);

      expect(steps[0], 'vasita_think_suv_1');
      expect(steps[3], 'vasita_think_suv_4');
      expect(VasitaNegotiationEngine.getThinkingStepDurationMs(listing), 850);
    });

    test('Standard passenger vehicle returns standard steps with standard 850ms duration', () {
      final car = createSampleCar(
        brand: 'Renault',
        modelName: 'Megane',
        bodyType: 'Sedan',
        category: VehicleCategory.car,
      );
      final listing = createSampleListing(car, askingPrice: 950000.0);
      final steps = VasitaNegotiationEngine.getThinkingStepsForListing(listing);

      expect(steps[0], 'vasita_think_std_1');
      expect(steps[3], 'vasita_think_std_4');
      expect(VasitaNegotiationEngine.getThinkingStepDurationMs(listing), 850);
    });
  });

  group('Dark Pattern & Suspense Localization & Invariants', () {
    final translationMaps = {
      'tr': trTranslations,
      'en': enTranslations,
      'de': deTranslations,
      'es': esTranslations,
      'pt': ptTranslations,
      'ru': ruTranslations,
      'ar': arTranslations,
    };

    const newKeys = [
      'vasita_think_comm_1',
      'vasita_think_comm_2',
      'vasita_think_comm_3',
      'vasita_think_comm_4',
      'vasita_think_perf_1',
      'vasita_think_perf_2',
      'vasita_think_perf_3',
      'vasita_think_perf_4',
      'vasita_think_classic_1',
      'vasita_think_classic_2',
      'vasita_think_classic_3',
      'vasita_think_classic_4',
      'vasita_think_suv_1',
      'vasita_think_suv_2',
      'vasita_think_suv_3',
      'vasita_think_suv_4',
      'vasita_think_std_1',
      'vasita_think_std_2',
      'vasita_think_std_3',
      'vasita_think_std_4',
      'vasita_think_high_stakes',
      'vasita_dark_live_viewers',
      'vasita_dark_urgency_comm',
      'vasita_dark_urgency_perf',
      'vasita_dark_urgency_classic',
      'vasita_dark_urgency_suv',
      'vasita_dark_urgency_std',
      'vasita_dark_timer_label',
      'vasita_dark_timer_expired',
      'vasita_dark_obstinacy_label',
      'vasita_dark_obstinacy_desc',
      'vasita_dark_remaining_attempts',
      'vasita_dark_sunk_cost_warning',
      'vasita_dark_discount_gain',
      'vasita_dark_noter_est',
      'vasita_dark_net_benefit',
    ];

    test('All 36 extended keys exist across all 7 supported languages without empty values', () {
      for (final entry in translationMaps.entries) {
        final lang = entry.key;
        final map = entry.value;

        for (final key in newKeys) {
          expect(map.containsKey(key), isTrue, reason: 'Language $lang missing key: $key');
          expect(map[key]!.trim().isNotEmpty, isTrue, reason: 'Language $lang has empty key: $key');
        }
      }
    });

    test('Zero Unicode Emojis invariant strictly respected in all new keys across 7 languages', () {
      final emojiRegex = RegExp(
        r'[\u{1F300}-\u{1F64F}\u{1F680}-\u{1F6FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}\u{1F900}-\u{1F9FF}\u{1F1E0}-\u{1F1FF}]',
        unicode: true,
      );

      for (final entry in translationMaps.entries) {
        final lang = entry.key;
        final map = entry.value;

        for (final key in newKeys) {
          final text = map[key]!;
          expect(emojiRegex.hasMatch(text), isFalse,
              reason: 'Key $key in language $lang contains forbidden Unicode Emoji: $text');
        }
      }
    });

    test('Zero Parentheses invariant strictly respected in all new keys across 7 languages', () {
      for (final entry in translationMaps.entries) {
        final lang = entry.key;
        final map = entry.value;

        for (final key in newKeys) {
          final text = map[key]!;
          expect(text.contains('(') || text.contains(')'), isFalse,
              reason: 'Key $key in language $lang contains forbidden parentheses: $text');
        }
      }
    });
  });
}
