import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galeriden/core/localization/translations/ar_translations.dart';
import 'package:galeriden/core/localization/translations/de_translations.dart';
import 'package:galeriden/core/localization/translations/en_translations.dart';
import 'package:galeriden/core/localization/translations/es_translations.dart';
import 'package:galeriden/core/localization/translations/pt_translations.dart';
import 'package:galeriden/core/localization/translations/ru_translations.dart';
import 'package:galeriden/core/localization/translations/tr_translations.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/data/models/real_estate_category.dart';
import 'package:galeriden/data/models/real_estate_model.dart';
import 'package:galeriden/data/models/staff_model.dart';
import 'package:galeriden/domain/usecases/zoning_engine.dart';
import 'package:galeriden/domain/usecases/construction_timeline_engine.dart';
import 'package:galeriden/domain/usecases/construction_negative_events_engine.dart';
import 'package:galeriden/domain/usecases/real_estate_chat_negotiation_engine.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Section F Dynamics & Realism Comprehensive Suite', () {
    test('F1·1 & F3·2: DealershipModel constructionCostIndex default, serialization and clamp', () {
      final defaultModel = DealershipModel.initial();
      expect(defaultModel.constructionCostIndex, equals(1.0));

      final json = defaultModel.toJson();
      expect(json['constructionCostIndex'], equals(1.0));

      final fromJsonModel = DealershipModel.fromJson(json);
      expect(fromJsonModel.constructionCostIndex, equals(1.0));

      final customModel = defaultModel.copyWith(constructionCostIndex: 1.25);
      expect(customModel.constructionCostIndex, equals(1.25));
    });

    test('F1·6: RealEstateModel stepped pre-sale discount schedule', () {
      final land = RealEstateModel(
        id: 'test_land',
        title: 'Maslak Ticari Arsa',
        category: RealEstateCategory.land,
        district: 'Maslak',
        city: 'İstanbul',
        squareMeters: 1000,
        roomCount: '-',
        buildingAge: 0,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
        baseMarketValue: 10000000.0,
        currentPurchasePrice: 10000000.0,
        totalProjectUnits: 10,
        playerSharePercent: 100,
        soldPreSaleUnits: 0,
      );

      // Stage <= 2: 0.65
      final landStage1 = land.copyWith(constructionStage: 1);
      final landStage2 = land.copyWith(constructionStage: 2);
      expect(landStage1.preSaleDiscountRate, closeTo(0.65, 0.001));
      expect(landStage2.preSaleDiscountRate, closeTo(0.65, 0.001));

      // Stage 3: 0.70
      final landStage3 = land.copyWith(constructionStage: 3);
      expect(landStage3.preSaleDiscountRate, closeTo(0.70, 0.001));

      // Stage 4: 0.75
      final landStage4 = land.copyWith(constructionStage: 4);
      expect(landStage4.preSaleDiscountRate, closeTo(0.75, 0.001));

      // Stage 5: 0.80
      final landStage5 = land.copyWith(constructionStage: 5);
      expect(landStage5.preSaleDiscountRate, closeTo(0.80, 0.001));

      // Stage 6: 0.85
      final landStage6 = land.copyWith(constructionStage: 6);
      expect(landStage6.preSaleDiscountRate, closeTo(0.85, 0.001));

      // Stage 7: 0.92
      final landStage7 = land.copyWith(constructionStage: 7);
      expect(landStage7.preSaleDiscountRate, closeTo(0.92, 0.001));

      // Stage 8: 1.0
      final landStage8 = land.copyWith(constructionStage: 8);
      expect(landStage8.preSaleDiscountRate, closeTo(1.0, 0.001));
    });

    test('F3·3: RealEstateModel qualityScore and mortgage effects', () {
      final apartmentBase = RealEstateModel(
        id: 'apt_test',
        title: 'Maslak 2+1 Lüks Daire',
        category: RealEstateCategory.housing,
        district: 'Maslak',
        city: 'İstanbul',
        squareMeters: 100,
        roomCount: '2+1',
        buildingAge: 0,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
        baseMarketValue: 5000000.0,
        currentPurchasePrice: 5000000.0,
        qualityScore: 75.0,
        isMortgaged: false,
      );

      // Quality 75.0 is base (delta = 0)
      expect(apartmentBase.estimatedRealValue, equals(5000000.0));

      // Quality 100.0 gives +15% premium
      final apartmentPrime = apartmentBase.copyWith(qualityScore: 100.0);
      expect(apartmentPrime.estimatedRealValue, closeTo(5750000.0, 1.0));

      // Quality 50.0 gives -15% discount
      final apartmentFlawed = apartmentBase.copyWith(qualityScore: 50.0);
      expect(apartmentFlawed.estimatedRealValue, closeTo(4250000.0, 1.0));

      // Mortgage flag blocks sale
      expect(apartmentBase.canBeSold, isTrue);
      final mortgagedApartment = apartmentBase.copyWith(isMortgaged: true);
      expect(mortgagedApartment.canBeSold, isFalse);
    });

    test('F1·2 & F1·3: ZoningEngine district-based KAKS & TAKS', () {
      // Maslak / Şişli: High density
      final maslakZoning = ZoningEngine.calculateZoning(
        parcelSquareMeters: 1000.0,
        baseMarketValue: 10000000.0,
        district: 'Maslak',
      );
      expect(maslakZoning.kaks, equals(2.40));
      expect(maslakZoning.taks, equals(0.38));
      expect(maslakZoning.maxFloors, equals(12));

      // Kadıköy / Beşiktaş: Moderate density
      final kadikoyZoning = ZoningEngine.calculateZoning(
        parcelSquareMeters: 1000.0,
        baseMarketValue: 10000000.0,
        district: 'Kadıköy',
      );
      expect(kadikoyZoning.kaks, equals(1.85));
      expect(kadikoyZoning.taks, equals(0.32));
      expect(kadikoyZoning.maxFloors, equals(7));

      // Sarıyer / Urla / Gölbaşı: Low density
      final sariyerZoning = ZoningEngine.calculateZoning(
        parcelSquareMeters: 1000.0,
        baseMarketValue: 10000000.0,
        district: 'Sarıyer',
      );
      expect(sariyerZoning.kaks, equals(1.35));
      expect(sariyerZoning.taks, equals(0.28));
      expect(sariyerZoning.maxFloors, equals(4));
    });

    test('F1·9: ConstructionPricing applies costIndex correctly', () {
      final land = RealEstateModel(
        id: 'test_pricing_land',
        title: 'Kadıköy Parsel',
        category: RealEstateCategory.land,
        district: 'Kadıköy',
        city: 'İstanbul',
        squareMeters: 800,
        roomCount: '-',
        buildingAge: 0,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
        baseMarketValue: 6000000.0,
        currentPurchasePrice: 6000000.0,
      );

      final standardCost = ConstructionPricing.stageCost(land, 2, costIndex: 1.0);
      final inflatedCost = ConstructionPricing.stageCost(land, 2, costIndex: 1.20);
      final discountedCost = ConstructionPricing.stageCost(land, 2, costIndex: 0.90);

      expect(inflatedCost, closeTo(standardCost * 1.20, 2.0));
      expect(discountedCost, closeTo(standardCost * 0.90, 2.0));
    });

    test('F1·12: RealEstateChatNegotiationEngine raises player share cap to 60% for high reputation', () {
      // Normal reputation (< 700) -> maxCap 55%
      final sessionNormal = RealEstateChatNegotiationEngine.createContractorSession(
        landId: 'land_kadikoy',
        totalUnits: 10,
        baseMarketValue: 6000000.0,
        playerReputationScore: 500,
      );
      expect(sessionNormal.maxSharePercent, equals(55));

      // High reputation (>= 700) -> maxCap 60%
      final sessionReputed = RealEstateChatNegotiationEngine.createContractorSession(
        landId: 'land_kadikoy',
        totalUnits: 10,
        baseMarketValue: 6000000.0,
        playerReputationScore: 750,
      );
      expect(sessionReputed.maxSharePercent, equals(60));
    });

    test('F2·5: ConstructionNegativeEventsEngine handles master mechanic and bad weather', () {
      int rollCount = 1000;
      int standardIncidents = 0;
      int mechanicIncidents = 0;
      int badWeatherIncidents = 0;

      for (int i = 0; i < rollCount; i++) {
        final std = ConstructionNegativeEventsEngine.rollStageIncident(
          stageNumber: 2,
          baseStageCost: 100000.0,
          hasMasterMechanic: false,
          isBadWeather: false,
        );
        if (std != null) standardIncidents++;

        final mech = ConstructionNegativeEventsEngine.rollStageIncident(
          stageNumber: 2,
          baseStageCost: 100000.0,
          hasMasterMechanic: true,
          isBadWeather: false,
        );
        if (mech != null) mechanicIncidents++;

        final weather = ConstructionNegativeEventsEngine.rollStageIncident(
          stageNumber: 2,
          baseStageCost: 100000.0,
          hasMasterMechanic: false,
          isBadWeather: true,
        );
        if (weather != null) badWeatherIncidents++;
      }

      // Master mechanic reduces incidents
      expect(mechanicIncidents, lessThan(standardIncidents));
      // Bad weather increases incidents
      expect(badWeatherIncidents, greaterThan(standardIncidents));
    });

    test('F2·5 & F3·1: Self-build construction with legal advisor gets 30% discount on permit stage', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.stopPeriodicOrganicOfferTimer();

      final land = RealEstateModel(
        id: 'land_legal_test',
        title: 'Kadıköy Arsa',
        category: RealEstateCategory.land,
        district: 'Kadıköy',
        city: 'İstanbul',
        squareMeters: 500,
        roomCount: '-',
        buildingAge: 0,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
        baseMarketValue: 5000000.0,
        currentPurchasePrice: 5000000.0,
      );

      notifier.state = notifier.state.copyWith(
        balance: 10000000.0,
        ownedRealEstates: [land],
        hiredStaff: [
          StaffModel(
            id: 'staff_lawyer',
            name: 'Av. Ceyda Hanım',
            role: StaffRole.legalAdvisor,
            hiredAt: DateTime.now(),
            morale: 90,
          ),
        ],
      );

      final balanceBefore = notifier.state.balance;
      final ok = notifier.startSelfBuildConstruction(land.id);
      expect(ok, isTrue);
      final spentStep1 = balanceBefore - notifier.state.balance;

      notifier.advanceGameDay();
      notifier.state = notifier.state.copyWith(constructionCostIndex: 1.0);
      final balanceBeforePermit = notifier.state.balance;
      final permitOk = notifier.submitSelfBuildMunicipalPermit(land.id);
      expect(permitOk, isTrue);
      final spentStep2 = balanceBeforePermit - notifier.state.balance;

      final spent = spentStep1 + spentStep2;
      expect(spent, closeTo(350000.0, 1.0));
      expect(notifier.state.ownedRealEstates.first.provenanceLog.last, contains('Hukuk Müşaviri %30 İndirimi'));

      container.dispose();
    });

    test('F2·6 & F5: Construction loan mortgages land and releases upon full repayment', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.stopPeriodicOrganicOfferTimer();

      final land = RealEstateModel(
        id: 'land_loan_test',
        title: 'Beylikdüzü Sanayi Arsası',
        category: RealEstateCategory.land,
        district: 'Beylikdüzü',
        city: 'İstanbul',
        squareMeters: 1000,
        roomCount: '-',
        buildingAge: 0,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
        baseMarketValue: 4000000.0,
        currentPurchasePrice: 4000000.0,
        isMortgaged: false,
      );

      notifier.state = notifier.state.copyWith(
        balance: 100000.0,
        ownedRealEstates: [land],
        activeLoans: [],
      );

      // Max loan is 50% = 2,000,000
      expect(land.canBeSold, isTrue);

      // Attempt loan over 50% fails
      final overLoan = notifier.takeConstructionLoan(land.id, 2500000.0);
      expect(overLoan, isFalse);

      // Valid loan succeeds
      final okLoan = notifier.takeConstructionLoan(land.id, 2000000.0);
      expect(okLoan, isTrue);

      final stateAfterLoan = notifier.state;
      expect(stateAfterLoan.balance, equals(2100000.0));
      expect(stateAfterLoan.activeLoans.length, equals(1));
      expect(stateAfterLoan.activeLoans.first.id, equals('loan_construction_${land.id}'));

      final mortgagedLand = stateAfterLoan.ownedRealEstates.first;
      expect(mortgagedLand.isMortgaged, isTrue);
      expect(mortgagedLand.canBeSold, isFalse); // Land is locked!

      // Repay loan
      // Increase balance to afford repayment (2,000,000 * 1.25 = 2,500,000)
      notifier.state = notifier.state.copyWith(balance: 5000000.0);
      final okRepay = notifier.repayConstructionLoan(land.id);
      expect(okRepay, isTrue);

      final stateAfterRepay = notifier.state;
      expect(stateAfterRepay.activeLoans.isEmpty, isTrue);
      final releasedLand = stateAfterRepay.ownedRealEstates.first;
      expect(releasedLand.isMortgaged, isFalse);
      expect(releasedLand.canBeSold, isTrue); // Land unlocked!

      container.dispose();
    });

    test('Simultaneous 7-language synchronization for all new Section F keys', () {
      final keys = [
        'real_estate_construction_cost_index_title',
        'real_estate_quality_score_label',
        'real_estate_mortgaged_badge',
        'real_estate_construction_loan_btn',
        'real_estate_construction_loan_repay_btn',
        'real_estate_construction_loan_dialog_title',
        'real_estate_construction_loan_dialog_desc',
        'real_estate_construction_loan_repay_dialog_desc',
        'real_estate_bureaucracy_legal_advisor_badge',
        'real_estate_loan_taken_toast',
        'real_estate_loan_repaid_toast',
      ];

      final translationMaps = {
        'tr': trTranslations,
        'en': enTranslations,
        'de': deTranslations,
        'pt': ptTranslations,
        'es': esTranslations,
        'ru': ruTranslations,
        'ar': arTranslations,
      };

      for (final key in keys) {
        for (final entry in translationMaps.entries) {
          final lang = entry.key;
          final map = entry.value;

          expect(map.containsKey(key), isTrue, reason: 'Key $key must exist in $lang');
          final val = map[key]!;
          expect(val.isNotEmpty, isTrue, reason: 'Key $key in $lang must not be empty');

          // Rule 1: Zero Unicode emojis
          final emojiRegex = RegExp(r'[\u{1F300}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]', unicode: true);
          expect(emojiRegex.hasMatch(val), isFalse, reason: 'Key $key in $lang has emoji: $val');

          // Rule 2: Zero parentheses (...)
          expect(val.contains('('), isFalse, reason: 'Key $key in $lang has opening parenthesis: $val');
          expect(val.contains(')'), isFalse, reason: 'Key $key in $lang has closing parenthesis: $val');
        }
      }
    });
  });
}
