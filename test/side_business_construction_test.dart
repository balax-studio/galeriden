import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galeriden/data/models/side_business_model.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/domain/usecases/side_business_engine.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('Side Business Construction Duration Tests', () {
    test('Verifies base construction duration matrix across all business types', () {
      expect(SideBusinessType.vendingMachine.baseConstructionDays, 0);
      expect(SideBusinessType.billboard.baseConstructionDays, 1);
      expect(SideBusinessType.autoShop.baseConstructionDays, 2);
      expect(SideBusinessType.carWash.baseConstructionDays, 2);
      expect(SideBusinessType.towTruck.baseConstructionDays, 3);
      expect(SideBusinessType.sparePartsStore.baseConstructionDays, 3);
      expect(SideBusinessType.wrapStudio.baseConstructionDays, 3);
      expect(SideBusinessType.evCharging.baseConstructionDays, 4);
      expect(SideBusinessType.inspectionStation.baseConstructionDays, 4);
      expect(SideBusinessType.corporateExpertise.baseConstructionDays, 5);
      expect(SideBusinessType.carRental.baseConstructionDays, 5);
    });

    test('SideBusinessModel operational and progress getters work correctly', () {
      final business = SideBusinessModel(
        id: 'wash_1',
        name: 'Oto Yıkama',
        type: SideBusinessType.carWash,
        dailyIncome: 1200.0,
        cost: 150000.0,
        isOwned: true,
        isUnderConstruction: true,
        constructionDaysRemaining: 2,
        totalConstructionDays: 2,
      );

      expect(business.isOperational, false);
      expect(business.grossDailyIncome, 0.0);
      expect(business.effectiveDailyIncome, 0.0);
      expect(business.constructionProgress, 0.0);

      final progressed = business.copyWith(
        constructionDaysRemaining: 1,
      );
      expect(progressed.constructionProgress, 0.5);
      expect(progressed.isOperational, false);

      final finished = business.copyWith(
        isUnderConstruction: false,
        constructionDaysRemaining: 0,
      );
      expect(finished.isOperational, true);
      expect(finished.grossDailyIncome, greaterThan(0.0));
      expect(finished.effectiveDailyIncome, greaterThan(0.0));
      expect(finished.constructionProgress, 1.0);
    });

    test('Serialization correctly preserves construction fields in JSON round-trip', () {
      final model = SideBusinessModel(
        id: 'exp_1',
        name: 'Kurumsal Ekspertiz',
        type: SideBusinessType.corporateExpertise,
        dailyIncome: 4500.0,
        cost: 500000.0,
        isOwned: true,
        isUnderConstruction: true,
        constructionDaysRemaining: 3,
        totalConstructionDays: 5,
      );

      final json = model.toJson();
      expect(json['isUnderConstruction'], true);
      expect(json['constructionDaysRemaining'], 3);
      expect(json['totalConstructionDays'], 5);

      final restored = SideBusinessModel.fromJson(json);
      expect(restored.isUnderConstruction, true);
      expect(restored.constructionDaysRemaining, 3);
      expect(restored.totalConstructionDays, 5);
      expect(restored.isOperational, false);
    });
  });

  group('SideBusinessEngine Construction Gating Tests', () {
    test('Engine does not generate revenue for businesses under construction', () {
      final businesses = [
        SideBusinessModel(
          id: 'vending_1',
          name: 'Otomat',
          type: SideBusinessType.vendingMachine,
          dailyIncome: 500.0,
          cost: 20000.0,
          isOwned: true,
          isUnderConstruction: false,
        ),
        SideBusinessModel(
          id: 'wash_1',
          name: 'Oto Yıkama',
          type: SideBusinessType.carWash,
          dailyIncome: 2000.0,
          cost: 200000.0,
          isOwned: true,
          isUnderConstruction: true,
          constructionDaysRemaining: 2,
          totalConstructionDays: 2,
        ),
      ];

      final (newBalance, updated) = SideBusinessEngine.processDailyEarnings(
        balance: 10000.0,
        cars: [],
        businesses: businesses,
        specializationPath: SpecializationPath.none,
        carsWashedLast7Days: 0,
        expertisesPerformedLast7Days: 0,
        partsRepairedLast7Days: 0,
        towedCarsLast7Days: 0,
        activeRentalsCount: 0,
      );

      // Only vending machine earns income
      expect(updated[0].totalEarned, greaterThan(0.0));
      expect(updated[1].totalEarned, 0.0);
      expect(newBalance, greaterThan(10000.0));
    });
  });

  group('GameProvider Purchase and Rush Actions Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
      // Stop periodic timers to prevent test assertion issues (§6)
      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Buying side business initializes construction correctly', () {
      final notifier = container.read(gameProvider.notifier);

      // Give ample balance
      notifier.state = notifier.state.copyWith(balance: 1000000.0);

      // Find car wash business
      final carWash = notifier.state.sideBusinesses.firstWhere(
        (b) => b.type == SideBusinessType.carWash,
      );

      final buySuccess = notifier.buySideBusiness(carWash.id);
      expect(buySuccess, true);

      final updatedWash = notifier.state.sideBusinesses.firstWhere(
        (b) => b.id == carWash.id,
      );

      expect(updatedWash.isOwned, true);
      expect(updatedWash.isUnderConstruction, true);
      expect(updatedWash.constructionDaysRemaining, 2);
      expect(updatedWash.totalConstructionDays, 2);
      expect(updatedWash.isOperational, false);
    });

    test('Rushing construction instantly completes build and activates business', () {
      final notifier = container.read(gameProvider.notifier);
      notifier.state = notifier.state.copyWith(balance: 1000000.0);

      final carWash = notifier.state.sideBusinesses.firstWhere(
        (b) => b.type == SideBusinessType.carWash,
      );

      notifier.buySideBusiness(carWash.id);

      // Rush action
      final rushSuccess = notifier.completeSideBusinessConstruction(carWash.id);
      expect(rushSuccess, true);

      final updatedWash = notifier.state.sideBusinesses.firstWhere(
        (b) => b.id == carWash.id,
      );

      expect(updatedWash.isOwned, true);
      expect(updatedWash.isUnderConstruction, false);
      expect(updatedWash.constructionDaysRemaining, 0);
      expect(updatedWash.isOperational, true);
    });

    test('Advancing game days progresses and automatically completes construction', () {
      final notifier = container.read(gameProvider.notifier);
      notifier.state = notifier.state.copyWith(balance: 1000000.0);

      final carWash = notifier.state.sideBusinesses.firstWhere(
        (b) => b.type == SideBusinessType.carWash,
      );

      notifier.buySideBusiness(carWash.id);

      // Day 1
      notifier.advanceGameDay();
      var washState = notifier.state.sideBusinesses.firstWhere((b) => b.id == carWash.id);
      expect(washState.isUnderConstruction, true);
      expect(washState.constructionDaysRemaining, 1);

      // Day 2 (completes construction)
      notifier.advanceGameDay();
      washState = notifier.state.sideBusinesses.firstWhere((b) => b.id == carWash.id);
      expect(washState.isUnderConstruction, false);
      expect(washState.constructionDaysRemaining, 0);
      expect(washState.isOperational, true);
    });
  });
}
