import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galeriden/data/models/real_estate_category.dart';
import 'package:galeriden/data/models/real_estate_model.dart';
import 'package:galeriden/domain/usecases/construction_timeline_engine.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Construction Bug Fixes Suite (Contractor 0-Day & Self-Build Peyzaj)', () {
    test('1. Contractor Mode: Reaching 0 days sets isConstructionComplete = true and allows finalization', () {
      final land = RealEstateModel(
        id: 'land_contractor_bug_test',
        title: 'Kadıköy İnşaat Parseli',
        category: RealEstateCategory.land,
        city: 'İstanbul',
        district: 'Kadıköy',
        squareMeters: 600,
        roomCount: '-',
        buildingAge: 0,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
        baseMarketValue: 6000000,
        currentPurchasePrice: 6000000,
        constructionMode: 'contractor',
        constructionStage: 8,
        constructionDaysRemaining: 0,
        isConstructionWorking: true, // simulates ad speedup artifact
      );

      // Model must recognize completion even if isConstructionWorking was true
      expect(land.isConstructionComplete, isTrue);
      expect(land.constructionPercent, equals(100));

      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.stopPeriodicOrganicOfferTimer();

      notifier.state = notifier.state.copyWith(
        ownedRealEstates: [land],
        balance: 1000000,
      );

      final created = notifier.finalizeConstruction('land_contractor_bug_test');
      expect(created.isNotEmpty, isTrue);
      expect(notifier.state.ownedRealEstates.any((r) => r.id == 'land_contractor_bug_test'), isFalse);

      notifier.stopPeriodicOrganicOfferTimer();
      container.dispose();
    });

    test('2. Contractor Mode: Daily time progression loop runs Stage 8 and advances to completion', () {
      final land = RealEstateModel(
        id: 'land_contractor_stage7_test',
        title: 'Üsküdar İnşaat Parseli',
        category: RealEstateCategory.land,
        city: 'İstanbul',
        district: 'Üsküdar',
        squareMeters: 600,
        roomCount: '-',
        buildingAge: 0,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
        baseMarketValue: 6000000,
        currentPurchasePrice: 6000000,
        constructionMode: 'contractor',
        constructionStage: 7,
        constructionDaysRemaining: 1,
        contractorStageDays: 15,
        isConstructionWorking: false,
      );

      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.stopPeriodicOrganicOfferTimer();

      notifier.state = notifier.state.copyWith(
        ownedRealEstates: [land],
        balance: 1000000,
      );

      // Advance day: Stage 7 completes, advances to Stage 8 with 15 days
      notifier.advanceGameDay();

      var updatedLand = notifier.state.ownedRealEstates.firstWhere((r) => r.id == 'land_contractor_stage7_test');
      expect(updatedLand.constructionStage, equals(8));
      expect(updatedLand.constructionDaysRemaining, equals(15));
      expect(updatedLand.isConstructionComplete, isFalse);

      // Fast forward stage 8 to day 1 remaining
      notifier.state = notifier.state.copyWith(
        ownedRealEstates: [
          updatedLand.copyWith(constructionDaysRemaining: 1),
        ],
      );

      // Advance day: Stage 8 completes, advances to stage 9 (100% complete)
      notifier.advanceGameDay();

      updatedLand = notifier.state.ownedRealEstates.firstWhere((r) => r.id == 'land_contractor_stage7_test');
      expect(updatedLand.constructionStage, equals(9));
      expect(updatedLand.constructionDaysRemaining, equals(0));
      expect(updatedLand.isConstructionComplete, isTrue);

      notifier.stopPeriodicOrganicOfferTimer();
      container.dispose();
    });

    test('3. Self-Build Mode: Stage 7 completion advances to Stage 8 (Peyzaj) without getting stuck', () {
      final land = RealEstateModel(
        id: 'land_selfbuild_stage7_test',
        title: 'Beykoz Doğa Parseli',
        category: RealEstateCategory.land,
        city: 'İstanbul',
        district: 'Beykoz',
        squareMeters: 500,
        roomCount: '-',
        buildingAge: 0,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
        baseMarketValue: 5000000,
        currentPurchasePrice: 5000000,
        constructionMode: 'selfBuild',
        playerSharePercent: 100,
        constructionStage: 7,
        constructionDaysRemaining: 0,
        isConstructionWorking: false,
        activeSubcontractorName: 'Altyapı Ekibi',
        provenanceLog: [
          '2026-09-11 • Aşama 1 başarıyla teslim alındı ve denetimden geçti • Sonraki etaba hazır',
          '2026-09-11 • Aşama 2 başarıyla teslim alındı ve denetimden geçti • Sonraki etaba hazır',
          '2026-09-11 • Aşama 3 başarıyla teslim alındı ve denetimden geçti • Sonraki etaba hazır',
          '2026-09-11 • Aşama 4 başarıyla teslim alındı ve denetimden geçti • Sonraki etaba hazır',
          '2026-09-11 • Aşama 5 başarıyla teslim alındı ve denetimden geçti • Sonraki etaba hazır',
          '2026-09-11 • Aşama 6 başarıyla teslim alındı ve denetimden geçti • Sonraki etaba hazır',
        ],
      );

      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.stopPeriodicOrganicOfferTimer();

      notifier.state = notifier.state.copyWith(
        ownedRealEstates: [land],
        balance: 10000000,
      );

      // Complete stage 7
      final success7 = notifier.completeSelfBuildStage('land_selfbuild_stage7_test');
      expect(success7, isTrue);

      var updatedLand = notifier.state.ownedRealEstates.firstWhere((r) => r.id == 'land_selfbuild_stage7_test');
      // Must advance to Stage 8
      expect(updatedLand.constructionStage, equals(8));
      // Stage 8 is NOT yet complete; player must play Stage 8 (peyzaj & iskan)
      expect(updatedLand.isConstructionComplete, isFalse);
      expect(updatedLand.landPhase, equals(LandPhase.etapHazir));

      // Player starts Stage 8 with subcontractor
      final sub = ConstructionTimelineEngine.getSubcontractorsForStage(8)[0];
      final start8 = notifier.startSelfBuildStage(
        'land_selfbuild_stage7_test',
        subcontractor: sub,
        triggerIncidents: false,
      );
      expect(start8, isTrue);

      updatedLand = notifier.state.ownedRealEstates.firstWhere((r) => r.id == 'land_selfbuild_stage7_test');
      expect(updatedLand.isConstructionWorking, isTrue);
      expect(updatedLand.constructionDaysRemaining, greaterThan(0));

      // Fast forward Stage 8 days to 0
      notifier.state = notifier.state.copyWith(
        ownedRealEstates: [
          updatedLand.copyWith(
            constructionDaysRemaining: 0,
            isConstructionWorking: false,
          ),
        ],
      );

      // Handover Stage 8
      final success8 = notifier.completeSelfBuildStage('land_selfbuild_stage7_test');
      expect(success8, isTrue);

      final finishedLand = notifier.state.ownedRealEstates.firstWhere((r) => r.id == 'land_selfbuild_stage7_test');
      // Advanced to stage 9 (all 8 stages finished)
      expect(finishedLand.constructionStage, equals(9));
      expect(finishedLand.isConstructionComplete, isTrue);
      expect(finishedLand.landPhase, equals(LandPhase.teslimeHazir));

      // Finalize turnkey apartments
      final apartments = notifier.finalizeConstruction('land_selfbuild_stage7_test');
      expect(apartments.length, equals(finishedLand.playerShareUnits));

      notifier.stopPeriodicOrganicOfferTimer();
      container.dispose();
    });

    test('4. Finalize Construction: Auto-expands maxRealEstateSlots if portfolio capacity is reached', () {
      final land = RealEstateModel(
        id: 'land_slot_expansion_test',
        title: 'Pendik Mega Proje Parseli',
        category: RealEstateCategory.land,
        city: 'İstanbul',
        district: 'Pendik',
        squareMeters: 1000,
        roomCount: '-',
        buildingAge: 0,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
        baseMarketValue: 10000000,
        currentPurchasePrice: 10000000,
        constructionMode: 'contractor',
        constructionStage: 9,
        constructionDaysRemaining: 0,
        playerSharePercent: 60,
      );

      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.stopPeriodicOrganicOfferTimer();

      // Only 2 slots max, but project produces 4 units
      notifier.state = notifier.state.copyWith(
        maxRealEstateSlots: 2,
        ownedRealEstates: [land],
        balance: 500000,
      );

      final created = notifier.finalizeConstruction('land_slot_expansion_test');
      expect(created.length, equals(4));
      expect(notifier.state.maxRealEstateSlots, greaterThanOrEqualTo(4));
      expect(notifier.state.ownedRealEstates.length, equals(4));

      notifier.stopPeriodicOrganicOfferTimer();
      container.dispose();
    });

    test('5. Ownership Transfer Verification: Both contractor & self-build units transfer correctly with Kat Mülkiyeti deeds', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.stopPeriodicOrganicOfferTimer();

      // SCENARIO 1: Contractor Mode Handover
      final contractorLand = RealEstateModel(
        id: 'land_contractor_transfer_test',
        title: 'Kadıköy İnşaat Parseli',
        category: RealEstateCategory.land,
        city: 'İstanbul',
        district: 'Kadıköy',
        squareMeters: 600,
        roomCount: '-',
        buildingAge: 0,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
        baseMarketValue: 6000000,
        currentPurchasePrice: 6000000,
        constructionMode: 'contractor',
        constructionStage: 9,
        constructionDaysRemaining: 0,
        playerSharePercent: 50,
      );

      // SCENARIO 2: Self-Build Mode Handover (with 1 unit pre-sold)
      final selfBuildLand = RealEstateModel(
        id: 'land_selfbuild_transfer_test',
        title: 'Beşiktaş İnşaat Parseli',
        category: RealEstateCategory.land,
        city: 'İstanbul',
        district: 'Beşiktaş',
        squareMeters: 500,
        roomCount: '-',
        buildingAge: 0,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
        baseMarketValue: 8000000,
        currentPurchasePrice: 8000000,
        totalConstructionSpent: 4000000,
        constructionMode: 'selfBuild',
        constructionStage: 9,
        constructionDaysRemaining: 0,
        playerSharePercent: 100,
        soldPreSaleUnits: 1, // 1 unit was pre-sold
      );

      notifier.state = notifier.state.copyWith(
        ownedRealEstates: [contractorLand, selfBuildLand],
        balance: 10000000,
      );

      // Finalize Scenario 1 (Contractor)
      final contractorUnits = notifier.finalizeConstruction('land_contractor_transfer_test');
      expect(contractorUnits.isNotEmpty, isTrue);
      // Land removed from portfolio
      expect(notifier.state.ownedRealEstates.any((r) => r.id == 'land_contractor_transfer_test'), isFalse);
      // Turnkey units added to portfolio
      for (final unit in contractorUnits) {
        final ownedUnit = notifier.state.ownedRealEstates.firstWhere((r) => r.id == unit.id);
        expect(ownedUnit.category, equals(RealEstateCategory.housing));
        expect(ownedUnit.deedType, equals(DeedType.ownershipDeed)); // Kat Mülkiyeti
        expect(ownedUnit.buildingAge, equals(0));
        expect(ownedUnit.canBeRented, isTrue);
        expect(ownedUnit.canBeSold, isTrue);
        expect(ownedUnit.canBePersonalResidence, isTrue);
        expect(ownedUnit.isConstructionActive, isFalse);
        expect(ownedUnit.currentPurchasePrice, greaterThan(0));
        expect(ownedUnit.provenanceLog.isNotEmpty, isTrue);
        expect(ownedUnit.provenanceLog.first, contains('İnşaat tamamlandı'));
      }

      // Finalize Scenario 2 (Self-Build)
      final expectedUnitsCount = selfBuildLand.playerShareUnits;
      final selfBuildUnits = notifier.finalizeConstruction('land_selfbuild_transfer_test');
      expect(selfBuildUnits.length, equals(expectedUnitsCount));
      // Land removed from portfolio
      expect(notifier.state.ownedRealEstates.any((r) => r.id == 'land_selfbuild_transfer_test'), isFalse);
      // Turnkey units added to portfolio
      for (final unit in selfBuildUnits) {
        final ownedUnit = notifier.state.ownedRealEstates.firstWhere((r) => r.id == unit.id);
        expect(ownedUnit.category, equals(RealEstateCategory.housing));
        expect(ownedUnit.deedType, equals(DeedType.ownershipDeed));
        expect(ownedUnit.buildingAge, equals(0));
        expect(ownedUnit.canBeRented, isTrue);
        expect(ownedUnit.canBeSold, isTrue);
        expect(ownedUnit.isConstructionActive, isFalse);
        expect(ownedUnit.currentPurchasePrice, greaterThan(0));
        expect(ownedUnit.provenanceLog.isNotEmpty, isTrue);
      }

      notifier.stopPeriodicOrganicOfferTimer();
      container.dispose();
    });

    test('6. Construction Loan Repayment: Loan can be repaid even after land is finalized into apartments', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.stopPeriodicOrganicOfferTimer();

      final land = RealEstateModel(
        id: 'land_mortgage_transfer_test',
        title: 'Sarıyer Arsa Parseli',
        category: RealEstateCategory.land,
        city: 'İstanbul',
        district: 'Sarıyer',
        squareMeters: 500,
        roomCount: '-',
        buildingAge: 0,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
        baseMarketValue: 10000000,
        currentPurchasePrice: 10000000,
        constructionMode: 'contractor',
        constructionStage: 9,
        constructionDaysRemaining: 0,
        playerSharePercent: 50,
      );

      notifier.state = notifier.state.copyWith(
        ownedRealEstates: [land],
        balance: 5000000,
      );

      // Take a construction loan on the land
      final loanOk = notifier.takeConstructionLoan('land_mortgage_transfer_test', 2000000);
      expect(loanOk, isTrue);
      expect(notifier.state.activeLoans.any((l) => l.id == 'loan_construction_land_mortgage_transfer_test'), isTrue);

      // Finalize construction -> land turns into turnkey apartments
      final units = notifier.finalizeConstruction('land_mortgage_transfer_test');
      expect(units.isNotEmpty, isTrue);
      expect(notifier.state.ownedRealEstates.any((r) => r.id == 'land_mortgage_transfer_test'), isFalse);

      // Player gives loan repayment after units are already in portfolio
      final repayOk = notifier.repayConstructionLoan('land_mortgage_transfer_test');
      expect(repayOk, isTrue);
      expect(notifier.state.activeLoans.any((l) => l.id == 'loan_construction_land_mortgage_transfer_test'), isFalse);

      notifier.stopPeriodicOrganicOfferTimer();
      container.dispose();
    });

    test('7. Stage 8 Active Save with Days Remaining: displays Stage 8 active card, speedup works, and ETABI TESLİM AL triggers Stage 9', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.stopPeriodicOrganicOfferTimer();

      final stage8Land = RealEstateModel(
        id: 'land_stage8_active_save',
        title: 'Çankaya İnşaat Parseli',
        category: RealEstateCategory.land,
        city: 'Ankara',
        district: 'Çankaya',
        squareMeters: 600,
        roomCount: '-',
        buildingAge: 0,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
        baseMarketValue: 6000000,
        currentPurchasePrice: 6000000,
        constructionMode: 'selfBuild',
        constructionStage: 8,
        constructionDaysRemaining: 5,
        stageTotalDays: 10,
        isConstructionWorking: true,
        activeSubcontractorName: 'Peyzaj & İskan Ekibi',
        playerSharePercent: 100,
      );

      notifier.state = notifier.state.copyWith(
        ownedRealEstates: [stage8Land],
        balance: 10000000,
      );

      // Not yet complete because 5 days remain
      expect(stage8Land.isConstructionComplete, isFalse);
      expect(stage8Land.landPhase, equals(LandPhase.etapCalisiyor));

      // Speed up construction by 5 days (e.g. ad / double shift)
      final speedOk = notifier.accelerateConstructionTimer('land_stage8_active_save', daysToReduce: 5);
      expect(speedOk, isTrue);

      final readyLand = notifier.state.ownedRealEstates.firstWhere((r) => r.id == 'land_stage8_active_save');
      expect(readyLand.constructionDaysRemaining, equals(0));
      expect(readyLand.landPhase, equals(LandPhase.etapTeslimAlinir));

      // ETABI TESLİM AL step advances to Stage 9
      final completeOk = notifier.completeSelfBuildStage('land_stage8_active_save');
      expect(completeOk, isTrue);

      final finishedLand = notifier.state.ownedRealEstates.firstWhere((r) => r.id == 'land_stage8_active_save');
      expect(finishedLand.constructionStage, equals(9));
      expect(finishedLand.isConstructionComplete, isTrue);
      expect(finishedLand.landPhase, equals(LandPhase.teslimeHazir));

      // Finalize and claim deeds
      final apartments = notifier.finalizeConstruction('land_stage8_active_save');
      expect(apartments.isNotEmpty, isTrue);
      expect(notifier.state.ownedRealEstates.any((r) => r.id == 'land_stage8_active_save'), isFalse);

      notifier.stopPeriodicOrganicOfferTimer();
      container.dispose();
    });

    test('8. Stage 8 Save with 0 Days Remaining: can directly receive apartment title deeds', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.stopPeriodicOrganicOfferTimer();

      // Existing saved game with 0 days remaining
      final stage8DoneLand = RealEstateModel(
        id: 'land_stage8_zero_days',
        title: 'Bornova Arsa Projesi',
        category: RealEstateCategory.land,
        city: 'İzmir',
        district: 'Bornova',
        squareMeters: 500,
        roomCount: '-',
        buildingAge: 0,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
        baseMarketValue: 5000000,
        currentPurchasePrice: 5000000,
        constructionMode: 'contractor',
        constructionStage: 8,
        constructionDaysRemaining: 0,
        playerSharePercent: 60,
      );

      notifier.state = notifier.state.copyWith(
        ownedRealEstates: [stage8DoneLand],
        balance: 5000000,
      );

      // Instantly eligible to finalize and receive deeds
      expect(stage8DoneLand.isConstructionComplete, isTrue);
      expect(stage8DoneLand.landPhase, equals(LandPhase.teslimeHazir));

      final apartments = notifier.finalizeConstruction('land_stage8_zero_days');
      expect(apartments.length, equals(stage8DoneLand.playerShareUnits));
      for (final apt in apartments) {
        expect(apt.deedType, equals(DeedType.ownershipDeed)); // Kat Mülkiyeti tapusu
        expect(apt.category, equals(RealEstateCategory.housing));
      }

      notifier.stopPeriodicOrganicOfferTimer();
      container.dispose();
    });
  });
}
