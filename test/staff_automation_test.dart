import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/staff_model.dart';
import 'package:galeriden/domain/usecases/loan_settlement_engine.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Staff Automation & Daily Simulation Tests', () {
    late GameNotifier gameNotifier;
    late CarModel dirtyCar;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      gameNotifier = GameNotifier();
      await Future.delayed(const Duration(milliseconds: 100));

      dirtyCar = CarModel(
        id: 'test_dirty_car_1',
        brand: 'Merso',
        modelName: 'C200',
        modelYear: 2020,
        bodyType: 'Sedan',
        colorHex: '000000',
        baseMarketValue: 1200000,
        currentPurchasePrice: 1000000,
        customListingPrice: 1250000,
        isWashed: false,
        isPolished: false,
        isDetailedCleaned: false,
        expertise: ExpertiseReport(
          engineCondition: 60.0,
          transmissionCondition: 55.0,
          tramerAmount: 0,
          mileage: 50000,
          isMileageTampered: false,
          bodyParts: {},
        ),
      );

      final washer = StaffModel(
        id: 'staff_washer_1',
        name: 'Ali Usta',
        role: StaffRole.washer,
        hiredAt: DateTime(2026, 1, 1),
      );

      final mechanic = StaffModel(
        id: 'staff_mechanic_1',
        name: 'Hasan Usta',
        role: StaffRole.masterMechanic,
        hiredAt: DateTime(2026, 1, 1),
      );

      final salesman = StaffModel(
        id: 'staff_sales_1',
        name: 'Kemal Danışman',
        role: StaffRole.salesman,
        hiredAt: DateTime(2026, 1, 1),
      );

      gameNotifier.completeTutorial();
      gameNotifier.state = gameNotifier.state.copyWith(
        balance: 500000.0,
        ownedCars: [dirtyCar],
        hiredStaff: [washer, mechanic, salesman],
      );
    });

    tearDown(() {
      gameNotifier.dispose();
    });

    test('advanceGameDay automatically washes dirty cars if Washer staff is present', () {
      expect(gameNotifier.state.ownedCars.first.isWashed, isFalse);
      expect(gameNotifier.state.ownedCars.first.isPolished, isFalse);

      gameNotifier.advanceGameDay();

      final updatedCar = gameNotifier.state.ownedCars.first;
      expect(updatedCar.isWashed, isTrue);
      expect(updatedCar.isPolished, isTrue);
      expect(updatedCar.isDetailedCleaned, isTrue);
    });

    test('advanceGameDay automatically repairs low engine/transmission condition if Mechanic is present', () {
      expect(gameNotifier.state.ownedCars.first.expertise.engineCondition, equals(60.0));
      expect(gameNotifier.state.ownedCars.first.expertise.transmissionCondition, equals(55.0));

      gameNotifier.advanceGameDay();

      final updatedCar = gameNotifier.state.ownedCars.first;
      expect(updatedCar.expertise.engineCondition, equals(80.0));
      expect(updatedCar.expertise.transmissionCondition, equals(75.0));
    });

    test('advanceGameDay deducts daily staff salaries and property overhead accurately', () {
      final startingBalance = gameNotifier.state.balance;
      final totalDailySalary = gameNotifier.state.hiredStaff.fold(0.0, (sum, s) => sum + s.role.dailySalary);
      final dailyTax = LoanSettlementEngine.calculateDailyTax(
        gameNotifier.state.level,
        totalLiquidWealth: gameNotifier.state.balance + gameNotifier.state.bankDepositBalance,
      );

      gameNotifier.advanceGameDay();

      // Property burn (Level 1 = 300) + staff salaries + daily tax
      expect(gameNotifier.state.balance, equals(startingBalance - 300.0 - totalDailySalary - dailyTax));
      expect(gameNotifier.state.currentDay, equals(2));
    });
  });
}
