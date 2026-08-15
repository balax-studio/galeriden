import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/data/models/dramatic_card_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/player_skills.dart';
import 'package:galeriden/data/models/side_business_model.dart';
import 'package:galeriden/data/models/staff_model.dart';
import 'package:galeriden/domain/usecases/dramatic_card_engine.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RPG Identity, Ownership & Dynasty Roadmap Tests (RPG_AIDIYET_MULKIYET_RAPORU.md)', () {
    late ProviderContainer container;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('§1.1 & §1.4 PlayerSkills getters, multipliers and disambiguated reputation', () {
      final skills = PlayerSkills(
        negotiationLevel: 5,
        eyeForDetail: 4,
        marketSense: 3,
        reputation: 6, // Network / Çevre
        financeSense: 4,
        xp: 1500,
      );

      // Multipliers verification
      expect(skills.negotiationMultiplier, closeTo(0.08, 0.001)); // (5-1)*0.02 = 0.08 (8%)
      expect(skills.expertiseCostDiscount, closeTo(0.15, 0.001)); // (4-1)*0.05 = 0.15 (15%)
      expect(skills.marketingDopingBonus, closeTo(0.30, 0.001));  // (3-1)*0.15 = 0.30 (30%)
      expect(skills.financeInterestDiscount, closeTo(0.03, 0.001)); // (4-1)*0.01 = 0.03 (3%)
      expect(skills.chequeRiskReduction, closeTo(0.015, 0.001)); // (4-1)*0.005 = 0.015 (1.5%)

      // SP spending calculations
      expect(skills.totalSkillPointsSpent, (5-1) + (4-1) + (3-1) + (6-1) + (4-1));
    });

    test('§1.3 & §2.3 Dynamic RPG Title generation based on Level and ReputationScore', () {
      // Level 1-2
      var model = DealershipModel.initial().copyWith(level: 1, reputationScore: 90);
      expect(model.rpgTitle, 'Dürüst Çırak');
      model = model.copyWith(level: 2, reputationScore: 50);
      expect(model.rpgTitle, 'Sanayi Çırağı');
      model = model.copyWith(level: 2, reputationScore: 20);
      expect(model.rpgTitle, 'Kurnaz Çırak');

      // Level 3-4
      model = model.copyWith(level: 3, reputationScore: 85);
      expect(model.rpgTitle, 'Güvenilir Esnaf');
      model = model.copyWith(level: 4, reputationScore: 30);
      expect(model.rpgTitle, 'Açıkgöz Galerici');

      // Level 5-7
      model = model.copyWith(level: 6, reputationScore: 85);
      expect(model.rpgTitle, 'Sanayinin Namuslu Adamı');
      model = model.copyWith(level: 6, reputationScore: 50);
      expect(model.rpgTitle, 'Usta Galerici');

      // Level 12+
      model = model.copyWith(level: 15, reputationScore: 95);
      expect(model.rpgTitle, 'Galeriler Şahı');
    });

    test('§2.1 CharacterOrigin perks: Sanayi Çırağı tamir indirimi, Tüccar Torunu alım indirimi', () {
      final notifier = container.read(gameProvider.notifier);

      final car = CarModel(
        id: 'test_car_rpg',
        brand: 'BMW',
        modelName: '320i',
        modelYear: 2020,
        bodyType: 'Sedan',
        colorHex: '0xFF000000',
        currentPurchasePrice: 200000.0,
        baseMarketValue: 250000.0,
        expertise: ExpertiseReport(
          engineCondition: 60.0,
          transmissionCondition: 100.0,
          tramerAmount: 0,
          mileage: 80000,
          isMileageTampered: false,
          bodyParts: const {},
        ),
      );

      // 1. Sanayi Çırağı -> -%15 Repair Cost
      notifier.state = notifier.state.copyWith(
        balance: 1000000.0,
        ownedCars: [car],
        characterOrigin: CharacterOrigin.sanayiCiragi,
        specializationPath: SpecializationPath.none,
      );

      final prevBalance = notifier.state.balance;
      final success = notifier.performWorkshopStationRepair(car.id, repairType: 'engine', cost: 10000.0);
      expect(success, isTrue);
      // Cost should be 10000 * 0.85 = 8500
      expect(notifier.state.balance, prevBalance - 8500.0);

      // 2. Tüccar Torunu -> -%8 Car Purchase Price
      notifier.state = notifier.state.copyWith(
        balance: 1000000.0,
        characterOrigin: CharacterOrigin.tuccarTorunu,
      );
      final buyPrevBalance = notifier.state.balance;
      final buyCar = CarModel(
        id: 'buy_car_2',
        brand: 'Audi',
        modelName: 'A3',
        modelYear: 2021,
        bodyType: 'Hatchback',
        colorHex: '0xFFFFFFFF',
        currentPurchasePrice: 100000.0,
        baseMarketValue: 120000.0,
        expertise: ExpertiseReport(
          engineCondition: 100.0,
          transmissionCondition: 100.0,
          tramerAmount: 0,
          mileage: 30000,
          isMileageTampered: false,
          bodyParts: const {},
        ),
      );
      notifier.buyCar(buyCar, 100000.0, isExpertiseCompleted: true);
      // Purchase price should be 100000 * 0.92 = 92000
      expect(notifier.state.balance, buyPrevBalance - 92000.0);
    });

    test('§2.2 Specialization Classes (Restorer, Trader, Boss) perks', () {
      final notifier = container.read(gameProvider.notifier);

      // Specialization Selection requires level >= 4
      notifier.state = notifier.state.copyWith(level: 2);
      expect(notifier.chooseSpecialization(SpecializationPath.trader), isFalse);

      notifier.state = notifier.state.copyWith(level: 5);
      expect(notifier.chooseSpecialization(SpecializationPath.boss), isTrue);
      expect(notifier.state.specializationPath, SpecializationPath.boss);

      // Boss Specialization: -%20 Staff Salary & +%30 Side Business Income
      final staff = StaffModel(
        id: 'staff_1',
        name: 'Mert Usta',
        role: StaffRole.masterMechanic,
        hiredAt: DateTime.now(),
      );

      final business = SideBusinessModel(
        id: 'sb_test',
        name: 'Oto Yıkama',
        description: 'Yıkama istasyonu',
        type: SideBusinessType.carWash,
        dailyIncome: 50000.0,
        cost: 50000.0,
        managerSalary: 0,
        managerCost: 0,
        isOwned: true,
      );

      notifier.state = notifier.state.copyWith(
        balance: 100000.0,
        hiredStaff: [staff],
        sideBusinesses: [business],
        specializationPath: SpecializationPath.boss,
      );

      // Advance Day -> Staff salary: 1000 * 0.80 = 800 deduction; Business income: 1000 * 1.30 = 1300 addition; net positive change
      final balanceBefore = notifier.state.balance;
      notifier.advanceGameDay();
      expect(notifier.state.balance > balanceBefore, isTrue);
    });

    test('§2.4 NPC Relationships: trust levels and perk thresholds', () {
      final notifier = container.read(gameProvider.notifier);

      expect(notifier.state.getNpcRelation('haydar_usta'), 50);
      expect(notifier.state.hasHighNpcTrust('haydar_usta'), isFalse);

      // Adjust trust
      notifier.adjustNpcRelationship('haydar_usta', 25);
      expect(notifier.state.getNpcRelation('haydar_usta'), 75);
      expect(notifier.state.hasHighNpcTrust('haydar_usta'), isTrue);

      // Clamping check
      notifier.adjustNpcRelationship('haydar_usta', 50);
      expect(notifier.state.getNpcRelation('haydar_usta'), 100);

      // Test Dramatic Card NPC trust mutation (§2.4)
      final necatiCard = DramaticCardModel.defaultCards.firstWhere((c) => c.id == 'A1');
      final giveChoice = necatiCard.choices.firstWhere((c) => c.id == 'A1_give');
      final result = DramaticCardEngine.resolveChoice(notifier.state, necatiCard, giveChoice, fixedRoll: 0.1);
      expect(result.updatedState.getNpcRelation('necati'), 85); // 50 + 35
    });

    test('§1.5 & §2.6 & §2.7 Showcase Lock & Dynasty Season Prestige Reset', () {
      final notifier = container.read(gameProvider.notifier);

      final regularCar = CarModel(
        id: 'car_regular',
        brand: 'Fiat',
        modelName: 'Egea',
        modelYear: 2021,
        bodyType: 'Sedan',
        colorHex: '0xFFFFFFFF',
        currentPurchasePrice: 150000.0,
        baseMarketValue: 180000.0,
        isLockedInShowcase: false,
        expertise: ExpertiseReport(
          engineCondition: 100.0,
          transmissionCondition: 100.0,
          tramerAmount: 0,
          mileage: 40000,
          isMileageTampered: false,
          bodyParts: const {},
        ),
      );

      final showcaseCar = CarModel(
        id: 'car_showcase_yadigar',
        brand: 'Mercedes-Benz',
        modelName: '190E 2.5-16 Evolution II',
        modelYear: 1990,
        bodyType: 'Klasik',
        colorHex: '0xFF111111',
        currentPurchasePrice: 500000.0,
        baseMarketValue: 750000.0,
        isRare: true,
        isLockedInShowcase: true,
        expertise: ExpertiseReport(
          engineCondition: 100.0,
          transmissionCondition: 100.0,
          tramerAmount: 0,
          mileage: 55000,
          isMileageTampered: false,
          bodyParts: const {},
        ),
      );

      notifier.state = notifier.state.copyWith(
        balance: 2500000.0,
        ownedCars: [regularCar, showcaseCar],
        dynastyGeneration: 1,
        characterOrigin: CharacterOrigin.sanayiCiragi,
      );

      // Perform Prestige Dynasty Reset
      notifier.performDynastySeasonReset(newOrigin: CharacterOrigin.koleksiyoncuYegeni);

      // Verify Dynasty State
      expect(notifier.state.dynastyGeneration, 2);
      expect(notifier.state.characterOrigin, CharacterOrigin.koleksiyoncuYegeni);
      expect(notifier.state.dynastyHistoryLog.isNotEmpty, isTrue);

      // Regular car must be wiped, but Showcase Locked Car MUST be preserved!
      expect(notifier.state.ownedCars.any((c) => c.id == regularCar.id), isFalse);
      expect(notifier.state.ownedCars.any((c) => c.id == showcaseCar.id), isTrue);
      expect(notifier.state.ownedCars.first.isLockedInShowcase, isTrue);
    });
  });
}
